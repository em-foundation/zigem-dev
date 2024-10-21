pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Common = em.import.@"em.mcu/Common";

pub const EM__TARG = struct {};

pub const Error = error{};

const Uart = Common.ConsoleUart;
const Writer = struct {
    const Self = @This();
    pub const Error = error{};
    pub fn writeAll(_: @This(), bytes: []const u8) !void {
        for (bytes) |b| {
            Uart.put(b);
        }
    }
    pub fn writeBytesNTimes(self: @This(), bytes: []const u8, n: usize) !void {
        for (0..n) |_| {
            try self.writeAll(bytes);
        }
    }
};

pub fn writer() Writer {
    return Writer{};
}

pub fn wrN(v: anytype) void {
    const ti = @typeInfo(@TypeOf(v));
    switch (ti) {
        .Int => {
            const bcnt = (ti.Int.bits + 1) / 8;
            if (bcnt == 1) wr1(@intCast(v)) else if (bcnt == 2) wr2(@intCast(v)) else if (bcnt == 4) wr4(@intCast(v));
        },
        .Bool => {
            wr1(@intFromBool(v));
        },
        .Enum => {
            wr1(@intFromEnum(v));
        },
        .Pointer => {
            wr4(@intFromPtr(v));
        },
        else => {
            Uart.put(0x8F);
            Uart.put(@intFromEnum(ti));
        },
    }
}
fn wr1(v: u8) void {
    Uart.put(0x81);
    Uart.put(v);
}

fn wr2(v: u16) void {
    Uart.put(0x82);
    Uart.put(@intCast(((v >> 8) & 0xFF)));
    Uart.put(@intCast(((v >> 0) & 0xFF)));
}

fn wr4(v: u32) void {
    Uart.put(0x84);
    Uart.put(@intCast(((v >> 24) & 0xFF)));
    Uart.put(@intCast(((v >> 16) & 0xFF)));
    Uart.put(@intCast(((v >> 8) & 0xFF)));
    Uart.put(@intCast(((v >> 0) & 0xFF)));
}

//->> zigem publish #|27cc3cf97c287ab56ba260a4209a2aabcfb9d3200fd88fea90b300e79f87829b|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__TARG publics
