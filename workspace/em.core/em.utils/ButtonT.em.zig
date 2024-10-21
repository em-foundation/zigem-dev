pub const em = @import("../../zigem/em.zig");
pub const em__T = em.template(@This(), .{});
pub const EM__CONFIG = struct {
    em__upath: []const u8,
    Edge: em.Proxy(EdgeI),
    debounceF: em.Param(FiberMgr.Obj),
};

pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const EdgeI = em.import.@"em.hal/EdgeI";

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

        pub const DurationMs = ButtonI.DurationMs;
        pub const OnPressedCbFxn = ButtonI.OnPressedCbFxn;
        pub const OnPressedCbArg = ButtonI.OnPressedCbArg;

        pub const EM__META = struct {
            //
            pub const x_Edge = em__C.Edge;

            pub fn em__constructM() void {
                const fiber = FiberMgr.createM(em__U.fxn("debounceFB", FiberMgr.BodyArg));
                em__C.debounceF.setM(fiber);
                em__C.Edge.getM().setDetectHandlerM(em__U.fxn("buttonHandler", EdgeI.HandlerArg));
            }
        };

        pub const EM__TARG = struct {
            //
            const Edge = em__C.Edge.unwrap();

            var cur_cb: OnPressedCbFxn = null;
            var cur_dur: u16 = 0;
            var max_dur: u16 = 0;
            var min_dur: u16 = 0;

            pub fn em__startup() void {
                Edge.init(true);
                Edge.setDetectFallingEdge();
            }

            pub fn buttonHandler(_: EdgeI.HandlerArg) void {
                Edge.clearDetect();
                if (cur_cb != null) em__C.debounceF.unwrap().post();
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

            pub fn isPressed() bool {
                return !Edge.getState();
            }

            pub fn onPressed(cb: OnPressedCbFxn, dur: DurationMs) void {
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

        
        //->> zigem publish #|1143766c7f168aaa504e38b3ad17d9da7da4725f9a28ec690a60c7c1f68cc163|#

        //->> EM__META publics
        pub const x_Edge = EM__META.x_Edge;

        //->> EM__TARG publics
        pub const buttonHandler = EM__TARG.buttonHandler;
        pub const debounceFB = EM__TARG.debounceFB;
        pub const isPressed = EM__TARG.isPressed;
        pub const onPressed = EM__TARG.onPressed;

        //->> zigem publish -- end of generated code
    };
}
