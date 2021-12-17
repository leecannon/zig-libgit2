const std = @import("std");
const raw = @import("raw.zig");
const c = @import("c.zig");
const git = @import("../git.zig");
const log = std.log.scoped(.git);
pub const LibraryVersion = @import("version.zig").LibraryVersion;

pub const version: LibraryVersion = @intToEnum(LibraryVersion, @import("build_options").raw_version);

pub inline fn available(comptime minimum_version: LibraryVersion) bool {
    return @enumToInt(minimum_version) <= @import("build_options").raw_version;
}

pub inline fn wrapCall(comptime name: []const u8, args: anytype) git.GitError!void {
    checkForError(@call(.{}, @field(raw, name), args)) catch |err| {

        // We dont want to output log messages in tests, as the error might be expected
        // also dont incur the cost of calling `getDetailedLastError` if we are not going to use it
        if (!@import("builtin").is_test and @enumToInt(std.log.Level.warn) <= @enumToInt(std.log.level)) {
            if (git.getDetailedLastError()) |detailed| {
                log.warn(name ++ " failed with error {s}/{s} - {s}", .{
                    @errorName(err),
                    @tagName(detailed.class),
                    detailed.message(),
                });
            } else {
                log.warn(name ++ " failed with error {s}", .{@errorName(err)});
            }
        }

        return err;
    };
}

pub inline fn wrapCallWithReturn(
    comptime name: []const u8,
    args: anytype,
) git.GitError!@typeInfo(@TypeOf(@field(raw, name))).Fn.return_type.? {
    const value = @call(.{}, @field(raw, name), args);
    checkForError(value) catch |err| {

        // We dont want to output log messages in tests, as the error might be expected
        // also dont incur the cost of calling `getDetailedLastError` if we are not going to use it
        if (!@import("builtin").is_test and @enumToInt(std.log.Level.warn) <= @enumToInt(std.log.level)) {
            if (git.getDetailedLastError()) |detailed| {
                log.warn(name ++ " failed with error {s}/{s} - {s}", .{
                    @errorName(err),
                    @tagName(detailed.class),
                    detailed.message(),
                });
            } else {
                log.warn(name ++ " failed with error {s}", .{@errorName(err)});
            }
        }
        return err;
    };
    return value;
}

fn checkForError(value: raw.git_error_code) git.GitError!void {
    if (value >= 0) return;
    return switch (value) {
        raw.GIT_ERROR => git.GitError.GenericError,
        raw.GIT_ENOTFOUND => git.GitError.NotFound,
        raw.GIT_EEXISTS => git.GitError.Exists,
        raw.GIT_EAMBIGUOUS => git.GitError.Ambiguous,
        raw.GIT_EBUFS => git.GitError.BufferTooShort,
        raw.GIT_EUSER => git.GitError.User,
        raw.GIT_EBAREREPO => git.GitError.BareRepo,
        raw.GIT_EUNBORNBRANCH => git.GitError.UnbornBranch,
        raw.GIT_EUNMERGED => git.GitError.Unmerged,
        raw.GIT_ENONFASTFORWARD => git.GitError.NonFastForwardable,
        raw.GIT_EINVALIDSPEC => git.GitError.InvalidSpec,
        raw.GIT_ECONFLICT => git.GitError.Conflict,
        raw.GIT_ELOCKED => git.GitError.Locked,
        raw.GIT_EMODIFIED => git.GitError.Modifed,
        raw.GIT_EAUTH => git.GitError.Auth,
        raw.GIT_ECERTIFICATE => git.GitError.Certificate,
        raw.GIT_EAPPLIED => git.GitError.Applied,
        raw.GIT_EPEEL => git.GitError.Peel,
        raw.GIT_EEOF => git.GitError.EndOfFile,
        raw.GIT_EINVALID => git.GitError.Invalid,
        raw.GIT_EUNCOMMITTED => git.GitError.Uncommited,
        raw.GIT_EDIRECTORY => git.GitError.Directory,
        raw.GIT_EMERGECONFLICT => git.GitError.MergeConflict,
        raw.GIT_PASSTHROUGH => git.GitError.Passthrough,
        raw.GIT_ITEROVER => git.GitError.IterOver,
        raw.GIT_RETRY => git.GitError.Retry,
        raw.GIT_EMISMATCH => git.GitError.Mismatch,
        raw.GIT_EINDEXDIRTY => git.GitError.IndexDirty,
        raw.GIT_EAPPLYFAIL => git.GitError.ApplyFail,
        else => {
            log.err("encountered unknown libgit2 error: {}", .{value});
            unreachable;
        },
    };
}

pub fn formatWithoutFields(value: anytype, options: std.fmt.FormatOptions, writer: anytype, comptime blacklist: []const []const u8) !void {
    // This ANY const is a workaround for: https://github.com/ziglang/zig/issues/7948
    const ANY = "any";

    const T = @TypeOf(value);

    switch (@typeInfo(T)) {
        .Struct => |info| {
            try writer.writeAll(@typeName(T));
            try writer.writeAll("{");
            comptime var i = 0;
            outer: inline for (info.fields) |f| {
                inline for (blacklist) |blacklist_item| {
                    if (comptime std.mem.indexOf(u8, f.name, blacklist_item) != null) continue :outer;
                }

                if (i == 0) {
                    try writer.writeAll(" .");
                } else {
                    try writer.writeAll(", .");
                }

                try writer.writeAll(f.name);
                try writer.writeAll(" = ");
                try std.fmt.formatType(@field(value, f.name), ANY, options, writer, std.fmt.default_max_depth - 1);

                i += 1;
            }
            try writer.writeAll(" }");
        },
        else => {
            @compileError("Unimplemented for: " ++ @typeName(T));
        },
    }
}

comptime {
    std.testing.refAllDecls(@This());
}
