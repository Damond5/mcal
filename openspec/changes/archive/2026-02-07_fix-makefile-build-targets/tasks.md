# Tasks Artifact: fix-makefile-build-targets

## Implementation Checklist

### Error Handling Framework Implementation

- [ ] **EH-001**: Add `set -e` and trap statements for critical targets
  - Implement error trap function with line number context
  - Add trap to android-libs, android-build, android-release, native-build targets
  - Test error trapping works correctly on failure

- [ ] **EH-002**: Create standard error message format
  - Define `error_msg` make function with ERROR category, message, suggestion, and reference
  - Apply consistent format across all targets
  - Document error message standards

- [ ] **EH-003**: Implement shell command error handling for all build targets
  - Wrap cargo and flutter commands with proper error handling
  - Add actionable error messages for common failures
  - Ensure exit codes propagate correctly

### Verification Helper Functions Implementation

- [ ] **VH-001**: Create `check_dep` helper function for dependency verification
  - Define function signature: check_dep(TOOL_NAME, INSTALL_INSTRUCTION)
  - Implement command existence check
  - Add to android-libs, generate, and build targets

- [ ] **VH-002**: Implement fvm verification target
  - Create `verify-fvm-installed` target
  - Check fvm command availability
  - Verify .fvm/flutter_sdk directory exists
  - Provide clear installation instructions on failure

- [ ] **VH-003**: Create output path verification helper
  - Define ANDROID_DEBUG_APK, ANDROID_RELEASE_APK, LINUX_BUILD_DIR constants
  - Implement `verify-output` function
  - Add verification step to all build targets

### Android Library Build Improvements

- [ ] **AL-001**: Improve android-libs target error handling
  - Remove error suppression (2>/dev/null)
  - Add explicit error messages for each architecture build failure
  - Implement proper error trap for cargo ndk commands

- [ ] **AL-002**: Enhance architecture build loop with progress indicators
  - Add "Building for $$target..." message before each build
  - Show success/failure status after each architecture
  - Display overall completion message

- [ ] **AL-003**: Verify library copying with error handling
  - Add verification for each architecture library copy
  - Show clear error if source file not found
  - Confirm successful copy with file location message

### Android Run Target Improvements

- [ ] **AR-001**: Implement robust device detection
  - Add device discovery using `fvm flutter devices --machine`
  - Extract device ID from JSON output
  - Handle case when no device is found

- [ ] **AR-002**: Add clear error messages for device issues
  - Message for no device connected
  - Message for device not authorized
  - Suggestions for emulator startup

- [ ] **AR-003**: Pass device ID correctly to flutter run
  - Use extracted device ID in run command
  - Verify device ID format before execution

### Generate Target Fixes

- [ ] **GF-001**: Add fvm flutter prefix to generate target
  - Change `flutter` to `fvm flutter` in generate command
  - Verify fvm is installed before execution
  - Add error handling for generation failures

- [ ] **GF-002**: Add verification that generated code compiles
  - Run flutter analyze on generated code
  - Report any compilation issues
  - Provide guidance on regeneration if needed

### Help Target Enhancements

- [ ] **HE-001**: Reorganize help with logical categories
  - Quick Start section (deps, generate, linux-run)
  - Common Tasks section (analyze, test, format)
  - Platform-specific sections (Linux, Android, Rust)
  - Utilities section (clean, lint, verify-deps, devices)

- [ ] **HE-002**: Add usage examples for key targets
  - Example for `make android-build`
  - Example for `make linux-run`
  - Example for `make install-apk`

- [ ] **HE-003**: Add troubleshooting section
  - Common error messages and solutions
  - Reference to verify-deps target
  - Link to platform-specific setup documentation

- [ ] **HE-004**: Update help for platform-specific targets
  - Mark targets with platform indicators
  - Show prerequisite targets where applicable

### Success Feedback Improvements

- [ ] **SF-001**: Add success confirmation messages to all build targets
  - Android debug build: Show APK location and size
  - Android release build: Show release APK location
  - Linux build: Show binary location
  - Native build: Show library location

- [ ] **SF-002**: Add progress indicators for long-running operations
  - Show "Building..." before each build phase
  - Show "Verifying..." before verification steps
  - Display elapsed time for significant operations

- [ ] **SF-003**: Implement consistent success message format
  - "SUCCESS: [operation] completed"
  - "Output: [location]"
  - "Size: [file size]" where applicable

### Verify-Sync Improvements

- [ ] **VS-001**: Improve error handling for file existence checks
  - Add explicit file not found messages
  - Show expected file location
  - Suggest corrective actions

- [ ] **VS-002**: Add verification for sync files
  - Check .proto files exist before generation
  - Verify Rust bridge files are up to date
  - Report sync status clearly

