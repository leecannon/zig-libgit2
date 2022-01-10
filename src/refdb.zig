const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Refdb = opaque {
    pub fn deinit(self: *Refdb) void {
        log.debug("Refdb.deinit called", .{});

        c.git_refdb_free(@ptrCast(*c.git_refdb, self));

        log.debug("refdb freed successfully", .{});
    }

    /// Suggests that the given refdb compress or optimize its references.
    ///
    /// This mechanism is implementation specific. For on-disk reference databases, for example, this may pack all loose
    /// references.
    pub fn compress(self: *Refdb) !void {
        log.debug("Refdb.compress called", .{});

        try internal.wrapCall("git_refdb_compress", .{
            @ptrCast(*c.git_refdb, self),
        });

        log.debug("refdb compressed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
