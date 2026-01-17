# testing Specification Delta

## ADDED Requirements

### Requirement: The application SHALL Provide Test Timing Utilities

Integration tests SHALL use specialized timing utilities for Flutter-Rust interop operations where standard `pumpAndSettle()` is insufficient:

- Tests SHALL use `waitForEventProviderSettled()` after event operations
- Tests SHALL use `retryWithBackoff()` for operations requiring retry logic
- Tests SHALL use `TestTimeoutUtils` for configurable timeout management
- Timing utilities SHALL be configurable for different operation types
- Tests SHALL NOT rely solely on `pumpAndSettle()` for Rust-backed operations

#### Scenario: Event creation waits for provider state settlement
Given an integration test is creating an event
When the event is saved via the event provider
Then `waitForEventProviderSettled()` SHALL be called to ensure state consistency
And the test SHALL wait until provider.isLoading is false
And the test SHALL wait an additional 200ms for Rust backend synchronization

#### Scenario: Async operation retries with exponential backoff
Given an integration test performs an async operation that may fail intermittently
When the operation is wrapped with `retryWithBackoff()`
Then the operation SHALL be retried up to configured maxAttempts
And each retry SHALL wait with exponential backoff starting at 100ms
And the final attempt SHALL propagate the exception if all retries fail

#### Scenario: Test timeout configuration prevents hangs
Given an integration test configures timeout using TestTimeoutUtils
When an operation exceeds the configured timeout
Then a TimeoutException SHALL be thrown
And the test SHALL fail with clear timeout message
And subsequent tests SHALL not be affected by the timeout

### Requirement: The application SHALL Provide Test Isolation Utilities

Integration tests SHALL use complete test isolation to prevent state pollution between test executions:

- Tests SHALL use `isolateTestEnvironment()` before test operations
- Tests SHALL use `cleanupIsolation()` after test completion
- Each test SHALL receive a unique isolation ID
- File system isolation SHALL use unique temporary directories
- All state (providers, storage, notifications) SHALL be reset between tests
- Isolation utilities SHALL work across all target platforms

#### Scenario: Test environment isolation prevents state pollution
Given multiple integration tests are executing in sequence
When each test calls `isolateTestEnvironment()` before operations
Then each test SHALL operate in a completely isolated environment
And state from one test SHALL NOT affect subsequent tests
And test results SHALL be consistent regardless of execution order

#### Scenario: File system isolation with unique directories
Given an integration test is configured to isolate file system
When `isolateTestEnvironment(isolateFileSystem: true)` is called
Then a unique temporary directory SHALL be created
And EventStorage SHALL be configured to use the isolated directory
And the directory SHALL be cleaned up after test completion

#### Scenario: Complete cleanup prevents resource leaks
Given an integration test has completed execution
When `cleanupIsolation()` is called
Then all isolated file system directories SHALL be deleted
And all provider state SHALL be reset
And all scheduled notifications SHALL be cancelled
And no test artifacts SHALL remain for subsequent tests

### Requirement: The application SHALL Provide Error Injection Framework

Integration tests SHALL use controlled error injection for testing error scenarios:

- Tests SHALL use `setupErrorInjection()` to configure error responses
- Error injection SHALL work with PlatformException and other exception types
- Tests SHALL use `verifyErrorOccurred()` to validate error handling
- Error scenarios SHALL be deterministic and reproducible
- Error injection SHALL be cleaned up after test completion

#### Scenario: Controlled error injection for testing error handling
Given an integration test needs to verify error handling
When `setupErrorInjection()` is called with error configuration
Then subsequent method calls on the configured channel SHALL throw the configured error
And the error SHALL be a PlatformException with specified code and message
And the test SHALL be able to verify the error occurred

#### Scenario: Error verification helper validates error characteristics
Given an integration test wraps an action with `verifyErrorOccurred()`
When the action is executed and throws an exception
Then the helper SHALL verify the exception type matches
And the helper SHALL verify error code matches if specified
And the helper SHALL verify error message matches if specified
And the test SHALL fail if error characteristics don't match

### Requirement: The application SHALL Provide Test Data Factories

Integration tests SHALL use standardized data factories for creating consistent test data:

- Tests SHALL use `EventTestFactory` for creating events
- Tests SHALL use `TestDataFactory` for bulk operations
- Factory methods SHALL generate unique identifiers automatically
- Events SHALL have configurable properties (title, time, recurrence, etc.)
- Factory methods SHALL support common test scenarios (conflicts, sequences)

#### Scenario: Event factory creates valid, unique events
Given an integration test needs to create a test event
When `EventTestFactory.createValidEvent()` is called
Then a valid Event object SHALL be returned
And the event SHALL have a unique title (timestamp-based)
And the event SHALL have valid date/time format
And the event SHALL have default values for optional properties

#### Scenario: Event factory creates conflicting events
Given an integration test needs to test conflict detection
When `EventTestFactory.createConflictingEvent()` is called with an existing event
Then a new event SHALL be returned that overlaps with the existing event
And the overlap SHALL be configurable via overlapMinutes parameter
And the conflicting event SHALL have valid unique properties

#### Scenario: Bulk data factory creates multiple events
Given an integration test needs to test performance with many events
When `TestDataFactory.createBulkEvents(count: N)` is called
Then N unique events SHALL be returned
And each event SHALL have unique title and times
And all events SHALL be valid for the test scenario

### Requirement: The application SHALL Ensure Test Determinism

Integration tests SHALL execute deterministically with consistent results:

- Tests SHALL NOT have timing-dependent assertions
- Tests SHALL handle async operations with proper waiting
- Tests SHALL clean up all state after completion
- Tests SHALL use unique identifiers to prevent collisions
- Multiple test runs SHALL produce identical results

#### Scenario: Multiple test runs produce identical results
Given a deterministic integration test is executed multiple times
When each run uses fresh isolation and unique identifiers
Then the test results SHALL be identical across all runs
And no tests SHALL fail due to state from previous runs
And no tests SHALL fail due to timing variations

#### Scenario: Tests handle concurrent operations safely
Given an integration test performs concurrent operations
When synchronization utilities are used properly
Then all operations SHALL complete without race conditions
And test state SHALL remain consistent throughout execution
And final assertions SHALL reflect the actual operation results
