const @"// -------- EXECUTION DOMAIN -------- //" = {};

const domain_desc = @import("../../zigem/domain.zig");
pub const Domain = domain_desc.Domain;
pub const DOMAIN = domain_desc.DOMAIN;

pub const IS_META = (DOMAIN == .META);

fn declare_META() void {
    comptime {
        if (!IS_META) unreachable;
    }
}

fn declare_TARG() void {
    comptime {
        if (IS_META) unreachable;
    }
}

pub const @" ---- META ---- " = declare_META;
pub const @" ---- TARG ---- " = declare_TARG;

const @"// -------- UNIT SPEC -------- //" = {};

pub const UnitName = @import("../../zigem/unit_names.zig").UnitName;

pub fn asI(I: type, U: type) I.EM__SPEC {
    comptime {
        if (!U.em__U.hasInterface(I.em__U)) {
            @compileError(std.fmt.comptimePrint("{s} does not inherit {s}", .{ U.em__U.upath, I.em__U.upath }));
        }
    }
    return mkIobj(I.EM__SPEC, U);
}

fn mkUnit(This: type, kind: UnitKind, opts: UnitOpts) Unit {
    const un = if (opts.name != null) opts.name.? else @as([]const u8, @field(type_map, @typeName(This)));
    return Unit{
        ._U = This,
        .generated = opts.generated,
        .meta_only = opts.meta_only,
        .inherits = if (opts.inherits == void) null else opts.inherits.em__U,
        .Itab = if (kind == .interface) ItabType(This) else void,
        .IT = if (@hasDecl(This, "em__I")) This.em__I else void,
        .kind = kind,
        .legacy = opts.legacy,
        .upath = un,
    };
}

pub fn ItabType(T: type) type {
    comptime {
        const ti = @typeInfo(T);
        var fdeclem__list: []const std.builtin.Type.Declaration = &.{};
        for (ti.Struct.decls) |decl| {
            if (!isBuiltin(decl.name)) {
                const dval = @field(T, decl.name);
                const dti = @typeInfo(@TypeOf(dval));
                if (dti == .Fn) fdeclem__list = fdeclem__list ++ ([_]std.builtin.Type.Declaration{decl})[0..];
            }
        }
        var fldem__list: [fdeclem__list.len]std.builtin.Type.StructField = undefined;
        for (fdeclem__list, 0..) |fdecl, i| {
            const func = @field(T, fdecl.name);
            const func_ptr = &func;
            fldem__list[i] = std.builtin.Type.StructField{
                .name = fdecl.name,
                .type = *const @TypeOf(func),
                .default_value = @ptrCast(&func_ptr),
                .is_comptime = false,
                .alignment = 0,
            };
        }
        const fldem__list_freeze = fldem__list;
        return @Type(.{ .Struct = .{
            .layout = .auto,
            .fields = fldem__list_freeze[0..],
            .decls = &.{},
            .is_tuple = false,
            .backing_integer = null,
        } });
    }
}

pub fn mkIobj(Itab: type, U: type) Itab {
    var iobj = Itab{};
    const ti = @typeInfo(Itab);
    inline for (ti.Struct.fields) |fld| {
        if (@hasDecl(U, fld.name)) {
            @field(iobj, fld.name) = @field(U, fld.name);
        }
    }
    const iobj_freeze = iobj;
    return iobj_freeze;
}

pub fn composite(This: type, opts: UnitOpts) Unit {
    return mkUnit(This, .composite, opts);
}

pub fn interface(This: type, opts: UnitOpts) Unit {
    return mkUnit(This, .interface, opts);
}

pub fn module(This: type, opts: UnitOpts) Unit {
    return mkUnit(This, .module, opts);
}

pub fn template(This: type, opts: UnitOpts) Unit {
    return mkUnit(This, .template, opts);
}

pub const UnitKind = enum {
    composite,
    interface,
    module,
    template,
};

pub const UnitOpts = struct {
    name: ?[]const u8 = null,
    meta_only: bool = false,
    legacy: bool = false,
    generated: bool = false,
    inherits: type = void,
};

