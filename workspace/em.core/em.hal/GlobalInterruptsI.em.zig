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

//->> zigem publish #|f026e47b3d715c13723800248f05ccda7a8790cf5b57a36e610351068c2d07c1|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted
