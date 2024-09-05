pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.hal/GlobalInterruptsI",
});

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    var disable_key: u32 = 0;

    pub fn disable() u32 {
        const key = disable_key;
        disable_key = 1;
        //const key = get_PRIMASK();
        asm volatile ("cpsid i" ::: "memory");
        return key;
    }

    pub fn enable() void {
        disable_key = 0;
        asm volatile ("cpsie i" ::: "memory");
    }

    pub fn isEnabled() bool {
        return disable_key == 0;
        // return (get_PRIMASK() == 0);
    }

    pub fn restore(key: u32) void {
        if (key == 0) enable();
    }

    pub fn get_PRIMASK() u32 {
        const m: u32 = 0;
        asm volatile (
            \\mrs %[m], primask        
            :
            : [m] "r" (m),
            : "memory"
        );
        return m;
    }

    pub fn set_PRIMASK(m: u32) void {
        asm volatile ("msr primask, %[m]"
            :
            : [m] "r" (m),
            : "memory"
        );
    }
};
