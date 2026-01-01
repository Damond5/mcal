# Tasks: Implement Comprehensive Integration Tests

## Phase 1: Infrastructure and Fixtures

- [ ] **Task 1.1**: Create integration test helper functions in `integration_test/helpers/test_fixtures.dart`
  - Create `TestFixtures` class with static methods for common test data
  - Implement `createSampleEvent({date, title})` fixture
  - Implement `createRecurringEvent({recurrence})` fixture
  - Implement `createAllDayEvent({date})` fixture
  - Implement `createMultiDayEvent({startDate, endDate})` fixture
  - Add helper functions for common widget interactions
  - Verify fixtures generate valid Event objects
  - **Validation**: Run existing unit tests to ensure no regressions

- [ ] **Task 1.2**: Expand `test/test_helpers.dart` with integration test helpers
  - Add `setupMockGitRepository()` function for Git operation mocking
  - Add `setupMockNotifications()` function for notification mocking
  - Add `setupMockCertificateService()` function for SSL certificate mocking
  - Add `cleanTestEvents()` function for cleaning up test events between tests
  - Document all new helper functions with clear usage examples
  - **Validation**: Verify helpers work by running a simple integration test

- [ ] **Task 1.3**: Create integration test file structure
  - Create `integration_test/helpers/` directory
  - Create `integration_test/event_crud_integration_test.dart`
  - Create `integration_test/calendar_integration_test.dart`
  - Create `integration_test/event_form_integration_test.dart`
  - Create `integration_test/event_list_integration_test.dart`
  - Create `integration_test/sync_integration_test.dart`
  - Create `integration_test/conflict_resolution_integration_test.dart`
  - Create `integration_test/sync_settings_integration_test.dart`
  - Create `integration_test/notification_integration_test.dart`
  - Create `integration_test/certificate_integration_test.dart`
  - Create `integration_test/lifecycle_integration_test.dart`
  - Create `integration_test/edge_cases_integration_test.dart`
  - Create `integration_test/performance_integration_test.dart`
  - Create `integration_test/accessibility_integration_test.dart`
  - Create `integration_test/gesture_integration_test.dart`
  - Create `integration_test/responsive_layout_integration_test.dart`
  - **Validation**: Verify all files are created and have basic test structure

## Phase 2: Event CRUD Integration Tests

- [ ] **Task 2.1**: Implement event creation integration tests
  - Test adding event via FAB button
  - Test filling event form with all fields (title, dates, times, description, recurrence)
  - Test saving event and verifying it appears on calendar
  - Test event marker appears on calendar day
  - Test event appears in event list for selected date
  - Test form validation prevents saving invalid events
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 6 scenarios pass

- [ ] **Task 2.2**: Implement event editing integration tests
  - Test tapping event in event list opens details dialog
  - Test tapping edit button in details opens form dialog
  - Test modifying event fields and saving
  - Test event updates appear on calendar
  - Test event updates appear in event list
  - Test form validation prevents saving invalid edits
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 6 scenarios pass

- [ ] **Task 2.3**: Implement event deletion integration tests
  - Test tapping delete button in event list
  - Test confirming deletion in confirmation dialog
  - Test event is removed from calendar
  - Test event is removed from event list
  - Test cancelling deletion keeps event
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 2.4**: Implement event validation integration tests
  - Test empty title shows error message
  - Test title with invalid characters shows error
  - Test end date before start date shows error
  - Test end time before start time shows error
  - Test missing start time for timed event shows error
  - Test validation passes for valid event data
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 6 scenarios pass

