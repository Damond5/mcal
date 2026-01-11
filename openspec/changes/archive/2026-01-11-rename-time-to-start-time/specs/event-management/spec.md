## MODIFIED Requirements
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
