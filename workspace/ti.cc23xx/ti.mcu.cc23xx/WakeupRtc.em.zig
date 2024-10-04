pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = WakeupTimerI,
});

pub const Rtc = em.import.@"ti.mcu.cc23xx/Rtc";
pub const WakeupTimerI = em.import.@"em.hal/WakeupTimerI";

pub const HandlerFxn = WakeupTimerI.HandlerFxn;
pub const HandlerArg = WakeupTimerI.HandlerArg;

pub const disable = EM__TARG.disable;
pub const enable = EM__TARG.enable;
pub const secs256ToTicks = EM__TARG.secs256ToTicks;
pub const ticksToThresh = EM__TARG.ticksToThresh;
pub const timeToTicks = EM__TARG.timeToTicks;

pub const EM__TARG = struct {
    //
    fn disable() void {
        Rtc.disable();
    }

    fn enable(secs256: u32, handler: HandlerFxn) void {
        if (em.IS_META) return;
        Rtc.enable(secs256, @ptrCast(handler));
    }

    fn secs256ToTicks(secs256: u32) u32 {
        return secs256 << 8;
    }

    fn ticksToThresh(ticks: u32) u32 {
        return Rtc.toThresh(ticks);
    }

    fn timeToTicks(secs: u32, subs: u32) u32 {
        return (secs << 16) | (subs >> 16);
    }
};
