# integration-test-runner Specification

## ADDED Requirements

### Requirement: The application SHALL Linux Integration Test Runner Script

The application SHALL provide a shell script (`scripts/test-integration-linux.sh`) that executes each integration test file individually on Linux platform, working around Flutter desktop bug #101031 by ensuring clean app lifecycle management for each test file.

#### Scenario: Linux integration tests execute via script with all tests passing
Given a Linux development environment with Flutter installed
And integration test directory contains 15 test files
When developer executes `./scripts/test-integration-linux.sh`
Then each of the 15 integration test files executes individually
And all integration tests pass without "log reader stopped unexpectedly" error
And a summary report displays total tests passed, failed, and execution time
And script exits with code 0 (success)
And no app instances remain running after script completion

#### Scenario: Linux integration test runner handles test failures gracefully
Given a Linux development environment with Flutter installed
And at least one integration test file contains a failing test
When developer executes `./scripts/test-integration-linux.sh`
Then script executes all 15 integration test files
And failed test files are clearly marked with ✗ FAILED
And summary report correctly shows pass/fail counts
And script continues running remaining tests after failures (fail-fast disabled)
And script exits with code 1 (any test failed)
And developer can identify which specific test files failed from summary

#### Scenario: Linux integration test runner generates timing information
Given a Linux development environment with Flutter installed
And integration test directory contains test files
When developer executes `./scripts/test-integration-linux.sh`
Then script records execution time for each test file
And summary report displays individual test file durations
And summary report displays total execution time
And developer can identify slow or fast tests from timing data

#### Scenario: Linux integration test runner auto-detects test files
Given a Linux development environment with Flutter installed
And integration test directory contains files matching `*_integration_test.dart` pattern
When developer executes `./scripts/test-integration-linux.sh`
Then script automatically discovers all integration test files without manual configuration
And script executes test files in alphabetical order
And script works correctly when new integration test files are added
And script works correctly when integration test files are removed

#### Scenario: Linux integration test runner handles missing Flutter installation
Given a Linux development environment without Flutter installed
When developer executes `./scripts/test-integration-linux.sh`
Then script detects missing `fvm` or `flutter` command
And script displays clear error message explaining Flutter is required
And script exits with code 1 (failure)
And script does not attempt to run tests without Flutter available

### Requirement: The application SHALL Android Integration Test Runner Script

The application SHALL provide a shell script (`scripts/test-integration-android.sh`) that executes each integration test file individually on Android platform, with optional APK build caching to improve performance.

#### Scenario: Android integration tests execute via script with all tests passing
Given a Linux environment with connected Android device
And integration test directory contains 15 test files
When developer executes `./scripts/test-integration-android.sh`
Then script verifies Android device is connected and available
Then script executes all 15 integration test files individually
And all integration tests pass successfully
And APK is built once and reused for subsequent tests (with caching)
And a summary report displays total tests passed, failed, and execution time
And script exits with code 0 (success)
And no app instances remain running on device after script completion

#### Scenario: Android integration test runner handles test failures gracefully
Given a Linux environment with connected Android device
And at least one integration test file contains a failing test
When developer executes `./scripts/test-integration-android.sh`
Then script executes all 15 integration test files
And failed test files are clearly marked with ✗ FAILED
And summary report correctly shows pass/fail counts
And script continues running remaining tests after failures (fail-fast disabled)
And script exits with code 1 (any test failed)
And developer can identify which specific test files failed from summary

#### Scenario: Android integration test runner verifies APK caching feasibility
Given an Android test runner script implementation task
And Flutter documentation is reviewed for `flutter test` command capabilities
When script is implemented with APK caching logic
Then APK caching approach is verified to be supported or unsupported
And if unsupported, alternative uncached approach is documented
And if supported, caching provides expected performance improvement
Given a Linux environment with connected Android device
And integration test directory contains test files
When developer executes `./scripts/test-integration-android.sh` with APK caching enabled
Then first test file triggers APK build (~9-10 seconds)
Then subsequent 14 test files reuse the same APK (no rebuild)
Then total execution time is significantly reduced compared to uncached execution
And summary report notes that APK caching was used
And developer sees clear time savings in summary (e.g., "Total time: 150s (vs. ~250s without caching)")

#### Scenario: Android integration test runner detects connected device
Given a Linux environment with Flutter SDK installed
And one or more Android devices are connected via USB
When developer executes `./scripts/test-integration-android.sh`
Then script identifies connected Android device using `fvm flutter devices`
And script uses the correct device ID for test execution
And script displays which device is being used (e.g., "Running on device: CPH2415")
And if multiple devices are connected, script uses the first one or prompts for selection

#### Scenario: Android integration test runner handles missing Android device
Given a Linux environment with Flutter SDK installed
And no Android devices are connected via USB
When developer executes `./scripts/test-integration-android.sh`
Then script detects that no Android device is available
And script displays clear error message explaining device connection is required
And script exits with code 1 (failure)
And script does not attempt to run tests without device available

### Requirement: The application SHALL Test Runner Performance Standards

The integration test runner scripts SHALL complete execution within acceptable performance thresholds to ensure tests are practical for regular development and CI/CD workflows.

