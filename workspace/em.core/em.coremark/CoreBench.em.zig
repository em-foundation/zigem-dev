pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.coremark/BenchAlgI",
});

pub const Crc = em.import.@"em.coremark/Crc";
pub const ListBench = em.import.@"em.coremark/ListBench";
pub const MatrixBench = em.import.@"em.coremark/MatrixBench";
pub const StateBench = em.import.@"em.coremark/StateBench";
pub const Utils = em.import.@"em.coremark/Utils";

pub const NUM_ALGS: u8 = 3;
pub const TOTAL_DATA_SIZE: u16 = 2000;

pub const EM__META = struct {
    //
    pub fn em__configureM() void {
        const memsize = TOTAL_DATA_SIZE / NUM_ALGS;
        ListBench.c_memsize.setM(memsize);
        MatrixBench.c_memsize.setM(memsize);
        StateBench.c_memsize.setM(memsize);
    }

    pub fn em__constructM() void {
        Utils.bindSeedM(1, 0x0);
        Utils.bindSeedM(2, 0x0);
        Utils.bindSeedM(3, 0x66);
    }
};

pub const EM__TARG = struct {
    //
    pub fn dump() void {
        ListBench.dump();
        MatrixBench.dump();
        StateBench.dump();
    }

    pub fn kind() Utils.Kind {
        return .FINAL;
    }

    pub fn print() void {
        em.print("\n*** CoreBench.print\n", .{});
        ListBench.print();
        MatrixBench.print();
        StateBench.print();
    }

    pub fn run(_: i16) Utils.sum_t {
        var crc = ListBench.run(1);
        Utils.setCrc(.FINAL, Crc.add16(@bitCast(crc), Utils.getCrc(.FINAL)));
        crc = ListBench.run(-1);
        Utils.setCrc(.FINAL, Crc.add16(@bitCast(crc), Utils.getCrc(.FINAL)));
        Utils.bindCrc(.LIST, Utils.getCrc(.FINAL));
        return Utils.getCrc(.FINAL);
    }

    pub fn setup() void {
        ListBench.setup();
        MatrixBench.setup();
        StateBench.setup();
    }
};

//->> zigem publish #|41be640228e015f80e059bb65448f42eb2398c1682ce7468468b5236f92b8ce8|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__META publics

//->> EM__TARG publics
pub const dump = EM__TARG.dump;
pub const kind = EM__TARG.kind;
pub const print = EM__TARG.print;
pub const run = EM__TARG.run;
pub const setup = EM__TARG.setup;
