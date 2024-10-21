pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const IntrVec = em.import.@"em.arch.arm/IntrVec";
pub const TimeTypes = em.import.@"em.utils/TimeTypes";

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        IntrVec.useIntrM("CPUIRQ0");
    }
};

pub const EM__TARG = struct {
    //
    const Handler = struct {};

    const hal = em.hal;
    const reg = em.reg;

    const MSECS_SCALAR: u16 = 1000 / 8;
    const RES_BITS: u8 = 20;

    var cur_handler: em.Fxn_T(Handler) = null;

    pub fn em__startup() void {
        reg(hal.CKMD_BASE + hal.CKMD_O_LFINCOVR).* = 0x80000000 + (1 << RES_BITS);
        reg(hal.RTC_BASE + hal.RTC_O_CTL).* = hal.RTC_CTL_RST;
        reg(hal.EVTSVT_BASE + hal.EVTSVT_O_CPUIRQ0SEL).* = hal.EVTSVT_CPUIRQ0SEL_PUBID_AON_RTC_COMB;
        hal.NVIC_EnableIRQ(hal.CPUIRQ0_IRQn);
    }

    pub fn disable() void {
        cur_handler = null;
        reg(hal.RTC_BASE + hal.RTC_O_IMCLR).* = hal.RTC_IMCLR_EV0;
    }

    pub fn enable(thresh: u32, handler: em.Fxn(Handler)) void {
        cur_handler = handler;
        reg(hal.RTC_BASE + hal.RTC_O_CH0CC8U).* = thresh;
        reg(hal.RTC_BASE + hal.RTC_O_IMSET).* = hal.RTC_IMSET_EV0;
    }

    pub fn getRawTime() TimeTypes.RawTime {
        var lo: u32 = undefined;
        var hi: u32 = undefined;
        while (true) {
            lo = reg(hal.RTC_BASE + hal.RTC_O_TIME8U).*;
            hi = reg(hal.RTC_BASE + hal.RTC_O_TIME524M).*;
            if (lo == reg(hal.RTC_BASE + hal.RTC_O_TIME8U).*) break;
        }
        return .{ .secs = hi, .subs = lo << 16 };
    }

    pub fn toThresh(ticks: u32) u32 {
        return reg(hal.RTC_BASE + hal.RTC_O_TIME8U).* + ticks;
    }

    fn CPUIRQ0_isr() void {
        em.reg(hal.RTC_BASE + hal.RTC_O_ICLR).* = hal.RTC_ICLR_EV0;
        if (cur_handler != null) cur_handler.?(Handler{});
    }
};

export fn CPUIRQ0_isr() void {
    if (em.IS_META) return;
    EM__TARG.CPUIRQ0_isr();
}

//->> zigem publish #|c3439747d7fd1854741f00935f4c0cbda1d0f6af598277d3db7d47b6776e99c8|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__META publics

//->> EM__TARG publics
pub const disable = EM__TARG.disable;
pub const enable = EM__TARG.enable;
pub const getRawTime = EM__TARG.getRawTime;
pub const toThresh = EM__TARG.toThresh;