#### Scenario: Linux integration tests complete within performance threshold
Given a Linux development environment with Flutter installed
And integration test directory contains 15 test files
When developer executes `./scripts/test-integration-linux.sh`
Then all 15 test files execute successfully
And total execution time is less than 5 minutes (300 seconds)
And average test file execution time is less than 20 seconds

#### Scenario: Android integration tests complete within performance threshold with APK caching
Given a Linux environment with connected Android device
And integration test directory contains 15 test files
When developer executes `./scripts/test-integration-android.sh` with APK caching enabled
Then all 15 test files execute successfully
And APK is built once and reused for subsequent tests
And total execution time is less than 10 minutes (600 seconds)
And average test file execution time is less than 40 seconds

#### Scenario: Android integration tests complete within performance threshold without APK caching
Given a Linux environment with connected Android device
And integration test directory contains 15 test files
When developer executes `./scripts/test-integration-android.sh` without APK caching
Then all 15 test files execute successfully
And APK is rebuilt for each test file
And total execution time is less than 20 minutes (1200 seconds)
And developer sees clear message indicating uncached execution

### Requirement: The application SHALL Test Runner Error Messages

The integration test runner scripts SHALL provide clear, actionable error messages to help developers troubleshoot common issues.

#### Scenario: Error message when Flutter is not installed
Given a Linux environment without Flutter SDK or fvm installed
When developer executes integration test runner script
Then script detects missing Flutter installation
And clear error message is displayed explaining Flutter is required
And script suggests running `fvm install` or setting PATH
And script exits with code 1

#### Scenario: Error message when Android device not found
Given a Linux environment with Flutter SDK installed
And no Android devices are connected via USB
When developer executes Android integration test runner script
Then script detects no Android device is available
And clear error message is displayed explaining device connection is required
And script suggests running `fvm flutter devices` to check available devices
And script suggests enabling USB debugging on Android device
And script exits with code 1

#### Scenario: Error message when Flutter framework bug occurs
Given a Linux environment with Flutter installed
And integration test runner executes test files
When Flutter integration test framework encounters log reader error (Issue #101031)
Then script error message references Flutter Issue #101031
And script explains this is a known Flutter desktop bug
And script provides next steps to work around issue (use script)
And script continues running remaining test files
And script exits with code 1 after all files attempted

### Requirement: The application SHALL Test Runner Maintenance

The integration test runner scripts SHALL require minimal maintenance and automatically adapt to changes in test suite.

#### Scenario: Test runner detects new integration test files automatically
Given a development environment with integration test runner scripts installed
And a new integration test file `new_feature_integration_test.dart` is added to `integration_test/` directory
When developer executes test runner script
Then script automatically discovers and runs new test file
And no manual configuration changes are required
And new test is included in summary report

#### Scenario: Test runner continues working when test files are removed
Given a development environment with integration test runner scripts installed
And an existing integration test file is removed from `integration_test/` directory
When developer executes test runner script
Then script executes remaining test files without errors
And summary report reflects updated file count
And no manual script updates are required

### Requirement: The application SHALL Makefile Integration Test Targets

The application SHALL provide Makefile targets for convenient execution of integration test runner scripts on Linux and Android platforms.

#### Scenario: Developer runs Linux integration tests via Makefile
Given a Linux development environment with Makefile available
When developer executes `make test-integration-linux`
Then Makefile executes `./scripts/test-integration-linux.sh`
Then all 15 integration test files execute on Linux
And test results display in terminal
And Makefile target completes with appropriate exit code

#### Scenario: Developer runs Android integration tests via Makefile
Given a Linux development environment with Makefile and connected Android device
When developer executes `make test-integration-android`
Then Makefile executes `./scripts/test-integration-android.sh`
Then all 15 integration test files execute on Android device
And test results display in terminal
And Makefile target completes with appropriate exit code

#### Scenario: Developer runs integration tests on all platforms via Makefile
Given a Linux development environment with Makefile and connected Android device
When developer executes `make test-integration-all`
Then Makefile executes `make test-integration-linux` target
Then Makefile executes `make test-integration-android` target
Then all integration tests execute on both Linux and Android platforms sequentially
And test results display in terminal for both platforms
And Makefile completes after both targets finish

### Requirement: The application SHALL Document Integration Test Runner

The application SHALL document the integration test runner approach, Flutter desktop bug workaround, and usage instructions in project README.

#### Scenario: Developer reads documentation for integration testing approach
Given a developer new to the project
And README.md contains Testing section with integration test runner documentation
When developer reads README.md to understand how to run tests
Then README explains that Flutter desktop integration tests require individual execution
Then README references Flutter Issue #101031 with link to GitHub
Then README provides clear examples of running Linux tests: `./scripts/test-integration-linux.sh` or `make test-integration-linux`
Then README provides clear examples of running Android tests: `./scripts/test-integration-android.sh` or `make test-integration-android`
Then README explains expected output format (summary report with pass/fail counts and timing)
Then README explains why workaround is necessary (Flutter framework bug)

#### Scenario: Developer reads documentation for troubleshooting common issues
Given a developer experiencing issues running integration tests
And README.md contains Testing section with troubleshooting information
When developer encounters error (e.g., "no Android device found")
Then README provides guidance for the specific error
Then README suggests checking device connection with `fvm flutter devices`
Then README suggests verifying Flutter installation with `fvm flutter doctor`
Then README provides link to Flutter Issue #101031 for more information
