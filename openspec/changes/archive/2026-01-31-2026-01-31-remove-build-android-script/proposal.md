# Change: Remove Deprecated build-android.sh Script

## Summary
Remove the deprecated `scripts/build-android.sh` shell script and update documentation to reference the Makefile automation (`make android-build`) as the sole Android build method.

## Why
The `scripts/build-android.sh` script was deprecated in change 2026-01-31-standardize-build-methods with a warning directing users to use `make android-build` instead. The Makefile provides equivalent functionality with better maintainability and integration. The deprecation period is complete, and the script should now be removed.

## What Changes
- Delete `scripts/build-android.sh` file
- Remove script documentation from docs/platforms/android-workflow.md
- Update build-deployment spec to remove deprecation warning requirement
- Update any other documentation references to point to Makefile

## Scope
**Included:**
- Removing scripts/build-android.sh
- Updating android-workflow.md to remove script documentation
- Updating build-deployment spec to remove script-related requirement
- Ensuring all documentation points to Makefile for Android builds

**Not Included:**
- Changes to Makefile targets (already complete and functional)
- Changes to other build methods or scripts
- Creating new build functionality

## Affected Specs
- build-deployment (removing script deprecation requirement)

## Affected Code/Documentation
- `scripts/build-android.sh` - DELETE
- `docs/platforms/android-workflow.md` - Remove script documentation
- `openspec/specs/build-deployment/spec.md` - Remove deprecation warning requirement

## Risks
- Users still using the script may need to migrate to Makefile
- No breaking functionality - Makefile provides equivalent build process

## Rollback Plan
- Restore scripts/build-android.sh from git history if needed
- Revert documentation changes
- Restore build-deployment spec requirement
