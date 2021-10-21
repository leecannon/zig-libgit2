const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Blob = opaque {
    pub fn deinit(self: *Blob) void {
        log.debug("Blob.deinit called", .{});

        raw.git_blob_free(internal.toC(self));

        log.debug("Blob freed successfully", .{});
    }

    pub fn id(self: *const Blob) *const git.Oid {
        log.debug("Blame.id called", .{});

        const ret = internal.fromC(raw.git_blob_id(internal.toC(self)).?);

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            if (ret.formatHex(&buf)) |slice| {
                log.debug("successfully fetched blob id: {s}", .{slice});
            } else |_| {
                log.debug("successfully fetched blob id, but unable to format it", .{});
            }
        }

        return ret;
    }

    pub fn owner(self: *const Blob) *git.Repository {
        log.debug("Blame.owner called", .{});

        const ret = internal.fromC(raw.git_blob_owner(internal.toC(self)).?);

        log.debug("successfully fetched owning repository: {s}", .{ret});

        return ret;
    }

    pub fn rawContent(self: *const Blob) !*const c_void {
        log.debug("Blame.rawContent called", .{});

        if (raw.git_blob_rawcontent(internal.toC(self))) |ret| {
            log.debug("successfully fetched raw content pointer: {*}", .{ret});

            return ret;
        } else {
            return error.Invalid;
        }
    }

    pub fn rawContentLength(self: *const Blob) u64 {
        log.debug("Blame.rawContentLength called", .{});

        const ret = raw.git_blob_rawsize(internal.toC(self));

        log.debug("successfully fetched raw content length: {}", .{ret});

        return ret;
    }

    pub fn isBinary(self: *const Blob) bool {
        return raw.git_blob_is_binary(internal.toC(self)) == 1;
    }

    pub fn copy(self: *const Blob) !*Blob {
        var new_blob: ?*raw.git_blob = undefined;
        // This always returns 0
        _ = raw.git_blob_dup(&new_blob, internal.toC(self));
        return internal.fromC(new_blob.?);
    }

    pub usingnamespace if (internal.available(.@"0.99.0")) struct {
        pub fn filter(self: *Blob, as_path: [:0]const u8, options: FilterOptions) !git.Buf {
            log.debug("Blob.filter called, as_path={s}, options={}", .{ as_path, options });

            var buf: git.Buf = undefined;

            try internal.wrapCall("git_blob_filter", .{ internal.toC(&buf), internal.toC(self), as_path.ptr, &options.toC() });

            log.debug("successfully filtered blob", .{});

            return buf;
        }

        pub const FilterOptions = struct {
            flags: FilterFlags = .{},
            /// The commit to load attributes from, when `FilterFlags.ATTRIBUTES_FROM_COMMIT` is specified.
            commit_id: ?*git.Oid = null,

            pub const FilterFlags = packed struct {
                /// When set, filters will not be applied to binary files.
                CHECK_FOR_BINARY: bool = false,

                /// When set, filters will not load configuration from the system-wide `gitattributes` in `/etc` (or system equivalent).
                NO_SYSTEM_ATTRIBUTES: bool = false,

                /// When set, filters will be loaded from a `.gitattributes` file in the HEAD commit.
                ATTRIBUTES_FROM_HEAD: bool = false,

                /// When set, filters will be loaded from a `.gitattributes` file in the specified commit.
                ATTRIBUTES_FROM_COMMIT: bool = false,

                z_padding: u28 = 0,

                pub fn format(
                    value: FilterFlags,
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
                    try std.testing.expectEqual(@sizeOf(u32), @sizeOf(FilterFlags));
                    try std.testing.expectEqual(@bitSizeOf(u32), @bitSizeOf(FilterFlags));
                }

                comptime {
                    std.testing.refAllDecls(@This());
                }
            };

            pub fn toC(self: FilterOptions) raw.git_blob_filter_options {
                return .{
                    .version = raw.GIT_BLOB_FILTER_OPTIONS_VERSION,
                    .flags = @bitCast(u32, self.flags),
                    .commit_id = if (self.commit_id) |commit| internal.toC(commit) else null,
                };
            }

            comptime {
                std.testing.refAllDecls(@This());
            }
        };
    } else struct {};

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
