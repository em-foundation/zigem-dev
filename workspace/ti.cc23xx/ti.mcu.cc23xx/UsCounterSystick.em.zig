pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = UsCounterI,
});

pub const UsCounterI = em.import.@"em.hal/UsCounterI";

pub const EM__TARG = struct {
    //
    const hal = em.hal;

    pub fn start() void {
        hal.SysTick.*.CTRL = (1 << hal.SysTick_CTRL_CLKSOURCE_Pos) | (1 << hal.SysTick_CTRL_ENABLE_Pos);
        hal.SysTick.*.LOAD = 0xFFFFFF;
        hal.SysTick.*.VAL = 0;
    }

    pub fn stop(o_raw: ?*u32) u32 {
        const lr = hal.SysTick.*.LOAD;
        const vr = hal.SysTick.*.VAL;
        const raw = lr - vr;
        if (o_raw != null) o_raw.?.* = raw;
        const dt = (((raw) << 1) / 48) >> 1;
        hal.SysTick.*.CTRL = 0;
        return dt;
    }
};

//->> zigem publish #|564cb582e8ce371bb3073984d86bff93c28b03fea7b99e5349cfa8441fc5f16d|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__TARG publics
pub const start = EM__TARG.start;
pub const stop = EM__TARG.stop;
