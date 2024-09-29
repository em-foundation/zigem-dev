pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    appTicker: em.Param(TickerMgr.Obj),
    sysTicker: em.Param(TickerMgr.Obj),
};

pub const AppLed = em.import2.@"em__distro/BoardC".AppLed;
pub const FiberMgr = em.import2.@"em.utils/FiberMgr";
pub const TickerMgr = em.import2.@"em.utils/TickerMgr";
pub const SysLed = em.import2.@"em__distro/BoardC".SysLed;

// -------- META --------

pub fn em__constructH() void {
    em__C.appTicker.set(TickerMgr.createH());
    em__C.sysTicker.set(TickerMgr.createH());
}

// -------- TARG --------

const appTicker = em__C.appTicker.get();
const sysTicker = em__C.sysTicker.get();

pub fn em__run() void {
    appTicker.start(256, &appTickCb);
    sysTicker.start(384, &sysTickCb);
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
