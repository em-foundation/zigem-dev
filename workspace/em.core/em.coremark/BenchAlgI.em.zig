pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const Utils = em.import.@"em.coremark/Utils";

pub const EM__TARG = struct {
    dump: fn () void,
    kind: fn () Utils.Kind,
    print: fn () void,
    run: fn () void,
    setup: fn () void,
};


//->> zigem publish #|b4731ba0ded5f2d50e02a520eca132aa0195d0b2a953268da75755e599746676|#

pub fn dump () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn kind () Utils.Kind {
    // TODO
    return em.std.mem.zeroes(Utils.Kind);
}

pub fn print () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn run () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn setup () void {
    // TODO
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    dump: *const @TypeOf(em__Self.dump) = &em__Self.dump,
    kind: *const @TypeOf(em__Self.kind) = &em__Self.kind,
    print: *const @TypeOf(em__Self.print) = &em__Self.print,
    run: *const @TypeOf(em__Self.run) = &em__Self.run,
    setup: *const @TypeOf(em__Self.setup) = &em__Self.setup,
};

//->> zigem publish -- end of generated code
