# Proposal: Fix Linux Integration Testing

## Why
Integration tests on Linux and macOS desktop platforms are failing with error `Error waiting for a debug connection: The log reader stopped unexpectedly, or never started.` This is a known Flutter bug (#101031) that prevents running multiple integration test files sequentially on desktop platforms, leaving integration test suite broken and unable to verify end-to-end functionality.

## What Changes
Create test runner scripts that execute each integration test file individually on Linux and Android platforms, working around the Flutter desktop bug by ensuring clean app starts for each test file. Update build system and documentation to support the new test runner approach.

### Current Issues
Integration tests on Linux desktop are failing due to a **Flutter framework bug**:

1. **First test runs successfully**: `accessibility_integration_test.dart` passes all 11 tests
2. **Subsequent tests fail**: All other 14 integration test files fail with `Error waiting for a debug connection: The log reader stopped unexpectedly, or never started.`
3. **Platform-specific issue**: Only affects Linux/macOS desktop; mobile platforms (Android/iOS) work fine but have performance issues
4. **Known Flutter bug**: GitHub Issue #101031, open since March 2022, P2 priority
5. **No official fix**: Flutter team has not resolved the issue despite multiple years of reports

This represents a **critical testing infrastructure gap**:
- Integration test suite cannot run successfully on Linux development environment
- Developers cannot verify end-to-end workflows on desktop
- CI/CD pipelines cannot execute integration tests on Linux
- 14 of 15 integration test files provide no confidence (all fail)
- Android tests work but are extremely slow (20+ minutes due to APK rebuilds)

### Root Cause
Flutter's integration test framework has a bug where it fails to properly launch subsequent test app instances after the first test completes on desktop platforms. The log reader component fails to reconnect, causing the "Unable to start the app on the device" error.

## Proposed Solution
Implement **individual test runner scripts** that execute each integration test file in isolation, which works around the Flutter desktop bug by ensuring clean app lifecycle management for each test.

### Solution Components

1. **Linux Test Runner Script** (`scripts/test-integration-linux.sh`)
   - Detect all integration test files in `integration_test/` directory
   - Execute each test file individually using `fvm flutter test integration_test/<file>.dart -d linux`
   - Track pass/fail status for each test file
   - Generate comprehensive summary report with test counts
   - Return appropriate exit code (0 for all pass, 1 for any fail)

2. **Android Test Runner Script** (`scripts/test-integration-android.sh`)
   - Check for connected Android device
   - Execute each test file individually using `fvm flutter test integration_test/<file>.dart -d <device>`
   - Track pass/fail status for each test file
   - Generate comprehensive summary report with test counts
   - Return appropriate exit code (0 for all pass, 1 for any fail)
   - Consider caching APK builds between test files to improve performance

3. **Makefile Updates**
   - Add `test-integration-linux` target calling Linux test runner script
   - Add `test-integration-android` target calling Android test runner script
   - Add `test-integration-all` target to run both platforms sequentially
   - Ensure scripts are executable and have proper environment setup

4. **Documentation Updates**
   - Create comprehensive fix plan document (`INTEGRATION_TEST_FIX_PLAN.md`)
   - Update README.md with Testing section explaining:
     - Flutter desktop bug reference (#101031)
     - How to run integration tests using scripts
     - Why individual execution is required
   - Document script usage examples and expected outputs

## Documentation Updates
- **INTEGRATION_TEST_FIX_PLAN.md**: Comprehensive analysis and implementation plan (already created)
- **README.md**: Add Testing section with script usage instructions
- **TODO.md**: Mark integration testing issue as addressed (if exists)

## Scope
This change is focused on test infrastructure and build system:

- **In scope**:
  - Creating `scripts/test-integration-linux.sh` script
  - Creating `scripts/test-integration-android.sh` script
  - Updating `Makefile` with new test runner targets
  - Documenting the Flutter desktop bug and workaround
  - Creating test summary reporting functionality
  - Adding proper error handling and exit codes
  - Supporting all 15 integration test files

- **Out of scope**:
  - Modifying any integration test code (tests themselves)
  - Fixing the Flutter desktop bug itself (upstream issue)
  - Changing test structure or organization
  - Adding new integration tests
  - Modifying Flutter configuration files
  - Performance optimization beyond basic caching

## Acceptance Criteria
- **Linux Integration Tests**: All 15 integration test files execute without Flutter framework errors via `scripts/test-integration-linux.sh`
- **Android Integration Tests**: All 15 integration test files execute without Flutter framework errors via `scripts/test-integration-android.sh`
- **Performance Standards**:
  - Linux: All 15 test files complete in < 5 minutes total
  - Android: All 15 test files complete in < 10 minutes total (if APK caching works), < 20 minutes without caching
  - Individual test files average < 30 seconds each
- **Test Summary Reports**: Scripts generate clear summary showing:
  - Number of tests passed
  - Number of tests failed
  - Total execution time
  - Per-file breakdown with individual durations
  - Clear distinction between framework errors (log reader stopped) vs test failures (assertion failures)
- **Exit Codes**: Scripts return correct exit codes (0 = all pass, 1 = any fail)
- **Error Handling**:
  - Missing Flutter: Clear error message with exit code 1
  - No Android device: Clear error message with exit code 1
  - Test failures: Continue running, report all failures, exit code 1
  - Framework errors: Report Flutter Issue #101031 reference with next steps
- **Makefile Targets**: All new Makefile targets work correctly:
  - `make test-integration-linux` runs Linux tests
  - `make test-integration-android` runs Android tests
  - `make test-integration-all` runs both platforms
- **No Regressions**: All existing unit tests still pass (81/81)
- **Documentation**:
  - README.md explains approach and references Flutter bug #101031
  - README.md clarifies that scripts enable execution (not fixing existing test failures)
  - README.md Testing section is updated with script usage examples
  - `docs/platforms/linux-workflow.md` is updated with integration testing instructions
- **Automation**: Scripts automatically detect integration test files (no manual configuration)

## Impact
- **Testing**: Enables full integration test suite execution on Linux and Android platforms
- **Risk**: Low - test infrastructure only, no production code modifications
- **Dependencies**: None - uses existing Flutter test commands
- **Performance**: Acceptable - individual execution trades off some speed for working tests; Android may see improvement with APK caching
- **Maintainability**: Improves test reliability and provides clear automation

## Alternatives Considered

1. **Option 1: Consolidate integration tests into single file**
   - **Rejected**: Loss of test organization and maintainability; still may hit timeouts; not recommended for long-term

2. **Option 2: Use flutter drive command instead of flutter test**
   - **Rejected**: Still affected by same bug; requires additional test driver setup; more complex configuration

3. **Option 3: Run integration tests on different platform (e.g., Android only)**
   - **Rejected**: Loses Linux-specific testing; requires physical device/emulator always available; not a complete solution

4. **Option 4: Wait for Flutter team to fix bug (#101031)**
   - **Rejected**: Bug has been open since March 2022 (nearly 4 years) with no fix in sight; testing gap needs to be addressed now

5. **Option 5: Manually run each test file**
   - **Rejected**: Not scalable; not automatable; error-prone; defeats purpose of automated testing

**Decision**: Primary solution (individual test runner scripts) is best approach because:
- Works around Flutter bug without modifying tests
- Maintains existing test organization
- Fully automatable and repeatable
- Provides clear error reporting
- Can be integrated into CI/CD pipelines
- Minimal maintenance burden

## Notes
- Flutter Issue #101031: https://github.com/flutter/flutter/issues/101031
- First integration test file (accessibility_integration_test.dart) runs successfully on Linux
- All 14 subsequent test files fail with log reader error on Linux
- Unit tests work perfectly (81/81 passing) - issue is specific to integration tests
- Android tests work but are slow due to rebuilding APK for each test file
- Scripts should use `fvm flutter` commands for version consistency
- All 15 integration test files in `integration_test/` directory should be supported
