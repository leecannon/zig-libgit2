const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const RefDb = opaque {
    pub fn deinit(self: *RefDb) void {
        log.debug("RefDb.deinit called", .{});

        c.git_refdb_free(@ptrCast(*c.git_refdb, self));

        log.debug("refdb freed successfully", .{});
    }
    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
