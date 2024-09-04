pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    pub fn disable() u32 {
        return 0;
    }
    pub fn enable() void {
        return;
    }
    pub fn isEnabled() bool {
        return false;
    }
    pub fn restore(key: u32) void {
        _ = key;
        return;
    }
};
