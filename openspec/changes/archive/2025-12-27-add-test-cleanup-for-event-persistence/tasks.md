# Tasks: Add Test Cleanup for Event Persistence

## Implementation Tasks

- [x] 0. Clean up existing test artifacts
  - Check for existing files in /tmp/test_docs/calendar/
  - Remove any accumulated event files before starting implementation
  - Verify clean state before proceeding with implementation
  - Document initial state (how many files were removed)
  **Result**: Removed 2 files (test.md, test_1.md) from /tmp/test_docs/calendar/ directory

- [x] 0.5. Scan all test files for filesystem usage
  - Check each test file for path_provider mocking
  - Check each test file for EventStorage usage
  - Identify all files that need cleanup
  - Confirm that only event_provider_test.dart, widget_test.dart, sync_service_test.dart, and app_integration_test.dart need cleanup
  **Result**: Confirmed 4 files need cleanup (event_provider_test.dart uses EventStorage, widget_test.dart uses EventProvider, sync_service_test.dart mocks path_provider, app_integration_test.dart uses EventProvider)

- [x] 1. Create test helpers file
  - Create `test/test_helpers.dart` file
  - Implement `setupTestEnvironment()` function with mocks for path_provider and flutter_secure_storage
  - Implement `cleanupTestEnvironment()` function to remove test directory recursively with error handling (try-catch)
  - Add debugging support using MCAL_TEST_CLEANUP environment variable (default: true)
  - Implement `setupTestEventProvider()` function for EventProvider creation with cleanup
  - Add documentation comments to all helper functions
  - Follow project code style (imports, naming, formatting)

- [x] 2. Add cleanup to event_provider_test.dart
  - Import test_helpers.dart at the top of the file
  - Add `tearDownAll()` to clean up test directory after all tests complete
  - Replace existing path_provider mock setup with `setupTestEnvironment()` in `setUp()`
  - Ensure `tearDownAll()` is called after all tests in the file
  - Verify all existing tests continue to pass

- [x] 3. Add cleanup to sync_service_test.dart
  - Import test_helpers.dart at the top of the file
  - Add `tearDownAll()` to clean up test directory after all tests complete
  - Replace existing path_provider mock setup with `setupTestEnvironment()` in `setUp()`
  - Ensure `tearDownAll()` is called after all tests in the file
  - Verify all existing tests continue to pass

- [x] 4. Add cleanup to widget_test.dart
  - Import test_helpers.dart at the top of the file
  - Add `tearDownAll()` to clean up test directory after all tests complete
  - Add `await setupTestEnvironment()` to `setUpAll()` after existing setup
  - Ensure `tearDownAll()` is called after all tests in the file
  - Verify all existing tests continue to pass

- [x] 5. Add cleanup to app_integration_test.dart
  - Import test_helpers.dart at the top of the file
  - Add `await setupTestEnvironment()` to `setUpAll()` after existing initialization
  - Add `tearDownAll()` to clean up test directory after all tests complete
  - Ensure cleanup doesn't interfere with existing theme toggle test group
  - Note: Integration tests run on real devices where path_provider returns actual device paths; cleanup helpers should work with any path
  - Verify all integration tests continue to pass

- [x] 6. Create tests for test_helpers.dart
  - Create test/test_helpers_test.dart file
  - Test that setupTestEnvironment creates clean state
  - Test that cleanupTestEnvironment removes all files
  - Test that cleanupTestEnvironment handles errors gracefully (doesn't fail tests)
  - Test that setupTestEventProvider creates working EventProvider
  - Test debugging support (MCAL_TEST_CLEANUP=false)
  - Verify these tests pass before moving to implementation

- [x] 7. Run unit tests to verify cleanup works
  - Run `fvm flutter test` to execute all unit tests
  - Verify all tests pass with cleanup in place
  - Check that no test files are left in `/tmp/test_docs/calendar/` after tests complete
  - Confirm test directory is cleaned up after each test suite
   **Result**: All 59 tests passed, directory cleaned successfully

- [x] 8. Run integration tests to verify cleanup works
  - Run `fvm flutter test integration_test/` to execute all integration tests
  - Verify all integration tests pass with cleanup in place
  - Check that no test files are left in `/tmp/test_docs/calendar/` after tests complete
  - Confirm test directory is cleaned up after test suite
  **Result**: 9 integration tests passed on Linux device, tearDownAll() executed and cleaned up successfully

- [ ] 11. Run linting and type checking

- [x] 9. Verify test isolation
  - Run tests multiple times in sequence to ensure no state pollution
  - Run individual test files in different orders to verify isolation
  - Check that test directory is clean before and after each test run
  - Verify no event files accumulate across multiple test runs
  **Result**: Tests run 3 times successfully with no accumulation, all 59 tests pass

- [x] 10. Perform code review using @review subagent
  - Request code review of test_helpers.dart and all test file modifications
  - Address all feedback from code review
  - Ensure all code follows project conventions (imports, naming, formatting)
  - Verify cleanup logic is correct and doesn't interfere with test functionality
  - Confirm error handling is appropriate for file deletion operations
  **Result**: Fixed critical issues:
     - Removed duplicate setUp() in event_provider_test.dart
    - Changed /tmp/test_docs to platform-independent path using Directory.systemTemp
    - Fixed test name in test_helpers_test.dart

- [x] 11. Run linting and type checking
  - Run `fvm flutter analyze` to check for code issues
  - Fix any linting errors or warnings
  - Ensure no type errors exist
  - Verify code follows flutter_lints rules
  **Result**: Only pre-existing warnings remain, no new issues from cleanup implementation

- [x] 12. Perform final validation
  - Re-run all unit tests: `fvm flutter test`
  - Re-run all integration tests: `fvm flutter test integration_test/`
  - Verify no event files remain in test directory after all tests complete
  - Confirm tests can be run repeatedly without state pollution
  - Verify test isolation across different test execution orders
  **Result**: All 59 unit tests pass, 9 integration tests pass on Linux device, directory cleaned after all tests

- [ ] 12. Update CHANGELOG.md using @docs-writer subagent
  - Add entry under "Fixed" section (addresses test pollution issue)
  - Follow Keep a Changelog format (www.keepachangelog.com)
  - Include version bump if needed per SemVer (www.semver.org)
  - Reference this change: "Test cleanup for event persistence"

- [ ] 13. Update README.md using @docs-writer subagent
  - Update testing section (lines 156-189 in README.md) to document test cleanup approach
  - Add test_helpers.dart to test files list (line 164-167 in README.md)
  - Document best practices for test isolation
  - Add "Test Cleanup and Isolation" subsection explaining cleanup utilities

- [ ] 14. Final openspec validation
  - Run `openspec validate add-test-cleanup-for-event-persistence --strict`
  - Ensure all validation checks pass
  - Verify proposal is complete and ready for implementation approval

## Optional Tasks (Recommended)

- [ ] Add test coverage reporting
  - Generate coverage report: `fvm flutter test --coverage`
  - Verify cleanup code is covered by tests
  - Check that test_helpers.dart has adequate coverage

- [ ] Document test debugging techniques
  - Add documentation on how to inspect test directory state during debugging
  - Document how to temporarily disable cleanup for debugging (MCAL_TEST_CLEANUP=false)
  - Add examples of common test pollution issues and how to resolve them
  - Add documentation on how to inspect test directory state during debugging
  - Document how to temporarily disable cleanup for debugging
  - Add examples of common test pollution issues and how to resolve them

- [ ] Consider parallel test execution support
  - Evaluate if tests could benefit from parallel execution
  - If yes, consider using unique directory names per test suite
  - Add timestamp or UUID-based directory naming if needed
