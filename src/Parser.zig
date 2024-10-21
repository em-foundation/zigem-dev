const std = @import("std");

const AstUtils = @import("AstUtils.zig");

const print = std.debug.print;

var ast: std.zig.Ast = undefined;

pub fn exec(path: []const u8) !void {
    ast = try AstUtils.parse(path);
    for (ast.rootDecls()) |idx| {
        const node = ast.nodes.get(idx);
        switch (node.tag) {
            .simple_var_decl => {
                const tok = ast.tokenSlice(node.main_token);
                if (!std.mem.eql(u8, tok, "const")) continue;
                const d = ast.simpleVarDecl(idx);
                if (d.ast.mut_token == 0) continue;
                const mut = ast.tokenSlice(d.ast.mut_token - 1);
                if (!std.mem.eql(u8, mut, "pub")) continue;
                const name = ast.tokenSlice(node.main_token + 1);
                if (!std.mem.eql(u8, name, "EM__META") and !std.mem.eql(u8, name, "EM__TARG")) continue;
                print("pub const {s}\n", .{name});
                walkScope(node.data.rhs);
            },
            else => {},
        }
    }
    // var iter = AstUtils.NodeIter.init(&ast);
    // while (try iter.next()) |val| {
    //     if (val.direction != .down) continue;
    //     const node = ast.nodes.get(val.idx);
    //     switch (node.tag) {
    //         .simple_var_decl => {
    //             const tok = ast.tokenSlice(node.main_token);
    //             if (!std.mem.eql(u8, tok, "const")) continue;
    //             const d = ast.simpleVarDecl(val.idx);
    //             if (d.ast.mut_token != 1) continue;
    //             const name = ast.tokenSlice(node.main_token + 1);
    //             print("pub const {s}\n", .{name});
    //         },
    //         else => {},
    //     }
    // }
}

fn walkScope(idx: u32) void {
    const node = ast.nodes.get(idx);
    var scope: std.zig.Ast.full.ContainerDecl = undefined;
    switch (node.tag) {
        .container_decl, .container_decl_trailing => {
            scope = ast.containerDecl(idx);
        },
        .container_decl_two, .container_decl_two_trailing => {
            var buf: [2]u32 = undefined;
            scope = ast.containerDeclTwo(&buf, idx);
        },
        else => return,
    }
    for (scope.ast.members) |mem_idx| {
        const mem_decl = ast.nodes.get(mem_idx);
        print("    {any}\n", .{mem_decl.tag});
    }
}
