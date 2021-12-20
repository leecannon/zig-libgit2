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
            // TODO: Do this better
            if (!@hasDecl(c, "git_remote_completion_t")) return error.SkipZigTest;

            try std.testing.expectEqual(@sizeOf(c.git_indexer_progress), @sizeOf(Progress));
            try std.testing.expectEqual(@bitSizeOf(c.git_indexer_progress), @bitSizeOf(Progress));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Create a new indexer instance
    ///
    /// ## Parameters
    /// * `path` - to the directory where the packfile should be stored
    /// * `odb` - object database from which to read base objects when fixing thin packs. Pass `null` if no thin pack is expected
    ///           (an error will be returned if there are bases missing)
    /// * `options` - options
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function; a value less than zero to cancel the indexing or download
    ///
    /// ## Callback Parameters
    /// * `stats` - state of the transfer
    /// * `user_data_ptr` - The user data
    pub fn init(
        path: [:0]const u8,
        odb: ?*git.Odb,
        options: Options,
        user_data: anytype,
        comptime callback_fn: fn (
            stats: *const Progress,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !*git.Indexer {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(
                stats: [*c]const c.git_indexer_progress,
                payload: ?*anyopaque,
            ) callconv(.C) c_int {
                return callback_fn(@ptrCast(*const Progress, stats), @ptrCast(UserDataType, payload));
            }
        }.cb;

        log.debug("Indexer.init called, path={s}, odb={*}, options={}", .{ path, odb, options });

        var c_opts = c.git_indexer_options{
            .version = c.GIT_INDEXER_OPTIONS_VERSION,
            .progress_cb = cb,
            .progress_cb_payload = user_data,
            .verify = @boolToInt(options.verify),
        };

        var ret: *Indexer = undefined;

        try internal.wrapCall("git_indexer_new", .{
            @ptrCast(*c.git_indexer, &ret),
            path.ptr,
            options.mode,
            @ptrCast(?*c.git_oid, odb),
            &c_opts,
        });

        log.debug("successfully initalized Indexer", .{});

        return ret;
    }

    /// Add data to the indexer
    ///
    /// ## Parameters
    /// * `data` - the data to add
    /// * `stats` - stat storage
    pub fn append(self: *Indexer, data: []const u8, stats: *Progress) !void {
        // TODO: Do this better
        if (!@hasDecl(c, "git_indexer_progress")) @panic("`git_indexer_progress` is unsupported");

        log.debug("Indexer.append called, data_len={}, stats={}", .{ data.len, stats });

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
    /// * `data` - the data to add
    /// * `stats` - stat storage
    pub fn commit(self: *Indexer, stats: *Progress) !void {
        // TODO: Do this better
        if (!@hasDecl(c, "git_indexer_progress")) @panic("`git_indexer_progress` is unsupported");

        log.debug("Indexer.commit called, stats={}", .{stats});

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

        var opt_hash = @ptrCast(
            ?*const git.Oid,
            c.git_indexer_hash(@ptrCast(*const c.git_indexer, self)),
        );

        if (opt_hash) |ret| {
            // This check is to prevent formating the oid when we are not going to print anything
            if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
                var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
                if (ret.formatHex(&buf)) |slice| {
                    log.debug("successfully fetched packfile hash: {s}", .{slice});
                } else |_| {
                    log.debug("successfully fetched packfile, but unable to format it", .{});
                }
            }

            return ret;
        }

        log.debug("received null hash", .{});

        return null;
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
