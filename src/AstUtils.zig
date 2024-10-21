const std = @import("std");

const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");

const Ast = std.zig.Ast;

pub const NodeIter = struct {
    ast: *const Ast,
    root_decls: []const Ast.Node.Index,
    root_idx: usize,
    loc: std.ArrayList(NodeLoc),

    const NodeLoc = struct {
        idx: Ast.Node.Index,
        // 0 self, 1..n, n
        // node.children.len + 1
        last_step: u32,
    };

    const WalkDir = enum {
        down,
        up,
    };

    const Output = struct {
        idx: Ast.Node.Index,
        direction: WalkDir,
    };

    pub fn init(ast: *const Ast) NodeIter {
        return .{
            .ast = ast,
            .root_decls = ast.rootDecls(),
            .root_idx = 0,
            .loc = std.ArrayList(NodeLoc).init(Heap.get()),
        };
    }

    pub fn deinit(self: *NodeIter) void {
        self.loc.deinit();
    }

    fn append(self: *NodeIter, idx: Ast.Node.Index) !Output {
        try self.loc.append(.{
            .idx = idx,
            .last_step = 0,
        });

        return .{
            .idx = idx,
            .direction = WalkDir.down,
        };
    }

    // NOTE: When calling this externally on WalkDir.up, this will pop the
    // parent of the node that was returned. This should probably only be
    // called on WalkDir.down
    pub fn pop(self: *NodeIter) Output {
        const loc = self.loc.pop();
        return .{
            .idx = loc.idx,
            .direction = WalkDir.up,
        };
    }

    fn resolveChildNodeId(self: *NodeIter, node_idx: Ast.Node.Index, num_children_walked: u32) ?Ast.Node.Index {
        const node = self.ast.nodes.get(node_idx);
        switch (node.tag) {
            .simple_var_decl,
            .fn_decl,
            .fn_proto_multi,
            .fn_proto_simple,
            .builtin_call_two,
            .number_literal,
            .string_literal,
            .container_decl_two,
            .container_field_init,
            .block_two_semicolon,
            .identifier,
            => {
                switch (num_children_walked) {
                    0 => return node.data.lhs,
                    1 => return node.data.rhs,
                    else => return null,
                }
            },
            .container_decl => {
                const idx = node.data.lhs + num_children_walked;
                if (idx >= node.data.rhs) {
                    return null;
                }
                return self.ast.extra_data[idx];
            },
            else => {
                std.log.err("Unhandled tag: {any}", .{node.tag});
                return null;
            },
        }
    }

    pub fn next(self: *NodeIter) !?Output {
        while (true) {
            if (self.loc.items.len == 0) {
                if (self.root_idx >= self.root_decls.len) {
                    return null;
                }

                defer self.root_idx += 1;
                return try self.append(self.root_decls[self.root_idx]);
            }

            const loc = &self.loc.items[self.loc.items.len - 1];

            while (self.resolveChildNodeId(loc.idx, loc.last_step)) |node_idx| {
                defer loc.last_step += 1;
                if (node_idx == 0) {
                    continue;
                }
                return try self.append(node_idx);
            }

            return self.pop();
        }
    }
};

pub fn parse(path: []const u8) !Ast {
    const norm = try Fs.normalize(path);
    const source = Fs.readFileZ(norm);
    const ast = try Ast.parse(Heap.get(), source, .zig);
    return ast;
}
