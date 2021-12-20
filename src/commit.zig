const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Commit = opaque {
    pub fn deinit(self: *Commit) void {
        log.debug("Commit.deinit called", .{});

        c.git_commit_free(@ptrCast(*c.git_commit, self));

        log.debug("Commit freed successfully", .{});
    }

    pub fn id(self: *const Commit) *const git.Oid {
        log.debug("Commit.id called", .{});

        const ret = @ptrCast(
            *const git.Oid,
            c.git_commit_id(@ptrCast(*const c.git_commit, self)),
        );

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            if (ret.formatHex(&buf)) |slice| {
                log.debug("successfully fetched commit id: {s}", .{slice});
            } else |_| {
                log.debug("successfully fetched commit id, but unable to format it", .{});
            }
        }

        return ret;
    }

    pub fn getOwner(self: *const Commit) *git.Repository {
        log.debug("Commit.getOwner called", .{});

        const ret = @ptrCast(
            *git.Repository,
            c.git_commit_owner(@ptrCast(*const c.git_commit, self)),
        );

        log.debug("successfully fetched owning repository: {*}", .{ret});

        return ret;
    }

    pub fn getMessageEncoding(self: *const Commit) ?[:0]const u8 {
        log.debug("Commit.getMessageEncoding called", .{});

        const ret = c.git_commit_message_encoding(@ptrCast(*const c.git_commit, self));

        if (ret) |c_str| {
            const slice = std.mem.sliceTo(c_str, 0);
            log.debug("commit message encoding: {s}", .{slice});
            return slice;
        }

        log.debug("commit has no message encoding", .{});

        return null;
    }
    /// Get the full message of a commit.
    ///
    /// The returned message will be slightly prettified by removing any potential leading newlines.
    pub fn getMessage(self: *const Commit) ?[:0]const u8 {
        log.debug("Commit.getMessage called", .{});

        const ret = c.git_commit_message(@ptrCast(*const c.git_commit, self));

        if (ret) |c_str| {
            const slice = std.mem.sliceTo(c_str, 0);
            log.debug("commit message: {s}", .{slice});
            return slice;
        }

        log.debug("commit has no message", .{});

        return null;
    }

    /// Get the full raw message of a commit.
    pub fn getMessageRaw(self: *const Commit) ?[:0]const u8 {
        log.debug("Commit.getMessageRaw called", .{});

        const ret = c.git_commit_message_raw(@ptrCast(*const c.git_commit, self));

        if (ret) |c_str| {
            const slice = std.mem.sliceTo(c_str, 0);
            log.debug("commit message: {s}", .{slice});
            return slice;
        }

        log.debug("commit has no message", .{});

        return null;
    }

    /// Get the full raw text of the commit header.
    pub fn getHeaderRaw(self: *const Commit) ?[:0]const u8 {
        log.debug("Commit.getHeaderRaw called", .{});

        const ret = c.git_commit_raw_header(@ptrCast(*const c.git_commit, self));

        if (ret) |c_str| {
            const slice = std.mem.sliceTo(c_str, 0);
            log.debug("commit header: {s}", .{slice});
            return slice;
        }

        log.debug("commit has no header", .{});

        return null;
    }

    /// Get the short "summary" of the git commit message.
    ///
    /// The returned message is the summary of the commit, comprising the first paragraph of the message with whitespace trimmed
    /// and squashed.
    pub fn getSummary(self: *Commit) ?[:0]const u8 {
        log.debug("Commit.getSummary called", .{});

        const ret = c.git_commit_summary(@ptrCast(*c.git_commit, self));

        if (ret) |c_str| {
            const slice = std.mem.sliceTo(c_str, 0);
            log.debug("commit summary: {s}", .{slice});
            return slice;
        }

        log.debug("commit has no summary", .{});

        return null;
    }

    /// Get the long "body" of the git commit message.
    ///
    /// The returned message is the body of the commit, comprising everything but the first paragraph of the message. Leading and
    /// trailing whitespaces are trimmed.
    pub fn getBody(self: *Commit) ?[:0]const u8 {
        log.debug("Commit.getBody called", .{});

        const ret = c.git_commit_body(@ptrCast(*c.git_commit, self));

        if (ret) |c_str| {
            const slice = std.mem.sliceTo(c_str, 0);
            log.debug("commit body: {s}", .{slice});
            return slice;
        }

        log.debug("commit has no body", .{});

        return null;
    }

    /// Get the commit time (i.e. committer time) of a commit.
    pub fn getTime(self: *const Commit) i64 {
        log.debug("Commit.getTime called", .{});

        const ret = c.git_commit_time(@ptrCast(*const c.git_commit, self));

        log.debug("commit time: {}", .{ret});

        return ret;
    }

    /// Get the commit timezone offset (i.e. committer's preferred timezone) of a commit.
    pub fn getTimeOffset(self: *const Commit) i32 {
        log.debug("Commit.getTimeOffset called", .{});

        const ret = c.git_commit_time_offset(@ptrCast(*const c.git_commit, self));

        log.debug("commit time offset: {}", .{ret});

        return ret;
    }

    pub fn getCommitter(self: *const Commit) *const git.Signature {
        log.debug("Commit.getCommitter called", .{});

        const ret = @ptrCast(
            *const git.Signature,
            c.git_commit_committer(@ptrCast(*const c.git_commit, self)),
        );

        log.debug("commit committer: {s} {s}", .{ ret.z_name, ret.z_email });

        return ret;
    }

    pub fn getAuthor(self: *const Commit) *const git.Signature {
        log.debug("Commit.getAuthor called", .{});

        const ret = @ptrCast(
            *const git.Signature,
            c.git_commit_author(@ptrCast(*const c.git_commit, self)),
        );

        log.debug("commit author: {s} {s}", .{ ret.z_name, ret.z_email });

        return ret;
    }

    pub fn committerWithMailmap(self: *const Commit, mail_map: ?*const git.Mailmap) !*git.Signature {
        log.debug("Commit.committerWithMailmap called, mail_map={*}", .{mail_map});

        var signature: *git.Signature = undefined;

        try internal.wrapCall("git_commit_committer_with_mailmap", .{
            @ptrCast(*[*c]c.git_signature, &signature),
            @ptrCast(*const c.git_commit, self),
            @ptrCast(?*const c.git_mailmap, self),
        });

        log.debug("commit committer: {s} {s}", .{ signature.z_name, signature.z_email });

        return signature;
    }

    pub fn authorWithMailmap(self: *const Commit, mail_map: ?*const git.Mailmap) !*git.Signature {
        log.debug("Commit.authorWithMailmap called, mail_map={*}", .{mail_map});

        var signature: *git.Signature = undefined;

        try internal.wrapCall("git_commit_author_with_mailmap", .{
            @ptrCast(*[*c]c.git_signature, &signature),
            @ptrCast(*const c.git_commit, self),
            @ptrCast(?*const c.git_mailmap, mail_map),
        });

        log.debug("commit author: {s} {s}", .{ signature.z_name, signature.z_email });

        return signature;
    }

    pub fn getTree(self: *const Commit) !*git.Tree {
        log.debug("Commit.getTree called", .{});

        var tree: *git.Tree = undefined;

        try internal.wrapCall("git_commit_tree", .{
            @ptrCast(*?*c.git_tree, &tree),
            @ptrCast(*const c.git_commit, self),
        });

        log.debug("commit tree: {*}", .{tree});

        return tree;
    }

    pub fn getTreeId(self: *const Commit) !*const git.Oid {
        log.debug("Commit.getTreeId called", .{});

        const ret = @ptrCast(
            *const git.Oid,
            c.git_commit_tree_id(@ptrCast(*const c.git_commit, self)),
        );

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            if (ret.formatHex(&buf)) |slice| {
                log.debug("successfully fetched commit tree id: {s}", .{slice});
            } else |_| {
                log.debug("successfully fetched commit tree id, but unable to format it", .{});
            }
        }

        return ret;
    }

    pub fn getParentCount(self: *const Commit) u32 {
        log.debug("Commit.getParentCount called", .{});

        const ret = c.git_commit_parentcount(@ptrCast(*const c.git_commit, self));

        log.debug("commit parent count: {}", .{ret});

        return ret;
    }

    pub fn getParent(self: *const Commit, parent_number: u32) !*Commit {
        log.debug("Commit.getParent called, parent_number={}", .{parent_number});

        var commit: *Commit = undefined;

        try internal.wrapCall("git_commit_parent", .{
            @ptrCast(*?*c.git_commit, &commit),
            @ptrCast(*const c.git_commit, self),
            parent_number,
        });

        log.debug("parent commit: {*}", .{commit});

        return commit;
    }

    pub fn getParentId(self: *const Commit, parent_number: u32) ?*const git.Oid {
        log.debug("Commit.getParentId called", .{});

        const opt_ret = @ptrCast(
            ?*const git.Oid,
            c.git_commit_parent_id(
                @ptrCast(*const c.git_commit, self),
                parent_number,
            ),
        );

        if (opt_ret) |ret| {
            // This check is to prevent formating the oid when we are not going to print anything
            if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
                var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
                if (ret.formatHex(&buf)) |slice| {
                    log.debug("successfully fetched commit parent id: {s}", .{slice});
                } else |_| {
                    log.debug("successfully fetched commit parent id, but unable to format it", .{});
                }
            }

            return ret;
        }

        return null;
    }

    pub fn getAncestor(self: *const Commit, ancestor_number: u32) !*Commit {
        log.debug("Commit.getAncestor called, ancestor_number={}", .{ancestor_number});

        var commit: *Commit = undefined;

        try internal.wrapCall("git_commit_nth_gen_ancestor", .{
            @ptrCast(*?*c.git_commit, &commit),
            @ptrCast(*const c.git_commit, self),
            ancestor_number,
        });

        log.debug("ancestor commit: {*}", .{commit});

        return commit;
    }

    pub fn getHeaderField(self: *const Commit, field: [:0]const u8) !git.Buf {
        log.debug("Commit.getHeaderField called, field={s}", .{field});

        var buf: git.Buf = .{};

        try internal.wrapCall("git_commit_header_field", .{
            @ptrCast(*c.git_buf, &buf),
            @ptrCast(*const c.git_commit, self),
            field.ptr,
        });

        log.debug("header field: {s}", .{buf.toSlice()});

        return buf;
    }

    pub fn amend(
        self: *const Commit,
        update_ref: ?[:0]const u8,
        author: ?*const git.Signature,
        committer: ?*const git.Signature,
        message_encoding: ?[:0]const u8,
        message: ?[:0]const u8,
        tree: ?*const git.Tree,
    ) !git.Oid {
        log.debug("Commit.amend called, update_ref={s}, author={*}, committer={*}, message_encoding={s}, message={s}, tree={*}", .{
            update_ref,
            author,
            committer,
            message_encoding,
            message,
            tree,
        });

        var ret: git.Oid = undefined;

        const update_ref_temp: [*c]const u8 = if (update_ref) |slice| slice.ptr else null;
        const encoding_temp: [*c]const u8 = if (message_encoding) |slice| slice.ptr else null;
        const message_temp: [*c]const u8 = if (message) |slice| slice.ptr else null;

        try internal.wrapCall("git_commit_amend", .{
            @ptrCast(*c.git_oid, &ret),
            @ptrCast(*const c.git_commit, self),
            update_ref_temp,
            @ptrCast(?*const c.git_signature, author),
            @ptrCast(?*const c.git_signature, committer),
            encoding_temp,
            message_temp,
            @ptrCast(?*const c.git_tree, tree),
        });

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            const slice = try ret.formatHex(&buf);
            log.debug("successfully amended commit: {s}", .{slice});
        }

        return ret;
    }

    pub fn dupe(self: *Commit) !*Commit {
        log.debug("Commit.dupe called", .{});

        var commit: *Commit = undefined;

        try internal.wrapCall("git_commit_dup", .{
            @ptrCast(*?*c.git_commit, &commit),
            @ptrCast(*c.git_commit, self),
        });

        log.debug("duplicated commit", .{});

        return commit;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
