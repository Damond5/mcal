## Context
The current Git pull implementation uses libgit2's checkout_head with default options, which doesn't overwrite files that have uncommitted local changes. This causes the pull to succeed at the repository level but leave outdated files in the working directory, leading to the app not reflecting remote changes.

## Goals / Non-Goals
- Goals: Ensure pull operations always update the working directory with remote changes, even when local uncommitted changes exist
- Non-Goals: Change the user-facing behavior of when commits are made (still require explicit push)

## Decisions
- Decision: Use Git stash to temporarily save local changes before pull, then restore after
- Alternatives considered: Force checkout (loses local changes), require users to commit before pull (poor UX)
- Decision: On stash pop conflicts, prefer remote changes to ensure sync consistency
- Alternatives considered: Show conflict dialog (complex for background sync), abort pull (leaves user in inconsistent state)

## Risks / Trade-offs
- Risk: Stash pop conflicts could lose local changes → Mitigation: Prefer remote changes for consistency
- Risk: Performance impact of stashing → Mitigation: Only stash when necessary (detect local changes first)
- Trade-off: Complexity vs reliability → Accept complexity for correct sync behavior

## Migration Plan
No migration needed - this fixes broken behavior without changing APIs.

## Open Questions
- How to handle stash pop failures gracefully?
- Should we show a warning when local changes are stashed during pull? (Decision: For now, handle silently to avoid interrupting sync flow, but log for debugging)</content>
<parameter name="filePath">openspec/changes/fix-git-pull-working-directory-update/design.md