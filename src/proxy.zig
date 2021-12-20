const std = @import("std");
const raw = @import("internal/raw.zig");
const git = @import("git.zig");

/// Options for connecting through a proxy.
pub const ProxyOptions = struct {
    proxy_type: ProxyType = .NONE,
    url: ?[:0]const u8 = null,

    /// A callback used to create the git remote, prior to its being used to perform the clone option. This
    /// parameter may be NULL, indicating that handle.Clone should provide default behavior.
    payload: ?*anyopaque = null,
    credentials: ?fn (
        out: **raw.git_credential,
        url: [*:0]const u8,
        username_from_url: [*:0]const u8,
        allowed_types: c_int,
        payload: *anyopaque,
    ) callconv(.C) void = null,

    certificate_check: ?fn (
        cert: *raw.git_cert,
        valid: c_int,
        host: [*:0]const u8,
        payload: ?*anyopaque,
    ) callconv(.C) c_int = null,

    pub const ProxyType = enum(c_uint) {
        NONE,
        AUTO,
        SPECIFIED,
    };

    pub fn toC(self: ProxyOptions) raw.git_proxy_options {
        return .{
            .version = raw.GIT_PROXY_OPTIONS_VERSION,
            .@"type" = @enumToInt(self.proxy_type),
            .url = if (self.url) |s| s.ptr else null,
            .credentials = @ptrCast(raw.git_credential_acquire_cb, self.credentials),
            .payload = self.payload,
            .certificate_check = @ptrCast(raw.git_transport_certificate_check_cb, self.certificate_check),
        };
    }
};
