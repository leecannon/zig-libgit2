const std = @import("std");
const raw = @import("internal/raw.zig");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const bitjuggle = @import("internal/bitjuggle.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

const hasCredential = @hasDecl(c, "git_credential");
const RawCredentialType = if (hasCredential) raw.git_credential else raw.git_cred;

pub const Credential = extern struct {
    credtype: CredentialType,
    free: ?fn (*Credential) callconv(.C) void,

    pub fn deinit(self: *Credential) void {
        log.debug("Credential.deinit called", .{});

        if (hasCredential) {
            raw.git_credential_free(@ptrCast(*RawCredentialType, self));
        } else {
            raw.git_cred_free(@ptrCast(*RawCredentialType, self));
        }

        log.debug("credential freed successfully", .{});
    }

    pub fn hasUsername(self: *Credential) bool {
        log.debug("Credential.hasUsername called", .{});

        var ret: bool = undefined;

        if (hasCredential) {
            ret = raw.git_credential_has_username(@ptrCast(*RawCredentialType, self)) != 0;
        } else {
            ret = raw.git_cred_has_username(@ptrCast(*RawCredentialType, self)) != 0;
        }

        log.debug("credential has username: {}", .{ret});

        return ret;
    }

    pub fn getUsername(self: *Credential) ?[:0]const u8 {
        log.debug("Credential.getUsername called", .{});

        var opt_username: [*c]const u8 = undefined;

        if (hasCredential) {
            opt_username = raw.git_credential_get_username(@ptrCast(*RawCredentialType, self));
        } else {
            if (@hasDecl(c, "git_cred_get_username")) {
                opt_username = raw.git_cred_get_username(@ptrCast(*RawCredentialType, self));
            } else {
                // TODO: make this a compile error when we move to full c header
                log.err("the version of libgit2 linked does not provide a function to fetch the username of a credential", .{});
                return null;
            }
        }

        if (opt_username) |username| {
            const slice = std.mem.sliceTo(username, 0);
            log.debug("credential has username: {s}", .{slice});
            return slice;
        } else {
            log.debug("credential has no username", .{});
            return null;
        }
    }

    pub fn initUserPassPlaintext(username: [:0]const u8, password: [:0]const u8) !*Credential {
        log.debug("Credential.initUserPassPlaintext called, username={s}, password={s}", .{ username, password });

        var cred: *Credential = undefined;

        if (hasCredential) {
            try internal.wrapCall("git_credential_userpass_plaintext_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
                username.ptr,
                password.ptr,
            });
        } else {
            try internal.wrapCall("git_cred_userpass_plaintext_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
                username.ptr,
                password.ptr,
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    /// Create a "default" credential usable for Negotiate mechanisms like NTLM or Kerberos authentication.
    pub fn initDefault() !*Credential {
        log.debug("Credential.initDefault", .{});

        var cred: *Credential = undefined;

        if (hasCredential) {
            try internal.wrapCall("git_credential_default_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
            });
        } else {
            try internal.wrapCall("git_cred_default_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    /// Create a credential to specify a username.
    ///
    /// This is used with ssh authentication to query for the username if none is specified in the url.
    pub fn initUsername(username: [:0]const u8) !*Credential {
        log.debug("Credential.initUsername called, username={s}", .{username});

        var cred: *Credential = undefined;

        if (hasCredential) {
            try internal.wrapCall("git_credential_username_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
                username.ptr,
            });
        } else {
            try internal.wrapCall("git_cred_username_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
                username.ptr,
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    /// Create a new passphrase-protected ssh key credential object.
    ///
    /// ## Parameters
    /// * `username` - username to use to authenticate
    /// * `publickey` - The path to the public key of the credential.
    /// * `privatekey` - The path to the private key of the credential.
    /// * `passphrase` - The passphrase of the credential.
    pub fn initSshKey(
        username: [:0]const u8,
        publickey: ?[:0]const u8,
        privatekey: [:0]const u8,
        passphrase: ?[:0]const u8,
    ) !*Credential {
        log.debug(
            "Credential.initSshKey called, username={s}, publickey={s}, privatekey={s}, passphrase={s}",
            .{ username, publickey, privatekey, passphrase },
        );

        var cred: *Credential = undefined;

        const publickey_c = if (publickey) |str| str.ptr else null;
        const passphrase_c = if (passphrase) |str| str.ptr else null;

        if (hasCredential) {
            try internal.wrapCall("git_credential_ssh_key_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
                username.ptr,
                publickey_c,
                privatekey.ptr,
                passphrase_c,
            });
        } else {
            try internal.wrapCall("git_cred_ssh_key_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
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
    /// * `username` - username to use to authenticate
    /// * `publickey` - The public key of the credential.
    /// * `privatekey` - TThe private key of the credential.
    /// * `passphrase` - The passphrase of the credential.
    pub fn initSshKeyMemory(
        username: [:0]const u8,
        publickey: ?[:0]const u8,
        privatekey: [:0]const u8,
        passphrase: ?[:0]const u8,
    ) !*Credential {
        log.debug("Credential.initSshKeyMemory called", .{});

        var cred: *Credential = undefined;

        const publickey_c = if (publickey) |str| str.ptr else null;
        const passphrase_c = if (passphrase) |str| str.ptr else null;

        if (hasCredential) {
            try internal.wrapCall("git_credential_ssh_key_memory_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
                username.ptr,
                publickey_c,
                privatekey.ptr,
                passphrase_c,
            });
        } else {
            try internal.wrapCall("git_cred_ssh_key_memory_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
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
    /// * `user_data` - pointer to user data to be passed to the callback
    /// * `callback_fn` - the callback function
    pub fn initSshKeyInteractive(
        username: [:0]const u8,
        user_data: anytype,
        comptime callback_fn: fn (
            name: []const u8,
            instruction: []const u8,
            prompts: []*const raw.LIBSSH2_USERAUTH_KBDINT_PROMPT,
            responses: []*raw.LIBSSH2_USERAUTH_KBDINT_RESPONSE,
            abstract: [*c]?*anyopaque,
        ) void,
    ) !*Credential {
        // TODO: This callback needs to be massively cleaned up

        const cb = struct {
            pub fn cb(
                name: [*c]const u8,
                name_len: c_int,
                instruction: [*c]const u8,
                instruction_len: c_int,
                num_prompts: c_int,
                prompts: ?*const raw.LIBSSH2_USERAUTH_KBDINT_PROMPT,
                responses: ?*raw.LIBSSH2_USERAUTH_KBDINT_RESPONSE,
                abstract: [*c]?*anyopaque,
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

        log.debug("Credential.initSshKeyInteractive called, username={s}", .{username});

        var cred: *Credential = undefined;

        if (hasCredential) {
            try internal.wrapCall("git_credential_ssh_interactive_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
                username.ptr,
                cb,
                user_data,
            });
        } else {
            try internal.wrapCall("git_cred_ssh_interactive_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
                username.ptr,
                cb,
                user_data,
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    pub fn initSshKeyFromAgent(username: [:0]const u8) !*Credential {
        log.debug("Credential.initSshKeyFromAgent called, username={s}", .{username});

        var cred: *Credential = undefined;

        if (hasCredential) {
            try internal.wrapCall("git_credential_ssh_key_from_agent", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
                username.ptr,
            });
        } else {
            try internal.wrapCall("git_cred_ssh_key_from_agent", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
                username.ptr,
            });
        }

        log.debug("created new credential {*}", .{cred});

        return cred;
    }

    pub fn initSshKeyCustom(
        username: [:0]const u8,
        publickey: []const u8,
        user_data: anytype,
        comptime callback_fn: fn (
            session: *raw.LIBSSH2_SESSION,
            out_signature: *[]const u8,
            data: []const u8,
            abstract: [*c]?*anyopaque,
        ) c_int,
    ) !*Credential {
        const cb = struct {
            pub fn cb(
                session: ?*raw.LIBSSH2_SESSION,
                sig: [*c][*c]u8,
                sign_len: [*c]usize,
                data: [*c]const u8,
                data_len: usize,
                abstract: [*c]?*anyopaque,
            ) callconv(.C) c_int {
                var out_sig: []const u8 = undefined;

                const result = callback_fn(
                    session,
                    &out_sig,
                    data[0..data_len],
                    abstract,
                );

                sig.* = out_sig.ptr;
                sign_len.* = out_sig.len;

                return result;
            }
        }.cb;

        log.debug("Credential.initSshKeyCustom called, username={s}", .{username});

        var cred: *Credential = undefined;

        if (hasCredential) {
            try internal.wrapCall("git_credential_ssh_custom_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
                username.ptr,
                publickey.ptr,
                publickey.len,
                cb,
                user_data,
            });
        } else {
            try internal.wrapCall("git_cred_ssh_custom_new", .{
                @ptrCast(*[*c]RawCredentialType, &cred),
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

    pub const CredentialType = extern union {
        /// A vanilla user/password request
        /// @see git_credential_userpass_plaintext_new
        userpass_plaintext: bitjuggle.Boolean(c_uint, 0),

        /// An SSH key-based authentication request
        /// @see git_credential_ssh_key_new
        ssh_key: bitjuggle.Boolean(c_uint, 1),

        /// An SSH key-based authentication request, with a custom signature
        /// @see git_credential_ssh_custom_new
        ssh_custom: bitjuggle.Boolean(c_uint, 2),

        /// An NTLM/Negotiate-based authentication request.
        /// @see git_credential_default
        default: bitjuggle.Boolean(c_uint, 3),

        /// An SSH interactive authentication request
        /// @see git_credential_ssh_interactive_new
        ssh_interactive: bitjuggle.Boolean(c_uint, 4),

        /// Username-only authentication request
        ///
        /// Used as a pre-authentication step if the underlying transport
        /// (eg. SSH, with no username in its URL) does not know which username
        /// to use.
        ///
        /// @see git_credential_username_new
        username: bitjuggle.Boolean(c_uint, 5),

        /// An SSH key-based authentication request
        ///
        /// Allows credentials to be read from memory instead of files.
        /// Note that because of differences in crypto backend support, it might
        /// not be functional.
        ///
        /// @see git_credential_ssh_key_memory_new
        ssh_memory: bitjuggle.Boolean(c_uint, 6),

        value: c_uint,

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
