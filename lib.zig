const std = @import("std");
const raw = @import("raw.zig");
const bitjuggle = @import("bitjuggle.zig");

const log = std.log.scoped(.git);
const old_version: bool = @import("build_options").old_version;

pub const GIT_PATH_LIST_SEPARATOR = raw.GIT_PATH_LIST_SEPARATOR;

/// Initialize global state. This function must be called before any other function.
/// *NOTE*: This function can called multiple times.
pub fn init() !Handle {
    log.debug("init called", .{});

    const number = try wrapCallWithReturn("git_libgit2_init", .{});

    if (number == 1) {
        log.debug("libgit2 initalization successful", .{});
    } else {
        log.debug("{} ongoing initalizations without shutdown", .{number});
    }

    return Handle{};
}

/// Get detailed information regarding the last error that occured on this thread.
pub fn getDetailedLastError() ?*const DetailedError {
    return DetailedError.fromC(raw.git_error_last() orelse return null);
}

/// This type bundles all functionality that does not act on an instance of an object
pub const Handle = struct {
    /// De-initialize the libraries global state.
    /// *NOTE*: should be called as many times as `init` was called.
    pub fn deinit(self: Handle) void {
        _ = self;

        log.debug("Handle.deinit called", .{});

        const number = wrapCallWithReturn("git_libgit2_shutdown", .{}) catch unreachable;

        if (number == 0) {
            log.debug("libgit2 shutdown successful", .{});
        } else {
            log.debug("{} initializations have not been shutdown (after this one)", .{number});
        }
    }

    /// Create a new bare Git index object as a memory representation of the Git index file in `path`, without a repository to
    /// back it.
    ///
    /// ## Parameters
    /// * `path` - the path to the index
    pub fn indexOpen(self: Handle, path: [:0]const u8) !*Index {
        _ = self;

        log.debug("Handle.indexOpen called, path={s}", .{path});

        var index: ?*raw.git_index = undefined;

        try wrapCall("git_index_open", .{ &index, path.ptr });

        log.debug("index opened successfully", .{});

        return Index.fromC(index.?);
    }

    /// Create an in-memory index object.
    ///
    /// This index object cannot be read/written to the filesystem, but may be used to perform in-memory index operations.
    pub fn indexNew(self: Handle) !*Index {
        _ = self;

        log.debug("Handle.indexInit called", .{});

        var index: ?*raw.git_index = undefined;

        try wrapCall("git_index_new", .{&index});

        log.debug("index created successfully", .{});

        return Index.fromC(index.?);
    }

    /// Create a new repository in the given directory.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    /// * `is_bare` - If true, a Git repository without a working directory is created at the pointed path. 
    ///               If false, provided path will be considered as the working directory into which the .git directory will be 
    ///               created.
    pub fn repositoryInit(self: Handle, path: [:0]const u8, is_bare: bool) !*Repository {
        _ = self;

        log.debug("Handle.repositoryInit called, path={s}, is_bare={}", .{ path, is_bare });

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_init", .{ &repo, path.ptr, @boolToInt(is_bare) });

        log.debug("repository created successfully", .{});

        return Repository.fromC(repo.?);
    }

    /// Create a new repository in the given directory with extended options.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    /// * `options` - The options to use during the creation of the repository
    pub fn repositoryInitExtended(self: Handle, path: [:0]const u8, options: RepositoryInitOptions) !*Repository {
        _ = self;

        log.debug("Handle.repositoryInitExtended called, path={s}, options={}", .{ path, options });

        var opts: raw.git_repository_init_options = undefined;
        try options.toCType(&opts);

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_init_ext", .{ &repo, path.ptr, &opts });

        log.debug("repository created successfully", .{});

        return Repository.fromC(repo.?);
    }

    /// Open a repository.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    pub fn repositoryOpen(self: Handle, path: [:0]const u8) !*Repository {
        _ = self;

        log.debug("Handle.repositoryOpen called, path={s}", .{path});

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_open", .{ &repo, path.ptr });

        log.debug("repository opened successfully", .{});

        return Repository.fromC(repo.?);
    }

    /// Find and open a repository with extended options.
    ///
    /// *NOTE*: `path` can only be null if the `open_from_env` option is used.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    /// * `flags` - options controlling how the repository is opened
    /// * `ceiling_dirs` - A `GIT_PATH_LIST_SEPARATOR` delimited list of path prefixes at which the search for a containing
    ///                    repository should terminate.
    pub fn repositoryOpenExtended(
        self: Handle,
        path: ?[:0]const u8,
        flags: RepositoryOpenOptions,
        ceiling_dirs: ?[:0]const u8,
    ) !*Repository {
        _ = self;

        log.debug("Handle.repositoryOpenExtended called, path={s}, flags={}, ceiling_dirs={s}", .{ path, flags, ceiling_dirs });

        var repo: ?*raw.git_repository = undefined;

        const path_temp: [*c]const u8 = if (path) |slice| slice.ptr else null;
        const ceiling_dirs_temp: [*c]const u8 = if (ceiling_dirs) |slice| slice.ptr else null;
        try wrapCall("git_repository_open_ext", .{ &repo, path_temp, flags.toInt(), ceiling_dirs_temp });

        log.debug("repository opened successfully", .{});

        return Repository.fromC(repo.?);
    }

    /// Open a bare repository.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    pub fn repositoryOpenBare(self: Handle, path: [:0]const u8) !*Repository {
        _ = self;

        log.debug("Handle.repositoryOpenBare called, path={s}", .{path});

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_open_bare", .{ &repo, path.ptr });

        log.debug("repository opened successfully", .{});

        return Repository.fromC(repo.?);
    }

    /// Look for a git repository and return its path.
    ///
    /// The lookup starts from `start_path` and walks the directory tree until the first repository is found, or when reaching a
    /// directory referenced in `ceiling_dirs` or when the filesystem changes (when `across_fs` is false).
    ///
    /// ## Parameters
    /// * `start_path` - The path where the lookup starts.
    /// * `across_fs` - If true, then the lookup will not stop when a filesystem device change is encountered.
    /// * `ceiling_dirs` - A `GIT_PATH_LIST_SEPARATOR` separated list of absolute symbolic link free paths. The lookup will stop 
    ///                    when any of this paths is reached.
    pub fn repositoryDiscover(self: Handle, start_path: [:0]const u8, across_fs: bool, ceiling_dirs: ?[:0]const u8) !Buf {
        _ = self;

        log.debug(
            "Handle.repositoryDiscover called, start_path={s}, across_fs={}, ceiling_dirs={s}",
            .{ start_path, across_fs, ceiling_dirs },
        );

        var git_buf = Buf{};

        const ceiling_dirs_temp: [*c]const u8 = if (ceiling_dirs) |slice| slice.ptr else null;
        try wrapCall("git_repository_discover", .{ Buf.toC(&git_buf), start_path.ptr, @boolToInt(across_fs), ceiling_dirs_temp });

        log.debug("repository discovered - {s}", .{git_buf.slice()});

        return git_buf;
    }

    pub const RepositoryInitOptions = struct {
        flags: RepositoryInitExtendedFlags = .{},
        mode: InitMode = .shared_umask,

        /// The path to the working dir or `null` for default (i.e. repo_path parent on non-bare repos). 
        /// *NOTE*: if this is a relative path, it must be relative to the repository path. 
        /// If this is not the "natural" working directory, a .git gitlink file will be created linking to the repository path.
        workdir_path: ?[:0]const u8 = null,

        /// A "description" file to be used in the repository, instead of using the template content.
        description: ?[:0]const u8 = null,

        /// When `RepositoryInitExtendedFlags.external_template` is set, this must contain the path to use for the template
        /// directory. If this is `null`, the config or default directory options will be used instead.
        template_path: ?[:0]const u8 = null,

        /// The name of the head to point HEAD at. If `null`, then this will be treated as "master" and the HEAD ref will be set
        /// to "refs/heads/master".
        /// If this begins with "refs/" it will be used verbatim; otherwise "refs/heads/" will be prefixed.
        initial_head: ?[:0]const u8 = null,

        /// If this is non-`null`, then after the rest of the repository initialization is completed, an "origin" remote will be 
        /// added pointing to this URL.
        origin_url: ?[:0]const u8 = null,

        pub const RepositoryInitExtendedFlags = packed struct {
            /// Create a bare repository with no working directory.
            bare: bool = false,

            /// Return an `GitError.EXISTS` error if the path appears to already be an git repository.
            no_reinit: bool = false,

            /// Normally a "/.git/" will be appended to the repo path for non-bare repos (if it is not already there), but passing 
            /// this flag prevents that behavior.
            no_dotgit_dir: bool = false,

            /// Make the repo_path (and workdir_path) as needed. Init is always willing to create the ".git" directory even
            /// without this flag. This flag tells init to create the trailing component of the repo and workdir paths as needed.
            mkdir: bool = false,

            /// Recursively make all components of the repo and workdir paths as necessary.
            mkpath: bool = false,

            /// libgit2 normally uses internal templates to initialize a new repo. 
            /// This flag enables external templates, looking at the "template_path" from the options if set, or the
            /// `init.templatedir` global config if not, or falling back on "/usr/share/git-core/templates" if it exists.
            external_template: bool = false,

            /// If an alternate workdir is specified, use relative paths for the gitdir and core.worktree.
            relative_gitlink: bool = false,

            z_padding: std.meta.Int(.unsigned, @bitSizeOf(c_uint) - 7) = 0,

            pub fn toInt(self: RepositoryInitExtendedFlags) c_uint {
                return @bitCast(c_uint, self);
            }

            pub fn format(
                value: RepositoryInitExtendedFlags,
                comptime fmt: []const u8,
                options: std.fmt.FormatOptions,
                writer: anytype,
            ) !void {
                _ = fmt;
                return formatWithoutFields(
                    value,
                    options,
                    writer,
                    &.{"z_padding"},
                );
            }

            test {
                try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(RepositoryInitExtendedFlags));
                try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(RepositoryInitExtendedFlags));
            }

            comptime {
                std.testing.refAllDecls(@This());
            }
        };

        pub const InitMode = union(enum) {
            /// Use permissions configured by umask - the default.
            shared_umask: void,

            /// Use "--shared=group" behavior, chmod'ing the new repo to be group writable and "g+sx" for sticky group assignment.
            shared_group: void,

            /// Use "--shared=all" behavior, adding world readability.
            shared_all: void,

            custom: c_uint,

            pub fn toInt(self: InitMode) c_uint {
                return switch (self) {
                    .shared_umask => 0,
                    .shared_group => 0o2775,
                    .shared_all => 0o2777,
                    .custom => |custom| custom,
                };
            }
        };

        fn toCType(self: RepositoryInitOptions, c_type: *raw.git_repository_init_options) !void {
            if (old_version) {
                try wrapCall("git_repository_init_init_options", .{ c_type, raw.GIT_REPOSITORY_INIT_OPTIONS_VERSION });
            } else {
                try wrapCall("git_repository_init_options_init", .{ c_type, raw.GIT_REPOSITORY_INIT_OPTIONS_VERSION });
            }

            c_type.flags = self.flags.toInt();
            c_type.mode = self.mode.toInt();
            c_type.workdir_path = if (self.workdir_path) |slice| slice.ptr else null;
            c_type.description = if (self.description) |slice| slice.ptr else null;
            c_type.template_path = if (self.template_path) |slice| slice.ptr else null;
            c_type.initial_head = if (self.initial_head) |slice| slice.ptr else null;
            c_type.origin_url = if (self.origin_url) |slice| slice.ptr else null;
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    pub const RepositoryOpenOptions = packed struct {
        /// Only open the repository if it can be immediately found in the path. Do not walk up the directory tree to look for it.
        no_search: bool = false,

        /// Unless this flag is set, open will not search across filesystem boundaries.
        cross_fs: bool = false,

        /// Open repository as a bare repo regardless of core.bare config.
        bare: bool = false,

        /// Do not check for a repository by appending /.git to the path; only open the repository if path itself points to the
        /// git directory.     
        no_dotgit: bool = false,

        /// Find and open a git repository, respecting the environment variables used by the git command-line tools. If set, 
        /// `Handle.repositoryOpenExtended` will ignore the other flags and the `ceiling_dirs` argument, and will allow a `null`
        /// `path` to use `GIT_DIR` or search from the current directory.
        open_from_env: bool = false,

        z_padding: std.meta.Int(.unsigned, @bitSizeOf(c_uint) - 5) = 0,

        pub fn toInt(self: RepositoryOpenOptions) c_uint {
            return @bitCast(c_uint, self);
        }

        pub fn format(
            value: RepositoryOpenOptions,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            return formatWithoutFields(
                value,
                options,
                writer,
                &.{"z_padding"},
            );
        }

        test {
            try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(RepositoryOpenOptions));
            try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(RepositoryOpenOptions));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const Reference = opaque {
    pub fn deinit(self: *Reference) void {
        log.debug("Reference.deinit called", .{});

        raw.git_reference_free(self.toC());

        log.debug("reference freed successfully", .{});
    }

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_reference {
        return @intToPtr(*raw.git_reference, @ptrToInt(self));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

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

pub const Repository = opaque {
    pub fn deinit(self: *Repository) void {
        log.debug("Repository.deinit called", .{});

        raw.git_repository_free(self.toC());

        log.debug("repository closed successfully", .{});
    }

    pub fn getState(self: *const Repository) RepositoryState {
        log.debug("Repository.getState called", .{});

        const ret = @intToEnum(RepositoryState, raw.git_repository_state(self.toC()));

        log.debug("repository state: {s}", .{@tagName(ret)});

        return ret;
    }

    /// Retrieve the configured identity to use for reflogs
    pub fn getIdentity(self: *const Repository) !Identity {
        log.debug("Repository.getIdentity called", .{});

        var c_name: [*c]u8 = undefined;
        var c_email: [*c]u8 = undefined;

        try wrapCall("git_repository_ident", .{ &c_name, &c_email, self.toC() });

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
        try wrapCall("git_repository_set_ident", .{ self.toC(), name_temp, email_temp });

        log.debug("successfully set identity", .{});
    }

    pub fn getNamespace(self: *const Repository) !?[:0]const u8 {
        log.debug("Repository.getNamespace called", .{});

        const ret = raw.git_repository_get_namespace(self.toC());

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

        try wrapCall("git_repository_set_namespace", .{ self.toC(), namespace.ptr });

        log.debug("successfully set namespace", .{});
    }

    pub fn isHeadDetached(self: *const Repository) !bool {
        log.debug("Repository.isHeadDetached called", .{});

        const ret = (try wrapCallWithReturn("git_repository_head_detached", .{self.toC()})) == 1;

        log.debug("is head detached: {}", .{ret});

        return ret;
    }

    pub fn getHead(self: *const Repository) !*Reference {
        log.debug("Repository.head called", .{});

        var ref: ?*raw.git_reference = undefined;

        try wrapCall("git_repository_head", .{ &ref, self.toC() });

        log.debug("reference opened successfully", .{});

        return Reference.fromC(ref.?);
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

        try wrapCall("git_repository_set_head", .{ self.toC(), ref_name.ptr });

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
    pub fn setHeadDetached(self: *Repository, commit: Oid) !void {
        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const slice = try commit.formatHex(&buf);
            log.debug("Repository.setHeadDetached called, commit={s}", .{slice});
        }

        try wrapCall("git_repository_set_head_detached", .{ self.toC(), commit.toC() });

        log.debug("successfully set head", .{});
    }

    /// Make the repository HEAD directly point to the commit.
    ///
    /// This behaves like `Repository.setHeadDetached` but takes an annotated commit, which lets you specify which 
    /// extended sha syntax string was specified by a user, allowing for more exact reflog messages.
    ///
    /// See the documentation for `Repository.setHeadDetached`.
    pub fn setHeadDetachedFromAnnotated(self: *Repository, commitish: *const AnnotatedCommit) !void {
        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const oid = try commitish.getCommitId();
            const slice = try oid.formatHex(&buf);
            log.debug("Repository.setHeadDetachedFromAnnotated called, commitish={s}", .{slice});
        }

        try wrapCall("git_repository_set_head_detached_from_annotated", .{ self.toC(), commitish.toC() });

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

        try wrapCall("git_repository_detach_head", .{self.toC()});

        log.debug("successfully detached the head", .{});
    }

    pub fn isHeadForWorktreeDetached(self: *const Repository, name: [:0]const u8) !bool {
        log.debug("Repository.isHeadForWorktreeDetached called, name={s}", .{name});

        const ret = (try wrapCallWithReturn(
            "git_repository_head_detached_for_worktree",
            .{ self.toC(), name.ptr },
        )) == 1;

        log.debug("head for worktree {s} is detached: {}", .{ name, ret });

        return ret;
    }

    pub fn headForWorktree(self: *const Repository, name: [:0]const u8) !*Reference {
        log.debug("Repository.headForWorktree called, name={s}", .{name});

        var ref: ?*raw.git_reference = undefined;

        try wrapCall("git_repository_head_for_worktree", .{ &ref, self.toC(), name.ptr });

        log.debug("reference opened successfully", .{});

        return Reference.fromC(ref.?);
    }

    pub fn isHeadUnborn(self: *const Repository) !bool {
        log.debug("Repository.isHeadUnborn called", .{});

        const ret = (try wrapCallWithReturn("git_repository_head_unborn", .{self.toC()})) == 1;

        log.debug("is head unborn: {}", .{ret});

        return ret;
    }

    pub fn isShallow(self: *const Repository) bool {
        log.debug("Repository.isShallow called", .{});

        const ret = raw.git_repository_is_shallow(self.toC()) == 1;

        log.debug("is repository a shallow clone: {}", .{ret});

        return ret;
    }

    pub fn isEmpty(self: *const Repository) !bool {
        log.debug("Repository.isEmpty called", .{});

        const ret = (try wrapCallWithReturn("git_repository_is_empty", .{self.toC()})) == 1;

        log.debug("is repository empty: {}", .{ret});

        return ret;
    }

    pub fn isBare(self: *const Repository) bool {
        log.debug("Repository.isBare called", .{});

        const ret = raw.git_repository_is_bare(self.toC()) == 1;

        log.debug("is repository bare: {}", .{ret});

        return ret;
    }

    pub fn isWorktree(self: *const Repository) bool {
        log.debug("Repository.isWorktree called", .{});

        const ret = raw.git_repository_is_worktree(self.toC()) == 1;

        log.debug("is repository worktree: {}", .{ret});

        return ret;
    }

    /// Get the location of a specific repository file or directory
    pub fn getItemPath(self: *const Repository, item: RepositoryItem) !Buf {
        // TODO: Return optional instead of error
        log.debug("Repository.itemPath called, item={s}", .{item});

        var buf = Buf{};

        try wrapCall("git_repository_item_path", .{ Buf.toC(&buf), self.toC(), @enumToInt(item) });

        log.debug("item path: {s}", .{buf.slice()});

        return buf;
    }

    pub fn getPath(self: *const Repository) [:0]const u8 {
        log.debug("Repository.path called", .{});

        const slice = std.mem.sliceTo(raw.git_repository_path(self.toC()), 0);

        log.debug("path: {s}", .{slice});

        return slice;
    }

    pub fn getWorkdir(self: *const Repository) ?[:0]const u8 {
        log.debug("Repository.workdir called", .{});

        if (raw.git_repository_workdir(self.toC())) |ret| {
            const slice = std.mem.sliceTo(ret, 0);

            log.debug("workdir: {s}", .{slice});

            return slice;
        }

        log.debug("no workdir", .{});

        return null;
    }

    pub fn setWorkdir(self: *Repository, workdir: [:0]const u8, update_gitlink: bool) !void {
        log.debug("Repository.setWorkdir called, workdir={s}, update_gitlink={}", .{ workdir, update_gitlink });

        try wrapCall("git_repository_set_workdir", .{ self.toC(), workdir.ptr, @boolToInt(update_gitlink) });

        log.debug("successfully set workdir", .{});
    }

    pub fn getCommondir(self: *const Repository) ?[:0]const u8 {
        log.debug("Repository.commondir called", .{});

        if (raw.git_repository_commondir(self.toC())) |ret| {
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
    pub fn getConfig(self: *const Repository) !*Config {
        log.debug("Repository.getConfig called", .{});

        var config: ?*raw.git_config = undefined;

        try wrapCall("git_repository_config", .{ &config, self.toC() });

        log.debug("repository config acquired successfully", .{});

        return Config.fromC(config.?);
    }

    /// Get a snapshot of the repository's configuration
    ///
    /// The contents of this snapshot will not change, even if the underlying config files are modified.
    pub fn getConfigSnapshot(self: *const Repository) !*Config {
        log.debug("Repository.getConfigSnapshot called", .{});

        var config: ?*raw.git_config = undefined;

        try wrapCall("git_repository_config_snapshot", .{ &config, self.toC() });

        log.debug("repository config acquired successfully", .{});

        return Config.fromC(config.?);
    }

    pub fn getOdb(self: *const Repository) !*Odb {
        log.debug("Repository.getOdb called", .{});

        var odb: ?*raw.git_odb = undefined;

        try wrapCall("git_repository_odb", .{ &odb, self.toC() });

        log.debug("repository odb acquired successfully", .{});

        return Odb.fromC(odb.?);
    }

    pub fn getRefDb(self: *const Repository) !*RefDb {
        log.debug("Repository.getRefDb called", .{});

        var ref_db: ?*raw.git_refdb = undefined;

        try wrapCall("git_repository_refdb", .{ &ref_db, self.toC() });

        log.debug("repository refdb acquired successfully", .{});

        return RefDb.fromC(ref_db.?);
    }

    pub fn getIndex(self: *const Repository) !*Index {
        log.debug("Repository.getIndex called", .{});

        var index: ?*raw.git_index = undefined;

        try wrapCall("git_repository_index", .{ &index, self.toC() });

        log.debug("repository index acquired successfully", .{});

        return Index.fromC(index.?);
    }

    /// Retrieve git's prepared message
    ///
    /// Operations such as git revert/cherry-pick/merge with the -n option stop just short of creating a commit with the changes 
    /// and save their prepared message in .git/MERGE_MSG so the next git-commit execution can present it to the user for them to
    /// amend if they wish.
    ///
    /// Use this function to get the contents of this file. Don't forget to remove the file after you create the commit.
    pub fn getPreparedMessage(self: *const Repository) !Buf {
        // TODO: Change this function and others to return null instead of `GitError.NotFound`

        log.debug("Repository.getPreparedMessage called", .{});

        var buf = Buf{};

        try wrapCall("git_repository_message", .{ Buf.toC(&buf), self.toC() });

        log.debug("prepared message: {s}", .{buf.slice()});

        return buf;
    }

    /// Remove git's prepared message file.
    pub fn removePreparedMessage(self: *Repository) !void {
        log.debug("Repository.removePreparedMessage called", .{});

        try wrapCall("git_repository_message_remove", .{self.toC()});

        log.debug("successfully removed prepared message", .{});
    }

    /// Remove all the metadata associated with an ongoing command like merge, revert, cherry-pick, etc.
    /// For example: MERGE_HEAD, MERGE_MSG, etc.
    pub fn stateCleanup(self: *Repository) !void {
        log.debug("Repository.stateCleanup called", .{});

        try wrapCall("git_repository_state_cleanup", .{self.toC()});

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
            oid: *const Oid,
            is_merge: bool,
        ) c_int,
    ) !c_int {
        const cb = struct {
            pub fn cb(
                ref_name: [:0]const u8,
                remote_url: [:0]const u8,
                oid: *const Oid,
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
            oid: *const Oid,
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
                    Oid.fromC(c_oid.?),
                    c_is_merge == 1,
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("Repository.foreachFetchHeadWithUserData called", .{});

        const ret = try wrapCallWithReturn("git_repository_fetchhead_foreach", .{ self.toC(), cb, user_data });

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
        comptime callback_fn: fn (oid: *const Oid) c_int,
    ) !c_int {
        const cb = struct {
            pub fn cb(oid: *const Oid, _: *u8) c_int {
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
            oid: *const Oid,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !c_int {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(c_oid: [*c]const raw.git_oid, payload: ?*c_void) callconv(.C) c_int {
                return callback_fn(Oid.fromC(c_oid.?), @ptrCast(UserDataType, payload));
            }
        }.cb;

        log.debug("Repository.foreachMergeHeadWithUserData called", .{});

        const ret = try wrapCallWithReturn("git_repository_mergehead_foreach", .{ self.toC(), cb, user_data });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    /// Calculate hash of file using repository filtering rules.
    ///
    /// If you simply want to calculate the hash of a file on disk with no filters, you can just use `Odb.hashFile`.
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
    pub fn hashFile(self: *const Repository, path: [:0]const u8, object_type: ObjectType, as_path: ?[:0]const u8) !*const Oid {
        log.debug("Repository.hashFile called, path={s}, object_type={}, as_path={s}", .{ path, object_type, as_path });

        var oid: ?*raw.git_oid = undefined;

        const as_path_temp: [*c]const u8 = if (as_path) |slice| slice.ptr else null;
        try wrapCall("git_repository_hashfile", .{ oid, self.toC(), path.ptr, @enumToInt(object_type), as_path_temp });

        const ret = Oid.fromC(oid.?);

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [Oid.HEX_BUFFER_SIZE]u8 = undefined;
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
    pub fn fileStatus(self: *const Repository, path: [:0]const u8) !FileStatus {
        // TODO: return optional instead of GitError.NotFound

        log.debug("Repository.fileStatus called, path={s}", .{path});

        var flags: c_uint = undefined;

        try wrapCall("git_status_file", .{ &flags, self.toC(), path.ptr });

        const ret = @bitCast(FileStatus, flags);

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
        comptime callback_fn: fn (path: [:0]const u8, status: FileStatus) c_int,
    ) !c_int {
        const cb = struct {
            pub fn cb(path: [:0]const u8, status: FileStatus, _: *u8) c_int {
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
            status: FileStatus,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !c_int {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(path: [*c]const u8, status: c_uint, payload: ?*c_void) callconv(.C) c_int {
                return callback_fn(
                    std.mem.sliceTo(path, 0),
                    @bitCast(FileStatus, status),
                    @intToPtr(UserDataType, @ptrToInt(payload)),
                );
            }
        }.cb;

        log.debug("Repository.foreachFileStatusWithUserData called", .{});

        const ret = try wrapCallWithReturn("git_status_foreach", .{ self.toC(), cb, user_data });

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
        comptime callback_fn: fn (path: [:0]const u8, status: FileStatus) c_int,
    ) !c_int {
        const cb = struct {
            pub fn cb(path: [:0]const u8, status: FileStatus, _: *u8) c_int {
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
            status: FileStatus,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !c_int {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(path: [*c]const u8, status: c_uint, payload: ?*c_void) callconv(.C) c_int {
                return callback_fn(
                    std.mem.sliceTo(path, 0),
                    @bitCast(FileStatus, status),
                    @intToPtr(UserDataType, @ptrToInt(payload)),
                );
            }
        }.cb;

        log.debug("Repository.foreachFileStatusExtendedWithUserData called, options={}", .{options});

        var opts: raw.git_status_options = undefined;
        try options.toCType(&opts);

        const ret = try wrapCallWithReturn("git_status_foreach_ext", .{ self.toC(), &opts, cb, user_data });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    /// Gather file status information and populate a `StatusList`.
    ///
    /// Note that if a `pathspec` is given in the `FileStatusOptions` to filter the status, then the results from rename detection
    /// (if you enable it) may not be accurate. To do rename detection properly, this must be called with no `pathspec` so that
    /// all files can be considered.
    ///
    /// ## Parameters
    /// * `options` - options regarding which files to get the status of
    pub fn getStatusList(self: *const Repository, options: FileStatusOptions) !*StatusList {
        log.debug("Repository.getStatusList called, options={}", .{options});

        var opts: raw.git_status_options = undefined;
        try options.toCType(&opts);

        var status_list: ?*raw.git_status_list = undefined;
        try wrapCall("git_status_list_new", .{ &status_list, self.toC(), &opts });

        log.debug("successfully fetched status list", .{});

        return StatusList.fromC(status_list.?);
    }

    /// Test if the ignore rules apply to a given file.
    ///
    /// ## Parameters
    /// * `path` - The file to check ignores for, rooted at the repo's workdir.
    pub fn statusShouldIgnore(self: *const Repository, path: [:0]const u8) !bool {
        log.debug("Repository.statusShouldIgnore called, path={s}", .{path});

        var result: c_int = undefined;
        try wrapCall("git_status_should_ignore", .{ &result, self.toC(), path.ptr });

        const ret = result == 1;

        log.debug("status should ignore: {}", .{ret});

        return ret;
    }

    pub const FileStatusOptions = struct {
        /// which files to scan
        show: Show = .INDEX_AND_WORKDIR,

        /// Flags to control status callbacks
        flags: Flags = .{},

        /// The `pathspec` is an array of path patterns to match (using fnmatch-style matching), or just an array of paths to 
        /// match exactly if `Flags.DISABLE_PATHSPEC_MATCH` is specified in the flags.
        pathspec: StrArray = .{},

        /// The `baseline` is the tree to be used for comparison to the working directory and index; defaults to HEAD.
        baseline: ?*const Tree = null,

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
                return formatWithoutFields(
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
            if (old_version) {
                try wrapCall("git_status_init_options", .{ c_type, raw.GIT_REPOSITORY_INIT_OPTIONS_VERSION });
            } else {
                try wrapCall("git_status_options_init", .{ c_type, raw.GIT_REPOSITORY_INIT_OPTIONS_VERSION });
            }

            c_type.show = @enumToInt(self.show);
            c_type.flags = @bitCast(c_int, self.flags);
            c_type.pathspec = self.pathspec.toC();
            c_type.baseline = if (self.baseline) |tree| tree.toC() else null;
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

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

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_repository {
        return @intToPtr(*raw.git_repository, @ptrToInt(self));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const StrArray = extern struct {
    strings: [*c][*c]u8 = null,
    count: usize = 0,

    pub fn fromSlice(slice: []const [*:0]const u8) StrArray {
        return .{
            .strings = @intToPtr([*c][*c]u8, @ptrToInt(slice.ptr)),
            .count = slice.len,
        };
    }

    pub fn toSlice(self: StrArray) []const [*:0]const u8 {
        if (self.count == 0) return &[_][*:0]const u8{};
        return @ptrCast([*]const [*:0]const u8, self.strings)[0..self.count];
    }

    inline fn fromC(self: raw.git_strarray) StrArray {
        return @bitCast(StrArray, self);
    }

    inline fn toC(self: StrArray) raw.git_strarray {
        return @bitCast(raw.git_strarray, self);
    }

    test {
        try std.testing.expectEqual(@sizeOf(raw.git_strarray), @sizeOf(StrArray));
        try std.testing.expectEqual(@bitSizeOf(raw.git_strarray), @bitSizeOf(StrArray));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const StatusList = opaque {
    pub fn deinit(self: *StatusList) void {
        log.debug("StatusList.deinit called", .{});

        raw.git_status_list_free(self.toC());

        log.debug("status list freed successfully", .{});
    }

    pub fn getEntryCount(self: *const StatusList) usize {
        log.debug("StatusList.getEntryCount called", .{});

        const ret = raw.git_status_list_entrycount(self.toC());

        log.debug("status list entry count: {}", .{ret});

        return ret;
    }

    pub fn getStatusByIndex(self: *const StatusList, index: usize) ?*const StatusEntry {
        log.debug("StatusList.getStatusByIndex called, index={}", .{index});

        const ret_opt = raw.git_status_byindex(self.toC(), index);

        if (ret_opt) |ret| {
            const result = @intToPtr(*const StatusEntry, @ptrToInt(ret));

            log.debug("successfully fetched status entry: {}", .{result});

            return result;
        } else {
            log.debug("index out of bounds", .{});
            return null;
        }
    }

    /// A status entry, providing the differences between the file as it exists in HEAD and the index, and providing the 
    /// differences between the index and the working directory.
    pub const StatusEntry = extern struct {
        /// The status for this file
        status: FileStatus,

        /// information about the differences between the file in HEAD and the file in the index.
        head_to_index: *DiffDelta,

        /// information about the differences between the file in the index and the file in the working directory.
        index_to_workdir: *DiffDelta,

        test {
            try std.testing.expectEqual(@sizeOf(raw.git_status_entry), @sizeOf(StatusEntry));
            try std.testing.expectEqual(@bitSizeOf(raw.git_status_entry), @bitSizeOf(StatusEntry));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_status_list {
        return @intToPtr(*raw.git_status_list, @ptrToInt(self));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Description of changes to one entry.
///
/// A `delta` is a file pair with an old and new revision. The old version may be absent if the file was just created and the new
/// version may be absent if the file was deleted. A diff is mostly just a list of deltas.
///
/// When iterating over a diff, this will be passed to most callbacks and you can use the contents to understand exactly what has
/// changed.
///
/// The `old_file` represents the "from" side of the diff and the `new_file` represents to "to" side of the diff.  What those
/// means depend on the function that was used to generate the diff. You can also use the `GIT_DIFF_REVERSE` flag to flip it
/// around.
///
/// Although the two sides of the delta are named `old_file` and `new_file`, they actually may correspond to entries that
/// represent a file, a symbolic link, a submodule commit id, or even a tree (if you are tracking type changes or
/// ignored/untracked directories).
///
/// Under some circumstances, in the name of efficiency, not all fields will be filled in, but we generally try to fill in as much
/// as possible. One example is that the `flags` field may not have either the `BINARY` or the `NOT_BINARY` flag set to avoid
/// examining file contents if you do not pass in hunk and/or line callbacks to the diff foreach iteration function.  It will just
/// use the git attributes for those files.
///
/// The similarity score is zero unless you call `git_diff_find_similar()` which does a similarity analysis of files in the diff.
/// Use that function to do rename and copy detection, and to split heavily modified files in add/delete pairs. After that call,
/// deltas with a status of GIT_DELTA_RENAMED or GIT_DELTA_COPIED will have a similarity score between 0 and 100 indicating how
/// similar the old and new sides are.
///
/// If you ask `git_diff_find_similar` to find heavily modified files to break, but to not *actually* break the records, then
/// GIT_DELTA_MODIFIED records may have a non-zero similarity score if the self-similarity is below the split threshold. To
/// display this value like core Git, invert the score (a la `printf("M%03d", 100 - delta->similarity)`).
pub const DiffDelta = extern struct {
    status: DeltaType,
    flags: DiffFlags,
    /// for RENAMED and COPIED, value 0-100
    similarity: u16,
    number_of_files: u16,
    old_file: DiffFile,
    new_file: DiffFile,

    /// What type of change is described by a git_diff_delta?
    ///
    /// `GIT_DELTA_RENAMED` and `GIT_DELTA_COPIED` will only show up if you run `git_diff_find_similar()` on the diff object.
    ///
    /// `GIT_DELTA_TYPECHANGE` only shows up given `GIT_DIFF_INCLUDE_TYPECHANGE` in the option flags (otherwise type changes will
    /// be split into ADDED / DELETED pairs).
    pub const DeltaType = enum(c_uint) {
        /// no changes
        UNMODIFIED,
        /// entry does not exist in old version
        ADDED,
        /// entry does not exist in new version
        DELETED,
        /// entry content changed between old and new
        MODIFIED,
        /// entry was renamed between old and new
        RENAMED,
        /// entry was copied from another old entry
        COPIED,
        /// entry is ignored item in workdir
        IGNORED,
        /// entry is untracked item in workdir
        UNTRACKED,
        /// type of entry changed between old and new 
        TYPECHANGE,
        /// entry is unreadable
        UNREADABLE,
        /// entry in the index is conflicted
        CONFLICTED,
    };

    /// Flags for the delta object and the file objects on each side.
    ///
    /// These flags are used for both the `flags` value of the `git_diff_delta` and the flags for the `git_diff_file` objects
    /// representing the old and new sides of the delta.  Values outside of this public range should be considered reserved 
    /// for internal or future use.
    pub const DiffFlags = packed struct {
        /// file(s) treated as binary data
        BINARY: bool = false,
        /// file(s) treated as text data
        NOT_BINARY: bool = false,
        /// `id` value is known correct
        VALID_ID: bool = false,
        /// file exists at this side of the delta
        EXISTS: bool = false,

        z_padding1: u12 = 0,
        z_padding2: u16 = 0,

        pub fn format(
            value: DiffFlags,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            return formatWithoutFields(
                value,
                options,
                writer,
                &.{ "z_padding1", "z_padding2" },
            );
        }

        test {
            try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(DiffFlags));
            try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(DiffFlags));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Description of one side of a delta.
    ///
    /// Although this is called a "file", it could represent a file, a symbolic link, a submodule commit id, or even a tree
    /// (although that only if you are tracking type changes or ignored/untracked directories).
    pub const DiffFile = extern struct {
        /// The `git_oid` of the item.  If the entry represents an absent side of a diff (e.g. the `old_file` of a
        /// `GIT_DELTA_ADDED` delta), then the oid will be zeroes.
        id: Oid,
        /// Path to the entry relative to the working directory of the repository.
        path: [*:0]const u8,
        /// The size of the entry in bytes.
        size: u64,
        flags: DiffFlags,
        /// Roughly, the stat() `st_mode` value for the item.
        mode: FileMode,
        /// Represents the known length of the `id` field, when converted to a hex string.  It is generally `GIT_OID_HEXSZ`,
        /// unless this delta was created from reading a patch file, in which case it may be abbreviated to something reasonable,
        /// like 7 characters.
        id_abbrev: u16,

        test {
            try std.testing.expectEqual(@sizeOf(raw.git_diff_file), @sizeOf(DiffFile));
            try std.testing.expectEqual(@bitSizeOf(raw.git_diff_file), @bitSizeOf(DiffFile));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    test {
        try std.testing.expectEqual(@sizeOf(raw.git_diff_delta), @sizeOf(DiffDelta));
        try std.testing.expectEqual(@bitSizeOf(raw.git_diff_delta), @bitSizeOf(DiffDelta));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Valid modes for index and tree entries.
pub const FileMode = enum(u16) {
    UNREADABLE = 0o000000,
    TREE = 0o040000,
    BLOB = 0o100644,
    BLOB_EXECUTABLE = 0o100755,
    LINK = 0o120000,
    COMMIT = 0o160000,
};

pub const Tree = opaque {
    pub fn deinit(self: *Tree) void {
        log.debug("Tree.deinit called", .{});

        raw.git_tree_free(self.toC());

        log.debug("tree freed successfully", .{});
    }

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_tree {
        return @intToPtr(*raw.git_tree, @ptrToInt(self));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const FileStatus = packed struct {
    CURRENT: bool = false,
    INDEX_NEW: bool = false,
    INDEX_MODIFIED: bool = false,
    INDEX_DELETED: bool = false,
    INDEX_RENAMED: bool = false,
    INDEX_TYPECHANGE: bool = false,
    WT_NEW: bool = false,
    WT_MODIFIED: bool = false,
    WT_DELETED: bool = false,
    WT_TYPECHANGE: bool = false,
    WT_RENAMED: bool = false,
    WT_UNREADABLE: bool = false,
    IGNORED: bool = false,
    CONFLICTED: bool = false,

    z_padding1: u2 = 0,
    z_padding2: u16 = 0,

    pub fn format(
        value: FileStatus,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        return formatWithoutFields(
            value,
            options,
            writer,
            &.{ "z_padding1", "z_padding2" },
        );
    }

    test {
        try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(FileStatus));
        try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(FileStatus));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const Identity = struct {
    name: ?[:0]const u8,
    email: ?[:0]const u8,
};

pub const AnnotatedCommit = opaque {
    pub fn deinit(self: *AnnotatedCommit) void {
        log.debug("AnnotatedCommit.deinit called", .{});

        raw.git_annotated_commit_free(self.toC());

        log.debug("annotated commit freed successfully", .{});
    }

    /// Gets the commit ID that the given `AnnotatedCommit` refers to.
    pub fn getCommitId(self: *const AnnotatedCommit) !*const Oid {
        log.debug("AnnotatedCommit.getCommitId called", .{});

        const oid = Oid.fromC(raw.git_annotated_commit_id(self.toC()).?);

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const slice = try oid.formatHex(&buf);
            log.debug("annotated commit id acquired: {s}", .{slice});
        }

        return oid;
    }

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_annotated_commit {
        return @intToPtr(*raw.git_annotated_commit, @ptrToInt(self));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Basic type (loose or packed) of any Git object.
pub const ObjectType = enum(c_int) {
    /// Object can be any of the following
    ANY = -2,
    /// Object is invalid.
    INVALID = -1,
    /// A commit object.
    COMMIT = 1,
    /// A tree (directory listing) object.
    TREE = 2,
    /// A file revision object.
    BLOB = 3,
    /// An annotated tag object.
    TAG = 4,
    /// A delta, base is given by an offset.
    OFS_DELTA = 6,
    /// A delta, base is given by object id.
    REF_DELTA = 7,
};

/// Unique identity of any object (commit, tree, blob, tag).
pub const Oid = extern struct {
    id: [20]u8,

    /// Size (in bytes) of a hex formatted oid
    pub const HEX_BUFFER_SIZE = raw.GIT_OID_HEXSZ;

    /// Format a git_oid into a hex string.
    ///
    /// ## Parameters
    /// * `buf` - Slice to format the oid into, must be atleast `HEX_BUFFER_SIZE` long.
    pub fn formatHex(self: Oid, buf: []u8) ![]const u8 {
        if (buf.len < HEX_BUFFER_SIZE) return error.BufferTooShort;

        try wrapCall("git_oid_fmt", .{ buf.ptr, self.toC() });

        return buf[0..HEX_BUFFER_SIZE];
    }

    /// Format a git_oid into a zero-terminated hex string.
    ///
    /// ## Parameters
    /// * `buf` - Slice to format the oid into, must be atleast `HEX_BUFFER_SIZE` + 1 long.
    pub fn formatHexZ(self: Oid, buf: []u8) ![:0]const u8 {
        if (buf.len < (HEX_BUFFER_SIZE + 1)) return error.BufferTooShort;

        try wrapCall("git_oid_fmt", .{ buf.ptr, self.toC() });
        buf[HEX_BUFFER_SIZE] = 0;

        return buf[0..HEX_BUFFER_SIZE :0];
    }

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_oid {
        return @intToPtr(*raw.git_oid, @ptrToInt(self));
    }

    test {
        try std.testing.expectEqual(@sizeOf(raw.git_oid), @sizeOf(Oid));
        try std.testing.expectEqual(@bitSizeOf(raw.git_oid), @bitSizeOf(Oid));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const Index = opaque {
    pub fn deinit(self: *Index) void {
        log.debug("Index.deinit called", .{});

        raw.git_index_free(self.toC());

        log.debug("index freed successfully", .{});
    }

    pub fn getVersion(self: *const Index) !IndexVersion {
        log.debug("Index.getVersion called", .{});

        const raw_value = raw.git_index_version(self.toC());

        if (std.meta.intToEnum(IndexVersion, raw_value)) |version| {
            log.debug("successfully fetched index version={s}", .{@tagName(version)});
            return version;
        } else |_| {
            log.warn("failed to fetch valid index version, recieved={}", .{raw_value});
            return error.InvalidVersion;
        }
    }

    pub fn setVersion(self: *Index, version: IndexVersion) !void {
        log.debug("Index.setVersion called, version={s}", .{@tagName(version)});

        try wrapCall("git_index_set_version", .{ self.toC(), @enumToInt(version) });

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
        log.debug("Index.readIndexFromDisk called, force={}", .{force});

        try wrapCall("git_index_read", .{ self.toC(), @boolToInt(force) });

        log.debug("successfully read index data from disk", .{});
    }

    pub fn writeToDisk(self: *Index) !void {
        log.debug("Index.writeToDisk called", .{});

        try wrapCall("git_index_write", .{self.toC()});

        log.debug("successfully wrote index data to disk", .{});
    }

    pub fn getPath(self: *const Index) ?[:0]const u8 {
        log.debug("Index.getPath called", .{});

        if (raw.git_index_path(self.toC())) |ptr| {
            const slice = std.mem.sliceTo(ptr, 0);
            log.debug("successfully fetched index path={s}", .{slice});
            return slice;
        }

        log.debug("in-memory index has no path", .{});
        return null;
    }

    pub fn getRepository(self: *const Index) ?*Repository {
        log.debug("Index.getRepository called", .{});

        const ret = raw.git_index_owner(self.toC());

        if (ret) |ptr| {
            log.debug("successfully fetched owning repository", .{});
            return Repository.fromC(ptr);
        }

        log.debug("no owning repository", .{});
        return null;
    }

    /// Get the checksum of the index
    ///
    /// This checksum is the SHA-1 hash over the index file (except the last 20 bytes which are the checksum itself). In cases
    /// where the index does not exist on-disk, it will be zeroed out.
    pub fn getChecksum(self: *const Index) !*const Oid {
        log.debug("Index.getChecksum called", .{});

        const oid = raw.git_index_checksum(self.toC());

        const ret = Oid.fromC(oid.?);

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const slice = try ret.formatHex(&buf);
            log.debug("index checksum acquired successfully, checksum={s}", .{slice});
        }

        return ret;
    }

    pub fn setToTree(self: *Index, tree: *const Tree) !void {
        log.debug("Index.setToTree called, tree={*}", .{tree});

        try wrapCall("git_index_read_tree", .{ self.toC(), tree.toC() });

        log.debug("successfully set index to tree", .{});
    }

    pub fn writeToTreeOnDisk(self: *const Index) !Oid {
        log.debug("Index.writeToTreeOnDisk called", .{});

        var oid: Oid = undefined;

        try wrapCall("git_index_write_tree", .{ Oid.toC(&oid), self.toC() });

        log.debug("successfully wrote index tree to disk", .{});

        return oid;
    }

    pub fn getEntryCount(self: *const Index) usize {
        log.debug("Index.getEntryCount called", .{});

        const ret = raw.git_index_entrycount(self.toC());

        log.debug("index entry count: {}", .{ret});

        return ret;
    }

    /// Clear the contents of this index.
    ///
    /// This clears the index in memory; changes must be written to disk for them to be persistent.
    pub fn clear(self: *Index) !void {
        log.debug("Index.clear called", .{});

        try wrapCall("git_index_clear", .{self.toC()});

        log.debug("successfully cleared index", .{});
    }

    pub fn writeToTreeInRepository(self: *const Index, repository: *Repository) !Oid {
        log.debug("Index.writeToTreeInRepository called, repository={*}", .{repository});

        var oid: Oid = undefined;

        try wrapCall("git_index_write_tree_to", .{ Oid.toC(&oid), self.toC(), repository.toC() });

        log.debug("successfully wrote index tree to repository", .{});

        return oid;
    }

    pub fn getIndexCapabilities(self: *const Index) IndexCapabilities {
        log.debug("Index.getIndexCapabilities called", .{});

        const cap = @bitCast(IndexCapabilities, raw.git_index_caps(self.toC()));

        log.debug("successfully fetched index capabilities={}", .{cap});

        return cap;
    }

    /// If you pass `IndexCapabilities.FROM_OWNER` for the capabilities, then capabilities will be read from the config of the
    /// owner object, looking at `core.ignorecase`, `core.filemode`, `core.symlinks`.
    pub fn setIndexCapabilities(self: *Index, capabilities: IndexCapabilities) !void {
        log.debug("Index.getIndexCapabilities called, capabilities={}", .{capabilities});

        try wrapCall("git_index_set_caps", .{ self.toC(), @bitCast(c_int, capabilities) });

        log.debug("successfully set index capabilities", .{});
    }

    pub fn getEntryByIndex(self: *const Index, index: usize) ?*const IndexEntry {
        log.debug("Index.getEntryByIndex called, index={}", .{index});

        const ret_opt = raw.git_index_get_byindex(self.toC(), index);

        if (ret_opt) |ret| {
            const result = IndexEntry.fromC(ret);

            log.debug("successfully fetched index entry: {}", .{result});

            return result;
        } else {
            log.debug("index out of bounds", .{});
            return null;
        }
    }

    pub fn getEntryByPath(self: *const Index, path: [:0]const u8, stage: c_int) ?*const IndexEntry {
        log.debug("Index.getEntryByPath called, path={s}, stage={}", .{ path, stage });

        const ret_opt = raw.git_index_get_bypath(self.toC(), path.ptr, stage);

        if (ret_opt) |ret| {
            const result = IndexEntry.fromC(ret);

            log.debug("successfully fetched index entry: {}", .{result});

            return result;
        } else {
            log.debug("path not found", .{});
            return null;
        }
    }

    pub fn remove(self: *Index, path: [:0]const u8, stage: c_int) !void {
        log.debug("Index.remove called, path={s}, stage={}", .{ path, stage });

        try wrapCall("git_index_remove", .{ self.toC(), path.ptr, stage });

        log.debug("successfully removed from index", .{});
    }

    pub fn removeDirectory(self: *Index, path: [:0]const u8, stage: c_int) !void {
        log.debug("Index.removeDirectory called, path={s}, stage={}", .{ path, stage });

        try wrapCall("git_index_remove_directory", .{ self.toC(), path.ptr, stage });

        log.debug("successfully removed from index", .{});
    }

    pub fn add(self: *Index, entry: *const IndexEntry) !void {
        log.debug("Index.add called, entry={*}", .{entry});

        try wrapCall("git_index_add", .{ self.toC(), entry.toC() });

        log.debug("successfully added to index", .{});
    }

    /// The `path` must be relative to the repository's working folder.
    ///
    /// This forces the file to be added to the index, not looking at gitignore rules. Those rules can be evaluated using
    /// `Repository.statusShouldIgnore`.
    pub fn addByPath(self: *Index, path: [:0]const u8) !void {
        log.debug("Index.addByPath called, path={s}", .{path});

        try wrapCall("git_index_add_bypath", .{ self.toC(), path.ptr });

        log.debug("successfully added to index", .{});
    }

    pub fn addFromBuffer(self: *Index, index_entry: *const IndexEntry, buffer: []const u8) !void {
        log.debug("Index.addFromBuffer called, index_entry={*}, buffer.ptr={*}, buffer.len={}", .{
            index_entry,
            buffer.ptr,
            buffer.len,
        });

        try wrapCall("git_index_add_from_buffer", .{ self.toC(), index_entry.toC(), buffer.ptr, buffer.len });

        log.debug("successfully added to index", .{});
    }

    pub fn removeByPath(self: *Index, path: [:0]const u8) !void {
        log.debug("Index.removeByPath called, path={s}", .{path});

        try wrapCall("git_index_remove_bypath", .{ self.toC(), path.ptr });

        log.debug("successfully remove from index", .{});
    }

    pub fn iterate(self: *const Index) !*IndexIterator {
        log.debug("Index.iterate called", .{});

        var iterator: ?*raw.git_index_iterator = undefined;

        try wrapCall("git_index_iterator_new", .{ &iterator, self.toC() });

        log.debug("index iterator created successfully", .{});

        return IndexIterator.fromC(iterator.?);
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
        pathspec: *const StrArray,
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
        pathspec: *const StrArray,
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
                    path: [*c]const u8,
                    matched_pathspec: [*c]const u8,
                    payload: ?*c_void,
                ) callconv(.C) c_int {
                    return callback(
                        std.mem.sliceTo(path, 0),
                        std.mem.sliceTo(matched_pathspec, 0),
                        @ptrCast(UserDataType, payload),
                    );
                }
            }.cb;

            log.debug("Index.addAllWithUserData called", .{});

            const ret = try wrapCallWithReturn("git_index_add_all", .{
                self.toC(),
                pathspec.toC(),
                @bitCast(c_int, flags),
                cb,
                user_data,
            });

            log.debug("callback returned: {}", .{ret});

            return ret;
        } else {
            log.debug("Index.addAllWithUserData called", .{});

            try wrapCall("git_index_add_all", .{
                self.toC(),
                pathspec.toC(),
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
            return formatWithoutFields(
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

    pub const IndexCapabilities = packed struct {
        IGNORE_CASE: bool = false,
        NO_FILEMODE: bool = false,
        NO_SYMLINKS: bool = false,

        z_padding1: u13 = 0,
        z_padding2: u15 = 0,

        FROM_OWNER: bool = false,

        pub fn format(
            value: IndexCapabilities,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            return formatWithoutFields(
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

    pub const IndexEntry = extern struct {
        ctime: IndexTime,
        mtime: IndexTime,
        dev: u32,
        ino: u32,
        mode: u32,
        uid: u32,
        gid: u32,
        file_size: u32,
        id: Oid,
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
                try std.testing.expectEqual(@sizeOf(raw.git_index_time), @sizeOf(IndexTime));
                try std.testing.expectEqual(@bitSizeOf(raw.git_index_time), @bitSizeOf(IndexTime));
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
        };

        pub const ExtendedFlags = extern union {
            intent_to_add: bitjuggle.Bit(u16, 13),
            skip_worktree: bitjuggle.Bit(u16, 14),
            uptodate: bitjuggle.Bit(u16, 2),
        };

        inline fn fromC(self: anytype) *@This() {
            return @intToPtr(*@This(), @ptrToInt(self));
        }

        inline fn toC(self: anytype) *raw.git_index_entry {
            return @intToPtr(*raw.git_index_entry, @ptrToInt(self));
        }

        test {
            try std.testing.expectEqual(@sizeOf(raw.git_index_entry), @sizeOf(IndexEntry));
            try std.testing.expectEqual(@bitSizeOf(raw.git_index_entry), @bitSizeOf(IndexEntry));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    pub const IndexIterator = opaque {
        pub fn next(self: *IndexIterator) !?*const IndexEntry {
            log.debug("IndexIterator.next called", .{});

            var index_entry: [*c]const raw.git_index_entry = undefined;

            wrapCall("git_index_iterator_next", .{ &index_entry, self.toC() }) catch |err| switch (err) {
                GitError.IterOver => {
                    log.debug("end of iteration reached", .{});
                    return null;
                },
                else => return err,
            };

            const ret = IndexEntry.fromC(index_entry);

            log.debug("successfully fetched index entry: {}", .{ret});

            return ret;
        }

        pub fn deinit(self: *IndexIterator) void {
            log.debug("IndexIterator.deinit called", .{});

            raw.git_index_iterator_free(self.toC());

            log.debug("index iterator freed successfully", .{});
        }

        inline fn fromC(self: anytype) *@This() {
            return @intToPtr(*@This(), @ptrToInt(self));
        }

        inline fn toC(self: anytype) *raw.git_index_iterator {
            return @intToPtr(*raw.git_index_iterator, @ptrToInt(self));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_index {
        return @intToPtr(*raw.git_index, @ptrToInt(self));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const RefDb = opaque {
    pub fn deinit(self: *RefDb) void {
        log.debug("RefDb.deinit called", .{});

        raw.git_refdb_free(self.toC());

        log.debug("refdb freed successfully", .{});
    }

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_refdb {
        return @intToPtr(*raw.git_refdb, @ptrToInt(self));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const Config = opaque {
    pub fn deinit(self: *Config) void {
        log.debug("Config.deinit called", .{});

        raw.git_config_free(self.toC());

        log.debug("config freed successfully", .{});
    }

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_config {
        return @intToPtr(*raw.git_config, @ptrToInt(self));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const Worktree = opaque {
    pub fn deinit(self: *Worktree) void {
        log.debug("Worktree.deinit called", .{});

        raw.git_worktree_free(self.toC());

        log.debug("worktree freed successfully", .{});
    }

    pub fn repositoryOpen(self: *Worktree) !*Repository {
        log.debug("Worktree.repositoryOpen called", .{});

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_open_from_worktree", .{ &repo, self.toC() });

        log.debug("repository opened successfully", .{});

        return Repository.fromC(repo.?);
    }

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_worktree {
        return @intToPtr(*raw.git_worktree, @ptrToInt(self));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const Odb = opaque {
    pub fn deinit(self: *Odb) void {
        log.debug("Odb.deinit called", .{});

        raw.git_odb_free(self.toC());

        log.debug("Odb freed successfully", .{});
    }

    pub fn repositoryOpen(self: *Odb) !*Repository {
        log.debug("Odb.repositoryOpen called", .{});

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_wrap_odb", .{ &repo, self.toC() });

        log.debug("repository opened successfully", .{});

        return Repository.fromC(repo.?);
    }

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_odb {
        return @intToPtr(*raw.git_odb, @ptrToInt(self));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

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

        raw.git_buf_dispose(self.toC());

        log.debug("Buf freed successfully", .{});
    }

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_buf {
        return @intToPtr(*raw.git_buf, @ptrToInt(self));
    }

    test {
        try std.testing.expectEqual(@sizeOf(raw.git_buf), @sizeOf(Buf));
        try std.testing.expectEqual(@bitSizeOf(raw.git_buf), @bitSizeOf(Buf));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const GitError = error{
    /// Generic error
    GenericError,
    /// Requested object could not be found
    NotFound,
    /// Object exists preventing operation
    Exists,
    /// More than one object matches
    Ambiguous,
    /// Output buffer too short to hold data
    BufferTooShort,
    /// A special error that is never generated by libgit2 code.  You can return it from a callback (e.g to stop an iteration)
    /// to know that it was generated by the callback and not by libgit2.
    User,
    /// Operation not allowed on bare repository
    BareRepo,
    /// HEAD refers to branch with no commits
    UnbornBranch,
    /// Merge in progress prevented operation
    Unmerged,
    /// Reference was not fast-forwardable
    NonFastForwardable,
    /// Name/ref spec was not in a valid format
    InvalidSpec,
    /// Checkout conflicts prevented operation
    Conflict,
    /// Lock file prevented operation
    Locked,
    /// Reference value does not match expected
    Modifed,
    /// Authentication error
    Auth,
    /// Server certificate is invalid
    Certificate,
    /// Patch/merge has already been applied
    Applied,
    /// The requested peel operation is not possible
    Peel,
    /// Unexpected EOF
    EndOfFile,
    /// Invalid operation or input
    Invalid,
    /// Uncommitted changes in index prevented operation
    Uncommited,
    /// The operation is not valid for a directory
    Directory,
    /// A merge conflict exists and cannot continue
    MergeConflict,
    /// A user-configured callback refused to act
    Passthrough,
    /// Signals end of iteration with iterator
    IterOver,
    /// Internal only
    Retry,
    /// Hashsum mismatch in object
    Mismatch,
    /// Unsaved changes in the index would be overwritten
    IndexDirty,
    /// Patch application failed
    ApplyFail,
};

pub const DetailedError = extern struct {
    raw_message: [*:0]const u8,
    class: ErrorClass,

    pub const ErrorClass = enum(c_int) {
        NONE = 0,
        NOMEMORY,
        OS,
        INVALID,
        REFERENCE,
        ZLIB,
        REPOSITORY,
        CONFIG,
        REGEX,
        ODB,
        INDEX,
        OBJECT,
        NET,
        TAG,
        TREE,
        INDEXER,
        SSL,
        SUBMODULE,
        THREAD,
        STASH,
        CHECKOUT,
        FETCHHEAD,
        MERGE,
        SSH,
        FILTER,
        REVERT,
        CALLBACK,
        CHERRYPICK,
        DESCRIBE,
        REBASE,
        FILESYSTEM,
        PATCH,
        WORKTREE,
        SHA1,
        HTTP,
        INTERNAL,
    };

    pub fn message(self: DetailedError) [:0]const u8 {
        return std.mem.sliceTo(self.raw_message, 0);
    }

    inline fn fromC(self: anytype) *@This() {
        return @intToPtr(*@This(), @ptrToInt(self));
    }

    inline fn toC(self: anytype) *raw.git_error {
        return @intToPtr(*raw.git_error, @ptrToInt(self));
    }

    test {
        try std.testing.expectEqual(@sizeOf(raw.git_error), @sizeOf(DetailedError));
        try std.testing.expectEqual(@bitSizeOf(raw.git_error), @bitSizeOf(DetailedError));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

inline fn wrapCall(comptime name: []const u8, args: anytype) GitError!void {
    checkForError(@call(.{}, @field(raw, name), args)) catch |err| {

        // We dont want to output log messages in tests, as the error might be expected
        // also dont incur the cost of calling `getDetailedLastError` if we are not going to use it
        if (!std.builtin.is_test and @enumToInt(std.log.Level.warn) <= @enumToInt(std.log.level)) {
            if (getDetailedLastError()) |detailed| {
                log.warn(name ++ " failed with error {s}/{s} - {s}", .{
                    @errorName(err),
                    @tagName(detailed.class),
                    detailed.message(),
                });
            } else {
                log.warn(name ++ " failed with error {s}", .{@errorName(err)});
            }
        }

        return err;
    };
}

inline fn wrapCallWithReturn(
    comptime name: []const u8,
    args: anytype,
) GitError!@typeInfo(@TypeOf(@field(raw, name))).Fn.return_type.? {
    const value = @call(.{}, @field(raw, name), args);
    checkForError(value) catch |err| {

        // We dont want to output log messages in tests, as the error might be expected
        // also dont incur the cost of calling `getDetailedLastError` if we are not going to use it
        if (!std.builtin.is_test and @enumToInt(std.log.Level.warn) <= @enumToInt(std.log.level)) {
            if (getDetailedLastError()) |detailed| {
                log.warn(name ++ " failed with error {s}/{s} - {s}", .{
                    @errorName(err),
                    @tagName(detailed.class),
                    detailed.message(),
                });
            } else {
                log.warn(name ++ " failed with error {s}", .{@errorName(err)});
            }
        }
        return err;
    };
    return value;
}

fn checkForError(value: raw.git_error_code) GitError!void {
    if (value >= 0) return;
    return switch (value) {
        raw.GIT_ERROR => GitError.GenericError,
        raw.GIT_ENOTFOUND => GitError.NotFound,
        raw.GIT_EEXISTS => GitError.Exists,
        raw.GIT_EAMBIGUOUS => GitError.Ambiguous,
        raw.GIT_EBUFS => GitError.BufferTooShort,
        raw.GIT_EUSER => GitError.User,
        raw.GIT_EBAREREPO => GitError.BareRepo,
        raw.GIT_EUNBORNBRANCH => GitError.UnbornBranch,
        raw.GIT_EUNMERGED => GitError.Unmerged,
        raw.GIT_ENONFASTFORWARD => GitError.NonFastForwardable,
        raw.GIT_EINVALIDSPEC => GitError.InvalidSpec,
        raw.GIT_ECONFLICT => GitError.Conflict,
        raw.GIT_ELOCKED => GitError.Locked,
        raw.GIT_EMODIFIED => GitError.Modifed,
        raw.GIT_EAUTH => GitError.Auth,
        raw.GIT_ECERTIFICATE => GitError.Certificate,
        raw.GIT_EAPPLIED => GitError.Applied,
        raw.GIT_EPEEL => GitError.Peel,
        raw.GIT_EEOF => GitError.EndOfFile,
        raw.GIT_EINVALID => GitError.Invalid,
        raw.GIT_EUNCOMMITTED => GitError.Uncommited,
        raw.GIT_EDIRECTORY => GitError.Directory,
        raw.GIT_EMERGECONFLICT => GitError.MergeConflict,
        raw.GIT_PASSTHROUGH => GitError.Passthrough,
        raw.GIT_ITEROVER => GitError.IterOver,
        raw.GIT_RETRY => GitError.Retry,
        raw.GIT_EMISMATCH => GitError.Mismatch,
        raw.GIT_EINDEXDIRTY => GitError.IndexDirty,
        raw.GIT_EAPPLYFAIL => GitError.ApplyFail,
        else => {
            log.emerg("encountered unknown libgit2 error: {}", .{value});
            unreachable;
        },
    };
}

fn formatWithoutFields(value: anytype, options: std.fmt.FormatOptions, writer: anytype, comptime blacklist: []const []const u8) !void {
    // This ANY const is a workaround for: https://github.com/ziglang/zig/issues/7948
    const ANY = "any";

    const T = @TypeOf(value);

    switch (@typeInfo(T)) {
        .Struct => |info| {
            try writer.writeAll(@typeName(T));
            try writer.writeAll("{");
            comptime var i = 0;
            outer: inline for (info.fields) |f| {
                inline for (blacklist) |blacklist_item| {
                    if (comptime std.mem.indexOf(u8, f.name, blacklist_item) != null) continue :outer;
                }

                if (i == 0) {
                    try writer.writeAll(" .");
                } else {
                    try writer.writeAll(", .");
                }

                try writer.writeAll(f.name);
                try writer.writeAll(" = ");
                try std.fmt.formatType(@field(value, f.name), ANY, options, writer, std.fmt.default_max_depth - 1);

                i += 1;
            }
            try writer.writeAll(" }");
        },
        else => {
            @compileError("Unimplemented for: " ++ @typeName(T));
        },
    }
}

comptime {
    std.testing.refAllDecls(@This());
}
