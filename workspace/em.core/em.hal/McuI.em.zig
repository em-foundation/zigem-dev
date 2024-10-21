pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    startup: *const @TypeOf(startup) = &startup,
};

pub fn startup() void {
    return;
}

//->> zigem publish #|e11e30513147b4573bcfe0d72ed1e068abb895fe4accc7e855bdd1a7815ead49|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted
