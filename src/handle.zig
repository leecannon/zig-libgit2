//! This type bundles all functionality that does not act on an instance of an object

const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);
const old_version: bool = @import("build_options").old_version;
const git = @import("git.zig");

pub const Handle = struct {

    /// De-initialize the libraries global state.
    /// *NOTE*: should be called as many times as `init` was called.
    pub fn deinit(self: Handle) void {
        _ = self;

        log.debug("Handle.deinit called", .{});

        const number = internal.wrapCallWithReturn("git_libgit2_shutdown", .{}) catch unreachable;

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
    pub fn indexOpen(self: Handle, path: [:0]const u8) !*git.Index {
        _ = self;

        log.debug("Handle.indexOpen called, path={s}", .{path});

        var index: ?*raw.git_index = undefined;

        try internal.wrapCall("git_index_open", .{ &index, path.ptr });

        log.debug("index opened successfully", .{});

        return internal.fromC(index.?);
    }

    /// Create an in-memory index object.
    ///
    /// This index object cannot be read/written to the filesystem, but may be used to perform in-memory index operations.
    pub fn indexNew(self: Handle) !*git.Index {
        _ = self;

        log.debug("Handle.indexInit called", .{});

        var index: ?*raw.git_index = undefined;

        try internal.wrapCall("git_index_new", .{&index});

        log.debug("index created successfully", .{});

        return internal.fromC(index.?);
    }

    /// Create a new repository in the given directory.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    /// * `is_bare` - If true, a Git repository without a working directory is created at the pointed path. 
    ///               If false, provided path will be considered as the working directory into which the .git directory will be 
    ///               created.
    pub fn repositoryInit(self: Handle, path: [:0]const u8, is_bare: bool) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryInit called, path={s}, is_bare={}", .{ path, is_bare });

        var repo: ?*raw.git_repository = undefined;

        try internal.wrapCall("git_repository_init", .{ &repo, path.ptr, @boolToInt(is_bare) });

        log.debug("repository created successfully", .{});

        return internal.fromC(repo.?);
    }

    /// Create a new repository in the given directory with extended options.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    /// * `options` - The options to use during the creation of the repository
    pub fn repositoryInitExtended(self: Handle, path: [:0]const u8, options: RepositoryInitOptions) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryInitExtended called, path={s}, options={}", .{ path, options });

        var opts: raw.git_repository_init_options = undefined;
        try options.toCType(&opts);

        var repo: ?*raw.git_repository = undefined;

        try internal.wrapCall("git_repository_init_ext", .{ &repo, path.ptr, &opts });

        log.debug("repository created successfully", .{});

        return internal.fromC(repo.?);
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
                return internal.formatWithoutFields(
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
                try internal.wrapCall("git_repository_init_init_options", .{ c_type, raw.GIT_REPOSITORY_INIT_OPTIONS_VERSION });
            } else {
                try internal.wrapCall("git_repository_init_options_init", .{ c_type, raw.GIT_REPOSITORY_INIT_OPTIONS_VERSION });
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

    /// Open a repository.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    pub fn repositoryOpen(self: Handle, path: [:0]const u8) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryOpen called, path={s}", .{path});

        var repo: ?*raw.git_repository = undefined;

        try internal.wrapCall("git_repository_open", .{ &repo, path.ptr });

        log.debug("repository opened successfully", .{});

        return internal.fromC(repo.?);
    }

    /// Find and open a repository with extended options.
    ///
    /// *NOTE*: `path` can only be null if the `open_from_env` option is used.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    /// * `flags` - options controlling how the repository is opened
    /// * `ceiling_dirs` - A `PATH_LIST_SEPARATOR` delimited list of path prefixes at which the search for a containing
    ///                    repository should terminate.
    pub fn repositoryOpenExtended(
        self: Handle,
        path: ?[:0]const u8,
        flags: RepositoryOpenOptions,
        ceiling_dirs: ?[:0]const u8,
    ) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryOpenExtended called, path={s}, flags={}, ceiling_dirs={s}", .{ path, flags, ceiling_dirs });

        var repo: ?*raw.git_repository = undefined;

        const path_temp: [*c]const u8 = if (path) |slice| slice.ptr else null;
        const ceiling_dirs_temp: [*c]const u8 = if (ceiling_dirs) |slice| slice.ptr else null;
        try internal.wrapCall("git_repository_open_ext", .{ &repo, path_temp, flags.toInt(), ceiling_dirs_temp });

        log.debug("repository opened successfully", .{});

        return internal.fromC(repo.?);
    }

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
            return internal.formatWithoutFields(
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

    /// Open a bare repository.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    pub fn repositoryOpenBare(self: Handle, path: [:0]const u8) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryOpenBare called, path={s}", .{path});

        var repo: ?*raw.git_repository = undefined;

        try internal.wrapCall("git_repository_open_bare", .{ &repo, path.ptr });

        log.debug("repository opened successfully", .{});

        return internal.fromC(repo.?);
    }

    /// Look for a git repository and return its path.
    ///
    /// The lookup starts from `start_path` and walks the directory tree until the first repository is found, or when reaching a
    /// directory referenced in `ceiling_dirs` or when the filesystem changes (when `across_fs` is false).
    ///
    /// ## Parameters
    /// * `start_path` - The path where the lookup starts.
    /// * `across_fs` - If true, then the lookup will not stop when a filesystem device change is encountered.
    /// * `ceiling_dirs` - A `PATH_LIST_SEPARATOR` separated list of absolute symbolic link free paths. The lookup will stop 
    ///                    when any of this paths is reached.
    pub fn repositoryDiscover(self: Handle, start_path: [:0]const u8, across_fs: bool, ceiling_dirs: ?[:0]const u8) !git.Buf {
        _ = self;

        log.debug(
            "Handle.repositoryDiscover called, start_path={s}, across_fs={}, ceiling_dirs={s}",
            .{ start_path, across_fs, ceiling_dirs },
        );

        var git_buf = git.Buf{};

        const ceiling_dirs_temp: [*c]const u8 = if (ceiling_dirs) |slice| slice.ptr else null;
        try internal.wrapCall("git_repository_discover", .{ internal.toC(&git_buf), start_path.ptr, @boolToInt(across_fs), ceiling_dirs_temp });

        log.debug("repository discovered - {s}", .{git_buf.slice()});

        return git_buf;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
