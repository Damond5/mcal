## MODIFIED Requirements
### Requirement: The application SHALL Git Operations Support
The application SHALL implement comprehensive Git operations via Rust backend: init, clone, current_branch, list_branches, pull, push, status, add_remote, fetch, checkout, add_all, commit, merge_prefer_remote, merge_abort, stash, diff.

#### Scenario: Pulling with local changes
Given an initialized repository with uncommitted local changes
When pull is executed
Then local changes are temporarily stashed, remote changes are applied including deletions, and local changes are restored for non-deleted files; local changes to deleted files are discarded
And if stash pop fails due to conflicts, deletions remain enforced as remote state is preserved</content>
<parameter name="filePath">openspec/changes/fix-git-pull-deletion-handling/specs/git-sync/spec.md