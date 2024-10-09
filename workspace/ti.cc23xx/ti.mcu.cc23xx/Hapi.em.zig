pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const enterStandby = EM__TARG.enterStandby;

pub const EM__TARG = struct {
    //
    const ROM_T = extern struct {
        enterStandby: ?*const fn ([*c]const u32) callconv(.C) void = @import("std").mem.zeroes(?*const fn ([*c]const u32) callconv(.C) void),
    };

    const ROM_TABLE: *const ROM_T = @ptrFromInt(0x0F00004C);

    fn enterStandby(addr: u32) void {
        ROM_TABLE.enterStandby.?(addr);
    }
};
