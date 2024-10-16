pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    start: *const @TypeOf(start) = &start,
    stop: *const @TypeOf(stop) = &stop,
};

pub fn start() void {
    return;
}

pub fn stop(o_raw: ?*u32) u32 {
    _ = o_raw;
    return 0;
}