pub const Unit = struct {
    const Self = @This();

    _U: type,
    kind: UnitKind,
    upath: []const u8,
    meta_only: bool = false,
    legacy: bool = false,
    generated: bool = false,
    inherits: ?Unit,
    Itab: type,
    IT: type,

    pub fn config(self: Self, comptime CT: type) CT {
        switch (DOMAIN) {
            .META, .TARG_CHECK => {
                return initConfig(CT, self.upath);
            },
            .TARG => {
                return @field(targ, self.extendPath("config"));
            },
        }
    }

    fn extendPath(self: Self, comptime name: []const u8) []const u8 {
        return self.upath ++ "__" ++ name;
    }

    pub fn failif(self: Self, cond: bool, msg: []const u8) void {
        if (!cond) return;
        std.log.err("{s}: {s}", .{ self.upath, msg });
        fail();
    }

    pub fn fxn(self: Self, name: []const u8, FT: type) Fxn(FT) {
        return Fxn(FT){ .em__upath = self.upath, .em__fname = name };
    }

    pub fn Generate(self: Self, as_name: []const u8, comptime Template_Unit: type) type {
        return Template_Unit.em__generateS(self.extendPath(as_name));
    }

    pub fn hasInterface(self: Self, inter: Unit) bool {
        if (self.kind == .interface and std.mem.eql(u8, self.upath, inter.upath)) return true;
        comptime var iu = self.inherits;
        inline while (iu) |iuval| : (iu = iuval.inherits) {
            if (std.mem.eql(u8, iuval.upath, inter.upath)) return true;
        }
        return false;
    }

    pub fn resolve(self: Self) type {
        var it = std.mem.splitSequence(u8, self.upath, "__");
        var U = @field(import, it.first());
        inline while (it.next()) |seg| {
            U = @field(U, seg);
        }
        return U;
    }

    pub fn scope(self: Self) type {
        return self.resolve();
    }
};

fn unitTypeName(unit: type) []const u8 {
    const tn: []const u8 = @typeName(unit);
    return tn[0 .. tn.len - 3];
}

const @"// -------- CONFIG FLDS -------- //" = {};

fn initConfig(CT: type, upath: []const u8) CT {
    comptime {
        var new_c: CT = undefined;
        const cti = @typeInfo(CT);
        for (cti.Struct.fields, 0..) |fld, idx| {
            if (std.mem.eql(u8, fld.name, "em__upath")) {
                @field(new_c, fld.name) = upath;
            } else {
                const fti = @typeInfo(fld.type);
                switch (fti) {
                    .Struct => {
                        @field(new_c, fld.name) = std.mem.zeroInit(fld.type, .{});
                    },
                    .Pointer => {
                        const FT = fti.Pointer.child;
                        const fval = &struct {
                            var o = blk: {
                                const cid: *const CfgId = &.{ .un = upath, .cn = fld.name, .fi = idx };
                                break :blk std.mem.zeroInit(FT, .{ .em__cfgid = cid });
                            };
                        }.o;
                        @field(new_c, fld.name) = fval;
                    },
                    else => unreachable,
                }
            }
        }
        const res = new_c;
        return res;
    }
}

const CfgId = struct {
    un: []const u8,
    cn: []const u8,
    fi: usize,
};

pub fn Factory(T: type) type {
    return *Factory_S(T);
}

