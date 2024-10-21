pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    wait: *const @TypeOf(wait) = &wait,
};

pub fn wait(usecs: u32) void {
    _ = usecs;
}

//->> zigem publish #|8a65d4df045206bd2afaa643ceff3d0deb4848ff24c006df0417998e0583a42a|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted
