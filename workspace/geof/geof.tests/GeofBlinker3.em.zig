pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
};

pub const AppBut = em.import.@"em__distro/BoardC".AppBut;
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const Poller = em.import.@"em.mcu/Poller";

pub const busyWaitMax: u32 = 10000; // not sure of units

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    var busyWaitTime: u32 = busyWaitMax;
    var counter: u32 = 0;

    pub fn em__run() void {
        Common.GlobalInterrupts.enable();
        AppBut.onPressed(onPressedCb, .{});
        while (true) {
            AppLed.toggle();
            if ((counter % 2) == 0) {
                em.print("{}: Hello World, rate {}\n", .{ counter / 2, busyWaitMax / busyWaitTime });
            }
            counter += 1;
            Poller.pause(busyWaitTime);
        }
    }

    pub fn onPressedCb(_: AppBut.OnPressedCbArg) void {
        em.print("In callback\n", .{});
        busyWaitTime /= 2;
        if (busyWaitTime < (busyWaitMax / 8)) {
            busyWaitTime = busyWaitMax;
        }
    }
};
