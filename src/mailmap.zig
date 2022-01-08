const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Mailmap = opaque {
    /// Allocate a new mailmap object.
    ///
    /// This object is empty, so you'll have to add a mailmap file before you can do anything with it. 
    /// The mailmap must be freed with 'deinit'.
    pub fn init() !*Mailmap {
        log.debug("Mailmap.init called", .{});

        var mailmap: *Mailmap = undefined;

        try internal.wrapCall("git_mailmap_new", .{
            @ptrCast(*?*c.git_mailmap, &mailmap),
        });

        log.debug("successfully initalized mailmap {*}", .{mailmap});

        return mailmap;
    }

    /// Free the mailmap and its associated memory.
    pub fn deinit(self: *Mailmap) void {
        log.debug("Mailmap.deinit called", .{});

        c.git_mailmap_free(@ptrCast(*c.git_mailmap, self));

        log.debug("Mailmap freed successfully", .{});
    }

    /// Add a single entry to the given mailmap object. If the entry already exists, it will be replaced with the new entry.
    ///
    /// ## Parameters
    /// * `real_name` - the real name to use, or NULL
    /// * `real_email` - the real email to use, or NULL
    /// * `replace_name` - the name to replace, or NULL
    /// * `replace_email` - the email to replace
    pub fn addEntry(
        self: *Mailmap,
        real_name: ?[:0]const u8,
        real_email: ?[:0]const u8,
        replace_name: ?[:0]const u8,
        replace_email: [:0]const u8,
    ) !void {
        log.debug(
            "Mailmap.addEntry called, real_name: {s}, real_email: {s}, replace_name: {s}, replace_email: {s}",
            .{ real_name, real_email, replace_name, replace_email },
        );

        const c_real_name = if (real_name) |ptr| ptr.ptr else null;
        const c_real_email = if (real_email) |ptr| ptr.ptr else null;
        const c_replace_name = if (replace_name) |ptr| ptr.ptr else null;

        try internal.wrapCall("git_mailmap_add_entry", .{
            @ptrCast(*c.git_mailmap, self),
            c_real_name,
            c_real_email,
            c_replace_name,
            replace_email.ptr,
        });

        log.debug("successfully added entry to mailmap", .{});
    }

    pub const ResolveResult = struct {
        real_name: [:0]const u8,
        real_email: [:0]const u8,
    };

    /// Resolve a name and email to the corresponding real name and email.
    ///
    /// The lifetime of the strings are tied to `self`, `name`, and `email` parameters.
    ///
    /// ## Parameters
    /// * `self` - the mailmap to perform a lookup with (may be NULL)
    /// * `name` - the name to look up
    /// * `email` - the email to look up
    pub fn resolve(self: ?*const Mailmap, name: [:0]const u8, email: [:0]const u8) !ResolveResult {
        log.debug("Mailmap.resolve called, name: {s}, email: {s}", .{ name, email });

        var real_name: [*c]const u8 = undefined;
        var real_email: [*c]const u8 = undefined;

        try internal.wrapCall("git_mailmap_resolve", .{
            &real_name,
            &real_email,
            @ptrCast(*const c.git_mailmap, self),
            name.ptr,
            email.ptr,
        });

        const ret = ResolveResult{
            .real_name = std.mem.sliceTo(real_name, 0),
            .real_email = std.mem.sliceTo(real_email, 0),
        };

        log.debug("successfully resolved name and email: {}", .{ret});

        return ret;
    }

    /// Resolve a signature to use real names and emails with a mailmap.
    ///
    /// Call `git.Signature.deinit` to free the data.
    ///
    /// ## Parameters
    /// * `signature` - signature to resolve
    pub fn resolveSignature(self: *const Mailmap, signature: *const git.Signature) !*git.Signature {
        log.debug("Mailmap.resolveSignature called, signature: {*}", .{signature});

        var sig: *git.Signature = undefined;

        try internal.wrapCall("git_mailmap_resolve_signature", .{
            @ptrCast(*[*c]c.git_signature, &sig),
            @ptrCast(*const c.git_mailmap, self),
            @ptrCast(*const c.git_signature, signature),
        });

        log.debug("successfully resolved signature", .{});

        return sig;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
