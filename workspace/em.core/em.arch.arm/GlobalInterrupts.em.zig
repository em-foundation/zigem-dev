pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = GlobalInterruptsI });

pub const GlobalInterruptsI = em.import.@"em.hal/GlobalInterruptsI";

pub const EM__TARG = struct {
    //
    pub fn disable() u32 {
        if (em.IS_META) return 0;
        const key = get_PRIMASK();
        asm volatile ("cpsid i" ::: "memory");
        return key;
    }

    pub fn enable() void {
        if (em.IS_META) return;
        asm volatile ("cpsie i" ::: "memory");
    }

    pub fn isEnabled() bool {
        if (em.IS_META) return false;
        return get_PRIMASK() == 0;
    }

    pub fn restore(key: u32) void {
        if (em.IS_META) return;
        if (key == 0) EM__TARG.enable();
    }

    fn get_PRIMASK() u32 {
        if (em.IS_META) return 0;
        return asm volatile (
            \\mrs %[ret], primask        
            : [ret] "={r0}" (-> u32),
        );
    }
};

//->> zigem publish #|3d1539f9000dcdadbc29dcb9a3608001eb78c7259c93bafaa297cf2f86bb2597|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__TARG publics
pub const disable = EM__TARG.disable;
pub const enable = EM__TARG.enable;
pub const isEnabled = EM__TARG.isEnabled;
pub const restore = EM__TARG.restore;
