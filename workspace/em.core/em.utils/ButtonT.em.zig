pub const em = @import("../../zigem/em.zig");
pub const em__T = em.template(@This(), .{});
pub const EM__CONFIG = struct {
    em__upath: []const u8,
    Edge: em.Proxy(GpioEdgeI),
    debounceF: em.Param(FiberMgr.Obj),
};

pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const GpioEdgeI = em.import.@"em.hal/GpioEdgeI";

pub fn em__generateS(comptime name: []const u8) type {
    //
    return struct {
        //
        pub const em__U = em.module(@This(), .{
            .inherits = ButtonI,
            .generated = true,
            .name = name,
        });
        pub const em__C = em__U.config(EM__CONFIG);

        pub const ButtonI = em.import.@"em.hal/ButtonI";
        pub const Poller = em.import.@"em.mcu/Poller";

        pub const x_Edge = em__C.Edge;

        pub const DurationMs = ButtonI.DurationMs;
        pub const OnPressedCbFxn = ButtonI.OnPressedCbFxn;
        pub const OnPressedCbArg = ButtonI.OnPressedCbArg;

        pub const isPressed = EM__TARG.isPressed;
        pub const onPressed = EM__TARG.onPressed;

        pub const EM__META = struct {
            //
            pub fn em__constructH() void {
                const fiber = FiberMgr.createH(em__U.fxn("debounceFB", FiberMgr.BodyArg));
                em__C.debounceF.set(fiber);
                em__C.Edge.get().setDetectHandlerH(em__U.fxn("buttonHandler", GpioEdgeI.HandlerArg));
            }
        };

        pub const EM__TARG = struct {
            //
            const Edge = em__C.Edge.get();

            var cur_cb: OnPressedCbFxn = null;
            var cur_dur: u16 = 0;
            var max_dur: u16 = 0;
            var min_dur: u16 = 0;

            pub fn em__startup() void {
                Edge.makeInput();
                Edge.setInternalPullup(true);
                Edge.setDetectFallingEdge();
            }

            pub fn buttonHandler(_: GpioEdgeI.HandlerArg) void {
                Edge.clearDetect();
                if (cur_cb != null) em__C.debounceF.get().post();
            }

            pub fn debounceFB(_: FiberMgr.BodyArg) void {
                cur_dur = 0;
                while (true) {
                    Poller.pause(min_dur);
                    if (cur_dur == 0 and !EM__TARG.isPressed()) return;
                    cur_dur += min_dur;
                    if (!EM__TARG.isPressed() or cur_dur >= max_dur) break;
                }
                cur_cb.?(.{});
            }

            fn isPressed() bool {
                return !Edge.get();
            }

            fn onPressed(cb: OnPressedCbFxn, dur: DurationMs) void {
                cur_cb = cb;
                max_dur = dur.max;
                min_dur = dur.min;
                if (cb == null) {
                    Edge.disableDetect();
                } else {
                    Edge.enableDetect();
                }
            }
        };
    };
}
