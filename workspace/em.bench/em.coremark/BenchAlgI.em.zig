pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const Utils = em.import.@"em.coremark/Utils";

pub fn dump() void {
    // TODO
    return;
}

pub fn kind() Utils.Kind {
    // TODO
    return @enumFromInt(0);
}

pub fn print() void {
    // TODO
    return;
}

pub fn run(arg: i16) Utils.sum_t {
    // TODO
    _ = arg;
    return 0;
}

pub fn setup() void {
    // TODO
    return;
}

//package em.coremark
//
//import Utils
//
//interface BenchAlgI
//
//    config memSize: uint16
//
//    function dump()
//    function kind(): Utils.Kind
//    function print()
//    function run(arg: uarg_t = 0): Utils.sum_t
//    function setup()
//
//end
