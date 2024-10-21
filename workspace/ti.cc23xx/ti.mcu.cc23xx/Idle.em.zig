pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = IdleI });
pub const em__C = em__U.config(EM__CONFIG);

pub const Debug = em.import.@"em.lang/Debug";
pub const Hapi = em.import.@"ti.mcu.cc23xx/Hapi";
pub const IdleI = em.import.@"em.hal/IdleI";

pub const EM__CONFIG = struct {
    sleep_enter_fxn_tab: em.Table(SleepCbFxn, .RO),
    sleep_leave_fxn_tab: em.Table(SleepCbFxn, .RO),
};

pub const SleepCbFxn = em.Fxn(SleepCbArg);
pub const SleepCbArg = struct {};

pub const EM__META = struct {
    //
    pub fn addSleepEnterCbM(cb: SleepCbFxn) void {
        em__C.sleep_enter_fxn_tab.addM(cb);
    }

    pub fn addSleepLeaveCbM(cb: SleepCbFxn) void {
        em__C.sleep_leave_fxn_tab.addM(cb);
    }
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    var wait_only: u8 = 0;

    pub fn em__startup() void {
        em.@"%%[b+]"();
        // const tmp = reg(hal.PMCTL_BASE + hal.PMCTL_O_VDDRCTL).* & hal.PMCTL_VDDRCTL_SELECT; // LDO
        // reg(hal.PMCTL_BASE + hal.PMCTL_O_VDDRCTL).* = tmp | hal.PMCTL_VDDRCTL_SELECT_DCDC;
        // reg(hal.EVTULL_BASE + hal.EVTULL_O_WKUPMASK).* = hal.EVTULL_WKUPMASK_AON_RTC_COMB | hal.EVTULL_WKUPMASK_AON_IOC_COMB;
        reg(hal.PMCTL_BASE + hal.PMCTL_O_VDDRCTL).* = hal.PMCTL_VDDRCTL_SELECT; // LDO
        reg(hal.EVTULL_BASE + hal.EVTULL_O_WKUPMASK).* = hal.EVTULL_WKUPMASK_AON_RTC_COMB | hal.EVTULL_WKUPMASK_AON_IOC_COMB;
    }

    fn doSleep() void {
        if (em.IS_META) return;
        for (em__C.sleep_enter_fxn_tab.items()) |fxn| {
            fxn.?(.{});
        }
        em.@"%%[b:]"(1);
        em.@"%%[b-]"();
        Debug.reset();
        reg(hal.CKMD_BASE + hal.CKMD_O_LDOCTL).* = 0x0;
        set_PRIMASK(1);
        Hapi.enterStandby(0);
        Debug.startup();
        em.@"%%[b+]"();
        for (em__C.sleep_leave_fxn_tab.items()) |fxn| {
            fxn.?(.{});
        }
        set_PRIMASK(0);
    }

    fn doWait() void {
        if (em.IS_META) return;
        em.@"%%[b:]"(0);
        em.@"%%[b-]"();
        set_PRIMASK(1);
        asm volatile ("wfi");
        em.@"%%[b+]"();
        set_PRIMASK(0);
    }

    pub fn exec() void {
        if (wait_only > 0) {
            doWait();
        } else {
            doSleep();
        }
    }

    pub fn pause() void {
        doWait();
    }

    fn set_PRIMASK(m: u32) void {
        if (em.IS_META) return;
        asm volatile ("msr primask, %[m]"
            :
            : [m] "r" (m),
            : "memory"
        );
    }

    pub fn waitOnly(comptime op: enum { CLR, SET }) void {
        switch (op) {
            .CLR => wait_only -= 1,
            .SET => wait_only += 1,
        }
    }

    fn wakeup() void {
        // TODO
    }
};

//->> zigem publish #|dc5e3ffee8fcc9470051565da4b8e1471f50639f764cbecb4dc697bb6e0ade94|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__META publics
pub const addSleepEnterCbM = EM__META.addSleepEnterCbM;
pub const addSleepLeaveCbM = EM__META.addSleepLeaveCbM;

//->> EM__TARG publics
pub const exec = EM__TARG.exec;
pub const pause = EM__TARG.pause;
pub const waitOnly = EM__TARG.waitOnly;
