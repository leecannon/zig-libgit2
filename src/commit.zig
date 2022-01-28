const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Commit = opaque {
    pub fn deinit(self: *Commit) void {
        if (internal.trace_log) log.debug("Commit.deinit called", .{});

        c.git_commit_free(@ptrCast(*c.git_commit, self));
    }

    pub fn noteIterator(self: *Commit) !*git.NoteIterator {
        if (internal.trace_log) log.debug("Commit.noteIterator called", .{});

        var ret: *git.NoteIterator = undefined;

        try internal.wrapCall("git_note_commit_iterator_new", .{
            @ptrCast(*?*c.git_note_iterator, &ret),
            @ptrCast(*c.git_commit, self),
        });

        return ret;
    }

    pub fn id(self: *const Commit) *const git.Oid {
        if (internal.trace_log) log.debug("Commit.id called", .{});

        return @ptrCast(
            *const git.Oid,
            c.git_commit_id(@ptrCast(*const c.git_commit, self)),
        );
    }

    pub fn getOwner(self: *const Commit) *git.Repository {
        if (internal.trace_log) log.debug("Commit.getOwner called", .{});

        return @ptrCast(
            *git.Repository,
            c.git_commit_owner(@ptrCast(*const c.git_commit, self)),
        );
    }

    pub fn getMessageEncoding(self: *const Commit) ?[:0]const u8 {
        if (internal.trace_log) log.debug("Commit.getMessageEncoding called", .{});

        const ret = c.git_commit_message_encoding(@ptrCast(*const c.git_commit, self));

        return if (ret) |c_str| std.mem.sliceTo(c_str, 0) else null;
    }
    /// Get the full message of a commit.
    ///
    /// The returned message will be slightly prettified by removing any potential leading newlines.
    pub fn getMessage(self: *const Commit) ?[:0]const u8 {
        if (internal.trace_log) log.debug("Commit.getMessage called", .{});

        const ret = c.git_commit_message(@ptrCast(*const c.git_commit, self));

        return if (ret) |c_str| std.mem.sliceTo(c_str, 0) else null;
    }

    /// Get the full raw message of a commit.
    pub fn getMessageRaw(self: *const Commit) ?[:0]const u8 {
        if (internal.trace_log) log.debug("Commit.getMessageRaw called", .{});

        const ret = c.git_commit_message_raw(@ptrCast(*const c.git_commit, self));

        return if (ret) |c_str| std.mem.sliceTo(c_str, 0) else null;
    }

    /// Get the full raw text of the commit header.
    pub fn getHeaderRaw(self: *const Commit) ?[:0]const u8 {
        if (internal.trace_log) log.debug("Commit.getHeaderRaw called", .{});

        const ret = c.git_commit_raw_header(@ptrCast(*const c.git_commit, self));

        return if (ret) |c_str| std.mem.sliceTo(c_str, 0) else null;
    }

    /// Get the short "summary" of the git commit message.
    ///
    /// The returned message is the summary of the commit, comprising the first paragraph of the message with whitespace trimmed
    /// and squashed.
    pub fn getSummary(self: *Commit) ?[:0]const u8 {
        if (internal.trace_log) log.debug("Commit.getSummary called", .{});

        const ret = c.git_commit_summary(@ptrCast(*c.git_commit, self));

        return if (ret) |c_str| std.mem.sliceTo(c_str, 0) else null;
    }

    /// Get the long "body" of the git commit message.
    ///
    /// The returned message is the body of the commit, comprising everything but the first paragraph of the message. Leading and
    /// trailing whitespaces are trimmed.
    pub fn getBody(self: *Commit) ?[:0]const u8 {
        if (internal.trace_log) log.debug("Commit.getBody called", .{});

        const ret = c.git_commit_body(@ptrCast(*c.git_commit, self));

        return if (ret) |c_str| std.mem.sliceTo(c_str, 0) else null;
    }

    /// Get the commit time (i.e. committer time) of a commit.
    pub fn getTime(self: *const Commit) i64 {
        if (internal.trace_log) log.debug("Commit.getTime called", .{});

        return c.git_commit_time(@ptrCast(*const c.git_commit, self));
    }

    /// Get the commit timezone offset (i.e. committer's preferred timezone) of a commit.
    pub fn getTimeOffset(self: *const Commit) i32 {
        if (internal.trace_log) log.debug("Commit.getTimeOffset called", .{});

        return c.git_commit_time_offset(@ptrCast(*const c.git_commit, self));
    }

    pub fn getCommitter(self: *const Commit) *const git.Signature {
        if (internal.trace_log) log.debug("Commit.getCommitter called", .{});

        return @ptrCast(
            *const git.Signature,
            c.git_commit_committer(@ptrCast(*const c.git_commit, self)),
        );
    }

    pub fn getAuthor(self: *const Commit) *const git.Signature {
        if (internal.trace_log) log.debug("Commit.getAuthor called", .{});

        return @ptrCast(
            *const git.Signature,
            c.git_commit_author(@ptrCast(*const c.git_commit, self)),
        );
    }

    pub fn committerWithMailmap(self: *const Commit, mail_map: ?*const git.Mailmap) !*git.Signature {
        if (internal.trace_log) log.debug("Commit.committerWithMailmap", .{});

        var signature: *git.Signature = undefined;

        try internal.wrapCall("git_commit_committer_with_mailmap", .{
            @ptrCast(*?*c.git_signature, &signature),
            @ptrCast(*const c.git_commit, self),
            @ptrCast(?*const c.git_mailmap, mail_map),
        });

        return signature;
    }

    pub fn authorWithMailmap(self: *const Commit, mail_map: ?*const git.Mailmap) !*git.Signature {
        if (internal.trace_log) log.debug("Commit.authorWithMailmap called", .{});

        var signature: *git.Signature = undefined;

        try internal.wrapCall("git_commit_author_with_mailmap", .{
            @ptrCast(*?*c.git_signature, &signature),
            @ptrCast(*const c.git_commit, self),
            @ptrCast(?*const c.git_mailmap, mail_map),
        });

        return signature;
    }

    pub fn getTree(self: *const Commit) !*git.Tree {
        if (internal.trace_log) log.debug("Commit.getTree called", .{});

        var tree: *git.Tree = undefined;

        try internal.wrapCall("git_commit_tree", .{
            @ptrCast(*?*c.git_tree, &tree),
            @ptrCast(*const c.git_commit, self),
        });

        return tree;
    }

    pub fn getTreeId(self: *const Commit) !*const git.Oid {
        if (internal.trace_log) log.debug("Commit.getTreeId called", .{});

        return @ptrCast(
            *const git.Oid,
            c.git_commit_tree_id(@ptrCast(*const c.git_commit, self)),
        );
    }

    pub fn getParentCount(self: *const Commit) u32 {
        if (internal.trace_log) log.debug("Commit.getParentCount called", .{});

        return c.git_commit_parentcount(@ptrCast(*const c.git_commit, self));
    }

    pub fn getParent(self: *const Commit, parent_number: u32) !*Commit {
        if (internal.trace_log) log.debug("Commit.getParent called", .{});

        var commit: *Commit = undefined;

        try internal.wrapCall("git_commit_parent", .{
            @ptrCast(*?*c.git_commit, &commit),
            @ptrCast(*const c.git_commit, self),
            parent_number,
        });

        return commit;
    }

    pub fn getParentId(self: *const Commit, parent_number: u32) ?*const git.Oid {
        if (internal.trace_log) log.debug("Commit.getParentId called", .{});

        return @ptrCast(
            ?*const git.Oid,
            c.git_commit_parent_id(
                @ptrCast(*const c.git_commit, self),
                parent_number,
            ),
        );
    }

    pub fn getAncestor(self: *const Commit, ancestor_number: u32) !*Commit {
        if (internal.trace_log) log.debug("Commit.getAncestor called", .{});

        var commit: *Commit = undefined;

        try internal.wrapCall("git_commit_nth_gen_ancestor", .{
            @ptrCast(*?*c.git_commit, &commit),
            @ptrCast(*const c.git_commit, self),
            ancestor_number,
        });

        return commit;
    }

    pub fn getHeaderField(self: *const Commit, field: [:0]const u8) !git.Buf {
        if (internal.trace_log) log.debug("Commit.getHeaderField called", .{});

        var buf: git.Buf = .{};

        try internal.wrapCall("git_commit_header_field", .{
            @ptrCast(*c.git_buf, &buf),
            @ptrCast(*const c.git_commit, self),
            field.ptr,
        });

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
        if (internal.trace_log) log.debug("Commit.amend called", .{});

        var ret: git.Oid = undefined;

        const update_ref_temp = if (update_ref) |slice| slice.ptr else null;
        const encoding_temp = if (message_encoding) |slice| slice.ptr else null;
        const message_temp = if (message) |slice| slice.ptr else null;

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

        return ret;
    }

    pub fn duplicate(self: *Commit) !*Commit {
        if (internal.trace_log) log.debug("Commit.duplicate called", .{});

        var commit: *Commit = undefined;

        try internal.wrapCall("git_commit_dup", .{
            @ptrCast(*?*c.git_commit, &commit),
            @ptrCast(*c.git_commit, self),
        });

        return commit;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Options for revert
pub const RevertOptions = struct {
    /// For merge commits, the "mainline" is treated as the parent.
    mainline: bool = false,
    /// Options for the merging
    merge_options: git.MergeOptions = .{},
    /// Options for the checkout
    checkout_options: git.CheckoutOptions = .{},

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
