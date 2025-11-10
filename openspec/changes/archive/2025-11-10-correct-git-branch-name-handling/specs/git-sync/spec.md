## MODIFIED Requirements
### Requirement: The application SHALL Branch Handling
The application SHALL support dynamic detection of current and default branches for Git operations, correctly stripping "refs/heads/" prefixes from remote default branches to use short branch names, or using the full ref if the prefix is not present.

#### Scenario: Dynamic branch detection
Given a repository with a default branch (e.g., "refs/heads/main")
When performing Git operations without a local HEAD
Then the remote default branch is detected, prefix is stripped, and the short name ("main") is used for operations

#### Scenario: Handling non-standard refs
Given a repository with default branch "refs/tags/v1.0"
When performing Git operations without a local HEAD
Then the full ref is used if prefix stripping fails</content>
<parameter name="filePath">openspec/changes/correct-git-branch-name-handling/specs/git-sync/spec.md