pub fn Factory_S(T: type) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};

        const _ItemsType = [](T);
        const _ListType = if (IS_META) std.ArrayList(T) else _ItemsType;

        const _LIST_INIT = if (IS_META) _ListType.init(arena.allocator()) else undefined;

        em__cfgid: ?*const CfgId = null,
        em__dname: []const u8 = undefined,
        em__list: _ListType = _LIST_INIT,

        pub fn createM(self: *Self, init: anytype) Obj(T) {
            declare_META();
            const l = self.em__list.items.len;
            self.em__list.append(std.mem.zeroInit(T, init)) catch fail();
            const o = Obj(T){ .em__fty = self, .em__idx = l };
            return o;
        }

        pub fn items(self: *Self) _ItemsType {
            return self.em__list;
        }

        pub fn itemsM(self: *Self) _ItemsType {
            declare_META();
            return self.em__list.items;
        }

        pub fn em__F_toString(self: *const Self) []const u8 {
            declare_META();
            return sprint("@constCast(&em.Factory_S({s}){{.em__list = &@\"{s}__OBJARR\"}})", .{
                mkTypeName(T),
                self.em__dname,
            });
        }

        pub fn em__F_toStringDecls(self: *Self, comptime upath: []const u8, comptime cname: []const u8) []const u8 {
            declare_META();
            self.em__dname = upath ++ "_em__C_" ++ cname;
            var sb = StringM{};
            const tn = mkTypeName(T);
            sb.addM(sprint("pub var @\"{s}__OBJARR\" = [_]{s}{{\n", .{ self.em__dname, tn }));
            for (self.em__list.items) |e| {
                sb.addM(sprint("    {s},\n", .{em__F_toStringAux(e)}));
            }
            sb.addM("};\n");
            const size_txt =
                \\export const @"{0s}__BASE" = &@"{0s}__OBJARR";
                \\const @"{0s}__SIZE" = std.fmt.comptimePrint("{{d}}", .{{@sizeOf({1s})}});
                \\
                \\
            ;
            sb.addM(sprint(size_txt, .{ self.em__dname, tn }));
            for (0..self.itemsM().len) |i| {
                const abs_txt =
                    \\comptime {{
                    \\    asm (".globl \"{0s}${1d}\"");
                    \\    asm ("\"{0s}${1d}\" = \"zigem.targ.{0s}__OBJARR\" + {1d} * " ++ @"{0s}__SIZE");
                    \\}}
                    \\extern const @"{0s}${1d}": usize;
                    \\const @"{0s}__{1d}": *{2s} = @constCast(@ptrCast(&@"{0s}${1d}"));
                    \\
                    \\
                ;
                sb.addM(sprint(abs_txt, .{ self.em__dname, i, tn }));
            }
            return sb.getM();
        }
    };
}

pub fn Fxn(PT: type) type {
    switch (DOMAIN) {
        .META => {
            return struct {
                const Self = @This();
                pub const _em__builtin = {};
                em__upath: []const u8,
                em__fname: []const u8,
                pub fn em__F_toString(self: Self) []const u8 {
                    if (self.em__fname.len == 0) {
                        return "null";
                    } else {
                        return sprint("{s}.EM__TARG.{s}", .{ mkUnitImport(self.em__upath), self.em__fname });
                    }
                }
                pub fn em__F_typeName() []const u8 {
                    return sprint("em.Fxn({s})", .{mkTypeName(PT)});
                }
            };
        },
        .TARG, .TARG_CHECK => return Fxn_T(PT),
    }
}

pub fn Fxn_T(PT: type) type {
    return ?*const fn (params: PT) void;
}

pub fn Obj(T: type) type {
    return if (DOMAIN == .META) Obj_S(T) else *T;
}

pub fn Obj_S(T: type) type {
    return struct {
        const Self = @This();
        pub const _em__builtin = {};
        em__fty: ?Factory(T) = undefined,
        em__idx: usize,
        pub fn getIdxM(self: *const Self) usize {
            return self.em__idx;
        }
        pub fn objM(self: *const Self) *T {
            return @constCast(&self.em__fty.?.itemsM()[self.em__idx]);
        }
        pub fn em__F_toString(self: *const Self) []const u8 {
            return if (self.em__fty == null) "null" else sprint("@\"{s}__{d}\"", .{ self.em__fty.?.em__dname, self.em__idx });
        }
        pub fn em__F_typeName() []const u8 {
            return sprint("*{s}", .{mkTypeName(T)});
        }
    };
}

pub fn Param(T: type) type {
    return *Param_S(T);
}

