const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const RefDb = opaque {
    pub fn deinit(self: *RefDb) void {
        log.debug("RefDb.deinit called", .{});

        raw.git_refdb_free(internal.toC(self));

        log.debug("refdb freed successfully", .{});
    }
    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
