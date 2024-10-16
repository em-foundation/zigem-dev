pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    AlarmOF: em.Factory(Alarm),
    WakeupTimer: em.Proxy(WakeupTimerI),
};
pub const x_WakeupTimer = em__C.WakeupTimer;

pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const TimeTypes = em.import.@"em.utils/TimeTypes";
pub const WakeupTimerI = em.import.@"em.hal/WakeupTimerI";

pub const Obj = em.Obj(Alarm);

pub const Alarm = struct {
    _fiber: FiberMgr.Obj,
    _thresh: Thresh = 0, // opaque alarm time
    _dt_secs: Secs24p8 = 0, // time remaining until alarm (0 == alarm inactive)
    pub fn cancel(self: *Alarm) void {
        EM__TARG.Alarm_cancel(self);
    }
    pub fn isActive(self: *Alarm) bool {
        EM__TARG.Alarm_isActive(self);
    }
    pub fn wakeup(self: *Alarm, delta: Secs24p8) void {
        EM__TARG.Alarm_wakeup(self, delta);
    }
    pub fn wakeupAligned(self: *Alarm, delta: Secs24p8) void {
        EM__TARG.Alarm_wakeupAligned(self, delta);
    }
};

pub const createM = EM__META.createM;

const Secs24p8 = TimeTypes.Secs24p8;
const Thresh = WakeupTimerI.Thresh;

pub const EM__META = struct {
    //
    pub fn createM(fiber: FiberMgr.Obj) Obj {
        const alarm = em__C.AlarmOF.createM(.{ ._fiber = fiber });
        return alarm;
    }
};

pub const EM__TARG = struct {
    //
    const WakeupTimer = em__C.WakeupTimer.unwrap();

    var cur_alarm: ?*Alarm = null;

    fn dispatch(delta: Secs24p8) void {
        WakeupTimer.disable();
        const alarm_tab = em__C.AlarmOF.items();
        var nxt_alarm: ?*Alarm = null;
        var max_dt_secs = ~@as(Secs24p8, 0);
        for (0..alarm_tab.len) |idx| {
            const a = &alarm_tab[idx];
            if (a._dt_secs == 0) continue; // inactive
            a._dt_secs -|= delta;
            if (a._dt_secs == 0) {
                a._fiber.post(); // ring the alarm
                continue; // inactive
            }
            if (a._dt_secs < max_dt_secs) {
                nxt_alarm = a;
                max_dt_secs = a._dt_secs;
            }
        }
        cur_alarm = nxt_alarm;
        if (cur_alarm) |ca| {
            WakeupTimer.enable(ca._thresh, &wakeupHandler);
        }
    }

    fn setup(alarm: *Alarm, delta: Secs24p8) void {
        alarm._thresh = WakeupTimer.secsToThresh(delta);
        alarm._dt_secs = delta;
        dispatch(0);
    }

    fn wakeupHandler(_: WakeupTimerI.HandlerArg) void {
        dispatch(cur_alarm.?._dt_secs);
    }

    fn Alarm_cancel(alarm: *Alarm) void {
        alarm._dt_secs = 0;
        dispatch(0);
    }

    fn Alarm_isActive(alarm: *Alarm) bool {
        return alarm._dt_secs != 0;
    }

    fn Alarm_wakeup(alarm: *Alarm, delta: Secs24p8) void {
        setup(alarm, delta);
    }

    fn Alarm_wakeupAligned(alarm: *Alarm, delta: Secs24p8) void {
        setup(alarm, WakeupTimer.secsAligned(delta));
    }
};