pub fn Param_S(T: type) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};

        em__cfgid: ?*const CfgId = null,
        em__val: T,

        pub fn getM(self: *Self) T {
            return self.em__val;
        }

        pub fn setM(self: *Self, v: T) void {
            declare_META();
            self.em__val = v;
        }

        pub fn em__F_toString(self: *const Self) []const u8 {
            declare_META();
            return sprint("@constCast(&em.Param_S({s}){{.em__val = {s}}})", .{ mkTypeName(T), em__F_toStringAux(self.em__val) });
        }

        pub fn em__F_toStringDecls(_: *const Self, comptime _: []const u8, comptime _: []const u8) []const u8 {
            declare_META();
            return "";
        }

        pub fn unwrap(self: *Self) T {
            return switch (DOMAIN) {
                .META, .TARG_CHECK => std.mem.zeroes(T),
                .TARG => self.em__val,
            };
        }
    };
}

pub fn Proxy(I: type) type {
    return *Proxy_S(I);
}

pub fn Proxy_S(I: type) type {
    return struct {
        const Self = @This();
        pub const _em__builtin = {};

        em__cfgid: ?*const CfgId = null,
        em__iobj: I.EM__SPEC = asI(I, I),
        em__upath: []const u8 = I.em__U.upath,

        pub fn getM(self: *const Self) I.EM__SPEC {
            return self.em__iobj;
        }

        pub fn setM(self: *Self, Mod: anytype) void {
            declare_META();
            self.em__upath = Mod.em__U.upath;
            self.em__iobj = asI(I, Mod);
        }

        pub fn em__F_toStringDecls(_: *const Self, comptime _: []const u8, comptime _: []const u8) []const u8 {
            declare_META();
            return "";
        }

        pub fn em__F_toString(self: *const Self) []const u8 {
            declare_META();
            var it = std.mem.splitSequence(u8, self.em__upath, "__");
            var sb = StringM{};
            sb.addM(sprint("em.import.@\"{s}\"", .{it.first()}));
            while (it.next()) |seg| {
                sb.addM(sprint(".{s}", .{seg}));
            }
            const IMod = mkUnitImport(I.em__U.upath);
            const XMod = mkUnitImport(self.em__upath);
            const iobj = sprint("em.asI({s}, {s})", .{ IMod, XMod });
            return sprint("@constCast(&em.Proxy_S({s}){{.em__upath = \"{s}\", .em__iobj = {s},}})", .{ IMod, self.em__upath, iobj });
        }

        pub fn unwrap(self: *const Self) I.EM__SPEC {
            return if (DOMAIN == .TARG_CHECK) I.EM__SPEC{} else self.em__iobj;
        }
    };
}

pub const TableAccess = enum { RO, RW };

pub fn Table(T: type, acc: TableAccess) type {
    return *Table_S(T, acc);
}

pub fn Table_S(T: type, acc: TableAccess) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};

        const _ItemsType = if (IS_META or acc == .RW) []T else []const T;
        const _ListType = if (IS_META) std.ArrayList(T) else _ItemsType;

        const _LIST_INIT = if (IS_META) _ListType.init(arena.allocator()) else undefined;

        em__cfgid: ?*const CfgId = null,
        em__dname: []const u8 = "",
        em__is_virgin: bool = true,
        em__list: _ListType = _LIST_INIT,

        pub fn addM(self: *Self, item: T) void {
            if (!IS_META) return;
            self.em__list.append(item) catch fail();
            self.em__is_virgin = false;
        }

        pub fn items(self: *Self) _ItemsType {
            declare_TARG();
            return self.em__list;
        }

        pub fn itemsM(self: *Self) _ItemsType {
            declare_META();
            self.em__is_virgin = false;
            return self.em__list.items;
        }

        pub fn setLenM(self: *Self, len: usize) void {
            declare_META();
            const sav = self.em__is_virgin;
            const l = self.em__list.items.len;
            if (len > l) {
                for (l..len) |_| {
                    self.addM(std.mem.zeroes(T));
                }
            }
            self.em__is_virgin = sav;
        }

        pub fn em__F_toString(self: *const Self) []const u8 {
            declare_META();
            return sprint("@constCast(&em.Table_S({s}, .{s}){{.em__list = &@\"{s}\"}})", .{
                mkTypeName(T),
                @tagName(acc),
                self.em__dname,
            });
        }

        pub fn em__F_toStringDecls(self: *Self, comptime upath: []const u8, comptime cname: []const u8) []const u8 {
            declare_META();
            self.em__dname = upath ++ ".em__C." ++ cname;
            const tn = mkTypeName(T);
            var sb = StringM{};
            if (self.em__is_virgin) {
                sb.addM(sprint("std.mem.zeroes([{d}]{s})", .{ self.em__list.items.len, tn }));
            } else {
                sb.addM(sprint("[_]{s}{{", .{tn}));
                for (self.em__list.items) |e| {
                    sb.addM(sprint("    {s},\n", .{em__F_toStringAux(e)}));
                }
                sb.addM("}");
            }
            const ks = if (acc == .RO) "const" else "var";
            return sprint("pub {s} @\"{s}\" = {s};\n", .{ ks, self.em__dname, sb.getM() });
        }
    };
}

