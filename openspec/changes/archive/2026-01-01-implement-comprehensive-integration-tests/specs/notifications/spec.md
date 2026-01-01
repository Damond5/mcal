# ADDED|MODIFIED|REMOVED Requirements

## ADDED Requirements

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
