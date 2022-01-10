const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Indexer = opaque {
    pub const Options = struct {
        /// permissions to use creating packfile or 0 for defaults
        mode: c_uint = 0,

        /// do connectivity checks for the received pack
        verify: bool = false,
    };

    /// This structure is used to provide callers information about the progress of indexing a packfile, either directly or part
    /// of a fetch or clone that downloads a packfile.
    pub const Progress = extern struct {
        /// number of objects in the packfile being indexed
        total_objects: c_int,

        /// received objects that have been hashed
        indexed_objects: c_int,

        /// received_objects: objects which have been downloaded
        received_objects: c_int,

        /// locally-available objects that have been injected in order to fix a thin pack
        local_objects: c_int,

        /// number of deltas in the packfile being indexed
        total_deltas: c_int,

        /// received deltas that have been indexed
        indexed_deltas: c_int,

        /// size of the packfile received up to now
        received_bytes: usize,

        test {
            try std.testing.expectEqual(@sizeOf(c.git_indexer_progress), @sizeOf(Progress));
            try std.testing.expectEqual(@bitSizeOf(c.git_indexer_progress), @bitSizeOf(Progress));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Add data to the indexer
    ///
    /// ## Parameters
    /// * `data` - The data to add
    /// * `stats` - Stat storage
    pub fn append(self: *Indexer, data: []const u8, stats: *Progress) !void {
        log.debug("Indexer.append called, data_len: {}, stats: {}", .{ data.len, stats });

        try internal.wrapCall("git_indexer_append", .{
            @ptrCast(*c.git_indexer, self),
            data.ptr,
            data.len,
            @ptrCast(*c.git_indexer_progress, stats),
        });

        log.debug("successfully appended to indexer", .{});
    }

    /// Finalize the pack and index
    ///
    /// Resolve any pending deltas and write out the index file
    ///
    /// ## Parameters
    /// * `data` - The data to add
    /// * `stats` - Stat storage
    pub fn commit(self: *Indexer, stats: *Progress) !void {
        log.debug("Indexer.commit called, stats: {}", .{stats});

        try internal.wrapCall("git_indexer_commit", .{
            @ptrCast(*c.git_indexer, self),
            @ptrCast(*c.git_indexer_progress, stats),
        });

        log.debug("successfully commited indexer", .{});
    }

    /// Get the packfile's hash
    ///
    /// A packfile's name is derived from the sorted hashing of all object names. This is only correct after the index has been
    /// finalized.
    pub fn hash(self: *const Indexer) ?*const git.Oid {
        log.debug("Indexer.hash called", .{});

        return @ptrCast(
            ?*const git.Oid,
            c.git_indexer_hash(@ptrCast(*const c.git_indexer, self)),
        );
    }

    pub fn deinit(self: *Indexer) void {
        log.debug("Indexer.deinit called", .{});

        c.git_indexer_free(@ptrCast(*c.git_indexer, self));

        log.debug("Indexer freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
