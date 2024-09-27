pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const HandlerFxn = em.Fxn(HandlerArg);
pub const HandlerArg = struct {};

pub const EM__SPEC = struct {
    disable: *const @TypeOf(disable) = &disable,
    enable: *const @TypeOf(enable) = &enable,
    secs256ToTicks: *const @TypeOf(secs256ToTicks) = &secs256ToTicks,
    ticksToThresh: *const @TypeOf(ticksToThresh) = &ticksToThresh,
    timeToTicks: *const @TypeOf(timeToTicks) = &timeToTicks,
};

pub fn disable() void {
    return;
}

pub fn enable(thresh: u32, handler: HandlerFxn) void {
    _ = thresh;
    _ = handler;
    return;
}

pub fn secs256ToTicks(secs256: u32) u32 {
    _ = secs256;
    return 0;
}

pub fn ticksToThresh(ticks: u32) u32 {
    _ = ticks;
    return 0;
}

pub fn timeToTicks(secs: u32, subs: u32) u32 {
    _ = secs;
    _ = subs;
    return 0;
}