const @"// -------- BUILTIN FXNS -------- //" = {};

pub fn fail() void {
    switch (DOMAIN) {
        .META => {
            std.log.err("em.fail", .{});
            std.process.exit(1);
        },
        .TARG, .TARG_CHECK => {
            targ.em__fail();
        },
    }
}

pub fn halt() void {
    switch (DOMAIN) {
        .META => {
            std.log.info("em.halt", .{});
            std.process.exit(0);
        },
        .TARG, .TARG_CHECK => {
            targ.em__exit();
        },
    }
}

pub fn print(comptime fmt: []const u8, args: anytype) void {
    switch (DOMAIN) {
        .META => {
            std.log.debug(fmt, args);
        },
        .TARG, .TARG_CHECK => {
            std.fmt.format(Console.writer(), fmt, args) catch fail();
        },
    }
}

const @"// -------- DEBUG OPERATORS -------- //" = {};

const Console = @import("Console.em.zig");

pub fn @"%%[>]"(v: anytype) void {
    if (IS_META) return;
    Console.wrN(v);
}

const Debug = @import("Debug.em.zig");

pub fn @"%%[a]"() void {
    if (IS_META) return;
    Debug.pulse('A');
}
pub fn @"%%[a+]"() void {
    if (IS_META) return;
    Debug.plus('A');
}
pub fn @"%%[a-]"() void {
    if (IS_META) return;
    Debug.minus('A');
}
pub fn @"%%[a:]"(e: anytype) void {
    if (IS_META) return;
    Debug.mark('A', e);
}

pub fn @"%%[b]"() void {
    if (IS_META) return;
    Debug.pulse('B');
}
pub fn @"%%[b+]"() void {
    if (IS_META) return;
    Debug.plus('B');
}
pub fn @"%%[b-]"() void {
    if (IS_META) return;
    Debug.minus('B');
}
pub fn @"%%[b:]"(e: anytype) void {
    if (IS_META) return;
    Debug.mark('B', e);
}

pub fn @"%%[c]"() void {
    if (IS_META) return;
    Debug.pulse('C');
}
pub fn @"%%[c+]"() void {
    if (IS_META) return;
    Debug.plus('C');
}
pub fn @"%%[c-]"() void {
    if (IS_META) return;
    Debug.minus('C');
}
pub fn @"%%[c:]"(e: anytype) void {
    if (IS_META) return;
    Debug.mark('C', e);
}

pub fn @"%%[d]"() void {
    if (IS_META) return;
    Debug.pulse('D');
}
pub fn @"%%[d+]"() void {
    if (IS_META) return;
    Debug.plus('D');
}
pub fn @"%%[d-]"() void {
    if (IS_META) return;
    Debug.minus('D');
}
pub fn @"%%[d:]"(e: anytype) void {
    if (IS_META) return;
    Debug.mark('D', e);
}

