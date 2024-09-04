pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    DbgA: em.Proxy(GpioI),
    DbgB: em.Proxy(GpioI),
    DbgC: em.Proxy(GpioI),
    DbgD: em.Proxy(GpioI),
};

const Common = em.import.@"em.mcu/Common";
const GpioI = em.import.@"em.hal/GpioI";

pub const EM__HOST = struct {
    pub const DbgA = em__C.DbgA;
    pub const DbgB = em__C.DbgB;
    pub const DbgC = em__C.DbgC;
    pub const DbgD = em__C.DbgD;
};

pub const EM__TARG = struct {
    //
    const DbgA = em__C.DbgA.scope();
    const DbgB = em__C.DbgB.scope();
    const DbgC = em__C.DbgC.scope();
    const DbgD = em__C.DbgD.scope();

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
            pulse(id);
        }
    }

    pub fn minus(comptime id: u8) void {
        getDbg(id).set();
    }

    fn getDbg(comptime id: u8) type {
        switch (id) {
            'A' => return DbgA,
            'B' => return DbgB,
            'C' => return DbgC,
            'D' => return DbgD,
            else => return GpioI,
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
