pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.hal/McuI",
});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    no_cache: em.Param(bool),
};

pub const BusyWait = em.import.@"ti.mcu.cc23xx/BusyWait";
pub const Debug = em.import.@"em.lang/Debug";

pub const EM__META = struct {
    //
    pub fn em__initH() void {
        em__C.no_cache.init(false);
    }
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn startup() void {
        Debug.startup();
        em.@"%%[a:]"(3);
        em.@"%%[a+]"();
        //        // cc23xx already running at 48MHz after reset
        //        // the following code is strictly not needed for level A
        //        reg(hal.CKMD_BASE + hal.CKMD_O_TRIM1).* |= hal.CKMD_TRIM1_NABIAS_LFOSC;
        //        reg(hal.CKMD_BASE + hal.CKMD_O_LFCLKSEL).* = hal.CKMD_LFCLKSEL_MAIN_LFOSC;
        //        reg(hal.CKMD_BASE + hal.CKMD_O_LFOSCCTL).* = hal.CKMD_LFOSCCTL_EN;
        //        reg(hal.CKMD_BASE + hal.CKMD_O_LFINCCTL).* &= ~hal.CKMD_LFINCCTL_PREVENTSTBY_M;
        //        reg(hal.CKMD_BASE + hal.CKMD_O_IMSET).* = hal.CKMD_IMASK_LFCLKGOOD;
        // LFXTAL
        // reg(hal.CKMD_BASE + hal.CKMD_O_LFINCOVR).* = 0x001E8480 | hal.CKMD_LFINCOVR_OVERRIDE_M;
        reg(hal.CKMD_BASE + hal.CKMD_O_LFCLKSEL).* = hal.CKMD_LFCLKSEL_MAIN_LFXT;
        reg(hal.CKMD_BASE + hal.CKMD_O_LFXTCTL).* = hal.CKMD_LFXTCTL_EN;
        reg(hal.CKMD_BASE + hal.CKMD_O_IMSET).* = hal.CKMD_IMSET_HFXTFAULT | hal.CKMD_IMSET_TRACKREFLOSS | hal.CKMD_IMASK_LFCLKGOOD;
        // LFOSC
        //reg(hal.CKMD_BASE + hal.CKMD_O_TRIM1).* |= hal.CKMD_TRIM1_NABIAS_LFOSC;
        //reg(hal.CKMD_BASE + hal.CKMD_O_LFCLKSEL).* = hal.CKMD_LFCLKSEL_MAIN_LFOSC;
        //reg(hal.CKMD_BASE + hal.CKMD_O_LFOSCCTL).* = hal.CKMD_LFOSCCTL_EN;
        //reg(hal.CKMD_BASE + hal.CKMD_O_LFINCCTL).* &= ~hal.CKMD_LFINCCTL_PREVENTSTBY_M;
        //reg(hal.CKMD_BASE + hal.CKMD_O_IMSET).* = hal.CKMD_IMASK_LFCLKGOOD;
        if (em.property("em.build.BootFlash", bool, false)) {
            reg(hal.CLKCTL_BASE + hal.CLKCTL_O_IDLECFG).* = 1;
            reg(hal.VIMS_BASE + hal.VIMS_O_CCHCTRL).* = 0;
        }
        em.@"%%[a-]"();
    }
};
