const em = @import("../../zigem/em.zig");
const std = @import("std");

const type_map = @import("../../zigem/type_map.zig");

var used_set = std.StringHashMap(void).init(em.getHeap());

inline fn callAll(comptime fname: []const u8, ulist: []const em.Unit, filter_used: bool) void {
    inline for (ulist) |u| {
        if (!filter_used or used_set.contains(u.upath)) {
            const U = u.scope();
            if (@hasDecl(U, fname)) {
                _ = @call(.auto, @field(U, fname), .{});
            } else if (@hasDecl(U, "EM__META") and @hasDecl(U.EM__META, fname)) {
                _ = @call(.auto, @field(U.EM__META, fname), .{});
            }
        }
    }
}

pub fn exec(top: em.Unit) !void {
    const BuildH = em.import.@"em__distro/BuildH";
    @setEvalBranchQuota(100_000);
    const ulist_bot = mkUnitList(top, mkUnitList(BuildH.em__U, &.{}));
    const ulist_top = revUnitList(ulist_bot);
    callAll("em__initM", ulist_bot, false);
    callAll("em__configureM", ulist_top, false);
    try mkUsedSet(top);
    try mkUsedSet(BuildH.em__U);
    callAll("em__constructM", ulist_top, false);
    callAll("em__generateM", ulist_top, false);
    try genTarg(top, ulist_bot, ulist_top);
    std.process.exit(0);
}

fn genCall(comptime fname: []const u8, ulist: []const em.Unit, mode: enum { all, first }, out: std.fs.File.Writer) !void {
    inline for (ulist) |u| {
        const U = u.resolve();
        comptime var pre_o: ?[]const u8 = null;
        if (@hasDecl(U, fname)) pre_o = "";
        if (@hasDecl(U, "EM__TARG") and @hasDecl(U.EM__TARG, fname)) pre_o = "EM__TARG.";
        if (pre_o) |pre| {
            try out.print("    ", .{});
            try genImport(u.upath, out);
            try out.print(".{s}{s}();\n", .{ pre, fname });
            if (mode == .first) break;
        }
    }
}

fn genConfig(unit: em.Unit, out: std.fs.File.Writer) !void {
    const U = unit.resolve();
    if (!@hasDecl(U, "em__C")) return;
    const C = @field(U, "em__C");
    const cti = @typeInfo(@TypeOf(C));
    inline for (cti.Struct.fields) |fld| {
        const cfld = @field(C, fld.name);
        try out.print("{s}", .{em.em__F_toStringPre(cfld, unit.upath, fld.name)});
    }
    const cfgpath = if (!unit.generated) unit.upath else mkConfigPath(@typeName(@TypeOf(C)));
    try out.print("pub const @\"{s}__config\" = em.import.@\"{s}\".EM__CONFIG{{\n", .{ unit.upath, cfgpath });
    inline for (cti.Struct.fields) |fld| {
        const cfld = @field(C, fld.name);
        try out.print("    .{s} = {s},\n", .{ fld.name, em.em__F_toStringAux(cfld) });
    }
    try out.print("}};\n", .{});
}

fn genImport(path: []const u8, out: std.fs.File.Writer) !void {
    var it = std.mem.splitSequence(u8, path, "__");
    const un = it.first();
    if (std.mem.eql(u8, un, "em")) {
        try out.print("em", .{});
    } else {
        try out.print("em.import.@\"{s}\"", .{un});
    }
    while (it.next()) |seg| {
        try out.print(".{s}", .{seg});
    }
}

fn genExit(ulist: []const em.Unit, out: std.fs.File.Writer) !void {
    try out.print("pub fn em__exit() void {{\n", .{});
    try genCall("em__onexit", ulist, .all, out);
    try out.print("em__halt();\n", .{});
    try out.print("}}\n", .{});
}

