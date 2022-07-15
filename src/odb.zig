const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Odb = opaque {
    pub fn deinit(self: *Odb) void {
        if (internal.trace_log) log.debug("Odb.deinit called", .{});

        c.git_odb_free(@ptrCast(*c.git_odb, self));
    }

    /// Add an on-disk alternate to an existing Object DB.
    ///
    /// Note that the added path must point to an `objects`, not to a
    /// full repository, to use it as an alternate store.
    ///
    /// Alternate backends are always checked for objects *after*
    /// all the main backends have been exhausted.
    ///
    /// Writing is disabled on alternate backends.
    ///
    /// ## Parameters
    /// * `path` - path to the objects folder for the alternate
    pub fn addDiskAlternate(self: *Odb, path: [:0]const u8) !void {
        if (internal.trace_log) log.debug("Odb.addDiskAlternate called", .{});

        try internal.wrapCall("git_odb_add_disk_alternate", .{
            @ptrCast(*c.git_odb, self),
            path.ptr,
        });
    }

    /// Read an object from the database.
    ///
    /// This method queries all available ODB backends
    /// trying to read the given OID.
    ///
    /// The returned object is reference counted and
    /// internally cached, so it should be closed
    /// by the user once it's no longer in use.
    ///
    /// ## Parameters
    /// * `id` - identity of the object to read
    pub fn read(self: *Odb, id: git.Oid) !*git.OdbObject {
        if (internal.trace_log) log.debug("Odb.read called", .{});

        var object: *git.OdbObject = undefined;

        try internal.wrapCall("git_odb_read", .{
            @ptrCast(*?*c.git_odb_object, &object),
            @ptrCast(*c.git_odb, self),
            @ptrCast(*const c.git_oid, &id),
        });

        return object;
    }

    /// Read an object from the database, given a prefix of its identifier.
    ///
    /// This method queries all available ODB backends trying to match the
    /// 'len' first hexadecimal characters of the 'short_id'.
    /// The remaining (`git.Oid.hex_buffer_size`-len)*4 bits of 'short_id'
    /// must be 0s,  'len' must be at least `git.Oid.min_prefix_len`, and
    /// the prefix must be long enough to identify a unique object in all
    /// the backends; the method will fail otherwise.
    ///
    /// The returned object is reference counted and internally cached,
    /// so it should be closed by the user once it's no longer in use.
    ///
    /// ## Parameters
    /// * `short_id` - identity of the object to read
    /// * `len` - the length of the prefix
    pub fn readPrefix(self: *Odb, short_id: git.Oid, size: usize) !*git.OdbObject {
        if (internal.trace_log) log.debug("Odb.readPrefix called", .{});

        var object: *git.OdbObject = undefined;

        try internal.wrapCall("git_odb_read_prefix", .{
            @ptrCast(*?*c.git_odb_object, &object),
            @ptrCast(*c.git_odb, self),
            @ptrCast(*const c.git_oid, &short_id),
            size,
        });

        return object;
    }

    /// Read the header of an object from the database, without reading its full contents.
    ///
    /// The header includes the length and the type of an object.
    ///
    /// Note that most backends do not support reading only the header of an object,
    /// so the whole object will be read and then the header will be returned.
    ///
    /// ## Parameters
    /// * `id` - identity of the object to read
    pub fn readHeader(self: *Odb, id: git.Oid) !ReadHeaderResult {
        if (internal.trace_log) log.debug("Odb.readHeader called", .{});

        var len: usize = undefined;
        var object_type: git.ObjectType = undefined;

        try internal.wrapCall("git_odb_read_header", .{
            &len,
            @ptrCast(*c.git_object_t, &object_type),
            @ptrCast(*c.git_odb, self),
            @ptrCast(*const c.git_oid, &id),
        });

        return ReadHeaderResult{
            .len = len,
            .object_type = object_type,
        };
    }

    /// Determine if the given object can be found in the object database.
    ///
    /// ## Parameters
    /// * `id` - the object to search for
    pub fn exists(self: *Odb, id: git.Oid) !bool {
        if (internal.trace_log) log.debug("Odb.exists called", .{});

        return (try internal.wrapCallWithReturn("git_odb_exists", .{
            @ptrCast(*c.git_odb, self),
            @ptrCast(*const c.git_oid, &id),
        })) != 0;
    }

    /// Determine if the given object can be found in the object database.
    ///
    /// ## Parameters
    /// * `short_id` - A prefix of the id of the object to read
    /// * `len` - The length of the prefix
    pub fn existsPrefix(self: *Odb, short_id: git.Oid, len: usize) !git.Oid {
        if (internal.trace_log) log.debug("Odb.existsPrefix called", .{});

        var oid: git.Oid = undefined;

        try internal.wrapCall("git_odb_exists_prefix", .{
            @ptrCast(*c.git_oid, &oid),
            @ptrCast(*c.git_odb, self),
            @ptrCast(*const c.git_oid, &short_id),
            len,
        });

        return oid;
    }

    pub const ReadHeaderResult = struct {
        len: usize,
        object_type: git.ObjectType,
    };

    /// Determine if one or more objects can be found in the object database
    /// by their abbreviated object ID and type.
    /// The given slice will be updated in place: for each abbreviated ID that
    /// is unique in the database, and of the given type (if specified), the
    /// full object ID, object ID length (`git.Oid.hex_buffer_size`) and type
    /// will be written back to the slice.
    /// For IDs that are not found (or are ambiguous), the slice entry will be zeroed.
    ///
    /// Note that since this function operates on multiple objects, the underlying
    /// database will not be asked to be reloaded if an object is not found (which
    /// is unlike other object database operations.)
    ///
    /// ## Parameters
    /// * `ids` - A slice of short object IDs to search for
    pub fn expandIds(self: *Odb, ids: []ExpandId) !void {
        if (internal.trace_log) log.debug("Odb.expandIds called", .{});

        try internal.wrapCall("git_odb_expand_ids", .{
            @ptrCast(*c.git_odb, self),
            @ptrCast(*c.git_odb_expand_id, ids.ptr),
            ids.len,
        });
    }

    pub const ExpandId = extern struct {
        /// The object ID to expand
        id: git.Oid,

        /// The length of the object ID (in nibbles, or packets of 4 bits; the
        /// number of hex characters)
        length: u16,

        /// The (optional) type of the object to search for; leave as
        /// `git.ObjectType.any to query for any object matching the ID.
        object_type: git.ObjectType = git.ObjectType.any,
    };

    pub fn repositoryOpen(self: *Odb) !*git.Repository {
        if (internal.trace_log) log.debug("Odb.repositoryOpen called", .{});

        var repo: *git.Repository = undefined;

        try internal.wrapCall("git_repository_wrap_odb", .{
            @ptrCast(*?*c.git_repository, &repo),
            @ptrCast(*c.git_odb, self),
        });

        return repo;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

pub const OdbObject = opaque {
    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
