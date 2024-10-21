const std = @import("std");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Out = @import("./Out.zig");

const Ast = std.zig.Ast;
const print = std.debug.print;

const UnitKind = enum {
    composite,
    interface,
    module,
    template,
};

const kindMap = std.StaticStringMap(UnitKind).initComptime(.{
    .{ "composite", UnitKind.composite },
    .{ "interface", UnitKind.interface },
    .{ "module", UnitKind.module },
    .{ "template", UnitKind.template },
});

var ast: Ast = undefined;
var file: *Out.File = undefined;
var lines: std.ArrayList([]const u8) = undefined;
var members: []const Ast.Node.Index = undefined;
var tab: []const u8 = undefined;

pub fn exec(path: []const u8, force: bool) !void {
    //
    const norm = try Fs.normalize(path);
    ast = try Ast.parse(Heap.get(), Fs.readFileZ(norm), .zig);
    if (ast.errors.len > 0) {
        const writer = std.io.getStdErr().writer();
        try writer.print("*** syntax error\n", .{});
        std.process.exit(1);
    }
    const src = try ast.render(Heap.get());

    const mark = std.mem.indexOf(u8, src, "//->>");
    const src_pre = if (mark) |m| src[0..m] else src;
    var digest: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(src_pre, &digest, .{});
    const hbuf = std.fmt.bytesToHex(digest, .lower);
    var done = false;
    if (mark) |m| {
        const suf = src[m..];
        const idx1 = std.mem.indexOf(u8, suf, "|").?;
        const suf1 = suf[idx1 + 1 ..];
        const idx2 = std.mem.indexOf(u8, suf1, "|").?;
        const suf2 = suf1[0..idx2];
        done = !force and std.mem.eql(u8, &hbuf, suf2);
    }

    // zigemTest();
    // print("exit.\n", .{});
    // std.process.exit(0);

    file = try Out.open(norm);
    defer file.close();
    if (done) {
        file.print("{s}", .{src});
        return;
    }

    const kind = findUnitKind();

    var src_hd: []const u8 = src_pre;
    var src_tl: []const u8 = "";

    if (kind == .template) {
        const gen_idx = findDecl("em__generateS");
        const gen_fn = ast.nodes.get(gen_idx);
        const gen_body = ast.nodes.get(gen_fn.data.rhs);
        const gen_blk = ast.nodes.get(gen_body.data.lhs);
        members = ast.containerDecl(gen_blk.data.lhs).ast.members;
        tab = "        ";
        src_tl = "    };\n}\n";
        if (mark == null) src_hd = src_hd[0 .. src_hd.len - src_tl.len];
    } else {
        members = ast.rootDecls();
        tab = "";
    }

    file.print("{s}\n{s}//->> zigem publish #|{s}|#\n", .{ src_hd, tab, hbuf });
    if (kind == .interface) try genSpec() else genDecls();
    file.print("\n{s}//->> zigem publish -- end of generated code\n", .{tab});
    file.print("{s}", .{src_tl});
}

fn astNode(idx: Ast.Node.Index) Ast.Node {
    return ast.nodes.get(idx);
}

fn findDecl(dname: []const u8) Ast.Node.Index {
    for (ast.rootDecls()) |idx| {
        const decl = ast.nodes.get(idx);
        if (std.mem.eql(u8, ast.tokenSlice(decl.main_token + 1), dname)) return idx;
    }
    return 0;
}

fn findUnitKind() UnitKind {
    const ud = ast.simpleVarDecl(ast.rootDecls()[1]);
    const init = ast.callFull(ud.ast.init_node);
    const fe = astNode(init.ast.fn_expr);
    const id = ast.tokenSlice(fe.data.rhs);
    return kindMap.get(id).?;
}

fn genDecls() void {
    for (members) |idx| {
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
                walkScope(name, node.data.rhs);
            },
            else => {},
        }
    }
}

