const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

/// Unique identity of any object (commit, tree, blob, tag).
pub const Oid = extern struct {
    id: [20]u8,

    /// Minimum length (in number of hex characters, i.e. packets of 4 bits) of an oid prefix
    pub const MIN_PREFIX_LEN = c.GIT_OID_MINPREFIXLEN;

    /// Size (in bytes) of a hex formatted oid
    pub const HEX_BUFFER_SIZE = c.GIT_OID_HEXSZ;

    pub fn formatHexAlloc(self: Oid, allocator: *std.mem.Allocator) ![]const u8 {
        const buf = try allocator.alloc(u8, HEX_BUFFER_SIZE);
        errdefer allocator.free(buf);
        return try self.formatHex(buf);
    }

    /// `buf` must be atleast `HEX_BUFFER_SIZE` long.
    pub fn formatHex(self: Oid, buf: []u8) ![]const u8 {
        if (buf.len < HEX_BUFFER_SIZE) return error.BufferTooShort;

        try internal.wrapCall("git_oid_fmt", .{ buf.ptr, @ptrCast(*const c.git_oid, &self) });

        return buf[0..HEX_BUFFER_SIZE];
    }

    pub fn formatHexAllocZ(self: Oid, allocator: *std.mem.Allocator) ![:0]const u8 {
        const buf = try allocator.allocSentinel(u8, HEX_BUFFER_SIZE, 0);
        errdefer allocator.free(buf);
        return (try self.formatHex(buf))[0.. :0];
    }

    /// `buf` must be atleast `HEX_BUFFER_SIZE + 1` long.
    pub fn formatHexZ(self: Oid, buf: []u8) ![:0]const u8 {
        if (buf.len < (HEX_BUFFER_SIZE + 1)) return error.BufferTooShort;

        try internal.wrapCall("git_oid_fmt", .{ buf.ptr, @ptrCast(*const c.git_oid, &self) });
        buf[HEX_BUFFER_SIZE] = 0;

        return buf[0..HEX_BUFFER_SIZE :0];
    }

    /// Allows partial output
    pub fn formatHexCountAlloc(self: Oid, allocator: *std.mem.Allocator, length: usize) ![]const u8 {
        const buf = try allocator.alloc(u8, length);
        errdefer allocator.free(buf);
        return try self.formatHexCount(buf, length);
    }

    /// Allows partial output
    pub fn formatHexCount(self: Oid, buf: []u8, length: usize) ![]const u8 {
        if (buf.len < length) return error.BufferTooShort;

        try internal.wrapCall("git_oid_nfmt", .{ buf.ptr, length, @ptrCast(*const c.git_oid, &self) });

        return buf[0..length];
    }

    /// Allows partial output
    pub fn formatHexCountAllocZ(self: Oid, allocator: *std.mem.Allocator, length: usize) ![:0]const u8 {
        const buf = try allocator.allocSentinel(u8, length, 0);
        errdefer allocator.free(buf);
        return (try self.formatHexCount(buf, length))[0.. :0];
    }

    /// Allows partial output
    pub fn formatHexCountZ(self: Oid, buf: []u8, length: usize) ![:0]const u8 {
        if (buf.len < (length + 1)) return error.BufferTooShort;

        try internal.wrapCall("git_oid_nfmt", .{ buf.ptr, length, @ptrCast(*const c.git_oid, &self) });
        buf[length] = 0;

        return buf[0..length :0];
    }

    pub fn formatHexPathAlloc(self: Oid, allocator: *std.mem.Allocator) ![]const u8 {
        const buf = try allocator.alloc(u8, HEX_BUFFER_SIZE + 1);
        errdefer allocator.free(buf);
        return try self.formatHexPath(buf);
    }

    /// `buf` must be atleast `HEX_BUFFER_SIZE + 1` long.
    pub fn formatHexPath(self: Oid, buf: []u8) ![]const u8 {
        if (buf.len < HEX_BUFFER_SIZE + 1) return error.BufferTooShort;

        try internal.wrapCall("git_oid_pathfmt", .{ buf.ptr, @ptrCast(*const c.git_oid, &self) });

        return buf[0..HEX_BUFFER_SIZE];
    }

    pub fn formatHexPathAllocZ(self: Oid, allocator: *std.mem.Allocator) ![:0]const u8 {
        const buf = try allocator.allocSentinel(u8, HEX_BUFFER_SIZE + 1, 0);
        errdefer allocator.free(buf);
        return (try self.formatHexPath(buf))[0.. :0];
    }

    /// `buf` must be atleast `HEX_BUFFER_SIZE + 2` long.
    pub fn formatHexPathZ(self: Oid, buf: []u8) ![:0]const u8 {
        if (buf.len < (HEX_BUFFER_SIZE + 2)) return error.BufferTooShort;

        try internal.wrapCall("git_oid_pathfmt", .{ buf.ptr, @ptrCast(*const c.git_oid, &self) });
        buf[HEX_BUFFER_SIZE] = 0;

        return buf[0..HEX_BUFFER_SIZE :0];
    }

    pub fn tryParse(str: [:0]const u8) ?Oid {
        return tryParsePtr(str.ptr);
    }

    pub fn tryParsePtr(str: [*:0]const u8) ?Oid {
        var result: Oid = undefined;
        internal.wrapCall("git_oid_fromstrp", .{ @ptrCast(*c.git_oid, &result), str }) catch {
            return null;
        };
        return result;
    }

    /// Parse `length` characters of a hex formatted object id into a `Oid`
    ///
    /// If `length` is odd, the last byte's high nibble will be read in and the low nibble set to zero.
    pub fn parseCount(buf: []const u8, length: usize) !Oid {
        if (buf.len < length) return error.BufferTooShort;

        var result: Oid = undefined;
        try internal.wrapCall("git_oid_fromstrn", .{ @ptrCast(*c.git_oid, &result), buf.ptr, length });
        return result;
    }

    /// <0 if a < b; 0 if a == b; >0 if a > b
    pub fn compare(a: Oid, b: Oid) c_int {
        return c.git_oid_cmp(@ptrCast(*const c.git_oid, &a), @ptrCast(*const c.git_oid, &b));
    }

    pub fn equal(self: Oid, other: Oid) bool {
        return c.git_oid_equal(@ptrCast(*const c.git_oid, &self), @ptrCast(*const c.git_oid, &other)) == 1;
    }

    pub fn compareCount(self: Oid, other: Oid, count: usize) bool {
        return c.git_oid_ncmp(@ptrCast(*const c.git_oid, &self), @ptrCast(*const c.git_oid, &other), count) == 0;
    }

    pub fn equalStr(self: Oid, str: [:0]const u8) bool {
        return c.git_oid_streq(@ptrCast(*const c.git_oid, &self), str.ptr) == 0;
    }

    /// <0 if a < str; 0 if a == str; >0 if a > str
    pub fn compareStr(a: Oid, str: [:0]const u8) c_int {
        return c.git_oid_strcmp(@ptrCast(*const c.git_oid, &a), str.ptr);
    }

    pub fn allZeros(self: Oid) bool {
        for (self.id) |i| if (i != 0) return false;
        return true;
    }

    pub fn zero() Oid {
        return .{ .id = [_]u8{0} ** 20 };
    }

    test {
        try std.testing.expectEqual(@sizeOf(c.git_oid), @sizeOf(Oid));
        try std.testing.expectEqual(@bitSizeOf(c.git_oid), @bitSizeOf(Oid));
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// The OID shortener is used to process a list of OIDs in text form and return the shortest length that would uniquely identify
/// all of them.
///
/// E.g. look at the result of `git log --abbrev-commit`.
pub const OidShortener = opaque {

    /// `min_length` is the minimal length for all identifiers, which will be used even if shorter OIDs would still be unique.
    pub fn init(min_length: usize) !*OidShortener {
        log.debug("OidShortener.init called, min_length: {}", .{min_length});

        if (c.git_oid_shorten_new(min_length)) |ret| {
            log.debug("Oid shortener created successfully", .{});

            return @ptrCast(*OidShortener, ret);
        }

        return error.OutOfMemory;
    }

    pub fn add(self: *OidShortener, str: []const u8) !c_uint {
        log.debug("OidShortener.add called, str: {s}", .{str});

        if (str.len < Oid.HEX_BUFFER_SIZE) return error.BufferTooShort;
        const ret = try internal.wrapCallWithReturn("git_oid_shorten_add", .{
            @ptrCast(*c.git_oid_shorten, self),
            str.ptr,
        });

        log.debug("shortest unique Oid length: {}", .{ret});

        return @bitCast(c_uint, ret);
    }

    pub fn deinit(self: *OidShortener) void {
        log.debug("OidShortener.deinit called", .{});

        c.git_oid_shorten_free(@ptrCast(*c.git_oid_shorten, self));

        log.debug("Oid shortener freed successfully", .{});
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
