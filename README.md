# zig-libgit2

Zig bindings to [libgit2](https://github.com/libgit2/libgit2)

This is an in-progress zig binding to libgit2, unfortunately libgit2 doesn't full document all possible errors so every errorable function returns the full errorset.

## Files fully wrapped (others maybe partially complete)

- [x] annotated_commit.h
- [x] apply.h
- [x] attr.h
- [x] blame.h
- [x] blob.h
- [x] branch.h
- [x] buffer.h
- [ ] cert.h
- [x] checkout.h
- [x] cherrypick.h
- [ ] clone.h
- [ ] commit.h
- [x] common.h
- [ ] config.h
- [ ] cred_helpers.h
- [ ] credential_helpers.h
- [ ] credential.h
- [ ] describe.h
- [ ] diff.h
- [x] errors.h
- [ ] filter.h
- [ ] global.h
- [ ] graph.h
- [ ] ignore.h
- [x] index.h
- [ ] indexer.h
- [ ] mailmap.h
- [ ] merge.h
- [ ] message.h
- [ ] net.h
- [ ] notes.h
- [ ] object.h
- [ ] odb_backend.h
- [ ] odb.h
- [x] oid.h
- [ ] oidarray.h
- [ ] pack.h
- [ ] patch.h
- [ ] pathspec.h
- [ ] proxy.h
- [ ] rebase.h
- [ ] refdb.h
- [ ] reflog.h
- [ ] refs.h
- [ ] refspec.h
- [ ] remote.h
- [x] repository.h
- [ ] reset.h
- [ ] revert.h
- [ ] revparse.h
- [ ] revwalk.h
- [ ] signature.h
- [ ] stash.h
- [x] status.h
- [x] strarray.h
- [ ] submodule.h
- [ ] tag.h
- [ ] trace.h
- [ ] transaction.h
- [ ] transport.h
- [ ] tree.h
- [ ] types.h
- [ ] version.h
- [ ] worktree.h
