# Change: Fix Git Pull Deletion Handling

## Why
When an event is deleted remotely and MCAL pulls, it reports success but fails to remove the local event if there are uncommitted local changes. This occurs because git_pull_impl stashes local changes, updates the working directory (deleting the file), then pops the stash, recreating the deleted file with local content.

## What Changes
- Modify git_pull_impl in native/src/api.rs to, after popping the stash, identify files deleted remotely and delete them from the working directory.
- Ensure deletions are enforced while preserving local changes to other files.
- This fix assumes deletions are for tracked files (e.g., event .md files). Untracked or ignored files are unaffected.

## Impact
- Affected specs: git-sync
- Affected code: native/src/api.rs (git_pull_impl function)
- No breaking changes to public APIs
- If deletion enforcement fails, log an error but do not fail the pull to maintain usability.</content>
<parameter name="filePath">openspec/changes/fix-git-pull-deletion-handling/proposal.md