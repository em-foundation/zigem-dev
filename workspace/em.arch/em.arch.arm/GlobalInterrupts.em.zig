pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.hal/GlobalInterruptsI",
});

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    pub fn disable() u32 {
        const key = get_PRIMASK();
        asm volatile ("cpsid i" ::: "memory");
        // set_PRIMASK(1);
        return key;
    }

    pub fn enable() void {
        asm volatile ("cpsie i" ::: "memory");
        // set_PRIMASK(0);
    }

    pub fn isEnabled() bool {
        return get_PRIMASK() == 0;
    }

    pub fn restore(key: u32) void {
        if (key == 0) enable();
    }

    pub fn get_PRIMASK() u32 {
        const key: u32 = 0;
        asm volatile (
            \\mrs %[key], primask        
            :
            : [key] "r" (key),
            : "memory"
        );
        return key;
    }

    pub fn set_PRIMASK(m: u32) void {
        asm volatile ("msr primask, %[m]"
            :
            : [m] "r" (m),
            : "memory"
        );
    }
};
