pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = MsCounterI });

pub const MsCounterI = em.import.@"em.hal/MsCounterI";

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn start() void {
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENSET0).* = hal.CLKCTL_CLKENSET0_LGPT3;
        reg(hal.LGPT3_BASE + hal.LGPT_O_IMSET).* = hal.LGPT_IMSET_TGT;
        reg(hal.LGPT3_BASE + hal.LGPT_O_TGT).* = 0xffffff;
        reg(hal.LGPT3_BASE + hal.LGPT_O_CTL).* = hal.LGPT_CTL_MODE_UP_ONCE | hal.LGPT_CTL_C0RST;
    }

    pub fn stop() u32 {
        const dt: u32 = reg(hal.LGPT3_BASE + hal.LGPT_O_CNTR).* / (48_000_000 / 1000);
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENCLR0).* = hal.CLKCTL_CLKENSET0_LGPT3;
        return dt;
    }
};

//->> zigem publish #|f72d469222d5a6fc2659f42a47b9b7ba99190e2bf12b14302ba016fac5b6db23|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__TARG publics
pub const start = EM__TARG.start;
pub const stop = EM__TARG.stop;
