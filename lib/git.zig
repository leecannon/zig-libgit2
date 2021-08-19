const std = @import("std");
const raw = @import("raw.zig");

const log = std.log.scoped(.git);

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
    pub fn repositoryInit(self: Handle, path: [:0]const u8, is_bare: bool) !GitRepository {
        _ = self;

        log.debug("Handle.repositoryInit called, path={s}, is_bare={}", .{ path, is_bare });

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_init", .{ &repo, path.ptr, @boolToInt(is_bare) });

        log.debug("repository created successfully", .{});

        return GitRepository{ .repo = repo.? };
    }

    /// Open a git repository.
    ///
    /// The `path` argument must point to either a git repository folder, or an existing work dir.
    ///
    /// The method will automatically detect if 'path' is a normal or bare repository or fail is `path` is neither.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    pub fn repositoryOpen(self: Handle, path: [:0]const u8) !GitRepository {
        _ = self;

        log.debug("Handle.repositoryOpen called, path={s}", .{path});

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_open", .{ &repo, path.ptr });

        log.debug("repository opened successfully", .{});

        return GitRepository{ .repo = repo.? };
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
        flags: GitRepositoryOpenExtendedFlags,
        ceiling_dirs: ?[:0]const u8,
    ) !GitRepository {
        _ = self;

        log.debug("Handle.repositoryOpenExtended called, path={s}, flags={}, ceiling_dirs={s}", .{ path, flags, ceiling_dirs });

        var repo: ?*raw.git_repository = undefined;

        const path_temp: [*c]const u8 = if (path) |slice| slice.ptr else null;
        const ceiling_dirs_temp: [*c]const u8 = if (ceiling_dirs) |slice| slice.ptr else null;
        try wrapCall("git_repository_open_ext", .{ &repo, path_temp, flags.toInt(), ceiling_dirs_temp });

        log.debug("repository opened successfully", .{});

        return GitRepository{ .repo = repo.? };
    }

    /// Options for `Handle.repositoryOpenExtended`
    pub const GitRepositoryOpenExtendedFlags = packed struct {
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

        pub fn toInt(self: GitRepositoryOpenExtendedFlags) c_uint {
            return @bitCast(c_uint, self);
        }

        pub fn format(
            value: GitRepositoryOpenExtendedFlags,
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
            try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(GitRepositoryOpenExtendedFlags));
            try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(GitRepositoryOpenExtendedFlags));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

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
    pub fn repositoryDiscover(self: Handle, start_path: [:0]const u8, across_fs: bool, ceiling_dirs: ?[:0]const u8) !GitBuf {
        _ = self;

        log.debug(
            "Handle.repositoryDiscover called, start_path={s}, across_fs={}, ceiling_dirs={s}",
            .{ start_path, across_fs, ceiling_dirs },
        );

        var git_buf = GitBuf.zero();

        const ceiling_dirs_temp: [*c]const u8 = if (ceiling_dirs) |slice| slice.ptr else null;
        try wrapCall("git_repository_discover", .{ &git_buf.buf, start_path.ptr, @boolToInt(across_fs), ceiling_dirs_temp });

        log.debug("repository discovered - {s}", .{git_buf.slice()});

        return git_buf;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Representation of an existing git repository, including all its object contents
pub const GitRepository = struct {
    repo: *raw.git_repository,

    /// Free a previously allocated repository
    ///
    /// *Note:* that after a repository is free'd, all the objects it has spawned will still exist until they are manually closed 
    /// by the user, but accessing any of the attributes of an object without a backing repository will result in undefined 
    /// behavior
    pub fn deinit(self: *GitRepository) void {
        log.debug("GitRepository.deinit called", .{});

        raw.git_repository_free(self.repo);
        self.* = undefined;

        log.debug("repository closed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Representation of a working tree
pub const GitWorktree = struct {
    worktree: *raw.git_worktree,

    /// Open working tree as a repository
    ///
    /// Open the working directory of the working tree as a normal repository that can then be worked on.
    pub fn repositoryOpen(self: GitWorktree) !GitRepository {
        log.debug("GitWorktree.repositoryOpen called", .{});

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_open_from_worktree", .{ &repo, self.worktree });

        log.debug("repository opened successfully", .{});

        return GitRepository{ .repo = repo.? };
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// An open object database handle.
pub const GitOdb = struct {
    odb: *raw.git_odb,

    /// Create a "fake" repository to wrap an object database
    ///
    /// Create a repository object to wrap an object database to be used with the API when all you have is an object database. 
    /// This doesn't have any paths associated with it, so use with care.
    pub fn repositoryOpen(self: GitOdb) !GitRepository {
        log.debug("GitOdb.repositoryOpen called", .{});

        var repo: ?*raw.git_repository = undefined;

        try wrapCall("git_repository_wrap_odb", .{ &repo, self.odb });

        log.debug("repository opened successfully", .{});

        return GitRepository{ .repo = repo.? };
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// A data buffer for exporting data from libgit2
pub const GitBuf = struct {
    buf: raw.git_buf,

    fn zero() GitBuf {
        return .{ .buf = std.mem.zeroInit(raw.git_buf, .{}) };
    }

    pub fn slice(self: GitBuf) [:0]const u8 {
        return self.buf.ptr[0..self.buf.size :0];
    }

    /// Free the memory referred to by the git_buf.
    pub fn deinit(self: *GitBuf) void {
        raw.git_buf_dispose(&self.buf);
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

inline fn wrapCall(comptime name: []const u8, args: anytype) GitError!void {
    checkForError(@call(.{}, @field(raw, name), args)) catch |err| {
        log.emerg(name ++ " failed with error {}", .{err});
        return err;
    };
}

inline fn wrapCallWithReturn(
    comptime name: []const u8,
    args: anytype,
) GitError!@typeInfo(@TypeOf(@field(raw, name))).Fn.return_type.? {
    const value = @call(.{}, @field(raw, name), args);
    checkForError(value) catch |err| {
        log.emerg(name ++ " failed with error {}", .{err});
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
