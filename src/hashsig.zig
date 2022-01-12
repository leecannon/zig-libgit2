const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

/// Similarity signature of arbitrary text content based on line hashes
pub const Hashsig = opaque {
    pub fn deinit(self: *Hashsig) void {
        log.debug("Hashsig.deinit called", .{});

        c.git_hashsig_free(@ptrCast(*c.git_hashsig, self));

        log.debug("hashsig freed successfully", .{});
    }

    /// Measure similarity score between two similarity signatures
    ///
    /// Returns [0 to 100] as the similarity score
    pub fn compare(self: *const Hashsig, other: *const Hashsig) !u7 {
        log.debug("Hashsig.compare called, other: {*}", .{other});

        const ret = try internal.wrapCallWithReturn("git_hashsig_compare", .{
            @ptrCast(*const c.git_hashsig, self),
            @ptrCast(*const c.git_hashsig, other),
        });

        log.debug("similarity score: {}", .{ret});

        return @truncate(u7, @intCast(c_uint, ret));
    }

    /// Options for hashsig computation
    pub const HashsigOptions = struct {
        whitespace_mode: WhitespaceMode = .normal,

        /// Allow hashing of small files
        allow_small_files: bool = false,

        pub const WhitespaceMode = enum {
            /// Use all data
            normal,
            /// Ignore whitespace
            ignore_whitespace,
            /// Ignore \r and all space after \n
            smart_whitespace,
        };

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
