pub const em = @import("../../build/.gen/em.zig");
pub const em__U = em.composite(@This(), .{});

pub const AlarmMgr = em.import.@"em.utils/AlarmMgr";
pub const AppBut = em__U.Generate("AppBut", em.import.@"em.utils/ButtonT");
pub const AppButEdge = em__U.Generate("AppButEdge", em.import.@"ti.mcu.cc23xx/GpioEdgeT");
pub const AppLed = em__U.Generate("AppLed", em.import.@"em.utils/LedT");
pub const AppLedPin = em__U.Generate("AppLedPin", em.import.@"ti.mcu.cc23xx/GpioT");
pub const AppOutPin = em__U.Generate("AppOutPin", em.import.@"ti.mcu.cc23xx/GpioT");
pub const AppOutUart = em.import.@"ti.mcu.cc23xx/ConsoleUart0";
pub const BoardController = em.import.@"em.utils/BoardController";
pub const BusyWait = em.import.@"ti.mcu.cc23xx/BusyWait";
pub const Console = em.import.@"em.lang/Console";
pub const Common = em.import.@"em.mcu/Common";
pub const DbgA = em__U.Generate("DbgA", em.import.@"ti.mcu.cc23xx/GpioT");
pub const DbgB = em__U.Generate("DbgB", em.import.@"ti.mcu.cc23xx/GpioT");
pub const DbgC = em__U.Generate("DbgC", em.import.@"ti.mcu.cc23xx/GpioT");
pub const DbgD = em__U.Generate("DbgD", em.import.@"ti.mcu.cc23xx/GpioT");
pub const Debug = em.import.@"em.lang/Debug";
pub const EpochTime = em.import.@"em.utils/EpochTime";
pub const ExtFlashDisabler = em.import.@"ti.mcu.cc23xx/ExtFlashDisabler";
pub const FlashCLK = em__U.Generate("FlashCLK", em.import.@"ti.mcu.cc23xx/GpioT");
pub const FlashCS = em__U.Generate("FlashCS", em.import.@"ti.mcu.cc23xx/GpioT");
pub const FlashPICO = em__U.Generate("FlashPICO", em.import.@"ti.mcu.cc23xx/GpioT");
pub const FlashPOCI = em__U.Generate("FlashPOCI", em.import.@"ti.mcu.cc23xx/GpioT");
pub const GlobalInterrupts = em.import.@"em.arch.arm/GlobalInterrupts";
pub const Idle = em.import.@"ti.mcu.cc23xx/Idle";
pub const Mcu = em.import.@"ti.mcu.cc23xx/Mcu";
pub const MsCounter = em.import.@"ti.mcu.cc23xx/MsCounterGpt3";
pub const OneShot = em.import.@"ti.mcu.cc23xx/OneShotGpt3";
pub const Poller = em.import.@"em.mcu/Poller";
pub const SysLed = em__U.Generate("SysLed", em.import.@"em.utils/LedT");
pub const SysLedPin = em__U.Generate("SysLedPin", em.import.@"ti.mcu.cc23xx/GpioT");
pub const Uptimer = em.import.@"ti.mcu.cc23xx/UptimerRtc";
pub const UsCounter = em.import.@"ti.mcu.cc23xx/UsCounterSystick";
pub const WakeupTimer = em.import.@"ti.mcu.cc23xx/WakeupRtc";

pub const EM__HOST = struct {};

pub fn em__configureH() void {
    AlarmMgr.WakeupTimer.set(WakeupTimer);
    AppBut.Edge.set(AppButEdge);
    AppButEdge.pin.set(9);
    AppLedPin.pin.set(15);
    AppLed.Pin.set(AppLedPin);
    AppOutPin.pin.set(20);
    AppOutUart.TxPin.set(AppOutPin);
    BoardController.Led.set(SysLed);
    Common.BusyWait.set(BusyWait);
    Common.ConsoleUart.set(AppOutUart);
    Common.GlobalInterrupts.set(GlobalInterrupts);
    Common.Idle.set(Idle);
    Common.Mcu.set(Mcu);
    Common.MsCounter.set(MsCounter);
    Common.UsCounter.set(UsCounter);
    DbgA.pin.set(23);
    DbgB.pin.set(25);
    DbgC.pin.set(1);
    DbgD.pin.set(2);
    Debug.DbgA.set(DbgA);
    Debug.DbgB.set(DbgB);
    Debug.DbgC.set(DbgC);
    Debug.DbgD.set(DbgD);
    EpochTime.Uptimer.set(Uptimer);
    ExtFlashDisabler.CLK.set(FlashCLK);
    ExtFlashDisabler.CS.set(FlashCS);
    ExtFlashDisabler.PICO.set(FlashPICO);
    ExtFlashDisabler.POCI.set(FlashPOCI);
    FlashCLK.pin.set(18);
    FlashCS.pin.set(6);
    FlashPICO.pin.set(13);
    FlashPOCI.pin.set(12);
    Poller.OneShot.set(OneShot);
    SysLedPin.pin.set(14);
    SysLed.Pin.set(SysLedPin);
}
