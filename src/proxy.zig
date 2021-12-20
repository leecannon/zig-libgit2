const std = @import("std");
const c = @import("internal/c.zig");
const git = @import("git.zig");

/// Options for connecting through a proxy.
/// Note that not all types may be supported, depending on the platform  and compilation options.
pub const ProxyOptions = struct {
    /// The type of proxy to use, by URL, auto-detect.
    proxy_type: ProxyType = .NONE,

    /// The URL of the proxy.
    url: ?[:0]const u8 = null,

    /// This will be called if the remote host requires authentication in order to connect to it.
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

    /// Payload to be provided to the credentials and certificate check callbacks.
    payload: ?*anyopaque = null,

    pub const ProxyType = enum(c_uint) {
        /// Do not attempt to connect through a proxy
        ///
        /// If built against libcurl, it itself may attempt to connect
        /// to a proxy if the environment variables specify it.
        NONE = 0,

        /// Try to auto-detect the proxy from the git configuration.
        AUTO,

        /// Connect via the URL given in the options
        SPECIFIED,
    };

    pub fn makeCOptionsObject(self: ProxyOptions) c.git_proxy_options {
        // TODO: Do this better
        if (!@hasDecl(c, "git_credential_acquire_cb")) @panic("`git_credential_acquire_cb` is unsupported");

        return .{
            .version = c.GIT_PROXY_OPTIONS_VERSION,
            .@"type" = @enumToInt(self.proxy_type),
            .url = if (self.url) |s| s.ptr else null,
            .credentials = @ptrCast(c.git_credential_acquire_cb, self.credentials),
            .payload = self.payload,
            .certificate_check = @ptrCast(c.git_transport_certificate_check_cb, self.certificate_check),
        };
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
