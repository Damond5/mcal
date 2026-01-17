# testing Specification

## Purpose
TBD - created by archiving change incorporate-existing-docs. Update Purpose after archive.
## Requirements
### Requirement: The application SHALL Comprehensive Test Suite
The application SHALL maintain comprehensive test suite with widget tests for GUI functionality, unit tests for business logic, and integration tests for end-to-end workflows.

#### Scenario: Widget tests
Given app components
When tests run
Then GUI loading, calendar display, day selection, theme toggle are verified

#### Scenario: Unit tests
Given providers and services
When tests run
Then ThemeProvider, EventProvider, NotificationService, SyncService, SyncSettings logic is verified

### Requirement: The application SHALL Testing Framework
Tests SHALL use Flutter's testing framework with mockito for SharedPreferences mocking.

#### Scenario: Mocking dependencies
Given SharedPreferences usage
When tests run
Then mocked preferences are used for isolation

### Requirement: The application SHALL Test Execution
All tests SHALL run via `fvm flutter test`, with separate execution for units and integrations.

#### Scenario: Running unit tests
Given test command
When executed
Then all unit tests pass without external dependencies

#### Scenario: Running integration tests
Given integration test command
When executed on device
Then end-to-end workflows are verified

### Requirement: The application SHALL Test Coverage
Tests SHALL cover app loading, calendar display, day selection, theme toggle interactions, event management, notification scheduling, sync operations, and settings persistence.

#### Scenario: Coverage verification
Given test suite
When coverage report generated
Then critical paths are adequately covered

### Requirement: The application SHALL Hybrid Testing Approach
The application SHALL use unit tests for isolated logic (models, services), integration tests for UI interactions and real plugins.

#### Scenario: Unit isolation
Given service class
When unit tested
Then external dependencies are mocked

#### Scenario: Integration verification
Given full app
When integration tested
Then real plugin interactions work correctly

### Requirement: The application SHALL Theme Toggle Integration Tests
The application SHALL include integration tests in `integration_test/app_integration_test.dart` for the theme toggle functionality to verify end-to-end behavior:

- Button interaction and tappability verification
- Theme mode changes (system → light ↔ dark cycle)
- Button icon updates (Icons.brightness_6/light_mode/dark_mode)
- Theme persistence across app restarts via SharedPreferences
- Visual theme changes in UI elements (colors, themes)

This complements existing unit tests in `test/theme_provider_test.dart` which verify ThemeProvider logic in isolation.

#### Scenario: Theme toggle button interaction
Given the app is loaded with system theme
When the theme toggle button is tapped
Then the theme mode changes to the opposite of current system theme
And the button icon updates to reflect the new theme

#### Scenario: Theme toggle cycle
Given the app is loaded and theme is set to light mode
When the theme toggle button is tapped
Then the theme mode changes to dark mode
And when tapped again it returns to light mode
And the button icon matches each theme mode

#### Scenario: Theme persistence verification
Given the app is loaded and theme is set to dark mode
When the app widget is reloaded (simulating restart)
Then the dark theme is restored from persistence
And the button icon reflects the dark mode state

#### Scenario: Visual theme changes
Given the app is loaded
When the theme is toggled between light and dark modes
Then UI elements such as calendar and dialogs reflect the current theme colors
And the theme toggle button icon matches the current theme mode

### Requirement: The application SHALL Test Cleanup and Isolation
Tests SHALL implement proper cleanup mechanisms to prevent state pollution and ensure test isolation:

- Helper utilities in `test/test_helpers.dart` for test environment setup and cleanup
- `tearDown()` methods to clean up created events after each test
- `tearDownAll()` methods to remove test directory after test suite completion
- No event files shall remain in `/tmp/test_docs/calendar/` after test execution
- Tests SHALL be isolated and produce deterministic results regardless of execution order

This ensures test reliability, prevents accumulated state interference, and maintains clean test hygiene.

#### Scenario: Test environment setup with clean state
Given a test file is being executed
When setupTestEnvironment() is called
Then test directory /tmp/test_docs/ is cleaned or created
And path_provider is mocked to return /tmp/test_docs
And flutter_secure_storage is mocked appropriately
And SharedPreferences is initialized with empty values

