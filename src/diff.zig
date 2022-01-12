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

    /// Match a pathspec against files in a diff list.
    ///
    /// This matches the pathspec against the files in the given diff list.
    ///
    /// If `match_list` is not `null`, this returns a `git.PathspecMatchList`. That contains the list of all matched filenames
    /// (unless you pass the `MatchOptions.failures_only` options) and may also contain the list of pathspecs with no match (if
    /// you used the `MatchOptions.find_failures` option).
    /// You must call `PathspecMatchList.deinit()` on this object.
    ///
    /// ## Parameters
    /// * `pathspec` - Pathspec to be matched
    /// * `options` - Options to control match
    /// * `match_list` - Output list of matches; pass `null` to just get return value
    pub fn pathspecMatch(
        self: *Diff,
        pathspec: *git.Pathspec,
        options: git.PathspecMatchOptions,
        match_list: ?**git.PathspecMatchList,
    ) !bool {
        log.debug("Diff.pathspecMatch called, options: {}, pathspec: {*}", .{ options, pathspec });

        const ret = (try internal.wrapCallWithReturn("git_pathspec_match_diff", .{
            @ptrCast(?*?*c.git_pathspec_match_list, match_list),
            @ptrCast(*c.git_diff, self),
            @bitCast(c.git_pathspec_flag_t, options),
            @ptrCast(*c.git_pathspec, pathspec),
        })) != 0;

        log.debug("match: {}", .{ret});

        return ret;
    }

    /// Get performance data for a diff object.
    pub fn getPerfData(self: *const Diff) !DiffPerfData {
        log.debug("Diff.getPerfData called", .{});

        var c_ret = c.git_diff_perfdata{
            .version = c.GIT_DIFF_PERFDATA_VERSION,
            .stat_calls = 0,
            .oid_calculations = 0,
        };

        try internal.wrapCall("git_diff_get_perfdata", .{
            &c_ret,
            @ptrCast(*const c.git_diff, self),
        });

        const ret: DiffPerfData = .{
            .stat_calls = c_ret.stat_calls,
            .oid_calculations = c_ret.oid_calculations,
        };

        log.debug("perf data: {}", .{ret});

        return ret;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Performance data from diffing
pub const DiffPerfData = struct {
    /// Number of stat() calls performed
    stat_calls: usize,

    /// Number of ID calculations
    oid_calculations: usize,

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
    pub const header_size: usize = c.GIT_DIFF_HUNK_HEADER_SIZE;

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
    /// Use `header`
    z_header: [header_size]u8,

    pub fn header(self: DiffHunk) [:0]const u8 {
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
/// means depend on the function that was used to generate the diff. You can also use the `reverse` flag to flip it
/// around.
///
/// Although the two sides of the delta are named `old_file` and `new_file`, they actually may correspond to entries that
/// represent a file, a symbolic link, a submodule commit id, or even a tree (if you are tracking type changes or
/// ignored/untracked directories).
///
/// Under some circumstances, in the name of efficiency, not all fields will be filled in, but we generally try to fill in as much
/// as possible. One example is that the `flags` field may not have either the `binary` or the `not_binary` flag set to avoid
/// examining file contents if you do not pass in hunk and/or line callbacks to the diff foreach iteration function.  It will just
/// use the git attributes for those files.
///
/// The similarity score is zero unless you call `git_diff_find_similar()` which does a similarity analysis of files in the diff.
/// Use that function to do rename and copy detection, and to split heavily modified files in add/delete pairs. After that call,
/// deltas with a status of `renamed` or `copied` will have a similarity score between 0 and 100 indicating how
/// similar the old and new sides are.
///
/// If you ask `git_diff_find_similar` to find heavily modified files to break, but to not *actually* break the records, then
/// modified records may have a non-zero similarity score if the self-similarity is below the split threshold. To
/// display this value like core Git, invert the score (a la `printf("M%03d", 100 - delta->similarity)`).
pub const DiffDelta = extern struct {
    status: DeltaType,
    flags: DiffFlags,
    /// for renamed and copied, value 0-100
    similarity: u16,
    number_of_files: u16,
    old_file: DiffFile,
    new_file: DiffFile,

    /// What type of change is described by a git_diff_delta?
    ///
    /// `renamed` and `copied` will only show up if you run `git_diff_find_similar()` on the diff object.
    ///
    /// `typechange` only shows up given `GIT_DIFF_INCLUDE_typechange` in the option flags (otherwise type changes will
    /// be split into added / deleted pairs).
    pub const DeltaType = enum(c_uint) {
        /// no changes
        unmodified,
        /// entry does not exist in old version
        added,
        /// entry does not exist in new version
        deleted,
        /// entry content changed between old and new
        modified,
        /// entry was renamed between old and new
        renamed,
        /// entry was copied from another old entry
        copied,
        /// entry is ignored item in workdir
        ignored,
        /// entry is untracked item in workdir
        untracked,
        /// type of entry changed between old and new 
        typechange,
        /// entry is unreadable
        unreadable,
        /// entry in the index is conflicted
        conflicted,
    };

    test {
        try std.testing.expectEqual(@sizeOf(c.git_diff_delta), @sizeOf(DiffDelta));
        try std.testing.expectEqual(@bitSizeOf(c.git_diff_delta), @bitSizeOf(DiffDelta));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const ApplyOptions = struct {
    /// callback that will be made per delta (file)
    ///
    /// When the callback:
    ///   - returns < 0, the apply process will be aborted.
    ///   - returns > 0, the delta will not be applied, but the apply process continues
    ///   - returns 0, the delta is applied, and the apply process continues.
    delta_cb: ?fn (delta: *const git.DiffDelta) callconv(.C) c_int = null,

    /// callback that will be made per hunk
    ///
    /// When the callback:
    ///   - returns < 0, the apply process will be aborted.
    ///   - returns > 0, the hunk will not be applied, but the apply process continues
    ///   - returns 0, the hunk is applied, and the apply process continues.
    hunk_cb: ?fn (hunk: *const git.DiffHunk) callconv(.C) c_int = null,

    flags: ApplyOptionsFlags = .{},

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub fn ApplyOptionsWithUserData(comptime T: type) type {
    return struct {
        /// callback that will be made per delta (file)
        ///
        /// When the callback:
        ///   - returns < 0, the apply process will be aborted.
        ///   - returns > 0, the delta will not be applied, but the apply process continues
        ///   - returns 0, the delta is applied, and the apply process continues.
        delta_cb: ?fn (delta: *const git.DiffDelta, user_data: T) callconv(.C) c_int = null,

        /// callback that will be made per hunk
        ///
        /// When the callback:
        ///   - returns < 0, the apply process will be aborted.
        ///   - returns > 0, the hunk will not be applied, but the apply process continues
        ///   - returns 0, the hunk is applied, and the apply process continues.
        hunk_cb: ?fn (hunk: *const git.DiffHunk, user_data: T) callconv(.C) c_int = null,

        payload: T,

        flags: git.ApplyOptionsFlags = .{},

        comptime {
            std.testing.refAllDecls(@This());
        }
    };
}

pub const ApplyOptionsFlags = packed struct {
    /// Don't actually make changes, just test that the patch applies. This is the equivalent of `git apply --check`.
    check: bool = false,

    z_padding: u31 = 0,

    pub fn format(
        value: git.ApplyOptionsFlags,
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
        try std.testing.expectEqual(@sizeOf(c_uint), @sizeOf(ApplyOptionsFlags));
        try std.testing.expectEqual(@bitSizeOf(c_uint), @bitSizeOf(ApplyOptionsFlags));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const ApplyLocation = enum(c_uint) {
    /// Apply the patch to the workdir, leaving the index untouched.
    /// This is the equivalent of `git apply` with no location argument.
    workdir = 0,

    /// Apply the patch to the index, leaving the working directory
    /// untouched.  This is the equivalent of `git apply --cached`.
    index = 1,

    /// Apply the patch to both the working directory and the index.
    /// This is the equivalent of `git apply --index`.
    both = 2,
};

/// Description of one side of a delta.
///
/// Although this is called a "file", it could represent a file, a symbolic link, a submodule commit id, or even a tree
/// (although that only if you are tracking type changes or ignored/untracked directories).
pub const DiffFile = extern struct {
    /// The `git_oid` of the item.  If the entry represents an absent side of a diff (e.g. the `old_file` of a
    /// `GIT_DELTA_added` delta), then the oid will be zeroes.
    id: git.Oid,
    /// Path to the entry relative to the working directory of the repository.
    path: [*:0]const u8,
    /// The size of the entry in bytes.
    size: u64,
    flags: DiffFlags,
    /// Roughly, the stat() `st_mode` value for the item.
    mode: git.FileMode,
    /// Represents the known length of the `id` field, when converted to a hex string.  It is generally `git.Oid.hex_buffer_size`,
    /// unless this delta was created from reading a patch file, in which case it may be abbreviated to something reasonable,
    /// like 7 characters.
    id_abbrev: u16,

    test {
        try std.testing.expectEqual(@sizeOf(c.git_diff_file), @sizeOf(DiffFile));
        try std.testing.expectEqual(@bitSizeOf(c.git_diff_file), @bitSizeOf(DiffFile));
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
    binary: bool = false,
    /// file(s) treated as text data
    not_binary: bool = false,
    /// `id` value is known correct
    valid_id: bool = false,
    /// file exists at this side of the delta
    exists: bool = false,

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

comptime {
    std.testing.refAllDecls(@This());
}
