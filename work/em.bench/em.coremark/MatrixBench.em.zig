pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.coremark/BenchAlgI",
});
pub const em__C: *EM__CONFIG = em__unit.Config(EM__CONFIG);

pub const Crc = em.Import.@"em.coremark/Crc";
pub const Utils = em.Import.@"em.coremark/Utils";

pub const EM__CONFIG = struct {
    dimN: em.Param(usize),
    memsize: em.Param(u16),
};

pub const c_dimN = em__C.dimN.ref();
pub const c_memsize = em__C.memsize.ref();

pub const matdat_t = i16;
pub const matres_t = i32;

pub var a_matA = em__unit.array("a_matA", matdat_t);
pub var a_matB = em__unit.array("a_matB", matdat_t);
pub var a_matC = em__unit.array("a_matC", matres_t);

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        var i: usize = 0;
        var j: usize = 0;
        while (j < em__C.memsize.get()) {
            i += 1;
            j = i * i * 2 * 4;
        }
        const d = i - 1;
        a_matA.setLen(d * d);
        a_matB.setLen(d * d);
        a_matC.setLen(d * d);
        c_dimN.set(d);
    }
};

pub const EM__TARG = struct {
    //
    const dimN = em__C.dimN.unwrap();

    var matA = a_matA.unwrap();
    var matB = a_matB.unwrap();
    var matC = a_matC.unwrap();

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

//package em.coremark
//
//import BenchAlgI
//import Crc
//import Utils
//
//# patterned after core_matrix.c
//
//module MatrixBench: BenchAlgI
//
//private:
//
//    type matdat_t: int16
//    type matres_t: int32
//
//    config dimN: uint8
//
//    var matA: matdat_t[]
//    var matB: matdat_t[]
//    var matC: matres_t[]
//
//    function addVal(val: matdat_t)
//    function mulVal(val: matdat_t)
//    function mulMat()
//    function mulMatBix()
//    function mulVec()
//    function sumDat(clipval: matdat_t): matdat_t
//
//    function bix(res: matres_t, lower: uint8, upper: uint8): matres_t
//    function clip(d: matdat_t, b: bool): matdat_t
//    function enlarge(val: matdat_t): matdat_t
//
//    function prDat(lab: string, mat: matdat_t[])
//    function prRes(lab: string)
//
//end
//
//def em$construct()
//    auto i = 0
//    auto j = 0
//    while j < memSize
//        i += 1
//        j = i * i * 2 * 4
//    end
//    dimN = i - 1
//    matA.length = matB.length = matC.length = dimN * dimN
//end
//
//def addVal(val)
//    for auto i = 0; i < dimN; i++
//        for auto j = 0; j < dimN; j++
//            matA[i * dimN + j] += val
//        end
//    end
//end
//
//def bix(res, lower, upper)
//    auto r = <uint32>res
//    auto l = <uint32>lower
//    auto u = <uint32>upper
//    return <matres_t>((r >> l) & (~(0xffffffff << u)))
//end
//
//def clip(d, b)
//    auto x = <uint16>d
//    return <matdat_t>(x & (b ? 0x0ff : 0x0ffff))
//end
//
//def dump()
//    ## TODO -- implement
//end
//
//def enlarge(val)
//    auto v = <uint16>val
//    return <matdat_t>(0xf000 | v)
//end
//
//def kind()
//    return Utils.Kind.MATRIX
//end
//
//def mulVal(val)
//    for auto i = 0; i < dimN; i++
//        for auto j = 0; j < dimN; j++
//            matC[i * dimN + j] = <matres_t>matA[i * dimN + j] * <matres_t>val
//        end
//    end
//end
//
//def mulMat()
//    for auto i = 0; i < dimN; i++
//        for auto j = 0; j < dimN; j++
//            matC[i * dimN + j] = 0
//            for auto k = 0; k < dimN; k++
//                matC[i * dimN + j] += <matres_t>matA[i * dimN + k] * <matres_t>matB[k * dimN + j]
//            end
//        end
//    end
//end
//
//def mulMatBix()
//    for auto i = 0; i < dimN; i++
//        for auto j = 0; j < dimN; j++
//            matC[i * dimN + j] = 0
//            for auto k = 0; k < dimN; k++
//                auto tmp = <matres_t>matA[i * dimN + k] * <matres_t>matB[k * dimN + j]
//                matC[i * dimN + j] += bix(tmp, 2, 4) * bix(tmp, 5, 7)
//            end
//        end
//    end
//end
//
//def mulVec()
//    for auto i = 0; i < dimN; i++
//        matC[i] = 0
//        for auto j = 0; j < dimN; j++
//            matC[i] += <matres_t>matA[i * dimN + j] * <matres_t>matB[j]
//        end
//    end
//end
//
//def print()
//    prDat("A", matA)
//    prDat("B", matB)
//end
//
//def prDat(lab, mat)
//    printf "\n%s:\n    ", lab
//    for auto i = 0; i < dimN; i++
//        auto sep = ""
//        for auto j = 0; j < dimN; j++
//            printf "%s%d", sep, mat[i * dimN + j]
//            sep = ","
//        end
//        printf "\n    "
//    end
//end
//
//def prRes(lab)
//    printf "\n%s:\n    ", lab
//    for auto i = 0; i < dimN; i++
//        auto sep = ""
//        for auto j = 0; j < dimN; j++
//            printf "%s%d", sep, matC[i * dimN + j]
//            sep = ","
//        end
//        printf "\n    "
//    end
//end
//
//def run(arg)
//    auto crc = <Crc.sum_t>0
//    auto val = <matdat_t>arg
//    auto clipval = enlarge(val)
//    #
//    addVal(val)
//    mulVal(val)
//    crc = Crc.add16(sumDat(clipval), crc)
//    #
//    mulVec()
//    crc = Crc.add16(sumDat(clipval), crc)
//    #
//    mulMat()
//    crc = Crc.add16(sumDat(clipval), crc)
//    #
//    mulMatBix()
//    crc = Crc.add16(sumDat(clipval), crc)
//    #
//    addVal(-val)
//    return Crc.add16(<int16>crc, Utils.getCrc(Utils.Kind.FINAL))
//end
//
//def setup()
//    auto s32 = <uint32>Utils.getSeed(1) | (<uint32>Utils.getSeed(2) << 16)
//    auto sd = <matdat_t>s32
//    sd = 1 if sd == 0
//    auto order = <matdat_t>1
//    for auto i = 0; i < dimN; i++
//        for auto j = 0; j < dimN; j++
//            sd = <int16>((order * sd) % 65536)
//            auto val = <matdat_t>(sd + order)
//            val = clip(val, false)
//            matB[i * dimN + j] = val
//            val += order
//            val = clip(val, true)
//            matA[i * dimN + j] = val
//            order += 1
//        end
//    end
//end
//
//def sumDat(clipval)
//    auto cur = <matres_t>0
//    auto prev = <matres_t>0
//    auto tmp = <matres_t>0
//    auto ret = <matdat_t>0
//    for auto i = 0; i < dimN; i++
//        for auto j = 0; j < dimN; j++
//            cur = matC[i * dimN + j]
//            tmp += cur
//            if tmp > clipval
//                ret += 10
//                tmp = 0
//            else
//                ret += (cur > prev) ? 1 : 0
//            end
//            prev = cur
//        end
//    end
//    return ret
//end
//
