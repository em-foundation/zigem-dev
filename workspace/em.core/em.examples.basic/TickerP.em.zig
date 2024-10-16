pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    appTicker: em.Param(TickerMgr.Obj),
    sysTicker: em.Param(TickerMgr.Obj),
};

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const TickerMgr = em.import.@"em.utils/TickerMgr";
pub const TimeTypes = em.import.@"em.utils/TimeTypes";
pub const SysLed = em.import.@"em__distro/BoardC".SysLed;

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        em__C.appTicker.setM(TickerMgr.createM());
        em__C.sysTicker.setM(TickerMgr.createM());
    }
};

pub const EM__TARG = struct {
    //
    const appTicker = em__C.appTicker.unwrap();
    const sysTicker = em__C.sysTicker.unwrap();

    pub fn em__run() void {
        appTicker.start(TimeTypes.Secs24p8_initMsecs(1_000), &appTickCb);
        sysTicker.start(TimeTypes.Secs24p8_initMsecs(1_500), &sysTickCb);
        FiberMgr.run();
    }

    fn appTickCb(_: TickerMgr.CallbackArg) void {
        em.@"%%[c]"();
        AppLed.wink(100);
    }

    fn sysTickCb(_: TickerMgr.CallbackArg) void {
        em.@"%%[d]"();
        SysLed.wink(100);
    }
};
