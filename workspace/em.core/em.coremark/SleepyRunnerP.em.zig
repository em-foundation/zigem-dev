pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    ticker: em.Param(TickerMgr.Obj),
};

pub const CoreBench = em.import.@"em.coremark/CoreBench";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const TickerMgr = em.import.@"em.utils/TickerMgr";
pub const TimeTypes = em.import.@"em.utils/TimeTypes";

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        em__C.ticker.setM(TickerMgr.createM());
    }
};

pub const EM__TARG = struct {
    //
    const ticker = em__C.ticker.unwrap();

    var count: u8 = 10;

    pub fn em__startup() void {
        CoreBench.setup();
    }

    pub fn em__run() void {
        ticker.start(TimeTypes.Secs24p8_initMsecs(1_000), &tickCb);
        FiberMgr.run();
    }

    fn tickCb(_: TickerMgr.CallbackArg) void {
        em.@"%%[d+]"();
        const crc = CoreBench.run(0);
        em.@"%%[d-]"();
        em.print("crc = {x:0>4}\n", .{crc});
        count -= 1;
        if (count > 0) return;
        ticker.stop();
        em.halt();
    }
};
