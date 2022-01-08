const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Tree = opaque {
    pub fn deinit(self: *Tree) void {
        log.debug("Tree.deinit called", .{});

        c.git_tree_free(@ptrCast(*c.git_tree, self));

        log.debug("tree freed successfully", .{});
    }

    /// Get the id of a tree.
    pub fn getId(self: *const Tree) *const git.Oid {
        log.debug("Tree.id called", .{});

        const ret = @ptrCast(
            *const git.Oid,
            c.git_tree_id(@ptrCast(*const c.git_tree, self)),
        );

        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            if (ret.formatHex(&buf)) |slice| {
                log.debug("tree id: {s}", .{slice});
            } else |_| {}
        }

        return ret;
    }

    /// Get the repository that contains the tree.
    pub fn owner(self: *const Tree) *git.Repository {
        log.debug("Tree.owner called", .{});

        const ret = @ptrCast(
            *git.Repository,
            c.git_tree_owner(@ptrCast(*const c.git_tree, self)),
        );

        log.debug("tree owner: {*}", .{ret});

        return ret;
    }

    /// Get the number of entries listed in a tree
    pub fn entryCount(self: *const Tree) usize {
        log.debug("Tree.entryCount called", .{});

        const ret = c.git_tree_entrycount(@ptrCast(*const c.git_tree, self));

        log.debug("tree entry count: {}", .{ret});

        return ret;
    }

    /// Lookup a tree entry by its filename
    ///
    /// This returns a `git.Tree.Entry` that is owned by the `git.Tree`.  
    /// You don't have to free it, but you must not use it after the `git.Tree` is `deinit`ed.
    pub fn entryByName(self: *const Tree, name: [:0]const u8) ?*const Tree.Entry {
        log.debug("Tree.entryByName called, name={s}", .{name});

        const opt_ret = @ptrCast(?*const Tree.Entry, c.git_tree_entry_byname(
            @ptrCast(*const c.git_tree, self),
            name.ptr,
        ));

        if (opt_ret) |ret| {
            log.debug("found entry: {*}", .{ret});
        } else {
            log.debug("could not find entry", .{});
        }

        return opt_ret;
    }

    /// Lookup a tree entry by its position in the tree
    ///
    /// This returns a `git.Tree.Entry` that is owned by the `git.Tree`.  
    /// You don't have to free it, but you must not use it after the `git.Tree` is `deinit`ed.
    pub fn entryByIndex(self: *const Tree, index: usize) ?*const Tree.Entry {
        log.debug("Tree.entryByIndex called, index={}", .{index});

        const opt_ret = @ptrCast(?*const Tree.Entry, c.git_tree_entry_byindex(
            @ptrCast(*const c.git_tree, self),
            index,
        ));

        if (opt_ret) |ret| {
            log.debug("found entry: {*}", .{ret});
        } else {
            log.debug("could not find entry", .{});
        }

        return opt_ret;
    }

    /// Duplicate a tree
    ///
    /// The returned tree is owned by the user and must be freed explicitly with `Tree.deinit`.
    pub fn duplicate(self: *Tree) !*Tree {
        log.debug("Tree.duplicate called", .{});

        var ret: *Tree = undefined;

        try internal.wrapCall("git_tree_dup", .{
            @ptrCast(*?*c.git_tree, &ret),
            @ptrCast(*c.git_tree, self),
        });

        log.debug("successfully duplicated tree", .{});

        return ret;
    }

    ///  * Lookup a tree entry by SHA value.
    ///
    /// This returns a `git.Tree.Entry` that is owned by the `git.Tree`.  
    /// You don't have to free it, but you must not use it after the `git.Tree` is `deinit`ed.
    ///
    /// Warning: this must examine every entry in the tree, so it is not fast.
    pub fn entryById(self: *const Tree, id: *const git.Oid) ?*const Tree.Entry {
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            if (id.formatHex(&buf)) |slice| {
                log.debug("Tree.entryById called, id={s}", .{slice});
            } else |_| {}
        }

        const opt_ret = @ptrCast(?*const Tree.Entry, c.git_tree_entry_byid(
            @ptrCast(*const c.git_tree, self),
            @ptrCast(*const c.git_oid, id),
        ));

        if (opt_ret) |ret| {
            log.debug("found entry: {*}", .{ret});
        } else {
            log.debug("could not find entry", .{});
        }

        return opt_ret;
    }

    /// Retrieve a tree entry contained in a tree or in any of its subtrees, given its relative path.
    ///
    /// Unlike the other lookup functions, the returned tree entry is owned by the user and must be freed explicitly with 
    /// `Entry.deinit`.
    pub fn entryByPath(root: *const Tree, path: [:0]const u8) !*Tree.Entry {
        log.debug("Tree.entryByPath called, path={s}", .{path});

        var ret: *Entry = undefined;

        try internal.wrapCall("git_tree_entry_bypath", .{
            @ptrCast(*?*c.git_tree_entry, &ret),
            @ptrCast(*const c.git_tree, root),
            path.ptr,
        });

        log.debug("found entry: {*}", .{ret});

        return ret;
    }

    /// Tree traversal modes
    pub const WalkMode = enum(c_uint) {
        pre = 0,
        post = 1,
    };

    /// Traverse the entries in a tree and its subtrees in post or pre order.
    ///
    /// The entries will be traversed in the specified order, children subtrees will be automatically loaded as required,
    /// and the `callback` will be called once per entry with the current (relative) root for the entry and the entry data itself.
    ///
    /// If the callback returns a positive value, the passed entry will be skipped on the traversal (in pre mode).
    /// A negative value stops the walk.
    ///
    /// ## Parameters
    /// * `mode` - Traversal mode (pre or post-order)
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `root` - The current (relative) root
    /// * `entry` - The entry
    /// * `user_data_ptr` - pointer to user data
    pub fn walk(
        self: *const Tree,
        mode: WalkMode,
        comptime callback_fn: fn (
            root: [:0]const u8,
            entry: *const Tree.Entry,
        ) c_int,
    ) !void {
        const cb = struct {
            pub fn cb(
                root: [:0]const u8,
                entry: *const Tree.Entry,
                _: *u8,
            ) bool {
                return callback_fn(root, entry);
            }
        }.cb;

        var dummy_data: u8 = undefined;
        return self.walkWithUserData(&dummy_data, mode, cb);
    }

    /// Traverse the entries in a tree and its subtrees in post or pre order.
    ///
    /// The entries will be traversed in the specified order, children subtrees will be automatically loaded as required,
    /// and the `callback` will be called once per entry with the current (relative) root for the entry and the entry data itself.
    ///
    /// If the callback returns a positive value, the passed entry will be skipped on the traversal (in pre mode).
    /// A negative value stops the walk.
    ///
    /// ## Parameters
    /// * `mode` - Traversal mode (pre or post-order)
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `root` - The current (relative) root
    /// * `entry` - The entry
    /// * `user_data_ptr` - pointer to user data
    pub fn walkWithUserData(
        self: *const Tree,
        mode: WalkMode,
        user_data: anytype,
        comptime callback_fn: fn (
            root: [:0]const u8,
            entry: *const Tree.Entry,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !void {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(
                root: [*:0]const u8,
                entry: *const c.git_tree_entry,
                payload: ?*anyopaque,
            ) callconv(.C) c_int {
                return callback_fn(
                    std.mem.sliceTo(root, 0),
                    @ptrCast(*const Tree.Entry, entry),
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("Tree.walkWithUserData called, mode={}", .{mode});

        _ = try internal.wrapCallWithReturn("git_tree_walk", .{
            @ptrCast(*c.git_tree, self),
            @enumToInt(mode),
            cb,
            user_data,
        });
    }

    pub const Entry = opaque {
        pub fn deinit(self: *Entry) void {
            log.debug("Entry.deinit called", .{});

            c.git_tree_entry_free(@ptrCast(*c.git_tree_entry, self));

            log.debug("tree entry freed successfully", .{});
        }

        /// Get the filename of a tree entry
        pub fn filename(self: *const Entry) [:0]const u8 {
            log.debug("Entry.filename called", .{});

            const ret = c.git_tree_entry_name(@ptrCast(*const c.git_tree_entry, self));

            const slice = std.mem.sliceTo(ret, 0);

            log.debug("entry filename: {s}", .{slice});

            return slice;
        }

        /// Get the id of the object pointed by the entry
        pub fn getId(self: *const Entry) *const git.Oid {
            log.debug("Entry.getId called", .{});

            const ret = @ptrCast(
                *const git.Oid,
                c.git_tree_entry_id(@ptrCast(*const c.git_tree_entry, self)),
            );

            if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
                var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
                if (ret.formatHex(&buf)) |slice| {
                    log.debug("entry id: {s}", .{slice});
                } else |_| {}
            }

            return ret;
        }

        /// Get the type of the object pointed by the entry
        pub fn getType(self: *const Entry) git.ObjectType {
            log.debug("Entry.getType called", .{});

            const ret = @intToEnum(git.ObjectType, c.git_tree_entry_type(@ptrCast(*const c.git_tree_entry, self)));

            log.debug("entry type: {}", .{ret});

            return ret;
        }

        /// Get the UNIX file attributes of a tree entry
        pub fn filemode(self: *const Entry) git.FileMode {
            log.debug("Entry.filemode called", .{});

            const ret = @intToEnum(git.FileMode, c.git_tree_entry_filemode(@ptrCast(*const c.git_tree_entry, self)));

            log.debug("entry file mode: {}", .{ret});

            return ret;
        }

        /// Get the raw UNIX file attributes of a tree entry
        ///
        /// This function does not perform any normalization and is only useful if you need to be able to recreate the
        /// original tree object.
        pub fn filemodeRaw(self: *const Entry) c_uint {
            log.debug("Entry.filemodeRaw called", .{});

            const ret = c.git_tree_entry_filemode_raw(@ptrCast(*const c.git_tree_entry, self));

            log.debug("entry raw file mode: {}", .{ret});

            return ret;
        }

        /// Compare two tree entries
        ///
        /// Returns <0 if `self` is before `other`, 0 if `self` == `other`, >0 if `self` is after `other`
        pub fn compare(self: *const Entry, other: *const Entry) c_int {
            log.debug("Entry.compare called", .{});

            const ret = c.git_tree_entry_cmp(
                @ptrCast(*const c.git_tree_entry, self),
                @ptrCast(*const c.git_tree_entry, other),
            );

            log.debug("compare result: {}", .{ret});

            return ret;
        }

        /// Duplicate a tree entry
        ///
        /// The returned tree entry is owned by the user and must be freed explicitly with `Entry.deinit`.
        pub fn duplicate(self: *Entry) !*Entry {
            log.debug("Tree.duplicate called", .{});

            var ret: *Entry = undefined;

            try internal.wrapCall("git_tree_entry_dup", .{
                @ptrCast(*?*c.git_tree_entry, &ret),
                @ptrCast(*c.git_tree_entry, self),
            });

            log.debug("successfully duplicated tree entry", .{});

            return ret;
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const TreeBuilder = opaque {
    /// Free a tree builder
    ///
    /// This will clear all the entries and free to builder.
    /// Failing to free the builder after you're done using it will result in a memory leak
    pub fn deinit(self: *TreeBuilder) void {
        log.debug("TreeBuilder.deinit called", .{});

        c.git_treebuilder_free(@ptrCast(*c.git_treebuilder, self));

        log.debug("treebuilder freed successfully", .{});
    }

    /// Clear all the entires in the builder
    pub fn clear(self: *TreeBuilder) !void {
        log.debug("Tree.clear called", .{});

        try internal.wrapCall("git_treebuilder_clear", .{
            @ptrCast(*c.git_treebuilder, self),
        });

        log.debug("successfully cleared treebuilder", .{});
    }

    /// Get the number of entries listed in a treebuilder
    pub fn entryCount(self: *TreeBuilder) usize {
        log.debug("TreeBuilder.entryCount called", .{});

        const ret = c.git_treebuilder_entrycount(@ptrCast(*c.git_treebuilder, self));

        log.debug("treebuilder entry count: {}", .{ret});

        return ret;
    }

    /// Get an entry from the builder from its filename
    ///
    /// The returned entry is owned by the builder and should not be freed manually.
    pub fn get(self: *TreeBuilder, filename: [:0]const u8) ?*const git.Tree.Entry {
        log.debug("TreeBuilder.get called, filename={s}", .{filename});

        const opt_ret = @ptrCast(
            ?*const git.Tree.Entry,
            c.git_treebuilder_get(
                @ptrCast(*c.git_treebuilder, self),
                filename.ptr,
            ),
        );

        if (opt_ret) |ret| {
            log.debug("found entry: {*}", .{ret});
        } else {
            log.debug("could not find entry", .{});
        }

        return opt_ret;
    }

    /// Add or update an entry to the builder
    ///
    /// Insert a new entry for `filename` in the builder with the given attributes.
    ///
    /// If an entry named `filename` already exists, its attributes will be updated with the given ones.
    ///
    /// The returned pointer may not be valid past the next operation in this builder. Duplicate the entry if you want to keep it.
    ///
    /// By default the entry that you are inserting will be checked for validity; that it exists in the object database and
    /// is of the correct type. If you do not want this behavior, set `Handle.optionSetStrictObjectCreation` to false.
    pub fn insert(self: *TreeBuilder, filename: [:0]const u8, id: *const git.Oid, filemode: git.FileMode) !*const Tree.Entry {
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            if (id.formatHex(&buf)) |slice| {
                log.debug("TreeBuilder.insert called, filename={s}, id={s}, filemode={}", .{ filename, slice, filemode });
            } else |_| {}
        }

        var ret: *const Tree.Entry = undefined;

        try internal.wrapCall("git_treebuilder_insert", .{
            @ptrCast(*?*const c.git_tree_entry, &ret),
            @ptrCast(*c.git_treebuilder, self),
            filename.ptr,
            @ptrCast(*const c.git_oid, id),
            @enumToInt(filemode),
        });

        log.debug("inserted entry: {*}", .{ret});

        return ret;
    }

    /// Remove an entry from the builder by its filename
    pub fn remove(self: *TreeBuilder, filename: [:0]const u8) !void {
        log.debug("TreeBuilder.remove called, filename={s}", .{filename});

        try internal.wrapCall("git_treebuilder_remove", .{
            @ptrCast(*c.git_treebuilder, self),
            filename.ptr,
        });

        log.debug("successfully removed entry", .{});
    }

    /// Invoke `callback_fn` to selectively remove entries in the tree
    ///
    /// The `filter` callback will be called for each entry in the tree with a pointer to the entry;
    /// if the callback returns `true`, the entry will be filtered (removed from the builder).
    ///
    /// ## Parameters
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `entry` - The entry
    pub fn filter(
        self: *TreeBuilder,
        comptime callback_fn: fn (entry: *const Tree.Entry) bool,
    ) !void {
        const cb = struct {
            pub fn cb(
                entry: *const Tree.Entry,
                _: *u8,
            ) bool {
                return callback_fn(entry);
            }
        }.cb;

        var dummy_data: u8 = undefined;
        return self.filterWithUserData(&dummy_data, cb);
    }

    /// Invoke `callback_fn` to selectively remove entries in the tree
    ///
    /// The `filter` callback will be called for each entry in the tree with a pointer to the entry and the provided `payload`;
    /// if the callback returns `true`, the entry will be filtered (removed from the builder).
    ///
    /// ## Parameters
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `entry` - The entry
    /// * `user_data_ptr` - pointer to user data
    pub fn filterWithUserData(
        self: *TreeBuilder,
        user_data: anytype,
        comptime callback_fn: fn (
            entry: *const Tree.Entry,
            user_data_ptr: @TypeOf(user_data),
        ) bool,
    ) !void {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(
                entry: *const c.git_tree_entry,
                payload: ?*anyopaque,
            ) callconv(.C) c_int {
                return callback_fn(
                    @ptrCast(*const Tree.Entry, entry),
                    @ptrCast(UserDataType, payload),
                ) != 0;
            }
        }.cb;

        log.debug("Repository.filterWithUserData called", .{});

        _ = try internal.wrapCallWithReturn("git_treebuilder_filter", .{
            @ptrCast(*c.git_treebuilder, self),
            cb,
            user_data,
        });
    }

    /// Write the contents of the tree builder as a tree object
    ///
    /// The tree builder will be written to the given `repo`, and its identifying SHA1 hash will be returned.
    pub fn write(self: *TreeBuilder) !git.Oid {
        log.debug("TreeBuilder.write called", .{});

        var ret: git.Oid = undefined;

        try internal.wrapCall("git_treebuilder_write", .{
            @ptrCast(*c.git_oid, &ret),
            @ptrCast(*c.git_treebuilder, self),
        });

        log.debug("successfully written treebuilder", .{});

        return ret;
    }

    /// Match a pathspec against files in a tree.
    ///
    /// This matches the pathspec against the files in the given tree.
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
        self: *Tree,
        pathspec: *git.Pathspec,
        options: git.Pathspec.MatchOptions,
        match_list: ?**git.PathspecMatchList,
    ) !bool {
        log.debug("Tree.pathspecMatch called, options={}, pathspec={*}", .{ options, pathspec });

        const ret = (try internal.wrapCallWithReturn("git_pathspec_match_tree", .{
            @ptrCast(?*?*c.git_pathspec_match_list, match_list),
            @ptrCast(*c.git_tree, self),
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
