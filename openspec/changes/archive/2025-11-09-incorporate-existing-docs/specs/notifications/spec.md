## ADDED Requirements

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
On Linux, notifications SHALL use a periodic timer to check for upcoming events and show immediate notifications, as scheduled notifications may not persist when the app is closed.

#### Scenario: Linux notification handling
Given Linux platform
When app is running
Then timer checks for upcoming events and shows notifications

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