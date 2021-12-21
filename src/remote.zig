const std = @import("std");
const git = @import("git.zig");
const c = @import("internal/c.zig");

pub const Remote = opaque {
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
        /// GIT_PASSTHROUGH will make libgit2 behave as though this field isn't set.
        ///
        /// Return 0 for success, < 0 to indicate an error, > 0 to indicate no credential was acquired
        /// Returning `GIT_PASSTHROUGH` will make libgit2 behave as though this field isn't set.
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
        pack_progress: ?fn (stage: git.PackbuildStage, current: u32, total: u32, payload: ?*anyopaque) callconv(.C) c_int = null,

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
        /// Return 0 on success, `GIT_PASSTHROUGH` or an error
        /// If you return `GIT_PASSTHROUGH`, you don't need to write anything to url_resolved.
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

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
