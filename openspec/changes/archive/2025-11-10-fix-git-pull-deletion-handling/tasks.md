- [x] In git_pull_impl, before the fetch operation, capture `let old_tree = repo.head()?.peel_to_tree()?;`.
- [x] After successful checkout_head, capture `let new_tree = repo.head()?.peel_to_tree()?;`.
- [x] After stash_pop, compute deleted paths using `git2::Diff::tree_to_tree(&old_tree, &new_tree, None)?.deltas().filter(|d| d.status() == git2::Delta::Deleted).map(|d| d.old_file().path().to_string())`.
- [x] For each deleted path, check if `repo.workdir().join(path)` exists and call `std::fs::remove()`; log errors via error_logger but don't propagate failures.
- [x] Update tests in sync_service_test.dart: Add a unit test mocking git_pull to verify deletions are applied. Use temp repos for integration tests simulating remote deletes with local changes.
- [x] Run manual tests with real Git repos (e.g., delete a file remotely, modify locally, pull) and validate with openspec validate fix-git-pull-deletion-handling --strict.</content>
<parameter name="filePath">openspec/changes/fix-git-pull-deletion-handling/tasks.md