#### Scenario: Test directory cleanup after test suite
Given tests have created event files in /tmp/test_docs/calendar/
When tearDownAll() is called
Then entire /tmp/test_docs/ directory is removed recursively
And no event files remain on the filesystem
And subsequent test runs start with clean state

#### Scenario: Per-test event cleanup
Given a test creates events via EventProvider.addEvent()
When tearDown() is called
Then events created by that test are deleted
And test state is reset for next test
And no event files from previous test persist

#### Scenario: Test isolation across multiple runs
Given tests create event files during execution
When tests are run multiple times
Then no state pollution occurs between runs
And tests pass consistently regardless of order
And no event files accumulate over time

#### Scenario: Integration test cleanup
Given integration tests create events in real device environment
When integration tests complete
Then test directory is cleaned up
And no event files remain on device
And subsequent integration test runs are not affected

#### Scenario: Cleanup failure handling
Given cleanupTestEnvironment() is called
And test directory contains locked files or has permission errors
When cleanup fails
Then cleanup errors are logged for debugging
And test failures are not masked by cleanup errors
And tests continue to pass or fail based on their own assertions

### Requirement: The application SHALL Include Event CRUD Integration Tests

The application SHALL include integration tests in `integration_test/event_crud_integration_test.dart` for end-to-end event management workflows to verify complete user workflows for creating, editing, and deleting events through GUI, complementing existing unit tests in `test/event_provider_test.dart` (see also: `specs/event-management/spec.md`).

#### Scenario: Adding event via FAB button
Given the app is loaded and displaying the calendar
When the user taps the floating action button (FAB)
Then the event form dialog opens
And the form is empty with default values

#### Scenario: Filling and saving event form
Given the event form dialog is open
When the user enters a title "Team Meeting"
And the user selects a start date
And the user enters a start time "14:00"
And the user enters an end time "15:00"
And the user enters a description "Weekly sync"
And the user selects recurrence "weekly"
And the user taps "Save"
Then the event is saved to storage
And an event marker appears on the calendar date
And the event appears in the event list for that date
And the event persists after app restart

#### Scenario: Event appears in event list after creation
Given an event was created for today
When the user selects today on the calendar
Then the event is displayed in the event list below the calendar
And the event list shows the event title
And the event list shows the event time "14:00 - 15:00"
And the event list shows the description

#### Scenario: Form validation prevents invalid events
Given the event form dialog is open
And the title field is empty
When the user taps "Save"
Then an error message is displayed
And the event is not saved
And the form remains open

#### Scenario: Creating recurring daily event
Given the event form dialog is open
When the user creates an event with recurrence "daily"
Then the event is saved
And event markers appear on subsequent days in the calendar
And the event list shows the event for each day

#### Scenario: Creating recurring yearly event
Given the event form dialog is open
When the user creates an event on February 29th with recurrence "yearly"
Then the event is saved
And event markers appear on February 29th on leap years
And event markers appear on February 28th on non-leap years
And the event list shows the event for each year

#### Scenario: Creating multi-day event
Given the event form dialog is open
When the user creates an event with start date "2025-11-10"
And end date "2025-11-12"
Then the event is saved
And event markers appear on November 10th, 11th, and 12th
And the event list shows the event for each day in the range

### Requirement: The application SHALL Include Calendar Interactions Integration Tests

The application SHALL include integration tests in `integration_test/calendar_integration_test.dart` for calendar navigation, day selection, and visual feedback to verify complete user interactions with the calendar widget (see also: `specs/ui-calendar/spec.md`).

#### Scenario: Selecting calendar day
Given the app is loaded and displaying the calendar
When the user taps a calendar day
Then the selected day is highlighted with a circular decoration
And the event list is updated to show events for the selected day
And the EventProvider selectedDate is updated

#### Scenario: Navigating to previous month
Given the app is displaying the current month
When the user taps the previous month button
Then the calendar displays the previous month
And the focusedDay is updated to the previous month
And event markers are updated for the new month

#### Scenario: Navigating to next month
Given the app is displaying the current month
When the user taps the next month button
Then the calendar displays the next month
And the focusedDay is updated to the next month
And event markers are updated for the new month

