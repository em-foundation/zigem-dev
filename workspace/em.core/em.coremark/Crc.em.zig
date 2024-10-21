pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Utils = em.import.@"em.coremark/Utils";
pub const sum_t = Utils.sum_t;

pub const EM__TARG = struct {
    //
    pub fn add16(val: i16, old_crc: sum_t) sum_t {
        const v: u16 = @bitCast(val);
        var crc = old_crc;
        crc = update(@intCast(v), crc);
        crc = update(@intCast(v >> 8), crc);
        return crc;
    }

    pub fn add32(val: u32, old_crc: sum_t) sum_t {
        var crc = old_crc;
        crc = EM__TARG.add16(@intCast(@as(i32, @bitCast(val))), crc);
        crc = EM__TARG.add16(@intCast(@as(i32, @bitCast(val >> 16))), crc);
        return crc;
    }

    fn update(old_data: u8, old_crc: sum_t) sum_t {
        var i: u8 = 0;
        var x16: u8 = 0;
        var carry: u8 = 0;
        var crc = old_crc;
        var data = old_data;
        while (i < 8) : (i += 1) {
            x16 = @intCast((data & 1) ^ (crc & 1));
            data >>= 1;
            if (x16 == 1) {
                crc ^= 0x4002;
                carry = 1;
            } else {
                carry = 0;
            }
            crc >>= 1;
            if (carry != 0) {
                crc |= 0x8000;
            } else {
                crc &= 0x7fff;
            }
        }
        return crc;
    }
};

//->> zigem publish #|4e2173d93278db2987c9171b8d196cac68385de8d5fd2c25737fb7a50964e2b5|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__TARG publics
pub const add16 = EM__TARG.add16;
pub const add32 = EM__TARG.add32;