- [ ] **Task 2.5a**: Implement basic recurring event tests (daily, weekly, monthly)
  - Test creating daily recurring event
  - Test creating weekly recurring event
  - Test creating monthly recurring event
  - Test recurring events appear on multiple days on calendar
  - Test recurring events appear in event list for each day
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 2.5b**: Implement yearly recurring event tests
  - Test creating yearly recurring event
  - Test yearly events appear on multiple days on calendar
  - Test yearly events appear in event list for each year
  - Test yearly events handle Feb 29th correctly on leap years
  - Test yearly events fall back to Feb 28th on non-leap years
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 2.5c**: Implement recurring event marker display tests
  - Test recurring daily events show markers on all days in month
  - Test recurring weekly events show markers on appropriate days
  - Test recurring monthly events show markers on appropriate days
  - Test recurring yearly events show markers on same month across years
  - Test markers disappear when recurring event is deleted
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 2.6a**: Implement multi-day event creation tests
  - Test creating multi-day event with start and end dates
  - Test event markers appear on all days in range
  - Test event appears in event list for each day
  - Test creating multi-day event with all-day option
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 2.6b**: Implement multi-day event editing tests
  - Test editing multi-day event start date updates all markers
  - Test editing multi-day event end date updates all markers
  - Test editing multi-day event to single-day removes extra markers
  - Test editing multi-day event title preserves markers
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 2.6c**: Implement multi-day event deletion tests
  - Test deleting multi-day event removes all markers from calendar
  - Test deleting multi-day event removes from all event lists
  - Test deleting one instance of multi-day event deletes entire event
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 3 scenarios pass

## Phase 3: Calendar Interactions Integration Tests

- [ ] **Task 3.1**: Implement day selection integration tests
  - Test tapping calendar day updates selectedDate
  - Test event list updates for selected day
  - Test selected day is highlighted
  - Test switching between days updates event list
  - **Validation**: Run `flutter test integration_test/calendar_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 3.2**: Implement month navigation integration tests
  - Test tapping previous month button shows previous month
  - Test tapping next month button shows next month
  - Test focusedDay updates on navigation
  - Test event markers persist across month navigation
  - **Validation**: Run `flutter test integration_test/calendar_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 3.3**: Implement event marker integration tests
  - Test event marker appears on day with single event
  - Test event marker appears on day with multiple events
  - Test event marker disappears when event deleted
  - Test recurring events show markers on all days
  - Test multi-day events show markers on all days in range
  - **Validation**: Run `flutter test integration_test/calendar_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 3.4**: Implement calendar theme integration tests
  - Test calendar colors reflect light theme
  - Test calendar colors reflect dark theme
  - Test calendar updates when theme changes
  - Test calendar responds to system theme changes
  - **Validation**: Run `flutter test integration_test/calendar_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 3.5**: Implement calendar week number tests
  - Test week numbers display on left side of calendar
  - Test week numbers update color on theme change
  - Test week numbers are correctly calculated for each week
  - **Validation**: Run `flutter test integration_test/calendar_integration_test.dart` and verify all 3 scenarios pass

- [ ] **Task 3.6**: Implement today's date highlighting tests
  - Test today is highlighted with distinct decoration
  - Test today's decoration uses theme's primary color with opacity
  - Test today's text is bold
  - Test today can be selected independently
  - **Validation**: Run `flutter test integration_test/calendar_integration_test.dart` and verify all 4 scenarios pass

## Phase 4: Event Form Dialog Integration Tests