#### Scenario: Event markers display on calendar
Given multiple events exist on different days
When the calendar is displayed
Then each day with an event shows a marker
And markers use the theme's secondary color
And markers appear as circular decorations

#### Scenario: Today is highlighted
Given today's date is visible on the calendar
When the calendar is displayed
Then today is highlighted with a distinct decoration
And today's decoration uses the theme's primary color with 30% opacity
And today's text is bold

#### Scenario: Selected day remains highlighted after navigation
Given a day is selected on the calendar
When the user navigates to a different month
And navigates back to the original month
Then the selected day is still highlighted
And the event list still shows events for the selected day

### Requirement: The application SHALL Include Event Form Dialog Integration Tests

The application SHALL include integration tests in `integration_test/event_form_integration_test.dart` for the event form dialog to verify form functionality, input handling, and validation (see also: `specs/event-management/spec.md`).

#### Scenario: All-day checkbox toggles time fields
Given the event form dialog is open
When the user taps the "All Day" checkbox
Then the start time field is hidden
And the end time field is hidden
And when the user unchecks "All Day"
Then the start time field becomes visible
And the end time field becomes visible

#### Scenario: Date picker for start date
Given the event form dialog is open
When the user taps the start date button
Then a date picker dialog opens
And when the user selects a date
Then the start date field displays the selected date

#### Scenario: Date picker for end date
Given the event form dialog is open
When the user taps the end date button
Then a date picker dialog opens
And when the user selects a date
Then the end date field displays the selected date
And if the selected end date is before the start date
Then the end date is automatically adjusted to the start date

#### Scenario: Time picker for start time
Given the event form dialog is open with "All Day" unchecked
When the user taps the start time button
Then a time picker dialog opens
And when the user selects a time
Then the start time field displays the selected time in HH:MM format

#### Scenario: Time picker for end time
Given the event form dialog is open with "All Day" unchecked
When the user taps the end time button
Then a time picker dialog opens
And when the user selects a time
Then the end time field displays the selected time in HH:MM format

#### Scenario: Recurrence dropdown selection
Given the event form dialog is open
When the user taps the recurrence dropdown
Then all options are displayed: none, daily, weekly, monthly, yearly
And when the user selects "weekly"
Then the recurrence field displays "weekly"

#### Scenario: Multi-line description input
Given the event form dialog is open
When the user enters a long description
Then the description field displays multiple lines
And the field is scrollable
And the description is saved correctly

#### Scenario: Cancel button closes form without saving
Given the event form dialog is open with filled fields
When the user taps "Cancel"
Then the form dialog closes
And the event is not saved
And no event marker appears on the calendar

#### Scenario: Form opens empty for new event
Given the app is loaded and displaying the calendar
When the user taps the FAB to add a new event
Then the event form dialog opens
And all fields are empty or have default values
And the title is "Add Event"

#### Scenario: Form opens with data for existing event
Given an event exists on the calendar
When the user opens the event details and taps "Edit"
Then the event form dialog opens
And all fields contain the event's current values
And the title is "Edit Event"

### Requirement: The application SHALL Include Event List Widget Integration Tests

The application SHALL include integration tests in `integration_test/event_list_integration_test.dart` for the event list widget to verify event display, interactions, and empty state handling (see also: `specs/event-management/spec.md`).

#### Scenario: Empty state shows when no events
Given the app is loaded
When the user selects a day with no events
Then the text "No events for this day" is displayed
And no event cards are shown

#### Scenario: Event card displays event details
Given an event exists for the selected day
When the event list is displayed
Then an event card is shown
And the card displays the event title
And the card displays the event time
And if a description exists, the card displays the description

#### Scenario: All-day event displays correctly
Given an all-day event exists for the selected day
When the event list is displayed
Then the event card shows "All day" instead of a specific time
And if an end date exists, the card shows the date range

#### Scenario: Multi-day event displays date range
Given a multi-day event exists spanning multiple days
When the user selects a day within the event range
Then the event card shows the start and end dates in MM/DD format

