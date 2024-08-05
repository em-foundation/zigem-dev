pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    txTicker: em.Param(TickerMgr.Obj),
};

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const TickerMgr = em.import.@"em.utils/TickerMgr";
pub const RadioConfig = em.import.@"ti.radio.cc23xx/RadioConfig";
pub const RadioDriver = em.import.@"ti.radio.cc23xx/RadioDriver";

pub const EM__HOST = struct {
    pub fn em__configureH() void {
        RadioConfig.phy.set(.BLE_1M);
    }
    pub fn em__constructH() void {
        em__C.txTicker.set(TickerMgr.createH());
    }
};

pub const EM__TARG = struct {
    //
    const txTicker = em__C.txTicker;

    var data = [_]u32{ 0x02030014, 0x0E220001, 0xBBBBCCCC, 0x0804AAAA, 0x0247495A, 0x00000601 };

    pub fn em__run() void {
        txTicker.start(256, &txTickCb);
        FiberMgr.run();
        //Common.GlobalInterrupts.enable();
        //for (0..25) |_| {
        //    Common.BusyWait.wait(200_000);
        //    txTickCb(.{});
        //}
    }

    fn txTickCb(_: TickerMgr.CallbackArg) void {
        AppLed.wink(100);
        RadioDriver.setup(.TX);
        RadioDriver.startTx(data[0..]);
    }
};
