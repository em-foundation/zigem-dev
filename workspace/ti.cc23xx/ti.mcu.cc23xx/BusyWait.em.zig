pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = BusyWaitI });
pub const em__C = em__U.config(EM__CONFIG);

pub const BusyWaitI = em.import.@"em.hal/BusyWaitI";

pub const EM__CONFIG = struct {
    scalar: em.Param(u8),
};
pub const c_scalar = em__C.scalar;

pub const wait = EM__TARG.wait;

pub const EM__META = struct {
    //
    pub fn em__initH() void {
        em__C.scalar.set(6);
    }
};

pub const EM__TARG = struct {
    //
    fn wait(usecs: u32) void {
        if (usecs == 0) return;
        var dummy: u32 = undefined;
        const p: *volatile u32 = &dummy;
        for (0..(usecs * em__C.scalar.get())) |_| {
            p.* = 0;
        }
    }
};