#### Scenario: Tapping event card opens details
Given an event card is displayed
When the user taps the event card
Then the event details dialog opens
And the dialog shows the event title
And the dialog shows the event date and time
And the dialog shows the event description
And if recurrence is set, the dialog shows the recurrence

#### Scenario: Delete button on event card
Given an event card is displayed
When the user taps the delete icon
Then a confirmation dialog appears with the message
And the confirmation dialog shows the event title
And the user can confirm or cancel the deletion

#### Scenario: Multiple events displayed in list
Given three events exist for the selected day
When the event list is displayed
Then three event cards are shown
And each card displays a different event
And events are ordered by time (chronological)

#### Scenario: Editing event from details dialog
Given the event details dialog is open
When the user taps "Edit"
Then the event details dialog closes
And the event form dialog opens with the event's current values
And the user can modify and save the event

#### Scenario: Event list updates after deletion
Given two events exist for the selected day
When the user deletes one event
Then the deleted event is removed from the list
And the remaining event is still displayed
And the event list shows only one event

### Requirement: The application SHALL Include Theme Integration Tests

The application SHALL include integration tests in `integration_test/calendar_integration_test.dart` to verify theme changes work correctly during user interactions and all widgets respond appropriately, extending existing unit tests in `test/theme_provider_test.dart` and `integration_test/app_integration_test.dart` (see also: `specs/theme-system/spec.md`).

#### Scenario: Theme toggle changes entire app theme
Given the app is loaded in light mode
When the user taps the theme toggle button
Then the app switches to dark mode
And all UI elements update to dark theme colors
And the theme toggle button icon changes to Icons.light_mode

#### Scenario: Theme toggle during event form open preserves form state
Given the event form dialog is open with filled fields
When the user taps the theme toggle button
Then the theme changes (light ↔ dark)
And the event form dialog colors update to match the new theme
And all form fields retain their values
And the form remains open and functional

#### Scenario: Theme toggle during event details open preserves details
Given the event details dialog is open
When the user taps the theme toggle button
Then the theme changes (light ↔ dark)
And the event details dialog colors update to match the new theme
And all event information remains displayed
And the dialog remains open and functional

#### Scenario: Calendar colors update on theme change
Given the calendar is displayed in light mode
When the user taps the theme toggle button
Then the theme changes to dark mode
And the calendar background color updates to the dark background
And the calendar text color updates to light text
And event marker colors update to the dark theme secondary color
And the selected day decoration updates to the dark theme primary color
And the today decoration updates to the dark theme primary color with opacity

#### Scenario: Event list colors update on theme change
Given the event list is displaying events in light mode
When the user taps the theme toggle button
Then the theme changes to dark mode
And the event list background color updates to the dark background
And the event card background colors update to the dark theme surface color
And the event card text colors update to light text
And all icons and buttons in the event list update colors

#### Scenario: Buttons and icons update on theme change
Given the app is displayed in light mode
When the user taps the theme toggle button
Then the theme changes to dark mode
And the sync button icon color updates to the dark theme on-surface color
And the FAB icon color updates to the dark theme on-primary color
And all other buttons update their colors appropriately
And all icons update their colors appropriately

#### Scenario: Theme persists across app restart
Given the app is in dark mode
When the app widget is reloaded (simulating restart)
Then the dark theme is restored
And all UI elements display in dark mode
And the theme toggle button shows Icons.light_mode icon

#### Scenario: System theme changes are detected
Given the app is in system theme mode
When the system theme changes from light to dark
Then the app switches to dark mode
And all UI elements update to dark theme colors
And the theme toggle button icon updates to Icons.light_mode

#### Scenario: Theme toggle cycles correctly
Given the app is in system theme mode
When the user taps the theme toggle button once
Then the app switches to light mode
And when the user taps the theme toggle button again
Then the app switches to dark mode
And when the user taps the theme toggle button third time
Then the app returns to system theme mode

### Requirement: The application SHALL Certificate Mocking Utilities
The application SHALL provide utility functions in `test/test_helpers.dart` for mocking the certificate MethodChannel in unit tests, enabling consistent and maintainable test setups:

- `setupCertificateMocks()` function to configure mock channel with test data
- `clearCertificateMocks()` function to remove mock handlers for test cleanup
- Optional parameters to return certificates, throw exceptions, or simulate various error conditions
- Documentation comments explaining usage and purpose