- [ ] **Task 4.1**: Implement all-day event form tests
  - Test all-day checkbox toggles time field visibility
  - Test all-day event saves without times
  - Test unchecking all-day shows time fields
  - Test switching between all-day and timed modes
  - **Validation**: Run `flutter test integration_test/event_form_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 4.2**: Implement date picker integration tests
  - Test start date picker opens on tap
  - Test selecting date updates start date field
  - Test end date picker opens on tap
  - Test selecting date updates end date field
  - Test end date automatically adjusted if before start date
  - **Validation**: Run `flutter test integration_test/event_form_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 4.3**: Implement time picker integration tests
  - Test start time picker opens on tap
  - Test selecting time updates start time field
  - Test end time picker opens on tap
  - Test selecting time updates end time field
  - Test time validation prevents invalid ranges
  - **Validation**: Run `flutter test integration_test/event_form_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 4.4**: Implement recurrence dropdown tests
  - Test dropdown shows all recurrence options
  - Test selecting recurrence updates form
  - Test default recurrence is "none"
  - Test all options are selectable
  - **Validation**: Run `flutter test integration_test/event_form_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 4.5**: Implement description field tests
  - Test multi-line description input
  - Test long description is scrollable
  - Test empty description is allowed
  - Test description is saved and displayed
  - **Validation**: Run `flutter test integration_test/event_form_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 4.6**: Implement form reset tests
  - Test opening form for new event shows empty fields
  - Test opening form for existing event shows event data
  - Test cancel button closes form without saving
  - Test form state is independent between open/close cycles
  - **Validation**: Run `flutter test integration_test/event_form_integration_test.dart` and verify all 4 scenarios pass

## Phase 5: Event List Widget Integration Tests

- [ ] **Task 5.1**: Implement empty state tests
  - Test "No events for this day" message when no events
  - Test empty state disappears when event is added
  - Test empty state reappears when all events deleted
  - **Validation**: Run `flutter test integration_test/event_list_integration_test.dart` and verify all 3 scenarios pass

- [ ] **Task 5.2**: Implement event card display tests
  - Test event card shows event title
  - Test event card shows event time (formatted)
  - Test event card shows event description (if present)
  - Test all-day events show "All day" time
  - Test multi-day events show date range
  - **Validation**: Run `flutter test integration_test/event_list_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 5.3**: Implement event details dialog tests
  - Test tapping event card opens details dialog
  - Test details dialog shows event title
  - Test details dialog shows event date and time
  - Test details dialog shows event description
  - Test details dialog shows recurrence (if set)
  - **Validation**: Run `flutter test integration_test/event_list_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 5.4**: Implement event delete action tests
  - Test delete button appears on event card
  - Test tapping delete shows confirmation dialog
  - Test confirming delete removes event
  - Test cancelling delete keeps event
  - **Validation**: Run `flutter test integration_test/event_list_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 5.5**: Implement multiple events tests
  - Test event list shows multiple events for same day
  - Test events are ordered by time (chronological)
  - Test deleting one event doesn't affect others
  - Test editing one event doesn't affect others
  - **Validation**: Run `flutter test integration_test/event_list_integration_test.dart` and verify all 4 scenarios pass

## Phase 6: Sync Functionality Integration Tests

- [ ] **Task 6.1**: Implement sync initialization tests
  - Test opening sync menu and selecting "Init Sync"
  - Test entering HTTPS URL with credentials
  - Test entering SSH URL without credentials
  - Test successful initialization shows success message
  - Test initialization failure shows error message
  - Test sync status shows "initialized" after successful init
  - **Validation**: Run `flutter test integration_test/sync_integration_test.dart` and verify all 6 scenarios pass

- [ ] **Task 6.2**: Implement pull sync tests
  - Test opening sync menu and selecting "Pull"
  - Test successful pull reloads events
  - Test pull success message shows event count
  - Test pull failure shows error message
  - Test loading indicator appears during pull
  - **Validation**: Run `flutter test integration_test/sync_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 6.3**: Implement push sync tests
  - Test opening sync menu and selecting "Push"
  - Test successful push shows success message
  - Test push success after adding event
  - Test push success after editing event
  - Test push success after deleting event
  - Test push failure shows error message
  - Test loading indicator appears during push
  - **Validation**: Run `flutter test integration_test/sync_integration_test.dart` and verify all 6 scenarios pass

- [ ] **Task 6.4**: Implement sync status tests
  - Test opening sync menu and selecting "Status"
  - Test status dialog shows current status
  - Test status "clean" when no changes
  - Test status "modified" when there are changes
  - Test status "not initialized" when not configured
  - **Validation**: Run `flutter test integration_test/sync_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 6.5**: Implement credential update tests
  - Test opening sync menu and selecting "Update Credentials"
  - Test entering new username and password
  - Test saving credentials shows success message
  - Test validation requires both username and password
  - Test clear username and password works
  - **Validation**: Run `flutter test integration_test/sync_integration_test.dart` and verify all 5 scenarios pass

## Phase 7: Conflict Resolution Integration Tests

- [ ] **Task 7.1**: Implement conflict dialog display tests
  - Test conflict dialog appears on merge conflict
  - Test dialog shows conflict message
  - Test dialog shows "Cancel", "Keep Local", "Use Remote" buttons
  - Test dialog is not dismissible by tapping outside
  - **Validation**: Run `flutter test integration_test/conflict_resolution_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 7.2**: Implement keep local resolution tests
  - Test selecting "Keep Local" aborts merge
  - Test success message shows "kept local changes"
  - Test local events remain unchanged
  - Test sync button can be used again
  - **Validation**: Run `flutter test integration_test/conflict_resolution_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 7.3**: Implement use remote resolution tests
  - Test selecting "Use Remote" prefers remote changes
  - Test success message shows "pulled successfully"
  - Test remote events are loaded
  - Test sync button can be used again
  - **Validation**: Run `flutter test integration_test/conflict_resolution_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 7.4**: Implement cancel resolution tests
  - Test selecting "Cancel" closes dialog
  - Test merge conflict is not resolved
  - Test app remains in sync error state
  - Test conflict resolution can be attempted again
  - **Validation**: Run `flutter test integration_test/conflict_resolution_integration_test.dart` and verify all 4 scenarios pass

## Phase 8: Sync Settings Integration Tests

- [ ] **Task 8.1**: Implement auto sync toggle tests
  - Test opening sync settings dialog
  - Test toggling auto sync switch
  - Test saving settings persists auto sync preference
  - Test workmanager is registered when enabled (mocked)
  - Test workmanager is cancelled when disabled (mocked)
  - **Validation**: Run `flutter test integration_test/sync_settings_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 8.2**: Implement resume sync toggle tests
  - Test toggling resume sync switch
  - Test saving settings persists resume sync preference
  - Test auto-pull on app resume when enabled
  - Test no auto-pull on app resume when disabled
  - **Validation**: Run `flutter test integration_test/sync_settings_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 8.3**: Implement sync frequency tests
  - Test frequency slider shows current value
  - Test sliding slider updates frequency label
  - Test minimum frequency is 5 minutes
  - Test maximum frequency is 60 minutes
  - Test saving settings persists frequency preference
  - **Validation**: Run `flutter test integration_test/sync_settings_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 8.4**: Implement sync settings save and cancel tests
  - Test saving modified settings persists all changes
  - Test cancelling modified settings does not persist
  - Test settings take effect immediately after save
  - Test original settings remain after cancel
  - **Validation**: Run `flutter test integration_test/sync_settings_integration_test.dart` and verify all 4 scenarios pass

## Phase 9: Notification Integration Tests

- [ ] **Task 9.1**: Implement timed event notification tests
  - Test notification is scheduled for timed event 30 minutes before
  - Test notification appears at correct time (mocked)
  - Test notification shows event title
  - Test notification is cancelled when event deleted
  - Test notification is rescheduled when event time changed
  - **Validation**: Run `flutter test integration_test/notification_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 9.2**: Implement all-day event notification tests
  - Test notification is scheduled for all-day event at midday before
  - Test notification appears at correct time (mocked)
  - Test notification shows event title
  - Test notification is cancelled when event deleted
  - **Validation**: Run `flutter test integration_test/notification_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 9.3**: Implement notification display tests
  - Test notification can be shown immediately
  - Test notification title is correct
  - Test notification body is correct
  - Test multiple notifications can be shown
  - **Validation**: Run `flutter test integration_test/notification_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 9.4**: Implement notification cancellation tests
  - Test notifications are cancelled on event delete
  - Test notifications are cancelled on event update
  - Test all notifications for event are cancelled
  - Test notification cancellation respects event deletion among multiple events
  - **Validation**: Run `flutter test integration_test/notification_integration_test.dart` and verify all 4 scenarios pass

## Phase 10: Certificate Service Integration Tests

- [ ] **Task 10.1**: Implement certificate loading tests
  - Test SSL certificates are loaded during sync initialization
  - Test certificate loading uses platform-appropriate method
  - Test certificate loading failure is handled gracefully
  - Test app falls back to default SSL behavior on certificate read failure
  - **Validation**: Run `flutter test integration_test/certificate_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 10.2**: Implement certificate validation tests
  - Test certificates are configured in Rust git2 backend
  - Test HTTPS operations use configured certificates
  - Test custom CA certificates validate server certificates
  - Test certificate errors are logged for debugging
  - **Validation**: Run `flutter test integration_test/certificate_integration_test.dart` and verify all 4 scenarios pass

