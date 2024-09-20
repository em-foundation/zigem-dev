pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    OneShot: em.Proxy(em.import.@"em.hal/OneShotI"),
};

pub const Common = em.import.@"em.mcu/Common";

pub const EM__META = struct {
    //
    pub const OneShot = em__C.OneShot;
};

pub const EM__TARG = struct {
    //
    pub const PollFxn = *const fn () bool;

    const OneShot = em__C.OneShot.scope();

    var active_flag: bool = false;
    const active_flag_VP: *volatile bool = &active_flag;

    fn handler(_: OneShot.HandlerArg) void {
        active_flag_VP.* = false;
    }

    pub fn pause(time_ms: u32) void {
        upause(time_ms * 1000);
    }

    pub fn upause(time_us: u32) void {
        if (time_us == 0) return;
        active_flag_VP.* = true;
        OneShot.uenable(time_us, handler, null);
        while (active_flag_VP.*) {
            Common.Idle.exec();
        }
    }

    pub fn poll(rate_ms: u32, count: usize, fxn: PollFxn) usize {
        _ = rate_ms;
        _ = count;
        _ = fxn;
        return 0;
    }
};
