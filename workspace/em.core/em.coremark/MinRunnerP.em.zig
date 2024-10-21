pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Common = em.import.@"em.mcu/Common";
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
        Common.UsCounter.start();
        for (0..ITERATIONS) |_| {
            _ = CoreBench.run(0);
        }
        em.@"%%[d-]"();
        var raw: u32 = undefined;
        const us = Common.UsCounter.stop(&raw);
        em.print("raw = {d}, us = {d}\n", .{ raw, us });
    }
};

//->> zigem publish #|e352dcac0624edb99ceb42b8a47d68a887e5d4f4a5f065b18725f5c24dac378b|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__TARG publics
