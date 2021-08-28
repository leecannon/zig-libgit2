const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Repository = opaque {
    pub fn deinit(self: *Repository) void {
        log.debug("Repository.deinit called", .{});

        raw.git_repository_free(internal.toC(self));

        log.debug("repository closed successfully", .{});
    }

    pub fn getState(self: *const Repository) RepositoryState {
        log.debug("Repository.getState called", .{});

        const ret = @intToEnum(RepositoryState, raw.git_repository_state(internal.toC(self)));

        log.debug("repository state: {s}", .{@tagName(ret)});

        return ret;
    }

    pub const RepositoryState = enum(c_int) {
        NONE,
        MERGE,
        REVERT,
        REVERT_SEQUENCE,
        CHERRYPICK,
        CHERRYPICK_SEQUENCE,
        BISECT,
        REBASE,
        REBASE_INTERACTIVE,
        REBASE_MERGE,
        APPLY_MAILBOX,
        APPLY_MAILBOX_OR_REBASE,
    };

    /// Retrieve the configured identity to use for reflogs
    pub fn getIdentity(self: *const Repository) !Identity {
        log.debug("Repository.getIdentity called", .{});

        var c_name: [*c]u8 = undefined;
        var c_email: [*c]u8 = undefined;

        try internal.wrapCall("git_repository_ident", .{ &c_name, &c_email, internal.toC(self) });

        const name: ?[:0]const u8 = if (c_name) |ptr| std.mem.sliceTo(ptr, 0) else null;
        const email: ?[:0]const u8 = if (c_email) |ptr| std.mem.sliceTo(ptr, 0) else null;

        log.debug("identity acquired: name={s}, email={s}", .{ name, email });

        return Identity{ .name = name, .email = email };
    }

    /// Set the identity to be used for writing reflogs
    ///
    /// If both are set, this name and email will be used to write to the reflog.
    /// Set to `null` to unset; When unset, the identity will be taken from the repository's configuration.
    pub fn setIdentity(self: *const Repository, identity: Identity) !void {
        log.debug("Repository.setIdentity called, identity.name={s}, identity.email={s}", .{ identity.name, identity.email });

        const name_temp: [*c]const u8 = if (identity.name) |slice| slice.ptr else null;
        const email_temp: [*c]const u8 = if (identity.email) |slice| slice.ptr else null;
        try internal.wrapCall("git_repository_set_ident", .{ internal.toC(self), name_temp, email_temp });

        log.debug("successfully set identity", .{});
    }

    pub const Identity = struct {
        name: ?[:0]const u8,
        email: ?[:0]const u8,
    };

    pub fn getNamespace(self: *const Repository) !?[:0]const u8 {
        log.debug("Repository.getNamespace called", .{});

        const ret = raw.git_repository_get_namespace(internal.toC(self));

        if (ret) |ptr| {
            const slice = std.mem.sliceTo(ptr, 0);
            log.debug("namespace: {s}", .{slice});
            return slice;
        }

        log.debug("no namespace", .{});

        return null;
    }

    /// Sets the active namespace for this Git Repository
    ///
    /// This namespace affects all reference operations for the repo. See `man gitnamespaces`
    ///
    /// ## Parameters
    /// * `namespace` - The namespace. This should not include the refs folder, e.g. to namespace all references under 
    ///                 "refs/namespaces/foo/", use "foo" as the namespace.
    pub fn setNamespace(self: *Repository, namespace: [:0]const u8) !void {
        log.debug("Repository.setNamespace called, namespace={s}", .{namespace});

        try internal.wrapCall("git_repository_set_namespace", .{ internal.toC(self), namespace.ptr });

        log.debug("successfully set namespace", .{});
    }

    pub fn isHeadDetached(self: *const Repository) !bool {
        log.debug("Repository.isHeadDetached called", .{});

        const ret = (try internal.wrapCallWithReturn("git_repository_head_detached", .{internal.toC(self)})) == 1;

        log.debug("is head detached: {}", .{ret});

        return ret;
    }

    pub fn getHead(self: *const Repository) !*git.Reference {
        log.debug("Repository.head called", .{});

        var ref: ?*raw.git_reference = undefined;

        try internal.wrapCall("git_repository_head", .{ &ref, internal.toC(self) });

        log.debug("reference opened successfully", .{});

        return internal.fromC(ref.?);
    }

    /// Make the repository HEAD point to the specified reference.
    ///
    /// If the provided reference points to a Tree or a Blob, the HEAD is unaltered and an error is returned.
    ///
    /// If the provided reference points to a branch, the HEAD will point to that branch, staying attached, or become attached if
    /// it isn't yet. If the branch doesn't exist yet, the HEAD will be attached to an unborn branch.
    ///
    /// Otherwise, the HEAD will be detached and will directly point to the commit.
    ///
    /// ## Parameters
    /// * `ref_name` - Canonical name of the reference the HEAD should point at
    pub fn setHead(self: *Repository, ref_name: [:0]const u8) !void {
        log.debug("Repository.setHead called, workdir={s}", .{ref_name});

        try internal.wrapCall("git_repository_set_head", .{ internal.toC(self), ref_name.ptr });

        log.debug("successfully set head", .{});
    }

    /// Make the repository HEAD directly point to a commit.
    ///
    /// If the provided commit cannot be found in the repository `GitError.NotFound` is returned.
    /// If the provided commit cannot be peeled into a commit, the HEAD is unaltered and an error is returned.
    /// Otherwise, the HEAD will eventually be detached and will directly point to the peeled commit.
    ///
    /// ## Parameters
    /// * `commit` - Object id of the commit the HEAD should point to
    pub fn setHeadDetached(self: *Repository, commit: git.Oid) !void {
        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const slice = try commit.formatHex(&buf);
            log.debug("Repository.setHeadDetached called, commit={s}", .{slice});
        }

        try internal.wrapCall("git_repository_set_head_detached", .{ internal.toC(self), internal.toC(&commit) });

        log.debug("successfully set head", .{});
    }

    /// Make the repository HEAD directly point to the commit.
    ///
    /// This behaves like `Repository.setHeadDetached` but takes an annotated commit, which lets you specify which 
    /// extended sha syntax string was specified by a user, allowing for more exact reflog messages.
    ///
    /// See the documentation for `Repository.setHeadDetached`.
    pub fn setHeadDetachedFromAnnotated(self: *Repository, commitish: *const git.AnnotatedCommit) !void {
        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const oid = try commitish.getCommitId();
            const slice = try oid.formatHex(&buf);
            log.debug("Repository.setHeadDetachedFromAnnotated called, commitish={s}", .{slice});
        }

        try internal.wrapCall("git_repository_set_head_detached_from_annotated", .{ internal.toC(self), internal.toC(commitish) });

        log.debug("successfully set head", .{});
    }

    /// Detach the HEAD.
    ///
    /// If the HEAD is already detached and points to a Tag, the HEAD is updated into making it point to the peeled commit.
    /// If the HEAD is already detached and points to a non commitish, the HEAD is unaltered, and an error is returned.
    ///
    /// Otherwise, the HEAD will be detached and point to the peeled commit.
    pub fn detachHead(self: *Repository) !void {
        log.debug("Repository.detachHead called", .{});

        try internal.wrapCall("git_repository_detach_head", .{internal.toC(self)});

        log.debug("successfully detached the head", .{});
    }

    pub fn isHeadForWorktreeDetached(self: *const Repository, name: [:0]const u8) !bool {
        log.debug("Repository.isHeadForWorktreeDetached called, name={s}", .{name});

        const ret = (try internal.wrapCallWithReturn(
            "git_repository_head_detached_for_worktree",
            .{ internal.toC(self), name.ptr },
        )) == 1;

        log.debug("head for worktree {s} is detached: {}", .{ name, ret });

        return ret;
    }

    pub fn headForWorktree(self: *const Repository, name: [:0]const u8) !*git.Reference {
        log.debug("Repository.headForWorktree called, name={s}", .{name});

        var ref: ?*raw.git_reference = undefined;

        try internal.wrapCall("git_repository_head_for_worktree", .{ &ref, internal.toC(self), name.ptr });

        log.debug("reference opened successfully", .{});

        return internal.fromC(ref.?);
    }

    pub fn isHeadUnborn(self: *const Repository) !bool {
        log.debug("Repository.isHeadUnborn called", .{});

        const ret = (try internal.wrapCallWithReturn("git_repository_head_unborn", .{internal.toC(self)})) == 1;

        log.debug("is head unborn: {}", .{ret});

        return ret;
    }

    pub fn isShallow(self: *const Repository) bool {
        log.debug("Repository.isShallow called", .{});

        const ret = raw.git_repository_is_shallow(internal.toC(self)) == 1;

        log.debug("is repository a shallow clone: {}", .{ret});

        return ret;
    }

    pub fn isEmpty(self: *const Repository) !bool {
        log.debug("Repository.isEmpty called", .{});

        const ret = (try internal.wrapCallWithReturn("git_repository_is_empty", .{internal.toC(self)})) == 1;

        log.debug("is repository empty: {}", .{ret});

        return ret;
    }

    pub fn isBare(self: *const Repository) bool {
        log.debug("Repository.isBare called", .{});

        const ret = raw.git_repository_is_bare(internal.toC(self)) == 1;

        log.debug("is repository bare: {}", .{ret});

        return ret;
    }

    pub fn isWorktree(self: *const Repository) bool {
        log.debug("Repository.isWorktree called", .{});

        const ret = raw.git_repository_is_worktree(internal.toC(self)) == 1;

        log.debug("is repository worktree: {}", .{ret});

        return ret;
    }

    /// Get the location of a specific repository file or directory
    pub fn getItemPath(self: *const Repository, item: RepositoryItem) !git.Buf {
        log.debug("Repository.itemPath called, item={s}", .{item});

        var buf = git.Buf{};

        try internal.wrapCall("git_repository_item_path", .{ internal.toC(&buf), internal.toC(self), @enumToInt(item) });

        log.debug("item path: {s}", .{buf.toSlice()});

        return buf;
    }

    pub const RepositoryItem = enum(c_uint) {
        GITDIR,
        WORKDIR,
        COMMONDIR,
        INDEX,
        OBJECTS,
        REFS,
        PACKED_REFS,
        REMOTES,
        CONFIG,
        INFO,
        HOOKS,
        LOGS,
        MODULES,
        WORKTREES,
    };

    pub fn getPath(self: *const Repository) [:0]const u8 {
        log.debug("Repository.path called", .{});

        const slice = std.mem.sliceTo(raw.git_repository_path(internal.toC(self)), 0);

        log.debug("path: {s}", .{slice});

        return slice;
    }

    pub fn getWorkdir(self: *const Repository) ?[:0]const u8 {
        log.debug("Repository.workdir called", .{});

        if (raw.git_repository_workdir(internal.toC(self))) |ret| {
            const slice = std.mem.sliceTo(ret, 0);

            log.debug("workdir: {s}", .{slice});

            return slice;
        }

        log.debug("no workdir", .{});

        return null;
    }

    pub fn setWorkdir(self: *Repository, workdir: [:0]const u8, update_gitlink: bool) !void {
        log.debug("Repository.setWorkdir called, workdir={s}, update_gitlink={}", .{ workdir, update_gitlink });

        try internal.wrapCall("git_repository_set_workdir", .{ internal.toC(self), workdir.ptr, @boolToInt(update_gitlink) });

        log.debug("successfully set workdir", .{});
    }

    pub fn getCommondir(self: *const Repository) ?[:0]const u8 {
        log.debug("Repository.commondir called", .{});

        if (raw.git_repository_commondir(internal.toC(self))) |ret| {
            const slice = std.mem.sliceTo(ret, 0);

            log.debug("commondir: {s}", .{slice});

            return slice;
        }

        log.debug("no commondir", .{});

        return null;
    }

    /// Get the configuration file for this repository.
    ///
    /// If a configuration file has not been set, the default config set for the repository will be returned, including any global 
    /// and system configurations.
    pub fn getConfig(self: *const Repository) !*git.Config {
        log.debug("Repository.getConfig called", .{});

        var config: ?*raw.git_config = undefined;

        try internal.wrapCall("git_repository_config", .{ &config, internal.toC(self) });

        log.debug("repository config acquired successfully", .{});

        return internal.fromC(config.?);
    }

    /// Get a snapshot of the repository's configuration
    ///
    /// The contents of this snapshot will not change, even if the underlying config files are modified.
    pub fn getConfigSnapshot(self: *const Repository) !*git.Config {
        log.debug("Repository.getConfigSnapshot called", .{});

        var config: ?*raw.git_config = undefined;

        try internal.wrapCall("git_repository_config_snapshot", .{ &config, internal.toC(self) });

        log.debug("repository config acquired successfully", .{});

        return internal.fromC(config.?);
    }

    pub fn getOdb(self: *const Repository) !*git.Odb {
        log.debug("Repository.getOdb called", .{});

        var odb: ?*raw.git_odb = undefined;

        try internal.wrapCall("git_repository_odb", .{ &odb, internal.toC(self) });

        log.debug("repository odb acquired successfully", .{});

        return internal.fromC(odb.?);
    }

    pub fn getRefDb(self: *const Repository) !*git.RefDb {
        log.debug("Repository.getRefDb called", .{});

        var ref_db: ?*raw.git_refdb = undefined;

        try internal.wrapCall("git_repository_refdb", .{ &ref_db, internal.toC(self) });

        log.debug("repository refdb acquired successfully", .{});

        return internal.fromC(ref_db.?);
    }

    pub fn getIndex(self: *const Repository) !*git.Index {
        log.debug("Repository.getIndex called", .{});

        var index: ?*raw.git_index = undefined;

        try internal.wrapCall("git_repository_index", .{ &index, internal.toC(self) });

        log.debug("repository index acquired successfully", .{});

        return internal.fromC(index.?);
    }

    /// Retrieve git's prepared message
    ///
    /// Operations such as git revert/cherry-pick/merge with the -n option stop just short of creating a commit with the changes 
    /// and save their prepared message in .git/MERGE_MSG so the next git-commit execution can present it to the user for them to
    /// amend if they wish.
    ///
    /// Use this function to get the contents of this file. Don't forget to remove the file after you create the commit.
    pub fn getPreparedMessage(self: *const Repository) !git.Buf {
        log.debug("Repository.getPreparedMessage called", .{});

        var buf = git.Buf{};

        try internal.wrapCall("git_repository_message", .{ internal.toC(&buf), internal.toC(self) });

        log.debug("prepared message: {s}", .{buf.toSlice()});

        return buf;
    }

    /// Remove git's prepared message file.
    pub fn removePreparedMessage(self: *Repository) !void {
        log.debug("Repository.removePreparedMessage called", .{});

        try internal.wrapCall("git_repository_message_remove", .{internal.toC(self)});

        log.debug("successfully removed prepared message", .{});
    }

    /// Remove all the metadata associated with an ongoing command like merge, revert, cherry-pick, etc.
    /// For example: MERGE_HEAD, MERGE_MSG, etc.
    pub fn stateCleanup(self: *Repository) !void {
        log.debug("Repository.stateCleanup called", .{});

        try internal.wrapCall("git_repository_state_cleanup", .{internal.toC(self)});

        log.debug("successfully cleaned state", .{});
    }

    /// Invoke `callback_fn` for each entry in the given FETCH_HEAD file.
    ///
    /// Return a non-zero value from the callback to stop the loop. This non-zero value is returned by the function.
    ///
    /// ## Parameters
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `ref_name` - The reference name
    /// * `remote_url` - The remote URL
    /// * `oid` - The reference OID
    /// * `is_merge` - Was the reference the result of a merge
    pub fn foreachFetchHead(
        self: *const Repository,
        comptime callback_fn: fn (
            ref_name: [:0]const u8,
            remote_url: [:0]const u8,
            oid: *const git.Oid,
            is_merge: bool,
        ) c_int,
    ) !c_int {
        const cb = struct {
            pub fn cb(
                ref_name: [:0]const u8,
                remote_url: [:0]const u8,
                oid: *const git.Oid,
                is_merge: bool,
                _: *u8,
            ) c_int {
                return callback_fn(ref_name, remote_url, oid, is_merge);
            }
        }.cb;

        var dummy_data: u8 = undefined;
        return self.foreachFetchHeadWithUserData(&dummy_data, cb);
    }

    /// Invoke `callback_fn` for each entry in the given FETCH_HEAD file.
    ///
    /// Return a non-zero value from the callback to stop the loop. This non-zero value is returned by the function.
    ///
    /// ## Parameters
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `ref_name` - The reference name
    /// * `remote_url` - The remote URL
    /// * `oid` - The reference OID
    /// * `is_merge` - Was the reference the result of a merge
    /// * `user_data_ptr` - pointer to user data
    pub fn foreachFetchHeadWithUserData(
        self: *const Repository,
        user_data: anytype,
        comptime callback_fn: fn (
            ref_name: [:0]const u8,
            remote_url: [:0]const u8,
            oid: *const git.Oid,
            is_merge: bool,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !c_int {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(
                c_ref_name: [*c]const u8,
                c_remote_url: [*c]const u8,
                c_oid: [*c]const raw.git_oid,
                c_is_merge: c_uint,
                payload: ?*c_void,
            ) callconv(.C) c_int {
                return callback_fn(
                    std.mem.sliceTo(c_ref_name, 0),
                    std.mem.sliceTo(c_remote_url, 0),
                    internal.fromC(c_oid.?),
                    c_is_merge == 1,
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("Repository.foreachFetchHeadWithUserData called", .{});

        const ret = try internal.wrapCallWithReturn("git_repository_fetchhead_foreach", .{ internal.toC(self), cb, user_data });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    /// If a merge is in progress, invoke 'callback' for each commit ID in the MERGE_HEAD file.
    ///
    /// Return a non-zero value from the callback to stop the loop. This non-zero value is returned by the function.
    ///
    /// ## Parameters
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `oid` - The merge OID
    pub fn foreachMergeHead(
        self: *const Repository,
        comptime callback_fn: fn (oid: *const git.Oid) c_int,
    ) !c_int {
        const cb = struct {
            pub fn cb(oid: *const git.Oid, _: *u8) c_int {
                return callback_fn(oid);
            }
        }.cb;

        var dummy_data: u8 = undefined;
        return self.foreachMergeHeadWithUserData(&dummy_data, cb);
    }

    /// If a merge is in progress, invoke 'callback' for each commit ID in the MERGE_HEAD file.
    ///
    /// Return a non-zero value from the callback to stop the loop. This non-zero value is returned by the function.
    ///
    /// ## Parameters
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `oid` - The merge OID
    /// * `user_data_ptr` - pointer to user data
    pub fn foreachMergeHeadWithUserData(
        self: *const Repository,
        user_data: anytype,
        comptime callback_fn: fn (
            oid: *const git.Oid,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !c_int {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(c_oid: [*c]const raw.git_oid, payload: ?*c_void) callconv(.C) c_int {
                return callback_fn(internal.fromC(c_oid.?), @ptrCast(UserDataType, payload));
            }
        }.cb;

        log.debug("Repository.foreachMergeHeadWithUserData called", .{});

        const ret = try internal.wrapCallWithReturn("git_repository_mergehead_foreach", .{ internal.toC(self), cb, user_data });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    /// Calculate hash of file using repository filtering rules.
    ///
    /// If you simply want to calculate the hash of a file on disk with no filters, you can just use `git.Odb.hashFile`.
    /// However, if you want to hash a file in the repository and you want to apply filtering rules (e.g. crlf filters) before
    /// generating the SHA, then use this function.
    ///
    /// Note: if the repository has `core.safecrlf` set to fail and the filtering triggers that failure, then this function will
    /// return an error and not calculate the hash of the file.
    ///
    /// ## Parameters
    /// * `path` - Path to file on disk whose contents should be hashed. This can be a relative path.
    /// * `object_type` - The object type to hash as (e.g. `ObjectType.BLOB`)
    /// * `as_path` - The path to use to look up filtering rules. If this is `null`, then the `path` parameter will be used
    ///               instead. If this is passed as the empty string, then no filters will be applied when calculating the hash.
    pub fn hashFile(
        self: *const Repository,
        path: [:0]const u8,
        object_type: git.ObjectType,
        as_path: ?[:0]const u8,
    ) !*const git.Oid {
        log.debug("Repository.hashFile called, path={s}, object_type={}, as_path={s}", .{ path, object_type, as_path });

        var oid: ?*raw.git_oid = undefined;

        const as_path_temp: [*c]const u8 = if (as_path) |slice| slice.ptr else null;
        try internal.wrapCall("git_repository_hashfile", .{ oid, internal.toC(self), path.ptr, @enumToInt(object_type), as_path_temp });

        const ret = internal.fromC(oid.?);

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const slice = try ret.formatHex(&buf);
            log.debug("file hash acquired successfully, hash={s}", .{slice});
        }

        return ret;
    }

    /// Get file status for a single file.
    ///
    /// This tries to get status for the filename that you give. If no files match that name (in either the HEAD, index, or
    /// working directory), this returns `GitError.NotFound`.
    ///
    /// If the name matches multiple files (for example, if the `path` names a directory or if running on a case- insensitive
    /// filesystem and yet the HEAD has two entries that both match the path), then this returns `GitError.Ambiguous`.
    ///
    /// This does not do any sort of rename detection.
    pub fn fileStatus(self: *const Repository, path: [:0]const u8) !git.FileStatus {
        log.debug("Repository.fileStatus called, path={s}", .{path});

        var flags: c_uint = undefined;

        try internal.wrapCall("git_status_file", .{ &flags, internal.toC(self), path.ptr });

        const ret = @bitCast(git.FileStatus, flags);

        log.debug("file status: {}", .{ret});

        return ret;
    }

    /// Gather file statuses and run a callback for each one.
    ///
    /// Return a non-zero value from the callback to stop the loop. This non-zero value is returned by the function.
    ///
    /// ## Parameters
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `path` - The file path
    /// * `status` - The status of the file
    pub fn foreachFileStatus(
        self: *const Repository,
        comptime callback_fn: fn (path: [:0]const u8, status: git.FileStatus) c_int,
    ) !c_int {
        const cb = struct {
            pub fn cb(path: [:0]const u8, status: git.FileStatus, _: *u8) c_int {
                return callback_fn(path, status);
            }
        }.cb;

        var dummy_data: u8 = undefined;
        return self.foreachFileStatusWithUserData(&dummy_data, cb);
    }

    /// Gather file statuses and run a callback for each one.
    ///
    /// Return a non-zero value from the callback to stop the loop. This non-zero value is returned by the function.
    ///
    /// ## Parameters
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `path` - The file path
    /// * `status` - The status of the file
    /// * `user_data_ptr` - pointer to user data
    pub fn foreachFileStatusWithUserData(
        self: *const Repository,
        user_data: anytype,
        comptime callback_fn: fn (
            path: [:0]const u8,
            status: git.FileStatus,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !c_int {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(path: [*c]const u8, status: c_uint, payload: ?*c_void) callconv(.C) c_int {
                return callback_fn(
                    std.mem.sliceTo(path, 0),
                    @bitCast(git.FileStatus, status),
                    @intToPtr(UserDataType, @ptrToInt(payload)),
                );
            }
        }.cb;

        log.debug("Repository.foreachFileStatusWithUserData called", .{});

        const ret = try internal.wrapCallWithReturn("git_status_foreach", .{ internal.toC(self), cb, user_data });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    /// Gather file status information and run callbacks as requested.
    ///
    /// This is an extended version of the `foreachFileStatus` function that allows for more granular control over which paths
    /// will be processed. See `FileStatusOptions` for details about the additional options that this makes available.
    ///
    /// Note that if a `pathspec` is given in the `FileStatusOptions` to filter the status, then the results from rename
    /// detection (if you enable it) may not be accurate. To do rename detection properly, this must be called with no `pathspec`
    /// so that all files can be considered.
    ///
    /// Return a non-zero value from the callback to stop the loop. This non-zero value is returned by the function.
    ///
    /// ## Parameters
    /// * `options` - callback options
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `path` - The file path
    /// * `status` - The status of the file
    pub fn foreachFileStatusExtended(
        self: *const Repository,
        options: FileStatusOptions,
        comptime callback_fn: fn (path: [:0]const u8, status: git.FileStatus) c_int,
    ) !c_int {
        const cb = struct {
            pub fn cb(path: [:0]const u8, status: git.FileStatus, _: *u8) c_int {
                return callback_fn(path, status);
            }
        }.cb;

        var dummy_data: u8 = undefined;
        return self.foreachFileStatusExtendedWithUserData(options, &dummy_data, cb);
    }

    /// Gather file status information and run callbacks as requested.
    ///
    /// This is an extended version of the `foreachFileStatus` function that allows for more granular control over which paths
    /// will be processed. See `FileStatusOptions` for details about the additional options that this makes available.
    ///
    /// Note that if a `pathspec` is given in the `FileStatusOptions` to filter the status, then the results from rename
    /// detection (if you enable it) may not be accurate. To do rename detection properly, this must be called with no `pathspec`
    /// so that all files can be considered.
    ///
    /// Return a non-zero value from the callback to stop the loop. This non-zero value is returned by the function.
    ///
    /// ## Parameters
    /// * `options` - callback options
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `path` - The file path
    /// * `status` - The status of the file
    /// * `user_data_ptr` - pointer to user data
    pub fn foreachFileStatusExtendedWithUserData(
        self: *const Repository,
        options: FileStatusOptions,
        user_data: anytype,
        comptime callback_fn: fn (
            path: [:0]const u8,
            status: git.FileStatus,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !c_int {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(path: [*c]const u8, status: c_uint, payload: ?*c_void) callconv(.C) c_int {
                return callback_fn(
                    std.mem.sliceTo(path, 0),
                    @bitCast(git.FileStatus, status),
                    @intToPtr(UserDataType, @ptrToInt(payload)),
                );
            }
        }.cb;

        log.debug("Repository.foreachFileStatusExtendedWithUserData called, options={}", .{options});

        var opts: raw.git_status_options = undefined;
        try options.toCType(&opts);

        const ret = try internal.wrapCallWithReturn("git_status_foreach_ext", .{ internal.toC(self), &opts, cb, user_data });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    /// Gather file status information and populate a `git.StatusList`.
    ///
    /// Note that if a `pathspec` is given in the `FileStatusOptions` to filter the status, then the results from rename detection
    /// (if you enable it) may not be accurate. To do rename detection properly, this must be called with no `pathspec` so that
    /// all files can be considered.
    ///
    /// ## Parameters
    /// * `options` - options regarding which files to get the status of
    pub fn getStatusList(self: *const Repository, options: FileStatusOptions) !*git.StatusList {
        log.debug("Repository.getStatusList called, options={}", .{options});

        var opts: raw.git_status_options = undefined;
        try options.toCType(&opts);

        var status_list: ?*raw.git_status_list = undefined;
        try internal.wrapCall("git_status_list_new", .{ &status_list, internal.toC(self), &opts });

        log.debug("successfully fetched status list", .{});

        return internal.fromC(status_list.?);
    }

    pub const FileStatusOptions = struct {
        /// which files to scan
        show: Show = .INDEX_AND_WORKDIR,

        /// Flags to control status callbacks
        flags: Flags = .{},

        /// The `pathspec` is an array of path patterns to match (using fnmatch-style matching), or just an array of paths to 
        /// match exactly if `Flags.DISABLE_PATHSPEC_MATCH` is specified in the flags.
        pathspec: git.StrArray = .{},

        /// The `baseline` is the tree to be used for comparison to the working directory and index; defaults to HEAD.
        baseline: ?*const git.Tree = null,

        /// Select the files on which to report status.
        pub const Show = enum(c_uint) {
            /// The default. This roughly matches `git status --porcelain` regarding which files are included and in what order.
            INDEX_AND_WORKDIR,
            /// Only gives status based on HEAD to index comparison, not looking at working directory changes.
            INDEX_ONLY,
            /// Only gives status based on index to working directory comparison, not comparing the index to the HEAD.
            WORKDIR_ONLY,
        };

        /// Flags to control status callbacks
        ///
        /// Calling `Repository.forEachFileStatus` is like calling the extended version with: `INCLUDE_IGNORED`, 
        /// `INCLUDE_UNTRACKED`, and `RECURSE_UNTRACKED_DIRS`. Those options are provided as `Options.DEFAULTS`.
        pub const Flags = packed struct {
            /// Says that callbacks should be made on untracked files.
            /// These will only be made if the workdir files are included in the status
            /// "show" option.
            INCLUDE_UNTRACKED: bool = false,

            /// Says that ignored files get callbacks.
            /// Again, these callbacks will only be made if the workdir files are
            /// included in the status "show" option.
            INCLUDE_IGNORED: bool = false,

            /// Indicates that callback should be made even on unmodified files.
            INCLUDE_UNMODIFIED: bool = false,

            /// Indicates that submodules should be skipped.
            /// This only applies if there are no pending typechanges to the submodule
            /// (either from or to another type).
            EXCLUDE_SUBMODULES: bool = false,

            /// Indicates that all files in untracked directories should be included.
            /// Normally if an entire directory is new, then just the top-level
            /// directory is included (with a trailing slash on the entry name).
            /// This flag says to include all of the individual files in the directory
            /// instead.
            RECURSE_UNTRACKED_DIRS: bool = false,

            /// Indicates that the given path should be treated as a literal path,
            /// and not as a pathspec pattern.
            DISABLE_PATHSPEC_MATCH: bool = false,

            /// Indicates that the contents of ignored directories should be included
            /// in the status. This is like doing `git ls-files -o -i --exclude-standard`
            /// with core git.
            RECURSE_IGNORED_DIRS: bool = false,

            /// Indicates that rename detection should be processed between the head and
            /// the index and enables the GIT_STATUS_INDEX_RENAMED as a possible status
            /// flag.
            RENAMES_HEAD_TO_INDEX: bool = false,

            /// Indicates that rename detection should be run between the index and the
            /// working directory and enabled GIT_STATUS_WT_RENAMED as a possible status
            /// flag.
            RENAMES_INDEX_TO_WORKDIR: bool = false,

            /// Overrides the native case sensitivity for the file system and forces
            /// the output to be in case-sensitive order.
            SORT_CASE_SENSITIVELY: bool = false,

            /// Overrides the native case sensitivity for the file system and forces
            /// the output to be in case-insensitive order.
            SORT_CASE_INSENSITIVELY: bool = false,

            /// Iindicates that rename detection should include rewritten files.
            RENAMES_FROM_REWRITES: bool = false,

            /// Bypasses the default status behavior of doing a "soft" index reload
            /// (i.e. reloading the index data if the file on disk has been modified
            /// outside libgit2).
            NO_REFRESH: bool = false,

            /// Tells libgit2 to refresh the stat cache in the index for files that are
            /// unchanged but have out of date stat einformation in the index.
            /// It will result in less work being done on subsequent calls to get status.
            /// This is mutually exclusive with the NO_REFRESH option.
            UPDATE_INDEX: bool = false,

            /// Normally files that cannot be opened or read are ignored as
            /// these are often transient files; this option will return
            /// unreadable files as `GIT_STATUS_WT_UNREADABLE`.
            INCLUDE_UNREADABLE: bool = false,

            /// Unreadable files will be detected and given the status
            /// untracked instead of unreadable.
            INCLUDE_UNREADABLE_AS_UNTRACKED: bool = false,

            z_padding: u16 = 0,

            pub const DEFAULT: Flags = blk: {
                var opt = Flags{};
                opt.INCLUDE_IGNORED = true;
                opt.INCLUDE_UNTRACKED = true;
                opt.RECURSE_UNTRACKED_DIRS = true;
                break :blk opt;
            };

            pub fn format(
                value: Flags,
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
                try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(Flags));
                try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(Flags));
            }

            comptime {
                std.testing.refAllDecls(@This());
            }
        };

        fn toCType(self: FileStatusOptions, c_type: *raw.git_status_options) !void {
            if (comptime internal.available(.@"1.0.0")) {
                try internal.wrapCall("git_status_options_init", .{ c_type, raw.GIT_REPOSITORY_INIT_OPTIONS_VERSION });
            } else {
                try internal.wrapCall("git_status_init_options", .{ c_type, raw.GIT_REPOSITORY_INIT_OPTIONS_VERSION });
            }

            c_type.show = @enumToInt(self.show);
            c_type.flags = @bitCast(c_int, self.flags);
            c_type.pathspec = internal.toC(self.pathspec);
            c_type.baseline = if (self.baseline) |tree| internal.toC(tree) else null;
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Test if the ignore rules apply to a given file.
    ///
    /// ## Parameters
    /// * `path` - The file to check ignores for, rooted at the repo's workdir.
    pub fn statusShouldIgnore(self: *const Repository, path: [:0]const u8) !bool {
        log.debug("Repository.statusShouldIgnore called, path={s}", .{path});

        var result: c_int = undefined;
        try internal.wrapCall("git_status_should_ignore", .{ &result, internal.toC(self), path.ptr });

        const ret = result == 1;

        log.debug("status should ignore: {}", .{ret});

        return ret;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
