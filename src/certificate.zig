const std = @import("std");
const c = @import("internal/c.zig");
const git = @import("git.zig");

pub const Certificate = extern struct {
    /// Type of certificate
    cert_type: CertificateType,

    pub const CertificateType = enum(c_uint) {
        ///  No information about the certificate is available. This may happen when using curl.
        NONE = 0,
        ///  The `data` argument to the callback will be a pointer to the DER-encoded data.
        X509,
        // TODO: Update doc comments when `git_cert_hostkey` is implemented
        ///  The `data` argument to the callback will be a pointer to a `git_cert_hostkey` structure.
        HOSTKEY_LIBSSH2,
        ///  The `data` argument to the callback will be a pointer to a `git.StrArray` with `name:content` strings containing
        ///  information about the certificate. This is used when using  curl.
        STRARRAY,
    };

    comptime {
        std.testing.refAllDecls(@This());
    }
};

comptime {
    std.testing.refAllDecls(@This());
}
