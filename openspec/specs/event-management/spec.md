# event-management Specification

## Purpose
TBD - created by archiving change incorporate-existing-docs. Update Purpose after archive.
## Requirements
### Requirement: The application SHALL store events as individual Markdown files per event
Events SHALL be stored as individual Markdown files per event in the app's calendar subdirectory within the documents directory, following rcal specification with fields: Date (YYYY-MM-DD or range), Time (HH:MM or all-day), Description, and Recurrence (none/daily/weekly/monthly).

#### Scenario: Storing a timed event
Given an event with title "Meeting", date "2025-11-09", start time "14:00", end time "15:00", description "Team meeting", recurrence "none"
When the event is saved
Then a Markdown file is created with the rcal format containing all fields

#### Scenario: Storing an all-day event
Given an event with title "Holiday", date range "2025-11-09 to 2025-11-10", all-day true, description "Vacation", recurrence "none"
When the event is saved
Then a Markdown file is created with all-day indicator and date range

### Requirement: The application SHALL support Event CRUD Operations
The application SHALL support creating, viewing, editing, and deleting events through GUI dialogs with full field editing.

#### Scenario: Creating a new event
Given the user selects a calendar day and chooses to add an event
When they complete the event form with all required fields
Then the event is saved to a new Markdown file and appears on the calendar

#### Scenario: Editing an existing event
Given an existing event is selected for editing
When the user modifies fields in the dialog
Then the changes are saved to the corresponding Markdown file

#### Scenario: Deleting an event
Given an existing event is selected for deletion
When the user confirms deletion
Then the Markdown file is removed from storage

### Requirement: The application SHALL support Recurrence
Events SHALL support recurrence patterns: none, daily, weekly, monthly, with automatic expansion for display and interaction.

#### Scenario: Creating recurring event
Given an event with recurrence "weekly"
When saved
Then individual instances are expanded for calendar display up to 1 year ahead

#### Scenario: Displaying recurring events
Given a recurring event on calendar view
When the event day is selected
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

