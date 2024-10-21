pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.coremark/BenchAlgI",
});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    memsize: em.Param(u16),
};

pub const Crc = em.import.@"em.coremark/Crc";
pub const Utils = em.import.@"em.coremark/Utils";

pub const EM__META = struct {
    //
    pub const c_memsize = em__C.memsize;
};

pub const EM__TARG = struct {
    //
    const StringBuf = [*]u8;

    const State = enum(u8) {
        START,
        INVALID,
        S1,
        S2,
        INT,
        FLOAT,
        EXPONENT,
        SCIENTIFIC,
    };

    const NUM_STATES = @typeInfo(State).Enum.fields.len;

    const memsize = em__C.memsize.unwrap();

    const errpat = [_][]const u8{ "T0.3e-1F", "-T.T++Tq", "1T3.4e4z", "34.0e-T^" };
    const fltpat = [_][]const u8{ "35.54400", ".1234500", "-110.700", "+0.64400" };
    const intpat = [_][]const u8{ "5012", "1234", "-874", "+122" };
    const scipat = [_][]const u8{ "5.500e+3", "-.123e-2", "-87e+832", "+0.6e-12" };

    var membuf = em.std.mem.zeroes([memsize]u8);

    pub fn dump() void {
        // TODO
        return;
    }

    fn isDigit(ch: u8) bool {
        return ch >= '0' and ch <= '9';
    }

    pub fn kind() Utils.Kind {
        return .STATE;
    }

    fn nextState(pstr: *StringBuf, transcnt: [*]u32) State {
        var str = pstr.*;
        var state = State.START;
        while (str[0] != 0 and state != State.INVALID) : (str += 1) {
            const ch = str[0];
            if (ch == ',') {
                str += 1;
                break;
            }
            switch (state) {
                .INVALID => {},
                .START => {
                    if (isDigit(ch)) {
                        state = .INT;
                    } else if (ch == '+' or ch == '-') {
                        state = .S1;
                    } else if (ch == '.') {
                        state = .FLOAT;
                    } else {
                        state = .INVALID;
                        transcnt[ord(.INVALID)] += 1;
                    }
                    transcnt[ord(.START)] += 1;
                },
                .S1 => {
                    if (isDigit(ch)) {
                        state = .INT;
                        transcnt[ord(.S1)] += 1;
                    } else if (ch == '.') {
                        state = .FLOAT;
                        transcnt[ord(.S1)] += 1;
                    } else {
                        state = .INVALID;
                        transcnt[ord(.S1)] += 1;
                    }
                },
                .INT => {
                    if (ch == '.') {
                        state = .FLOAT;
                        transcnt[ord(.INT)] += 1;
                    } else if (!isDigit(ch)) {
                        state = .INVALID;
                        transcnt[ord(.INT)] += 1;
                    }
                },
                .FLOAT => {
                    if (ch == 'E' or ch == 'e') {
                        state = .S2;
                        transcnt[ord(.FLOAT)] += 1;
                    } else if (!isDigit(ch)) {
                        state = .INVALID;
                        transcnt[ord(.FLOAT)] += 1;
                    }
                },
                .S2 => {
                    if (ch == '+' or ch == '-') {
                        state = .EXPONENT;
                        transcnt[ord(.S2)] += 1;
                    } else {
                        state = .INVALID;
                        transcnt[ord(.S2)] += 1;
                    }
                },
                .EXPONENT => {
                    if (isDigit(ch)) {
                        state = .SCIENTIFIC;
                        transcnt[ord(.EXPONENT)] += 1;
                    } else {
                        state = .INVALID;
                        transcnt[ord(.EXPONENT)] += 1;
                    }
                },
                .SCIENTIFIC => {
                    //em.@"%%[a+]"();
                    if (!isDigit(ch)) {
                        state = .INVALID;
                        transcnt[ord(.INVALID)] += 1;
                    }
                },
            }
        }
        pstr.* = str;
        return state;
    }

    fn ord(state: State) usize {
        return @intFromEnum(state);
    }

    fn prCnts(lab: []const u8, finalcnt: [*]u32, transcnt: [*]u32) void {
        em.print("\n{s}\n", .{lab});
        for (0..NUM_STATES) |i| {
            em.print("zig: {d} {d}\n", .{ finalcnt[i], transcnt[i] });
        }
    }

    pub fn print() void {
        var idx: usize = 0;
        var cnt: usize = 0;
        em.print("\n\"", .{});
        while (idx < membuf.len and membuf[idx] != 0) {
            if ((cnt % @as(usize, 8)) == 0) {
                em.print("\n    ", .{});
            }
            cnt += 1;
            while (true) {
                const c = membuf[idx];
                idx += 1;
                if (c == ',') break;
                em.print("{c}", .{c});
            }
            em.print(", ", .{});
        }
        em.print("\n\", count = {d}\n", .{cnt});
    }

    pub fn run(arg: i16) Utils.sum_t {
        var uarg: usize = @intCast(@as(u16, @bitCast(arg)));
        if (arg < 0x22) uarg = 0x22;
        var finalcnt: [NUM_STATES]u32 = undefined;
        var transcnt: [NUM_STATES]u32 = undefined;
        for (0..NUM_STATES) |i| {
            finalcnt[i] = 0;
            transcnt[i] = 0;
        }
        scan(&finalcnt, &transcnt);
        scramble(Utils.getSeed(1), uarg);
        scan(&finalcnt, &transcnt);
        scramble(Utils.getSeed(2), uarg);
        var crc = Utils.getCrc(Utils.Kind.FINAL);
        for (0..NUM_STATES) |i| {
            crc = Crc.add32(finalcnt[i], crc);
            crc = Crc.add32(transcnt[i], crc);
        }
        return crc;
    }

    fn scan(finalcnt: [*]u32, transcnt: [*]u32) void {
        var str: StringBuf = &membuf;
        while (str[0] != 0) {
            const state = nextState(&str, transcnt);
            finalcnt[ord(state)] += 1;
        }
    }

    fn scramble(seed: Utils.seed_t, step: usize) void {
        var idx: usize = 0;
        while (idx < memsize) : (idx += step) {
            if (membuf[idx] != ',') membuf[idx] ^= @as(u8, @intCast(seed));
        }
    }

    pub fn setup() void {
        var seed = Utils.getSeed(1);
        var idx = @as(usize, 0);
        var total = @as(usize, 0);
        var pat: []const u8 = "";
        var plen = @as(usize, 0);
        while ((total + plen + 1) < (memsize - 1)) {
            if (plen > 0) {
                for (0..plen) |i| {
                    membuf[idx] = pat[i];
                    idx += 1;
                }
                membuf[idx] = ',';
                idx += 1;
                total += plen + 1;
            }
            seed += 1;
            switch (@as(u3, @intCast(seed & 0x7))) {
                0, 1, 2 => {
                    pat = intpat[(seed >> 3) & 0x3];
                },
                3, 4 => {
                    pat = fltpat[(seed >> 3) & 0x3];
                },
                5, 6 => {
                    pat = scipat[(seed >> 3) & 0x3];
                },
                7 => {
                    pat = errpat[(seed >> 3) & 0x3];
                },
            }
            plen = pat.len;
        }
    }
};

//->> zigem publish #|10cfce28fbd971af60303e496aa54da3bdb7ade5ac581af2f1f05bef55817ab4|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__META publics
pub const c_memsize = EM__META.c_memsize;

//->> EM__TARG publics
pub const dump = EM__TARG.dump;
pub const kind = EM__TARG.kind;
pub const print = EM__TARG.print;
pub const run = EM__TARG.run;
pub const setup = EM__TARG.setup;
