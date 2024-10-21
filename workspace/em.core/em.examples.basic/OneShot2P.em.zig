pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    blinkF: em.Param(FiberMgr.Obj),
};

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const OneShot = em.import.@"em__distro/BoardC".OneShot;

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        em__C.blinkF.setM(FiberMgr.createM(em__U.fxn("blinkFB", FiberMgr.BodyArg)));
    }
};

pub const EM__TARG = struct {
    //
    const blinkF = em__C.blinkF.unwrap();
    var count: u8 = 5;

    pub fn em__run() void {
        blinkF.post();
        FiberMgr.run();
    }

    pub fn blinkFB(_: FiberMgr.BodyArg) void {
        em.@"%%[d]"();
        count -= 1;
        if (count == 0) em.halt();
        AppLed.on();
        Common.BusyWait.wait(5000);
        AppLed.off();
        OneShot.enable(100, &handler, null);
    }

    fn handler(_: OneShot.HandlerArg) void {
        em.@"%%[c]"();
        blinkF.post();
    }
};

//->> zigem publish #|cc9fa597e73e317ae0db5b8247a21eda5e32b2175805744c156fd835e9c53359|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__META publics

//->> EM__TARG publics
pub const blinkFB = EM__TARG.blinkFB;
