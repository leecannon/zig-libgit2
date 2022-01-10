const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const GitAllocator = extern struct {
    malloc: fn (n: usize, file: [*:0]const u8, line: c_int) callconv(.C) *anyopaque,
    calloc: fn (nelem: usize, elsize: usize, file: [*:0]const u8, line: c_int) callconv(.C) *anyopaque,
    strdup: fn (str: [*:0]const u8, file: [*:0]const u8, line: c_int) callconv(.C) [*:0]const u8,
    strndup: fn (str: [*:0]const u8, n: usize, file: [*:0]const u8, line: c_int) callconv(.C) [*:0]const u8,
    substrdup: fn (str: [*:0]const u8, n: usize, file: [*:0]const u8, line: c_int) callconv(.C) [*:0]const u8,
    realloc: fn (ptr: *anyopaque, size: usize, file: [*:0]const u8, line: c_int) callconv(.C) *anyopaque,
    reallocarray: fn (ptr: *anyopaque, nelem: usize, elsize: usize, file: [*:0]const u8, line: c_int) callconv(.C) *anyopaque,
    mallocarray: fn (nelem: usize, elsize: usize, file: [*:0]const u8, line: c_int) callconv(.C) *anyopaque,
    free: fn (ptr: *anyopaque) callconv(.C) void,

    test {
        try std.testing.expectEqual(@sizeOf(c.git_allocator), @sizeOf(GitAllocator));
        try std.testing.expectEqual(@bitSizeOf(c.git_allocator), @bitSizeOf(GitAllocator));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
