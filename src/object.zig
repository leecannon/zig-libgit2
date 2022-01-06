const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Object = opaque {
    /// Close an open object
    ///
    /// This method instructs the library to close an existing object; note that `git.Object`s are owned and cached by
    /// the repository so the object may or may not be freed after this library call, depending on how aggressive is the
    /// caching mechanism used by the repository.
    ///
    /// IMPORTANT:
    /// It *is* necessary to call this method when you stop using an object. Failure to do so will cause a memory leak.
    pub fn deinit(self: *Object) void {
        log.debug("Object.deinit called", .{});

        c.git_object_free(@ptrCast(*c.git_object, self));

        log.debug("object freed successfully", .{});
    }

    /// Get the id (SHA1) of a repository object
    pub fn id(self: *const Object) *const git.Oid {
        log.debug("Object.id called", .{});

        const ret = @ptrCast(
            *const git.Oid,
            c.git_object_id(@ptrCast(*const c.git_object, self)),
        );

        // This check is to prevent formating the oid when we are not going to print anything
        if (@enumToInt(std.log.Level.debug) <= @enumToInt(std.log.level)) {
            var buf: [git.Oid.HEX_BUFFER_SIZE]u8 = undefined;
            if (ret.formatHex(&buf)) |slice| {
                log.debug("object id: {s}", .{slice});
            } else |_| {}
        }

        return ret;
    }

    /// Get a short abbreviated OID string for the object
    ///
    /// This starts at the "core.abbrev" length (default 7 characters) and iteratively extends to a longer string if that length
    /// is ambiguous.
    /// The result will be unambiguous (at least until new objects are added to the repository).
    pub fn shortId(self: *const Object) !git.Buf {
        log.debug("Object.shortId called", .{});

        var buf: git.Buf = .{};

        try internal.wrapCall("git_object_short_id", .{
            @ptrCast(*c.git_buf, &buf),
            @ptrCast(*const c.git_object, self),
        });

        log.debug("object short id: {s}", .{buf.toSlice()});

        return buf;
    }

    /// Get the object type of an object
    pub fn objectType(self: *const Object) ObjectType {
        log.debug("Object.objectType called", .{});

        const ret = @intToEnum(
            ObjectType,
            c.git_object_type(@ptrCast(*const c.git_object, self)),
        );

        log.debug("object type: {}", .{ret});

        return ret;
    }

    /// Get the repository that owns this object
    pub fn objectOwner(self: *const Object) *const git.Repository {
        log.debug("Object.objectOwner called", .{});

        const ret = @ptrCast(
            *const git.Repository,
            c.git_object_owner(@ptrCast(*const c.git_object, self)),
        );

        log.debug("object owner: {*}", .{ret});

        return ret;
    }

    /// Describe a commit
    ///
    /// Perform the describe operation on the given committish object.
    pub fn describe(self: *Object, options: git.DescribeOptions) !*git.DescribeResult {
        log.debug("Object.describe called, options={}", .{options});

        var result: *git.DescribeResult = undefined;

        var c_options = options.makeCOptionObject();
        try internal.wrapCall("git_describe_commit", .{
            @ptrCast(*?*c.git_describe_result, &result),
            @ptrCast(*c.git_object, self),
            &c_options,
        });

        log.debug("successfully described commitish object", .{});

        return result;
    }

    /// Lookup an object that represents a tree entry.
    ///
    /// ## Parameters
    /// * `treeish` - root object that can be peeled to a tree
    /// * `path` - relative path from the root object to the desired object
    /// * `object_type` - type of object desired
    pub fn lookupByPath(treeish: *const Object, path: [:0]const u8, object_type: ObjectType) !*Object {
        log.debug("Object.lookupByPath called, path={s}, object_type={}", .{ path, object_type });

        var ret: *Object = undefined;

        try internal.wrapCall("git_object_lookup_bypath", .{
            @ptrCast(*?*c.git_object, &ret),
            @ptrCast(*const c.git_object, treeish),
            path.ptr,
            @enumToInt(object_type),
        });

        log.debug("successfully found object: {*}", .{ret});

        return ret;
    }

    /// Recursively peel an object until an object of the specified type is met.
    ///
    /// If the query cannot be satisfied due to the object model, `error.InvalidSpec` will be returned (e.g. trying to peel a blob
    /// to a tree).
    ///
    /// If you pass `ObjectType.ANY` as the target type, then the object will be peeled until the type changes.
    /// A tag will be peeled until the referenced object is no longer a tag, and a commit will be peeled to a tree.
    /// Any other object type will return `error.InvalidSpec`.
    ///
    /// If peeling a tag we discover an object which cannot be peeled to the target type due to the object model, `error.Peel`
    /// will be returned.
    ///
    /// You must `deinit` the returned object.
    ///
    /// ## Parameters
    /// * `target_type` - The type of the requested object
    pub fn peel(self: *const Object, target_type: ObjectType) !*git.Object {
        log.debug("Object.peel called, target_type={}", .{target_type});

        var ret: *Object = undefined;

        try internal.wrapCall("git_object_peel", .{
            @ptrCast(*?*c.git_object, &ret),
            @ptrCast(*const c.git_object, self),
            @enumToInt(target_type),
        });

        log.debug("successfully found object: {*}", .{ret});

        return ret;
    }

    /// Create an in-memory copy of a Git object. The copy must be explicitly `deinit`'d or it will leak.
    pub fn duplicate(self: *Object) *Object {
        log.debug("Object.duplicate called", .{});

        var ret: *Object = undefined;

        _ = c.git_object_dup(
            @ptrCast(*?*c.git_object, &ret),
            @ptrCast(*c.git_object, self),
        );

        log.debug("successfully duplicated object", .{});

        return ret;
    }

    comptime {
        std.testing.refAllDecls(@This());
    }
};

/// Basic type (loose or packed) of any Git object.
pub const ObjectType = enum(c_int) {
    /// Object can be any of the following
    ANY = -2,
    /// Object is invalid.
    INVALID = -1,
    /// A commit object.
    COMMIT = 1,
    /// A tree (directory listing) object.
    TREE = 2,
    /// A file revision object.
    BLOB = 3,
    /// An annotated tag object.
    TAG = 4,
    /// A delta, base is given by an offset.
    OFS_DELTA = 6,
    /// A delta, base is given by object id.
    REF_DELTA = 7,

    /// Convert an object type to its string representation.
    pub fn toString(self: ObjectType) [:0]const u8 {
        return std.mem.sliceTo(
            c.git_object_type2string(@enumToInt(self)),
            0,
        );
    }

    /// Convert a string object type representation to it's `ObjectType`.
    ///
    /// If the given string is not a valid object type `.INVALID` is returned.
    pub fn fromString(str: [:0]const u8) ObjectType {
        return @intToEnum(ObjectType, c.git_object_string2type(str.ptr));
    }

    /// Determine if the given `ObjectType` is a valid loose object type.
    pub fn validLoose(self: ObjectType) bool {
        return c.git_object_typeisloose(@enumToInt(self)) != 0;
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
