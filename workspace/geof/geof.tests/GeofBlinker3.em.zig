pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const AppBut = em.import.@"em__distro/BoardC".AppBut;
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const Poller = em.import.@"em.mcu/Poller";
pub const SysLed = em.import.@"em__distro/BoardC".SysLed;

pub const pauseMax: u32 = 500; // ms

pub const EM__CONFIG = struct {
    blinkFiber: em.Param(FiberMgr.Obj),
};

pub const EM__HOST = struct {
    pub fn em__constructH() void {
        const blinkFiber = FiberMgr.createH(em__U.fxn("toggleLed", FiberMgr.BodyArg));
        em__C.blinkFiber.set(blinkFiber);
    }
};

pub const EM__TARG = struct {
    const blinkFiber = em__C.blinkFiber;
    var pauseTime: u32 = pauseMax;
    var counter: u32 = 0;

    pub fn em__run() void {
        AppBut.onPressed(onPressedCb, .{ .min = 100, .max = 200 });
        blinkFiber.post();
        FiberMgr.run();
    }

    pub fn toggleLed(_: FiberMgr.BodyArg) void {
        AppLed.toggle();
        if ((counter % 2) == 0) {
            // em.print("{}: Hello World, rate {}\n", .{ counter / 2, pauseMax / pauseTime });
        }
        counter += 1;
        Poller.pause(pauseTime);
        blinkFiber.post();
    }

    pub fn onPressedCb(_: AppBut.OnPressedCbArg) void {
        // em.print("In callback\n", .{});
        // em.@"%%[c]"();
        // SysLed.wink(100);
        SysLed.on();
        Common.BusyWait.wait(100_000);
        SysLed.off();
        pauseTime /= 2;
        if (pauseTime * 8 < pauseMax) {
            pauseTime = pauseMax;
        }
    }
};