fn genTarg(cur_top: em.Unit, ulist_bot: []const em.Unit, ulist_top: []const em.Unit) !void {
    const file = try std.fs.createFileAbsolute(em._targ_file, .{});
    const out = file.writer();
    const fmt =
        \\pub const _em_targ = {{}};
        \\
        \\const em = @import("em.zig");
        \\const std = @import("std");
        \\
        \\
    ;
    try out.print(fmt, .{});
    inline for (ulist_bot) |u| {
        if (u.kind == .module and !u.meta_only and !u.legacy) {
            //const @"// -------- BUILTIN FXNS -------- //" = {};

            try out.print("const @\"// {0s} {1s} {0s} //\" = {{}};\n\n", .{ "-" ** 8, u.upath });
            //try out.print("// {0s} {1s} {0s}\n", .{ "=" ** 8, u.upath });
            try genConfig(u, out);
            try out.print("\n", .{});
        }
    }
    const fmt2 =
        \\pub fn em__done() void {{
        \\    var dummy: u32 = 0xCAFE;
        \\    const vp: *volatile u32 = &dummy;
        \\    while (true) {{
        \\        if (vp.* != 0) continue;
        \\    }}
        \\}}
        \\
    ;
    try out.print(fmt2, .{});
    try genTermFn("em__fail", ulist_top, out);
    try genTermFn("em__halt", ulist_top, out);
    try genExit(ulist_top, out);
    try out.print("pub fn exec() void {{\n", .{});
    try genCall("em__reset", ulist_top, .first, out);
    try genCall("em__startup", ulist_bot, .all, out);
    try genCall("em__ready", ulist_top, .first, out);
    try out.print("    asm volatile (\".global __em__run\");\n", .{});
    try out.print("    asm volatile (\"__em__run:\");\n", .{});
    try out.print("    ", .{});
    try genImport(cur_top.upath, out);
    try out.print(".EM__TARG.em__run();\n", .{});
    try out.print("    em__halt();\n", .{});
    try out.print("}}\n", .{});
    file.close();
}

fn genTermFn(comptime name: []const u8, ulist: []const em.Unit, out: std.fs.File.Writer) !void {
    try out.print("pub fn {s}() void {{\n", .{name});
    try genCall(name, ulist, .first, out);
    try out.print("    em__done();\n", .{});
    try out.print("}}\n", .{});
}

fn mkConfigPath(comptime tn: []const u8) []const u8 {
    const idx = comptime std.mem.lastIndexOf(u8, tn, ".").?;
    const tun = comptime tn[0..idx];
    return @as([]const u8, @field(type_map, tun));
}

fn mkUnitList(comptime unit: em.Unit, comptime ulist: []const em.Unit) []const em.Unit {
    comptime var res = ulist;
    inline for (ulist) |u| {
        if (std.mem.eql(u8, u.upath, unit.upath)) return res;
    }
    const U = unit.resolve();
    std.debug.assert(@typeInfo(U) == .Struct);
    if (!unit.legacy) {
        inline for (@typeInfo(U).Struct.decls) |d| {
            const iu = @field(U, d.name);
            if (@TypeOf(iu) == type and @typeInfo(iu) == .Struct and @hasDecl(iu, "em__U")) {
                res = mkUnitList(@as(em.Unit, @field(iu, "em__U")), res);
            }
        }
    }
    return res ++ .{unit};
}

fn mkUsedSet(comptime unit: em.Unit) !void {
    if (unit.kind == .composite or unit.kind == .template) return;
    if (!unit.legacy) {
        try used_set.put(unit.upath, {});
        const U = unit.resolve();
        inline for (@typeInfo(U).Struct.decls) |d| {
            const decl = @field(U, d.name);
            const Decl = @TypeOf(decl);
            if (Decl == type and @typeInfo(decl) == .Struct and @hasDecl(decl, "em__U")) {
                try mkUsedSet(@as(em.Unit, @field(decl, "em__U")));
            }
        }
        // TODO: handle em.Proxy configs
    }
}

fn revUnitList(comptime ulist: []const em.Unit) []const em.Unit {
    comptime var res: []const em.Unit = &.{};
    inline for (ulist) |u| {
        res = .{u} ++ res;
    }
    return res;
}
