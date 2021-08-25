# zig-libgit2
Zig bindings to [libgit2](https://github.com/libgit2/libgit2)

This is an in-progress zig binding to libgit2, unfortunately libgit2 doesn't full document all possible errors so every errorable function returns the full errorset.

As Github Actions uses Ubuntu LTS (20.04) as `ubuntu-latest` which has a version of libgit2 before 1.0 we need to handle an API breaking change of renamed functions this is the use case of the `-Dold_version` option.

## Progress
- [ ] annotated_commit.h
- [ ] apply.h
- [ ] attr.h
- [ ] blame.h
- [ ] blob.h
- [ ] branch.h
- [ ] buffer.h
- [ ] cert.h
- [ ] checkout.h
- [ ] cherrypick.h
- [ ] clone.h
- [ ] commit.h
- [ ] common.h
- [ ] config.h
- [ ] cred_helpers.h
- [ ] credential_helpers.h
- [ ] credential.h
- [ ] deprecated.h
- [ ] describe.h
- [ ] diff.h
- [ ] errors.h
- [ ] filter.h
- [ ] global.h
- [ ] graph.h
- [ ] ignore.h
- [ ] index.h
- [ ] indexer.h
- [ ] mailmap.h
- [ ] merge.h
- [ ] message.h
- [ ] net.h
- [ ] notes.h
- [ ] object.h
- [ ] odb_backend.h
- [ ] odb.h
- [ ] oid.h
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
- [ ] stdint.h
- [ ] strarray.h
- [ ] submodule.h
- [ ] tag.h
- [ ] trace.h
- [ ] transaction.h
- [ ] transport.h
- [ ] tree.h
- [ ] types.h
- [ ] version.h
- [ ] worktree.h
