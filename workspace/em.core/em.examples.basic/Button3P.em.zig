pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
};

pub const AppBut = em.import.@"em__distro/BoardC".AppBut;
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const SysLed = em.import.@"em__distro/BoardC".SysLed;

pub const EM__TARG = struct {
    //
    pub fn em__run() void {
        AppBut.onPressed(EM__TARG.onPressedCb, .{});
        FiberMgr.run();
    }

    pub fn onPressedCb(_: AppBut.OnPressedCbArg) void {
        em.@"%%[c]"();
        if (AppBut.isPressed()) {
            SysLed.on();
            Common.BusyWait.wait(40_000);
            SysLed.off();
        } else {
            AppLed.on();
            Common.BusyWait.wait(5_000);
            AppLed.off();
        }
    }
};

//->> zigem publish #|0e27453b208da6d2f2c3e62941d7050711c53790325bada8f007ee1644ce8b4e|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__TARG publics
pub const onPressedCb = EM__TARG.onPressedCb;
