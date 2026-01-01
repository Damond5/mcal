## Linux Development Workflow

**Breadcrumb:** [Project Root](../../README.md) > [Docs](../) > [Platforms](.) > Linux Workflow

This section provides guidelines for Linux-specific development tasks in the MCAL project.

### Building the App

Platform-specific instructions to be added

### Testing

This section covers integration testing on Linux platform.

#### Integration Test Runner Scripts

MCAL provides integration test runner scripts that work around Flutter desktop bug #101031, which prevents running multiple integration test files sequentially on Linux. The scripts execute each test file individually with clean app lifecycle management.

**Note:** This is a workaround for a Flutter framework bug. See:
- Flutter Issue #101031: https://github.com/flutter/flutter/issues/101031
- Fix plan: INTEGRATION_TEST_FIX_PLAN.md

##### Linux Integration Tests

To run all integration tests on Linux:

```bash
./scripts/test-integration-linux.sh
```

Or using Makefile:

```bash
make test-integration-linux
```

##### Expected Behavior

- All 15 integration test files execute individually
- Each test file has clean app start/shutdown cycle
- No "log reader stopped unexpectedly" errors
- Summary report displays pass/fail counts and timing
- Script exits with code 0 if all tests pass, code 1 if any fail

##### Test Files

The script automatically discovers and runs all test files matching `*_integration_test.dart` pattern in the `integration_test/` directory. Current test files include:

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

##### Troubleshooting

**Problem:** Script reports "Error: No Android device found"
- **Solution:** You're on Linux, use the Linux integration test runner instead

**Problem:** Script reports "Error: Flutter (fvm) is not installed"
- **Solution:** Install Flutter or check your PATH configuration

**Problem:** Tests fail with "log reader stopped unexpectedly" error
- **Solution:** This is the Flutter desktop bug #101031. The script's individual execution approach is the workaround. If errors persist, check Flutter version compatibility.

**Problem:** Script is not executable
- **Solution:** Run `chmod +x scripts/test-integration-linux.sh` to make it executable

### Running on Device

Platform-specific instructions to be added

### Troubleshooting

Platform-specific instructions to be added