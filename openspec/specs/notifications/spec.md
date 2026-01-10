# notifications Specification

## Purpose
TBD - created by archiving change incorporate-existing-docs. Update Purpose after archive.
## Requirements
### Requirement: The application SHALL Local Notification Support
The application SHALL implement local notifications using flutter_local_notifications for cross-platform support (Android, iOS, Linux).

#### Scenario: Requesting permissions
Given app launch
When notifications are needed
Then permission is requested from the user

#### Scenario: Scheduling notifications
Given an upcoming event
When notification is scheduled
Then it appears at the specified time

### Requirement: The application SHALL Notification Timing
Notifications SHALL be sent 30 minutes before timed events and at midday the day before for all-day events, consistent with rcal daemon mode.

#### Scenario: Timed event notification
Given a timed event at 14:00
When current time reaches 13:30
Then a notification is shown

#### Scenario: All-day event notification
Given an all-day event on 2025-11-10
When current time is 12:00 on 2025-11-09
Then a notification is shown

### Requirement: The application SHALL Notification Management
A singleton NotificationService SHALL handle scheduling and unscheduling notifications, preventing duplicates by tracking IDs.

#### Scenario: Scheduling event notification
Given a new event is created
When notification is scheduled
Then it is tracked to prevent duplicates

#### Scenario: Unscheduling on event delete
Given an event is deleted
When notification exists
Then it is removed from the schedule

### Requirement: The application SHALL Platform-Specific Implementation
On Linux, notifications SHALL use a periodic timer to check for upcoming events and show immediate notifications, as scheduled notifications may not persist when the app is closed. On Android, notifications SHALL use WorkManager for reliable background delivery when the app is swiped from recents.

#### Scenario: Linux notification handling
Given Linux platform
When app is running
Then timer checks for upcoming events and shows notifications

#### Scenario: Android WorkManager scheduling
Given Android platform
When event notification is scheduled
Then WorkManager task is created with event data
And notification delivers reliably when app is not running

#### Scenario: Android WorkManager background delivery
Given Android device with scheduled notification
When app is swiped from recents
Then WorkManager executes in background
And notification appears at scheduled time

### Requirement: The application SHALL Timezone Handling
The application SHALL initialize timezone database for zoned scheduling.

#### Scenario: Timezone-aware scheduling
Given event in different timezone
When scheduling notification
Then correct local time is used for display

### Requirement: The application SHALL Integration with Event Provider
NotificationService SHALL integrate with EventProvider for automatic scheduling on event CRUD operations and loading existing events.

#### Scenario: Auto-schedule on event create
Given new event is saved
When provider notifies
Then notification is automatically scheduled

### Requirement: The application SHALL Include Notification Integration Tests

The application SHALL include integration tests in `integration_test/notification_integration_test.dart` to verify notification scheduling, display, and cancellation workflows, complementing existing unit tests in `test/notification_service_test.dart` (see also: `specs/testing/spec.md`).

#### Scenario: Timed event notification is scheduled
Given a timed event is created at 14:00
When event is saved
Then a notification is scheduled for 13:30 (30 minutes before event)
And notification is tracked to prevent duplicates

#### Scenario: Timed event notification displays correctly
Given a timed event is scheduled at 14:00 with a notification
When current time reaches 13:30
Then a notification is displayed (mocked)
And notification title contains event title
And notification body contains event details

#### Scenario: All-day event notification is scheduled
Given an all-day event is created for November 10th
When event is saved
Then a notification is scheduled for 12:00 on November 9th (midday day before)
And notification is tracked to prevent duplicates

#### Scenario: All-day event notification displays correctly
Given an all-day event is scheduled for November 10th with a notification
When current time is 12:00 on November 9th
Then a notification is displayed (mocked)
And notification title contains event title
And notification body indicates it's an all-day event

#### Scenario: Notification is cancelled on event deletion
Given an event has a scheduled notification
When event is deleted
Then notification is cancelled
And notification will not be displayed at its scheduled time

#### Scenario: Notification is rescheduled on event update
Given an event has a scheduled notification at 13:30
When event is updated to start at 15:00
Then original notification is cancelled
And a new notification is scheduled for 14:30
And notification will display at new time

#### Scenario: Multiple notifications can be scheduled
Given three timed events exist with different times
When events are loaded
Then three notifications are scheduled
And each notification is for a different event
And each notification will display at its scheduled time

#### Scenario: Notification cancellation respects event deletion
Given multiple events have scheduled notifications
When one event is deleted
Then only that event's notification is cancelled
And other event notifications remain scheduled
And other events will still notify at their scheduled times

#### Scenario: Notification can be shown immediately
Given an event exists
When notification service is triggered to show a notification immediately
Then a notification is displayed (mocked)
And notification contains correct event title
And notification contains correct event details

### Requirement: The application SHALL Calendar App Qualification
The application SHALL be recognized as a calendar app by Android for automatic SCHEDULE_EXACT_ALARM permission grant, using appropriate package naming and intent filters. (See: docs/platforms/android-workflow.md)

#### Scenario: Calendar intent filter
Given Android app installation
When system scans manifest
Then calendar intent filter enables calendar app recognition

#### Scenario: Calendar package naming
Given app package name
When SCHEDULE_EXACT_ALARM requested
Then calendar-appropriate naming enables auto-grant

### Requirement: The application SHALL Permission Denial Feedback
When notification permissions are denied, the application SHALL display user-friendly feedback explaining the impact and how to re-enable permissions.

#### Scenario: Permission denied SnackBar
Given notification permission request
When user denies permission
Then SnackBar appears with explanation and re-enable instructions</content>
<parameter name="filePath">openspec/changes/improve-android-notification-reliability/specs/notifications/spec.md

