pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = OneShotI });

pub const Idle = em.import.@"ti.mcu.cc23xx/Idle";
pub const IntrVec = em.import.@"em.arch.arm/IntrVec";
pub const OneShotI = em.import.@"em.hal/OneShotI";

pub const HandlerArg = OneShotI.HandlerArg;

pub const disable = EM__TARG.disable;
pub const enable = EM__TARG.enable;
pub const uenable = EM__TARG.uenable;

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        IntrVec.useIntrM("LGPT3_COMB");
    }
};

pub const EM__TARG = struct {
    //
    const HandlerFxn = OneShotI.HandlerFxn;

    const hal = em.hal;
    const reg = em.reg;

    var cur_arg: em.ptr_t = null;
    var cur_fxn: em.Fxn_T(HandlerArg) = null;

    pub fn disable() void {
        cur_fxn = null;
        Idle.waitOnly(.CLR);
        hal.NVIC_DisableIRQ(hal.LGPT3_COMB_IRQn);
        reg(hal.LGPT3_BASE + hal.LGPT_O_ICLR).* = hal.LGPT_ICLR_TGT;
    }

    pub fn enable(msecs: u32, handler: HandlerFxn, arg: em.ptr_t) void {
        ustart(msecs * 1000, handler, arg);
    }

    pub fn uenable(usecs: u32, handler: HandlerFxn, arg: em.ptr_t) void {
        ustart(usecs, handler, arg);
    }

    fn ustart(usecs: u32, handler: HandlerFxn, arg: em.ptr_t) void {
        if (em.IS_META) return;
        cur_fxn = handler;
        cur_arg = arg;
        Idle.waitOnly(.SET);
        hal.NVIC_EnableIRQ(hal.LGPT3_COMB_IRQn);
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENSET0).* = hal.CLKCTL_CLKENSET0_LGPT3;
        reg(hal.LGPT3_BASE + hal.LGPT_O_IMSET).* = hal.LGPT_IMSET_TGT;
        reg(hal.LGPT3_BASE + hal.LGPT_O_PRECFG).* = (48 << hal.LGPT_PRECFG_TICKDIV_S);
        reg(hal.LGPT3_BASE + hal.LGPT_O_TGT).* = usecs;
        reg(hal.LGPT3_BASE + hal.LGPT_O_CTL).* = hal.LGPT_CTL_MODE_UP_ONCE | hal.LGPT_CTL_C0RST;
    }

    fn LGPT3_COMB_isr() void {
        const fxn = cur_fxn;
        EM__TARG.disable();
        if (fxn != null) fxn.?(.{ .arg = cur_arg });
    }
};

export fn LGPT3_COMB_isr() void {
    if (em.IS_META) return;
    EM__TARG.LGPT3_COMB_isr();
}
