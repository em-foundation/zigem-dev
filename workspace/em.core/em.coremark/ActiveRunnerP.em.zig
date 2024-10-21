pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const CoreBench = em.import.@"em.coremark/CoreBench";
pub const Utils = em.import.@"em.coremark/Utils";

pub const ITERATIONS: u16 = 10;

pub const EM__TARG = struct {
    //
    pub fn em__startup() void {
        CoreBench.setup();
    }

    pub fn em__run() void {
        em.@"%%[d+]"();
        for (0..ITERATIONS) |_| {
            _ = CoreBench.run(0);
        }
        em.@"%%[d-]"();
        em.print("z: list crc = {x:0>4}\n", .{Utils.getCrc(.LIST)});
        em.print("z: matrix crc = {x:0>4}\n", .{Utils.getCrc(.MATRIX)});
        em.print("z: state crc = {x:0>4}\n", .{Utils.getCrc(.STATE)});
        em.print("z: final crc = {x:0>4}\n", .{Utils.getCrc(.FINAL)});
    }
};

//->> zigem publish #|ab691aa544a06b13d8e0a14291cb0e0ec1d034376d96dfc16ce7b5cdb1bb746c|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__TARG publics