## Phase 11: App Lifecycle Integration Tests

- [ ] **Task 11.1**: Implement auto sync on start tests
  - Test sync pulls on app start if initialized
  - Test no sync pull if not initialized
  - Test sync pulls if resume sync is enabled
  - Test no sync pull if resume sync is disabled
  - Test loading indicator shows during auto sync
  - **Validation**: Run `flutter test integration_test/lifecycle_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 11.2**: Implement auto sync on resume tests
  - Test sync pulls on app resume if initialized
  - Test sync only pulls if 5+ minutes since last sync
  - Test no sync pull if not initialized
  - Test no sync pull if resume sync is disabled
  - **Validation**: Run `flutter test integration_test/lifecycle_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 11.3**: Implement data persistence tests
  - Test events persist after app "restart" (re-pumpWidget)
  - Test all event details persist (title, dates, times, description, recurrence)
  - Test sync settings persist after app "restart"
  - Test theme settings persist after app "restart"
  - Test persisted data is correct on reload
  - **Validation**: Run `flutter test integration_test/lifecycle_integration_test.dart` and verify all 5 scenarios pass

## Phase 12: Edge Cases and Error Handling Integration Tests

- [ ] **Task 12.1**: Implement empty repository tests
  - Test app handles empty git repository on start
  - Test pull from empty repository works
  - Test push to empty repository works
  - **Validation**: Run `flutter test integration_test/edge_cases_integration_test.dart` and verify all 3 scenarios pass

- [ ] **Task 12.2**: Implement network error tests
  - Test sync failure shows user-friendly error message
  - Test app remains functional after sync error
  - Test retry after network error works
  - **Validation**: Run `flutter test integration_test/edge_cases_integration_test.dart` and verify all 3 scenarios pass

