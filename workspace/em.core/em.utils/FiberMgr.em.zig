pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    FiberOF: em.Factory(Fiber),
};

pub const Common = em.import.@"em.mcu/Common";

pub const Obj = em.Obj(Fiber);
pub const BodyFxn = em.Fxn(BodyArg);
pub const BodyArg = struct {
    arg: usize,
};

pub const FiberBody = struct {
    arg: usize,
};

pub const Fiber = struct {
    const Self = @This();
    link: ?Obj,
    body: BodyFxn,
    arg: usize = 0,
    pub fn post(self: *Self) void {
        em__U.scope().Fiber_post(self);
    }
};

pub const EM__HOST = struct {
    //
    pub fn createH(body: BodyFxn) Obj {
        const fiber = em__C.FiberOF.createH(.{ .body = body });
        return fiber;
    }
};

pub const EM__TARG = struct {
    //
    var ready_list = struct {
        const Self = @This();
        const NIL: *Fiber = @ptrFromInt(4);
        head: *Fiber = NIL,
        tail: *Fiber = NIL,
        count: u8 = 0,
        fn empty(self: *Self) bool {
            return self.head == NIL;
        }
        fn give(self: *Self, elem: *Fiber) void {
            self.count += 1;
            if (self.empty()) {
                self.head = elem;
                self.tail = elem;
            } else {
                self.tail.link = elem;
            }
            elem.link = NIL;
        }
        fn take(self: *Self) *Fiber {
            self.count -= 1;
            const e = self.head;
            self.head = e.link.?;
            e.link = null;
            if (self.head == NIL) self.tail = NIL;
            return e;
        }
    }{};

    pub fn dispatch() void {
        while (!ready_list.empty()) {
            // if (Common.GlobalInterrupts.isEnabled()) em.fail();
            const fiber = ready_list.take();
            const body = fiber.body;
            Common.GlobalInterrupts.enable();
            body.?(.{ .arg = fiber.arg });
            _ = Common.GlobalInterrupts.disable();
        }
    }

    pub fn run() void {
        Common.Idle.wakeup();
        Common.GlobalInterrupts.enable();
        while (true) {
            _ = Common.GlobalInterrupts.disable();
            dispatch();
            Common.Idle.exec();
        }
    }

    pub fn Fiber_post(self: *Fiber) void {
        const key = Common.GlobalInterrupts.disable();
        em.@"%%[a:]"(self.link == null);
        if (self.link == null) ready_list.give(self);
        // em.@"%%[a:]"(ready_list.count);
        //em.@"%%[>]"(ready_list.count);
        Common.GlobalInterrupts.restore(key);
    }
};
