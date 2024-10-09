pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    off: *const @TypeOf(off) = &off,
    on: *const @TypeOf(on) = &on,
    toggle: *const @TypeOf(toggle) = &toggle,
};

pub fn off() void {
    return;
}

pub fn on() void {
    return;
}

pub fn toggle() void {
    return;
}
