const std = @import("std");
const zls = @import("zls");

const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");

const builtin = @import("builtin");

const types = zls.types;

const Context = struct {
    //
    const Config = zls.Config;
    const Server = zls.Server;

    const default_config: Config = .{
        .semantic_tokens = .partial,
        .enable_inlay_hints = false,
        .inlay_hints_exclude_single_argument = false,
        .inlay_hints_show_builtin = false,
        .zig_exe_path = null,
        .zig_lib_path = null,
        .global_cache_path = null,
    };

    server: *Server,
    source: [:0]const u8 = &[_:0]u8{},
    uri: []const u8 = &[_]u8{},

    pub fn init() !Context {
        const server = try Server.create(Heap.get());
        errdefer server.destroy();
        try server.updateConfiguration2(default_config);
        var ctx: Context = .{
            .server = server,
        };
        _ = try ctx.server.sendRequestSync(Heap.get(), "initialize", .{ .capabilities = .{} });
        _ = try ctx.server.sendNotificationSync(Heap.get(), "initialized", .{});
        return ctx;
    }

    pub fn deinit(self: *Context) void {
        _ = self.server.sendRequestSync(Heap.get(), "shutdown", {}) catch unreachable;
        self.server.sendNotificationSync(Heap.get(), "exit", {}) catch unreachable;
        std.debug.assert(self.server.status == .exiting_success);
        self.server.destroy();
    }

    pub fn addDoc(self: *Context, path: []const u8) !void {
        const norm = try Fs.normalize(path);
        self.uri = try std.fmt.allocPrint(
            Heap.get(),
            "file:///{s}",
            .{norm},
        );
        self.source = Fs.readFileZ(norm);
        const params = types.DidOpenTextDocumentParams{
            .textDocument = .{
                .uri = self.uri,
                .languageId = .{ .custom_value = "zig" }, // no zig :(
                .version = 420,
                .text = self.source,
            },
        };
        _ = try self.server.sendNotificationSync(Heap.get(), "textDocument/didOpen", params);
    }

    pub fn getSource(self: Context) [:0]const u8 {
        return self.source;
    }

    pub fn parseDoc(self: *Context) ![]const u32 {
        const params = types.SemanticTokensParams{
            .textDocument = .{ .uri = self.uri },
        };
        const rsp = try self.server.sendRequestSync(Heap.get(), "textDocument/semanticTokens/full", params) orelse {
            std.debug.print("Server returned `null` as the result\n", .{});
            return error.InvalidResponse;
        };
        return rsp.data;
    }
};

const SemTokStream = struct {
    data: []const u32,
    idx: usize = 0,
    line_num: u32 = 1,
    col_num: u32 = 1,
    pub const Token = struct {
        ttype: zls.semantic_tokens.TokenType,
        line: u32,
        col: u32,
        len: u32,
        tmods: u32,
    };
    pub fn init(data: []const u32) SemTokStream {
        return SemTokStream{
            .data = data,
        };
    }
    pub fn next(self: *SemTokStream) ?Token {
        if (self.idx >= self.data.len) return null;
        const chunk = self.data[self.idx .. self.idx + 5];
        self.idx += 5;
        if (chunk[0] > 0) {
            self.line_num += chunk[0];
            self.col_num = 1;
        }
        self.col_num += chunk[1];
        const tok = Token{
            .line = self.line_num,
            .col = self.col_num,
            .len = chunk[2],
            .ttype = @enumFromInt(chunk[3]),
            .tmods = chunk[4],
        };
        return tok;
    }
};

const SrcLines = struct {
    iter: std.mem.SplitIterator(u8, .scalar),
    pub fn init(src: []const u8) SrcLines {
        return SrcLines{
            .iter = std.mem.splitScalar(u8, src, '\n'),
        };
    }
    pub fn next(self: *SrcLines) ?[]const u8 {
        return self.iter.next();
    }
};

pub fn exec(path: []const u8) !void {
    var ctx = try Context.init();
    defer ctx.deinit();
    std.log.debug("\n", .{});
    try ctx.addDoc(path);
    // var lines = SrcLines.init(ctx.getSource());
    // while (lines.next()) |line| {
    //     std.log.debug("line: {s}", .{line});
    // }
    const toks = try ctx.parseDoc();
    var tok_str = SemTokStream.init(toks);
    while (tok_str.next()) |tok| {
        std.log.debug("{d:>3},{d:>3}:    {s} [{d}]", .{ tok.line, tok.col, @tagName(tok.ttype), tok.tmods });
        // switch (tok.ttype) {
        //     .function, .type => {
        //         std.log.debug("{d:>3},{d:>3}:    {s}", .{ tok.line, tok.col, @tagName(tok.ttype) });
        //     },
        //     else => {},
        // }
    }
}
