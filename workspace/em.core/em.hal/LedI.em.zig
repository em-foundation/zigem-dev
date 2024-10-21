pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    off: fn () void,
    on: fn () void,
    toggle: fn () void,
};

//->> zigem publish #|1c55db3091534441c24369c70c4a2fe8ea7addca24a81ea9c3480173364e557a|#

fn off () void {
    // TODO
    return em.std.mem.zeroes(void);
}

fn on () void {
    // TODO
    return em.std.mem.zeroes(void);
}

fn toggle () void {
    // TODO
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    off: *const @TypeOf(em__Self.off) = &em__Self.off,
    on: *const @TypeOf(em__Self.on) = &em__Self.on,
    toggle: *const @TypeOf(em__Self.toggle) = &em__Self.toggle,
};

//->> zigem publish -- end of generated code
