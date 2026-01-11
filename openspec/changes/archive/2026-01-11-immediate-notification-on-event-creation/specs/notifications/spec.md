# notifications Specification Delta

## MODIFIED Requirements

### Requirement: The application SHALL handle Notification Timing
The application SHALL send notifications 30 minutes before timed events and at midday the day before for all-day events, consistent with rcal daemon mode. Additionally, when an event is created within its notification window (within 30 minutes for timed events, or anytime after midday the day before for all-day events), an immediate notification SHALL be shown at the moment of creation.

#### Scenario: Timed event notification
Given a timed event at 14:00  
When current time reaches 13:30  
Then a notification is shown

#### Scenario: Timed event immediate notification on creation
Given current time is 13:45  
When a timed event is created for 14:00  
Then an immediate notification is shown at creation time  
And a scheduled notification is planned for 13:30 (but filtered as past)

#### Scenario: All-day event notification  
Given an all-day event on 2025-11-10  
When current time is 12:00 on 2025-11-09  
Then a notification is shown

#### Scenario: All-day event immediate notification on creation after standard time
Given current time is 13:00 on 2025-11-09  
When an all-day event is created for 2025-11-10  
Then an immediate notification is shown at creation time  
And a scheduled notification is planned for 12:00 on 2025-11-09 (but filtered as past)

#### Scenario: Event created outside notification window
Given current time is 13:15  
When a timed event is created for 14:00  
Then no immediate notification is shown  
And a scheduled notification is planned for 13:30

#### Scenario: Event in the past
Given current time is 15:00  
When a timed event is created for 14:00 today  
Then no notification is shown (event already started)

#### Scenario: All-day event created before standard notification time
Given current time is 11:00 on 2025-11-09  
When an all-day event is created for 2025-11-10  
Then no immediate notification is shown  
And a scheduled notification is planned for 12:00 on 2025-11-09

#### Scenario: All-day event created after event has started
Given current time is 14:00 on 2025-11-10  
When an all-day event is created for 2025-11-10  
Then no notification is shown (event already in progress)

### Requirement: The application SHALL integrate with Event Provider
NotificationService SHALL integrate with EventProvider for automatic scheduling on event CRUD operations and loading existing events. Additionally, EventProvider SHALL check if newly created or updated events are within their notification windows and trigger immediate notifications when applicable.

#### Scenario: Auto-schedule on event create
Given new event is saved  
When provider notifies  
Then notification is automatically scheduled

#### Scenario: Immediate notification on event create within window
Given new timed event is created for 14:00 and current time is 13:45  
When event creation completes  
Then an immediate notification is shown for the event

#### Scenario: Immediate notification on event update within window  
Given an existing event is updated to start within 30 minutes  
When update completes  
Then an immediate notification is shown for the updated event

#### Scenario: No duplicate notifications
Given an event is created within notification window  
When notification is shown immediately  
Then no duplicate notification appears from scheduled system

### Requirement: The application SHALL handle Platform-Specific Implementation
On Linux, notifications SHALL use a periodic timer to check for upcoming events and show immediate notifications, as scheduled notifications may not persist when the app is closed. On Android and iOS, immediate notifications SHALL be shown when events are created within notification windows, using flutter_local_notifications show() method. On Android, notifications SHALL use WorkManager for reliable background delivery when the app is swiped from recents.

#### Scenario: Linux notification handling
Given Linux platform  
When app is running  
Then timer checks for upcoming events and shows notifications

#### Scenario: Mobile immediate notification on event creation
Given Android or iOS platform  
When an event is created within notification window  
Then immediate notification is shown using showNotification() method

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

## ADDED Requirements

### Requirement: The application SHALL provide Immediate Notification Capability
When an event is created or updated within its notification window, the application SHALL show an immediate notification at the moment of creation/update, in addition to scheduling regular notifications for future occurrences.

#### Scenario: Timed event immediate notification conditions
Given a timed event being created or updated  
When the current time is within 30 minutes before the event start time  
And the event has not yet started  
Then an immediate notification SHALL be shown

#### Scenario: All-day event immediate notification conditions  
Given an all-day event being created or updated
When the current time is after midday the day before the event date
And the event date has not yet passed
Then an immediate notification SHALL be shown

#### Scenario: Recurring event immediate notification
Given a recurring event is created  
When the first instance is within notification window  
Then an immediate notification SHALL be shown for the first instance  
And scheduled notifications SHALL be planned for all instances

#### Scenario: Notification content for immediate notifications
Given an immediate notification is triggered  
When notification is displayed  
Then notification title SHALL indicate "Upcoming Event" or "Upcoming All-Day Event"  
And notification body SHALL contain event title and time information

## Cross-Reference
- **Related Capability**: event-management spec - Event creation workflow
- **Related Capability**: testing spec - Integration test requirements
- **Related Platform**: android-workflow.md - Android notification specifics
- **Related Platform**: linux-workflow.md - Linux notification timer specifics