const @"// -------- MEM MGMT -------- //" = {};

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

pub fn getHeap() std.mem.Allocator {
    return arena.allocator();
}

const @"// -------- TARGET GEN -------- //" = {};

const targ = @import("../../zigem/targ.zig");
const type_map = @import("../../zigem/type_map.zig");

fn mkTypeName(T: type) []const u8 {
    const ti = @typeInfo(T);
    const tn = @typeName(T);
    switch (ti) {
        .Enum => {
            return mkTypeImport(tn);
        },
        .Struct => {
            if (@hasDecl(T, "_em__builtin") and @hasDecl(T, "em__F_typeName")) {
                return @call(.auto, @field(T, "em__F_typeName"), .{});
            } else {
                return mkTypeImport(tn);
            }
        },
        else => {
            return tn;
        },
    }
}

fn mkTypeImport(comptime tn: []const u8) []const u8 {
    const idx = comptime std.mem.lastIndexOf(u8, tn, ".").?;
    const tun = comptime tn[0..idx];
    return "em.import.@\"" ++ @as([]const u8, @field(type_map, tun)) ++ "\"." ++ tn[idx + 1 ..];
}

fn mkUnitImport(upath: []const u8) []const u8 {
    var it = std.mem.splitSequence(u8, upath, "__");
    var sb = StringM{};
    sb.addM(sprint("em.import.@\"{s}\"", .{it.first()}));
    while (it.next()) |seg| {
        sb.addM(sprint(".{s}", .{seg}));
    }
    return sb.getM();
}

pub fn em__F_toStringAux(v: anytype) []const u8 { // use zig fmt after meta build
    const T = @TypeOf(v);
    const ti = @typeInfo(T);
    const tn = @typeName(T);
    switch (ti) {
        .Null => {
            return "null";
        },
        .Optional => {
            if (v) |val| {
                return em__F_toStringAux(val);
            } else {
                return "null";
            }
        },
        .Int => {
            if (ti.Int.signedness == .signed) {
                return sprint("@as({s}, {d})", .{ tn, v });
            } else if (ti.Int.bits <= 8) {
                return sprint("@as({s}, 0x{X:0>2})", .{ tn, v });
            } else if (ti.Int.bits <= 16) {
                return sprint("@as({s}, 0x{X:0>4})", .{ tn, v });
            } else if (ti.Int.bits <= 32) {
                return sprint("@as({s}, 0x{X:0>8})", .{ tn, v });
            } else {
                return sprint("@as({s}, 0x{X:0>16})", .{ tn, v });
            }
        },
        .Bool, .ComptimeInt, .Float, .ComptimeFloat => {
            return sprint("@as({s}, {any})", .{ tn, v });
        },
        .Enum => {
            return sprint("{s}.{s}", .{ mkTypeImport(tn), @tagName(v) });
        },
        .Struct => {
            if (@hasDecl(T, "_em__builtin")) {
                return v.em__F_toString();
            } else {
                var res: []const u8 = sprint("{s}{{\n", .{mkTypeImport(tn)});
                inline for (ti.Struct.fields) |fld| {
                    res = sprint("    {s} .{s} = {s},\n", .{ res, fld.name, em__F_toStringAux(@field(v, fld.name)) });
                }
                return sprint("{s}}}\n", .{res});
            }
        },
        .Array => {
            var res: []const u8 = ".{";
            inline for (0..v.len) |i| {
                res = sprint("{s} {s},", .{ res, em__F_toStringAux(v[i]) });
            }
            return sprint("{s} }}", .{res});
        },
        .Pointer => |ptr_info| {
            if (ptr_info.size == .Slice and ptr_info.child == u8) {
                return sprint("\"{s}\"", .{v});
            } else if (ptr_info.size == .One) {
                return em__F_toStringAux(v.*);
            } else {
                return "<<ptr>>";
            }
        },
        else => {
            return "<<unknown>>";
        },
    }
}

