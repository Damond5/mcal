# Proposal: Add Test Cleanup for Event Persistence

## Problem
Tests are accumulating event files in `/tmp/test_docs/calendar/` directory, causing test pollution and potential interference between test runs. This occurs because:

1. **No tearDown methods**: None of the test files have `tearDown()` or `tearDownAll()` methods to clean up created events
2. **Real filesystem writes**: Tests mock `path_provider` to return `/tmp/test_docs` but perform real file operations through `EventStorage`
3. **Evidence**: Event files already accumulated (`test.md`, `test_1.md`) from test executions
4. **Test pollution**: Events created in one test persist and may interfere with subsequent test runs

This represents a **test reliability and hygiene issue** that can cause:
- False positives/negatives due to state leakage
- Accumulating disk space usage over time
- Unpredictable test behavior depending on execution order
- Difficulty debugging test failures caused by state pollution

## Proposed Solution
Add comprehensive test cleanup mechanisms to ensure tests leave no persistent state:

1. **Create test helper utilities** in `test/test_helpers.dart`:
   - `setupTestEnvironment()` - mocks path_provider, secure_storage, ensures clean test directory
   - `cleanupTestEnvironment()` - removes test directory and all contents
   - `setupTestEventProvider()` - creates EventProvider with automatic cleanup

2. **Add tearDown methods** to all affected test files:
   - Unit tests: `event_provider_test.dart`, `widget_test.dart`, `sync_service_test.dart`
   - Integration tests: `app_integration_test.dart`

3. **Ensure test isolation** by:
   - Cleaning up event files after each test
   - Removing the test calendar directory in tearDownAll
   - Preventing filesystem state from leaking between tests

## Documentation Updates
- **CHANGELOG.md**: Will be updated under "Fixed" section to document test cleanup improvements addressing test pollution
- **README.md**: Testing section (lines 156-189) will be updated to include test_helpers.dart and test isolation best practices

## Scope
This change is focused on test infrastructure and hygiene:
- **In scope**:
  - Creating `test/test_helpers.dart` with cleanup utilities
  - Adding tearDown/tearDownAll to unit tests in `test/`
  - Adding tearDown/tearDownAll to integration tests in `integration_test/`
  - Ensuring EventStorage tests properly clean up created events
  - Creating tests for test_helpers.dart to verify cleanup functionality

- **Out of scope**:
  - Changing test logic or assertions
  - Modifying production code (EventStorage, EventProvider)
  - Changing event storage implementation
  - Refactoring test structure beyond cleanup additions

## Acceptance Criteria
- Test helper file `test/test_helpers.dart` is created with cleanup utilities and error handling
- All unit test files in `test/` have tearDown/tearDownAll methods that clean up created events
- Integration test file `integration_test/app_integration_test.dart` has tearDown/tearDownAll methods
- Tests for test_helpers.dart exist and pass (setupTestEnvironment, cleanupTestEnvironment, setupTestEventProvider)
- After running tests, `/tmp/test_docs/calendar/` directory is empty or removed, verified by:
  - Running `ls -la /tmp/test_docs/calendar/` returns "No such file or directory" or empty listing
  - Running tests in a loop (e.g., 5 times) shows no file accumulation
- All tests pass with cleanup in place (no regressions)
- No event files are left behind after test execution
- Test isolation is verified (tests can be run in any order without interference)
- Cleanup errors are logged but do not mask test failures

## Impact
- **Testing**: Improves test reliability and prevents state pollution
- **Risk**: Low - test infrastructure only, no production code changes
- **Dependencies**: None
- **Performance**: Minimal - adds teardown overhead to each test
- **Maintainability**: Improves test hygiene and debugging experience

## Alternatives Considered
1. **In-memory mock storage**: Create a mock `EventStorage` that doesn't write to filesystem
   - *Rejected*: Less realistic testing, requires more code to maintain, doesn't test actual storage behavior

2. **Ignore the issue**: Continue accumulating test files
   - *Rejected*: Poor test hygiene, can cause flaky tests, accumulates disk space

3. **Delete files before each test**: Use setUp to clean before each test instead of tearDown
   - *Rejected*: tearDown is more appropriate (cleanup after test), may hide test failures if cleanup happens before assertion

4. **Separate test helpers per file**: Create cleanup logic in each test file independently
   - *Rejected*: Duplicates code, harder to maintain, centralized helpers are better

## Notes
- Current tests write real files to `/tmp/test_docs/calendar/` during execution
- Tests mock path_provider to use test directory but still use real filesystem operations
- EventStorage persists events as Markdown files (`lib/services/event_storage.dart:78-83`)
- No existing test cleanup mechanisms exist in the codebase
- This follows testing best practices for isolation and hygiene
