const std = @import("std");
const raw = @import("raw.zig");

const log = std.log.scoped(.git);
const old_version: bool = @import("build_options").old_version;

pub const GIT_PATH_LIST_SEPARATOR = raw.GIT_PATH_LIST_SEPARATOR;

/// Init the global state
///
/// This function must be called before any other libgit2 function in order to set up global state and threading.
///
/// This function may be called multiple times.
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
pub fn getDetailedLastError() ?DetailedError {
    return DetailedError{
        .e = raw.git_error_last() orelse return null,
    };
}

/// This type bundles all functionality that does not act on an instance of an object
pub const Handle = struct {
    /// Shutdown the global state
    /// 
    /// Clean up the global state and threading context after calling it as many times as `init` was called.
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

    /// Creates a new Git repository in the given folder.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    /// * `is_bare` - If true, a Git repository without a working directory is created at the pointed path. 
    ///               If false, provided path will be considered as the working directory into which the .git directory will be 
    ///               created.
    pub fn repositoryInit(self: Handle, path: [:0]const u8, is_bare: bool) !Repository {
        _ = self;

        log.debug("Handle.repositoryInit called, path={s}, is_bare={}", .{ path, is_bare });

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_init", .{ &repo, path.ptr, @boolToInt(is_bare) });

        log.debug("repository created successfully", .{});

        return Repository{ .repo = repo.? };
    }

    /// Create a new Git repository in the given folder with extended controls.
    ///
    /// This will initialize a new git repository (creating the repo_path if requested by flags) and working directory as needed.
    /// It will auto-detect the case sensitivity of the file system and if the file system supports file mode bits correctly.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    /// * `options` - The options to use during the creation of the repository
    pub fn repositoryInitExtended(self: Handle, path: [:0]const u8, options: RepositoryInitExtendedOptions) !Repository {
        _ = self;

        log.debug("Handle.repositoryInitExtended called, path={s}, options={}", .{ path, options });

        var opts: raw.git_repository_init_options = undefined;
        try options.toCType(&opts);

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_init_ext", .{ &repo, path.ptr, &opts });

        log.debug("repository created successfully", .{});

        return Repository{ .repo = repo.? };
    }

    pub const RepositoryInitExtendedOptions = struct {
        flags: RepositoryInitExtendedFlags = .{},
        mode: InitMode = .shared_umask,

        /// The path to the working dir or NULL for default (i.e. repo_path parent on non-bare repos). IF THIS IS RELATIVE PATH, 
        /// IT WILL BE EVALUATED RELATIVE TO THE REPO_PATH. If this is not the "natural" working directory, a .git gitlink file 
        /// will be created here linking to the repo_path.
        workdir_path: ?[:0]const u8 = null,

        /// If set, this will be used to initialize the "description" file in the repository, instead of using the template 
        /// content.
        description: ?[:0]const u8 = null,

        /// When GIT_REPOSITORY_INIT_EXTERNAL_TEMPLATE is set, this contains the path to use for the template directory. If this 
        /// is `null`, the config or default directory options will be used instead.
        template_path: ?[:0]const u8 = null,

        /// The name of the head to point HEAD at. If NULL, then this will be treated as "master" and the HEAD ref will be set to
        /// "refs/heads/master".
        /// If this begins with "refs/" it will be used verbatim; otherwise "refs/heads/" will be prefixed.
        initial_head: ?[:0]const u8 = null,

        /// If this is non-NULL, then after the rest of the repository initialization is completed, an "origin" remote will be 
        /// added pointing to this URL.
        origin_url: ?[:0]const u8 = null,

        pub const RepositoryInitExtendedFlags = packed struct {
            /// Create a bare repository with no working directory.
            bare: bool = false,

            /// Return an GIT_EEXISTS error if the repo_path appears to already be an git repository.
            no_reinit: bool = false,

            /// Normally a "/.git/" will be appended to the repo path for non-bare repos (if it is not already there), but passing 
            /// this flag prevents that behavior.
            no_dotgit_dir: bool = false,

            /// Make the repo_path (and workdir_path) as needed. Init is always willing to create the ".git" directory even without 
            /// this flag. This flag tells init to create the trailing component of the repo and workdir paths as needed.
            mkdir: bool = false,

            /// Recursively make all components of the repo and workdir paths as necessary.
            mkpath: bool = false,

            /// libgit2 normally uses internal templates to initialize a new repo. This flags enables external templates, looking the
            /// "template_path" from the options if set, or the `init.templatedir` global config if not, or falling back on 
            /// "/usr/share/git-core/templates" if it exists.
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

        fn toCType(self: RepositoryInitExtendedOptions, c_type: *raw.git_repository_init_options) !void {
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

    /// Open a git repository.
    ///
    /// The `path` argument must point to either a git repository folder, or an existing work dir.
    ///
    /// The method will automatically detect if 'path' is a normal or bare repository or fail is `path` is neither.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    pub fn repositoryOpen(self: Handle, path: [:0]const u8) !Repository {
        _ = self;

        log.debug("Handle.repositoryOpen called, path={s}", .{path});

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_open", .{ &repo, path.ptr });

        log.debug("repository opened successfully", .{});

        return Repository{ .repo = repo.? };
    }

    /// Find and open a repository with extended controls.
    ///
    /// The `path` argument must point to either a git repository folder, or an existing work dir.
    ///
    /// The method will automatically detect if 'path' is a normal or bare repository or fail is `path` is neither.
    ///
    /// *Note:* `path` can only be null if the `open_from_env` option is used.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    /// * `flags` - A combination of the GIT_REPOSITORY_OPEN flags above.
    /// * `ceiling_dirs` - A `GIT_PATH_LIST_SEPARATOR` delimited list of path prefixes at which the search for a containing
    ///                    repository should terminate. `ceiling_dirs` can be `null`.
    pub fn repositoryOpenExtended(
        self: Handle,
        path: ?[:0]const u8,
        flags: RepositoryOpenExtendedFlags,
        ceiling_dirs: ?[:0]const u8,
    ) !Repository {
        _ = self;

        log.debug("Handle.repositoryOpenExtended called, path={s}, flags={}, ceiling_dirs={s}", .{ path, flags, ceiling_dirs });

        var repo: ?*raw.git_repository = undefined;

        const path_temp: [*c]const u8 = if (path) |slice| slice.ptr else null;
        const ceiling_dirs_temp: [*c]const u8 = if (ceiling_dirs) |slice| slice.ptr else null;
        try wrapCall("git_repository_open_ext", .{ &repo, path_temp, flags.toInt(), ceiling_dirs_temp });

        log.debug("repository opened successfully", .{});

        return Repository{ .repo = repo.? };
    }

    pub const RepositoryOpenExtendedFlags = packed struct {
        /// Only open the repository if it can be immediately found in the start_path. Do not walk up from the start_path looking 
        /// at parent directories.
        no_search: bool = false,

        /// Unless this flag is set, open will not continue searching across filesystem boundaries (i.e. when `st_dev` changes 
        /// from the `stat` system call).  For example, searching in a user's home directory at "/home/user/source/" will not 
        /// return "/.git/" as the found repo if "/" is a different filesystem than "/home".
        cross_fs: bool = false,

        /// Open repository as a bare repo regardless of core.bare config, and defer loading config file for faster setup.
        /// Unlike `Handle.repositoryOpenBare`, this can follow gitlinks.
        bare: bool = false,

        /// Do not check for a repository by appending /.git to the start_path; only open the repository if start_path itself 
        /// points to the git directory.     
        no_dotgit: bool = false,

        /// Find and open a git repository, respecting the environment variables used by the git command-line tools. If set, 
        /// `Handle.repositoryOpenExtended` will ignore the other flags and the `ceiling_dirs` argument, and will allow a null 
        /// `path` to use `GIT_DIR` or search from the current directory.
        /// The search for a repository will respect $GIT_CEILING_DIRECTORIES and $GIT_DISCOVERY_ACROSS_FILESYSTEM.  The opened 
        /// repository will respect $GIT_INDEX_FILE, $GIT_NAMESPACE, $GIT_OBJECT_DIRECTORY, and $GIT_ALTERNATE_OBJECT_DIRECTORIES.
        /// In the future, this flag will also cause `Handle.repositoryOpenExtended` to respect $GIT_WORK_TREE and 
        /// $GIT_COMMON_DIR; currently, `Handle.repositoryOpenExtended` with this flag will error out if either $GIT_WORK_TREE or 
        /// $GIT_COMMON_DIR is set.
        open_from_env: bool = false,

        z_padding: std.meta.Int(.unsigned, @bitSizeOf(c_uint) - 5) = 0,

        pub fn toInt(self: RepositoryOpenExtendedFlags) c_uint {
            return @bitCast(c_uint, self);
        }

        pub fn format(
            value: RepositoryOpenExtendedFlags,
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
            try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(RepositoryOpenExtendedFlags));
            try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(RepositoryOpenExtendedFlags));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Open a bare repository on the serverside.
    ///
    /// This is a fast open for bare repositories that will come in handy if you're e.g. hosting git repositories and need to 
    /// access them efficiently
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    pub fn repositoryOpenBare(self: Handle, path: [:0]const u8) !Repository {
        _ = self;

        log.debug("Handle.repositoryOpenBare called, path={s}", .{path});

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_open_bare", .{ &repo, path.ptr });

        log.debug("repository opened successfully", .{});

        return Repository{ .repo = repo.? };
    }

    /// Look for a git repository and provide its path.
    ///
    /// The lookup start from base_path and walk across parent directories if nothing has been found. The lookup ends when the
    /// first repository is found, or when reaching a directory referenced in ceiling_dirs or when the filesystem changes 
    /// (in case across_fs is true).
    ///
    /// The method will automatically detect if the repository is bare (if there is a repository).
    ///
    /// ## Parameters
    /// * `start_path` - The base path where the lookup starts.
    /// * `across_fs` - If true, then the lookup will not stop when a filesystem device change is detected while exploring parent 
    ///                 directories.
    /// * `ceiling_dirs` - A `GIT_PATH_LIST_SEPARATOR` separated list of absolute symbolic link free paths. The lookup will stop 
    ///                    when any of this paths is reached. Note that the lookup always performs on `start_path` no matter 
    ///                    `start_path` appears in `ceiling_dirs`. `ceiling_dirs` can be `null`.
    pub fn repositoryDiscover(self: Handle, start_path: [:0]const u8, across_fs: bool, ceiling_dirs: ?[:0]const u8) !Buf {
        _ = self;

        log.debug(
            "Handle.repositoryDiscover called, start_path={s}, across_fs={}, ceiling_dirs={s}",
            .{ start_path, across_fs, ceiling_dirs },
        );

        var git_buf = Buf.zero();

        const ceiling_dirs_temp: [*c]const u8 = if (ceiling_dirs) |slice| slice.ptr else null;
        try wrapCall("git_repository_discover", .{ &git_buf.buf, start_path.ptr, @boolToInt(across_fs), ceiling_dirs_temp });

        log.debug("repository discovered - {s}", .{git_buf.slice()});

        return git_buf;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// In-memory representation of a reference.
pub const Reference = struct {
    ref: *raw.git_reference,

    /// Free the given reference.
    pub fn deinit(self: *Reference) void {
        log.debug("Reference.deinit called", .{});

        raw.git_reference_free(self.ref);
        self.* = undefined;

        log.debug("reference freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Representation of an existing git repository, including all its object contents
pub const Repository = struct {
    repo: *raw.git_repository,

    /// Free a previously allocated repository
    ///
    /// *Note:* that after a repository is free'd, all the objects it has spawned will still exist until they are manually closed 
    /// by the user, but accessing any of the attributes of an object without a backing repository will result in undefined 
    /// behavior
    pub fn deinit(self: *Repository) void {
        log.debug("Repository.deinit called", .{});

        raw.git_repository_free(self.repo);
        self.* = undefined;

        log.debug("repository closed successfully", .{});
    }

    /// These values represent possible states for the repository to be in, based on the current operation which is ongoing.
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

    /// Determines the status of a git repository - ie, whether an operation (merge, cherry-pick, etc) is in progress.
    pub fn getState(self: Repository) RepositoryState {
        log.debug("Repository.getState called", .{});

        const ret = @intToEnum(RepositoryState, raw.git_repository_state(self.repo));

        log.debug("repository state: {s}", .{@tagName(ret)});

        return ret;
    }

    /// Retrieve the configured identity to use for reflogs
    ///
    /// The memory is owned by the repository and must not be freed by the user.
    pub fn getIdentity(self: Repository) !Identity {
        log.debug("Repository.getIdentity called", .{});

        var c_name: [*c]u8 = undefined;
        var c_email: [*c]u8 = undefined;

        try wrapCall("git_repository_ident", .{ &c_name, &c_email, self.repo });

        const name: ?[:0]const u8 = if (c_name) |ptr| std.mem.sliceTo(ptr, 0) else null;
        const email: ?[:0]const u8 = if (c_email) |ptr| std.mem.sliceTo(ptr, 0) else null;

        log.debug("identity acquired: name={s}, email={s}", .{ name, email });

        return Identity{ .name = name, .email = email };
    }

    /// Set the identity to be used for writing reflogs
    ///
    /// If both are set, this name and email will be used to write to the reflog. Pass `null` to unset. When unset, the identity
    /// will be taken from the repository's configuration.
    pub fn setIdentity(self: Repository, identity: Identity) !void {
        log.debug("Repository.setIdentity called, identity.name={s}, identity.email={s}", .{ identity.name, identity.email });

        const name_temp: [*c]const u8 = if (identity.name) |slice| slice.ptr else null;
        const email_temp: [*c]const u8 = if (identity.email) |slice| slice.ptr else null;
        try wrapCall("git_repository_set_ident", .{ self.repo, name_temp, email_temp });

        log.debug("successfully set identity", .{});
    }

    /// Get the currently active namespace for this repository
    pub fn getNamespace(self: Repository) !?[:0]const u8 {
        log.debug("Repository.getNamespace called", .{});

        const ret = raw.git_repository_get_namespace(self.repo);

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
    /// This namespace affects all reference operations for the repo.
    /// See `man gitnamespaces`
    /// ## Parameters
    /// * `namespace` - The namespace. This should not include the refs folder, e.g. to namespace all references under 
    ///                 "refs/namespaces/foo/", use "foo" as the namespace.
    pub fn setNamespace(self: *Repository, namespace: [:0]const u8) !void {
        log.debug("Repository.setNamespace called, namespace={s}", .{namespace});

        try wrapCall("git_repository_set_namespace", .{ self.repo, namespace.ptr });

        log.debug("successfully set namespace", .{});
    }

    /// Check if a repository's HEAD is detached
    ///
    /// A repository's HEAD is detached when it points directly to a commit instead of a branch.
    pub fn isHeadDetached(self: Repository) !bool {
        log.debug("Repository.isHeadDetached called", .{});

        const ret = (try wrapCallWithReturn("git_repository_head_detached", .{self.repo})) == 1;

        log.debug("is head detached: {}", .{ret});

        return ret;
    }

    /// Retrieve and resolve the reference pointed at by HEAD.
    pub fn getHead(self: Repository) !Reference {
        log.debug("Repository.head called", .{});

        var ref: ?*raw.git_reference = undefined;

        try wrapCall("git_repository_head", .{ &ref, self.repo });

        log.debug("reference opened successfully", .{});

        return Reference{ .ref = ref.? };
    }

    /// Make the repository HEAD point to the specified reference.
    ///
    /// If the provided reference points to a Tree or a Blob, the HEAD is unaltered and -1 is returned.
    ///
    /// If the provided reference points to a branch, the HEAD will point to that branch, staying attached, or become attached if
    /// it isn't yet.
    /// If the branch doesn't exist yet, no error will be return. The HEAD will then be attached to an unborn branch.
    ///
    /// Otherwise, the HEAD will be detached and will directly point to the Commit.
    ///
    /// ## Parameters
    /// * `ref_name` - Canonical name of the reference the HEAD should point at
    pub fn setHead(self: *Repository, ref_name: [:0]const u8) !void {
        log.debug("Repository.setHead called, workdir={s}", .{ref_name});

        try wrapCall("git_repository_set_head", .{ self.repo, ref_name.ptr });

        log.debug("successfully set head", .{});
    }

    /// Make the repository HEAD directly point to the Commit.
    ///
    /// If the provided committish cannot be found in the repository, the HEAD is unaltered and GIT_ENOTFOUND is returned.
    ///
    /// If the provided commitish cannot be peeled into a commit, the HEAD is unaltered and -1 is returned.
    ///
    /// Otherwise, the HEAD will eventually be detached and will directly point to the peeled Commit.
    ///
    /// ## Parameters
    /// * `commitish` - Object id of the Commit the HEAD should point to
    pub fn setHeadDetached(self: *Repository, commitish: Oid) !void {
        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const slice = try commitish.formatHex(&buf);
            log.debug("Repository.setHeadDetached called, commitish={s}", .{slice});
        }

        try wrapCall("git_repository_set_head_detached", .{ self.repo, commitish.oid });

        log.debug("successfully set head", .{});
    }

    /// Make the repository HEAD directly point to the Commit.
    ///
    /// This behaves like `Repository.setHeadDetached` but takes an annotated commit, which lets you specify which 
    /// extended sha syntax string was specified by a user, allowing for more exact reflog messages.
    ///
    /// See the documentation for `Repository.setHeadDetached`.
    pub fn setHeadDetachedFromAnnotated(self: *Repository, commitish: AnnotatedCommit) !void {
        log.debug("Repository.setHeadDetachedFromAnnotated called", .{});

        try wrapCall("git_repository_set_head_detached_from_annotated", .{ self.repo, commitish.commit });

        log.debug("successfully set head", .{});
    }

    /// Detach the HEAD.
    ///
    /// If the HEAD is already detached and points to a Commit, 0 is returned.
    ///
    /// If the HEAD is already detached and points to a Tag, the HEAD is updated into making it point to the peeled Commit, and 0
    /// is returned.
    ///
    /// If the HEAD is already detached and points to a non commitish, the HEAD is unaltered, and -1 is returned.
    ///
    /// Otherwise, the HEAD will be detached and point to the peeled Commit.
    pub fn detachHead(self: *Repository) !void {
        log.debug("Repository.detachHead called", .{});

        try wrapCall("git_repository_detach_head", .{self.repo});

        log.debug("successfully detached the head", .{});
    }

    /// Check if a worktree's HEAD is detached
    ///
    /// A worktree's HEAD is detached when it points directly to a commit instead of a branch.
    ///
    /// ## Parameters
    /// * `name` - name of the worktree to retrieve HEAD for
    pub fn isHeadForWorktreeDetached(self: Repository, name: [:0]const u8) !bool {
        log.debug("Repository.isHeadForWorktreeDetached called, name={s}", .{name});

        const ret = (try wrapCallWithReturn(
            "git_repository_head_detached_for_worktree",
            .{ self.repo, name.ptr },
        )) == 1;

        log.debug("head for worktree {s} is detached: {}", .{ name, ret });

        return ret;
    }

    /// Retrieve the referenced HEAD for the worktree
    ///
    /// ## Parameters
    /// * `name` - name of the worktree to retrieve HEAD for
    pub fn headForWorktree(self: Repository, name: [:0]const u8) !Reference {
        log.debug("Repository.headForWorktree called, name={s}", .{name});

        var ref: ?*raw.git_reference = undefined;

        try wrapCall("git_repository_head_for_worktree", .{ &ref, self.repo, name.ptr });

        log.debug("reference opened successfully", .{});

        return Reference{ .ref = ref.? };
    }

    /// Check if the current branch is unborn
    ///
    /// An unborn branch is one named from HEAD but which doesn't exist in the refs namespace, because it doesn't have any commit
    /// to point to.
    pub fn isHeadUnborn(self: Repository) !bool {
        log.debug("Repository.isHeadUnborn called", .{});

        const ret = (try wrapCallWithReturn("git_repository_head_unborn", .{self.repo})) == 1;

        log.debug("is head unborn: {}", .{ret});

        return ret;
    }

    /// Determine if the repository was a shallow clone
    pub fn isShallow(self: Repository) bool {
        log.debug("Repository.isShallow called", .{});

        const ret = raw.git_repository_is_shallow(self.repo) == 1;

        log.debug("is repository a shallow clone: {}", .{ret});

        return ret;
    }

    /// Check if a repository is empty
    ///
    /// An empty repository has just been initialized and contains no references apart from HEAD, which must be pointing to the
    /// unborn master branch.
    pub fn isEmpty(self: Repository) !bool {
        log.debug("Repository.isEmpty called", .{});

        const ret = (try wrapCallWithReturn("git_repository_is_empty", .{self.repo})) == 1;

        log.debug("is repository empty: {}", .{ret});

        return ret;
    }

    /// Check if a repository is bare
    pub fn isBare(self: Repository) bool {
        log.debug("Repository.isBare called", .{});

        const ret = raw.git_repository_is_bare(self.repo) == 1;

        log.debug("is repository bare: {}", .{ret});

        return ret;
    }

    /// Check if a repository is a linked work tree
    pub fn isWorktree(self: Repository) bool {
        log.debug("Repository.isWorktree called", .{});

        const ret = raw.git_repository_is_worktree(self.repo) == 1;

        log.debug("is repository worktree: {}", .{ret});

        return ret;
    }

    /// Get the location of a specific repository file or directory
    ///
    /// This function will retrieve the path of a specific repository item. It will thereby honor things like the repository's
    /// common directory, gitdir, etc. In case a file path cannot exist for a given item (e.g. the working directory of a bare
    /// repository), `NOTFOUND` is returned.
    pub fn getItemPath(self: Repository, item: RepositoryItem) !Buf {
        log.debug("Repository.itemPath called, item={s}", .{item});

        var buf = Buf.zero();

        try wrapCall("git_repository_item_path", .{ &buf.buf, self.repo, @enumToInt(item) });

        log.debug("item path: {s}", .{buf.slice()});

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

    /// Get the path of this repository
    ///
    /// This is the path of the `.git` folder for normal repositories, or of the repository itself for bare repositories.
    pub fn getPath(self: Repository) [:0]const u8 {
        log.debug("Repository.path called", .{});

        const slice = std.mem.sliceTo(raw.git_repository_path(self.repo), 0);

        log.debug("path: {s}", .{slice});

        return slice;
    }

    /// Get the path of the working directory for this repository
    ///
    /// If the repository is bare, this function will always return `null`.
    pub fn getWorkdir(self: Repository) ?[:0]const u8 {
        log.debug("Repository.workdir called", .{});

        if (raw.git_repository_workdir(self.repo)) |ret| {
            const slice = std.mem.sliceTo(ret, 0);

            log.debug("workdir: {s}", .{slice});

            return slice;
        }

        log.debug("no workdir", .{});

        return null;
    }

    /// Set the path to the working directory for this repository
    pub fn setWorkdir(self: *Repository, workdir: [:0]const u8, update_gitlink: bool) !void {
        log.debug("Repository.setWorkdir called, workdir={s}, update_gitlink={}", .{ workdir, update_gitlink });

        try wrapCall("git_repository_set_workdir", .{ self.repo, workdir.ptr, @boolToInt(update_gitlink) });

        log.debug("successfully set workdir", .{});
    }

    /// Get the path of the shared common directory for this repository.
    ///
    /// If the repository is bare, it is the root directory for the repository. If the repository is a worktree, it is the parent 
    /// repo's gitdir. Otherwise, it is the gitdir.
    pub fn getCommondir(self: Repository) ?[:0]const u8 {
        log.debug("Repository.commondir called", .{});

        if (raw.git_repository_commondir(self.repo)) |ret| {
            const slice = std.mem.sliceTo(ret, 0);

            log.debug("commondir: {s}", .{slice});

            return slice;
        }

        log.debug("no commondir", .{});

        return null;
    }

    /// Get the configuration file for this repository.
    ///
    /// If a configuration file has not been set, the default config set for the repository will be returned, including global 
    /// and system configurations (if they are available). The configuration file must be freed once it's no longer being used by
    /// the user.
    pub fn getConfig(self: Repository) !Config {
        log.debug("Repository.getConfig called", .{});

        var config: ?*raw.git_config = undefined;

        try wrapCall("git_repository_config", .{ &config, self.repo });

        log.debug("repository config acquired successfully", .{});

        return Config{ .config = config.? };
    }

    /// Get a snapshot of the repository's configuration
    ///
    /// Convenience function to take a snapshot from the repository's configuration. The contents of this snapshot will not 
    /// change, even if the underlying config files are modified.
    ///
    /// The configuration file must be freed once it's no longer being used by the user.
    pub fn getConfigSnapshot(self: Repository) !Config {
        log.debug("Repository.getConfigSnapshot called", .{});

        var config: ?*raw.git_config = undefined;

        try wrapCall("git_repository_config_snapshot", .{ &config, self.repo });

        log.debug("repository config acquired successfully", .{});

        return Config{ .config = config.? };
    }

    /// Get the Object Database for this repository.
    ///
    /// If a custom ODB has not been set, the default database for the repository will be returned (the one located in 
    /// `.git/objects`).
    ///
    /// The ODB must be freed once it's no longer being used by the user.
    pub fn getOdb(self: Repository) !Odb {
        log.debug("Repository.getOdb called", .{});

        var odb: ?*raw.git_odb = undefined;

        try wrapCall("git_repository_odb", .{ &odb, self.repo });

        log.debug("repository odb acquired successfully", .{});

        return Odb{ .odb = odb.? };
    }

    /// Get the Reference Database Backend for this repository.
    ///
    /// If a custom refsdb has not been set, the default database for the repository will be returned (the one that manipulates
    /// loose and packed references in the `.git` directory).
    /// 
    /// The refdb must be freed once it's no longer being used by the user.
    pub fn getRefDb(self: Repository) !RefDb {
        log.debug("Repository.getRefDb called", .{});

        var ref_db: ?*raw.git_refdb = undefined;

        try wrapCall("git_repository_refdb", .{ &ref_db, self.repo });

        log.debug("repository refdb acquired successfully", .{});

        return RefDb{ .ref_db = ref_db.? };
    }

    /// Get the Reference Database Backend for this repository.
    ///
    /// If a custom refsdb has not been set, the default database for the repository will be returned (the one that manipulates
    /// loose and packed references in the `.git` directory).
    /// 
    /// The refdb must be freed once it's no longer being used by the user.
    pub fn getIndex(self: Repository) !Index {
        log.debug("Repository.getIndex called", .{});

        var index: ?*raw.git_index = undefined;

        try wrapCall("git_repository_index", .{ &index, self.repo });

        log.debug("repository index acquired successfully", .{});

        return Index{ .index = index.? };
    }

    /// Retrieve git's prepared message
    ///
    /// Operations such as git revert/cherry-pick/merge with the -n option stop just short of creating a commit with the changes 
    /// and save their prepared message in .git/MERGE_MSG so the next git-commit execution can present it to the user for them to
    /// amend if they wish.
    ///
    /// Use this function to get the contents of this file. Don't forget to remove the file after you create the commit.
    pub fn getPreparedMessage(self: Repository) !Buf {
        // TODO: Change this function and others to return null instead of `GitError.NotFound`

        log.debug("Repository.getPreparedMessage called", .{});

        var buf = Buf.zero();

        try wrapCall("git_repository_message", .{ &buf.buf, self.repo });

        log.debug("prepared message: {s}", .{buf.slice()});

        return buf;
    }

    /// Remove git's prepared message.
    ///
    /// Remove the message that `getPreparedMessage` retrieves.
    pub fn removePreparedMessage(self: *Repository) !void {
        log.debug("Repository.removePreparedMessage called", .{});

        try wrapCall("git_repository_message_remove", .{self.repo});

        log.debug("successfully removed prepared message", .{});
    }

    /// Remove all the metadata associated with an ongoing command like merge, revert, cherry-pick, etc.
    /// For example: MERGE_HEAD, MERGE_MSG, etc.
    pub fn stateCleanup(self: *Repository) !void {
        log.debug("Repository.stateCleanup called", .{});

        try wrapCall("git_repository_state_cleanup", .{self.repo});

        log.debug("successfully cleaned state", .{});
    }

    /// Invoke `callback_fn` for each entry in the given FETCH_HEAD file.
    ///
    /// Return a non-zero value from the callback to stop the loop.
    ///
    /// ## Parameters
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `ref_name` - The reference name
    /// * `remote_url` - The remote URL
    /// * `oid` - The reference target OID
    /// * `is_merge` - Was the reference the result of a merge
    pub fn foreachFetchHead(
        self: Repository,
        comptime callback_fn: fn (
            ref_name: [:0]const u8,
            remote_url: [:0]const u8,
            oid: Oid,
            is_merge: bool,
        ) c_int,
    ) !c_int {
        const cb = struct {
            pub fn cb(
                ref_name: [:0]const u8,
                remote_url: [:0]const u8,
                oid: Oid,
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
    /// Return a non-zero value from the callback to stop the loop.
    ///
    /// ## Parameters
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `ref_name` - The reference name
    /// * `remote_url` - The remote URL
    /// * `oid` - The reference target OID
    /// * `is_merge` - Was the reference the result of a merge
    /// * `user_data_ptr` - pointer to user data
    pub fn foreachFetchHeadWithUserData(
        self: Repository,
        user_data: anytype,
        comptime callback_fn: fn (
            ref_name: [:0]const u8,
            remote_url: [:0]const u8,
            oid: Oid,
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
                    Oid{ .oid = c_oid.? },
                    c_is_merge == 1,
                    @ptrCast(UserDataType, payload),
                );
            }
        }.cb;

        log.debug("Repository.foreachFetchHeadWithUserData called", .{});

        const ret = try wrapCallWithReturn("git_repository_fetchhead_foreach", .{ self.repo, cb, user_data });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    /// If a merge is in progress, invoke 'callback' for each commit ID in the MERGE_HEAD file.
    ///
    /// Return a non-zero value from the callback to stop the loop.
    ///
    /// ## Parameters
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `oid` - The merge OID
    pub fn foreachMergeHead(
        self: Repository,
        comptime callback_fn: fn (oid: Oid) c_int,
    ) !c_int {
        const cb = struct {
            pub fn cb(oid: Oid, _: *u8) c_int {
                return callback_fn(oid);
            }
        }.cb;

        var dummy_data: u8 = undefined;
        return self.foreachMergeHeadWithUserData(&dummy_data, cb);
    }

    /// If a merge is in progress, invoke 'callback' for each commit ID in the MERGE_HEAD file.
    ///
    /// Return a non-zero value from the callback to stop the loop.
    ///
    /// ## Parameters
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `oid` - The merge OID
    /// * `user_data_ptr` - pointer to user data
    pub fn foreachMergeHeadWithUserData(
        self: Repository,
        user_data: anytype,
        comptime callback_fn: fn (
            oid: Oid,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !c_int {
        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(c_oid: [*c]const raw.git_oid, payload: ?*c_void) callconv(.C) c_int {
                return callback_fn(Oid{ .oid = c_oid.? }, @ptrCast(UserDataType, payload));
            }
        }.cb;

        log.debug("Repository.foreachMergeHeadWithUserData called", .{});

        const ret = try wrapCallWithReturn("git_repository_mergehead_foreach", .{ self.repo, cb, user_data });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    /// Calculate hash of file using repository filtering rules.
    ///
    /// If you simply want to calculate the hash of a file on disk with no filters, you can just use the `Odb.hashFile` API.
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
    pub fn hashFile(self: Repository, path: [:0]const u8, object_type: ObjectType, as_path: ?[:0]const u8) !Oid {
        log.debug("Repository.hashFile called, path={s}, object_type={}, as_path={s}", .{ path, object_type, as_path });

        var oid: ?*raw.git_oid = undefined;

        const as_path_temp: [*c]const u8 = if (as_path) |slice| slice.ptr else null;
        try wrapCall("git_repository_hashfile", .{ oid, self.repo, path.ptr, @enumToInt(object_type), as_path_temp });

        const ret = Oid{ .oid = oid.? };

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
    /// This tries to get status for the filename that you give.  If no files match that name (in either the HEAD, index, or
    /// working directory), this returns GIT_ENOTFOUND.
    ///
    /// If the name matches multiple files (for example, if the `path` names a directory or if running on a case- insensitive
    /// filesystem and yet the HEAD has two entries that both match the path), then this returns GIT_EAMBIGUOUS because it cannot
    /// give correct results.
    ///
    /// This does not do any sort of rename detection.  Renames require a set of targets and because of the path filtering, there
    /// is not enough information to check renames correctly.  To check file status with rename detection, there is no choice but
    /// to do a full `git_status_list_new` and scan through looking for the path that you are interested in.
    pub fn fileStatus(self: Repository, path: [:0]const u8) !FileStatus {
        log.debug("Repository.fileStatus called, path={s}", .{path});

        var flags: c_uint = undefined;

        try wrapCall("git_status_file", .{ &flags, self.repo, path.ptr });

        const ret = @bitCast(FileStatus, flags);

        log.debug("file status: {}", .{ret});

        return ret;
    }

    /// Gather file statuses and run a callback for each one.
    ///
    /// If the callback returns a non-zero value, this function will stop looping and return that value to caller.
    ///
    /// ## Parameters
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `path` - The file path
    /// * `status` - The status of the file
    pub fn foreachFileStatus(
        self: Repository,
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
    /// If the callback returns a non-zero value, this function will stop looping and return that value to caller.
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
        self: Repository,
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

        const ret = try wrapCallWithReturn("git_status_foreach", .{ self.repo, cb, user_data });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    /// Gather file status information and run callbacks as requested.
    ///
    /// This is an extended version of the `foreachFileStatus` API that allows for more granular control over which paths will be
    /// processed and in what order. See the `ForeachFileStatusExtendedOptions` structure for details about the additional 
    /// controls that this makes available.
    ///
    /// Note that if a `pathspec` is given in the `ForeachFileStatusExtendedOptions` to filter the status, then the results from
    /// rename detection (if you enable it) may not be accurate. To do rename detection properly, this must be called with no
    /// `pathspec` so that all files can be considered.
    ///
    /// ## Parameters
    /// * `options` - callback options
    /// * `callback_fn` - the callback function
    ///
    /// ## Callback Parameters
    /// * `path` - The file path
    /// * `status` - The status of the file
    pub fn foreachFileStatusExtended(
        self: Repository,
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
    /// This is an extended version of the `foreachFileStatus` API that allows for more granular control over which paths will be
    /// processed and in what order. See the `ForeachFileStatusExtendedOptions` structure for details about the additional 
    /// controls that this makes available.
    ///
    /// Note that if a `pathspec` is given in the `ForeachFileStatusExtendedOptions` to filter the status, then the results from
    /// rename detection (if you enable it) may not be accurate. To do rename detection properly, this must be called with no
    /// `pathspec` so that all files can be considered.
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
        self: Repository,
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

        const ret = try wrapCallWithReturn("git_status_foreach_ext", .{ self.repo, &opts, cb, user_data });

        log.debug("callback returned: {}", .{ret});

        return ret;
    }

    pub const FileStatusOptions = struct {
        /// which files to scan and in what order
        show: Show = .INDEX_AND_WORKDIR,

        /// Flags to control status callbacks
        options: Options = .{},

        /// The `pathspec` is an array of path patterns to match (using fnmatch-style matching), or just an array of paths to 
        /// match exactly if `Options.DISABLE_PATHSPEC_MATCH` is specified in the flags.
        pathspec: [][:0]const u8 = &[_][:0]const u8{},

        /// The `baseline` is the tree to be used for comparison to the working directory and index; defaults to HEAD.
        baseline: ?Tree = null,

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
        /// `INCLUDE_UNTRACKED`, and `RECURSE_UNTRACKED_DIRS`. Those options are bundled together as `Options.DEFAULTS` if
        /// you want them as a baseline.
        pub const Options = packed struct {
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

            pub const DEFAULT: Options = blk: {
                var opt = Options{};
                opt.INCLUDE_IGNORED = true;
                opt.INCLUDE_UNTRACKED = true;
                opt.RECURSE_UNTRACKED_DIRS = true;
                break :blk opt;
            };

            pub fn format(
                value: Options,
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
                try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(Options));
                try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(Options));
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
            c_type.flags = @bitCast(c_int, self.options);
            c_type.pathspec = .{
                .strings = @intToPtr([*c][*c]u8, @ptrToInt(self.pathspec.ptr)),
                .count = self.pathspec.len,
            };
            c_type.baseline = if (self.baseline) |tree| tree.tree else null;
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Gather file status information and populate a `StatusList`.
    ///
    /// Note that if a `pathspec` is given in the `git_status_options` to filter the status, then the results from rename
    /// detection (if you enable it) may not be accurate. To do rename detection properly, this must be called with no `pathspec`
    /// so that all files can be considered.
    ///
    /// ## Parameters
    /// * `options` - options regarding which files to get the status of
    pub fn getStatusList(self: Repository, options: FileStatusOptions) !StatusList {
        log.debug("Repository.getStatusList called, options={}", .{options});

        var opts: raw.git_status_options = undefined;
        try options.toCType(&opts);

        var status_list: ?*raw.git_status_list = undefined;
        try wrapCall("git_status_list_new", .{ &status_list, self.repo, &opts });

        log.debug("successfully fetched status list", .{});

        return StatusList{ .status_list = status_list.? };
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Representation of a status collection
pub const StatusList = struct {
    status_list: *raw.git_status_list,

    /// Free an existing status list
    pub fn deinit(self: *StatusList) void {
        log.debug("StatusList.deinit called", .{});

        raw.git_status_list_free(self.status_list);
        self.* = undefined;

        log.debug("status list freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Representation of a tree object.
pub const Tree = struct {
    tree: *raw.git_tree,

    /// Close an open tree
    pub fn deinit(self: *Tree) void {
        log.debug("Tree.deinit called", .{});

        raw.git_tree_free(self.tree);
        self.* = undefined;

        log.debug("tree freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Status flags for a single file
///
/// A combination of these values will be returned to indicate the status of a file.  Status compares the working directory, the
/// index, and the current HEAD of the repository.  
/// The `INDEX` set of flags represents the status of file in the  index relative to the HEAD, and the `WT` set of flags represent
/// the status of the file in the working directory relative to the index.
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

/// Annotated commits, the input to merge and rebase.
pub const AnnotatedCommit = struct {
    commit: *raw.git_annotated_commit,

    /// Free the annotated commit
    pub fn deinit(self: *AnnotatedCommit) void {
        log.debug("AnnotatedCommit.deinit called", .{});

        raw.git_annotated_commit_free(self.commit);
        self.* = undefined;

        log.debug("annotated commit freed successfully", .{});
    }

    /// Gets the commit ID that the given `AnnotatedCommit` refers to.
    pub fn getCommitId(self: AnnotatedCommit) !Oid {
        log.debug("AnnotatedCommit.getCommitId called", .{});

        const oid = Oid{ .oid = raw.git_annotated_commit_ref(self.commit).? };

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const slice = try oid.formatHex(&buf);
            log.debug("annotated commit id acquired: {s}", .{slice});
        }

        return oid;
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
pub const Oid = struct {
    oid: *const raw.git_oid,

    /// Size (in bytes) of a hex formatted oid
    pub const HEX_BUFFER_SIZE = raw.GIT_OID_HEXSZ;

    /// Format a git_oid into a hex string.
    ///
    /// ## Parameters
    /// * `buf` - Slice to format the oid into, must be atleast `HEX_BUFFER_SIZE` long.
    pub fn formatHex(self: Oid, buf: []u8) ![]const u8 {
        if (buf.len < HEX_BUFFER_SIZE) return error.BufferTooShort;

        try wrapCall("git_oid_fmt", .{ buf.ptr, self.oid });

        return buf[0..HEX_BUFFER_SIZE];
    }

    /// Format a git_oid into a zero-terminated hex string.
    ///
    /// ## Parameters
    /// * `buf` - Slice to format the oid into, must be atleast `HEX_BUFFER_SIZE` + 1 long.
    pub fn formatHexZ(self: Oid, buf: []u8) ![:0]const u8 {
        if (buf.len < (HEX_BUFFER_SIZE + 1)) return error.BufferTooShort;

        try wrapCall("git_oid_fmt", .{ buf.ptr, self.oid });
        buf[HEX_BUFFER_SIZE] = 0;

        return buf[0..HEX_BUFFER_SIZE :0];
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Memory representation of an index file.
pub const Index = struct {
    index: *raw.git_index,

    /// Free an existing index object.
    pub fn deinit(self: *Index) void {
        log.debug("Index.deinit called", .{});

        raw.git_index_free(self.index);
        self.* = undefined;

        log.debug("index freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// An open refs database handle.
pub const RefDb = struct {
    ref_db: *raw.git_refdb,

    /// Free the configuration and its associated memory and files
    pub fn deinit(self: *RefDb) void {
        log.debug("RefDb.deinit called", .{});

        raw.git_refdb_free(self.ref_db);
        self.* = undefined;

        log.debug("refdb freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Memory representation of a set of config files
pub const Config = struct {
    config: *raw.git_config,

    /// Free the configuration and its associated memory and files
    pub fn deinit(self: *Config) void {
        log.debug("Config.deinit called", .{});

        raw.git_config_free(self.config);
        self.* = undefined;

        log.debug("config freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Representation of a working tree
pub const Worktree = struct {
    worktree: *raw.git_worktree,

    /// Free a previously allocated worktree
    pub fn deinit(self: *Worktree) void {
        log.debug("Worktree.deinit called", .{});

        raw.git_worktree_free(self.worktree);
        self.* = undefined;

        log.debug("worktree freed successfully", .{});
    }

    /// Open working tree as a repository
    ///
    /// Open the working directory of the working tree as a normal repository that can then be worked on.
    pub fn repositoryOpen(self: Worktree) !Repository {
        log.debug("Worktree.repositoryOpen called", .{});

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_open_from_worktree", .{ &repo, self.worktree });

        log.debug("repository opened successfully", .{});

        return Repository{ .repo = repo.? };
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// An open object database handle.
pub const Odb = struct {
    odb: *raw.git_odb,

    /// Close an open object database.
    pub fn deinit(self: *Odb) void {
        log.debug("Odb.deinit called", .{});

        raw.git_odb_free(self.odb);
        self.* = undefined;

        log.debug("Odb freed successfully", .{});
    }

    /// Create a "fake" repository to wrap an object database
    ///
    /// Create a repository object to wrap an object database to be used with the API when all you have is an object database. 
    /// This doesn't have any paths associated with it, so use with care.
    pub fn repositoryOpen(self: Odb) !Repository {
        log.debug("Odb.repositoryOpen called", .{});

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_wrap_odb", .{ &repo, self.odb });

        log.debug("repository opened successfully", .{});

        return Repository{ .repo = repo.? };
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// A data buffer for exporting data from libgit2
pub const Buf = struct {
    buf: raw.git_buf,

    fn zero() Buf {
        return .{ .buf = std.mem.zeroInit(raw.git_buf, .{}) };
    }

    pub fn slice(self: Buf) [:0]const u8 {
        return self.buf.ptr[0..self.buf.size :0];
    }

    /// Free the memory referred to by the Buf.
    pub fn deinit(self: *Buf) void {
        log.debug("Buf.deinit called", .{});

        raw.git_buf_dispose(&self.buf);
        self.* = undefined;

        log.debug("Buf freed successfully", .{});
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

pub const DetailedError = struct {
    e: *const raw.git_error,

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
        return std.mem.sliceTo(self.e.message, 0);
    }

    pub fn errorClass(self: DetailedError) ErrorClass {
        return @intToEnum(ErrorClass, self.e.klass);
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
                    @tagName(detailed.errorClass()),
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
                    @tagName(detailed.errorClass()),
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