pub fn em__F_toStringPre(v: anytype, comptime upath: []const u8, comptime cname: []const u8) []const u8 {
    const T = @TypeOf(v);
    const ti = @typeInfo(T);
    switch (ti) {
        .Pointer => |ptr_info| {
            if (ptr_info.size == .Slice and ptr_info.child == u8) {
                return "";
            } else if (ptr_info.size == .One) {
                return v.em__F_toStringDecls(upath, cname);
            } else {
                return "<<ptr>>";
            }
        },
        else => {
            return "<<unknown>>";
        },
    }
}

const @"// -------- PROPERTY VALUES -------- //" = {};

const props = @import("../../zigem/props.zig");

pub fn property(name: []const u8, T: type, v: T) T {
    if (!props.map.has(name)) return v;
    const vs = props.map.get(name).?;
    const ti = @typeInfo(T);
    switch (ti) {
        .Bool => return std.mem.eql(u8, vs, "true"),
        .ComptimeInt, .Int => return std.fmt.parseInt(T, vs, 0),
        else => return std.mem.zeroes(T),
    }
}

const @"// -------- MISC HELPERS -------- //" = {};

pub fn @"<>"(T: type, val: anytype) T {
    const ti = @typeInfo(T);
    const vi = @typeInfo(@TypeOf(val));
    switch (vi) {
        .Bool => {
            return @as(T, @intFromBool(val));
        },
        .ComptimeInt => {
            return @as(T, val);
        },
        .Int => {
            if (ti.Int.signedness == vi.Int.signedness) {
                return @as(T, @intCast(val));
            } else {
                const VT: std.builtin.Type = .{ .Int = .{ .bits = vi.Int.bits, .signedness = ti.Int.signedness } };
                return @as(T, @intCast(@as(@Type(VT), @bitCast(val))));
            }
        },
        else => {
            return val;
        },
    }
}

pub const assert = std.debug.assert;

pub fn complog(comptime fmt: []const u8, args: anytype) void {
    //_ = fmt;
    //_ = args;
    const mode = if (@inComptime()) "c" else "r";
    const msg = std.fmt.comptimePrint(fmt, args);
    @compileLog(std.fmt.comptimePrint(" |{s}| {s}", .{ mode, msg }));
}

pub const import = @import("../../zigem/imports.zig");

pub fn isBuiltin(name: []const u8) bool {
    return std.mem.eql(u8, name, "em") or std.mem.startsWith(u8, name, "em__") or std.mem.startsWith(u8, name, "EM__");
}

pub const ptr_t = ?*anyopaque;

pub fn reg(adr: u32) *volatile u32 {
    const r: *volatile u32 = @ptrFromInt(adr);
    return r;
}

pub fn reg16(adr: u32) *volatile u16 {
    const r: *volatile u16 = @ptrFromInt(adr);
    return r;
}

pub fn sizeof(x: anytype) usize {
    const T = @TypeOf(x);
    if (@typeInfo(T) == .Type) {
        return @sizeOf(x);
    } else {
        return @sizeOf(T);
    }
}

pub const std = @import("std");

pub fn sprint(comptime fmt: []const u8, args: anytype) []const u8 {
    return std.fmt.allocPrint(getHeap(), fmt, args) catch unreachable;
}

pub const StringM = struct {
    const Self = @This();
    em__txt: []const u8 = "",
    pub fn addM(self: *Self, txt: []const u8) void {
        self.em__txt = sprint("{s}{s}", .{ self.em__txt, txt });
    }
    pub fn getM(self: Self) []const u8 {
        return self.em__txt;
    }
};

pub const text_t = []const u8;

pub fn typeid(comptime T: type) usize {
    const H = struct {
        var byte: u8 = 0;
        var _ = T;
    };
    return @intFromPtr(&H.byte);
}

pub fn writeFile(dpath: []const u8, fname: []const u8, txt: []const u8) void {
    const fpath = sprint("{s}/{s}", .{ dpath, fname });
    const file = std.fs.createFileAbsolute(fpath, .{}) catch unreachable;
    _ = file.write(txt) catch unreachable;
    file.close();
}
