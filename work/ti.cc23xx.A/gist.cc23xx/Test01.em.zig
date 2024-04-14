const std = @import("std");

const em = @import("../../.gen/em.zig");
const me = @This();

const Hal = em.Unit.@"ti.mcu.cc23xx/Hal";

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "gist.cc23xx/Test01",
    .self = me,
};

pub const d_ = &em__decls;
pub var em__decls = em__unit.declare(struct {
    max: em.Config(u32) = em.Config(u32).initV(20),
    min: em.Config(u32) = em.Config(u32).initV(10),
});

pub fn em__init() void {
    std.log.debug("hosted = {any}", .{em.hosted});
    d_.max.set(20);
}

pub fn em__run() void {
    //c.max.set(20);
    em.REG(1111).* = d_.max.get();
}
