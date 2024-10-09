const std = @import("std");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Out = @import("./Out.zig");
const Props = @import("./Props.zig");

const makefile_txt = @embedFile("./makefile.txt");

pub const Mode = enum {
    CLEAN,
    COMPILE,
    REFRESH,
};

const ZIGEM_MAIN = ".zigem-main.zig";

var cur_mode: Mode = undefined;
var build_root: []const u8 = undefined;
var gen_root: []const u8 = undefined;
var out_root: []const u8 = undefined;
var work_root: []const u8 = undefined;

pub const ActivateParams = struct {
    work: []const u8,
    mode: Mode,
    bundle: ?[]const u8 = null,
    setup: ?[]const u8 = null,
};

pub fn activate(params: ActivateParams) !void {
    cur_mode = params.mode;
    work_root = try Fs.normalize(params.work);
    build_root = Fs.slashify(Fs.join(&.{ work_root, "zigem" }));
    gen_root = build_root;
    out_root = Fs.slashify(Fs.join(&.{ build_root, "out" }));
    Fs.delete(build_root);
    Fs.delete(Fs.slashify(Fs.join(&.{ work_root, ZIGEM_MAIN })));
    if (cur_mode == .CLEAN) {
        // legacy
        Fs.delete(Fs.slashify(Fs.join(&.{ work_root, ".gen" })));
        Fs.delete(Fs.slashify(Fs.join(&.{ work_root, ".out" })));
        Fs.delete(Fs.slashify(Fs.join(&.{ work_root, ".main-meta.zig" })));
        Fs.delete(Fs.slashify(Fs.join(&.{ work_root, ".main-targ.zig" })));
        return;
    }
    Fs.mkdirs(work_root, "zigem/out");
    Fs.chdir(work_root);
    Props.init(work_root, params.setup != null);
    try Props.addPackage("em.core");
    if (params.bundle) |bn| try Props.addPackage(bn);
    if (params.setup) |sn| try Props.addSetup(sn);
    try Props.addWorkspace();
    try Props.addPackage(getDistroPkg());
}

pub fn doBuild(upath: []const u8) !void {
    const uname = mkUname(upath);
    try genStub("meta", uname);
    try genStub("targ", uname);
}

pub fn doRefresh() !void {
    try genEmStub();
    try genMakefile();
    try genProps();
    try genMain();
    try genDomain();
    try genUnits();
}

fn genDomain() !void {
    var file = try Out.open(Fs.join(&.{ gen_root, "domain.zig" }));
    file.print(
        \\pub const Domain = enum {{META, TARG}};
        \\pub const DOMAIN: Domain = .META;
        \\
    , .{});
    file.close();
    //
    file = try Out.open(Fs.join(&.{ gen_root, "meta.zig" }));
    file.close();
    //
    file = try Out.open(Fs.join(&.{ gen_root, "targ.zig" }));
    file.close();
}

fn genEmStub() !void {
    var file = try Out.open(Fs.join(&.{ gen_root, "em.zig" }));
    const fmt =
        \\pub usingnamespace @import("../em.core/em.lang/em.zig");
        \\
        \\pub const gen_root = "{0s}";
        \\pub const out_root = "{1s}";
        \\
        \\pub const _domain_file = "{0s}/domain.zig";
        \\pub const _targ_file = "{0s}/targ.zig";
        \\
        \\pub const hal = @import("../{2s}/{3s}/hal.zig");
    ;
    file.print(fmt, .{ gen_root, out_root, getDistroPkg(), getDistroBuck() });
    file.close();
}

fn genMakefile() !void {
    var file = try Out.open(Fs.join(&.{ build_root, "makefile" }));
    file.print("{s}", .{makefile_txt});
    file.close();
}

fn genMain() !void {
    var file = try Out.open(Fs.join(&.{ work_root, ZIGEM_MAIN }));
    const txt =
        \\// GENERATED FILE -- do not edit!!!
        \\
        \\pub usingnamespace @import("zigem/em.zig");
        \\const domain_desc = @import("zigem/domain.zig");
        \\
        \\pub fn main() void {
        \\    if (domain_desc.DOMAIN == .META) @import("zigem/meta.zig").exec();
        \\}
        \\
        \\export fn zigem_main() void {
        \\    if (domain_desc.DOMAIN == .TARG) @import("zigem/targ.zig").exec();
        \\}
    ;
    file.print("{s}", .{txt});
    file.close();
}

