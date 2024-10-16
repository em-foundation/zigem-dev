pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.coremark/BenchAlgI",
});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    cur_head: em.Param(Elem.Obj),
    max_elems: em.Param(u16),
    memsize: em.Param(u16),
    DataOF: em.Factory(Data),
    ElemOF: em.Factory(Elem),
};
pub const c_memsize = em__C.memsize;

pub const Common = em.import.@"em.mcu/Common";
pub const Crc = em.import.@"em.coremark/Crc";
pub const Utils = em.import.@"em.coremark/Utils";

const Bench0 = em.import.@"em.coremark/StateBench";
const Bench1 = em.import.@"em.coremark/MatrixBench";

pub const Data = struct {
    const Obj = em.Obj(Data);
    val: i16 = 0,
    idx: i16 = 0,
};

pub const Elem = struct {
    const Obj = em.Obj(Elem);
    next: ?Elem.Obj,
    data: Data.Obj,
};

pub const Comparator = fn (a: Data.Obj, b: Data.Obj) i32;

pub const dump = EM__TARG.dump;
pub const kind = EM__TARG.kind;
pub const print = EM__TARG.print;
pub const run = EM__TARG.run;
pub const setup = EM__TARG.setup;

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        const item_size = 16 + @sizeOf(Data);
        const max = @as(u16, @intFromFloat(@round(@as(f32, @floatFromInt(em__C.memsize.getM())) / @as(f32, @floatFromInt(item_size))))) - 3;
        const head = em__C.ElemOF.createM(.{});
        head.objM().data = em__C.DataOF.createM(.{});
        var p = head;
        for (0..max - 1) |_| {
            const q = em__C.ElemOF.createM(.{});
            q.objM().data = em__C.DataOF.createM(.{});
            p.objM().next = q;
            p = q;
        }
        p.objM().next = null;
        em__C.cur_head.setM(head);
        em__C.max_elems.setM(max);
    }
};

