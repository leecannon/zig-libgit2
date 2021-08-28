const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

pub const Tree = opaque {
    pub fn deinit(self: *Tree) void {
        log.debug("Tree.deinit called", .{});

        raw.git_tree_free(internal.toC(self));

        log.debug("tree freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
