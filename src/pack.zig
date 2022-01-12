const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const PackBuilder = opaque {
    pub fn deinit(self: *PackBuilder) void {
        log.debug("PackBuilder.deinit called", .{});

        c.git_packbuilder_free(@ptrCast(*c.git_packbuilder, self));

        log.debug("PackBuilder freed successfully", .{});
    }

    /// Set number of threads to spawn
    ///
    /// By default, libgit2 won't spawn any threads at all; when set to 0, libgit2 will autodetect the number of CPUs.
    pub fn setThreads(self: *PackBuilder, n: c_uint) c_uint {
        log.debug("PackBuilder.setThreads called, n: {}", .{n});

        const ret = c.git_packbuilder_set_threads(
            @ptrCast(*c.git_packbuilder, self),
            n,
        );

        log.debug("set number of threads to: {}", .{ret});

        return ret;
    }

    /// Get the total number of objects the packbuilder will write out
    pub fn objectCount(self: *PackBuilder) usize {
        log.debug("PackBuilder.objectCount called", .{});

        const ret = c.git_packbuilder_object_count(@ptrCast(*c.git_packbuilder, self));

        log.debug("number of objects: {}", .{ret});

        return ret;
    }

    /// Get the number of objects the packbuilder has already written out
    pub fn writtenCount(self: *PackBuilder) usize {
        log.debug("PackBuilder.writtenCount called", .{});

        const ret = c.git_packbuilder_written(@ptrCast(*c.git_packbuilder, self));

        log.debug("number of written objects: {}", .{ret});

        return ret;
    }

    /// Insert a single object
    ///
    /// For an optimal pack it's mandatory to insert objects in recency order, commits followed by trees and blobs.
    pub fn insert(self: *PackBuilder, id: *const git.Oid, name: [:0]const u8) !void {
        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.hex_buffer_size]u8 = undefined;
            const slice = try id.formatHex(&buf);
            log.debug("PackBuilder.insert called, id: {s}, name: {s}", .{
                slice,
                name,
            });
        }

        try internal.wrapCall("git_packbuilder_insert", .{
            @ptrCast(*c.git_packbuilder, self),
            @ptrCast(*const c.git_oid, id),
            name.ptr,
        });

        log.debug("successfully inserted object", .{});
    }

    /// Recursively insert an object and its referenced objects
    ///
    /// Insert the object as well as any object it references.
    pub fn insertRecursive(self: *PackBuilder, id: *const git.Oid, name: [:0]const u8) !void {
        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.hex_buffer_size]u8 = undefined;
            const slice = try id.formatHex(&buf);
            log.debug("PackBuilder.insertRecursive called, id: {s}, name: {s}", .{
                slice,
                name,
            });
        }

        try internal.wrapCall("git_packbuilder_insert_recur", .{
            @ptrCast(*c.git_packbuilder, self),
            @ptrCast(*const c.git_oid, id),
            name.ptr,
        });

        log.debug("successfully inserted object", .{});
    }

    /// Insert a root tree object
    ///
    /// This will add the tree as well as all referenced trees and blobs.
    pub fn insertTree(self: *PackBuilder, id: *const git.Oid) !void {
        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.hex_buffer_size]u8 = undefined;
            const slice = try id.formatHex(&buf);
            log.debug("PackBuilder.insertTree called, id: {s}", .{
                slice,
            });
        }

        try internal.wrapCall("git_packbuilder_insert_tree", .{
            @ptrCast(*c.git_packbuilder, self),
            @ptrCast(*const c.git_oid, id),
        });

        log.debug("successfully inserted root tree", .{});
    }

    /// Insert a commit object
    ///
    /// This will add a commit as well as the completed referenced tree.
    pub fn insertCommit(self: *PackBuilder, id: *const git.Oid) !void {
        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.hex_buffer_size]u8 = undefined;
            const slice = try id.formatHex(&buf);
            log.debug("PackBuilder.insertCommit called, id: {s}", .{
                slice,
            });
        }

        try internal.wrapCall("git_packbuilder_insert_commit", .{
            @ptrCast(*c.git_packbuilder, self),
            @ptrCast(*const c.git_oid, id),
        });

        log.debug("successfully inserted commit", .{});
    }

    /// Insert objects as given by the walk
    ///
    /// Those commits and all objects they reference will be inserted into the packbuilder.
    pub fn insertWalk(self: *PackBuilder, walk: *git.RevWalk) !void {
        log.debug("PackBuilder.insertWalk called, walk: {*}", .{walk});

        try internal.wrapCall("git_packbuilder_insert_walk", .{
            @ptrCast(*c.git_packbuilder, self),
            @ptrCast(*c.git_revwalk, walk),
        });

        log.debug("successfully inserted walk", .{});
    }

    /// Write the contents of the packfile to an in-memory buffer
    ///
    /// The contents of the buffer will become a valid packfile, even though there will be no attached index
    pub fn writeToBuffer(self: *PackBuilder) !git.Buf {
        log.debug("PackBuilder.writeToBuffer called", .{});

        var buf: git.Buf = .{};

        try internal.wrapCall("git_packbuilder_write_buf", .{
            @ptrCast(*c.git_buf, &buf),
            @ptrCast(*c.git_packbuilder, self),
        });

        log.debug("successfully wrote packfile to buffer", .{});

        return buf;
    }

    /// Write the new pack and corresponding index file to path.
    ///
    /// ## Parameters
    /// * `path` - Path to the directory where the packfile and index should be stored, or `null` for default location
    /// * `mode` - Permissions to use creating a packfile or 0 for defaults
    pub fn writeToFile(self: *PackBuilder, path: ?[:0]const u8, mode: c_uint) !void {
        log.debug("PackBuilder.writeToFile called, path: {s}, mode: {o}", .{ path, mode });

        const path_c = if (path) |str| str.ptr else null;

        try internal.wrapCall("git_packbuilder_write", .{
            @ptrCast(*c.git_packbuilder, self),
            path_c,
            mode,
            null,
            null,
        });

        log.debug("successfully wrote packfile to file", .{});
    }

    /// Write the new pack and corresponding index file to path.
    ///
    /// ## Parameters
    /// * `path` - Path to the directory where the packfile and index should be stored, or `null` for default location
    /// * `mode` - Permissions to use creating a packfile or 0 for defaults
    /// * `callback_fn` - Function to call with progress information from the indexer
    ///
    /// ## Callback Parameters
    /// * `stats` - State of the transfer
    pub fn writeToFileCallback(
        self: *PackBuilder,
        path: ?[:0]const u8,
        mode: c_uint,
        comptime callback_fn: fn (stats: *const git.IndexerProgress) c_int,
    ) !void {
        const cb = struct {
            pub fn cb(
                stats: *const git.IndexerProgress,
                _: *u8,
            ) c_int {
                return callback_fn(stats);
            }
        }.cb;

        var dummy_data: u8 = undefined;
        return self.writeToFileCallbackWithUserData(path, mode, &dummy_data, cb);
    }

    /// Write the new pack and corresponding index file to path.
    ///
    /// ## Parameters
    /// * `path` - Path to the directory where the packfile and index should be stored, or `null` for default location
    /// * `mode` - Permissions to use creating a packfile or 0 for defaults
    /// * `user_data` - Pointer to user data to be passed to the callback
    /// * `callback_fn` - Function to call with progress information from the indexer
    ///
    /// ## Callback Parameters
    /// * `stats` - State of the transfer
    /// * `user_data_ptr` - The user data
    pub fn writeToFileCallbackWithUserData(
        self: *PackBuilder,
        path: ?[:0]const u8,
        mode: c_uint,
        user_data: anytype,
        comptime callback_fn: fn (
            stats: *const git.IndexerProgress,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !void {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(
                stats: *const c.git_indexer_progress,
                payload: ?*anyopaque,
            ) callconv(.C) c_int {
                return callback_fn(@ptrCast(*const git.IndexerProgress, stats), @ptrCast(UserDataType, payload));
            }
        }.cb;

        log.debug("PackBuilder.writeToFileCallbackWithUserData called, path: {s}, mode: {o}", .{ path, mode });

        const path_c = if (path) |str| str.ptr else null;

        try internal.wrapCall("git_packbuilder_write", .{
            @ptrCast(*c.git_packbuilder, self),
            path_c,
            mode,
            cb,
            user_data,
        });

        log.debug("successfully wrote packfile to file", .{});
    }

    /// Get the packfile's hash
    ///
    /// A packfile's name is derived from the sorted hashing of all object names. 
    /// This is only correct after the packfile has been written.
    pub fn hash(self: *PackBuilder) *const git.Oid {
        log.debug("PackBuilder.hash called", .{});

        const ret = @ptrCast(
            *const git.Oid,
            c.git_packbuilder_hash(@ptrCast(*c.git_packbuilder, self)),
        );

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.hex_buffer_size]u8 = undefined;
            if (ret.formatHex(&buf)) |slice| {
                log.debug("packfile hash: {s}", .{slice});
            } else |_| {}
        }

        return ret;
    }

    /// Create the new pack and pass each object to the callback
    ///
    /// Return non-zero from the callback to terminate the iteration
    ///
    /// ## Parameters
    /// * `callback_fn` - The callback to call with each packed object's buffer
    ///
    /// ## Callback Parameters
    /// * `object_data` - Slice of the objects data
    pub fn foreach(
        self: *PackBuilder,
        comptime callback_fn: fn (object_data: []u8) c_int,
    ) !void {
        const cb = struct {
            pub fn cb(
                object_data: []u8,
                _: *u8,
            ) c_int {
                return callback_fn(object_data);
            }
        }.cb;

        var dummy_data: u8 = undefined;
        return self.foreachWithUserData(&dummy_data, cb);
    }

    /// Create the new pack and pass each object to the callback
    ///
    /// Return non-zero from the callback to terminate the iteration
    ///
    /// ## Parameters
    /// * `user_data` - Pointer to user data to be passed to the callback
    /// * `callback_fn` - The callback to call with each packed object's buffer
    ///
    /// ## Callback Parameters
    /// * `object_data` - Slice of the objects data
    /// * `user_data_ptr` - The user data
    pub fn foreachWithUserData(
        self: *PackBuilder,
        user_data: anytype,
        comptime callback_fn: fn (
            object_data: []u8,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !void {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(
                ptr: ?*anyopaque,
                len: usize,
                payload: ?*anyopaque,
            ) callconv(.C) c_int {
                return callback_fn(
                    @ptrCast([*]u8, ptr)[0..len],
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("PackBuilder.foreachWithUserData called", .{});

        try internal.wrapCall("git_packbuilder_foreach", .{
            @ptrCast(*c.git_packbuilder, self),
            cb,
            user_data,
        });
    }

    /// Set the callbacks for a packbuilder
    ///
    /// ## Parameters
    /// * `callback_fn` - Function to call with progress information during pack building. 
    ///                   Be aware that this is called inline with pack building operations, so performance may be affected.
    pub fn setCallbacks(
        self: *PackBuilder,
        comptime callback_fn: fn (
            stage: PackbuilderStage,
            current: u32,
            total: u32,
        ) void,
    ) void {
        const cb = struct {
            pub fn cb(
                stage: PackbuilderStage,
                current: u32,
                total: u32,
                _: *u8,
            ) void {
                callback_fn(stage, current, total);
            }
        }.cb;

        var dummy_data: u8 = undefined;
        return self.setCallbacksWithUserData(&dummy_data, cb);
    }

    /// Set the callbacks for a packbuilder
    ///
    /// ## Parameters
    /// * `user_data` - Pointer to user data to be passed to the callback
    /// * `callback_fn` - Function to call with progress information during pack building. 
    ///                   Be aware that this is called inline with pack building operations, so performance may be affected.
    pub fn setCallbacksWithUserData(
        self: *PackBuilder,
        user_data: anytype,
        comptime callback_fn: fn (
            stage: PackbuilderStage,
            current: u32,
            total: u32,
            user_data_ptr: @TypeOf(user_data),
        ) void,
    ) void {
        const UserDataType = @TypeOf(user_data);

        // fn (c_int, u32, u32, ?*anyopaque) callconv(.C) c_int

        const cb = struct {
            pub fn cb(
                stage: c_int,
                current: u32,
                total: u32,
                payload: ?*anyopaque,
            ) callconv(.C) c_int {
                callback_fn(
                    @intToEnum(PackbuilderStage, stage),
                    current,
                    total,
                    @ptrCast(UserDataType, payload),
                );
                return 0;
            }
        }.cb;

        log.debug("PackBuilder.setCallbacksWithUserData called", .{});

        _ = c.git_packbuilder_set_callbacks(
            @ptrCast(*c.git_packbuilder, self),
            cb,
            user_data,
        );
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Stages that are reported by the packbuilder progress callback.
pub const PackbuilderStage = enum(c_uint) {
    adding_objects = 0,
    deltafication = 1,
};

comptime {
    std.testing.refAllDecls(@This());
}
