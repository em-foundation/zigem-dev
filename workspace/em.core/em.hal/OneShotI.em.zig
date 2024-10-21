pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const HandlerFxn = em.Fxn(HandlerArg);
pub const HandlerArg = struct {
    arg: em.ptr_t,
};

pub const EM__SPEC = struct {
    disable: *const @TypeOf(disable) = &disable,
    enable: *const @TypeOf(enable) = &enable,
    uenable: *const @TypeOf(uenable) = &uenable,
};

pub fn disable() void {
    return;
}

pub fn enable(msecs: u32, handler: HandlerFxn, arg: em.ptr_t) void {
    _ = msecs;
    _ = handler;
    _ = arg;
    return;
}

pub fn uenable(usecs: u32, handler: HandlerFxn, arg: em.ptr_t) void {
    _ = usecs;
    _ = handler;
    _ = arg;
    return;
}

//->> zigem publish #|d07f67e01b324c6fa6c380f9e4a64fbefa475ad615178b3fe52fecfb9e62222e|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted
