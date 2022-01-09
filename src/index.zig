const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");
const bitjuggle = @import("internal/bitjuggle.zig");

pub const Index = opaque {
    pub fn deinit(self: *Index) void {
        log.debug("Index.deinit called", .{});

        c.git_index_free(@ptrCast(*c.git_index, self));

        log.debug("index freed successfully", .{});
    }

    pub fn versionGet(self: *Index) !IndexVersion {
        log.debug("Index.versionGet called", .{});

        const raw_value = c.git_index_version(@ptrCast(*c.git_index, self));

        if (std.meta.intToEnum(IndexVersion, raw_value)) |version| {
            log.debug("successfully fetched index version: {s}", .{@tagName(version)});
            return version;
        } else |_| {
            log.debug("failed to fetch valid index version, recieved: {}", .{raw_value});
            return error.InvalidVersion;
        }
    }

    pub fn versionSet(self: *Index, version: IndexVersion) !void {
        log.debug("Index.setVersion called, version: {s}", .{@tagName(version)});

        try internal.wrapCall("git_index_set_version", .{ @ptrCast(*c.git_index, self), @enumToInt(version) });

        log.debug("successfully set index version", .{});
    }

    pub const IndexVersion = enum(c_uint) {
        @"2" = 2,
        @"3" = 3,
        @"4" = 4,
    };

    /// Update the contents of this index by reading from the hard disk.
    ///
    /// If `force` is true, in-memory changes are discarded.
    pub fn readIndexFromDisk(self: *Index, force: bool) !void {
        log.debug("Index.readIndexFromDisk called, force: {}", .{force});

        try internal.wrapCall("git_index_read", .{ @ptrCast(*c.git_index, self), @boolToInt(force) });

        log.debug("successfully read index data from disk", .{});
    }

    pub fn writeToDisk(self: *Index) !void {
        log.debug("Index.writeToDisk called", .{});

        try internal.wrapCall("git_index_write", .{@ptrCast(*c.git_index, self)});

        log.debug("successfully wrote index data to disk", .{});
    }

    pub fn pathGet(self: *const Index) ?[:0]const u8 {
        log.debug("Index.pathGet called", .{});

        if (c.git_index_path(@ptrCast(*const c.git_index, self))) |ptr| {
            const slice = std.mem.sliceTo(ptr, 0);
            log.debug("successfully fetched index path: {s}", .{slice});
            return slice;
        }

        log.debug("in-memory index has no path", .{});
        return null;
    }

    pub fn repositoryGet(self: *const Index) ?*git.Repository {
        log.debug("Index.repositoryGet called", .{});

        return @ptrCast(
            ?*git.Repository,
            c.git_index_owner(@ptrCast(*const c.git_index, self)),
        );
    }

    /// Get the checksum of the index
    ///
    /// This checksum is the SHA-1 hash over the index file (except the last 20 bytes which are the checksum itself). In cases
    /// where the index does not exist on-disk, it will be zeroed out.
    pub fn checksum(self: *Index) !*const git.Oid {
        log.debug("Index.checksum called", .{});

        const oid = @ptrCast(
            *const git.Oid,
            c.git_index_checksum(@ptrCast(*c.git_index, self)),
        );

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const slice = try oid.formatHex(&buf);
            log.debug("index checksum acquired successfully, checksum: {s}", .{slice});
        }

        return oid;
    }

    pub fn setToTree(self: *Index, tree: *const git.Tree) !void {
        log.debug("Index.setToTree called, tree: {*}", .{tree});

        try internal.wrapCall("git_index_read_tree", .{
            @ptrCast(*c.git_index, self),
            @ptrCast(*const c.git_tree, tree),
        });

        log.debug("successfully set index to tree", .{});
    }

    pub fn writeToTreeOnDisk(self: *Index) !git.Oid {
        log.debug("Index.writeToTreeOnDisk called", .{});

        var oid: git.Oid = undefined;

        try internal.wrapCall("git_index_write_tree", .{ @ptrCast(*c.git_oid, &oid), @ptrCast(*c.git_index, self) });

        log.debug("successfully wrote index tree to disk", .{});

        return oid;
    }

    pub fn entryCount(self: *const Index) usize {
        log.debug("Index.entryCount called", .{});

        const ret = c.git_index_entrycount(@ptrCast(*const c.git_index, self));

        log.debug("index entry count: {}", .{ret});

        return ret;
    }

    /// Clear the contents of this index.
    ///
    /// This clears the index in memory; changes must be written to disk for them to be persistent.
    pub fn clear(self: *Index) !void {
        log.debug("Index.clear called", .{});

        try internal.wrapCall("git_index_clear", .{@ptrCast(*c.git_index, self)});

        log.debug("successfully cleared index", .{});
    }

    pub fn writeToTreeInRepository(self: *Index, repository: *git.Repository) !git.Oid {
        log.debug("Index.writeToTreeIngit.Repository called, repository: {*}", .{repository});

        var oid: git.Oid = undefined;

        try internal.wrapCall("git_index_write_tree_to", .{
            @ptrCast(*c.git_oid, &oid),
            @ptrCast(*c.git_index, self),
            @ptrCast(*c.git_repository, repository),
        });

        log.debug("successfully wrote index tree to repository", .{});

        return oid;
    }

    pub fn indexCapabilities(self: *const Index) IndexCapabilities {
        log.debug("Index.indexCapabilities called", .{});

        const cap = @bitCast(IndexCapabilities, c.git_index_caps(@ptrCast(*const c.git_index, self)));

        log.debug("successfully fetched index capabilities: {}", .{cap});

        return cap;
    }

    /// If you pass `IndexCapabilities.FROM_OWNER` for the capabilities, then capabilities will be read from the config of the
    /// owner object, looking at `core.ignorecase`, `core.filemode`, `core.symlinks`.
    pub fn indexCapabilitiesSet(self: *Index, capabilities: IndexCapabilities) !void {
        log.debug("Index.getIndexCapabilities called, capabilities: {}", .{capabilities});

        try internal.wrapCall("git_index_set_caps", .{ @ptrCast(*c.git_index, self), @bitCast(c_int, capabilities) });

        log.debug("successfully set index capabilities", .{});
    }

    pub const IndexCapabilities = packed struct {
        IGNORE_CASE: bool = false,
        NO_FILEMODE: bool = false,
        NO_SYMLINKS: bool = false,

        z_padding1: u13 = 0,
        z_padding2: u16 = 0,

        pub fn isGetCapabilitiesFromOwner(self: IndexCapabilities) bool {
            return @bitCast(c_int, self) == -1;
        }

        pub fn getCapabilitiesFromOwner() IndexCapabilities {
            return @bitCast(IndexCapabilities, @as(c_int, -1));
        }

        pub fn format(
            value: IndexCapabilities,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            return internal.formatWithoutFields(
                value,
                options,
                writer,
                &.{ "z_padding1", "z_padding2" },
            );
        }

        test {
            try std.testing.expectEqual(@sizeOf(c_int), @sizeOf(IndexCapabilities));
            try std.testing.expectEqual(@bitSizeOf(c_int), @bitSizeOf(IndexCapabilities));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    pub fn entryByIndex(self: *Index, index: usize) ?*const IndexEntry {
        log.debug("Index.entryByIndex called, index: {}", .{index});

        return @ptrCast(
            ?*const IndexEntry,
            c.git_index_get_byindex(@ptrCast(*c.git_index, self), index),
        );
    }

    pub fn entryByPath(self: *Index, path: [:0]const u8, stage: c_int) ?*const IndexEntry {
        log.debug("Index.entryByPath called, path: {s}, stage: {}", .{ path, stage });

        return @ptrCast(
            ?*const IndexEntry,
            c.git_index_get_bypath(@ptrCast(*c.git_index, self), path.ptr, stage),
        );
    }

    pub fn remove(self: *Index, path: [:0]const u8, stage: c_int) !void {
        log.debug("Index.remove called, path: {s}, stage: {}", .{ path, stage });

        try internal.wrapCall("git_index_remove", .{ @ptrCast(*c.git_index, self), path.ptr, stage });

        log.debug("successfully removed from index", .{});
    }

    pub fn directoryRemove(self: *Index, path: [:0]const u8, stage: c_int) !void {
        log.debug("Index.directoryRemove called, path: {s}, stage: {}", .{ path, stage });

        try internal.wrapCall("git_index_remove_directory", .{ @ptrCast(*c.git_index, self), path.ptr, stage });

        log.debug("successfully removed from index", .{});
    }

    pub fn add(self: *Index, entry: *const IndexEntry) !void {
        log.debug("Index.add called, entry: {*}", .{entry});

        try internal.wrapCall("git_index_add", .{ @ptrCast(*c.git_index, self), @ptrCast(*const c.git_index_entry, entry) });

        log.debug("successfully added to index", .{});
    }

    /// The `path` must be relative to the repository's working folder.
    ///
    /// This forces the file to be added to the index, not looking at gitignore rules. Those rules can be evaluated using
    /// `git.Repository.statusShouldIgnore`.
    pub fn addByPath(self: *Index, path: [:0]const u8) !void {
        log.debug("Index.addByPath called, path: {s}", .{path});

        try internal.wrapCall("git_index_add_bypath", .{ @ptrCast(*c.git_index, self), path.ptr });

        log.debug("successfully added to index", .{});
    }

    pub fn addFromBuffer(self: *Index, index_entry: *const IndexEntry, buffer: []const u8) !void {
        log.debug("Index.addFromBuffer called, index_entry: {*}, buffer.ptr: {*}, buffer.len: {}", .{
            index_entry,
            buffer.ptr,
            buffer.len,
        });

        if (@hasDecl(c, "git_index_add_from_buffer")) {
            try internal.wrapCall(
                "git_index_add_from_buffer",
                .{ @ptrCast(*c.git_index, self), @ptrCast(*const c.git_index_entry, index_entry), buffer.ptr, buffer.len },
            );
        } else {
            try internal.wrapCall(
                "git_index_add_frombuffer",
                .{ @ptrCast(*c.git_index, self), @ptrCast(*const c.git_index_entry, index_entry), buffer.ptr, buffer.len },
            );
        }

        log.debug("successfully added to index", .{});
    }

    pub fn removeByPath(self: *Index, path: [:0]const u8) !void {
        log.debug("Index.removeByPath called, path: {s}", .{path});

        try internal.wrapCall("git_index_remove_bypath", .{ @ptrCast(*c.git_index, self), path.ptr });

        log.debug("successfully remove from index", .{});
    }

    pub fn iterate(self: *Index) !*IndexIterator {
        log.debug("Index.iterate called", .{});

        var iterator: *IndexIterator = undefined;

        try internal.wrapCall("git_index_iterator_new", .{
            @ptrCast(*?*c.git_index_iterator, &iterator),
            @ptrCast(*c.git_index, self),
        });

        log.debug("index iterator created successfully", .{});

        return iterator;
    }

    pub const IndexIterator = opaque {
        pub fn next(self: *IndexIterator) !?*const IndexEntry {
            log.debug("IndexIterator.next called", .{});

            var index_entry: *const IndexEntry = undefined;

            internal.wrapCall("git_index_iterator_next", .{
                @ptrCast(*?*c.git_index_entry, &index_entry),
                @ptrCast(*c.git_index_iterator, self),
            }) catch |err| switch (err) {
                git.GitError.IterOver => {
                    log.debug("end of iteration reached", .{});
                    return null;
                },
                else => return err,
            };

            log.debug("successfully fetched index entry: {}", .{index_entry});

            return index_entry;
        }

        pub fn deinit(self: *IndexIterator) void {
            log.debug("IndexIterator.deinit called", .{});

            c.git_index_iterator_free(@ptrCast(*c.git_index_iterator, self));

            log.debug("index iterator freed successfully", .{});
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Remove all matching index entries.
    ///
    /// If you provide a callback function, it will be invoked on each matching item in the working directory immediately *before*
    /// it is removed.  Returning zero will remove the item, greater than zero will skip the item, and less than zero will abort
    /// the scan and return that value to the caller.
    ///
    /// ## Parameters
    /// * `pathspec` - array of path patterns
    /// * `callback_fn` - the callback function; return 0 to remove, < 0 to abort, > 0 to skip.
    ///
    /// ## Callback Parameters
    /// * `path` - The reference name
    /// * `matched_pathspec` - The remote URL
    pub fn removeAll(
        self: *Index,
        pathspec: *const git.StrArray,
        comptime callback_fn: ?fn (
            path: [:0]const u8,
            matched_pathspec: [:0]const u8,
        ) c_int,
    ) !c_int {
        if (callback_fn) |callback| {
            const cb = struct {
                pub fn cb(
                    path: [:0]const u8,
                    matched_pathspec: [:0]const u8,
                    _: *u8,
                ) c_int {
                    return callback(path, matched_pathspec);
                }
            }.cb;

            var dummy_data: u8 = undefined;
            return self.removeAllWithUserData(pathspec, &dummy_data, cb);
        } else {
            return self.removeAllWithUserData(pathspec, null, null);
        }
    }

    /// Remove all matching index entries.
    ///
    /// If you provide a callback function, it will be invoked on each matching item in the working directory immediately *before*
    /// it is removed.  Returning zero will remove the item, greater than zero will skip the item, and less than zero will abort
    /// the scan and return that value to the caller.
    ///
    /// ## Parameters
    /// * `pathspec` - array of path patterns
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function; return 0 to remove, < 0 to abort, > 0 to skip.
    ///
    /// ## Callback Parameters
    /// * `path` - The reference name
    /// * `matched_pathspec` - The remote URL
    /// * `user_data_ptr` - The user data
    pub fn removeAllWithUserData(
        self: *Index,
        pathspec: *const git.StrArray,
        user_data: anytype,
        comptime callback_fn: ?fn (
            path: [:0]const u8,
            matched_pathspec: [:0]const u8,
            user_data_ptr: @TypeOf(user_data),
        ) void,
    ) !c_int {
        if (callback_fn) |callback| {
            const UserDataType = @TypeOf(user_data);

            const cb = struct {
                pub fn cb(
                    path: [*:0]const u8,
                    matched_pathspec: [*:0]const u8,
                    payload: ?*anyopaque,
                ) callconv(.C) c_int {
                    return callback(
                        std.mem.sliceTo(path, 0),
                        std.mem.sliceTo(matched_pathspec, 0),
                        @ptrCast(UserDataType, payload),
                    );
                }
            }.cb;

            log.debug("Index.removeAllWithUserData called", .{});

            const ret = try internal.wrapCallWithReturn("git_index_remove_all", .{
                @ptrCast(*const c.git_index, self),
                @ptrCast(*const c.git_strarray, pathspec),
                cb,
                user_data,
            });

            log.debug("callback returned: {}", .{ret});

            return ret;
        } else {
            log.debug("Index.removeAllWithUserData called", .{});

            try internal.wrapCall("git_index_remove_all", .{
                @ptrCast(*const c.git_index, self),
                @ptrCast(*const c.git_strarray, pathspec),
                null,
                null,
            });

            return 0;
        }
    }

    /// Update all index entries to match the working directory
    ///
    /// If you provide a callback function, it will be invoked on each matching item in the working directory immediately *before*
    /// it is updated.  Returning zero will update the item, greater than zero will skip the item, and less than zero will abort
    /// the scan and return that value to the caller.
    ///
    /// ## Parameters
    /// * `pathspec` - array of path patterns
    /// * `callback_fn` - the callback function; return 0 to update, < 0 to abort, > 0 to skip.
    ///
    /// ## Callback Parameters
    /// * `path` - The reference name
    /// * `matched_pathspec` - The remote URL
    pub fn updateAll(
        self: *Index,
        pathspec: *const git.StrArray,
        comptime callback_fn: ?fn (
            path: [:0]const u8,
            matched_pathspec: [:0]const u8,
        ) c_int,
    ) !c_int {
        if (callback_fn) |callback| {
            const cb = struct {
                pub fn cb(
                    path: [:0]const u8,
                    matched_pathspec: [:0]const u8,
                    _: *u8,
                ) c_int {
                    return callback(path, matched_pathspec);
                }
            }.cb;

            var dummy_data: u8 = undefined;
            return self.updateAllWithUserData(pathspec, &dummy_data, cb);
        } else {
            return self.updateAllWithUserData(pathspec, null, null);
        }
    }

    /// Update all index entries to match the working directory
    ///
    /// If you provide a callback function, it will be invoked on each matching item in the working directory immediately *before*
    /// it is updated.  Returning zero will update the item, greater than zero will skip the item, and less than zero will abort
    /// the scan and return that value to the caller.
    ///
    /// ## Parameters
    /// * `pathspec` - array of path patterns
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function; return 0 to update, < 0 to abort, > 0 to skip.
    ///
    /// ## Callback Parameters
    /// * `path` - The reference name
    /// * `matched_pathspec` - The remote URL
    /// * `user_data_ptr` - The user data
    pub fn updateAllWithUserData(
        self: *Index,
        pathspec: *const git.StrArray,
        user_data: anytype,
        comptime callback_fn: ?fn (
            path: [:0]const u8,
            matched_pathspec: [:0]const u8,
            user_data_ptr: @TypeOf(user_data),
        ) void,
    ) !c_int {
        if (callback_fn) |callback| {
            const UserDataType = @TypeOf(user_data);

            const cb = struct {
                pub fn cb(
                    path: [*:0]const u8,
                    matched_pathspec: [*:0]const u8,
                    payload: ?*anyopaque,
                ) callconv(.C) c_int {
                    return callback(
                        std.mem.sliceTo(path, 0),
                        std.mem.sliceTo(matched_pathspec, 0),
                        @ptrCast(UserDataType, payload),
                    );
                }
            }.cb;

            log.debug("Index.updateAllWithUserData called", .{});

            const ret = try internal.wrapCallWithReturn("git_index_update_all", .{
                @ptrCast(*const c.git_index, self),
                @ptrCast(*const c.git_strarray, pathspec),
                cb,
                user_data,
            });

            log.debug("callback returned: {}", .{ret});

            return ret;
        } else {
            log.debug("Index.updateAllWithUserData called", .{});

            try internal.wrapCall("git_index_update_all", .{
                @ptrCast(*const c.git_index, self),
                @ptrCast(*const c.git_strarray, pathspec),
                null,
                null,
            });

            return 0;
        }
    }

    /// Add or update index entries matching files in the working directory.
    ///
    /// The `pathspec` is a list of file names or shell glob patterns that will be matched against files in the repository's
    /// working directory. Each file that matches will be added to the index (either updating an existing entry or adding a new
    /// entry).  You can disable glob expansion and force exact matching with the `AddFlags.DISABLE_PATHSPEC_MATCH` flag.
    /// Invoke `callback_fn` for each entry in the given FETCH_HEAD file.
    ///
    /// Files that are ignored will be skipped (unlike `Index.AddByPath`). If a file is already tracked in the index, then it
    /// *will* be updated even if it is ignored. Pass the `AddFlags.FORCE` flag to skip the checking of ignore rules.
    ///
    /// If you provide a callback function, it will be invoked on each matching item in the working directory immediately *before*
    /// it is added to/updated in the index.  Returning zero will add the item to the index, greater than zero will skip the item,
    /// and less than zero will abort the scan and return that value to the caller.
    ///
    /// ## Parameters
    /// * `pathspec` - array of path patterns
    /// * `flags` - flags controlling how the add is performed
    /// * `callback_fn` - the callback function; return 0 to add, < 0 to abort, > 0 to skip.
    ///
    /// ## Callback Parameters
    /// * `path` - The reference name
    /// * `matched_pathspec` - The remote URL
    pub fn addAll(
        self: *Index,
        pathspec: *const git.StrArray,
        flags: AddFlags,
        comptime callback_fn: ?fn (
            path: [:0]const u8,
            matched_pathspec: [:0]const u8,
        ) c_int,
    ) !c_int {
        if (callback_fn) |callback| {
            const cb = struct {
                pub fn cb(
                    path: [:0]const u8,
                    matched_pathspec: [:0]const u8,
                    _: *u8,
                ) c_int {
                    return callback(path, matched_pathspec);
                }
            }.cb;

            var dummy_data: u8 = undefined;
            return self.addAllWithUserData(pathspec, flags, &dummy_data, cb);
        } else {
            return self.addAllWithUserData(pathspec, flags, null, null);
        }
    }

    /// Add or update index entries matching files in the working directory.
    ///
    /// The `pathspec` is a list of file names or shell glob patterns that will be matched against files in the repository's
    /// working directory. Each file that matches will be added to the index (either updating an existing entry or adding a new
    /// entry).  You can disable glob expansion and force exact matching with the `AddFlags.DISABLE_PATHSPEC_MATCH` flag.
    /// Invoke `callback_fn` for each entry in the given FETCH_HEAD file.
    ///
    /// Files that are ignored will be skipped (unlike `Index.AddByPath`). If a file is already tracked in the index, then it
    /// *will* be updated even if it is ignored. Pass the `AddFlags.FORCE` flag to skip the checking of ignore rules.
    ///
    /// If you provide a callback function, it will be invoked on each matching item in the working directory immediately *before*
    /// it is added to/updated in the index.  Returning zero will add the item to the index, greater than zero will skip the item,
    /// and less than zero will abort the scan and return that value to the caller.
    ///
    /// ## Parameters
    /// * `pathspec` - array of path patterns
    /// * `flags` - flags controlling how the add is performed
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function; return 0 to add, < 0 to abort, > 0 to skip.
    ///
    /// ## Callback Parameters
    /// * `path` - The reference name
    /// * `matched_pathspec` - The remote URL
    /// * `user_data_ptr` - The user data
    pub fn addAllWithUserData(
        self: *Index,
        pathspec: *const git.StrArray,
        flags: AddFlags,
        user_data: anytype,
        comptime callback_fn: ?fn (
            path: [:0]const u8,
            matched_pathspec: [:0]const u8,
            user_data_ptr: @TypeOf(user_data),
        ) void,
    ) !c_int {
        if (callback_fn) |callback| {
            const UserDataType = @TypeOf(user_data);

            const cb = struct {
                pub fn cb(
                    path: [*:0]const u8,
                    matched_pathspec: [*:0]const u8,
                    payload: ?*anyopaque,
                ) callconv(.C) c_int {
                    return callback(
                        std.mem.sliceTo(path, 0),
                        std.mem.sliceTo(matched_pathspec, 0),
                        @ptrCast(UserDataType, payload),
                    );
                }
            }.cb;

            log.debug("Index.addAllWithUserData called", .{});

            const ret = try internal.wrapCallWithReturn("git_index_add_all", .{
                @ptrCast(*const c.git_index, self),
                @ptrCast(*const c.git_strarray, pathspec),
                @bitCast(c_int, flags),
                cb,
                user_data,
            });

            log.debug("callback returned: {}", .{ret});

            return ret;
        } else {
            log.debug("Index.addAllWithUserData called", .{});

            try internal.wrapCall("git_index_add_all", .{
                @ptrCast(*const c.git_index, self),
                @ptrCast(*const c.git_strarray, pathspec),
                @bitCast(c_int, flags),
                null,
                null,
            });

            return 0;
        }
    }

    pub const AddFlags = packed struct {
        FORCE: bool = false,
        DISABLE_PATHSPEC_MATCH: bool = false,
        CHECK_PATHSPEC: bool = false,

        z_padding: u29 = 0,

        pub fn format(
            value: AddFlags,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            return internal.formatWithoutFields(
                value,
                options,
                writer,
                &.{"z_padding"},
            );
        }

        test {
            try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(AddFlags));
            try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(AddFlags));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    pub fn find(self: *Index, path: [:0]const u8) !usize {
        log.debug("Index.find called, path: {s}", .{path});

        var position: usize = 0;

        try internal.wrapCall("git_index_find", .{ &position, @ptrCast(*c.git_index, self), path.ptr });

        log.debug("successfully fetched position: {}", .{position});

        return position;
    }

    pub fn findPrefix(self: *Index, prefix: [:0]const u8) !usize {
        log.debug("Index.find called, prefix: {s}", .{prefix});

        var position: usize = 0;

        try internal.wrapCall("git_index_find_prefix", .{ &position, @ptrCast(*c.git_index, self), prefix.ptr });

        log.debug("successfully fetched position: {}", .{position});

        return position;
    }

    /// Add or update index entries to represent a conflict.  Any staged entries that exist at the given paths will be removed.
    ///
    /// The entries are the entries from the tree included in the merge.  Any entry may be null to indicate that that file was not
    /// present in the trees during the merge. For example, `ancestor_entry` may be `null` to indicate that a file was added in
    /// both branches and must be resolved.
    pub fn conflictAdd(
        self: *Index,
        ancestor_entry: ?*const IndexEntry,
        our_entry: ?*const IndexEntry,
        their_entry: ?*const IndexEntry,
    ) !void {
        log.debug("Index.conflictAdd called, ancestor_entry: {*}, our_entry: {*}, their_entry: {*}", .{
            ancestor_entry,
            our_entry,
            their_entry,
        });

        try internal.wrapCall("git_index_conflict_add", .{
            @ptrCast(*c.git_index, self),
            @ptrCast(?*const c.git_index_entry, ancestor_entry),
            @ptrCast(?*const c.git_index_entry, our_entry),
            @ptrCast(?*const c.git_index_entry, their_entry),
        });

        log.debug("successfully wrote index data to disk", .{});
    }

    /// Get the index entries that represent a conflict of a single file.
    ///
    /// *IMPORTANT*: These entries should *not* be freed.
    pub fn conflictGet(index: *Index, path: [:0]const u8) !Conflicts {
        log.debug("Index.conflictGet called, path: {s}", .{path});

        var ancestor_out: *const IndexEntry = undefined;
        var our_out: *const IndexEntry = undefined;
        var their_out: *const IndexEntry = undefined;

        try internal.wrapCall("git_index_conflict_get", .{
            @ptrCast(*?*const c.git_index_entry, &ancestor_out),
            @ptrCast(*?*const c.git_index_entry, &our_out),
            @ptrCast(*?*const c.git_index_entry, &their_out),
            @ptrCast(*c.git_index, index),
            path.ptr,
        });

        log.debug("successfully fetched conflict entries", .{});

        return Conflicts{
            .ancestor = ancestor_out,
            .our = our_out,
            .their = their_out,
        };
    }

    pub fn conlfictRemove(self: *Index, path: [:0]const u8) !void {
        log.debug("Index.conlfictRemove called, path: {s}", .{path});

        try internal.wrapCall("git_index_conflict_remove", .{ @ptrCast(*c.git_index, self), path.ptr });

        log.debug("successfully removed conflict", .{});
    }

    /// Remove all conflicts in the index
    pub fn conflictCleanup(self: *Index) !void {
        log.debug("Index.conflictCleanup called", .{});

        try internal.wrapCall("git_index_conflict_cleanup", .{@ptrCast(*c.git_index, self)});

        log.debug("successfully cleaned up all conflicts", .{});
    }

    pub fn hasConflicts(self: *const Index) bool {
        log.debug("Index.hasConflicts called", .{});

        const ret = c.git_index_has_conflicts(@ptrCast(*const c.git_index, self)) == 1;

        log.debug("index had conflicts: {}", .{ret});

        return ret;
    }

    pub const IndexConflictIterator = opaque {
        pub fn next(self: *IndexConflictIterator) !?Conflicts {
            log.debug("IndexConflictIterator.next called", .{});

            var ancestor_out: *const IndexEntry = undefined;
            var our_out: *const IndexEntry = undefined;
            var their_out: *const IndexEntry = undefined;

            internal.wrapCall("git_index_conflict_next", .{
                @ptrCast(*?*const c.git_index_entry, &ancestor_out),
                @ptrCast(*?*const c.git_index_entry, &our_out),
                @ptrCast(*?*const c.git_index_entry, &their_out),
                @ptrCast(*c.git_index_conflict_iterator, self),
            }) catch |err| switch (err) {
                git.GitError.IterOver => {
                    log.debug("end of iteration reached", .{});
                    return null;
                },
                else => return err,
            };

            log.debug("successfully fetched conflicts", .{});

            return Conflicts{
                .ancestor = ancestor_out,
                .our = our_out,
                .their = their_out,
            };
        }

        pub fn deinit(self: *IndexConflictIterator) void {
            log.debug("IndexConflictIterator.deinit called", .{});

            c.git_index_conflict_iterator_free(@ptrCast(*c.git_index_conflict_iterator, self));

            log.debug("index conflict iterator freed successfully", .{});
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    pub const Conflicts = struct {
        ancestor: *const IndexEntry,
        our: *const IndexEntry,
        their: *const IndexEntry,
    };

    pub const IndexEntry = extern struct {
        ctime: IndexTime,
        mtime: IndexTime,
        dev: u32,
        ino: u32,
        mode: u32,
        uid: u32,
        gid: u32,
        file_size: u32,
        id: git.Oid,
        flags: Flags,
        flags_extended: ExtendedFlags,
        raw_path: [*:0]const u8,

        pub fn path(self: IndexEntry) [:0]const u8 {
            return std.mem.sliceTo(self.raw_path, 0);
        }

        pub fn stage(self: IndexEntry) c_int {
            return @intCast(c_int, self.flags.stage.read());
        }

        pub fn isConflict(self: IndexEntry) bool {
            return self.stage() > 0;
        }

        pub const IndexTime = extern struct {
            seconds: i32,
            nanoseconds: u32,

            test {
                try std.testing.expectEqual(@sizeOf(c.git_index_time), @sizeOf(IndexTime));
                try std.testing.expectEqual(@bitSizeOf(c.git_index_time), @bitSizeOf(IndexTime));
            }

            comptime {
                std.testing.refAllDecls(@This());
            }
        };

        pub const Flags = extern union {
            name: bitjuggle.Bitfield(u16, 0, 12),
            stage: bitjuggle.Bitfield(u16, 12, 2),
            extended: bitjuggle.Bit(u16, 14),
            valid: bitjuggle.Bit(u16, 15),

            test {
                try std.testing.expectEqual(@sizeOf(u16), @sizeOf(Flags));
                try std.testing.expectEqual(@bitSizeOf(u16), @bitSizeOf(Flags));
            }
        };

        pub const ExtendedFlags = extern union {
            intent_to_add: bitjuggle.Bit(u16, 13),
            skip_worktree: bitjuggle.Bit(u16, 14),
            uptodate: bitjuggle.Bit(u16, 2),

            test {
                try std.testing.expectEqual(@sizeOf(u16), @sizeOf(ExtendedFlags));
                try std.testing.expectEqual(@bitSizeOf(u16), @bitSizeOf(ExtendedFlags));
            }
        };

        test {
            try std.testing.expectEqual(@sizeOf(c.git_index_entry), @sizeOf(IndexEntry));
            try std.testing.expectEqual(@bitSizeOf(c.git_index_entry), @bitSizeOf(IndexEntry));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Match a pathspec against entries in an index.
    ///
    /// This matches the pathspec against the files in the repository index.
    ///
    /// NOTE: At the moment, the case sensitivity of this match is controlled by the current case-sensitivity of the index object
    /// itself and the `MatchOptions.USE_CASE` and `MatchOptions.IGNORE_CASE` options will have no effect.
    /// This behavior will be corrected in a future release.
    ///
    /// If `match_list` is not `null`, this returns a `git.PathspecMatchList`. That contains the list of all matched filenames
    /// (unless you pass the `MatchOptions.FAILURES_ONLY` options) and may also contain the list of pathspecs with no match (if
    /// you used the `MatchOptions.FIND_FAILURES` option).
    /// You must call `PathspecMatchList.deinit()` on this object.
    ///
    /// ## Parameters
    /// * `pathspec` - pathspec to be matched
    /// * `options` - options to control match
    /// * `match_list` - output list of matches; pass `null` to just get return value
    pub fn pathspecMatch(
        self: *Index,
        pathspec: *git.Pathspec,
        options: git.Pathspec.MatchOptions,
        match_list: ?**git.PathspecMatchList,
    ) !bool {
        log.debug("Index.pathspecMatch called, options: {}, pathspec: {*}", .{ options, pathspec });

        const ret = (try internal.wrapCallWithReturn("git_pathspec_match_index", .{
            @ptrCast(?*?*c.git_pathspec_match_list, match_list),
            @ptrCast(*c.git_index, self),
            @bitCast(c.git_pathspec_flag_t, options),
            @ptrCast(*c.git_pathspec, pathspec),
        })) != 0;

        log.debug("match: {}", .{ret});

        return ret;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
