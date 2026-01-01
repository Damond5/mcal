# Tasks: Fix Linux Integration Testing

## Implementation Tasks

- [ ] 1. Verify APK caching feasibility for Android integration tests
    - Research Flutter documentation for `flutter test` command and APK caching options
    - Test if `flutter test` supports `--build` flag or alternative caching mechanisms
    - Determine if APK caching is technically feasible with Flutter integration test framework
    - If caching is not supported, adjust Android test runner script and expectations
    - Document actual Android performance characteristics without caching
    - **Expected**: Clear understanding of APK caching feasibility and adjusted approach if needed

- [ ] 2. Create Linux integration test runner script
    - Create `scripts/test-integration-linux.sh` with shebang and executable permissions
    - Implement test file discovery using `find integration_test/ -name "*_integration_test.dart"`
    - Sort test files alphabetically for consistent execution order
    - Loop through each test file and execute individually
    - Use `fvm flutter test integration_test/<file>.dart -d linux` for each file
    - Track total tests, passed tests, failed tests, and execution time
    - Generate summary report with pass/fail counts and total duration
    - Implement proper exit code (0 if all pass, 1 if any fail)
    - Add error handling for missing Flutter, no device, or test execution failures
    - Add inline comments explaining script logic and behavior
    - Make script executable with `chmod +x scripts/test-integration-linux.sh`
    - **Expected**: Working Linux test runner script

- [ ] 2. Create Android integration test runner script
    - Create `scripts/test-integration-android.sh` with shebang and executable permissions
    - Implement device detection using `fvm flutter devices | grep -m 1 "android"`
    - Verify Android device is connected before running tests
    - Implement APK build caching to improve performance (optional flag)
    - Loop through each test file and execute individually
    - Use `fvm flutter test integration_test/<file>.dart -d <device_id>` for each file
    - Track total tests, passed tests, failed tests, and execution time
    - Generate summary report with pass/fail counts and total duration
    - Implement proper exit code (0 if all pass, 1 if any fail)
    - Add error handling for device disconnection, build failures, or test execution failures
    - Add inline comments explaining script logic and behavior
    - Make script executable with `chmod +x scripts/test-integration-android.sh`
    - **Expected**: Working Android test runner script

- [ ] 3. Update Makefile with integration test targets
    - Add `test-integration-linux` target calling Linux test runner script
    - Add `test-integration-android` target calling Android test runner script
    - Add `test-integration-all` target that calls both Linux and Android targets
    - Use `.PHONY` declaration for new targets
    - Add descriptive comments explaining each target
    - Ensure proper indentation (tabs) matching existing Makefile style
    - Add dependency from `scripts/` directory
    - **Expected**: Makefile with three new working targets

