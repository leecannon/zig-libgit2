const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Remote = opaque {
    /// Free the memory associated with a remote.
    pub fn deinit(self: *Remote) !void {
        log.debug("Remote.deinit called", .{});

        c.git_remote_free(@ptrCast(*c.git_remote, self));

        log.debug("remote closed successfully", .{});
    }

    /// Add a fetch refspec to the remote's configuration.
    ///
    /// ## Parameters
    /// * `remote` - Name of the remote to change.
    /// * `refspec` - The new fetch refspec.
    pub fn addFetch(repository: *git.Repository, remote: [:0]const u8, refspec: [:0]const u8) !void {
        log.debug("Remote.addFetch called, remote={s}, refspec={s}", .{ remote, refspec });

        try internal.wrapCall("git_remote_add_fetch", .{
            @ptrCast(*c.git_repository, repository),
            remote.ptr,
            refspec.ptr,
        });

        log.debug("successfully added fetch", .{});
    }

    /// Add a pull refspec to the remote's configuration.
    ///
    /// ## Parameters
    /// * `remote` - Name of the remote to change.
    /// * `refspec` - The new pull refspec.
    pub fn addPush(repository: *git.Repository, remote: [:0]const u8, refspec: [:0]const u8) !void {
        log.debug("Remote.addPush called, remote={s}, refspecs={s}", .{ remote, refspec });

        try internal.wrapCall("git_remote_add_push", .{
            @ptrCast(*c.git_repository, repository),
            remote.ptr,
            refspec.ptr,
        });

        log.debug("successfully added pull", .{});
    }

    const AutotagOption = enum(c_uint) {
        DOWNLOAD_TAGS_UNSPECIFIED,
        DOWNLOAD_TAGS_AUTO,
        DOWNLOAD_TAGS_NONE,
        DOWNLOAD_TAGS_ALL,
    };

    /// Retrieve the tag auto-follow setting.
    pub fn autotag(self: *const Remote) AutotagOption {
        log.debug("Remote.autotag called", .{});

        var res = c.git_remote_autotag(@ptrCast(*const c.git_remote, self));
        return @intToEnum(AutotagOption, res);
    }

    /// Open a connection to a remote.
    ///
    /// ## Parameters
    /// * `direction` - FETCH if you want to fetch or PUSH if you want to push.
    /// * `callbacks` - The callbacks to use for this connection.
    /// * `proxy_opts` - Proxy settings.
    /// * `custom_headers` - Extra HTTP headers to use in this connection.
    pub fn connect(
        self: *Remote,
        direction: git.Direction,
        callbacks: RemoteCallbacks,
        proxy_opts: git.ProxyOptions,
        custom_headers: *git.StrArray,
    ) !void {
        log.debug("Remote.connect called, direction={}, proxy_opts: {}", .{ direction, proxy_opts });

        try internal.wrapCall("git_remote_connect", .{
            @ptrCast(*c.git_remote, self),
            @enumToInt(direction),
            &callbacks.makeCOptionsObject(),
            &proxy_opts.makeCOptionsObject(),
            @ptrCast(*c.git_strarray, custom_headers),
        });

        log.debug("successfully made connection", .{});
    }

    /// Check whether the remote is connected.
    pub fn connected(self: *const Remote) !bool {
        log.debug("Remote.connected called", .{});

        var res = try internal.wrapCallWithReturn("git_remote_connected", .{
            @ptrCast(*const c.git_remote, self),
        });

        log.debug("connected={}", .{res != 0});
        return res != 0;
    }

    /// Add a remote with the default fetch refspec to the repository's configuration.
    ///
    /// ## Parameters
    /// * `repository` - The repository in which to create the remote.
    /// * `name` - The remote's name.
    /// * `url` - The remote's url.
    pub fn create(repository: *git.Repository, name: [:0]const u8, url: [:0]const u8) !*Remote {
        log.debug("Remote.create called, name={s}, url={s}", .{ name, url });

        var remote: *Remote = undefined;
        try internal.wrapCall("git_remote_create", .{
            @ptrCast([*c]?*c.git_remote, &remote),
            @ptrCast(*c.git_repository, repository),
            name.ptr,
            url.ptr,
        });

        log.debug("successfully created remote", .{});
        return remote;
    }

    /// Create a remote with the given url in-memory. You can use this when you have a url instead of a remote's name.
    ///
    /// ## Parameters
    /// * `repository` - The repository in which to create the remote.
    /// * `name` - The remote's name.
    /// * `url` - The remote's url.
    pub fn createAnonymous(repository: *git.Repository, url: [:0]const u8) !*Remote {
        log.debug("Remote.createAnonymous called, url={s}", .{url});

        var remote: *Remote = undefined;
        try internal.wrapCall("git_remote_create_anonymous", .{
            @ptrCast([*c]?*c.git_remote, &remote),
            @ptrCast(*c.git_repository, repository),
            url.ptr,
        });

        log.debug("successfully created remote", .{});
        return remote;
    }

    /// Create a remote without a connected local repo.
    ///
    /// Create a remote with the given url in-memory. You can use this when you have a URL instead of a remote's name.
    ///
    /// Contrasted with git_remote_create_anonymous, a detached remote will not consider any repo configuration values
    /// (such as insteadof url substitutions).
    ///
    /// ## Parameters
    /// * `url` - The remote's url.
    pub fn createDetached(url: [:0]const u8) !*Remote {
        log.debug("Remote.createDetached called, url={s}", .{url});

        var remote: *Remote = undefined;
        try internal.wrapCall("git_remote_create_detached", .{
            @ptrCast([*c]?*c.git_remote, &remote),
            url.ptr,
        });

        log.debug("successfully created remote", .{});
        return remote;
    }

    /// Add a remote with the provided refspec (or default if NULL) to the repository's configuration.
    ///
    /// ## Parameters
    /// * `repository` - The repository in which to create the remote.
    /// * `name` - The remote's name.
    /// * `url` - The remote's url.
    /// * `fetch` - The remote fetch value.
    pub fn createWithFetchspec(repository: *git.Repository, name: [:0]const u8, url: [:0]const u8, fetchspec: [:0]const u8) !*Remote {
        log.debug("Remote.createDetached called, name={s}, url={s}, fetch={s}", .{ name, url, fetchspec });

        var remote: *Remote = undefined;
        try internal.wrapCall("git_remote_create_with_fetchspec", .{
            @ptrCast([*c]?*c.git_remote, &remote),
            @ptrCast(*c.git_repository, repository),
            name.ptr,
            url.ptr,
            fetchspec.ptr,
        });

        log.debug("successfully created remote", .{});
        return remote;
    }

    /// Remote creation options flags.
    pub const CreateFlags = packed struct {
        /// Ignore the repository apply.insteadOf configuration.
        SKIP_INSTEADOF: bool = false,

        /// Don't build a fetchspec from the name if none is set.
        SKIP_DEFAULT_FETCHSPEC: bool = false,

        z_padding: u30 = 0,

        comptime {
            std.testing.refAllDecls(@This());
            std.debug.assert(@sizeOf(c_uint) == @sizeOf(CreateFlags));
            std.debug.assert(@bitSizeOf(c_uint) == @bitSizeOf(CreateFlags));
        }
    };

    /// Remote creation options structure.
    pub const CreateOptions = struct {
        repository: *git.Repository,
        name: []const u8,
        fetchspec: []const u8,
        flags: CreateFlags = .{},

        pub fn makeCOptionsObject(self: CreateOptions) c.git_remote_create_options {
            return .{
                .version = c.GIT_STATUS_OPTIONS_VERSION,
                .repository = @ptrCast(*c.git_repository, self.repository),
                .name = self.name.ptr,
                .fetchspec = self.fetchspec.ptr,
                .flags = @bitCast(c_uint, self.flags),
            };
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Create a remote, with options.
    ///
    /// This function allows more fine-grained control over the remote creation.
    ///
    /// Passing NULL as the opts argument will result in a detached remote.
    ///
    /// ## Parameters
    /// * `url` - The remote's url.
    /// * `options` - The remote creation options.
    pub fn createWithOpts(url: [:0]const u8, options: CreateOptions) !*Remote {
        log.debug("Remote.createDetached called, url={s}, options={}", .{ url, options });

        var remote: *Remote = undefined;
        try internal.wrapCall("git_remote_create_with_opts", .{
            @ptrCast([*c]?*c.git_remote, &remote),
            url.ptr,
            @ptrCast(*c.git_remote_create_options, &options.makeCOptionsObject()),
        });

        log.debug("successfully created remote", .{});
        return remote;
    }

    /// Retrieve the name of the remote's default branch
    ///
    /// The default branch of a repository is the branch which HEAD points to. If the remote does not support reporting this information directly, it performs the guess as git does; that is, if there are multiple branches which point to the same commit, the first one is chosen. If the master branch is a candidate, it wins.
    ///
    /// This function must only be called after connecting.
    pub fn defaultBranch(self: *Remote) !git.Buf {
        log.debug("Remote.defaultBranch called", .{});

        var buf = git.Buf{};
        try internal.wrapCall("git_remote_default_branch", .{
            @ptrCast(*c.git_buf, &buf),
            @ptrCast(*c.git_remote, self),
        });

        log.debug("successfully found default branch={s}", .{buf.toSlice()});
        return buf;
    }

    /// Delete an existing persisted remote.
    ///
    /// All remote-tracking branches and configuration settings for the remote will be removed.
    ///
    /// ## Parameters
    /// * `name` - The remote to delete
    pub fn delete(repository: *git.Repository, name: [:0]const u8) !void {
        log.debug("Remote.delete called, name={s}", .{name});

        try internal.wrapCall("git_remote_delete", .{
            @ptrCast(*c.git_repository, repository),
            name.ptr,
        });

        log.debug("successfully deleted remote", .{});
    }

    /// Close the connection to the remote.
    pub fn disconnect(self: *Remote) !void {
        log.debug("Remote.diconnect called", .{});
        try internal.wrapCall("git_remote_disconnect", .{
            @ptrCast(*c.git_remote, self),
        });
        log.debug("successfully disconnected remote", .{});
    }

    /// Download and index the packfile
    ///
    /// Connect to the remote if it hasn't been done yet, negotiate with the remote git which objects are missing,
    /// download and index the packfile.
    ///
    /// The .idx file will be created and both it and the packfile with be renamed to their final name.
    ///
    /// ## Parameters
    /// * `refspecs` - the refspecs to use for this negotiation and download. Use NULL or an empty array to use the
    ///    base refspecs
    /// * `options` - the options to use for this fetch
    pub fn download(self: *Remote, refspecs: *git.StrArray, options: FetchOptions) !void {
        log.debug("Remote.download called, options={}", .{options});

        try internal.wrapCall("git_remote_download", .{
            @ptrCast(*c.git_remote, self),
            @ptrCast(*c.git_strarray, refspecs),
            &options.makeCOptionsObject(),
        });

        log.debug("successfully downloaded remote", .{});
    }

    /// Create a copy of an existing remote. All internal strings are also duplicated. Callbacks are not duplicated.
    pub fn dupe(self: *Remote) !*Remote {
        log.debug("Remote.dupe called", .{});

        var remote: *Remote = undefined;
        try internal.wrapCall("git_remote_dup", .{
            @ptrCast([*c]?*c.git_remote, &remote),
            @ptrCast(*c.git_remote, self),
        });

        log.debug("successfully duplicated remote", .{});
        return remote;
    }

    /// Fetch options structure.
    pub const FetchOptions = struct {
        /// Callbacks to use for this fetch operation.
        callbacks: RemoteCallbacks = .{},

        /// Whether to perform a prune after the fetch.
        prune: FetchPrune = .UNSPECIFIED,

        /// Whether to write the results to FETCH_HEAD. Defaults to on. Leave this default to behave like git.
        update_fetchhead: bool = false,

        /// Determines how to behave regarding tags on the remote, such as auto-dowloading tags for objects we're
        /// downloading or downloading all of them. The default is to auto-follow tags.
        download_tags: AutoTagOption = .UNSPECIFIED,

        /// Proxy options to use, bu default no proxy is used.
        proxy_opts: git.ProxyOptions = .{},

        /// Extra headers for this fetch operation.
        custom_headers: git.StrArray = .{},

        /// Acceptable prune settings from the configuration.
        pub const FetchPrune = enum(c_uint) {
            /// Use the setting from the configuration.
            UNSPECIFIED = 0,

            /// Force pruning on.
            PRUNE,

            /// Force pruning off.
            NO_PRUNE,
        };

        /// Automatic tag following option.
        pub const AutoTagOption = enum(c_uint) {
            /// Use the setting from the configuration.
            UNSPECIFIED = 0,

            /// Ask the server for tags pointing to objects we're already downloading.
            AUTO,

            /// Don't ask for any tags beyond the refspecs.
            NONE,

            /// Ask for all the tags.
            ALL,
        };

        pub fn makeCOptionsObject(self: FetchOptions) c.git_fetch_options {
            return .{
                .version = c.GIT_FETCH_OPTIONS_VERSION,
                .callbacks = self.callbacks.makeCOptionsObject(),
                .prune = @enumToInt(self.prune),
                .update_fetchhead = @boolToInt(self.update_fetchhead),
                .download_tags = @enumToInt(self.download_tags),
                .proxy_opts = self.proxy_opts.makeCOptionsObject(),
                .custom_headers = @bitCast(c.git_strarray, self.custom_headers),
            };
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Download new data and update tips.
    ///
    /// ## Parameters
    /// * `refspecs` - The refspecs to use for this fetch. Pass null or an empty array to use the base refspecs.
    /// * `options` - Options to use for this fetch.
    /// * `reflog_message` - The message to insert into the reflogs. If null, the default is "fetch".
    pub fn fetch(self: *Remote, refspecs: ?*git.StrArray, options: FetchOptions, reflog_message: [:0]const u8) !void {
        log.debug("Remote.fetch called, options={}", .{options});

        try internal.wrapCall("git_remote_fetch", .{
            @ptrCast(*c.git_remote, self),
            @ptrCast(*c.git_strarray, refspecs),
            &options.makeCOptionsObject(),
            reflog_message.ptr,
        });

        log.debug("successfully fetched remote", .{});
    }

    /// Get the remote's list of fetch refspecs.
    ///
    /// The memory is owned by the caller and should be free with StrArray.deinit.
    pub fn getFetchRefspecs(self: *Remote) !git.StrArray {
        log.debug("Remote.getFetchRefspecs called", .{});

        var ret: git.StrArray = undefined;
        try internal.wrapCall("git_remote_get_fetch_refspecs", .{
            @ptrCast(*c.git_strarray, &ret),
            @ptrCast(*c.git_remote, self),
        });

        log.debug("successfully got fetch refspecs", .{});
        return ret;
    }

    /// Get the remote's list of push refspecs.
    ///
    /// The memory is owned by the caller and should be free with StrArray.deinit.
    pub fn getPushRefspecs(self: *Remote) !git.StrArray {
        log.debug("Remote.getPushRefspecs called", .{});

        var ret: git.StrArray = undefined;
        try internal.wrapCall("git_remote_get_push_refspecs", .{
            @ptrCast(*c.git_strarray, &ret),
            @ptrCast(*c.git_remote, self),
        });

        log.debug("successfully got push refspecs", .{});
        return ret;
    }

    /// Get a refspec from the remote
    ///
    /// ## Parameters
    /// * `n` - The refspec to get.
    pub fn getRefspecs(self: *const Remote, n: usize) ?*const git.Refspec {
        log.debug("Remote.getRefspecs called", .{});

        var ret = c.git_remote_get_refspec(@ptrCast(*const c.git_remote, self), n);
        return @ptrCast(?*const git.Refspec, ret);
    }

    /// Get a list of the configured remotes for a repo
    ///
    /// The returned array must be deinit by user.
    pub fn list(repo: *git.Repository) !git.StrArray {
        log.debug("Remote.list called", .{});

        var str: git.StrArray = undefined;
        try internal.wrapCall("git_remote_list", .{
            @ptrCast(*c.git_strarray, &str),
            @ptrCast(*c.git_repository, repo),
        });

        log.debug("successfully got remotes list", .{});
        return str;
    }

    /// Get the information for a particular remote.
    ///
    /// ## Parameters
    /// * `name` - The remote's name
    pub fn lookup(repository: *git.Repository, name: [:0]const u8) !*Remote {
        log.debug("Remote.lookup called, name=\"{s}\"", .{name});

        var remote: *Remote = undefined;
        try internal.wrapCall("git_remote_lookup", .{
            @ptrCast([*c]?*c.git_remote, &remote),
            @ptrCast(*c.git_repository, repository),
            name.ptr,
        });

        log.debug("successfully found remote", .{});
        return remote;
    }

    /// Description of a reference advertised by a remote server, given out on `ls` calls.
    pub const Head = extern struct {
        local: c_int,
        oid: git.Oid,
        loid: git.Oid,
        name: [*:0]u8,
        symref_trget: [*:0]u8,
    };

    /// Get the remote repository's reference advertisement list
    ///
    /// Get the list of references with which the server responds to a new connection.
    ///
    /// The remote (or more exactly its transport) must have connected to the remote repository. This list is available
    /// as soon as the connection to the remote is initiated and it remains available after disconnecting.
    ///
    /// The memory belongs to the remote. The pointer will be valid as long as a new connection is not initiated, but
    /// it is recommended that you make a copy in order to make use of the data.
    pub fn ls(self: *Remote) ![]*Head {
        log.debug("Remote.ls called", .{});

        var head_ptr: [*c]*Head = undefined;
        var head_n: usize = undefined;
        try internal.wrapCall("git_remote_ls", .{
            @ptrCast([*c][*c][*c]c.git_remote_head, &head_ptr),
            &head_n,
            @ptrCast(*c.git_remote, self),
        });

        log.debug("successfully found heads", .{});
        return head_ptr[0..head_n];
    }

    /// Get the remote's name.
    pub fn getName(self: *const Remote) ?[:0]const u8 {
        log.debug("Remote.getName called", .{});

        var ret_c = c.git_remote_name(@ptrCast(*const c.git_remote, self));
        const ret = if (ret_c) |r| std.mem.span(r) else null;

        log.debug("name={s}", .{ret});
        return ret;
    }

    /// Get the remote's repository.
    pub fn getOwner(self: *const Remote) ?*git.Repository {
        log.debug("Remote.owner called", .{});

        var ret = @ptrCast(?*git.Repository, c.git_remote_owner(@ptrCast(*const c.git_remote, self)));
        return ret;
    }

    /// Prune tracking refs that are no longer present on remote.
    ///
    /// ## Parameters
    /// * `callbacks` - Callbacks to use for this prune.
    pub fn prune(self: *Remote, callbacks: RemoteCallbacks) !void {
        log.debug("Remote.prune called", .{});

        try internal.wrapCall("git_remote_prune", .{
            @ptrCast(*c.git_remote, self),
            &callbacks.makeCOptionsObject(),
        });

        log.debug("successfully pruned remote", .{});
    }

    /// Retrieve the ref-prune setting.
    pub fn getPruneRefs(self: *const Remote) c_int {
        log.debug("Remote.getPruneRefs called", .{});
        return c.git_remote_prune_refs(@ptrCast(*const c.git_remote, self));
    }

    pub const PushOptions = struct {
        /// If the transport being used to push to the remote requires the creation of a pack file, this controls the
        /// number of worker threads used by the packbuilder when creating that pack file to be sent to the remote. If
        /// set to 0, the packbuilder will auto-detect the number of threads to create. The default value is 1.
        pb_parallelism: c_uint = 1,

        ///Callbacks to use for this push operation
        callbacks: RemoteCallbacks = .{},

        ///Proxy options to use, by default no proxy is used.
        proxy_opts: git.ProxyOptions = .{},

        ///Extra headers for this push operation
        custom_headers: git.StrArray = .{},

        pub fn makeCOptionsObject(self: PushOptions) c.git_push_options {
            return .{
                .version = c.GIT_PUSH_OPTIONS_VERSION,
                .pb_parallelism = self.pb_parallelism,
                .callbacks = self.callbacks.makeCOptionsObject(),
                .proxy_opts = self.proxy_opts.makeCOptionsObject(),
                .custom_headers = @bitCast(c.git_strarray, self.custom_headers),
            };
        }
    };

    /// Preform a push.
    ///
    /// ## Parameters
    /// * `refspecs` - The refspecs to use for pushing. If NULL or an empty array, the configured refspecs will be used.
    /// * `options`  - The options to use for this push.
    pub fn push(self: *Remote, refspecs: ?*git.StrArray, options: PushOptions) !void {
        log.debug("Remote.push called, options={}", .{options});

        try internal.wrapCall("git_remote_push", .{
            @ptrCast(*c.git_remote, self),
            @ptrCast(*c.git_strarray, refspecs),
            &options.makeCOptionsObject(),
        });

        log.debug("successfully pushed remote", .{});
    }

    /// Get the remote's url for pushing.
    pub fn getPushUrl(self: *const Remote) ?[:0]const u8 {
        log.debug("Remote.getPushUrl called", .{});
        var ret = c.git_remote_pushurl(@ptrCast(*const c.git_remote, self));
        return if (ret) |r| std.mem.span(r) else null;
    }

    /// Get the number of refspecs for a remote.
    pub fn getRefspecCount(self: *const Remote) usize {
        log.debug("Remote.getRefspecsCount called", .{});
        return c.git_remote_refspec_count(@ptrCast(*const c.git_remote, self));
    }

    /// Give the remote a new name
    ///
    /// All remote-tracking branches and configuration settings for the remote are updated.
    ///
    /// The new name will be checked for validity. See git_tag_create() for rules about valid names.
    ///
    /// No loaded instances of a the remote with the old name will change their name or their list of refspecs.
    ///
    /// ## Problems
    /// * `problems` - non-default refspecs cannot be renamed and will be stored here for further processing by the
    ///   caller. Always free this strarray on successful return.
    /// * `repository` - the repository in which to rename
    /// * `name` - the current name of the remote
    /// * `new_name` - the new name the remote should bear
    pub fn rename(problems: *git.StrArray, repository: *git.Repository, name: [:0]const u8, new_name: [:0]const u8) !void {
        log.debug("Remote.rename called, name={s}, new_name={s}", .{ name, new_name });

        try internal.wrapCall("git_remote_rename", .{
            @ptrCast(*c.git_strarray, problems),
            @ptrCast(*c.git_repository, repository),
            name.ptr,
            new_name.ptr,
        });

        log.debug("successfully renamed", .{});
    }

    /// Set the remote's tag following setting.
    ///
    /// The change will be made in the configuration. No loaded remotes will be affected.
    ///
    /// ## Parameters
    /// * `repository` - The repository in which to make the change.
    /// * `remote` - The name of the remote.
    /// * `value` - The new value to take.
    pub fn setAutotag(repository: *git.Repository, remote: [:0]const u8, value: AutotagOption) !void {
        log.debug("Remote.setAutotag called, remote={s}, value={s}", .{ remote, @tagName(value) });

        try internal.wrapCall("git_remote_set_autotag", .{
            @ptrCast(*c.git_repository, repository),
            remote.ptr,
            @enumToInt(value),
        });

        log.debug("successfully set autotag", .{});
    }

    /// Set the remote's url for pushing in the configuration.
    ///
    /// ## Parameters
    /// * `repository` - The repository in which to perform the change.
    /// * `remote` - The remote's name.
    /// * `url` - The url to set.
    pub fn setPushurl(repository: *git.Repository, remote: [:0]const u8, url: [:0]const u8) !void {
        log.debug("Remote.setPushurl called, remote={s}, url={s}", .{ remote, url });

        try internal.wrapCall("git_remote_set_pushurl", .{
            @ptrCast(*c.git_repository, repository),
            remote.ptr,
            url.ptr,
        });

        log.debug("successfully set pushurl", .{});
    }

    /// Set the remote's url in the configuration
    ///
    /// ## Parameters
    /// * `repository` - The repository in which to perform the change.
    /// * `remote` - The remote's name.
    /// * `url` - The url to set.
    pub fn setUrl(repository: *git.Repository, remote: [:0]const u8, url: [:0]const u8) !void {
        log.debug("Remote.setUrl called, remote={s}, url={s}", .{ remote, url });

        try internal.wrapCall("git_remote_set_url", .{
            @ptrCast(*c.git_repository, repository),
            remote.ptr,
            url.ptr,
        });

        log.debug("successfully set url", .{});
    }

    /// Get the statistics structure that is filled in by the fetch operation.
    pub fn getStats(self: *Remote) ?*const git.Indexer.Progress {
        var ret: ?*const c.git_indexer_progress = c.git_remote_stats(@ptrCast(*c.git_remote, self));
        return @ptrCast(?*const git.Indexer.Progress, ret);
    }

    /// Cancel the operation.
    ///
    /// At certain points in its operation, the network code checks whether the operation has been cancelled and if so
    /// stops the operation.
    pub fn stop(self: *Remote) !void {
        log.debug("Remote.stop called", .{});

        try internal.wrapCall("git_remote_stop", .{
            @ptrCast(*c.git_remote, self),
        });

        log.debug("successfully stopped remote operation", .{});
    }

    /// Update the tips to the new state.
    ///
    /// ## Parameters
    /// * `callbacks` pointer to the callback structure to use
    /// * `update_fetchhead` whether to write to FETCH_HEAD. Pass true to behave like git.
    /// * `download_tags` what the behaviour for downloading tags is for this fetch. This is ignored for push. This must be the same value passed to `git_remote_download()`.
    /// * `reflog_message` The message to insert into the reflogs. If NULL and fetching, the default is "fetch ", where is the name of the remote (or its url, for in-memory remotes). This parameter is ignored when pushing.
    pub fn updateTips(
        self: *Remote,
        callbacks: RemoteCallbacks,
        update_fetchead: bool,
        download_tags: AutotagOption,
        reflog_message: [:0]const u8,
    ) !void {
        log.debug("Remote.updateTips called, update_fetchhead={}, download_tags={s}, reflog_message={s}", .{ update_fetchead, @tagName(download_tags), reflog_message });

        try internal.wrapCall("git_remote_update_tips", .{
            @ptrCast(*c.git_remote, self),
            &callbacks.makeCOptionsObject(),
            @boolToInt(update_fetchead),
            @enumToInt(download_tags),
            reflog_message.ptr,
        });

        log.debug("successfully updated tips", .{});
    }

    /// Create a packfile and send it to the server
    ///
    /// Connect to the remote if it hasn't been done yet, negotiate with the remote git which objects are missing, create a packfile with the missing objects and send it.
    ///
    /// ## Parameters
    /// * remote - The remote.
    /// * refspecs - The refspecs to use for this negotiation and upload. Use NULL or an empty array to use the base
    ///  refspecs.
    /// * options - The options to use for this push.
    pub fn upload(self: *Remote, refspecs: *git.StrArray, options: PushOptions) !void {
        log.debug("Remote.upload called, options={}", .{options});

        try internal.wrapCall("git_remote_upload", .{
            @ptrCast(*c.git_remote, self),
            @ptrCast(*c.git_strarray, refspecs),
            &options.makeCOptionsObject(),
        });
        log.debug("successfully completed upload", .{});
    }

    /// Get the remote's url
    ///
    /// If url.*.insteadOf has been configured for this URL, it will return the modified URL. If
    /// git_remote_set_instance_pushurl has been called for this remote, then that URL will be returned.
    pub fn getUrl(self: *const Remote) ?[:0]const u8 {
        var ret = c.git_remote_url(@ptrCast(*const c.git_remote, self));
        return if (ret) |r| std.mem.span(r) else null;
    }

    /// Argument to the completion callback which tells it which operation finished.
    pub const RemoteCompletion = enum(c_uint) {
        DOWNLOAD,
        INDEXING,
        ERROR,
    };

    /// Set the callbacks to be called by the remote when informing the user about the proogress of the networking
    /// operations.
    pub const RemoteCallbacks = struct {
        /// Textual progress from the remote. Text send over the progress side-band will be passed to this function (this is
        /// the 'counting objects' output).
        ///
        /// Return a negative value to cancel the network operation.
        ///
        /// ## Parameters
        /// * `str` - The message from the transport
        /// * `len` - The length of the message
        /// * `payload` - Payload provided by the caller
        sideband_progress: ?fn (str: [*:0]const u8, len: c_uint, payload: ?*anyopaque) callconv(.C) c_int = null,

        /// Completion is called when different parts of the download process are done (currently unused).
        completion: ?fn (@"type": RemoteCompletion, payload: ?*anyopaque) callconv(.C) c_int = null,

        /// This will be called if the remote host requires authentication in order to connect to it. Returning
        /// `GitError.Passthrough` will make libgit2 behave as though this field isn't set.
        ///
        /// Return 0 for success, < 0 to indicate an error, > 0 to indicate no credential was acquired
        /// Returning `GitError.Passthrough` will make libgit2 behave as though this field isn't set.
        ///
        /// ## Parameters
        /// * `out` - The newly created credential object.
        /// * `url` - The resource for which we are demanding a credential.
        /// * `username_from_url` - The username that was embedded in a "user\@host" remote url, or `null` if not included.
        /// * `allowed_types` - A bitmask stating which credential types are OK to return.
        /// * `payload` - The payload provided when specifying this callback.
        credentials: ?fn (
            out: **git.Credential,
            url: [*:0]const u8,
            username_from_url: [*:0]const u8,
            /// BUG: This is supposed to be `git.Credential.CredentialType`, but can't be due to a zig compiler bug
            allowed_types: c_uint,
            payload: ?*anyopaque,
        ) callconv(.C) c_int = null,

        /// If cert verification fails, this will be called to let the user make the final decision of whether to allow the
        /// connection to proceed. Returns 0 to allow the connection or a negative value to indicate an error.
        ///
        /// Return 0 to proceed with the connection, < 0 to fail the connection or > 0 to indicate that the callback refused
        /// to act and that the existing validity determination should be honored
        ///
        /// ## Parameters
        /// * `cert` - The host certificate
        /// * `valid` - Whether the libgit2 checks (OpenSSL or WinHTTP) think this certificate is valid.
        /// * `host` - Hostname of the host libgit2 connected to
        /// * `payload` - Payload provided by the caller
        certificate_check: ?fn (
            cert: *git.Certificate,
            valid: bool,
            host: [*:0]const u8,
            payload: ?*anyopaque,
        ) callconv(.C) c_int = null,

        /// During the download of new data, this will be regularly called with the current count of progress done by the
        /// indexer.
        ///
        /// Return a value less than 0 to cancel the indexing or download.
        ///
        /// ## Parameters
        /// * `stats` - Structure containing information about the state of the transfer
        /// * `payload` - Payload provided by the caller
        transfer_progress: ?fn (stats: *const git.Indexer.Progress, payload: ?*anyopaque) callconv(.C) c_int = null,

        /// Each time a reference is updated locally, this function will be called with information about it.
        update_tips: ?fn (
            refname: [*:0]const u8,
            a: *const git.Oid,
            b: *const git.Oid,
            payload: ?*anyopaque,
        ) callconv(.C) c_int = null,

        /// Function to call with progress information during pack building. Be aware that this is called inline with pack
        /// building operations, so perfomance may be affected.
        pack_progress: ?fn (stage: git.PackbuilderStage, current: u32, total: u32, payload: ?*anyopaque) callconv(.C) c_int = null,

        /// Function to call with progress information during the upload portion nof a push. Be aware that this is called
        /// inline with pack building operations, so performance may be affected.
        push_transfer_progress: ?fn (current: c_uint, total: c_uint, size: usize, payload: ?*anyopaque) callconv(.C) c_int = null,

        /// Callback used to inform of the update status from the remote.
        ///
        /// Called for each updated reference on push. If `status` is not `null`, the update was rejected by the remote server
        /// and `status` contains the reason given.
        ///
        /// 0 on success, otherwise an error
        ///
        /// ## Parameters
        /// * `refname` - refname specifying to the remote ref
        /// * `status` - status message sent from the remote
        /// * `data` - data provided by the caller
        push_update_reference: ?fn (
            refname: [*:0]const u8,
            status: ?[*:0]const u8,
            data: ?*anyopaque,
        ) callconv(.C) c_int = null,

        /// Called once between the negotiation step and the upload. It provides information about what updates will be
        /// performed.
        /// Callback used to inform of upcoming updates.
        ///
        /// ## Parameters
        /// * `updates` - an array containing the updates which will be sent as commands to the destination.
        /// * `len` - number of elements in `updates`
        /// * `payload` - Payload provided by the caller
        push_negotiation: ?fn (updates: [*]*const PushUpdate, len: usize, payload: ?*anyopaque) callconv(.C) c_int = null,

        /// Create the transport to use for this operation. Leave `null` to auto-detect.
        transport: ?fn (out: **git.Transport, owner: *Remote, param: ?*anyopaque) callconv(.C) c_int = null,

        // This will be passed to each of the callbacks in this sruct as the last parameter.
        payload: ?*anyopaque = null,

        /// Resolve URL before connecting to remote. The returned URL will be used to connect to the remote instead. 
        /// This callback is deprecated; users should use git_remote_ready_cb and configure the instance URL instead.
        ///
        /// Return 0 on success, `GitError.Passthrough` or an error
        /// If you return `GitError.Passthrough`, you don't need to write anything to url_resolved.
        ///
        /// ## Parameters
        /// * `url_resolved` - The buffer to write the resolved URL to
        /// * `url` - The URL to resolve
        /// * `direction` - direction of the resolution
        /// * `payload` - Payload provided by the caller
        resolve_url: ?fn (
            url_resolved: *git.Buf,
            url: [*:0]const u8,
            direction: git.Direction,
            payload: ?*anyopaque,
        ) callconv(.C) c_int = null,

        pub fn makeCOptionsObject(self: RemoteCallbacks) c.git_remote_callbacks {
            return .{
                .version = c.GIT_CHECKOUT_OPTIONS_VERSION,
                .sideband_progress = @ptrCast(c.git_transport_message_cb, self.sideband_progress),
                .completion = @ptrCast(?fn (c.git_remote_completion_t, ?*anyopaque) callconv(.C) c_int, self.completion),
                .credentials = @ptrCast(c.git_credential_acquire_cb, self.credentials),
                .certificate_check = @ptrCast(c.git_transport_certificate_check_cb, self.certificate_check),
                .transfer_progress = @ptrCast(c.git_indexer_progress_cb, self.transfer_progress),
                .update_tips = @ptrCast(
                    ?fn ([*c]const u8, [*c]const c.git_oid, [*c]const c.git_oid, ?*anyopaque) callconv(.C) c_int,
                    self.update_tips,
                ),
                .pack_progress = @ptrCast(c.git_packbuilder_progress, self.pack_progress),
                .push_transfer_progress = @ptrCast(c.git_push_transfer_progress_cb, self.push_transfer_progress),
                .push_update_reference = @ptrCast(c.git_push_update_reference_cb, self.push_update_reference),
                .push_negotiation = @ptrCast(c.git_push_negotiation, self.push_negotiation),
                .transport = @ptrCast(c.git_transport_cb, self.transport),
                .payload = self.payload,
                .resolve_url = @ptrCast(c.git_url_resolve_cb, self.resolve_url),
            };
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    /// Represents an update which will be performed on the remote during push
    pub const PushUpdate = extern struct {
        /// The source name of the reference
        src_refname: [*:0]const u8,

        /// The name of the reference to update on the server
        dst_refname: [*:0]const u8,

        /// The current target of the reference
        src: git.Oid,

        /// The new target for the reference
        dst: git.Oid,

        test {
            try std.testing.expectEqual(@sizeOf(c.git_push_update), @sizeOf(PushUpdate));
            try std.testing.expectEqual(@bitSizeOf(c.git_push_update), @bitSizeOf(PushUpdate));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// A refspec specifies the mapping between remote and local reference names when fetch or pushing.
pub const Refspec = opaque {
    /// Free a refspec object  which has been created by Refspec.parse.
    pub fn deinit(self: *Refspec) void {
        log.debug("Refspec.deinit called", .{});

        c.git_refspec_free(@ptrCast(*c.git_refspec, self));

        log.debug("refspec freed successfully", .{});
    }

    /// Parse a given refspec string.
    ///
    /// ## Parameters
    /// * `input` the refspec string
    /// * `is_fetch` is this a refspec for a fetch
    pub fn parse(input: [:0]const u8, is_fetch: bool) !*Refspec {
        log.debug("Refspec.parse called, input: {s}, is_fetch={}", .{ input, is_fetch });

        var ret: *Refspec = undefined;

        try internal.wrapCall("git_refspec_parse", .{
            @ptrCast(*?*c.git_refspec, &ret),
            input.ptr,
            @boolToInt(is_fetch),
        });

        log.debug("successfully parsed refspec: {*}", .{ret});

        return ret;
    }

    /// Get the source specifier.
    pub fn source(self: *const Refspec) [:0]const u8 {
        log.debug("Refspec.source called", .{});

        const slice = std.mem.sliceTo(
            c.git_refspec_src(@ptrCast(
                *const c.git_refspec,
                self,
            )),
            0,
        );

        log.debug("source specifier: {s}", .{slice});

        return slice;
    }

    /// Get the destination specifier.
    pub fn destination(self: *const Refspec) [:0]const u8 {
        log.debug("Refspec.destination called", .{});

        const slice = std.mem.sliceTo(
            c.git_refspec_dst(@ptrCast(
                *const c.git_refspec,
                self,
            )),
            0,
        );

        log.debug("destination specifier: {s}", .{slice});

        return slice;
    }

    /// Get the refspec's string.
    pub fn string(self: *const Refspec) [:0]const u8 {
        log.debug("Refspec.string called", .{});

        const slice = std.mem.sliceTo(
            c.git_refspec_string(@ptrCast(
                *const c.git_refspec,
                self,
            )),
            0,
        );

        log.debug("refspec string: {s}", .{slice});

        return slice;
    }

    /// Get the force update setting.
    pub fn isForceUpdate(refspec: *const Refspec) bool {
        log.debug("Refspec.isForceUpdate called", .{});

        const ret = c.git_refspec_force(@ptrCast(*const c.git_refspec, refspec)) != 0;

        log.debug("is force update: {}", .{ret});

        return ret;
    }

    /// Get the refspec's direction.
    pub fn direction(refspec: *const Refspec) git.Direction {
        log.debug("Refspec.direction called", .{});

        const ret = @intToEnum(
            git.Direction,
            c.git_refspec_direction(@ptrCast(
                *const c.git_refspec,
                refspec,
            )),
        );

        log.debug("refspec direction: {}", .{ret});

        return ret;
    }

    /// Check if a refspec's source descriptor matches a reference
    pub fn srcMatches(refspec: *const Refspec, refname: [:0]const u8) bool {
        log.debug("Refspec.srcMatches called, refname={s}", .{refname});

        const ret = c.git_refspec_src_matches(
            @ptrCast(*const c.git_refspec, refspec),
            refname.ptr,
        ) != 0;

        log.debug("match: {}", .{ret});

        return ret;
    }

    /// Check if a refspec's destination descriptor matches a reference
    pub fn destMatches(refspec: *const Refspec, refname: [:0]const u8) bool {
        log.debug("Refspec.destMatches called, refname={s}", .{refname});

        const ret = c.git_refspec_dst_matches(
            @ptrCast(*const c.git_refspec, refspec),
            refname.ptr,
        ) != 0;

        log.debug("match: {}", .{ret});

        return ret;
    }

    /// Transform a reference to its target following the refspec's rules
    ///
    /// # Parameters
    /// * `name` - The name of the reference to transform.
    pub fn transform(refspec: *const Refspec, name: [:0]const u8) !git.Buf {
        log.debug("Refspec.transform called, name={s}", .{name});

        var ret: git.Buf = .{};

        try internal.wrapCall("git_refspec_transform", .{
            @ptrCast(*c.git_buf, &ret),
            @ptrCast(*const c.git_refspec, refspec),
            name.ptr,
        });

        log.debug("refspec transform completed, out={s}", .{ret.toSlice()});

        return ret;
    }

    /// Transform a target reference to its source reference following the refspec's rules
    ///
    /// # Parameters
    /// * `name` - The name of the reference to transform.
    pub fn rtransform(refspec: *const Refspec, name: [:0]const u8) !git.Buf {
        log.debug("Refspec.rtransform called, name={s}", .{name});

        var ret: git.Buf = .{};

        try internal.wrapCall("git_refspec_rtransform", .{
            @ptrCast(*c.git_buf, &ret),
            @ptrCast(*const c.git_refspec, refspec),
            name.ptr,
        });

        log.debug("refspec rtransform completed, out={s}", .{ret.toSlice()});
        return ret;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
