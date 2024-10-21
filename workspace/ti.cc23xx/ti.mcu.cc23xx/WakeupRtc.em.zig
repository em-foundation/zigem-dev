pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = WakeupTimerI,
});

pub const Rtc = em.import.@"ti.mcu.cc23xx/Rtc";
pub const TimeTypes = em.import.@"em.utils/TimeTypes";
pub const WakeupTimerI = em.import.@"em.hal/WakeupTimerI";

pub const HandlerFxn = WakeupTimerI.HandlerFxn;
pub const HandlerArg = WakeupTimerI.HandlerArg;

const Secs24p8 = TimeTypes.Secs24p8;
const Thresh = WakeupTimerI.Thresh;

pub const EM__TARG = struct {
    //
    pub fn disable() void {
        Rtc.disable();
    }

    pub fn enable(secs256: Secs24p8, handler: HandlerFxn) void {
        if (em.IS_META) return;
        Rtc.enable(secs256, @ptrCast(handler));
    }

    pub fn secsAligned(secs: Secs24p8) Secs24p8 {
        const raw_time = Rtc.getRawTime();
        const raw_secs = em.@"<>"(Secs24p8, raw_time.secs << 8 | raw_time.subs >> 24);
        const rem = raw_secs % secs;
        return secs - rem;
    }

    pub fn secsToThresh(secs: Secs24p8) Thresh {
        return Rtc.toThresh(secs << 8);
    }
};

//->> zigem publish #|447f3808809c1cf9bbb06b814813b9215a6972eb303acdb34c3a30c85dea2ad9|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__TARG publics
pub const disable = EM__TARG.disable;
pub const enable = EM__TARG.enable;
pub const secsAligned = EM__TARG.secsAligned;
pub const secsToThresh = EM__TARG.secsToThresh;
