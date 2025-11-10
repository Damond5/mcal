# Change: Fix Git Pull Working Directory Update

## Why
When users create local events and then perform a sync pull, the operation reports success but doesn't actually update the app with remote changes. This happens because Git pull updates the repository state but doesn't overwrite locally modified files that haven't been committed, leaving outdated event data in the working directory.

## What Changes
- Modify the Git pull implementation in Rust to properly handle local uncommitted changes
- Add stashing of local changes before pull and restoration after pull
- Ensure working directory is correctly updated even when local changes exist
- Add conflict resolution for stash pop operations

## Impact
- Affected specs: git-sync
- Affected code: native/src/api.rs (git_pull_impl function)
- No breaking changes to public APIs</content>
<parameter name="filePath">openspec/changes/fix-git-pull-working-directory-update/proposal.md