- [ ] **Task 12.3**: Implement invalid credentials tests
  - Test sync with invalid username/password fails
  - Test error message indicates authentication failure
  - Test app remains functional after auth error
  - Test updating to correct credentials works
  - **Validation**: Run `flutter test integration_test/edge_cases_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 12.4**: Implement file system error tests
  - Test app handles missing event directory
  - Test app creates directory if missing
  - Test app handles permission errors gracefully
  - **Validation**: Run `flutter test integration_test/edge_cases_integration_test.dart` and verify all 3 scenarios pass

- [ ] **Task 12.5**: Implement corrupted data tests
  - Test app handles corrupted event file
  - Test app skips corrupted events on load
  - Test app continues to work with remaining events
  - **Validation**: Run `flutter test integration_test/edge_cases_integration_test.dart` and verify all 3 scenarios pass

## Phase 13: Multi-Event Scenarios Integration Tests

- [ ] **Task 13.1**: Implement multiple events same day tests
  - Test calendar shows marker for day with multiple events
  - Test event list shows all events for day
  - Test events are in correct order
  - Test each event can be edited independently
  - Test each event can be deleted independently
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 5 scenarios pass

- [ ] **Task 13.2**: Implement overlapping events tests
  - Test events with same time display correctly
  - Test event list shows overlapping events
  - Test each overlapping event can be edited
  - Test each overlapping event can be deleted
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 13.3a**: Implement many recurring events creation tests
  - Test yearly recurring events over many years
  - Test calendar handles many recurring events
  - Test event list handles many recurring instances
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 3 scenarios pass

- [ ] **Task 13.3b**: Implement many recurring events performance tests
  - Test yearly events over 50 years load in reasonable time
  - Test calendar displays many yearly event instances
  - Test performance doesn't degrade with long chains
  - Test each test file runs in under 30 seconds
  - **Validation**: Run `flutter test integration_test/event_crud_integration_test.dart` and verify all 4 scenarios pass within time budget

## Phase 14: Theme Integration Tests

- [ ] **Task 14.1**: Implement theme change during interaction tests
  - Test theme toggle works while event form is open
  - Test theme toggle works while event details are open
  - Test theme toggle works while sync settings are open
  - Test dialogs update colors on theme change
  - **Validation**: Run `flutter test integration_test/calendar_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 14.2**: Implement widget theme response tests
  - Test calendar colors update on theme change
  - Test event list colors update on theme change
  - Test buttons and icons update on theme change
  - Test all widgets respond consistently to theme
  - **Validation**: Run `flutter test integration_test/calendar_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 14.3**: Implement system theme response tests
  - Test app responds to system theme changes (mocked)
  - Test theme provider detects system theme
  - Test theme button shows correct icon for system theme
  - **Validation**: Run `flutter test integration_test/calendar_integration_test.dart` and verify all 3 scenarios pass

## Phase 15: Performance and Load Testing Integration Tests

- [ ] **Task 15.1a**: Implement large event set creation tests
  - Test adding 100 events completes in reasonable time (<5s)
  - Test events are properly saved
  - Test all events appear on calendar
  - **Validation**: Run `flutter test integration_test/performance_integration_test.dart` and verify all 3 scenarios pass within time budget

- [ ] **Task 15.1b**: Implement large event set loading tests
  - Test loading 100 events completes in reasonable time (<5s)
  - Test app remains responsive with 100 events
  - Test each test file runs in under 30 seconds
  - **Validation**: Run `flutter test integration_test/performance_integration_test.dart` and verify all 3 scenarios pass within time budget

- [ ] **Task 15.1c**: Implement large event set rendering tests
  - Test calendar renders smoothly with many event markers
  - Test event list scrolls smoothly with many events
  - Test UI remains responsive with many events
  - **Validation**: Run `flutter test integration_test/performance_integration_test.dart` and verify all 3 scenarios pass within time budget

- [ ] **Task 15.2**: Implement rapid operation tests
  - Test rapid add/edit/delete operations don't crash
  - Test rapid theme toggles don't crash
  - Test rapid calendar navigation doesn't crash
  - Test state remains consistent after rapid operations
  - **Validation**: Run `flutter test integration_test/performance_integration_test.dart` and verify all 4 scenarios pass

## Phase 16: Accessibility Integration Tests

- [ ] **Task 16.1**: Implement accessibility label tests
  - Test calendar days have accessibility labels
  - Test event cards have accessibility labels
  - Test buttons have accessibility labels
  - Test form fields have accessibility labels
  - Use semantic finders where possible (e.g., `find.bySemanticsLabel('Save button')`)
  - **Validation**: Run `flutter test integration_test/accessibility_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 16.2**: Implement keyboard navigation tests
  - Test tab navigation works through app
  - Test enter key activates buttons
  - Test escape key cancels dialogs
  - Test focus order is logical
  - **Validation**: Run `flutter test integration_test/accessibility_integration_test.dart` and verify all 4 scenarios pass

- [ ] **Task 16.3**: Implement touch target tests
  - Test all buttons meet minimum touch target size (48x48px)
  - Test all tappable areas are large enough
  - Test no overlapping touch targets
  - **Validation**: Run `flutter test integration_test/accessibility_integration_test.dart` and verify all 3 scenarios pass

## Phase 17: Gesture Integration Tests

- [ ] **Task 17.1**: Implement long-press interaction tests
  - Test long-press on calendar day shows context menu (if applicable)
  - Test long-press on event card shows options (if applicable)
  - Test long-press gestures are recognized
  - **Validation**: Run `flutter test integration_test/gesture_integration_test.dart` and verify all 3 scenarios pass

- [ ] **Task 17.2**: Implement drag interaction tests
  - Test calendar month swipe gesture works
  - Test event list scroll gesture works
  - Test form scroll gesture works
  - **Validation**: Run `flutter test integration_test/gesture_integration_test.dart` and verify all 3 scenarios pass

## Phase 18: Responsive Layout Integration Tests

- [ ] **Task 18.1**: Implement screen orientation tests
  - Test calendar displays correctly in portrait mode
  - Test calendar displays correctly in landscape mode
  - Test event list adapts to orientation changes
  - **Validation**: Run `flutter test integration_test/responsive_layout_integration_test.dart` and verify all 3 scenarios pass

