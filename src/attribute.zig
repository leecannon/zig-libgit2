const std = @import("std");
const c = @import("internal/c.zig");
const internal = @import("internal/internal.zig");
const log = std.log.scoped(.git);

const git = @import("git.zig");

pub const Attribute = struct {
    z_attr: ?[*:0]const u8,

    /// Check if an attribute is set on. In core git parlance, this the value for "Set" attributes.
    ///
    /// For example, if the attribute file contains:
    ///    *.c foo
    ///
    /// Then for file `xyz.c` looking up attribute "foo" gives a value for which this is true.
    pub fn isTrue(self: Attribute) bool {
        return self.getValue() == .@"true";
    }

    /// Checks if an attribute is set off. In core git parlance, this is the value for attributes that are "Unset" (not to be
    /// confused with values that a "Unspecified").
    ///
    /// For example, if the attribute file contains:
    ///    *.h -foo
    ///
    /// Then for file `zyx.h` looking up attribute "foo" gives a value for which this is true.
    pub fn isFalse(self: Attribute) bool {
        return self.getValue() == .@"false";
    }

    /// Checks if an attribute is unspecified. This may be due to the attribute not being mentioned at all or because the
    /// attribute was explicitly set unspecified via the `!` operator.
    ///
    /// For example, if the attribute file contains:
    ///    *.c foo
    ///    *.h -foo
    ///    onefile.c !foo
    ///
    /// Then for `onefile.c` looking up attribute "foo" yields a value with of true. Also, looking up "foo" on file `onefile.rb`
    /// or looking up "bar" on any file will all give a value of true.
    pub fn isUnspecified(self: Attribute) bool {
        return self.getValue() == .unspecified;
    }

    /// Checks if an attribute is set to a value (as opposed to @"true", @"false" or unspecified). This would be the case if for a file
    /// with something like:
    ///    *.txt eol=lf
    ///
    /// Given this, looking up "eol" for `onefile.txt` will give back the string "lf" and will return true.
    pub fn hasValue(self: Attribute) bool {
        return self.getValue() == .string;
    }

    pub fn getValue(self: Attribute) AttributeValue {
        return @intToEnum(AttributeValue, c.git_attr_value(self.z_attr));
    }

    pub const AttributeValue = enum(c_uint) {
        /// The attribute has been left unspecified
        unspecified = 0,
        /// The attribute has been set
        @"true",
        /// The attribute has been unset
        @"false",
        /// This attribute has a value
        string,
    };

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
