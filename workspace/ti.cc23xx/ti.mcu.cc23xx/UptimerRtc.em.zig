pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = UptimerI,
});

pub const Rtc = em.import.@"ti.mcu.cc23xx/Rtc";
pub const TimeTypes = em.import.@"em.utils/TimeTypes";
pub const UptimerI = em.import.@"em.hal/UptimerI";

pub const read = EM__TARG.read;

pub const EM__TARG = struct {
    //
    pub fn read() TimeTypes.RawTime {
        return Rtc.getRawTime();
    }
};
