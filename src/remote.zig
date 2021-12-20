const std = @import("std");
const git = @import("git.zig");
const raw = @import("internal/raw.zig");

/// Fetch options structure.
pub const FetchOptions = struct {
    /// Callbacks to use for this fetch operation.
    callbacks: git.RemoteCallbacks = .{},

    /// Whether to perform a prune after the fetch.
    prune: FetchPrune = .UNSPECIFIED,

    /// Whether to write the results to FETCH_HEAD. Defaults to on. Leave this default to behave like git.
    update_fetchhead: bool = true,

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
        UNSPECIFIED,

        /// Force pruning on.
        PRUNE,

        /// Force pruning off.
        NO_PRUNE,
    };

    /// Automatic tag following option.
    pub const AutoTagOption = enum(c_uint) {
        /// Use the setting from the configuration.
        UNSPECIFIED,

        /// Ask the server for tags pointing to objects we're already downloading.
        AUTO,

        /// Don't ask for any tags beyond the refspecs.
        NONE,

        /// Ask for all the tags.
        ALL,
    };

    pub fn toC(self: FetchOptions) raw.git_fetch_options {
        return .{
            .version = raw.GIT_FETCH_OPTIONS_VERSION,
            .callbacks = self.callbacks.toC(),
            .prune = @enumToInt(self.prune),
            .update_fetchhead = @boolToInt(self.update_fetchhead),
            .download_tags = @enumToInt(self.download_tags),
            .proxy_opts = self.proxy_opts.toC(),
            .custom_headers = @bitCast(raw.git_strarray, self.custom_headers),
        };
    }
};

/// Set the callbacks to be called by the remote when informing the user about the proogress of the networking
/// operations.
pub const RemoteCallbacks = struct {
    /// Textual progress from the remote. Text send over the progress side-band will be passed to this function (this is
    /// the 'counting objects' output).
    sideband_progress: git_transport_message_cb = null,

    completion: ?fn (raw.git_remote_completion_t, ?*anyopaque) callconv(.C) c_int = null,

    /// This will be called if the remote host requires authentication in order to connect to it. Returning
    /// GIT_PASSTHROUGH will make libgit2 behave as though this field isn't set.
    credentials: git_credential_acquire_cb = null,

    /// If cert verification fails, this will be called to let the user make the final decision of whether to allow
    /// the connection to proceed. Returns 0 to allow the connection or a negative value to indicate an error.
    certificate_check: git_transport_certificate_check_cb = null,

    /// During the download of new data, this will be regularly called with the current count of progress done by the
    /// indexer.
    transfer_progress: git_indexer_progress_cb = null,

    update_tips: ?fn ([*c]const u8, [*c]const raw.git_oid, [*c]const raw.git_oid, ?*anyopaque) callconv(.C) c_int = null,

    /// Function to call with progress information during pack building. Be aware that this is called inline with pack
    /// building operations, so perfomance may be affected.
    pack_progress: git_packbuilder_progress = null,

    /// Function to call with progress information during the upload portion nof a push. Be aware that this is called
    /// inline with pack building operations, so performance may be affected.
    push_transfer_progress: git_push_transfer_progress_cb = null,

    /// See documentation of git_push_update_reference_cb.
    push_update_reference: git_push_update_reference_cb = null,

    /// Called once between the negotiation step and the upload. It provides information about what updates will be
    /// performed.
    push_negotiation: git_push_negotiation = null,

    /// Create the transport to use for this operation. Leave null to auto-detect.
    transport: git_transport_cb = null,

    // This will be passed to each of the callbacks in this sruct as the last parameter.
    payload: ?*anyopaque = null,

    /// Resolve URL before connecting to remote. The returned URL will be used to connect to the remote instead. This
    /// callback is deprecated; users should use git_remote_ready_cb and configure the instance URL instead.
    resolve_url: git_url_resolve_cb = null,

    pub fn toC(self: RemoteCallbacks) raw.git_remote_callbacks {
        return .{
            .version = raw.GIT_CHECKOUT_OPTIONS_VERSION,
            .sideband_progress = self.sideband_progress,
            .completion = self.completion,
            .credentials = self.credentials,
            .certificate_check = self.certificate_check,
            .transfer_progress = self.transfer_progress,
            .update_tips = self.update_tips,
            .pack_progress = self.pack_progress,
            .push_transfer_progress = self.push_transfer_progress,
            .push_update_reference = self.push_update_reference,
            .push_negotiation = self.push_negotiation,
            .transport = self.transport,
            .payload = self.payload,
            .resolve_url = self.resolve_url,
        };
    }

    pub const git_transport_message_cb = ?fn ([*c]const u8, c_int, ?*anyopaque) callconv(.C) c_int;
    pub const git_credential_acquire_cb = ?fn ([*c][*c]raw.git_credential, [*c]const u8, [*c]const u8, c_uint, ?*anyopaque) callconv(.C) c_int;
    pub const git_transport_certificate_check_cb = ?fn ([*c]raw.git_cert, c_int, [*c]const u8, ?*anyopaque) callconv(.C) c_int;
    pub const git_indexer_progress_cb = ?fn ([*c]const raw.git_indexer_progress, ?*anyopaque) callconv(.C) c_int;
    pub const git_packbuilder_progress = ?fn (c_int, u32, u32, ?*anyopaque) callconv(.C) c_int;
    pub const git_push_transfer_progress_cb = ?fn (c_uint, c_uint, usize, ?*anyopaque) callconv(.C) c_int;
    pub const git_push_update_reference_cb = ?fn ([*c]const u8, [*c]const u8, ?*anyopaque) callconv(.C) c_int;
    pub const git_push_negotiation = ?fn ([*c][*c]const raw.git_push_update, usize, ?*anyopaque) callconv(.C) c_int;
    pub const git_transport_cb = ?fn ([*c]?*raw.git_transport, ?*raw.git_remote, ?*anyopaque) callconv(.C) c_int;
    pub const git_url_resolve_cb = ?fn ([*c]raw.git_buf, [*c]const u8, c_int, ?*anyopaque) callconv(.C) c_int;
};
