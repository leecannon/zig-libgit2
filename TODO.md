# Plans

- [ ] Implement entire API from commit `3f02b5b95e90d6be25aedf3f861e173182e815d7`
- [ ] Replace any `const slice = try id.formatHex(&buf);` type Oid formating with no try version
- [ ] Any `extern struct` passed as `*const` should be passed by value 
- [ ] Update with all API changes up to latest master
- [ ] Build against each version from latest to oldest and mark added APIs using `@hasDecl`
- [ ] Option to disable logging
- [ ] Add documentation to *every* function and type
- [ ] Check all functions that dont take a "self" pointer to a libgit2 type and decide if they should be moved to `Handle`
- [ ] Add functionality to build.zig to include package as either static or dynamic
- [ ] Package with zigmod/gyro

15 sys/cred.h
21 sys/reflog.h
38 sys/openssl.h
45 sys/commit_graph.h
49 sys/refs.h
64 sys/path.h
80 sys/commit.h
87 sys/mempack.h
90 sys/credential.h
91 revert.h
94 sys/diff.h
98 proxy.h
101 sys/alloc.h
103 signature.h
106 sys/hashsig.h
111 reset.h
121 transaction.h
130 sys/config.h
135 odb_backend.h
138 sys/stream.h
168 sys/odb_backend.h
180 sys/repository.h
182 sys/index.h
182 sys/merge.h
260 stash.h
282 patch.h
299 revwalk.h
332 sys/filter.h
361 sys/refdb_backend.h
367 rebase.h
382 tag.h
440 sys/transport.h
559 odb.h
606 merge.h
663 submodule.h
771 refs.h
1525 diff.h
