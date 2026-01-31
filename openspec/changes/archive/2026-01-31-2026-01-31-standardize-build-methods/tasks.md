## 1. Documentation Updates

### 1.1 Update README.md Flutter Commands
- [x] 1.1.1 Update line 43: Change `flutter pub get` to `fvm flutter pub get`
- [x] 1.1.2 Update lines 54-63: Add `fvm` prefix to all `flutter run` commands
- [x] 1.1.3 Update line 69: Change `flutter build apk` to `fvm flutter build apk`
- [x] 1.1.4 Update line 74: Change `flutter build ios` to `fvm flutter build ios`
- [x] 1.1.5 Remove lines 78-79: Delete `flutter build web` command entirely from README, keeping only the existing FFI incompatibility warning
- [x] 1.1.6 Update line 85: Change `flutter build linux/mac/windows` to `fvm flutter build linux/mac/windows`
- [x] 1.1.7 Update lines 259-265: Add `fvm` prefix to all `flutter test` commands

### 1.2 Update docs/platforms/linux-workflow.md
- [x] 1.2.1 Remove lines 15-78: Delete all references to integration test runner scripts (scripts/test-integration-linux.sh)
- [x] 1.2.2 Add section: "Use `fvm flutter test` for running tests on Linux"
- [x] 1.2.3 Add FVM requirement note to setup section if not present

### 1.3 Update docs/platforms/README.md
- [x] 1.3.1 Update Android workflow status to "Available"
- [x] 1.3.2 Update iOS workflow status to "Coming soon" (or current status)
- [x] 1.3.3 Update Linux workflow status to "Available"
- [x] 1.3.4 Update macOS workflow status to "Coming soon" (or current status)
- [x] 1.3.5 Update Web workflow status to "NOT SUPPORTED"
- [x] 1.3.6 Update Windows workflow status to "Coming soon" (or current status)

### 1.4 Clarify Build Output Locations
- [x] 1.4.1 Add to docs/platforms/android-workflow.md: "Debug APK output: build/app/outputs/flutter-apk/"
- [x] 1.4.2 Add to docs/platforms/android-workflow.md: "Release APK output: android/app/build/outputs/apk/release/"
- [x] 1.4.3 Add note about `--debug` vs `--release` flag affecting output location

### 1.5 Review Documentation Changes
- [x] 1.5.1 Review all documentation updates from sections 1.1-1.4 using @code-review subagent
- [x] 1.5.2 Implement all suggested changes from code review
- [x] 1.5.3 Re-verify documentation updates with @code-review if changes were made

## 2. Deprecation Handling

### 2.1 Deprecate scripts/build-android.sh
- [x] 2.1.1 Add deprecation warning comment at top of file:
  ```bash
  # DEPRECATED: This script is deprecated in favor of Makefile automation.
  # Use `make android-build` instead.
  # This script will be removed in a future version.
  ```
- [x] 2.1.2 Keep script functional (do not break existing workflows)
- [x] 2.1.3 Add reference to Makefile targets in comment

## 3. OpenSpec Updates

### 3.1 Add Build Method Requirements
- [x] 3.1.1 Verify spec delta file exists at openspec/changes/2026-01-31-standardize-build-methods/specs/build-deployment/spec.md
- [x] 3.1.2 Add "ADDED Requirements" header
- [x] 3.1.3 Add requirement: "The application SHALL use fvm prefix for all Flutter commands"
  - Add scenario: "Running Flutter commands with fvm"
  - Add scenario: "Verifying Flutter version with fvm"
- [x] 3.1.4 Add requirement: "The application SHALL support platform-specific build methods"
  - Add scenario: "Building Android APK"
  - Add scenario: "Building Linux executable"
- [x] 3.1.5 Add requirement: "The application SHALL document web builds as not supported"
  - Add scenario: "User attempts web build"
- [x] 3.1.6 Add requirement: "The application SHALL use Makefile as primary build automation"
  - Add scenario: "Using Makefile for Android builds"
- [x] 3.1.7 Add requirement: "The application SHALL maintain accurate build documentation"
  - Add scenario: "Documentation reflects current build state"
- [x] 3.1.8 Ensure all scenarios use proper `#### Scenario:` format with `**WHEN**` and `**THEN**` keywords

### 3.2 Review OpenSpec Updates
- [x] 3.2.1 Review new requirements and scenarios in spec delta using @code-review subagent
- [x] 3.2.2 Implement all suggested changes from code review
- [x] 3.2.3 Re-verify OpenSpec updates with @code-review if changes were made

## 4. Validation

### 4.1 Validate Documentation Updates
- [x] 4.1.1 Run grep for all occurrences of `^flutter ` (without fvm prefix) to verify consistency
- [x] 4.1.2 Run grep for `test-integration-linux.sh` to verify all references removed
- [x] 4.1.3 Review README.md to verify web build section is clear
- [x] 4.1.4 Verify all Flutter commands in documentation use `fvm flutter` prefix

### 4.2 Validate OpenSpec Changes
- [x] 4.2.1 Run `openspec validate 2026-01-31-standardize-build-methods --strict`
- [x] 4.2.2 Fix any validation errors reported
- [x] 4.2.3 Verify all requirements have at least one scenario
- [x] 4.2.4 Verify scenario format uses 4 hashtags (`#### Scenario:`)
- [x] 4.2.5 Verify scenarios use proper `**WHEN**` and `**THEN**` formatting

### 4.3 Validate Build Methods
- [x] 4.3.1 Test `fvm flutter run` command works
- [x] 4.3.2 Test `fvm flutter build apk` command works
- [x] 4.3.3 Test `fvm flutter build linux` command works (if Linux available)
- [x] 4.3.4 Test `make android-build` target works
- [x] 4.3.5 Verify scripts/build-android.sh still works with deprecation warning

### 4.4 Final Review
- [x] 4.4.1 Verify all files in Affected Code/Documentation section of proposal.md are updated
- [x] 4.4.2 Verify no dead references to deleted scripts remain
- [x] 4.4.3 Verify deprecation warning is visible in scripts/build-android.sh
- [x] 4.4.4 Verify build-deployment spec includes new requirements
- [x] 4.4.5 Verify all changes align with goals in design.md
