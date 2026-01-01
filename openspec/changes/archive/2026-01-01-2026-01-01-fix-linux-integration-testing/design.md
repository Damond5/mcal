# Design: Fix Linux Integration Testing

## Architectural Approach

This change implements a **test runner script strategy** to work around Flutter's desktop integration testing bug, enabling reliable execution of the full integration test suite on Linux and Android platforms.

### Why Individual Test Runner Scripts?

The Flutter integration test framework has a bug (GitHub Issue #101031) that prevents running multiple integration test files sequentially on desktop platforms. After the first test file completes successfully, subsequent test files fail to start because the log reader component cannot reconnect to the debug connection.

**Current Behavior**:
```bash
$ fvm flutter test integration_test/ -d linux
✓ accessibility_integration_test.dart: 11/11 tests passed
✗ app_integration_test.dart: Error waiting for a debug connection: The log reader stopped unexpectedly
✗ certificate_integration_test.dart: Error waiting for a debug connection: The log reader stopped unexpectedly
... (12 more failures)
```

**Expected Behavior with Workaround**:
```bash
$ ./scripts/test-integration-linux.sh
✓ accessibility_integration_test.dart: 11/11 tests passed in 8.2s
✓ app_integration_test.dart: 4/4 tests passed in 12.5s
✓ certificate_integration_test.dart: 6/6 tests passed in 15.3s
... (all 15 test files pass)

Summary: 15/15 test files passed, 0 failed
Total time: 245.7s
```

### Desktop Bug Workaround Strategy

The core problem is Flutter's test framework cannot cleanly handle app lifecycle across multiple test file executions on desktop. The workaround isolates each test file execution:

| Aspect | Current Approach | Workaround Approach |
|---------|-----------------|-------------------|
| Test execution | Single command runs all files | Script runs each file individually |
| App lifecycle | Flutter manages multiple app instances | Each test gets fresh app start/shutdown |
| Error handling | Fail-fast on first subsequent file | Track and report all failures |
| Debug connection | Shared across files | Isolated per test file |
| Reporting | Flutter default | Custom summary report |

### Script Architecture

#### Linux Test Runner (`scripts/test-integration-linux.sh`)

**Core Responsibilities**:
1. **Test Discovery**: Auto-detect all `*_integration_test.dart` files in `integration_test/` directory
2. **Individual Execution**: Run each test with `fvm flutter test integration_test/<file>.dart -d linux`
3. **Status Tracking**: Track pass/fail status and execution time per file
4. **Summary Reporting**: Generate comprehensive report with totals
5. **Exit Code Management**: Return 0 if all pass, 1 if any fail

**Pseudo-Algorithm**:
```bash
#!/bin/bash
total_tests=0
passed_tests=0
failed_tests=0
total_time=0

for test_file in integration_test/*_integration_test.dart; do
    total_tests=$((total_tests + 1))
    start_time=$(date +%s)

    echo "Running: $test_file"
    fvm flutter test "$test_file" -d linux

    exit_code=$?
    end_time=$(date +%s)
    duration=$((end_time - start_time))

    if [ $exit_code -eq 0 ]; then
        passed_tests=$((passed_tests + 1))
        echo "✓ PASSED: $test_file (${duration}s)"
    else
        failed_tests=$((failed_tests + 1))
        echo "✗ FAILED: $test_file"
    fi

    total_time=$((total_time + duration))
done

echo ""
echo "Summary: $passed_tests/$total_tests test files passed, $failed_tests failed"
echo "Total time: ${total_time}s"

if [ $failed_tests -gt 0 ]; then
    exit 1
fi
exit 0
```

**Error Handling**:
- Detect connected device before execution
- Handle missing Flutter installation
- Report which specific test files failed
- Continue running remaining tests even if one fails (unless critical error)
- Return proper exit codes for CI/CD integration

**IMPORTANT**: APK caching feasibility must be verified before implementing Android test runner. Flutter's `flutter test` command capabilities for caching are unclear and may not support `--build` flag. Implementation should research Flutter documentation and test behavior first (Task 1).

#### Android Test Runner (`scripts/test-integration-android.sh`)

**Core Responsibilities**:
1. **Device Detection**: Verify Android device is connected and available
2. **APK Build Caching**: Optionally cache APK between test files (performance optimization)
3. **Individual Execution**: Run each test with `fvm flutter test integration_test/<file>.dart -d <device_id>`
4. **Status Tracking**: Track pass/fail status and execution time per file
5. **Summary Reporting**: Generate comprehensive report with totals
6. **Exit Code Management**: Return 0 if all pass, 1 if any fail

**APK Build Caching Strategy**:
- First test file: Build APK (normal ~9-10s)
- Subsequent test files: Reuse APK if Flutter supports caching (saves ~9-10s per file)
- ⚠️ **Feasibility Note**: Flutter's `flutter test` command may not support explicit `--build` flag for APK caching. Implementation must research Flutter documentation and verify actual caching behavior before implementing.
- Trade-off: Adds complexity for performance improvement if caching is supported (~120-140s total for 15 tests); minimal impact if caching not available

**Pseudo-Algorithm**:
```bash
#!/bin/bash
device_id=$(fvm flutter devices | grep -m 1 "android" | awk '{print $2}')

if [ -z "$device_id" ]; then
    echo "Error: No Android device found"
    exit 1
fi

total_tests=0
passed_tests=0
failed_tests=0
total_time=0
apk_built=false

for test_file in integration_test/*_integration_test.dart; do
    total_tests=$((total_tests + 1))
    start_time=$(date +%s)

    echo "Running: $test_file on device $device_id"

    if [ "$apk_built" = false ]; then
        fvm flutter test "$test_file" -d "$device_id" --build  # First build
        apk_built=true
    else
        fvm flutter test "$test_file" -d "$device_id"        # Subsequent: reuse APK
    fi

    exit_code=$?
    end_time=$(date +%s)
    duration=$((end_time - start_time))

    if [ $exit_code -eq 0 ]; then
        passed_tests=$((passed_tests + 1))
        echo "✓ PASSED: $test_file (${duration}s)"
    else
        failed_tests=$((failed_tests + 1))
        echo "✗ FAILED: $test_file"
    fi

    total_time=$((total_time + duration))
done

echo ""
echo "Summary: $passed_tests/$total_tests test files passed, $failed_tests failed"
echo "Total time: ${total_time}s"

if [ $failed_tests -gt 0 ]; then
    exit 1
fi
exit 0
```

**Error Handling**:
- Verify Android device is available before execution
- Handle device disconnection during tests
- Report which specific test files failed
- Provide clear error messages for missing requirements
- Continue running remaining tests even if one fails

### Makefile Integration

Add new targets to Makefile for convenient test execution:

```makefile
.PHONY: test-integration-linux test-integration-android test-integration-all

test-integration-linux:
	@echo "Running integration tests on Linux..."
	./scripts/test-integration-linux.sh

test-integration-android:
	@echo "Running integration tests on Android..."
	./scripts/test-integration-android.sh

test-integration-all: test-integration-linux test-integration-android
	@echo "Running integration tests on all platforms..."
	@echo "Note: This will run tests on both Linux and Android sequentially"
```

### Test File Discovery

Both scripts should automatically detect integration test files:

**Current Integration Test Files** (15 total):
1. `accessibility_integration_test.dart`
2. `app_integration_test.dart`
3. `calendar_integration_test.dart`
4. `certificate_integration_test.dart`
5. `conflict_resolution_integration_test.dart`
6. `edge_cases_integration_test.dart`
7. `event_crud_integration_test.dart`
8. `event_form_integration_test.dart`
9. `event_list_integration_test.dart`
10. `gesture_integration_test.dart`
11. `lifecycle_integration_test.dart`
12. `notification_integration_test.dart`
13. `performance_integration_test.dart`
14. `responsive_layout_integration_test.dart`
15. `sync_integration_test.dart`
16. `sync_settings_integration_test.dart`

**Discovery Strategy**:
```bash
# Find all files matching pattern
find integration_test/ -name "*_integration_test.dart" | sort

# Result: Alphabetically sorted list of all integration test files
```

## Integration Points

### Flutter Test Framework Integration

**Current Command** (broken on desktop):
```bash
fvm flutter test integration_test/ -d linux
# Fails after first test file on desktop
```

**Workaround Command** (works on all platforms):
```bash
./scripts/test-integration-linux.sh
# Runs each test individually, works around Flutter bug
```

**Key Difference**:
- Individual file execution vs. directory execution
- Manual lifecycle management vs. Flutter framework management
- Custom summary reporting vs. Flutter default output
- Isolated debug connections per test file

### CI/CD Integration

Scripts are designed to be easily integrated into CI/CD pipelines:

**GitHub Actions Example**:
```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: subosito/flutter-action@v2
      - run: flutter test
      - run: ./scripts/test-integration-linux.sh

  test-android:
    runs-on: macos-latest
    steps:
      - uses: subosito/flutter-action@v2
        with:
          device: android-emulator
      - run: ./scripts/test-integration-android.sh
```

**Exit Code Handling**:
- CI/CD systems use exit code to determine pass/fail
- Scripts return 0 for success, 1 for any failure
- Standard practice for Unix/Linux automation

## Trade-offs and Decisions

### Why Scripts Over Framework Fix?

**Decision**: Implement workaround scripts instead of trying to fix Flutter framework

**Rationale**:
- Flutter bug has been open for nearly 4 years without resolution
- Fixing Flutter framework is outside project scope
- Workaround is minimal, maintainable, and fully under our control
- Enables immediate testing capability while monitoring upstream issue
- Can be easily removed if Flutter team fixes the bug

### Why Individual Execution Over Consolidation?

**Decision**: Keep separate test files with individual execution

**Rationale**:
- Maintains existing test organization and modularity
- Each test file can run independently (useful for debugging)
- No code reorganization required
- Clear separation of concerns (accessibility, calendar, sync, etc.)
- Easier to understand which specific functionality is failing
- Allows selective test execution during development

### Why Add APK Caching to Android Runner?

**Decision**: Implement APK build caching for Android test runner (optional feature)

**Rationale**:
- Android APK rebuild takes ~9-10 seconds per test file
- 15 test files × 10 seconds = 150 seconds overhead
- Significant time savings for frequent test runs
- Caching adds minimal complexity
- Can be skipped with flag if needed (fresh builds)

### Why Not Fix Flutter Bug Directly?

**Decision**: Do not attempt to fix Flutter desktop integration testing issue

**Rationale**:
- Bug is in Flutter test framework codebase, not MCAL codebase
- Would require forking Flutter SDK and maintaining custom version
- Unreasonable maintenance burden for a single project
- Upstream issue tracking exists (#101031)
- Better to use workaround and contribute to Flutter if needed

## Testing Coverage Goals

### Execution Platforms

| Platform | Test Files | Unit Tests | Integration Tests | Approach |
|-----------|-------------|--------------|-------------------|------------|
| Linux | 15 files | ✅ 81/81 passing | Individual runner script |
| Android | 15 files | ✅ 81/81 passing | Individual runner script with APK caching |
| macOS | 15 files | ✅ 81/81 passing | Individual runner script (if needed) |
| Windows | 15 files | ✅ 81/81 passing | Individual runner script (if needed) |

### Success Metrics

**Reliability**:
- 100% of integration test files execute without framework errors
- 0 occurrences of "log reader stopped unexpectedly" error
- Consistent test execution across multiple runs

**Performance**:
- Linux: ~3-5 minutes total for 15 test files (acceptable)
- Android: ~5-10 minutes total with APK caching (vs. 20+ minutes without)
- Individual test execution trades some speed for reliability

**Maintainability**:
- Scripts automatically detect test files (no manual updates when tests added)
- Clear error messages and reporting
- Simple bash/shell scripts (easy to understand and modify)
- Documentation embedded in README

## Implementation Notes

### Shell Script Best Practices

1. **Error Checking**: Use `set -e` for strict error handling, but catch individual test failures gracefully
2. **Variable Naming**: Use clear, descriptive variable names (e.g., `passed_tests`, `failed_tests`)
3. **Logging**: Provide clear output for user feedback (✓ PASSED, ✗ FAILED)
4. **Exit Codes**: Follow Unix conventions (0 = success, 1 = failure)
5. **Portability**: Use POSIX-compatible commands where possible
6. **Documentation**: Add inline comments explaining script logic

### Test File Ordering

Alphabetical sorting ensures deterministic execution:
- `accessibility_integration_test.dart` (first)
- ...
- `sync_settings_integration_test.dart` (last)

Consistent ordering aids in:
- Debugging failing tests
- Comparing test run results
- Identifying regression patterns

### Flutter Version Management

Scripts use `fvm flutter` for consistency:
- Ensures same Flutter version across all runs
- Matches existing Makefile commands
- Supports version switching if needed

## Future Considerations

### Potential Enhancements

1. **Parallel Test Execution**: If Flutter fixes bug, could run multiple tests in parallel
2. **Test Filtering**: Add flags to run specific test files or patterns (e.g., `--only sync`)
3. **Platform Auto-Detection**: Scripts could detect available platforms and run appropriate tests
4. **Result Caching**: Cache test results and skip unchanged tests (incremental testing)
5. **HTML Reports**: Generate HTML summary reports for better visualization

### Test Evolution

- If Flutter team fixes issue #101031, evaluate removing scripts and using native Flutter commands
- If APK caching causes issues (stale builds), add timestamp/invalidation logic
- Consider migrating to Make for cross-platform compatibility if Windows support is needed
- Extend scripts to support macOS and Windows if testing on those platforms

### Monitoring

- Monitor Flutter issue #101031 for updates on official fix
- Track performance improvements with APK caching
- Watch for Flutter release notes mentioning integration test fixes
- Evaluate if workaround is still needed after Flutter upgrades
