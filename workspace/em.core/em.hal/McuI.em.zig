pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    startup: *const @TypeOf(startup) = &startup,
};

pub fn startup() void {
    return;
}