fn genProps() !void {
    var file = try Out.open(Fs.join(&.{ gen_root, "props.zig" }));
    file.print("const std = @import(\"std\");\n\n", .{});
    file.print("pub const map = std.StaticStringMap([]const u8).initComptime(.{{\n", .{});
    var ent_iter = Props.getProps().iterator();
    while (ent_iter.next()) |e| {
        file.print("    .{{ \"{s}\", \"{s}\" }},\n", .{ e.key_ptr.*, e.value_ptr.* });
    }
    file.print("}});\n", .{});
    file.close();
}

fn genStub(kind: []const u8, uname: []const u8) !void {
    // zigem/<kind>.zig
    const fn1 = try sprint("{s}.zig", .{kind});
    var file = try Out.open(Fs.join(&.{ gen_root, fn1 }));
    const fmt =
        \\const em = @import("./em.zig");
        \\
        \\pub fn exec() void {{
        \\    @import("../em.core/em.lang/{0s}-main.zig").exec(em.import.@"{1s}".em__U) catch em.fail();
        \\}}
    ;
    file.print(fmt, .{ kind, uname });
    file.close();
}

fn genUnits() !void {
    const distro_buck = getDistroBuck();
    var buck_set = std.StringArrayHashMap(void).init(Heap.get());
    var type_map = std.StringArrayHashMap([]const u8).init(Heap.get());
    var file = try Out.open(Fs.join(&.{ gen_root, "imports.zig" }));
    const pre =
        \\const em = @import("./em.zig");
        \\
        \\
    ;
    file.print(pre, .{});
    for (Props.getPackages().items) |pkgpath| {
        var iter = Fs.openDir(pkgpath).iterate();
        const pkgname = Fs.basename(pkgpath);
        while (try iter.next()) |ent| {
            if (ent.kind != .directory) continue;
            const buckname = ent.name;
            const is_distro = std.mem.eql(u8, buckname, distro_buck);
            if (buck_set.contains(buckname)) continue;
            try buck_set.put(buckname, {});
            var iter2 = Fs.openDir(Fs.join(&.{ pkgpath, ent.name })).iterate();
            while (try iter2.next()) |ent2| {
                if (ent2.kind != .file) continue;
                const idx = std.mem.indexOf(u8, ent2.name, ".em.zig");
                if (idx == null) continue;
                file.print("pub const @\"{0s}/{1s}\" = @import(\"../{2s}/{0s}/{3s}\");\n", .{ buckname, ent2.name[0..idx.?], pkgname, ent2.name });
                const tn = try sprint("{s}.{s}.{s}.em", .{ pkgname, buckname, ent2.name[0..idx.?] });
                const un = try sprint("{s}/{s}", .{ buckname, ent2.name[0..idx.?] });
                try type_map.put(tn, un);
                if (!is_distro) continue;
                file.print("pub const @\"em__distro/{1s}\" = @import(\"../{2s}/{0s}/{3s}\");\n", .{ buckname, ent2.name[0..idx.?], pkgname, ent2.name });
            }
        }
    }
    file.close();
    //
    file = try Out.open(Fs.join(&.{ gen_root, "type_map.zig" }));
    for (type_map.keys()) |tn| {
        const un = type_map.get(tn).?;
        file.print("pub const @\"{s}\" = \"{s}\";\n", .{ tn, un });
    }
    file.print("\n", .{});
    for (type_map.keys()) |tn| {
        const un = type_map.get(tn).?;
        file.print("pub const @\"{s}\" = \"{s}\";\n", .{ un, tn });
    }
    file.close();
    //
    file = try Out.open(Fs.join(&.{ gen_root, "unit_names.zig" }));
    file.print("pub const UnitName = enum{{\n", .{});
    for (type_map.keys()) |tn| {
        const un = type_map.get(tn).?;
        file.print("    @\"{s}\",\n", .{un});
    }
    file.print("}};\n", .{});
    file.close();
}

pub fn getBoard() []const u8 {
    return Props.getProps().get("em.lang.BoardKind").?;
}

fn getDistroPkg() []const u8 {
    const distro = Props.getProps().get("em.lang.Distro").?;
    return distro[0..std.mem.indexOf(u8, distro, "://").?];
}

fn getDistroBuck() []const u8 {
    const distro = Props.getProps().get("em.lang.Distro").?;
    return distro[std.mem.indexOf(u8, distro, "://").? + 3 ..];
}

pub fn getSetup() []const u8 {
    return Props.getProps().get("em.lang.SetupExtends").?;
}

pub fn getOutRoot() []const u8 {
    return out_root;
}

fn mkUname(upath: []const u8) []const u8 {
    const idx = std.mem.indexOf(u8, upath, ".em.zig");
    if (idx == null) return upath;
    return upath[0..idx.?];
}

fn sprint(comptime fmt: []const u8, args: anytype) ![]const u8 {
    return try std.fmt.allocPrint(Heap.get(), fmt, args);
}
