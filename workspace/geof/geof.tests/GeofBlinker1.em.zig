pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
};

pub const AppButEdge = em.import.@"em__distro/BoardC".AppButEdge;
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";

pub const busyWaitMax: u32 = 250_000;

pub const EM__HOST = struct {
    pub fn em__constructH() void {
        AppButEdge.setDetectHandlerH(em__U.fxn("handler", AppButEdge.HandlerArg));
    }
};

pub const EM__TARG = struct {
    var busyWaitTime: u32 = busyWaitMax;
    var counter: u32 = 0;

    pub fn em__startup() void {
        AppButEdge.makeInput();
        AppButEdge.setInternalPullup(true);
        AppButEdge.setDetectFallingEdge();
    }

    pub fn em__run() void {
        Common.GlobalInterrupts.enable();
        AppButEdge.enableDetect();
        while (true) {
            AppLed.toggle();
            if ((counter % 2) == 0) {
                em.print("{}: Hello World, rate {}\n", .{ counter / 2, busyWaitMax / busyWaitTime });
                AppButEdge.enableDetect();
            }
            counter += 1;
            Common.BusyWait.wait(busyWaitTime);
        }
    }

    pub fn handler(_: AppButEdge.HandlerArg) void {
        AppButEdge.clearDetect();
        busyWaitTime /= 2;
        if (busyWaitTime < (busyWaitMax / 8)) {
            busyWaitTime = busyWaitMax;
        }
    }
};
