pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    disable: *const @TypeOf(disable) = &disable,
    enable: *const @TypeOf(enable) = &enable,
    isEnabled: *const @TypeOf(isEnabled) = &isEnabled,
    restore: *const @TypeOf(restore) = &restore,
};

pub fn disable() u32 {
    return 0;
}

pub fn enable() void {
    return;
}

pub fn isEnabled() bool {
    return false;
}

pub fn restore(key: u32) void {
    _ = key;
    return;
}
