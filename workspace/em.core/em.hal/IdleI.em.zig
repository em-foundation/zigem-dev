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

//->> zigem publish #|b760dc08a42f753cc27fb978495cb7c21687288753a1fb4820fe438dc7a66ba6|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted
