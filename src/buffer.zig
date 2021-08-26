const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);
const old_version: bool = @import("build_options").old_version;
const git = @import("git.zig");

/// A data buffer for exporting data from libgit2
pub const Buf = extern struct {
    ptr: ?[*]u8 = null,
    asize: usize = 0,
    size: usize = 0,

    pub fn slice(self: Buf) []const u8 {
        if (self.size == 0) return &[_]u8{};
        return self.ptr.?[0..self.size];
    }

    pub fn deinit(self: *Buf) void {
        log.debug("Buf.deinit called", .{});

        raw.git_buf_dispose(internal.toC(self));

        log.debug("Buf freed successfully", .{});
    }

    test {
        try std.testing.expectEqual(@sizeOf(raw.git_buf), @sizeOf(Buf));
        try std.testing.expectEqual(@bitSizeOf(raw.git_buf), @bitSizeOf(Buf));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