- [ ] **Task 18.2**: Implement different screen size tests
  - Test calendar displays correctly on small screens
  - Test calendar displays correctly on large screens
  - Test dialogs adapt to different screen sizes
  - **Validation**: Run `flutter test integration_test/responsive_layout_integration_test.dart` and verify all 3 scenarios pass

## Phase 19: Platform Testing Strategy

- [ ] **Task 19.1**: Document Linux-only testing justification
  - Document that integration tests target Linux as primary development platform
  - Justify that core functionality is platform-independent
  - Note that platform-specific behaviors (Android back button, iOS navigation) rely on manual testing
  - Document which platform-specific features are excluded from automated testing
  - **Validation**: Review documentation for clarity and completeness

- [ ] **Task 19.2**: Verify cross-platform manual testing checklist
  - Create checklist of platform-specific features to test manually
  - Include Android-specific behaviors (back button, permissions)
  - Include iOS-specific behaviors (navigation bar, permissions)
  - Include platform-specific notification behaviors
  - **Validation**: Review checklist for completeness and accuracy

## Phase 20: Organization and Documentation

- [ ] **Task 20.1**: Update existing integration test file
  - Move existing theme tests from `app_integration_test.dart` to `calendar_integration_test.dart`
  - Ensure all tests still pass after migration
  - Remove `app_integration_test.dart` if empty
  - **Validation**: Run `flutter test integration_test/` and verify all tests pass

- [ ] **Task 20.2**: Update test documentation in README.md
  - Document all new integration test files in README.md
  - Add instructions for running specific test files
  - Document test fixtures and helpers
  - Update test coverage information
  - Document Linux-only testing justification
  - Add platform-specific manual testing checklist reference
  - **Validation**: Verify README.md is accurate and complete

- [ ] **Task 20.3**: Update TODO.md
  - Mark completed integration test tasks as done
  - Update TODO.md to reflect completion status
  - **Validation**: Verify TODO.md is accurate

- [ ] **Task 20.4**: Run full test suite
  - Run all unit tests: `flutter test`
  - Run all integration tests: `flutter test integration_test/`
  - Verify all tests pass
  - Check total test execution time is under 8 minutes (with time budget tests)
  - **Validation**: All tests pass, execution time acceptable

- [ ] **Task 20.5**: Verify test coverage
  - Run tests with coverage: `flutter test --coverage`
  - Check coverage report for critical paths
  - Verify coverage has increased by at least 30%
  - Document coverage metrics in README.md
  - **Validation**: Coverage meets target, documented in README

- [ ] **Task 20.6**: Code review implementation
  - Use @code-review subagent to review all integration test files
  - Implement all code review suggestions
  - Ensure code quality and best practices are followed
  - **Validation**: Run full test suite again after code review changes

## Dependencies

- Phase 1 must be completed before all other phases
- Phases 2-7 can be completed in parallel by different developers
- Phases 8-10 can be completed in parallel after Phase 7
- Phases 11-18 can be completed in parallel after Phase 10
- Phase 19 can be completed in parallel with Phases 11-18
- Phase 20 must be completed after all other phases

## Estimated Timeline

- Phase 1: 2-3 hours
- Phases 2-7: 10-14 hours total (parallelizable)
- Phases 8-10: 6-8 hours total (parallelizable after Phase 7)
- Phases 11-18: 12-16 hours total (parallelizable after Phase 10)
- Phase 19: 1-2 hours (can be done in parallel)
- Phase 20: 3-4 hours

**Total Estimated Time**: 34-47 hours (revised to account for debugging, fixture refinement, and test failures)

## Notes

- Each task should be verified individually before moving to next task
- Tests should be added incrementally, running after each addition
- Test helpers and fixtures should be reused across test files
- All tests must properly clean up after themselves
- Tests should be independent and not rely on execution order
- Mock behavior should be documented in test helpers
- Each test file should run in under 30 seconds to maintain overall test suite performance
- Linux is the primary platform for integration tests; platform-specific features rely on manual testing
- Test fixtures should have clear, single purposes to avoid over-parameterization
- Prefer semantic finders (e.g., `find.bySemanticsLabel`) over implementation-specific finders
