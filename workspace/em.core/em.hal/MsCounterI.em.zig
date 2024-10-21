pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    start: *const @TypeOf(start) = &start,
    stop: *const @TypeOf(stop) = &stop,
};

pub fn start() void {
    return;
}

pub fn stop() u32 {
    return 0;
}

//->> zigem publish #|c66b56bc5e6da0b8e481295a76f88690b60da0bacf3e18ba16804a2a3d9ab584|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted
