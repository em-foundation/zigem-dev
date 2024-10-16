pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    DbgA: em.Proxy(GpioI),
    DbgB: em.Proxy(GpioI),
    DbgC: em.Proxy(GpioI),
    DbgD: em.Proxy(GpioI),
};
pub const x_DbgA = em__C.DbgA;
pub const x_DbgB = em__C.DbgB;
pub const x_DbgC = em__C.DbgC;
pub const x_DbgD = em__C.DbgD;

const Common = em.import.@"em.mcu/Common";
const GpioI = em.import.@"em.hal/GpioI";

pub const mark = EM__TARG.mark;
pub const minus = EM__TARG.minus;
pub const plus = EM__TARG.plus;
pub const pulse = EM__TARG.pulse;
pub const reset = EM__TARG.reset;
pub const startup = EM__TARG.startup;

pub const EM__TARG = struct {
    //
    const DbgA = em__C.DbgA.unwrap();
    const DbgB = em__C.DbgB.unwrap();
    const DbgC = em__C.DbgC.unwrap();
    const DbgD = em__C.DbgD.unwrap();

    fn delay() void {
        Common.BusyWait.wait(1);
    }

    pub fn mark(comptime id: u8, e: anytype) void {
        const ti = @typeInfo(@TypeOf(e));
        const k: u8 = switch (ti) {
            .Bool => @intFromBool(e),
            .Enum => @intFromEnum(e),
            .Int, .ComptimeInt => em.@"<>"(u8, e),
            else => 0,
        };
        for (0..k + 1) |_| {
            EM__TARG.pulse(id);
        }
    }

    pub fn minus(comptime id: u8) void {
        getDbg(id).set();
    }

    fn getDbg(comptime id: u8) GpioI.EM__SPEC {
        switch (id) {
            'A' => return DbgA,
            'B' => return DbgB,
            'C' => return DbgC,
            'D' => return DbgD,
            else => return GpioI.EM__SPEC,
        }
    }

    pub fn plus(comptime id: u8) void {
        getDbg(id).clear();
    }

    pub fn pulse(comptime id: u8) void {
        const Dbg = getDbg(id);
        Dbg.toggle();
        delay();
        Dbg.toggle();
        delay();
    }

    pub fn reset() void {
        resetDbg('A');
        resetDbg('B');
        resetDbg('C');
        resetDbg('D');
    }

    fn resetDbg(comptime id: u8) void {
        const Dbg = getDbg(id);
        Dbg.reset();
    }

    pub fn startup() void {
        startDbg('A');
        startDbg('B');
        startDbg('C');
        startDbg('D');
    }

    fn startDbg(comptime id: u8) void {
        const Dbg = getDbg(id);
        Dbg.makeOutput();
        Dbg.set();
    }
};
