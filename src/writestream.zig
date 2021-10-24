const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const WriteStream = extern struct {
    /// if this returns non-zero this will be counted as an error
    write: fn (self: *WriteStream, buffer: [*:0]const u8, len: usize) callconv(.C) c_int,
    /// if this returns non-zero this will be counted as an error
    close: fn (self: *WriteStream) callconv(.C) c_int,
    free: fn (self: *WriteStream) callconv(.C) void,

    pub usingnamespace if (internal.available(.@"0.99.0")) struct {
        pub fn commit(self: *WriteStream) !git.Oid {
            log.debug("WriteStream.commit called", .{});

            var ret: git.Oid = undefined;

            try internal.wrapCall("git_blob_create_from_stream_commit", .{ internal.toC(&ret), internal.toC(self) });

            // This check is to prevent formating the oid when we are not going to print anything
            if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
                var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
                const slice = try ret.formatHex(&buf);
                log.debug("successfully fetched blob id: {s}", .{slice});
            }

            return ret;
        }
    } else struct {};

    test {
        try std.testing.expectEqual(@sizeOf(raw.git_writestream), @sizeOf(WriteStream));
        try std.testing.expectEqual(@bitSizeOf(raw.git_writestream), @bitSizeOf(WriteStream));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}