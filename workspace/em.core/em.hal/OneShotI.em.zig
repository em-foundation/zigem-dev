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