fn genSpec() !void {
    const SCOPE: []const []const u8 = &.{ "EM__META", "EM__TARG" };
    const TAB4 = "    ";
    var fn_list = std.ArrayList([]const u8).init(Heap.get());
    for (SCOPE) |sname| {
        const sidx = findDecl(sname);
        if (sidx == 0) continue;
        const cidx = astNode(sidx).data.rhs;
        const node = astNode(cidx);
        var scope: std.zig.Ast.full.ContainerDecl = undefined;
        switch (node.tag) {
            .container_decl, .container_decl_trailing => {
                scope = ast.containerDecl(cidx);
            },
            .container_decl_two, .container_decl_two_trailing => {
                var buf: [2]Ast.Node.Index = undefined;
                scope = ast.containerDeclTwo(&buf, cidx);
            },
            else => return,
        }
        //
        for (scope.ast.members) |fld_idx| {
            var buf: [1]Ast.Node.Index = undefined;
            const fld = astNode(fld_idx);
            const fname = ast.tokenSlice(fld.main_token);
            file.print("\npub fn {s} (", .{fname});
            try fn_list.append(fname);
            const fn_proto = ast.fnProtoSimple(&buf, fld.data.lhs);
            var iter = fn_proto.iterate(&ast);
            var param_list = std.ArrayList(Ast.full.FnProto.Param).init(Heap.get());
            while (iter.next()) |par| try param_list.append(par);
            var sep: []const u8 = "";
            for (param_list.items) |par| {
                const pn = ast.tokenSlice(par.name_token.?);
                const pt = ast.getNodeSource(par.type_expr);
                file.print("{s}{s}: {s}", .{ sep, pn, pt });
                sep = ", ";
            }
            file.print(") {s} {{\n{s}// TODO\n", .{ ast.getNodeSource(fn_proto.ast.return_type), TAB4 });
            for (param_list.items) |par| {
                const pn = ast.tokenSlice(par.name_token.?);
                file.print("{s}_ = {s};\n", .{ TAB4, pn });
            }
            const rt = ast.getNodeSource(fn_proto.ast.return_type);
            file.print("{s}return em.std.mem.zeroes({s});\n}}\n", .{ TAB4, rt });
        }
    }
    //
    file.print(
        \\
        \\const em__Self = @This();
        \\
        \\pub const EM__SPEC = struct {{
        \\
    , .{});
    for (fn_list.items) |fname| {
        file.print("{1s}{0s}: *const @TypeOf(em__Self.{0s}) = &em__Self.{0s},\n", .{ fname, TAB4 });
    }
    file.print("}};\n", .{});
}

fn mkLines(txt: []const u8) !std.ArrayList([]const u8) {
    var res = std.ArrayList([]const u8).init(Heap.get());
    var iter = std.mem.splitScalar(u8, txt, '\n');
    while (iter.next()) |s| {
        try res.append(s);
    }
    return res;
}

fn walkFields(idx: Ast.Node.Index) void {
    const node = astNode(idx);
    var scope: std.zig.Ast.full.ContainerDecl = undefined;
    switch (node.tag) {
        .container_decl, .container_decl_trailing => {
            scope = ast.containerDecl(idx);
        },
        .container_decl_two, .container_decl_two_trailing => {
            var buf: [2]Ast.Node.Index = undefined;
            scope = ast.containerDeclTwo(&buf, idx);
        },
        else => return,
    }
    for (scope.ast.members) |fld_idx| {
        var buf: [1]Ast.Node.Index = undefined;
        const fld = astNode(fld_idx);
        const fname = ast.tokenSlice(fld.main_token);
        print("fn {s}\n", .{fname});
        const fn_proto = ast.fnProtoSimple(&buf, fld.data.lhs);
        var iter = fn_proto.iterate(&ast);
        while (iter.next()) |par| {
            const pn = ast.tokenSlice(par.name_token.?);
            const pt = ast.getNodeSource(par.type_expr);
            print("    {s}: {s}\n", .{ pn, pt });
        }
        print("ret {s}\n", .{ast.getNodeSource(fn_proto.ast.return_type)});
    }
}

fn walkScope(sname: []const u8, idx: Ast.Node.Index) void {
    file.print("\n{s}//->> {s} publics\n", .{ tab, sname });
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
        const mem_decl = astNode(mem_idx);
        if (!std.mem.eql(u8, ast.tokenSlice(mem_decl.main_token - 1), "pub")) continue;
        const dname = ast.tokenSlice(mem_decl.main_token + 1);
        if (std.mem.startsWith(u8, dname, "em__")) continue;
        file.print("{2s}pub const {0s} = {1s}.{0s};\n", .{ dname, sname, tab });
    }
}

fn zigemTest() void {
    if (findUnitKind()) |kind| {
        if (kind != .interface) return;
    }
    const idx = findDecl("EM__META");
    if (idx == 0) return;
    walkFields(astNode(idx).data.rhs);
}