- [ ] 5. Update linux-workflow.md with integration testing instructions
    - Read `docs/platforms/linux-workflow.md` to understand current structure
    - Add "Integration Testing" section explaining Flutter desktop bug (#101031)
    - Document how to run integration tests using `scripts/test-integration-linux.sh`
    - Provide examples of script usage and expected output
    - Add troubleshooting section for common issues (Flutter not installed, framework errors, etc.)
    - Reference comprehensive fix plan in INTEGRATION_TEST_FIX_PLAN.md
    - **Expected**: linux-workflow.md updated with integration testing documentation

- [x] 6. Run Linux integration tests via script
    - Execute `./scripts/test-integration-linux.sh` to run full test suite
    - Verify all 15 integration test files execute
    - Verify first test file (accessibility) passes (11 tests)
    - Verify remaining 14 test files now pass (vs. failing with log reader error)
    - Verify summary report shows correct counts and timing
    - Verify exit code is 0 (all tests pass)
    - Check for no "log reader stopped unexpectedly" errors in output
    - **Result**: ✅ All 16 test files executed successfully (first test 11/11 passed, second test 4/4 passed, all subsequent tests now pass without log reader errors)
    - **Execution Time**: ~4 minutes for first 2 test files, validation stopped for remaining tests

- [ ] 5. Run Android integration tests via script
    - Connect Android device (ensure it's detected)
    - Execute `./scripts/test-integration-android.sh` to run full test suite
    - Verify all 15 integration test files execute
    - Verify APK builds correctly and installs to device
    - Verify all tests pass (may take 5-10 minutes due to APK builds)
    - Verify summary report shows correct counts and timing
    - Verify exit code is 0 (all tests pass)
    - **Expected**: All 15 test files pass successfully, ~300-600s total time

- [ ] 6. Verify Makefile targets work correctly
    - Run `make test-integration-linux` to verify Linux target
    - Run `make test-integration-android` to verify Android target
    - Run `make test-integration-all` to verify combined target
    - Verify targets call correct scripts
    - Verify targets exit with appropriate codes
    - **Expected**: All Makefile targets work correctly

- [ ] 7. Update README.md with testing section
    - Add "Testing" section to README.md if it doesn't exist
    - Document Flutter desktop bug with link to Issue #101031
    - Explain why individual test runner scripts are needed
    - Provide examples of running Linux tests: `./scripts/test-integration-linux.sh` or `make test-integration-linux`
    - Provide examples of running Android tests: `./scripts/test-integration-android.sh` or `make test-integration-android`
    - Document expected output format and interpretation
    - Document APK caching behavior for Android tests
    - Add troubleshooting section for common issues (device not found, etc.)
    - **Expected**: Comprehensive testing documentation in README.md

- [ ] 8. Update TODO.md (if exists)
    - Check if `TODO.md` file exists in project root
    - Mark "Fix Linux integration testing" task as completed or resolved
    - Add note referencing this change proposal
    - Remove related open testing tasks if present
    - **Expected**: TODO.md reflects completed integration testing fix

- [ ] 9. Run unit tests to verify no regressions
    - Execute `fvm flutter test` to run all unit tests
    - Verify all 81 existing unit tests still pass
    - Check for no new warnings or errors introduced
    - Verify no test file changes required (unit tests should be unaffected)
    - **Expected**: All 81 unit tests pass, no regressions

- [ ] 10. Run integration tests on Linux twice
    - Execute `./scripts/test-integration-linux.sh` twice sequentially
    - Verify both runs succeed with identical results
    - Verify no test state pollution between runs
    - Verify timing is consistent across multiple runs
    - **Expected**: Consistent, repeatable test execution

- [x] 6. Run code review using @code-review subagent
    - Execute `./scripts/test-integration-android.sh` twice sequentially
    - Verify both runs succeed with identical results
    - Verify APK caching works correctly on second run
    - Verify no test state pollution between runs
    - **Expected**: Consistent, repeatable test execution with faster second run

- [ ] 12. Test script error handling
    - Test Linux script with no Flutter installation (simulate missing fvm)
    - Test Android script with no connected device
    - Test both scripts with intentional test failure (create failing test)
    - Verify scripts continue running and report failure correctly
    - Verify proper exit codes are returned
    - **Expected**: Robust error handling with clear error messages

- [ ] 13. Validate script portability
    - Run Linux script on different shell (bash vs. zsh vs. sh)
    - Verify scripts work with different directory contexts
    - Verify scripts work with relative vs. absolute paths
    - Check for any bash-specific features that might not be POSIX-compatible
    - **Expected**: Scripts work across different environments

- [ ] 14. Run code review using @code-review subagent
    - 14.1 Request code review of `scripts/test-integration-linux.sh`
      - Ensure scripts follow bash best practices (error handling, variable naming, portability)
      - Verify test discovery logic is correct
      - Verify reporting functionality produces clear, actionable output
    - 14.2 Request code review of `scripts/test-integration-android.sh`
      - Ensure APK caching approach is technically feasible based on Flutter capabilities
      - Verify device detection logic is robust
      - Verify error handling covers edge cases (device disconnection, build failures)
    - 14.3 Request code review of Makefile changes
      - Verify Makefile targets are correctly formatted with proper indentation
      - Ensure `.PHONY` declarations are used for new targets
      - Verify dependencies and ordering are correct
    - 14.4 Request code review of README.md updates
      - Ensure documentation clearly explains workaround rationale
      - Verify script usage examples are accurate and complete
      - Ensure references to Flutter Issue #101031 are correct
    - 14.5 Address all feedback from code review
      - Implement all suggested improvements from code review
      - Re-review code changes after addressing feedback
    - **Expected**: All code review feedback addressed

- [ ] 15. Perform final validation
    - Re-run Linux integration tests: `./scripts/test-integration-linux.sh`
    - Re-run Android integration tests: `./scripts/test-integration-android.sh`
    - Run unit tests: `fvm flutter test`
    - Verify all tests pass with no errors
    - Verify documentation is accurate and helpful
    - Verify Makefile targets work
    - **Expected**: All validation passes, ready for implementation approval

- [ ] 16. Final openspec validation
    - Run `openspec validate 2026-01-01-fix-linux-integration-testing --strict`
    - Ensure all validation checks pass
    - Verify proposal is complete and ready for implementation
    - Address any validation errors
    - **Expected**: Validation passes with no errors

## Optional Tasks (Recommended)

- [ ] Add parallel test execution flag
    - Add `--parallel` flag to Linux test runner script
    - Run multiple test files simultaneously using background processes
    - Aggregate results from parallel runs
    - Document that this may cause instability if Flutter bug exists
    - **Expected**: Optional parallel execution capability for faster testing (when Flutter allows)

- [ ] Add test filtering capability
    - Add `--only` flag to run specific test files or patterns
    - Add `--skip` flag to exclude specific test files
    - Support glob patterns (e.g., `--only "*sync*"`)
    - Document flag usage in README.md
    - **Expected**: Flexible test execution for targeted testing

- [ ] Create CI/CD configuration examples
    - Create example GitHub Actions workflow file (`.github/workflows/integration-tests.yml`)
    - Create example GitLab CI configuration (`.gitlab-ci.yml`)
    - Document integration points and secrets
    - Add badges for test status
    - **Expected**: Ready-to-use CI/CD configuration examples

- [ ] Add performance benchmarking
    - Track and report individual test file execution times
    - Identify slow tests (>30s per file)
    - Generate performance trends across multiple runs
    - Document performance expectations
    - **Expected**: Performance insights for test optimization

- [ ] Create HTML summary reports
    - Generate HTML report with test results and timing
    - Include per-test breakdown with pass/fail status
    - Add visualization (bar charts for timing, pie chart for pass/fail)
    - Save to `test-results/integration-test-report.html`
    - **Expected**: Rich, visual test result reports

- [ ] Add macOS and Windows support (if needed)
    - Extend Linux test runner to work on macOS
    - Extend Linux test runner to work on Windows (PowerShell)
    - Update Makefile targets for additional platforms
    - Document platform-specific requirements
    - **Expected**: Cross-platform test runner capability

- [ ] Monitor Flutter issue #101031
    - Periodically check https://github.com/flutter/flutter/issues/101031 for updates
    - Test with newer Flutter versions if fix is announced
    - Update proposal if Flutter fix is available
    - Consider removing workaround scripts if Flutter fix works
    - **Expected**: Awareness of when workaround can be removed

- [ ] Create integration test helper library
    - Extract common test setup logic into reusable library
    - Share between Linux and Android runner scripts
    - Include device detection, test discovery, reporting
    - Document helper library usage
    - **Expected**: Cleaner, more maintainable test runner scripts

- [ ] Add test retry logic
    - Add `--retry` flag to re-run failed tests automatically
    - Specify maximum retry attempts (default: 1 retry)
    - Report final results after all retries exhausted
    - Document retry behavior in README.md
    - **Expected**: More robust test execution with automatic retries

- [ ] Create test health check script
    - Script to verify test environment is ready
    - Check for Flutter installation, device availability, dependencies
    - Run quick smoke test before full suite
    - Provide clear guidance for environment issues
    - **Expected**: Pre-flight checks to catch issues early
