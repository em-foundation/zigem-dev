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
        AppLed.wink(100); // 100 ms
        counter += 1;
        if ((counter & 0x1) != 0) {
            em__C.alarm.unwrap().wakeup(TimeTypes.Secs24p8_initMsecs(2_000)); // 2s
        } else {
            em__C.alarm.unwrap().wakeup(TimeTypes.Secs24p8_initMsecs(750)); // 750ms
        }
    }
};

//->> zigem publish #|40f1a987302d12237779ab385b6f6302ed36790b8720fff448c05574388fe1a4|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__META publics

//->> EM__TARG publics
pub const blinkFB = EM__TARG.blinkFB;
