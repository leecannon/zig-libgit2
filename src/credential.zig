const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Credential = extern struct {
    credtype: CredentialType,
    free: ?fn (*Credential) callconv(.C) void,

    pub fn deinit(self: *Credential) void {
        log.debug("Credential.deinit called", .{});

        if (internal.has_credential) {
            c.git_credential_free(@ptrCast(*internal.RawCredentialType, self));
        } else {
            c.git_cred_free(@ptrCast(*internal.RawCredentialType, self));
        }

        log.debug("credential freed successfully", .{});
    }

    pub fn hasUsername(self: *Credential) bool {
        log.debug("Credential.hasUsername called", .{});

        var ret: bool = undefined;

        if (internal.has_credential) {
            ret = c.git_credential_has_username(@ptrCast(*internal.RawCredentialType, self)) != 0;
        } else {
            ret = c.git_cred_has_username(@ptrCast(*internal.RawCredentialType, self)) != 0;
        }

        log.debug("credential has username: {}", .{ret});

        return ret;
    }

    pub fn getUsername(self: *Credential) ?[:0]const u8 {
        log.debug("Credential.getUsername called", .{});

        const opt_username = if (internal.has_credential)
            c.git_credential_get_username(@ptrCast(*internal.RawCredentialType, self))
        else
            c.git_cred_get_username(@ptrCast(*internal.RawCredentialType, self));

        if (opt_username) |username| {
            const slice = std.mem.sliceTo(username, 0);
            log.debug("credential has username: {s}", .{slice});
            return slice;
        } else {
            log.debug("credential has no username", .{});
            return null;
        }
    }

    pub const CredentialType = packed struct {
        /// A vanilla user/password request
        userpass_plaintext: bool = false,

        /// An SSH key-based authentication request
        ssh_key: bool = false,

        /// An SSH key-based authentication request, with a custom signature
        ssh_custom: bool = false,

        /// An NTLM/Negotiate-based authentication request.
        default: bool = false,

        /// An SSH interactive authentication request
        ssh_interactive: bool = false,

        /// Username-only authentication request
        ///
        /// Used as a pre-authentication step if the underlying transport (eg. SSH, with no username in its URL) does not know
        /// which username to use.
        username: bool = false,

        /// An SSH key-based authentication request
        ///
        /// Allows credentials to be read from memory instead of files.
        /// Note that because of differences in crypto backend support, it might not be functional.
        ssh_memory: bool = false,

        z_padding: u25 = 0,

        pub fn format(
            value: CredentialType,
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
            try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(CredentialType));
            try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(CredentialType));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    test {
        try std.testing.expectEqual(@sizeOf(c.git_cred), @sizeOf(Credential));
        try std.testing.expectEqual(@bitSizeOf(c.git_cred), @bitSizeOf(Credential));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
