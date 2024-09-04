pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = OneShotMilliI,
});

pub const Idle = em.import.@"ti.mcu.cc23xx/Idle";
pub const IntrVec = em.import.@"em.arch.arm/IntrVec";
pub const OneShotMilliI = em.import.@"em.hal/OneShotMilliI";

pub const HandlerArg = OneShotMilliI.HandlerArg;
pub const HandlerFxn = OneShotMilliI.HandlerFxn;

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        IntrVec.useIntrH("LGPT3_COMB");
    }
};

pub const EM__TARG = struct {
    //

    const hal = em.hal;
    const reg = em.reg;

    var cur_arg: em.ptr_t = null;
    var cur_fxn: HandlerFxn = null;

    pub fn disable() void {
        cur_fxn = null;
        Idle.waitOnly(.CLR);
        hal.NVIC_DisableIRQ(hal.LGPT3_COMB_IRQn);
        reg(hal.LGPT3_BASE + hal.LGPT_O_ICLR).* = hal.LGPT_ICLR_TGT;
    }

    pub fn enable(msecs: u32, handler: HandlerFxn, arg: em.ptr_t) void {
        cur_fxn = handler;
        cur_arg = arg;
        Idle.waitOnly(.SET);
        hal.NVIC_EnableIRQ(hal.LGPT3_COMB_IRQn);
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENSET0).* = hal.CLKCTL_CLKENSET0_LGPT3;
        reg(hal.LGPT3_BASE + hal.LGPT_O_IMSET).* = hal.LGPT_IMSET_TGT;
        reg(hal.LGPT3_BASE + hal.LGPT_O_PRECFG).* = (192 << hal.LGPT_PRECFG_TICKDIV_S);
        reg(hal.LGPT3_BASE + hal.LGPT_O_TGT).* = msecs * (250);
        reg(hal.LGPT3_BASE + hal.LGPT_O_CTL).* = hal.LGPT_CTL_MODE_UP_ONCE | hal.LGPT_CTL_C0RST;
    }

    export fn LGPT3_COMB_isr() void {
        if (em.hosted) return;
        const fxn = cur_fxn;
        disable();
        if (fxn != null) fxn.?(.{ .arg = cur_arg });
    }
};
