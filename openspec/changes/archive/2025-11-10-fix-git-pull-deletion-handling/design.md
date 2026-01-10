# Design: Selective Deletion After Stash Pop

## Overview
The current git_pull_impl stashes local changes, performs a fast-forward pull, then pops the stash. For files deleted remotely, the pop recreates them, overriding the deletion.

To fix, after pop, compare the pre-pull tree to the post-pull tree to identify deletions, then delete any recreated files.

## Trade-offs
- Preserves local changes to non-deleted files.
- Loses local changes to deleted files (consistent with preferring remote).
- Adds complexity to git_pull_impl but keeps it contained.
- Potential for false positives if trees are corrupted, but rare.

## Alternatives Considered
- Reset hard: Loses all local changes.
- Preserve original formatting: Prevents uncommitted changes but complex to implement.

## Implementation
- Capture old tree before fetch: `let old_tree = repo.head()?.peel_to_tree()?;`
- After successful checkout_head, capture new tree: `let new_tree = repo.head()?.peel_to_tree()?;`
- Compute deleted paths: Use `git2::Diff::tree_to_tree(&old_tree, &new_tree, None)?.deltas().filter(|d| d.status() == git2::Delta::Deleted).map(|d| d.old_file().path().to_string())`
- After pop, for each deleted path, use `std::fs::remove(repo.workdir().join(path))` if exists; log errors but don't fail pull.</content>
<parameter name="filePath">openspec/changes/fix-git-pull-deletion-handling/design.md