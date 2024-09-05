pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const Intrs = em.import.@"em.arch.arm/GlobalInterrupts";

pub const EM__CONFIG = struct {
    em__upath: []const u8,
};

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    const MADDR = 0x2000_0010;
    const BADDR = 0x2000_0014;

    pub fn em__run() void {
        asm volatile ("bkpt");
        em.reg(MADDR).* = getMask();
        asm volatile ("nop");
        em.reg(BADDR).* = @intFromBool(Intrs.isEnabled());
        asm volatile ("nop");
        //em.print("PRIMASK = {d}, isEnabled = {any}\n", .{ em.reg(MADDR).*, em.reg(BADDR).* });
        //asm volatile ("nop");
        _ = Intrs.disable();
        asm volatile ("nop");
        em.reg(MADDR).* = getMask();
        asm volatile ("nop");
        em.reg(BADDR).* = @intFromBool(Intrs.isEnabled());
        //asm volatile ("nop");
        //em.print("PRIMASK = {d}, isEnabled = {any}\n", .{ em.reg(MADDR).*, em.reg(BADDR).* });
        //asm volatile ("nop");

        //asm volatile ("nop");
        //asm volatile ("nop");
        //em.reg(0x2000_0010).* = getMask();
        //asm volatile ("nop");
        //asm volatile ("nop");
        //em.reg(0x2000_0014).* = @intFromBool(Intrs.isEnabled());
        //asm volatile ("nop");
        //asm volatile ("nop");

        //em.print("PRIMASK = {d}, isEnabled = {any}\n", .{ getMask(), Intrs.isEnabled() });
        //Intrs.set_PRIMASK(1);

        // const key = Intrs.disable();
        // em.reg(0x1111).* = getMask();
        // em.reg(0x2222).* = @intFromBool(Intrs.isEnabled());
        // //em.print("PRIMASK = {d}, isEnabled = {any}\n", .{ getMask(), Intrs.isEnabled() });
        // //Intrs.set_PRIMASK(0);
        // Intrs.restore(key);
        // em.reg(0x1111).* = getMask();
        // em.reg(0x2222).* = @intFromBool(Intrs.isEnabled());

        //em.print("PRIMASK = {d}, isEnabled = {any}\n", .{ getMask(), Intrs.isEnabled() });

        //em.print("enabled = {any}\n", .{Common.GlobalInterrupts.isEnabled()});
        //_ = Common.GlobalInterrupts.disable();
        //em.print("enabled = {any}\n", .{Common.GlobalInterrupts.isEnabled()});
        //Common.GlobalInterrupts.enable();
        //em.print("enabled = {any}\n", .{Common.GlobalInterrupts.isEnabled()});
    }

    fn getMask() u32 {
        return Intrs.get_PRIMASK();
    }
};
