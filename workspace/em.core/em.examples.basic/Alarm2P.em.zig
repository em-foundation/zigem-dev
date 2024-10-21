pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    alarm: em.Param(AlarmMgr.Obj),
    blinkF: em.Param(FiberMgr.Obj),
};

pub const AlarmMgr = em.import.@"em.utils/AlarmMgr";
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const TimeTypes = em.import.@"em.utils/TimeTypes";

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        const blinkF = FiberMgr.createM(em__U.fxn("blinkFB", FiberMgr.BodyArg));
        const alarm = AlarmMgr.createM(blinkF);
        em__C.alarm.setM(alarm);
        em__C.blinkF.setM(blinkF);
    }
};

pub const EM__TARG = struct {
    //
    var counter: u32 = 0;

    pub fn em__run() void {
        em__C.blinkF.unwrap().post();
        FiberMgr.run();
    }

    pub fn blinkFB(_: FiberMgr.BodyArg) void {
        em.@"%%[c]"();
        counter += 1;
        if ((counter & 0x1) != 0) {
            AppLed.wink(100); // 100ms
        } else {
            AppLed.wink(5); // 5ms
        }
        em__C.alarm.unwrap().wakeupAligned(TimeTypes.Secs24p8_initMsecs(1_500)); // 1.5s window
    }
};

//->> zigem publish #|87c2591d6c0fc2ea3b4694b4fc0b090d4d2a77494bf782b8c9f2c5f22ea69474|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__META publics

//->> EM__TARG publics
pub const blinkFB = EM__TARG.blinkFB;
