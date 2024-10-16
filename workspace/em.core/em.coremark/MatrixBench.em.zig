pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.coremark/BenchAlgI",
});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    dimN: em.Param(usize),
    memsize: em.Param(u16),
    matA: em.Table(matdat_t, .RW),
    matB: em.Table(matdat_t, .RW),
    matC: em.Table(matres_t, .RW),
};
pub const c_memsize = em__C.memsize;

pub const Crc = em.import.@"em.coremark/Crc";
pub const Utils = em.import.@"em.coremark/Utils";

pub const matdat_t = i16;
pub const matres_t = i32;

pub const dump = EM__TARG.dump;
pub const kind = EM__TARG.kind;
pub const print = EM__TARG.print;
pub const run = EM__TARG.run;
pub const setup = EM__TARG.setup;

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        var i: usize = 0;
        var j: usize = 0;
        while (j < em__C.memsize.getM()) {
            i += 1;
            j = i * i * 2 * 4;
        }
        const d = i - 1;
        em__C.dimN.setM(d);
        em__C.matA.setLenM(d * d);
        em__C.matB.setLenM(d * d);
        em__C.matC.setLenM(d * d);
        em__C.matA.itemsM()[0] = 10; // TODO: make matA unique
        em__C.matB.itemsM()[0] = 20; // TODO  make matB unique
    }
};

pub const EM__TARG = struct {
    //
    const dimN = em__C.dimN.unwrap();

    var matA = em__C.matA.items();
    var matB = em__C.matB.items();
    var matC = em__C.matC.items();

    fn addVal(val: matdat_t) void {
        for (0..dimN) |i| {
            for (0..dimN) |j| {
                matA[i * dimN + j] += val;
            }
        }
    }

    fn bix(res: matres_t, lower: u8, upper: u8) matres_t {
        const r: u32 = @intCast(@as(i32, (@bitCast(res))));
        const l: u5 = @intCast(lower);
        const u: u5 = @intCast(upper);
        return @bitCast((r >> l) & (~(@as(u32, 0xffffffff) << u)));
    }

    fn clip(d: matdat_t, b: bool) matdat_t {
        const x: u16 = @bitCast(d);
        return @bitCast(x & (if (b) @as(u16, 0x0ff) else @as(u16, 0x0ffff)));
    }

    pub fn dump() void {
        // TODO
        return;
    }

    fn enlarge(val: matdat_t) matdat_t {
        return @bitCast(@as(u16, 0xf000) | @as(u16, @bitCast(val)));
    }

    pub fn kind() Utils.Kind {
        return .MATRIX;
    }

    fn mulMat() void {
        for (0..dimN) |i| {
            for (0..dimN) |j| {
                matC[i * dimN + j] = 0;
                for (0..dimN) |k| {
                    matC[i * dimN + j] += @as(matres_t, matA[i * dimN + k] * @as(matres_t, matB[k * dimN + j]));
                }
            }
        }
    }

    fn mulMatBix() void {
        for (0..dimN) |i| {
            for (0..dimN) |j| {
                matC[i * dimN + j] = 0;
                for (0..dimN) |k| {
                    const tmp = @as(matres_t, matA[i * dimN + k] * @as(matres_t, matB[k * dimN + j]));
                    matC[i * dimN + j] += bix(tmp, 2, 4) * bix(tmp, 5, 7);
                }
            }
        }
    }

    fn mulVal(val: matdat_t) void {
        for (0..dimN) |i| {
            for (0..dimN) |j| {
                matC[i * dimN + j] = @as(matres_t, matA[i * dimN + j]) * @as(matres_t, val);
            }
        }
    }

    fn mulVec() void {
        for (0..dimN) |i| {
            matC[i] = 0;
            for (0..dimN) |j| {
                matC[i] += @as(matres_t, matA[i * dimN + j]) * @as(matres_t, matB[j]);
            }
        }
    }

    pub fn print() void {
        prDat("A", matA);
        prDat("B", matB);
    }

    fn prDat(lab: []const u8, mat: []i16) void {
        em.print("\n{s}:\n    ", .{lab});
        for (0..dimN) |i| {
            var sep: []const u8 = "";
            for (0..dimN) |j| {
                em.print("{s}{d}", .{ sep, mat[i * dimN + j] });
                sep = ",";
            }
            em.print("\n    ", .{});
        }
    }

    pub fn run(arg: i16) Utils.sum_t {
        var crc: Crc.sum_t = 0;
        const val: matdat_t = arg;
        const clipval = enlarge(val);
        //
        addVal(val);
        mulVal(val);
        crc = Crc.add16(sumDat(clipval), crc);
        //
        mulVec();
        crc = Crc.add16(sumDat(clipval), crc);
        //
        mulMat();
        crc = Crc.add16(sumDat(clipval), crc);
        //
        mulMatBix();
        crc = Crc.add16(sumDat(clipval), crc);
        //
        addVal(-val);
        return Crc.add16(@bitCast(crc), Utils.getCrc(.FINAL));
    }

    pub fn setup() void {
        const s32 = @as(u32, Utils.getSeed(1)) | (@as(u32, Utils.getSeed(2)) << 16);
        var sd: matdat_t = @intCast(@as(i32, @bitCast(s32)));
        if (sd == 0) sd = 1;
        var order: matdat_t = 1;
        for (0..dimN) |i| {
            for (0..dimN) |j| {
                sd = @intCast(@rem(@as(i32, @intCast((order * sd))), 65536));
                var val: matdat_t = sd + order;
                val = clip(val, false);
                matB[i * dimN + j] = val;
                val += order;
                val = clip(val, true);
                matA[i * dimN + j] = val;
                order += 1;
            }
        }
    }

    fn sumDat(clipval: matdat_t) matdat_t {
        var cur: matres_t = 0;
        var prev: matres_t = 0;
        var tmp: matres_t = 0;
        var ret: matdat_t = 0;
        for (0..dimN) |i| {
            for (0..dimN) |j| {
                cur = matC[i * dimN + j];
                tmp += cur;
                if (tmp > clipval) {
                    ret += 10;
                    tmp = 0;
                } else {
                    ret += if (cur > prev) 1 else 0;
                }
                prev = cur;
            }
        }
        return ret;
    }
};
