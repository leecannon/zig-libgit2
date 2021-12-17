# Plans

Currently working against commit 3f02b5b95e90d6be25aedf3f861e173182e815d7

- [ ] `*const git.StrArray` parameters can be `git.StrArray`
- [ ] `*const git.Oid` parameters can be `git.Oid`
- [ ] Check options (e.g. do defaults match upstream)
- [ ] Use a raw.zig built from each release to make sure version flags are complete
- [ ] Use hasdecl to compile error instead of needing version
- [ ] add documentation to *every* function
- [ ] package with zigmod/gyro
- [ ] Use bitjuggle package
- [ ] language style
- [ ] remove:
    ```zig
    var c_thing: CType = undefined
    try internal.wrapCall("some_func", .{ &c_thing });
    const ret  = internal.toC(c_thing.?);
    ```
    Replace with
    ```zig
    var ret: NonCType = undefined
    try internal.wrapCall("some_func", .{ internal.toC(&ret) });
    ```
- [ ] Make as many pointers const as possible

## Libgit2 Version Timeline

- 1.3.0  2021/09/27 b7bad55
- 1.2.0  2021/09/02 4fd32be
- 1.1.1  2021/06/30 8a0dc67
- 1.1.0  2020/10/13 7f4fa17
- 1.0.1  2020/06/04 0ced296
- 1.0.0  2020/04/01 7d3c705
- 0.99.0 2020/02/19 1722390
