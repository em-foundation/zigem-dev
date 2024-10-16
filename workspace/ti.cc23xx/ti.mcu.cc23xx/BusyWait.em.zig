pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = BusyWaitI });
pub const em__C = em__U.config(EM__CONFIG);

pub const BusyWaitI = em.import.@"em.hal/BusyWaitI";

pub const EM__CONFIG = struct {
    scalar: em.Param(u8),
};
pub const c_scalar = em__C.scalar;

pub const EM__META = struct {
    //
    pub fn em__initM() void {
        em__C.scalar.setM(6);
    }
};

pub const EM__TARG = struct {
    //
    pub fn wait(usecs: u32) void {
        if (usecs == 0) return;
        var dummy: u32 = undefined;
        const p: *volatile u32 = &dummy;
        for (0..(usecs * em__C.scalar.unwrap())) |_| {
            p.* = 0;
        }
    }
};

//->> zigem publish #|ee82685f0ea6a00aee90e1fda5cfbde9ccce0d9b8c7edc241cb303d108cecd1c|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__META publics

//->> EM__TARG publics
pub const wait = EM__TARG.wait;
