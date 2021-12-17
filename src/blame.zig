const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Blame = opaque {
    pub fn deinit(self: *Blame) void {
        log.debug("Blame.deinit called", .{});

        raw.git_blame_free(@ptrCast(*raw.git_blame, self));

        log.debug("blame freed successfully", .{});
    }

    pub fn hunkCount(self: *Blame) u32 {
        log.debug("Blame.hunkCount called", .{});

        const ret = raw.git_blame_get_hunk_count(@ptrCast(*raw.git_blame, self));

        log.debug("blame hunk count: {}", .{ret});

        return ret;
    }

    pub fn hunkByIndex(self: *Blame, index: u32) ?*const BlameHunk {
        log.debug("Blame.hunkByIndex called, index={}", .{index});

        if (raw.git_blame_get_hunk_byindex(@ptrCast(*raw.git_blame, self), index)) |c_ret| {
            const ret = @ptrCast(*const git.BlameHunk, c_ret);
            log.debug("successfully fetched hunk: {*}", .{ret});
            return ret;
        }

        return null;
    }

    pub fn hunkByLine(self: *Blame, line: usize) ?*const BlameHunk {
        log.debug("Blame.hunkByLine called, line={}", .{line});

        if (raw.git_blame_get_hunk_byline(@ptrCast(*raw.git_blame, self), line)) |c_ret| {
            const ret = @ptrCast(*const git.BlameHunk, c_ret);
            log.debug("successfully fetched hunk: {*}", .{ret});
            return ret;
        }

        return null;
    }

    /// Get blame data for a file that has been modified in memory. The `reference` parameter is a pre-calculated blame for the
    /// in-odb history of the file. This means that once a file blame is completed (which can be expensive), updating the buffer
    /// blame is very fast.
    ///
    /// Lines that differ between the buffer and the committed version are marked as having a zero OID for their final_commit_id.
    pub fn blameBuffer(self: *Blame, buffer: [:0]const u8) !*git.Blame {
        log.debug("Blame.blameBuffer called, buffer={s}", .{buffer});

        var blame: *git.Blame = undefined;

        try internal.wrapCall("git_blame_buffer", .{
            @ptrCast(*?*raw.git_blame, &blame),
            @ptrCast(*raw.git_blame, self),
            buffer.ptr,
            buffer.len,
        });

        log.debug("successfully fetched blame buffer", .{});

        return blame;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const BlameHunk = extern struct {
    /// The number of lines in this hunk.
    lines_in_hunk: usize,

    /// The OID of the commit where this line was last changed.
    final_commit_id: git.Oid,

    /// The 1-based line number where this hunk begins, in the final version
    /// of the file.
    final_start_line_number: usize,

    /// The author of `final_commit_id`. If `GIT_BLAME_USE_MAILMAP` has been
    /// specified, it will contain the canonical real name and email address.
    final_signature: *git.Signature,

    /// The OID of the commit where this hunk was found.
    /// This will usually be the same as `final_commit_id`, except when
    /// `GIT_BLAME_TRACK_COPIES_ANY_COMMIT_COPIES` has been specified.
    orig_commit_id: git.Oid,

    /// The path to the file where this hunk originated, as of the commit
    /// specified by `orig_commit_id`.
    /// Use `origPath`
    z_orig_path: [*:0]const u8,

    /// The 1-based line number where this hunk begins in the file named by
    /// `orig_path` in the commit specified by `orig_commit_id`.
    orig_start_line_number: usize,

    /// The author of `orig_commit_id`. If `GIT_BLAME_USE_MAILMAP` has been
    /// specified, it will contain the canonical real name and email address.
    orig_signature: *git.Signature,

    /// The 1 iff the hunk has been tracked to a boundary commit (the root,
    /// or the commit specified in git_blame_options.oldest_commit)
    boundary: u8,

    pub fn origPath(self: BlameHunk) [:0]const u8 {
        return std.mem.sliceTo(self.z_orig_path, 0);
    }

    test {
        try std.testing.expectEqual(@sizeOf(raw.git_blame_hunk), @sizeOf(BlameHunk));
        try std.testing.expectEqual(@bitSizeOf(raw.git_blame_hunk), @bitSizeOf(BlameHunk));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
