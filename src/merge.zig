const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const SimilarityMetric = extern struct {
    file_signature: fn (out: *?*anyopaque, file: *const git.DiffFile, full_path: [*:0]const u8, payload: ?*anyopaque) callconv(.C) c_int,

    buffer_signature: fn (
        out: *?*anyopaque,
        file: *const git.DiffFile,
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

pub const FileFavor = enum(c_uint) {
    /// When a region of a file is changed in both branches, a conflict will be recorded in the index so that `git_checkout` can
    /// produce a merge file with conflict markers in the working directory.
    /// This is the default.
    NORMAL = 0,

    /// When a region of a file is changed in both branches, the file created in the index will contain the "ours" side of any
    /// conflicting region. The index will not record a conflict.
    OURS = 1,

    /// When a region of a file is changed in both branches, the file created in the index will contain the "theirs" side of any
    /// conflicting region. The index will not record a conflict.
    THEIRS = 2,

    /// When a region of a file is changed in both branches, the file created in the index will contain each unique line from each
    /// side, which has the result of combining both files. The index will not record a conflict.
    UNION = 3,
};

pub const MergeOptions = struct {
    flags: MergeFlags = .{},

    /// Similarity to consider a file renamed (default 50). If `Flags.IND_RENAMES` is enabled, added files will be compared with
    /// deleted files to determine their similarity. Files that are more similar than the rename threshold (percentage-wise) will
    /// be treated as a rename.
    rename_threshold: c_uint = 0,

    /// Maximum similarity sources to examine for renames (default 200). If the number of rename candidates (add / delete pairs)
    /// is greater than this value, inexact rename detection is aborted.
    ///
    /// This setting overrides the `merge.renameLimit` configuration value.
    target_limit: c_uint = 0,

    ///  Pluggable similarity metric; pass `null` to use internal metric
    metric: ?*SimilarityMetric = null,

    /// Maximum number of times to merge common ancestors to build a virtual merge base when faced with criss-cross merges. When
    /// this limit is reached, the next ancestor will simply be used instead of attempting to merge it. The default is unlimited.
    recursion_limit: c_uint = 0,

    /// Default merge driver to be used when both sides of a merge have changed. The default is the `text` driver.
    default_driver: ?[:0]const u8 = null,

    /// Flags for handling conflicting content, to be used with the standard (`text`) merge driver.
    file_favor: FileFavor = .NORMAL,

    file_flags: FileFlags = .{},

    pub const MergeFlags = packed struct {
        /// Detect renames that occur between the common ancestor and the "ours" side or the common ancestor and the "theirs"
        /// side. This will enable the ability to merge between a modified and renamed file.
        FIND_RENAMES: bool = false,

        /// If a conflict occurs, exit immediately instead of attempting to continue resolving conflicts. The merge operation will
        /// fail with `GitError.MERGECONFLICT` and no index will be returned.
        FAIL_ON_CONFLICT: bool = false,

        /// Do not write the REUC extension on the generated index
        SKIP_REUC: bool = false,

        /// If the commits being merged have multiple merge bases, do not build a recursive merge base (by merging the multiple
        /// merge bases), instead simply use the first base.  This flag provides a similar merge base to `git-merge-resolve`.
        NO_RECURSIVE: bool = false,

        z_padding: u12 = 0,
        z_padding2: u16 = 0,

        pub fn format(
            value: MergeFlags,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            return internal.formatWithoutFields(
                value,
                options,
                writer,
                &.{ "z_padding", "z_padding2" },
            );
        }

        test {
            try std.testing.expectEqual(@sizeOf(c.git_merge_flag_t), @sizeOf(MergeFlags));
            try std.testing.expectEqual(@bitSizeOf(c.git_merge_flag_t), @bitSizeOf(MergeFlags));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    pub const FileFlags = packed struct {
        /// Create standard conflicted merge files
        STYLE_MERGE: bool = false,

        /// Create diff3-style files
        STYLE_DIFF3: bool = false,

        /// Condense non-alphanumeric regions for simplified diff file
        SIMPLIFY_ALNUM: bool = false,

        /// Ignore all whitespace
        IGNORE_WHITESPACE: bool = false,

        /// Ignore changes in amount of whitespace
        IGNORE_WHITESPACE_CHANGE: bool = false,

        /// Ignore whitespace at end of line
        IGNORE_WHITESPACE_EOL: bool = false,

        /// Use the "patience diff" algorithm
        DIFF_PATIENCE: bool = false,

        /// Take extra time to find minimal diff
        DIFF_MINIMAL: bool = false,

        z_padding: u8 = 0,
        z_padding2: u16 = 0,

        pub fn format(
            value: FileFlags,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            return internal.formatWithoutFields(
                value,
                options,
                writer,
                &.{ "z_padding", "z_padding2" },
            );
        }

        test {
            try std.testing.expectEqual(@sizeOf(c.git_merge_file_flag_t), @sizeOf(FileFlags));
            try std.testing.expectEqual(@bitSizeOf(c.git_merge_file_flag_t), @bitSizeOf(FileFlags));
        }

        comptime {
            std.testing.refAllDecls(@This());
        }
    };

    pub fn makeCOptionObject(self: MergeOptions) c.git_merge_options {
        return .{
            .version = c.GIT_MERGE_OPTIONS_VERSION,
            .flags = @bitCast(u32, self.flags),
            .rename_threshold = self.rename_threshold,
            .target_limit = self.target_limit,
            .metric = @ptrCast(?*c.git_diff_similarity_metric, self.metric),
            .recursion_limit = self.recursion_limit,
            .default_driver = if (self.default_driver) |ptr| ptr.ptr else null,
            .file_favor = @enumToInt(self.file_favor),
            .file_flags = @bitCast(u32, self.file_flags),
        };
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
