pub const em = @import("../../build/.gen/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const DurationMs = struct {
    min: u16 = 100,
    max: u16 = 4000,
};

pub const OnPressedCbFxn = em.Fxn(OnPressedCbArg);
pub const OnPressedCbArg = struct {};

pub fn isPressed() bool {
    return false;
}

pub fn onPressed(cb: OnPressedCbFxn, dur: DurationMs) void {
    _ = cb;
    _ = dur;
}
