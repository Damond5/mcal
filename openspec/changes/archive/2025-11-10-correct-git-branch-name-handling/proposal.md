# Change: Correct Git Branch Name Handling

## Why
During sync operations, the application fails with "reference 'refs/heads/master' not found" because the code inconsistently handles branch names. When determining the branch for pull/push, if no local HEAD exists, it uses the remote's default branch name (e.g., "refs/heads/main") without stripping the "refs/heads/" prefix, leading to incorrect ref construction and errors. This prevents sync from working on repos using "main" as the default branch.

## What Changes
- Modify git_pull_impl and git_push_impl in native/src/api.rs to strip "refs/heads/" from remote.default_branch() output, ensuring branch_name is always the short name (e.g., "main"). If the prefix is not present, use the full ref string.
- This aligns with how local HEAD branch names are handled (native/src/api.rs:local_head_logic).

## Impact
- Affected specs: git-sync (Branch Handling requirement)
- Affected code: native/src/api.rs (git_pull_impl and git_push_impl functions)
- No breaking changes to public APIs
- Fixes sync errors for repos with "main" as default branch, improves reliability for modern Git setups.</content>
<parameter name="filePath">openspec/changes/correct-git-branch-name-handling/proposal.md