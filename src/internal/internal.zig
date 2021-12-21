const std = @import("std");
const c = @import("c.zig");
const git = @import("../git.zig");
const log = std.log.scoped(.git);

pub inline fn wrapCall(comptime name: []const u8, args: anytype) git.GitError!void {
    if (@typeInfo(@TypeOf(@field(c, name))).Fn.return_type.? == void) {
        @call(.{}, @field(c, name), args);
        return;
    }

    checkForError(@call(.{}, @field(c, name), args)) catch |err| {
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
) git.GitError!@typeInfo(@TypeOf(@field(c, name))).Fn.return_type.? {
    const value = @call(.{}, @field(c, name), args);
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

fn checkForError(value: c.git_error_code) git.GitError!void {
    if (value >= 0) return;
    return switch (value) {
        c.GIT_ERROR => git.GitError.GenericError,
        c.GIT_ENOTFOUND => git.GitError.NotFound,
        c.GIT_EEXISTS => git.GitError.Exists,
        c.GIT_EAMBIGUOUS => git.GitError.Ambiguous,
        c.GIT_EBUFS => git.GitError.BufferTooShort,
        c.GIT_EUSER => git.GitError.User,
        c.GIT_EBAREREPO => git.GitError.BareRepo,
        c.GIT_EUNBORNBRANCH => git.GitError.UnbornBranch,
        c.GIT_EUNMERGED => git.GitError.Unmerged,
        c.GIT_ENONFASTFORWARD => git.GitError.NonFastForwardable,
        c.GIT_EINVALIDSPEC => git.GitError.InvalidSpec,
        c.GIT_ECONFLICT => git.GitError.Conflict,
        c.GIT_ELOCKED => git.GitError.Locked,
        c.GIT_EMODIFIED => git.GitError.Modifed,
        c.GIT_EAUTH => git.GitError.Auth,
        c.GIT_ECERTIFICATE => git.GitError.Certificate,
        c.GIT_EAPPLIED => git.GitError.Applied,
        c.GIT_EPEEL => git.GitError.Peel,
        c.GIT_EEOF => git.GitError.EndOfFile,
        c.GIT_EINVALID => git.GitError.Invalid,
        c.GIT_EUNCOMMITTED => git.GitError.Uncommited,
        c.GIT_EDIRECTORY => git.GitError.Directory,
        c.GIT_EMERGECONFLICT => git.GitError.MergeConflict,
        c.GIT_PASSTHROUGH => git.GitError.Passthrough,
        c.GIT_ITEROVER => git.GitError.IterOver,
        c.GIT_RETRY => git.GitError.Retry,
        c.GIT_EMISMATCH => git.GitError.Mismatch,
        c.GIT_EINDEXDIRTY => git.GitError.IndexDirty,
        c.GIT_EAPPLYFAIL => git.GitError.ApplyFail,
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
