# TODO

## Integration Test Enhancements

### Event CRUD Operations
- Test adding events via FAB, filling form, saving, and verifying event appears on calendar
- Test editing existing events through the event list tap → details → edit flow
- Test deleting events through the confirmation dialog
- Test form validation errors (empty title, invalid dates, invalid times)

### Calendar Interactions
- Test tapping dates, updating selectedDate state, event list updates
- Test previous/next month navigation, focusedDay updates
- Test visual markers on calendar days with events
- Test event date highlighting (today decoration, selected day decoration)

### Event Form Dialog
- Test toggling all-day checkbox, time field visibility
- Test date picker for start/end dates
- Test time picker for start/end times
- Test dropdown for recurrence options
- Test multi-line description input
- Test form state when opening for new vs existing events
- Test form reset behavior

### Event List Widget
- Test empty state ("No events for this day" message)
- Test event cards with title, time, description
- Test opening event details dialog via tap
- Test delete button and confirmation flow
- Test list display with multiple events for same day

### Sync Functionality
- Test sync initialization with URL and credentials
- Test pulling from remote and event reload
- Test pushing local changes
- Test sync status display
- Test credential update flow
- Perform end-to-end tests with actual Git repos (initialized and uninitialized) to ensure sync operations (init, pull, push, status) handle all edge cases

### Conflict Resolution
- Test conflict resolution dialog display
- Test aborting merge and keeping local changes
- Test preferring remote changes and retrying pull
- Test sync error scenarios

### Sync Settings Dialog
- Test enabling/disabling auto-sync
- Test enabling/disabling resume sync
- Test adjusting sync frequency slider (5-60 min)
- Test saving and loading sync settings

### Notification Integration
- Test notification scheduling for timed events
- Test notification scheduling for all-day events
- Test showing notifications (with proper mocking)
- Test cancelling notifications when events are deleted/updated

### App Lifecycle
- Test auto-sync on app resume
- Test auto-sync on app start
- Test background sync service (platform-specific)

### Data Persistence
- Test saving events and reloading after app restart
- Test sync/settings persistence across sessions
- Test theme persistence across app restarts (expand edge cases)

### Edge Cases & Error Handling
- Test handling of empty git repositories
- Test sync failure with network errors
- Test handling of invalid credentials
- Test file system permission errors
- Test handling of corrupted event files

### Multi-Event Scenarios
- Test calendar display with multiple events
- Test recurring event expansion in UI
- Test display of overlapping events
- Test multi-day events spanning multiple dates

### Theme Integration
- Test theme toggle with open dialogs
- Test calendar, events, dialogs respond to theme changes
- Test response to system theme changes

### Performance & Load Testing
- Test performance with hundreds of events
- Test rapid add/edit/delete operations
- Test handling of yearly events over many years

### Accessibility
- Test widget accessibility labels for screen readers
- Test keyboard navigation through app
- Test minimum touch target sizes

## Test Structure Improvements
- Organize integration tests into multiple files:
  - `integration_test/event_crud_integration_test.dart`
  - `integration_test/sync_integration_test.dart`
  - `integration_test/notifications_integration_test.dart`
  - `integration_test/theme_integration_test.dart`
  - `integration_test/app_lifecycle_integration_test.dart`
- Create reusable test data fixtures for common scenarios

## Other Tasks
- Integration Testing: Perform end-to-end tests with actual Git repos (initialized and uninitialized) to ensure sync operations (init, pull, push, status) handle all edge cases
- Android specific integration tests
- Potential Enhancements: If needed, add features like improved error messaging for sync failures or support for additional Git auth methods
- Deployment Verification: Build for production (e.g., APK, Linux desktop) to confirm Rust linking works across platforms
