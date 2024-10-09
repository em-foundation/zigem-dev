pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    exec: *const @TypeOf(exec) = &exec,
    wakeup: *const @TypeOf(wakeup) = &wakeup,
};

pub fn exec() void {
    return;
}

pub fn wakeup() void {
    return;
}
