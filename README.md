# zig-libgit2
Zig bindings to [libgit2](https://github.com/libgit2/libgit2)

This is an in-progress zig binding to libgit2, unfortunately libgit2 doesn't full document all possible errors so every errorable function returns the full errorset.

As Github Actions uses Ubuntu LTS (20.04) as `ubuntu-latest` which has a version of libgit2 before 1.0 we need to handle an API breaking change of renamed functions this is the use case of the `Dold_version` option.
