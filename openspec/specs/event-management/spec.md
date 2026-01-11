# event-management Specification

## Purpose
TBD - created by archiving change incorporate-existing-docs. Update Purpose after archive.
## Requirements
### Requirement: The application SHALL store events as individual Markdown files per event (Time→Start Time rename + End Time field addition)
Events SHALL be stored as individual Markdown files per event in the app's calendar subdirectory within the documents directory, following rcal specification with fields: Date (YYYY-MM-DD or range), Time (renamed to Start Time: HH:MM or all-day), End Time (HH:MM, optional), Description, and Recurrence (none/daily/weekly/monthly).

**Changes documented:**
- **Field rename**: The original "Time" field is renamed to "Start Time" to support timed events with explicit end times
- **New field**: End Time field (HH:MM, optional) is added to document event end times alongside start times

#### Scenario: Storing a timed event
Given an event with title "Meeting", date "2025-11-09", start time "14:00", end time "15:00", description "Team meeting", recurrence "none"
When the event is saved
Then a Markdown file is created with the rcal format containing all fields including "- **Start Time**: 14:00 to 15:00"

#### Scenario: Storing an all-day event
Given an event with title "Holiday", date range "2025-11-09 to 2025-11-10", all-day true, description "Vacation", recurrence "none"
When the event is saved
Then a Markdown file is created with all-day indicator and date range
And the time field shows "- **Start Time**: all-day"

#### Scenario: Parsing events with old format for backward compatibility
Given an event file exists with the legacy "- **Time**: " field format
When the event is loaded
Then the application SHALL parse the event successfully
And log a deprecation warning about the old format
And future saves will use the new "- **Start Time**: " format

#### Scenario: Parsing events with new rcal format
Given an event file exists with the rcal-compliant "- **Start Time**: " field format
When the event is loaded
Then the application SHALL parse the event successfully
And the time values are correctly extracted

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

### Requirement: The application SHALL support Recurrence
Events SHALL support recurrence patterns: none, daily, weekly, monthly, yearly, with automatic expansion for display and interaction.

#### Scenario: Creating recurring event
Given an event with recurrence "weekly"
When saved
Then individual instances are expanded for calendar display up to 1 year ahead

#### Scenario: Creating yearly event
Given an event with recurrence "yearly"
When saved
Then individual instances are expanded for calendar display up to 1 year ahead

#### Scenario: Displaying recurring events
Given a recurring event on calendar view
When event day is selected
Then all expanded instances for that day are shown in the event list

### Requirement: The application SHALL manage Event Filenames
Event storage SHALL use sanitized titles as filenames with collision handling, storing actual filename in the Event model for correct operations.

#### Scenario: Handling similar titles
Given two events with similar titles like "Meeting" and "Meeting 2"
When saved
Then unique filenames are generated and stored in the model for accurate deletion

### Requirement: The application SHALL validate Event Input
Event creation/editing SHALL include validation for title sanitization, time order checks, and date ranges.

#### Scenario: Validating time order
Given start time "15:00" and end time "14:00"
When saving
Then an error is shown and save is prevented

#### Scenario: Sanitizing titles
Given a title with special characters
When saving
Then the title is sanitized for safe filename usage

### Requirement: The application SHALL handle February 29th in Yearly Recurrence
Yearly recurring events on February 29th SHALL fall back to February 28th on non-leap years to ensure annual occurrence.

#### Scenario: Feb 29th event on leap year
Given an event on February 29th, 2020 (leap year) with yearly recurrence
When expanding instances through 2024 (leap year)
Then instances include:
- Base event on 2020-02-29
- Instance on 2021-02-28 (fallback, non-leap year)
- Instance on 2022-02-28 (fallback, non-leap year)
- Instance on 2023-02-28 (fallback, non-leap year)
- Instance on 2024-02-29 (leap year, original date)

#### Scenario: Regular date with yearly recurrence
Given an event on December 25th with yearly recurrence
When expanding instances for 5 years
Then instances are generated for December 25th of each subsequent year

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

