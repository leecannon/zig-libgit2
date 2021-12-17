const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Tree = opaque {
    pub fn deinit(self: *Tree) void {
        log.debug("Tree.deinit called", .{});

        raw.git_tree_free(@ptrCast(*raw.git_tree, self));

        log.debug("tree freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
