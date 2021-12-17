//! This type bundles all functionality that does not act on an instance of an object

const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

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

        var index: *git.Index = undefined;

        try internal.wrapCall("git_index_open", .{
            @ptrCast(*?*raw.git_index, &index),
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
            @ptrCast(*?*raw.git_index, &index),
        });

        log.debug("index created successfully", .{});

        return index;
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

        var repo: *git.Repository = undefined;

        try internal.wrapCall("git_repository_init", .{
            @ptrCast(*?*raw.git_repository, &repo),
            path.ptr,
            @boolToInt(is_bare),
        });

        log.debug("repository created successfully", .{});

        return repo;
    }

    /// Create a new repository in the given directory with extended options.
    ///
    /// ## Parameters
    /// * `path` - the path to the repository
    /// * `options` - The options to use during the creation of the repository
    pub fn repositoryInitExtended(self: Handle, path: [:0]const u8, options: RepositoryInitOptions) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryInitExtended called, path={s}, options={}", .{ path, options });

        var repo: *git.Repository = undefined;

        var c_options = options.makeCOptionObject();

        try internal.wrapCall("git_repository_init_ext", .{
            @ptrCast(*?*raw.git_repository, &repo),
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

        pub fn makeCOptionObject(self: RepositoryInitOptions) raw.git_repository_init_options {
            return .{
                .version = raw.GIT_REPOSITORY_INIT_OPTIONS_VERSION,
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
    /// * `path` - the path to the repository
    pub fn repositoryOpen(self: Handle, path: [:0]const u8) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryOpen called, path={s}", .{path});

        var repo: *git.Repository = undefined;

        try internal.wrapCall("git_repository_open", .{
            @ptrCast(*?*raw.git_repository, &repo),
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

        var repo: *git.Repository = undefined;

        const path_temp: [*c]const u8 = if (path) |slice| slice.ptr else null;
        const ceiling_dirs_temp: [*c]const u8 = if (ceiling_dirs) |slice| slice.ptr else null;
        try internal.wrapCall("git_repository_open_ext", .{
            @ptrCast(*?*raw.git_repository, &repo),
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
    /// * `path` - the path to the repository
    pub fn repositoryOpenBare(self: Handle, path: [:0]const u8) !*git.Repository {
        _ = self;

        log.debug("Handle.repositoryOpenBare called, path={s}", .{path});

        var repo: *git.Repository = undefined;

        try internal.wrapCall("git_repository_open_bare", .{
            @ptrCast(*?*raw.git_repository, &repo),
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
    /// * `ceiling_dirs` - A `PATH_LIST_SEPARATOR` separated list of absolute symbolic link free paths. The lookup will stop 
    ///                    when any of this paths is reached.
    pub fn repositoryDiscover(self: Handle, start_path: [:0]const u8, across_fs: bool, ceiling_dirs: ?[:0]const u8) !git.Buf {
        _ = self;

        log.debug(
            "Handle.repositoryDiscover called, start_path={s}, across_fs={}, ceiling_dirs={s}",
            .{ start_path, across_fs, ceiling_dirs },
        );

        var buf: git.Buf = .{};

        const ceiling_dirs_temp: [*c]const u8 = if (ceiling_dirs) |slice| slice.ptr else null;

        try internal.wrapCall("git_repository_discover", .{
            @ptrCast(*raw.git_buf, &buf),
            start_path.ptr,
            @boolToInt(across_fs),
            ceiling_dirs_temp,
        });

        log.debug("repository discovered - {s}", .{buf.toSlice()});

        return buf;
    }

    pub fn optionGetMaximumMmapWindowSize(self: Handle) !usize {
        _ = self;

        log.debug("Handle.optionGetMmapWindowSize called", .{});

        var result: usize = undefined;
        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_GET_MWINDOW_SIZE, &result });

        log.debug("maximum mmap window size: {}", .{result});

        return result;
    }

    pub fn optionSetMaximumMmapWindowSize(self: Handle, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetMaximumMmapWindowSize called, value={}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_MWINDOW_SIZE, value });

        log.debug("successfully set maximum mmap window size", .{});
    }

    pub fn optionGetMaximumMmapLimit(self: Handle) !usize {
        _ = self;

        log.debug("Handle.optionGetMaximumMmapLimit called", .{});

        var result: usize = undefined;
        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_GET_MWINDOW_MAPPED_LIMIT, &result });

        log.debug("maximum mmap limit: {}", .{result});

        return result;
    }

    pub fn optionSetMaximumMmapLimit(self: Handle, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetMaximumMmapLimit called, value={}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_MWINDOW_MAPPED_LIMIT, value });

        log.debug("successfully set maximum mmap limit", .{});
    }

    /// zero means unlimited
    pub fn optionGetMaximumMappedFiles(self: Handle) !usize {
        _ = self;

        log.debug("Handle.optionGetMaximumMappedFiles called", .{});

        var result: usize = undefined;
        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_GET_MWINDOW_FILE_LIMIT, &result });

        log.debug("maximum mapped files: {}", .{result});

        return result;
    }

    /// zero means unlimited
    pub fn optionSetMaximumMmapFiles(self: Handle, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetMaximumMmapFiles called, value={}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_MWINDOW_FILE_LIMIT, value });

        log.debug("successfully set maximum mapped files", .{});
    }

    pub fn optionGetSearchPath(self: Handle, level: git.Config.Level) !git.Buf {
        _ = self;

        log.debug("Handle.optionGetSearchPath called, level={s}", .{@tagName(level)});

        var buf: git.Buf = .{};
        try internal.wrapCall("git_libgit2_opts", .{
            raw.GIT_OPT_GET_SEARCH_PATH,
            @enumToInt(level),
            @ptrCast(*raw.git_buf, &buf),
        });

        log.debug("got search path: {s}", .{buf.toSlice()});

        return buf;
    }

    /// `path` should be a list of directories delimited by PATH_LIST_SEPARATOR.
    /// Pass `null` to reset to the default (generally based on environment variables). Use magic path `$PATH` to include the old
    /// value of the path (if you want to prepend or append, for instance).
    pub fn optionSetSearchPath(self: Handle, level: git.Config.Level, path: ?[:0]const u8) !void {
        _ = self;

        log.debug("Handle.optionSetSearchPath called, path={s}", .{path});

        const path_c: [*c]const u8 = if (path) |slice| slice.ptr else null;
        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_SEARCH_PATH, @enumToInt(level), path_c });

        log.debug("successfully set search path", .{});
    }

    pub fn optionSetCacheObjectLimit(self: Handle, object_type: git.ObjectType, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetCacheObjectLimit called, object_type={s}, value={}", .{ @tagName(object_type), value });

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_CACHE_OBJECT_LIMIT, @enumToInt(object_type), value });

        log.debug("successfully set cache object limit", .{});
    }

    pub fn optionSetMaximumCacheSize(self: Handle, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetCacheMaximumSize called, value={}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_CACHE_MAX_SIZE, value });

        log.debug("successfully set maximum cache size", .{});
    }

    pub fn optionSetCaching(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetCaching called, enabled={}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_ENABLE_CACHING, enabled });

        log.debug("successfully set caching status", .{});
    }

    pub fn optionGetCachedMemory(self: Handle) !CachedMemory {
        _ = self;

        log.debug("Handle.optionGetCachedMemory called", .{});

        var result: CachedMemory = undefined;
        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_GET_CACHED_MEMORY, &result.current, &result.allowed });

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
            raw.GIT_OPT_GET_TEMPLATE_PATH,
            @ptrCast(*raw.git_buf, &result),
        });

        log.debug("got template path: {s}", .{result.toSlice()});

        return result;
    }

    pub fn optionSetTemplatePath(self: Handle, path: [:0]const u8) !void {
        _ = self;

        log.debug("Handle.optionSetTemplatePath called, path={s}", .{path});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_TEMPLATE_PATH, path.ptr });

        log.debug("successfully set template path", .{});
    }

    /// Either parameter may be `null`, but not both.
    pub fn optionSetSslCertLocations(self: Handle, file: ?[:0]const u8, path: ?[:0]const u8) !void {
        _ = self;

        log.debug("Handle.optionSetSslCertLocations called, file={s}, path={s}", .{ file, path });

        const file_c: [*c]const u8 = if (file) |ptr| ptr.ptr else null;
        const path_c: [*c]const u8 = if (path) |ptr| ptr.ptr else null;
        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_SSL_CERT_LOCATIONS, file_c, path_c });

        log.debug("successfully set ssl certificate location", .{});
    }

    pub fn optionSetUserAgent(self: Handle, user_agent: [:0]const u8) !void {
        _ = self;

        log.debug("Handle.optionSetUserAgent called, user_agent={s}", .{user_agent});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_USER_AGENT, user_agent.ptr });

        log.debug("successfully set user agent", .{});
    }

    pub fn optionGetUserAgent(self: Handle) !git.Buf {
        _ = self;

        log.debug("Handle.optionGetUserAgent called", .{});

        var result: git.Buf = .{};
        try internal.wrapCall("git_libgit2_opts", .{
            raw.GIT_OPT_GET_USER_AGENT,
            @ptrCast(*raw.git_buf, &result),
        });

        log.debug("got user agent: {s}", .{result.toSlice()});

        return result;
    }

    pub fn optionSetWindowsSharemode(self: Handle, value: c_uint) !void {
        _ = self;

        log.debug("Handle.optionSetWindowsSharemode called, value={}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_WINDOWS_SHAREMODE, value });

        log.debug("successfully set windows share mode", .{});
    }

    pub fn optionGetWindowSharemode(self: Handle) !c_uint {
        _ = self;

        log.debug("Handle.optionGetWindowSharemode called", .{});

        var result: c_uint = undefined;
        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_GET_WINDOWS_SHAREMODE, &result });

        log.debug("got windows share mode: {}", .{result});

        return result;
    }

    pub fn optionSetStrictObjectCreation(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetStrictObjectCreation called, enabled={}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_ENABLE_STRICT_OBJECT_CREATION, @boolToInt(enabled) });

        log.debug("successfully set strict object creation mode", .{});
    }

    pub fn optionSetStrictSymbolicRefCreations(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetStrictSymbolicRefCreations called, enabled={}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_ENABLE_STRICT_SYMBOLIC_REF_CREATION, @boolToInt(enabled) });

        log.debug("successfully set strict symbolic ref creation mode", .{});
    }

    pub fn optionSetSslCiphers(self: Handle, ciphers: [:0]const u8) !void {
        _ = self;

        log.debug("Handle.optionSetSslCiphers called, ciphers={s}", .{ciphers});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_SSL_CIPHERS, ciphers.ptr });

        log.debug("successfully set SSL ciphers", .{});
    }

    pub fn optionSetOffsetDeltas(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetOffsetDeltas called, enabled={}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_ENABLE_OFS_DELTA, @boolToInt(enabled) });

        log.debug("successfully set offset deltas mode", .{});
    }

    pub fn optionSetFsyncDir(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetFsyncDir called, enabled={}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_ENABLE_FSYNC_GITDIR, @boolToInt(enabled) });

        log.debug("successfully set fsync dir mode", .{});
    }

    pub fn optionSetStrictHashVerification(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetStrictHashVerification called, enabled={}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_ENABLE_STRICT_HASH_VERIFICATION, @boolToInt(enabled) });

        log.debug("successfully set strict hash verification mode", .{});
    }

    /// If the given `allocator` is `null`, then the system default will be restored.
    pub fn optionSetAllocator(self: Handle, allocator: ?*git.GitAllocator) !void {
        _ = self;

        log.debug("Handle.optionSetAllocator called, allocator={*}", .{allocator});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_ALLOCATOR, allocator });

        log.debug("successfully set allocator", .{});
    }

    pub fn optionSetUnsafedIndexSafety(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetUnsafedIndexSafety called, enabled={}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_ENABLE_UNSAVED_INDEX_SAFETY, @boolToInt(enabled) });

        log.debug("successfully set unsaved index safety mode", .{});
    }

    pub fn optionGetMaximumPackObjects(self: Handle) !usize {
        _ = self;

        log.debug("Handle.optionGetMaximumPackObjects called", .{});

        var result: usize = undefined;
        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_GET_PACK_MAX_OBJECTS, &result });

        log.debug("maximum pack objects: {}", .{result});

        return result;
    }

    pub fn optionSetMaximumPackObjects(self: Handle, value: usize) !void {
        _ = self;

        log.debug("Handle.optionSetMaximumPackObjects called, value={}", .{value});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_PACK_MAX_OBJECTS, value });

        log.debug("successfully set maximum pack objects", .{});
    }

    pub fn optionSetDisablePackKeepFileChecks(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetDisablePackKeepFileChecks called, enabled={}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_DISABLE_PACK_KEEP_FILE_CHECKS, @boolToInt(enabled) });

        log.debug("successfully set unsaved index safety mode", .{});
    }

    pub fn optionSetHTTPExpectContinue(self: Handle, enabled: bool) !void {
        _ = self;

        log.debug("Handle.optionSetHTTPExpectContinue called, enabled={}", .{enabled});

        try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_ENABLE_HTTP_EXPECT_CONTINUE, @boolToInt(enabled) });

        log.debug("successfully set HTTP expect continue mode", .{});
    }

    pub usingnamespace if (internal.available(.@"1.2.0")) struct {
        pub fn branchNameIsValid(name: [:0]const u8) !bool {
            log.debug("Handle.branchNameIsValid, name={s}", .{name});

            var valid: c_int = undefined;
            try internal.wrapCall("git_branch_name_is_valid", .{ &valid, name.ptr });

            const ret = valid == 1;

            log.debug("branch name valid: {}", .{ret});

            return ret;
        }

        pub fn optionSetOdbPackedPriority(self: Handle, value: usize) !void {
            _ = self;

            log.debug("Handle.optionSetOdbPackedPriority called, value={}", .{value});

            try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_ODB_PACKED_PRIORITY, value });

            log.debug("successfully set odb packed priority", .{});
        }

        pub fn optionSetOdbLoosePriority(self: Handle, value: usize) !void {
            _ = self;

            log.debug("Handle.optionSetOdbLoosePriority called, value={}", .{value});

            try internal.wrapCall("git_libgit2_opts", .{ raw.GIT_OPT_SET_ODB_LOOSE_PRIORITY, value });

            log.debug("successfully set odb loose priority", .{});
        }
    } else struct {};

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
