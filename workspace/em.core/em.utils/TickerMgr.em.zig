pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    TickerOF: em.Factory(Ticker),
};

pub const AlarmMgr = em.import.@"em.utils/AlarmMgr";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";

pub const CallbackFxn = em.Fxn(CallbackArg);
pub const CallbackArg = struct {};

pub const Obj = em.Obj(Ticker);

pub const Ticker = struct {
    _alarm: AlarmMgr.Obj,
    _fiber: FiberMgr.Obj,
    _rate256: u32 = 0,
    _tick_cb: CallbackFxn,
    pub fn start(self: *Ticker, rate256: u32, tick_cb: CallbackFxn) void {
        EM__TARG.Ticker_start(self, rate256, tick_cb);
    }
    pub fn stop(self: *Ticker) void {
        EM__TARG.Ticker_stop(self);
    }
};

pub const createH = EM__META.createH;

pub const EM__META = struct {
    //
    fn createH() Obj {
        const fiber = FiberMgr.createH(em__U.fxn("alarmFB", FiberMgr.BodyArg));
        const alarm = AlarmMgr.createH(fiber);
        const ticker = em__C.TickerOF.createH(.{ ._alarm = alarm, ._fiber = fiber });
        fiber.O().arg = ticker.getIdx();
        return ticker;
    }
};

pub const EM__TARG = struct {
    //
    pub fn alarmFB(a: FiberMgr.BodyArg) void {
        var ticker = em__C.TickerOF.items()[a.arg];
        if (ticker._tick_cb == null) return;
        ticker._tick_cb.?(.{});
        ticker._alarm.wakeupAligned(ticker._rate256);
    }

    fn Ticker_start(ticker: *Ticker, rate256: u32, tick_cb: CallbackFxn) void {
        ticker._rate256 = rate256;
        ticker._tick_cb = tick_cb;
        ticker._alarm.wakeupAligned(rate256);
    }

    fn Ticker_stop(ticker: *Ticker) void {
        ticker._alarm.cancel();
        ticker._tick_cb = null;
    }
};
