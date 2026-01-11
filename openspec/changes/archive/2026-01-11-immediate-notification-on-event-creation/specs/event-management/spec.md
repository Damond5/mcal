# event-management Specification Delta

## MODIFIED Requirements

### Requirement: The application SHALL support Event CRUD Operations
The application SHALL support creating, viewing, editing, and deleting events through GUI dialogs with full field editing. Additionally, when timed events are created or updated within their 30-minute notification window, or when all-day events are created or updated after midday the day before the event date, the application SHALL show an immediate notification at the moment of creation/update.

#### Scenario: Creating a new event
Given the user selects a calendar day and chooses to add an event  
When they complete the event form with all required fields  
Then the event is saved to a new Markdown file and appears on the calendar  
And if within notification window, an immediate notification is shown

#### Scenario: Creating a timed event within notification window
Given current time is 13:45  
When user creates a timed event for 14:00  
Then event is saved and appears on calendar  
And an immediate notification is shown for the event

#### Scenario: Creating an all-day event after standard notification time
Given current time is 13:00 on November 9th  
When user creates an all-day event for November 10th  
Then event is saved and appears on calendar  
And an immediate notification is shown for the event

#### Scenario: Editing an existing event
Given an existing event is selected for editing  
When the user modifies fields in the dialog  
Then the changes are saved to the corresponding Markdown file  
And if the updated event is now within notification window, an immediate notification is shown

#### Scenario: Deleting an event
Given an existing event is selected for deletion  
When the user confirms deletion  
Then the Markdown file is removed from storage  
And any pending notifications for the event are cancelled

#### Scenario: Event creation outside notification window
Given current time is 13:15  
When user creates a timed event for 14:00  
Then event is saved and appears on calendar  
And no immediate notification is shown (scheduled notification for 13:30)

### Requirement: The application SHALL Include Event CRUD Integration Tests
The application SHALL include integration tests in `integration_test/event_crud_integration_test.dart` to verify end-to-end event management workflows through GUI, complementing existing unit tests in `test/event_provider_test.dart`. Additionally, integration tests SHALL verify immediate notification behavior when events are created or updated within notification windows (see also: `specs/notifications/spec.md`).

#### Scenario: Adding event through complete form workflow
Given app is displaying calendar  
When user taps floating action button  
And user fills in event form with title, date, time, description, and recurrence  
And user taps Save  
Then event is saved to storage  
And an event marker appears on calendar date  
And event appears in event list for that date  
And event persists after app restart

#### Scenario: Adding event within notification window shows immediate notification
Given app is displaying calendar and notifications are enabled  
When user creates a timed event within 30 minutes of current time  
And user taps Save  
Then event is saved to storage  
And an event marker appears on calendar date  
And an immediate notification is displayed for the event

#### Scenario: Editing event through details dialog workflow
Given an event exists on calendar  
When user selects event date and taps event card  
And user taps Edit in event details dialog  
And user modifies event fields in form  
And user taps Save  
Then event is updated in storage  
And updated event appears on calendar  
And event list shows updated details  
And changes persist after app restart

#### Scenario: Editing event to be within notification window shows immediate notification
Given an event exists outside notification window  
When user edits event to start within 30 minutes  
And user taps Save  
Then event is updated in storage  
And an immediate notification is displayed for the updated event

#### Scenario: Deleting event through confirmation dialog workflow
Given an event exists on calendar  
When user selects event date and taps delete button on event card  
And user confirms deletion in confirmation dialog  
Then event is removed from storage  
And event marker disappears from calendar  
And event is removed from event list  
And deletion persists after app restart  
And no notifications appear for the deleted event

#### Scenario: Form validation prevents saving invalid events
Given event form dialog is open  
When user leaves title field empty  
And user taps Save  
Then an error message is displayed indicating title is required  
And event is not saved  
And form remains open for correction

#### Scenario: Recurring events display multiple calendar markers
Given a weekly recurring event is created starting on Monday  
When calendar displays current month  
Then event markers appear on Monday, Tuesday, Wednesday, Thursday, Friday  
And event list shows event for each day

#### Scenario: Multi-day events show markers on all days in range
Given a multi-day event from November 10th to November 12th is created  
When calendar displays November 2025  
Then event markers appear on November 10th, 11th, and 12th  
And event list shows event for each day in range

#### Scenario: Multiple events on same day all display
Given three events exist on same date with times 09:00, 14:00, and 18:00  
When user selects that date  
Then event list displays all three events  
And events are displayed in chronological order  
And each event shows its correct title, time, and description  
And each event can be independently edited or deleted

## Cross-Reference
- **Related Capability**: notifications spec - Immediate notification behavior
- **Related Capability**: testing spec - Integration test requirements
- **Related Platform**: android-workflow.md - Android notification specifics
- **Related Platform**: linux-workflow.md - Linux notification timer specifics