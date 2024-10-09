pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    wait: *const @TypeOf(wait) = &wait,
};

pub fn wait(usecs: u32) void {
    _ = usecs;
}
