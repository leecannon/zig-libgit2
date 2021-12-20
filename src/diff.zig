const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

/// The diff object that contains all individual file deltas.
/// A `diff` represents the cumulative list of differences between two snapshots of a repository (possibly filtered by a set of
/// file name patterns).
///
/// Calculating diffs is generally done in two phases: building a list of diffs then traversing it. This makes is easier to share
/// logic across the various types of diffs (tree vs tree, workdir vs index, etc.), and also allows you to insert optional diff
/// post-processing phases, such as rename detection, in between the steps. When you are done with a diff object, it must be
/// freed.
pub const Diff = opaque {
    pub fn deinit(self: *Diff) void {
        log.debug("Diff.deinit called", .{});

        c.git_diff_free(@ptrCast(*c.git_diff, self));

        log.debug("diff freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Structure describing a hunk of a diff.
///
/// A `hunk` is a span of modified lines in a delta along with some stable surrounding context. You can configure the amount of
/// context and other properties of how hunks are generated. Each hunk also comes with a header that described where it starts and
/// ends in both the old and new versions in the delta.
pub const DiffHunk = extern struct {
    pub const HEADER_SIZE: usize = c.GIT_DIFF_HUNK_HEADER_SIZE;

    /// Starting line number in old_file
    old_start: c_int,
    /// Number of lines in old_file
    old_lines: c_int,
    /// Starting line number in new_file
    new_start: c_int,
    /// Number of lines in new_file
    new_lines: c_int,
    /// Number of bytes in header text
    header_len: usize,
    /// Header text, NUL-byte terminated
    /// Use `header`
    z_header: [HEADER_SIZE]u8,

    pub fn header(self: DiffHunk) [:0]const u8 {
        // for some reason this gives `expected type '[:0]const u8', found '[]const u8'`
        // return std.mem.sliceTo(&self.z_header, 0);
        return std.mem.sliceTo(@ptrCast([*:0]const u8, &self.z_header), 0);
    }

    test {
        try std.testing.expectEqual(@sizeOf(c.git_diff_hunk), @sizeOf(DiffHunk));
        try std.testing.expectEqual(@bitSizeOf(c.git_diff_hunk), @bitSizeOf(DiffHunk));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Description of changes to one entry.
///
/// A `delta` is a file pair with an old and new revision. The old version may be absent if the file was just created and the new
/// version may be absent if the file was deleted. A diff is mostly just a list of deltas.
///
/// When iterating over a diff, this will be passed to most callbacks and you can use the contents to understand exactly what has
/// changed.
///
/// The `old_file` represents the "from" side of the diff and the `new_file` represents to "to" side of the diff.  What those
/// means depend on the function that was used to generate the diff. You can also use the `GIT_DIFF_REVERSE` flag to flip it
/// around.
///
/// Although the two sides of the delta are named `old_file` and `new_file`, they actually may correspond to entries that
/// represent a file, a symbolic link, a submodule commit id, or even a tree (if you are tracking type changes or
/// ignored/untracked directories).
///
/// Under some circumstances, in the name of efficiency, not all fields will be filled in, but we generally try to fill in as much
/// as possible. One example is that the `flags` field may not have either the `BINARY` or the `NOT_BINARY` flag set to avoid
/// examining file contents if you do not pass in hunk and/or line callbacks to the diff foreach iteration function.  It will just
/// use the git attributes for those files.
///
/// The similarity score is zero unless you call `git_diff_find_similar()` which does a similarity analysis of files in the diff.
/// Use that function to do rename and copy detection, and to split heavily modified files in add/delete pairs. After that call,
/// deltas with a status of GIT_DELTA_RENAMED or GIT_DELTA_COPIED will have a similarity score between 0 and 100 indicating how
/// similar the old and new sides are.
///
/// If you ask `git_diff_find_similar` to find heavily modified files to break, but to not *actually* break the records, then
/// GIT_DELTA_MODIFIED records may have a non-zero similarity score if the self-similarity is below the split threshold. To
/// display this value like core Git, invert the score (a la `printf("M%03d", 100 - delta->similarity)`).
pub const DiffDelta = extern struct {
    status: DeltaType,
    flags: DiffFlags,
    /// for RENAMED and COPIED, value 0-100
    similarity: u16,
    number_of_files: u16,
    old_file: DiffFile,
    new_file: DiffFile,

    /// What type of change is described by a git_diff_delta?
    ///
    /// `GIT_DELTA_RENAMED` and `GIT_DELTA_COPIED` will only show up if you run `git_diff_find_similar()` on the diff object.
    ///
    /// `GIT_DELTA_TYPECHANGE` only shows up given `GIT_DIFF_INCLUDE_TYPECHANGE` in the option flags (otherwise type changes will
    /// be split into ADDED / DELETED pairs).
    pub const DeltaType = enum(c_uint) {
        /// no changes
        UNMODIFIED,
        /// entry does not exist in old version
        ADDED,
        /// entry does not exist in new version
        DELETED,
        /// entry content changed between old and new
        MODIFIED,
        /// entry was renamed between old and new
        RENAMED,
        /// entry was copied from another old entry
        COPIED,
        /// entry is ignored item in workdir
        IGNORED,
        /// entry is untracked item in workdir
        UNTRACKED,
        /// type of entry changed between old and new 
        TYPECHANGE,
        /// entry is unreadable
        UNREADABLE,
        /// entry in the index is conflicted
        CONFLICTED,
    };

    test {
        try std.testing.expectEqual(@sizeOf(c.git_diff_delta), @sizeOf(DiffDelta));
        try std.testing.expectEqual(@bitSizeOf(c.git_diff_delta), @bitSizeOf(DiffDelta));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const SimilarityMetric = extern struct {
    file_signature: fn (out: *?*anyopaque, file: *const DiffFile, full_path: [*:0]const u8, payload: ?*anyopaque) callconv(.C) c_int,

    buffer_signature: fn (
        out: *?*anyopaque,
        file: *const DiffFile,
        buf: [*:0]const u8,
        buf_len: usize,
        payload: ?*anyopaque,
    ) callconv(.C) c_int,

    free_signature: fn (sig: ?*anyopaque, payload: ?*anyopaque) callconv(.C) void,

    similarity: fn (score: *c_int, siga: ?*anyopaque, sigb: ?*anyopaque, payload: ?*anyopaque) callconv(.C) c_int,

    payload: ?*anyopaque,

    test {
        try std.testing.expectEqual(@sizeOf(c.git_diff_similarity_metric), @sizeOf(SimilarityMetric));
        try std.testing.expectEqual(@bitSizeOf(c.git_diff_similarity_metric), @bitSizeOf(SimilarityMetric));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Flags for the delta object and the file objects on each side.
///
/// These flags are used for both the `flags` value of the `git_diff_delta` and the flags for the `git_diff_file` objects
/// representing the old and new sides of the delta.  Values outside of this public range should be considered reserved 
/// for internal or future use.
pub const DiffFlags = packed struct {
    /// file(s) treated as binary data
    BINARY: bool = false,
    /// file(s) treated as text data
    NOT_BINARY: bool = false,
    /// `id` value is known correct
    VALID_ID: bool = false,
    /// file exists at this side of the delta
    EXISTS: bool = false,

    z_padding1: u12 = 0,
    z_padding2: u16 = 0,

    pub fn format(
        value: DiffFlags,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        return internal.formatWithoutFields(
            value,
            options,
            writer,
            &.{ "z_padding1", "z_padding2" },
        );
    }

    test {
        try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(DiffFlags));
        try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(DiffFlags));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Description of one side of a delta.
///
/// Although this is called a "file", it could represent a file, a symbolic link, a submodule commit id, or even a tree
/// (although that only if you are tracking type changes or ignored/untracked directories).
pub const DiffFile = extern struct {
    /// The `git_oid` of the item.  If the entry represents an absent side of a diff (e.g. the `old_file` of a
    /// `GIT_DELTA_ADDED` delta), then the oid will be zeroes.
    id: git.Oid,
    /// Path to the entry relative to the working directory of the repository.
    path: [*:0]const u8,
    /// The size of the entry in bytes.
    size: u64,
    flags: DiffFlags,
    /// Roughly, the stat() `st_mode` value for the item.
    mode: FileMode,
    /// Represents the known length of the `id` field, when converted to a hex string.  It is generally `GIT_OID_HEXSZ`,
    /// unless this delta was created from reading a patch file, in which case it may be abbreviated to something reasonable,
    /// like 7 characters.
    id_abbrev: u16,

    /// Valid modes for index and tree entries.
    pub const FileMode = enum(u16) {
        UNREADABLE = 0o000000,
        TREE = 0o040000,
        BLOB = 0o100644,
        BLOB_EXECUTABLE = 0o100755,
        LINK = 0o120000,
        COMMIT = 0o160000,
    };

    test {
        try std.testing.expectEqual(@sizeOf(c.git_diff_file), @sizeOf(DiffFile));
        try std.testing.expectEqual(@bitSizeOf(c.git_diff_file), @bitSizeOf(DiffFile));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
