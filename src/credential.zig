const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Credential = opaque {
    pub fn deinit(self: *Credential) void {
        log.debug("Credential.deinit called", .{});

        raw.git_credential_free(internal.toC(self));

        log.debug("credential freed successfully", .{});
    }

    pub fn hasUsername(self: *const Credential) bool {
        log.debug("Credential.hasUsername called", .{});

        const ret = raw.git_credential_has_username(internal.toC(self)) != 0;

        log.debug("credential has username: {}", .{ret});

        return ret;
    }

    pub fn getUsername(self: *const Credential) ?[:0]const u8 {
        log.debug("Credential.getUsername called", .{});

        const opt_username = raw.git_credential_get_username(internal.toC(self));

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

        var cred: ?*raw.git_credential = undefined;

        try internal.wrapCall("git_credential_userpass_plaintext_new", .{ &cred, username.ptr, password.ptr });

        const ret = internal.fromC(cred.?);

        log.debug("created new credential {*}", .{ret});

        return ret;
    }

    /// Create a "default" credential usable for Negotiate mechanisms like NTLM or Kerberos authentication.
    pub fn initDefault() !*Credential {
        log.debug("Credential.initDefault", .{});

        var cred: ?*raw.git_credential = undefined;

        try internal.wrapCall("git_credential_default_new", .{&cred});

        const ret = internal.fromC(cred.?);

        log.debug("created new credential {*}", .{ret});

        return ret;
    }

    /// Create a credential to specify a username.
    ///
    /// This is used with ssh authentication to query for the username if none is specified in the url.
    pub fn initUsername(username: [:0]const u8) !*Credential {
        log.debug("Credential.initUsername called, username={s}", .{username});

        var cred: ?*raw.git_credential = undefined;

        try internal.wrapCall("git_credential_username_new", .{ &cred, username.ptr });

        const ret = internal.fromC(cred.?);

        log.debug("created new credential {*}", .{ret});

        return ret;
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

        var cred: ?*raw.git_credential = undefined;

        const publickey_c = if (publickey) |str| str.ptr else null;
        const passphrase_c = if (passphrase) |str| str.ptr else null;

        try internal.wrapCall("git_credential_ssh_key_new", .{
            &cred,
            username.ptr,
            publickey_c,
            privatekey.ptr,
            passphrase_c,
        });

        const ret = internal.fromC(cred.?);

        log.debug("created new credential {*}", .{ret});

        return ret;
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

        var cred: ?*raw.git_credential = undefined;

        const publickey_c = if (publickey) |str| str.ptr else null;
        const passphrase_c = if (passphrase) |str| str.ptr else null;

        try internal.wrapCall("git_credential_ssh_key_memory_new", .{
            &cred,
            username.ptr,
            publickey_c,
            privatekey.ptr,
            passphrase_c,
        });

        const ret = internal.fromC(cred.?);

        log.debug("created new credential {*}", .{ret});

        return ret;
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
            abstract: [*c]?*c_void,
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
                abstract: [*c]?*c_void,
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

        var cred: ?*raw.git_credential = undefined;

        try internal.wrapCall("git_credential_ssh_interactive_new", .{ &cred, username.ptr, cb, user_data });

        const ret = internal.fromC(cred.?);

        log.debug("created new credential {*}", .{ret});

        return ret;
    }

    pub fn initSshKeyFromAgent(username: [:0]const u8) !*Credential {
        log.debug("Credential.initSshKeyFromAgent called, username={s}", .{username});

        var cred: ?*raw.git_credential = undefined;

        try internal.wrapCall("git_credential_ssh_key_from_agent", .{ &cred, username.ptr });

        const ret = internal.fromC(cred.?);

        log.debug("created new credential {*}", .{ret});

        return ret;
    }

    pub fn initSshKeyCustom(
        username: [:0]const u8,
        publickey: []const u8,
        user_data: anytype,
        comptime callback_fn: fn (
            session: *raw.LIBSSH2_SESSION,
            out_signature: *[]const u8,
            data: []const u8,
            abstract: [*c]?*c_void,
        ) c_int,
    ) !*Credential {
        const cb = struct {
            pub fn cb(
                session: ?*raw.LIBSSH2_SESSION,
                sig: [*c][*c]u8,
                sign_len: [*c]usize,
                data: [*c]const u8,
                data_len: usize,
                abstract: [*c]?*c_void,
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

        var cred: ?*raw.git_credential = undefined;

        try internal.wrapCall("git_credential_ssh_custom_new", .{
            &cred,
            username.ptr,
            publickey.ptr,
            publickey.len,
            cb,
            user_data,
        });

        const ret = internal.fromC(cred.?);

        log.debug("created new credential {*}", .{ret});

        return ret;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
