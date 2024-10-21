pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const OneShot = em.import.@"em__distro/BoardC".OneShot;

pub const EM__TARG = struct {
    //
    var active_flag = false;

    pub fn em__run() void {
        Common.GlobalInterrupts.enable();
        for (0..5) |_| {
            em.@"%%[d]"();
            AppLed.on();
            Common.BusyWait.wait(5000);
            AppLed.off();
            active_flag = true;
            OneShot.enable(100, &handler, null);
            while (active_flag) {
                Common.Idle.exec();
            }
        }
    }

    fn handler(_: OneShot.HandlerArg) void {
        em.@"%%[c]"();
        active_flag = false;
    }
};

//->> zigem publish #|af5956fe16dae1e874dc5767851e8c4e1ec00977a7c8a051729e9f29f20383ed|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__TARG publics