These utilities SHALL be used by certificate unit tests and SHALL have their own tests in `test/test_helpers_test.dart`.

#### Scenario: Setup certificate mocks for unit tests
Given a unit test needs to test CertificateService
When `setupCertificateMocks(certificates: testCerts)` is called
Then the `com.example.mcal/certificates` MethodChannel is mocked
And `getCACertificates` returns the provided test certificates
And CertificateService can be tested without platform dependencies

#### Scenario: Setup certificate mocks to simulate errors
Given a unit test needs to test error handling
When `setupCertificateMocks(error: testException)` is called
Then the `com.example.mcal/certificates` MethodChannel is mocked
And `getCACertificates` throws the provided test exception
And CertificateService error handling can be verified

#### Scenario: Clear certificate mocks after test
Given a unit test has configured certificate mocks
When `clearCertificateMocks()` is called in `tearDown()`
Then the mock handler for certificate channel is removed
And subsequent tests start with clean mock state
And no test state pollution occurs between tests

#### Scenario: Certificate mocking utilities are tested
Given the test helpers file is being tested
When tests for certificate mocking utilities run
Then `setupCertificateMocks()` is verified to configure channel correctly
Then `clearCertificateMocks()` is verified to remove mock handlers
Then utility functions themselves have >90% test coverage

### Requirement: The application SHALL Test Window Configuration
Integration tests SHALL configure test window size to ensure all UI elements (including AppBar action buttons) are visible and tappable during test execution:

- Tests SHALL use window size configuration helper `setupTestWindowSize()` in test setup
- Tests SHALL reset window size using `resetTestWindowSize()` in teardown
- Window size SHALL be set to 1200x800 pixels minimum to accommodate all AppBar elements
- Device pixel ratio SHALL be set to 1.0 for consistent sizing across platforms
- Window size configuration SHALL happen before `pumpWidget()` to take effect
- Tests SHALL NOT use `ensureVisible()` for AppBar elements (cannot scroll into viewport)

#### Scenario: Integration tests configure window size before widget pumping
Given a calendar integration test is executing
And test setup calls `setupTestWindowSize(tester)`
When `pumpWidget()` is called with MyApp widget
Then test window size is 1200x800 pixels
And device pixel ratio is 1.0
And all AppBar elements (SyncButton, ThemeToggleButton) are visible at layout time

#### Scenario: Integration tests reset window size after test execution
Given a calendar integration test has executed
And test teardown calls `resetTestWindowSize(tester)`
Then window size is reset to default values
And subsequent tests start with clean window state
And no test state pollution occurs between tests

#### Scenario: ThemeToggleButton is visible and tappable during tests
Given a test is executing with window size 1200x800
And AppBar is displayed with "MCal: Mobile Calendar" title + actions
When test layout is calculated after pumpWidget()
Then ThemeToggleButton is visible within viewport bounds
And ThemeToggleButton is not clipped at right edge
And ThemeToggleButton can be tapped by test framework
And tests can verify theme toggle functionality without skip flags

#### Scenario: Window size configuration works across platforms
Given an integration test is running on any platform (Linux, Android, iOS, macOS, Windows, Web)
And `setupTestWindowSize()` is called
Then window size is set to 1200x800 on all platforms
And device pixel ratio is 1.0 on all platforms
And test execution behavior is consistent across platforms
And UI elements are visible regardless of platform

#### Scenario: Window size configuration does not affect test isolation
Given multiple tests are executing in sequence
And each test calls `setupTestWindowSize()` and `resetTestWindowSize()`
Then each test has independent window state
And test execution does not depend on order
And no test pollutes window state for subsequent tests
And all tests execute consistently regardless of test file structure

#### Scenario: ensureVisible() is not used for AppBar elements
Given a test needs to interact with AppBar buttons
Then test SHALL NOT call `tester.ensureVisible(find.byType(ThemeToggleButton))`
Then test SHALL NOT call `tester.ensureVisible(find.byType(SyncButton))`
Then test SHALL rely on window size configuration for visibility
Then tests are not cluttered with ineffective workaround code

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

