const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Tree = opaque {
    pub fn deinit(self: *Tree) void {
        log.debug("Tree.deinit called", .{});

        c.git_tree_free(@ptrCast(*c.git_tree, self));

        log.debug("tree freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