pub const EM__TARG = struct {
    //
    var cur_head = em__C.cur_head.unwrap();
    const max_elems = em__C.max_elems.unwrap();

    pub fn dump() void {
        // TODO
        return;
    }

    fn find(list: Elem.Obj, data: Data.Obj) ?Elem.Obj {
        var elem: ?Elem.Obj = list;
        if (data.idx >= 0) {
            while (elem != null and (elem.?.data.idx != data.idx)) {
                elem = elem.?.next;
            }
        } else {
            while (elem != null) {
                const v: i16 = @bitCast(@as(u16, @bitCast(elem.?.data.val)) & @as(u16, 0xff));
                if (v == data.val) break;
                elem = elem.?.next;
            }
        }
        return elem;
    }

    pub fn kind() Utils.Kind {
        return .LIST;
    }

    fn prList(list: Elem.Obj, name: []const u8) void {
        var elem: ?Elem.Obj = list;
        var sz: usize = 0;
        em.print("{s}\n[", .{name});
        while (elem != null) {
            const pre: []const u8 = if ((sz % 8) == 0) "\n    " else "";
            sz += 1;
            em.print("{s}({x:0>4},{x:0>4})", .{ pre, @as(u16, @bitCast(elem.?.data.idx)), @as(u16, @bitCast(elem.?.data.val)) });
            elem = elem.?.next;
        }
        em.print("\n], size = {d}\n", .{sz});
    }

    pub fn print() void {
        prList(cur_head, "current");
    }

    fn remove(item: Elem.Obj) Elem.Obj {
        const ret = item.next;
        const tmp = item.data;
        item.data = ret.?.data;
        ret.?.data = tmp;
        item.next = item.next.?.next;
        ret.?.next = null;
        return ret.?;
    }

    fn reverse(list: Elem.Obj) Elem.Obj {
        var p: ?Elem.Obj = list;
        var next: ?Elem.Obj = null;
        while (p != null) {
            const tmp = p.?.next;
            p.?.next = next;
            next = p;
            p = tmp;
        }
        return next.?;
    }

    pub fn run(arg: i16) Utils.sum_t {
        // em.@"%%[a+]"();
        var list = cur_head;
        const finder_idx = arg;
        const find_cnt = Utils.getSeed(3);
        var found: u16 = 0;
        var missed: u16 = 0;
        var retval: Crc.sum_t = 0;
        var data = Data{ .idx = finder_idx };
        var i: u16 = 0;
        while (i < find_cnt) : (i += 1) {
            data.val = @bitCast(i & 0xff);
            var elem = find(list, &data);
            list = reverse(list);
            if (elem == null) {
                missed += 1;
                const v: u16 = @bitCast(list.next.?.data.val);
                retval += (v >> 8) & 0x1;
            } else {
                found += 1;
                const v: u16 = @bitCast(elem.?.data.val);
                if ((v & 0x1) != 0) {
                    retval += (v >> 9) & 0x1;
                }
                if (elem.?.next != null) {
                    const tmp = elem.?.next;
                    elem.?.next = tmp.?.next;
                    tmp.?.next = list.next;
                    list.next = tmp;
                }
            }
            if (data.idx >= 0) data.idx += 1;
        }
        retval += found * 4 - missed;
        if (finder_idx > 0) list = sort(list, valCompare);
        const remover = remove(list.next.?);
        var finder = find(list, &data);
        if (finder == null) finder = list.next;
        while (finder != null) {
            retval = Crc.add16(list.data.val, retval);
            finder = finder.?.next;
        }
        unremove(remover, list.next.?);
        list = sort(list, idxCompare);
        var e = list.next;
        while (e != null) : (e = e.?.next) {
            retval = Crc.add16(list.data.val, retval);
        }
        // em.@"%%[a-]"();
        return retval;
    }

    pub fn setup() void {
        const seed = Utils.getSeed(1);
        var ki: u16 = 1;
        var kd: u16 = max_elems - 3;
        var e: ?Elem.Obj = cur_head;
        e.?.data.idx = 0;
        e.?.data.val = @bitCast(@as(u16, 0x8080));
        e = e.?.next;
        var cnt: u8 = 0;
        while (e.?.next != null) : (e = e.?.next) {
            var pat = (seed ^ kd) & 0xf;
            const dat = (pat << 3) | (kd & 0x7);
            e.?.data.val = @bitCast((dat << 8) | dat);
            kd -= 1;
            if (ki < (max_elems / 5)) {
                e.?.data.idx = @bitCast(ki);
                ki += 1;
            } else {
                pat = seed ^ ki;
                ki += 1;
                e.?.data.idx = @bitCast(@as(u16, 0x3fff) & (((ki & 0x7) << 8) | pat));
            }
            cnt += 1;
        }
        e.?.data.idx = @bitCast(@as(u16, 0x7fff));
        e.?.data.val = @bitCast(@as(u16, 0xffff));
        em.@"%%[c+]"();
        cur_head = sort(cur_head, idxCompare);
        em.@"%%[c-]"();
    }

    fn sort(list: Elem.Obj, cmp: Comparator) Elem.Obj {
        var res: ?Elem.Obj = list;
        var insize: usize = 1;
        var q: ?Elem.Obj = undefined;
        var e: Elem.Obj = undefined;
        while (true) {
            var p = res;
            res = null;
            var tail: ?Elem.Obj = null;
            var nmerges: i32 = 0; // count number of merges we do in this pass
            while (p != null) {
                nmerges += 1; // there exists a merge to be done
                // step `insize' places along from p
                q = p;
                var psize: usize = 0;
                for (0..insize) |_| {
                    psize += 1;
                    q = q.?.next;
                    if (q == null) break;
                }
                // if q hasn't fallen off end, we have two lists to merge
                var qsize: usize = insize;
                // now we have two lists; merge them
                while (psize > 0 or (qsize > 0 and q != null)) {
                    // decide whether next element of merge comes from p or q
                    if (psize == 0) {
                        // p is empty; e must come from q
                        e = q.?;
                        q = q.?.next;
                        qsize -= 1;
                    } else if (qsize == 0 or q == null) {
                        // q is empty; e must come from p.
                        e = p.?;
                        p = p.?.next;
                        psize -= 1;
                    } else if (cmp(p.?.data, q.?.data) <= 0) {
                        // First element of p is lower (or same); e must come from p.
                        e = p.?;
                        p = p.?.next;
                        psize -= 1;
                    } else {
                        // First element of q is lower; e must come from q.
                        e = q.?;
                        q = q.?.next;
                        qsize -= 1;
                    }
                    // add the next element to the merged list
                    if (tail != null) {
                        tail.?.next = e;
                    } else {
                        res = e;
                    }
                    tail = e;
                }
                // now p has stepped `insize' places along, and q has too
                p = q;
            }
            tail.?.next = null;
            // If we have done only one merge, we're finished
            if (nmerges <= 1) break; // allow for nmerges==0, the empty list case
            // Otherwise repeat, merging lists twice the size
            insize *= 2;
        }
        return res.?;
    }

    fn unremove(removed: Elem.Obj, modified: Elem.Obj) void {
        const tmp = removed.data;
        removed.data = modified.data;
        modified.data = tmp;
        removed.next = modified.next;
        modified.next = removed;
    }

    // IdxComparator

    fn idxCompare(a: Data.Obj, b: Data.Obj) i32 {
        const avu: u16 = @bitCast(a.val);
        const bvu: u16 = @bitCast(b.val);
        const sft: u4 = 8;
        const mhi: u16 = 0xff00;
        const mlo: u16 = 0x00ff;
        a.val = @bitCast((avu & mhi) | (mlo & (avu >> sft)));
        b.val = @bitCast((bvu & mhi) | (mlo & (bvu >> sft)));
        return a.idx - b.idx;
    }

    // ValComparator

    fn valCompare(a: Data.Obj, b: Data.Obj) i32 {
        const val1 = valCmpCalc(&a.val);
        const val2 = valCmpCalc(&b.val);
        // em.print("z: vcmp = {d}\n", .{val1 - val2});
        return @intCast(val1 - val2);
    }

    fn valCmpCalc(pval: *i16) i16 {
        const val: u16 = @bitCast(pval.*);
        const optype: u8 = @as(u8, @intCast(val >> 7)) & 0x1;
        if (optype != 0) return @bitCast(val & 0x007f);
        const flag = val & 0x7;
        var vtype = (val >> 3) & 0xf;
        vtype |= vtype << 4;
        var ret: u16 = undefined;
        switch (flag) {
            0 => {
                ret = Bench0.run(@bitCast(vtype));
                Utils.bindCrc(Bench0.kind(), ret);
            },
            1 => {
                ret = Bench1.run(@bitCast(vtype));
                Utils.bindCrc(Bench1.kind(), ret);
            },
            else => {
                ret = val;
            },
        }
        Utils.setCrc(.FINAL, Crc.add16(@bitCast(ret), Utils.getCrc(.FINAL)));
        ret &= 0x007f;
        pval.* = @bitCast((val & 0xff00) | 0x0080 | ret);
        return @bitCast(ret);
    }
};