- [ ] **VS-003**: Enhance sync verification output
  - Show which files are in sync
  - Highlight files that need regeneration
  - Provide commands to fix sync issues

### Output Verification Steps

- [ ] **OV-001**: Add post-build verification for Android
  - Verify debug APK exists after android-build
  - Verify release APK exists after android-release
  - Show file size and location in success message

- [ ] **OV-002**: Add post-build verification for Linux
  - Verify binary exists after linux-build
  - Check binary is executable
  - Report binary location

- [ ] **OV-003**: Add post-build verification for native libraries
  - Verify .so files exist after android-libs
  - Check native library exists after native-build
  - Report library locations

### Testing and Validation Tasks

- [ ] **TV-001**: Test all Linux targets manually
  - Execute `make linux-run` and verify app starts
  - Execute `make linux-build` and verify output
  - Execute `make linux-test` and verify tests pass
  - Execute `make linux-analyze` and verify no errors
  - Execute `make linux-clean` and verify cleanup

- [ ] **TV-002**: Test all Android targets manually
  - Execute `make android-libs` and verify all architectures build
  - Execute `make android-build` and verify debug APK
  - Execute `make android-release` and verify release APK
  - Execute `make install-apk` on connected device
  - Test `make android-run` with device connected

- [ ] **TV-003**: Test error handling scenarios
  - Run target without fvm installed
  - Run android-run without device connected
  - Run build targets with missing dependencies
  - Verify error messages are clear and actionable

- [ ] **TV-004**: Test cross-platform consistency
  - Verify fvm is used consistently across all targets
  - Verify output paths are consistent
  - Verify help displays correctly
  - Verify error messages follow standard format

- [ ] **TV-005**: Test verification and sync targets
  - Execute `make verify-deps` and verify all dependencies
  - Execute `make verify-sync` and verify status
  - Execute `make generate` and verify regeneration

- [ ] **TV-006**: Validate exit code behavior
  - Verify zero exit code on success
  - Verify non-zero exit code on failure
  - Verify error messages include context
  - Verify CI/CD can detect success/failure

- [ ] **TV-007**: Run Flutter analyzer
  - Execute `make analyze` and `make linux-analyze`
  - Verify no analyzer errors
  - Fix any warnings if present

- [ ] **TV-008**: Run test suite
  - Execute `make test` and `make android-test`
  - Verify all tests pass
  - Report test results summary

- [ ] **TV-009**: Test help target comprehensively
  - Execute `make help` and verify all targets listed
  - Verify category organization is correct
  - Verify examples are accurate
  - Verify troubleshooting section is present

- [ ] **TV-010**: Document test results
  - Create test report documenting all test scenarios
  - Note any issues found and resolutions
  - Update this tasks file with test status

## Task Summary

| Category | Task Count | Status |
|----------|------------|--------|
| Error Handling Framework | 3 | Pending |
| Verification Helpers | 3 | Pending |
| Android Library Build | 3 | Pending |
| Android Run Target | 3 | Pending |
| Generate Target | 2 | Pending |
| Help Target | 4 | Pending |
| Success Feedback | 3 | Pending |
| Verify-Sync | 3 | Pending |
| Output Verification | 3 | Pending |
| Testing/Validation | 10 | Pending |
| **Total** | **37** | **Pending** |

## Implementation Order

1. **Phase 1: Foundation**
   - Error Handling Framework (EH-001, EH-002, EH-003)
   - Verification Helper Functions (VH-001, VH-002, VH-003)

2. **Phase 2: Core Targets**
   - Android Library Build Improvements (AL-001, AL-002, AL-003)
   - Android Run Target Improvements (AR-001, AR-002, AR-003)

3. **Phase 3: Target Fixes**
   - Generate Target Fixes (GF-001, GF-002)
   - Help Target Enhancements (HE-001, HE-002, HE-003, HE-004)

4. **Phase 4: Feedback & Verification**
   - Success Feedback Improvements (SF-001, SF-002, SF-003)
   - Verify-Sync Improvements (VS-001, VS-002, VS-003)
   - Output Verification Steps (OV-001, OV-002, OV-003)

5. **Phase 5: Testing**
   - All Testing and Validation tasks (TV-001 through TV-010)

## Dependencies

- All implementation tasks depend on Error Handling Framework completion
- Android targets depend on Verification Helper Functions
- Testing depends on all implementation tasks being complete

## Notes

- Follow the design decisions in design.md for implementation approach
- Use consistent error message format defined in EH-002
- Ensure all Flutter commands use fvm flutter prefix
- Test on Linux before testing on Android devices
- Document any platform-specific behaviors discovered during testing
