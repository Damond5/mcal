# Change: Standardize Build Methods Documentation

## Summary
This change standardizes Flutter command usage across all documentation to consistently use `fvm flutter`, removes misleading web build references, cleans up dead references to non-existent integration test scripts, deprecates a redundant build automation script, and adds formal requirements to the build-deployment specification for consistency.

## Why
The project suffers from inconsistent Flutter command usage (mixing `flutter` and `fvm flutter` throughout README.md), misleading web build documentation that references `flutter build web` despite web being unsupported due to FFI incompatibility with Rust-based Git sync, dead references to deleted integration test runner scripts in linux-workflow.md, redundant automation via `scripts/build-android.sh` when Makefile targets exist, and a lack of formal requirements in the build-deployment spec for build method consistency and output locations.

## What Changes
- Standardize all Flutter commands in README.md to use `fvm flutter` prefix for consistency (lines 43, 54-85)
- Remove misleading `flutter build web` command from README (web not supported due to FFI incompatibility) while keeping the warning note
- Update docs/platforms/linux-workflow.md to remove references to non-existent integration test runner scripts (lines 15-78: test-integration-linux.sh references)
- Deprecate scripts/build-android.sh by adding a deprecation warning comment at the top, directing users to the Makefile `android-build` target
- Add formal build method requirements to build-deployment spec requiring consistent use of version management tools (fvm)
- Clarify debug vs release APK output locations in android-workflow.md documentation
- Update docs/platforms/README.md platform status indicators to reflect accurate availability (Linux shows actual content, not "Coming soon")

## Scope

**Included:**
- Documentation updates for build method consistency (Flutter command standardization)
- Deprecation of redundant build automation script (scripts/build-android.sh)
- Adding formal build method requirements to OpenSpec (build-deployment spec)
- Clarifying build output locations and platform support status
- Removing dead references to non-existent integration test scripts

**Not Included:**
- Removing any actual build functionality or capabilities
- Changes to Makefile targets or behavior (only referencing them in deprecation notices)
- Implementation changes (documentation-only change)

## Affected Specs
- `build-deployment` (adding new requirements for consistent build method usage with version management tools)

## Affected Code/Documentation

**README.md** (lines 43, 54-85, 259-265):
- Line 43: Change `flutter pub get` → `fvm flutter pub get`
- Line 54: Change `flutter run` → `fvm flutter run`
- Line 58: Change `flutter run -d chrome` → `fvm flutter run -d chrome`
- Line 62: Change `flutter run -d linux` → `fvm flutter run -d linux`
- Line 69: Change `flutter build apk` → `fvm flutter build apk`
- Line 74: Change `flutter build ios` → `fvm flutter build ios`
- Lines 78-79: Remove `flutter build web` command entirely (keep warning on line 81)
- Line 85: Change `flutter build linux` → `fvm flutter build linux`
- Lines 254, 259, 264: Change `flutter test` → `fvm flutter test`

**docs/platforms/linux-workflow.md** (lines 15-78):
- Remove entire "Integration Test Runner Scripts" section (lines 15-78) since the referenced script `scripts/test-integration-linux.sh` does not exist
- Keep any other Linux-specific content that remains valid

**docs/platforms/android-workflow.md** (build output locations):
- Add clarification for debug APK output location: `build/app/outputs/flutter-apk/app-debug.apk`
- Add clarification for release APK output location: `build/app/outputs/flutter-apk/app-release.apk`
- Ensure build type (debug vs release) is clearly distinguished in output location documentation

**docs/platforms/README.md** (platform status indicators):
- Update Linux status from "Coming soon" to "Available" to reflect actual documentation content

**scripts/build-android.sh** (add deprecation warning):
- Add comment at top: `# DEPRECATED: Use 'make android-build' instead. This script will be removed in a future version.`

**openspec/specs/build-deployment/spec.md** (add new requirements):
- Add requirement for consistent use of version management tools (fvm) for all Flutter commands
- Add requirement for documenting build output locations by build type (debug vs release)

## Risks
- **Migration risk**: Users may rely on the deprecated `scripts/build-android.sh` script and need a clear migration path to Makefile targets
- **Confusion risk**: Documentation changes may cause temporary confusion if not done thoroughly, particularly around Flutter command prefixes
- **Dead reference removal**: Removing integration test script references from linux-workflow.md may confuse users who were following those instructions, though the script never existed
- **Platform status updates**: Changing Linux status from "Coming soon" to "Available" may be inaccurate if other platforms have similar partial documentation

## Rollback Plan
- Revert all documentation changes if issues arise
- Restore `scripts/build-android.sh` functionality (remove deprecation warning) if users report migration problems
- Restore integration test script references in linux-workflow.md if the scripts are recreated
- Revert platform status indicators if changes cause confusion

## Timeline

**Phase 1: Documentation Updates (Low Risk)**
- Update README.md Flutter commands (15-30 minutes)
- Update docs/platforms/linux-workflow.md remove dead references (10-15 minutes)
- Update docs/platforms/android-workflow.md clarify build output locations (10-15 minutes)
- Update docs/platforms/README.md status indicators (5 minutes)
- Add deprecation warning to scripts/build-android.sh (5 minutes)

**Phase 2: Specification Updates (Moderate Risk)**
- Draft and review new requirements for build-deployment spec (30-45 minutes)
- Validate spec changes with `openspec validate` (10 minutes)

**Phase 3: Review and Validation (Moderate Effort)**
- Comprehensive review of all changes for completeness (30-45 minutes)
- Cross-check all modified sections for internal consistency (15-20 minutes)
- Verify all Flutter command examples use consistent prefix (15-20 minutes)

**Total Estimated Time**: 2-3 hours
