const std = @import("std");
const raw = @import("internal/raw.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const GitAllocator = extern struct {
    malloc: fn (n: usize, file: [*:0]const u8, line: c_int) callconv(.C) *c_void,
    calloc: fn (nelem: usize, elsize: usize, file: [*:0]const u8, line: c_int) callconv(.C) *c_void,
    strdup: fn (str: [*:0]const u8, file: [*:0]const u8, line: c_int) callconv(.C) [*:0]const u8,
    strndup: fn (str: [*:0]const u8, n: usize, file: [*:0]const u8, line: c_int) callconv(.C) [*:0]const u8,
    substrdup: fn (str: [*:0]const u8, n: usize, file: [*:0]const u8, line: c_int) callconv(.C) [*:0]const u8,
    realloc: fn (ptr: *c_void, size: usize, file: [*:0]const u8, line: c_int) callconv(.C) *c_void,
    reallocarray: fn (ptr: *c_void, nelem: usize, elsize: usize, file: [*:0]const u8, line: c_int) callconv(.C) *c_void,
    mallocarray: fn (nelem: usize, elsize: usize, file: [*:0]const u8, line: c_int) callconv(.C) *c_void,
    free: fn (ptr: *c_void) callconv(.C) void,

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
