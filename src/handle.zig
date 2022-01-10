const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

/// This type bundles all functionality that does not act on an instance of an object
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
    /// * `path` - The path to the index
    pub fn indexOpen(self: Handle, path: [:0]const u8) !*git.Index {
        _ = self;

        log.debug("Handle.indexOpen called, path: {s}", .{path});

        var index: *git.Index = undefined;

        try internal.wrapCall("git_index_open", .{
            @ptrCast(*?*c.git_index, &index),
            path.ptr,
        });

        log.debug("index opened successfully", .{});

        return index;
    }

    /// Create an in-memory index object.
    ///
    /// This index object cannot be read/written to the filesystem, but may be used to perform in-memory index operations.
    pub fn indexNew(self: Handle) !*git.Index {
        _ = self;

        log.debug("Handle.indexInit called", .{});

        var index: *git.Index = undefined;

        try internal.wrapCall("git_index_new", .{
            @ptrCast(*?*c.git_index, &index),
        });

        log.debug("index created successfully", .{});

        return index;
    }

    /// Create a new repository in the given directory.
    ///
    /// ## Parameters
    /// * `path` - The path to the repository
    /// * `is_bare` - If true, a Git repository without a working directory is created at the pointed path. 
    ///               If false, provided path will be considered as the working directory into which the .git directory will be 
    ///               created.
    pub fn repositoryInit(self: Handle, path: [:0]const u8, is_bare: bool) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryInit called, path: {s}, is_bare: {}", .{ path, is_bare });

        var repo: *git.Repository = undefined;

        try internal.wrapCall("git_repository_init", .{
            @ptrCast(*?*c.git_repository, &repo),
            path.ptr,
            @boolToInt(is_bare),
        });

        log.debug("repository created successfully", .{});

        return repo;
    }

    /// Create a new repository in the given directory with extended options.
    ///
    /// ## Parameters
    /// * `path` - The path to the repository
    /// * `options` - The options to use during the creation of the repository
    pub fn repositoryInitExtended(self: Handle, path: [:0]const u8, options: RepositoryInitOptions) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryInitExtended called, path: {s}, options: {}", .{ path, options });

        var repo: *git.Repository = undefined;

        var c_options = options.makeCOptionObject();

        try internal.wrapCall("git_repository_init_ext", .{
            @ptrCast(*?*c.git_repository, &repo),
            path.ptr,
            &c_options,
        });

        log.debug("repository created successfully", .{});

        return repo;
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

        pub fn makeCOptionObject(self: RepositoryInitOptions) c.git_repository_init_options {
            return .{
                .version = c.GIT_REPOSITORY_INIT_OPTIONS_VERSION,
                .flags = self.flags.toInt(),
                .mode = self.mode.toInt(),
                .workdir_path = if (self.workdir_path) |slice| slice.ptr else null,
                .description = if (self.description) |slice| slice.ptr else null,
                .template_path = if (self.template_path) |slice| slice.ptr else null,
                .initial_head = if (self.initial_head) |slice| slice.ptr else null,
                .origin_url = if (self.origin_url) |slice| slice.ptr else null,
            };
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Open a repository.
    ///
    /// ## Parameters
    /// * `path` - The path to the repository
    pub fn repositoryOpen(self: Handle, path: [:0]const u8) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryOpen called, path: {s}", .{path});

        var repo: *git.Repository = undefined;

        try internal.wrapCall("git_repository_open", .{
            @ptrCast(*?*c.git_repository, &repo),
            path.ptr,
        });

        log.debug("repository opened successfully", .{});

        return repo;
    }

    /// Find and open a repository with extended options.
    ///
    /// *NOTE*: `path` can only be null if the `open_from_env` option is used.
    ///
    /// ## Parameters
    /// * `path` - The path to the repository
    /// * `flags` - Options controlling how the repository is opened
    /// * `ceiling_dirs` - A `path_list_separator` delimited list of path prefixes at which the search for a containing
    ///                    repository should terminate.
    pub fn repositoryOpenExtended(
        self: Handle,
        path: ?[:0]const u8,
        flags: RepositoryOpenOptions,
        ceiling_dirs: ?[:0]const u8,
    ) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryOpenExtended called, path: {s}, flags: {}, ceiling_dirs: {s}", .{ path, flags, ceiling_dirs });

        var repo: *git.Repository = undefined;

        const path_temp = if (path) |slice| slice.ptr else null;
        const ceiling_dirs_temp = if (ceiling_dirs) |slice| slice.ptr else null;

        try internal.wrapCall("git_repository_open_ext", .{
            @ptrCast(*?*c.git_repository, &repo),
            path_temp,
            flags.toInt(),
            ceiling_dirs_temp,
        });

        log.debug("repository opened successfully", .{});

        return repo;
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
    /// * `path` - The path to the repository
    pub fn repositoryOpenBare(self: Handle, path: [:0]const u8) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryOpenBare called, path: {s}", .{path});

        var repo: *git.Repository = undefined;

        try internal.wrapCall("git_repository_open_bare", .{
            @ptrCast(*?*c.git_repository, &repo),
            path.ptr,
        });

        log.debug("repository opened successfully", .{});

        return repo;
    }

    /// Look for a git repository and return its path.
    ///
    /// The lookup starts from `start_path` and walks the directory tree until the first repository is found, or when reaching a
    /// directory referenced in `ceiling_dirs` or when the filesystem changes (when `across_fs` is false).
    ///
    /// ## Parameters
    /// * `start_path` - The path where the lookup starts.
    /// * `across_fs` - If true, then the lookup will not stop when a filesystem device change is encountered.
    /// * `ceiling_dirs` - A `path_list_separator` separated list of absolute symbolic link free paths. The lookup will stop 
    ///                    when any of this paths is reached.
    pub fn repositoryDiscover(self: Handle, start_path: [:0]const u8, across_fs: bool, ceiling_dirs: ?[:0]const u8) !git.Buf {
        _ = self;

        log.debug(
            "Handle.repositoryDiscover called, start_path: {s}, across_fs: {}, ceiling_dirs: {s}",
            .{ start_path, across_fs, ceiling_dirs },
        );

        var buf: git.Buf = .{};

        const ceiling_dirs_temp = if (ceiling_dirs) |slice| slice.ptr else null;

        try internal.wrapCall("git_repository_discover", .{
            @ptrCast(*c.git_buf, &buf),
            start_path.ptr,
            @boolToInt(across_fs),
            ceiling_dirs_temp,
        });

        log.debug("repository discovered - {s}", .{buf.toSlice()});

        return buf;
    }

    pub const CloneOptions = struct {
        /// Options to pass to the checkout step.
        checkout_options: git.Repository.CheckoutOptions = .{},

        // options which control the fetch, including callbacks. Callbacks are for reporting fetch progress, and for
        // acquiring credentials in the event they are needed.
        fetch_options: git.Remote.FetchOptions = .{},

        /// Set false (default) to create a standard repo or true for a bare repo.
        bare: bool = false,

        /// Whether to use a fetch or a copy of the object database.
        local: LocalType = .local_auto,

        /// Branch of the remote repository to checkout. `null` means the default.
        checkout_branch: ?[:0]const u8 = null,

        /// A callback used to create the new repository into which to clone. If `null` the `bare` field will be used to
        /// determine whether to create a bare repository.
        ///
        /// Return 0, or a negative value to indicate error
        ///
        /// ## Parameters
        /// * `out` - The resulting repository
        /// * `path` - Path in which to create the repository
        /// * `bare` - Whether the repository is bare. This is the value from the clone options
        /// * `payload` - Payload specified by the options
        repository_cb: ?fn (
            out: **git.Repository,
            path: [*:0]const u8,
            bare: bool,
            payload: *anyopaque,
        ) callconv(.C) void = null,

        /// An opaque payload to pass to the `repository_cb` creation callback.
        /// This parameter is ignored unless repository_cb is non-`null`.
        repository_cb_payload: ?*anyopaque = null,

        /// A callback used to create the git remote, prior to its being used to perform the clone option. 
        /// This parameter may be `null`, indicating that `Handle.clone` should provide default behavior.
        ///
        /// Return 0, or an error code
        ///
        /// ## Parameters
        /// * `out` - The resulting remote
        /// * `repo` - The repository in which to create the remote
        /// * `name` - The remote's name
        /// * `url` - The remote's url
        /// * `payload` - An opaque payload
        remote_cb: ?fn (
            out: **git.Remote,
            repo: *git.Repository,
            name: [*:0]const u8,
            url: [*:0]const u8,
            payload: ?*anyopaque,
        ) callconv(.C) void = null,

        remote_cb_payload: ?*anyopaque = null,

        /// Options for bypassing the git-aware transport on clone. Bypassing it means that instead of a fetch,
        /// libgit2 will copy the object database directory instead of figuring out what it needs, which is faster.
        pub const LocalType = enum(c_uint) {
            /// Auto-detect (default), libgit2 will bypass the git-aware transport for local paths, but use a normal fetch for
            /// `file://` urls.
            local_auto,
            /// Bypass the git-aware transport even for a `file://` url.
            local,
            /// Do no bypass the git-aware transport
            no_local,
            /// Bypass the git-aware transport, but do not try to use hardlinks.
            local_no_links,
        };

        fn makeCOptionsObject(self: CloneOptions) c.git_clone_options {
            return c.git_clone_options{
                .version = c.GIT_CHECKOUT_OPTIONS_VERSION,
                .checkout_opts = self.checkout_options.makeCOptionObject(),
                .fetch_opts = self.fetch_options.makeCOptionsObject(),
                .bare = @boolToInt(self.bare),
                .local = @enumToInt(self.local),
                .checkout_branch = if (self.checkout_branch) |b| b.ptr else null,
                .repository_cb = @ptrCast(c.git_repository_create_cb, self.repository_cb),
                .repository_cb_payload = self.repository_cb_payload,
                .remote_cb = @ptrCast(c.git_remote_create_cb, self.remote_cb),
                .remote_cb_payload = self.remote_cb_payload,
            };
        }
    };

    /// Clone a remote repository.
    ///
    /// By default this creates its repository and initial remote to match git's defaults. 
    /// You can use the options in the callback to customize how these are created.
    ///
    /// ## Parameters
    /// * `url` - URL of the remote repository to clone.
    /// * `local_path` - Directory to clone the repository into.
    /// * `options` - Customize how the repository is created.
    pub fn clone(self: Handle, url: [:0]const u8, local_path: [:0]const u8, options: CloneOptions) !*git.Repository {
        _ = self;

        log.debug("Handle.clone called, url: {s}, local_path: {s}", .{ url, local_path });

        var repo: *git.Repository = undefined;

        const c_options = options.makeCOptionsObject();

        try internal.wrapCall("git_clone", .{
            @ptrCast(*?*c.git_repository, &repo),
            url.ptr,
            local_path.ptr,
            &c_options,
        });

        log.debug("repository cloned successfully", .{});

        return repo;
    }

    pub fn optionGetMaximumMmapWindowSize(self: Handle) !usize {
        _ = self;

        log.debug("Handle.optionGetMmapWindowSize called", .{});

        var result: usize = undefined;
        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_GET_MWINDOW_SIZE, &result });

        log.debug("maximum mmap window size: {}", .{result});

        return result;
    }

    pub fn optionSetMaximumMmapWindowSize(self: Handle, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetMaximumMmapWindowSize called, value: {}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_MWINDOW_SIZE, value });

        log.debug("successfully set maximum mmap window size", .{});
    }

    pub fn optionGetMaximumMmapLimit(self: Handle) !usize {
        _ = self;

        log.debug("Handle.optionGetMaximumMmapLimit called", .{});

        var result: usize = undefined;
        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_GET_MWINDOW_MAPPED_LIMIT, &result });

        log.debug("maximum mmap limit: {}", .{result});

        return result;
    }

    pub fn optionSetMaximumMmapLimit(self: Handle, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetMaximumMmapLimit called, value: {}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_MWINDOW_MAPPED_LIMIT, value });

        log.debug("successfully set maximum mmap limit", .{});
    }

    /// zero means unlimited
    pub fn optionGetMaximumMappedFiles(self: Handle) !usize {
        _ = self;

        log.debug("Handle.optionGetMaximumMappedFiles called", .{});

        var result: usize = undefined;
        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_GET_MWINDOW_FILE_LIMIT, &result });

        log.debug("maximum mapped files: {}", .{result});

        return result;
    }

    /// zero means unlimited
    pub fn optionSetMaximumMmapFiles(self: Handle, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetMaximumMmapFiles called, value: {}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_MWINDOW_FILE_LIMIT, value });

        log.debug("successfully set maximum mapped files", .{});
    }

    pub fn optionGetSearchPath(self: Handle, level: git.Config.Level) !git.Buf {
        _ = self;

        log.debug("Handle.optionGetSearchPath called, level: {s}", .{@tagName(level)});

        var buf: git.Buf = .{};
        try internal.wrapCall("git_libgit2_opts", .{
            c.GIT_OPT_GET_SEARCH_PATH,
            @enumToInt(level),
            @ptrCast(*c.git_buf, &buf),
        });

        log.debug("got search path: {s}", .{buf.toSlice()});

        return buf;
    }

    /// `path` should be a list of directories delimited by path_list_separator.
    /// Pass `null` to reset to the default (generally based on environment variables). Use magic path `$PATH` to include the old
    /// value of the path (if you want to prepend or append, for instance).
    pub fn optionSetSearchPath(self: Handle, level: git.Config.Level, path: ?[:0]const u8) !void {
        _ = self;

        log.debug("Handle.optionSetSearchPath called, path: {s}", .{path});

        const path_c = if (path) |slice| slice.ptr else null;

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_SEARCH_PATH, @enumToInt(level), path_c });

        log.debug("successfully set search path", .{});
    }

    pub fn optionSetCacheObjectLimit(self: Handle, object_type: git.ObjectType, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetCacheObjectLimit called, object_type: {s}, value: {}", .{ @tagName(object_type), value });

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_CACHE_OBJECT_LIMIT, @enumToInt(object_type), value });

        log.debug("successfully set cache object limit", .{});
    }

    pub fn optionSetMaximumCacheSize(self: Handle, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetCacheMaximumSize called, value: {}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_CACHE_MAX_SIZE, value });

        log.debug("successfully set maximum cache size", .{});
    }

    pub fn optionSetCaching(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetCaching called, enabled: {}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_ENABLE_CACHING, enabled });

        log.debug("successfully set caching status", .{});
    }

    pub fn optionGetCachedMemory(self: Handle) !CachedMemory {
        _ = self;

        log.debug("Handle.optionGetCachedMemory called", .{});

        var result: CachedMemory = undefined;
        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_GET_CACHED_MEMORY, &result.current, &result.allowed });

        log.debug("cached memory: {}", .{result});

        return result;
    }

    pub const CachedMemory = struct {
        current: usize,
        allowed: usize,
    };

    pub fn optionGetTemplatePath(self: Handle) !git.Buf {
        _ = self;

        log.debug("Handle.optionGetTemplatePath called", .{});

        var result: git.Buf = .{};
        try internal.wrapCall("git_libgit2_opts", .{
            c.GIT_OPT_GET_TEMPLATE_PATH,
            @ptrCast(*c.git_buf, &result),
        });

        log.debug("got template path: {s}", .{result.toSlice()});

        return result;
    }

    pub fn optionSetTemplatePath(self: Handle, path: [:0]const u8) !void {
        _ = self;

        log.debug("Handle.optionSetTemplatePath called, path: {s}", .{path});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_TEMPLATE_PATH, path.ptr });

        log.debug("successfully set template path", .{});
    }

    /// Either parameter may be `null`, but not both.
    pub fn optionSetSslCertLocations(self: Handle, file: ?[:0]const u8, path: ?[:0]const u8) !void {
        _ = self;

        log.debug("Handle.optionSetSslCertLocations called, file: {s}, path: {s}", .{ file, path });

        const file_c = if (file) |ptr| ptr.ptr else null;
        const path_c = if (path) |ptr| ptr.ptr else null;

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_SSL_CERT_LOCATIONS, file_c, path_c });

        log.debug("successfully set ssl certificate location", .{});
    }

    pub fn optionSetUserAgent(self: Handle, user_agent: [:0]const u8) !void {
        _ = self;

        log.debug("Handle.optionSetUserAgent called, user_agent: {s}", .{user_agent});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_USER_AGENT, user_agent.ptr });

        log.debug("successfully set user agent", .{});
    }

    pub fn optionGetUserAgent(self: Handle) !git.Buf {
        _ = self;

        log.debug("Handle.optionGetUserAgent called", .{});

        var result: git.Buf = .{};
        try internal.wrapCall("git_libgit2_opts", .{
            c.GIT_OPT_GET_USER_AGENT,
            @ptrCast(*c.git_buf, &result),
        });

        log.debug("got user agent: {s}", .{result.toSlice()});

        return result;
    }

    pub fn optionSetWindowsSharemode(self: Handle, value: c_uint) !void {
        _ = self;

        log.debug("Handle.optionSetWindowsSharemode called, value: {}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_WINDOWS_SHAREMODE, value });

        log.debug("successfully set windows share mode", .{});
    }

    pub fn optionGetWindowSharemode(self: Handle) !c_uint {
        _ = self;

        log.debug("Handle.optionGetWindowSharemode called", .{});

        var result: c_uint = undefined;
        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_GET_WINDOWS_SHAREMODE, &result });

        log.debug("got windows share mode: {}", .{result});

        return result;
    }

    pub fn optionSetStrictObjectCreation(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetStrictObjectCreation called, enabled: {}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_ENABLE_STRICT_OBJECT_CREATION, @boolToInt(enabled) });

        log.debug("successfully set strict object creation mode", .{});
    }

    pub fn optionSetStrictSymbolicRefCreations(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetStrictSymbolicRefCreations called, enabled: {}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_ENABLE_STRICT_SYMBOLIC_REF_CREATION, @boolToInt(enabled) });

        log.debug("successfully set strict symbolic ref creation mode", .{});
    }

    pub fn optionSetSslCiphers(self: Handle, ciphers: [:0]const u8) !void {
        _ = self;

        log.debug("Handle.optionSetSslCiphers called, ciphers: {s}", .{ciphers});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_SSL_CIPHERS, ciphers.ptr });

        log.debug("successfully set SSL ciphers", .{});
    }

    pub fn optionSetOffsetDeltas(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetOffsetDeltas called, enabled: {}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_ENABLE_OFS_DELTA, @boolToInt(enabled) });

        log.debug("successfully set offset deltas mode", .{});
    }

    pub fn optionSetFsyncDir(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetFsyncDir called, enabled: {}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_ENABLE_FSYNC_GITDIR, @boolToInt(enabled) });

        log.debug("successfully set fsync dir mode", .{});
    }

    pub fn optionSetStrictHashVerification(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetStrictHashVerification called, enabled: {}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_ENABLE_STRICT_HASH_VERIFICATION, @boolToInt(enabled) });

        log.debug("successfully set strict hash verification mode", .{});
    }

    /// If the given `allocator` is `null`, then the system default will be restored.
    pub fn optionSetAllocator(self: Handle, allocator: ?*git.GitAllocator) !void {
        _ = self;

        log.debug("Handle.optionSetAllocator called, allocator: {*}", .{allocator});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_ALLOCATOR, allocator });

        log.debug("successfully set allocator", .{});
    }

    pub fn optionSetUnsafedIndexSafety(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetUnsafedIndexSafety called, enabled: {}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_ENABLE_UNSAVED_INDEX_SAFETY, @boolToInt(enabled) });

        log.debug("successfully set unsaved index safety mode", .{});
    }

    pub fn optionGetMaximumPackObjects(self: Handle) !usize {
        _ = self;

        log.debug("Handle.optionGetMaximumPackObjects called", .{});

        var result: usize = undefined;
        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_GET_PACK_MAX_OBJECTS, &result });

        log.debug("maximum pack objects: {}", .{result});

        return result;
    }

    pub fn optionSetMaximumPackObjects(self: Handle, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetMaximumPackObjects called, value: {}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_PACK_MAX_OBJECTS, value });

        log.debug("successfully set maximum pack objects", .{});
    }

    pub fn optionSetDisablePackKeepFileChecks(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetDisablePackKeepFileChecks called, enabled: {}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_DISABLE_PACK_KEEP_FILE_CHECKS, @boolToInt(enabled) });

        log.debug("successfully set unsaved index safety mode", .{});
    }

    pub fn optionSetHTTPExpectContinue(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetHTTPExpectContinue called, enabled: {}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_ENABLE_HTTP_EXPECT_CONTINUE, @boolToInt(enabled) });

        log.debug("successfully set HTTP expect continue mode", .{});
    }

    pub fn branchNameIsValid(self: Handle, name: [:0]const u8) !bool {
        _ = self;

        log.debug("Handle.branchNameIsValid, name: {s}", .{name});

        var valid: c_int = undefined;
        try internal.wrapCall("git_branch_name_is_valid", .{ &valid, name.ptr });

        const ret = valid == 1;

        log.debug("branch name valid: {}", .{ret});

        return ret;
    }

    pub fn optionSetOdbPackedPriority(self: Handle, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetOdbPackedPriority called, value: {}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_ODB_PACKED_PRIORITY, value });

        log.debug("successfully set odb packed priority", .{});
    }

    pub fn optionSetOdbLoosePriority(self: Handle, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetOdbLoosePriority called, value: {}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ c.GIT_OPT_SET_ODB_LOOSE_PRIORITY, value });

        log.debug("successfully set odb loose priority", .{});
    }

    /// Clean up excess whitespace and make sure there is a trailing newline in the message.
    ///
    /// Optionally, it can remove lines which start with the comment character.
    ///
    /// ## Parameters
    /// * `message` - The message to be prettified.
    /// * `strip_comment_char` - If non-`null` lines starting with this character are considered to be comments and removed
    pub fn messagePrettify(self: Handle, message: [:0]const u8, strip_comment_char: ?u8) !git.Buf {
        _ = self;

        log.debug("Handle.messagePrettify called, message: {s}, strip_comment_char: {}", .{ message, strip_comment_char });

        var ret: git.Buf = .{};

        if (strip_comment_char) |char| {
            try internal.wrapCall("git_message_prettify", .{
                @ptrCast(*c.git_buf, &ret),
                message.ptr,
                1,
                char,
            });
        } else {
            try internal.wrapCall("git_message_prettify", .{
                @ptrCast(*c.git_buf, &ret),
                message.ptr,
                0,
                0,
            });
        }

        log.debug("prettified message: {s}", .{ret.toSlice()});

        return ret;
    }

    /// Parse trailers out of a message
    ///
    /// Trailers are key/value pairs in the last paragraph of a message, not including any patches or conflicts that may
    /// be present.
    pub fn messageParseTrailers(self: Handle, message: [:0]const u8) !git.MessageTrailerArray {
        _ = self;

        log.debug("Handle.messageParseTrailers called, message: {s}", .{message});

        var ret: git.MessageTrailerArray = undefined;

        try internal.wrapCall("git_message_trailers", .{
            @ptrCast(*c.git_message_trailer_array, &ret),
            message.ptr,
        });

        log.debug("successfully parsed {} message trailers", .{ret.count});

        return ret;
    }

    /// Available tracing levels.
    /// When tracing is set to a particular level, callers will be provided tracing at the given level and all lower levels.
    pub const TraceLevel = enum(c_uint) {
        /// No tracing will be performed.
        none = 0,
        /// Severe errors that may impact the program's execution
        fatal = 1,
        /// Errors that do not impact the program's execution
        err = 2,
        /// Warnings that suggest abnormal data
        warn = 3,
        /// Informational messages about program execution
        info = 4,
        /// Detailed data that allows for debugging
        debug = 5,
        /// Exceptionally detailed debugging data
        trace = 6,
    };

    /// Sets the system tracing configuration to the specified level with the specified callback.
    /// When system events occur at a level equal to, or lower than, the given level they will be reported to the given callback.
    ///
    /// ## Parameters
    /// * `level` - Level to set tracing to
    /// * `callback_fn` - The callback function to call with trace data
    ///
    /// ## Callback Parameters
    /// * `level` - The trace level
    /// * `message` - The message
    pub fn traceSet(
        self: Handle,
        level: TraceLevel,
        comptime callback_fn: fn (level: TraceLevel, message: [:0]const u8) void,
    ) !void {
        _ = self;

        log.debug("Handle.traceSet called, level: {}", .{level});

        const cb = struct {
            pub fn cb(
                c_level: c.git_trace_level_t,
                msg: ?[*:0]const u8,
            ) callconv(.C) void {
                callback_fn(
                    @intToEnum(TraceLevel, c_level),
                    std.mem.sliceTo(msg.?, 0),
                );
            }
        }.cb;

        try internal.wrapCall("git_trace_set", .{
            @enumToInt(level),
            cb,
        });

        log.debug("successfully enabled tracing", .{});
    }

    /// The kinds of git-specific files we know about.
    pub const GitFile = enum(c_uint) {
        /// Check for the .gitignore file
        gitignore = 0,
        /// Check for the .gitmodules file
        gitmodules,
        /// Check for the .gitattributes file
        gitattributes,
    };

    /// The kinds of checks to perform according to which filesystem we are trying to protect.
    pub const FileSystem = enum(c_uint) {
        /// Do both NTFS- and HFS-specific checks
        generic = 0,
        /// Do NTFS-specific checks only
        ntfs,
        /// Do HFS-specific checks only
        hfs,
    };

    /// Check whether a path component corresponds to a .git$SUFFIX file.
    ///
    /// As some filesystems do special things to filenames when writing files to disk, you cannot always do a plain string
    /// comparison to verify whether a file name matches an expected path or not. This function can do the comparison for you,
    /// depending on the filesystem you're on.
    ///
    /// ## Parameters
    /// * `path` - The path to check
    /// * `gitfile` - Which file to check against
    /// * `fs` - Which filesystem-specific checks to use
    pub fn pathIsGitfile(self: Handle, path: []const u8, gitfile: GitFile, fs: FileSystem) !bool {
        _ = self;

        log.debug("Handle.pathIsGitfile called, path: {s}, gitfile: {}, fs: {}", .{ path, gitfile, fs });

        const ret = (try internal.wrapCallWithReturn("git_path_is_gitfile", .{
            path.ptr,
            path.len,
            @enumToInt(gitfile),
            @enumToInt(fs),
        })) != 0;

        log.debug("is git file: {}", .{ret});

        return ret;
    }

    pub fn configNew(self: Handle) !*git.Config {
        _ = self;

        log.debug("Handle.configNew called", .{});

        var config: *git.Config = undefined;

        try internal.wrapCall("git_config_new", .{
            @ptrCast(*?*c.git_config, &config),
        });

        log.debug("created new config", .{});

        return config;
    }

    pub fn configOpenOnDisk(self: Handle, path: [:0]const u8) !*git.Config {
        _ = self;

        log.debug("Handle.configOpenOnDisk called, path: {s}", .{path});

        var config: *git.Config = undefined;

        try internal.wrapCall("git_config_open_ondisk", .{
            @ptrCast(*?*c.git_config, &config),
            path.ptr,
        });

        log.debug("opened config from file", .{});

        return config;
    }

    pub fn configOpenDefault(self: Handle) !*git.Config {
        _ = self;

        log.debug("Handle.configOpenDefault called", .{});

        var config: *git.Config = undefined;

        try internal.wrapCall("git_config_open_default", .{
            @ptrCast(*?*c.git_config, &config),
        });

        log.debug("opened default config", .{});

        return config;
    }

    pub fn configFindGlobal(self: Handle) ?git.Buf {
        _ = self;

        log.debug("Handle.configFindGlobal called", .{});

        var buf: git.Buf = .{};

        if (c.git_config_find_global(@ptrCast(*c.git_buf, &buf)) == 0) return null;

        log.debug("global config path: {s}", .{buf.toSlice()});

        return buf;
    }

    pub fn configFindXdg(self: Handle) ?git.Buf {
        _ = self;

        log.debug("Handle.configFindXdg called", .{});

        var buf: git.Buf = .{};

        if (c.git_config_find_xdg(@ptrCast(*c.git_buf, &buf)) == 0) return null;

        log.debug("xdg config path: {s}", .{buf.toSlice()});

        return buf;
    }

    pub fn configFindSystem(self: Handle) ?git.Buf {
        _ = self;

        log.debug("Handle.configFindSystem called", .{});

        var buf: git.Buf = .{};

        if (c.git_config_find_system(@ptrCast(*c.git_buf, &buf)) == 0) return null;

        log.debug("system config path: {s}", .{buf.toSlice()});

        return buf;
    }

    pub fn configFindProgramdata(self: Handle) ?git.Buf {
        _ = self;

        log.debug("Handle.configFindProgramdata called", .{});

        var buf: git.Buf = .{};

        if (c.git_config_find_programdata(@ptrCast(*c.git_buf, &buf)) == 0) return null;

        log.debug("programdata config path: {s}", .{buf.toSlice()});

        return buf;
    }

    pub fn credentialInitUserPassPlaintext(self: Handle, username: [:0]const u8, password: [:0]const u8) !*git.Credential {
        _ = self;

        log.debug("Handle.credentialInitUserPassPlaintext called, username: {s}, password: {s}", .{ username, password });

        var cred: *git.Credential = undefined;

        if (internal.has_credential) {
            try internal.wrapCall("git_credential_userpass_plaintext_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
                password.ptr,
            });
        } else {
            try internal.wrapCall("git_cred_userpass_plaintext_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
                password.ptr,
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    /// Create a "default" credential usable for Negotiate mechanisms like NTLM or Kerberos authentication.
    pub fn credentialInitDefault(self: Handle) !*git.Credential {
        _ = self;

        log.debug("Handle.credentialInitDefault", .{});

        var cred: *git.Credential = undefined;

        if (internal.has_credential) {
            try internal.wrapCall("git_credential_default_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
            });
        } else {
            try internal.wrapCall("git_cred_default_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    /// Create a credential to specify a username.
    ///
    /// This is used with ssh authentication to query for the username if none is specified in the url.
    pub fn credentialInitUsername(self: Handle, username: [:0]const u8) !*git.Credential {
        _ = self;

        log.debug("Handle.credentialInitUsername called, username: {s}", .{username});

        var cred: *git.Credential = undefined;

        if (internal.has_credential) {
            try internal.wrapCall("git_credential_username_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
            });
        } else {
            try internal.wrapCall("git_cred_username_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    /// Create a new passphrase-protected ssh key credential object.
    ///
    /// ## Parameters
    /// * `username` - Username to use to authenticate
    /// * `publickey` - The path to the public key of the credential.
    /// * `privatekey` - The path to the private key of the credential.
    /// * `passphrase` - The passphrase of the credential.
    pub fn credentialInitSshKey(
        self: Handle,
        username: [:0]const u8,
        publickey: ?[:0]const u8,
        privatekey: [:0]const u8,
        passphrase: ?[:0]const u8,
    ) !*git.Credential {
        _ = self;

        log.debug(
            "Handle.credentialInitSshKey called, username: {s}, publickey: {s}, privatekey: {s}, passphrase: {s}",
            .{ username, publickey, privatekey, passphrase },
        );

        var cred: *git.Credential = undefined;

        const publickey_c = if (publickey) |str| str.ptr else null;
        const passphrase_c = if (passphrase) |str| str.ptr else null;

        if (internal.has_credential) {
            try internal.wrapCall("git_credential_ssh_key_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
                publickey_c,
                privatekey.ptr,
                passphrase_c,
            });
        } else {
            try internal.wrapCall("git_cred_ssh_key_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
                publickey_c,
                privatekey.ptr,
                passphrase_c,
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    /// Create a new ssh key credential object reading the keys from memory.
    ///
    /// ## Parameters
    /// * `username` - Username to use to authenticate
    /// * `publickey` - The public key of the credential.
    /// * `privatekey` - The private key of the credential.
    /// * `passphrase` - The passphrase of the credential.
    pub fn credentialInitSshKeyMemory(
        self: Handle,
        username: [:0]const u8,
        publickey: ?[:0]const u8,
        privatekey: [:0]const u8,
        passphrase: ?[:0]const u8,
    ) !*git.Credential {
        _ = self;

        log.debug("Handle.credentialInitSshKeyMemory called", .{});

        var cred: *git.Credential = undefined;

        const publickey_c = if (publickey) |str| str.ptr else null;
        const passphrase_c = if (passphrase) |str| str.ptr else null;

        if (internal.has_credential) {
            try internal.wrapCall("git_credential_ssh_key_memory_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
                publickey_c,
                privatekey.ptr,
                passphrase_c,
            });
        } else {
            try internal.wrapCall("git_cred_ssh_key_memory_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
                publickey_c,
                privatekey.ptr,
                passphrase_c,
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    /// Create a new ssh keyboard-interactive based credential object.
    ///
    /// ## Parameters
    /// * `username` - Username to use to authenticate.
    /// * `user_data` - Pointer to user data to be passed to the callback
    /// * `callback_fn` - The callback function
    pub fn credentialInitSshKeyInteractive(
        self: Handle,
        username: [:0]const u8,
        user_data: anytype,
        comptime callback_fn: fn (
            name: []const u8,
            instruction: []const u8,
            prompts: []*const c.LIBSSH2_USERAUTH_KBDINT_PROMPT,
            responses: []*c.LIBSSH2_USERAUTH_KBDINT_RESPONSE,
            abstract: ?*?*anyopaque,
        ) void,
    ) !*git.Credential {
        _ = self;

        // TODO: This callback needs to be massively cleaned up

        const cb = struct {
            pub fn cb(
                name: [*]const u8,
                name_len: c_int,
                instruction: [*]const u8,
                instruction_len: c_int,
                num_prompts: c_int,
                prompts: ?*const c.LIBSSH2_USERAUTH_KBDINT_PROMPT,
                responses: ?*c.LIBSSH2_USERAUTH_KBDINT_RESPONSE,
                abstract: ?*?*anyopaque,
            ) callconv(.C) void {
                callback_fn(
                    name[0..name_len],
                    instruction[0..instruction_len],
                    prompts[0..num_prompts],
                    responses[0..num_prompts],
                    abstract,
                );
            }
        }.cb;

        log.debug("Handle.credentialInitSshKeyInteractive called, username: {s}", .{username});

        var cred: *git.Credential = undefined;

        if (internal.has_credential) {
            try internal.wrapCall("git_credential_ssh_interactive_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
                cb,
                user_data,
            });
        } else {
            try internal.wrapCall("git_cred_ssh_interactive_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
                cb,
                user_data,
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    pub fn credentialInitSshKeyFromAgent(self: Handle, username: [:0]const u8) !*git.Credential {
        _ = self;

        log.debug("Handle.credentialInitSshKeyFromAgent called, username: {s}", .{username});

        var cred: *git.Credential = undefined;

        if (internal.has_credential) {
            try internal.wrapCall("git_credential_ssh_key_from_agent", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
            });
        } else {
            try internal.wrapCall("git_cred_ssh_key_from_agent", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    pub fn credentialInitSshKeyCustom(
        self: Handle,
        username: [:0]const u8,
        publickey: []const u8,
        user_data: anytype,
        comptime callback_fn: fn (
            session: *c.LIBSSH2_SESSION,
            out_signature: *[]const u8,
            data: []const u8,
            abstract: ?*?*anyopaque,
        ) c_int,
    ) !*git.Credential {
        _ = self;

        const cb = struct {
            pub fn cb(
                session: ?*c.LIBSSH2_SESSION,
                sig: *[*:0]u8,
                sig_len: *usize,
                data: [*]const u8,
                data_len: usize,
                abstract: ?*?*anyopaque,
            ) callconv(.C) c_int {
                var out_sig: []const u8 = undefined;

                const result = callback_fn(
                    session,
                    &out_sig,
                    data[0..data_len],
                    abstract,
                );

                sig.* = out_sig.ptr;
                sig_len.* = out_sig.len;

                return result;
            }
        }.cb;

        log.debug("Handle.credentialInitSshKeyCustom called, username: {s}", .{username});

        var cred: *git.Credential = undefined;

        if (internal.has_credential) {
            try internal.wrapCall("git_credential_ssh_custom_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
                publickey.ptr,
                publickey.len,
                cb,
                user_data,
            });
        } else {
            try internal.wrapCall("git_cred_ssh_custom_new", .{
                @ptrCast(*?*internal.RawCredentialType, &cred),
                username.ptr,
                publickey.ptr,
                publickey.len,
                cb,
                user_data,
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    /// Get detailed information regarding the last error that occured on *this* thread.
    pub fn getDetailedLastError(self: Handle) ?*const git.DetailedError {
        _ = self;
        return @ptrCast(?*const git.DetailedError, c.git_error_last());
    }

    /// Clear the last error that occured on *this* thread.
    pub fn clearLastError(self: Handle) void {
        _ = self;
        c.git_error_clear();
    }

    /// Create a new indexer instance
    ///
    /// ## Parameters
    /// * `path` - To the directory where the packfile should be stored
    /// * `odb` - Object database from which to read base objects when fixing thin packs. Pass `null` if no thin pack is expected
    ///           (an error will be returned if there are bases missing)
    /// * `options` - Options
    /// * `callback_fn` - The callback function; a value less than zero to cancel the indexing or download
    ///
    /// ## Callback Parameters
    /// * `stats` - State of the transfer
    pub fn indexerInit(
        self: Handle,
        path: [:0]const u8,
        odb: ?*git.Odb,
        options: git.Indexer.Options,
        comptime callback_fn: fn (stats: *const git.Indexer.Progress) c_int,
    ) !*git.Indexer {
        const cb = struct {
            pub fn cb(
                stats: *const git.Indexer.Progress,
                _: *u8,
            ) c_int {
                return callback_fn(stats);
            }
        }.cb;

        var dummy_data: u8 = undefined;
        return self.indexerInitWithUserData(path, odb, options, &dummy_data, cb);
    }

    /// Create a new indexer instance
    ///
    /// ## Parameters
    /// * `path` - To the directory where the packfile should be stored
    /// * `odb` - Object database from which to read base objects when fixing thin packs. Pass `null` if no thin pack is expected
    ///           (an error will be returned if there are bases missing)
    /// * `options` - Options
    /// * `user_data` - Pointer to user data to be passed to the callback
    /// * `callback_fn` - The callback function; a value less than zero to cancel the indexing or download
    ///
    /// ## Callback Parameters
    /// * `stats` - State of the transfer
    /// * `user_data_ptr` - The user data
    pub fn indexerInitWithUserData(
        self: Handle,
        path: [:0]const u8,
        odb: ?*git.Odb,
        options: git.Indexer.Options,
        user_data: anytype,
        comptime callback_fn: fn (
            stats: *const git.Indexer.Progress,
            user_data_ptr: @TypeOf(user_data),
        ) c_int,
    ) !*git.Indexer {
        _ = self;

        const UserDataType = @TypeOf(user_data);

        const cb = struct {
            pub fn cb(
                stats: *const c.git_indexer_progress,
                payload: ?*anyopaque,
            ) callconv(.C) c_int {
                return callback_fn(@ptrCast(*const git.Indexer.Progress, stats), @ptrCast(UserDataType, payload));
            }
        }.cb;

        log.debug("Handle.indexerInitWithUserData called, path: {s}, odb: {*}, options: {}", .{ path, odb, options });

        var c_opts = c.git_indexer_options{
            .version = c.GIT_INDEXER_OPTIONS_VERSION,
            .progress_cb = cb,
            .progress_cb_payload = user_data,
            .verify = @boolToInt(options.verify),
        };

        var ret: *git.Indexer = undefined;

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

    /// Allocate a new mailmap object.
    ///
    /// This object is empty, so you'll have to add a mailmap file before you can do anything with it. 
    /// The mailmap must be freed with 'deinit'.
    pub fn mailmapInit(self: Handle) !*git.Mailmap {
        _ = self;

        log.debug("Handle.mailmapInit called", .{});

        var mailmap: *git.Mailmap = undefined;

        try internal.wrapCall("git_mailmap_new", .{
            @ptrCast(*?*c.git_mailmap, &mailmap),
        });

        log.debug("successfully initalized mailmap {*}", .{mailmap});

        return mailmap;
    }

    /// Compile a pathspec
    ///
    /// ## Parameters
    /// * `pathspec` - A `git.StrArray` of the paths to match
    pub fn pathspecInit(self: Handle, pathspec: git.StrArray) !*git.Pathspec {
        _ = self;

        log.debug("Handle.pathspecInit called", .{});

        var ret: *git.Pathspec = undefined;

        try internal.wrapCall("git_pathspec_new", .{
            @ptrCast(*?*c.git_pathspec, &ret),
            @ptrCast(*const c.git_strarray, &pathspec),
        });

        log.debug("successfully created pathspec: {*}", .{ret});

        return ret;
    }

    /// Parse a given refspec string.
    ///
    /// ## Parameters
    /// * `input` - The refspec string
    /// * `is_fetch` - Is this a refspec for a fetch
    pub fn refspecParse(self: Handle, input: [:0]const u8, is_fetch: bool) !*git.Refspec {
        _ = self;

        log.debug("Handle.refspecParse called, input: {s}, is_fetch: {}", .{ input, is_fetch });

        var ret: *git.Refspec = undefined;

        try internal.wrapCall("git_refspec_parse", .{
            @ptrCast(*?*c.git_refspec, &ret),
            input.ptr,
            @boolToInt(is_fetch),
        });

        log.debug("successfully parsed refspec: {*}", .{ret});

        return ret;
    }

    /// Create a remote, with options.
    ///
    /// This function allows more fine-grained control over the remote creation.
    ///
    /// ## Parameters
    /// * `url` - The remote's url.
    /// * `options` - The remote creation options.
    pub fn remoteCreateWithOptions(self: Handle, url: [:0]const u8, options: git.Remote.CreateOptions) !*git.Remote {
        _ = self;

        log.debug("Handle.remoteCreateWithOptions called, url: {s}, options: {}", .{ url, options });

        var remote: *git.Remote = undefined;

        const c_opts = options.makeCOptionsObject();

        try internal.wrapCall("git_remote_create_with_opts", .{
            @ptrCast(*?*c.git_remote, &remote),
            url.ptr,
            &c_opts,
        });

        log.debug("successfully created remote: {*}", .{remote});

        return remote;
    }

    /// Create a remote without a connected local repo.
    ///
    /// Create a remote with the given url in-memory. You can use this when you have a URL instead of a remote's name.
    ///
    /// Contrasted with `Repository.remoteCreateAnonymous`, a detached remote will not consider any repo configuration values
    /// (such as insteadof url substitutions).
    ///
    /// ## Parameters
    /// * `url` - The remote's url.
    pub fn remoreCreateDetached(self: Handle, url: [:0]const u8) !*git.Remote {
        _ = self;

        log.debug("Handle.remoreCreateDetached called, url: {s}", .{url});

        var remote: *git.Remote = undefined;

        try internal.wrapCall("git_remote_create_detached", .{
            @ptrCast(*?*c.git_remote, &remote),
            url.ptr,
        });

        log.debug("successfully created remote: {*}", .{remote});

        return remote;
    }

    /// `min_length` is the minimal length for all identifiers, which will be used even if shorter OIDs would still be unique.
    pub fn oidShortenerInit(self: Handle, min_length: usize) !*git.OidShortener {
        _ = self;

        log.debug("Handle.oidShortenerInit called, min_length: {}", .{min_length});

        if (c.git_oid_shorten_new(min_length)) |ret| {
            log.debug("Oid shortener created successfully", .{});

            return @ptrCast(*git.OidShortener, ret);
        }

        return error.OutOfMemory;
    }

    pub fn oidTryParse(self: Handle, str: [:0]const u8) ?git.Oid {
        return self.oidTryParsePtr(str.ptr);
    }

    pub fn oidTryParsePtr(self: Handle, str: [*:0]const u8) ?git.Oid {
        _ = self;

        var result: git.Oid = undefined;
        internal.wrapCall("git_oid_fromstrp", .{ @ptrCast(*c.git_oid, &result), str }) catch {
            return null;
        };
        return result;
    }

    /// Parse `length` characters of a hex formatted object id into a `Oid`
    ///
    /// If `length` is odd, the last byte's high nibble will be read in and the low nibble set to zero.
    pub fn oidParseCount(self: Handle, buf: []const u8, length: usize) !git.Oid {
        _ = self;

        if (buf.len < length) return error.BufferTooShort;

        var result: git.Oid = undefined;
        try internal.wrapCall("git_oid_fromstrn", .{ @ptrCast(*c.git_oid, &result), buf.ptr, length });
        return result;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
