## ADDED Requirements

### Requirement: Event.getAllEventDates() must return all event dates regardless of their end date

The `Event.getAllEventDates()` method must return dates for all events without filtering out events that have already ended, ensuring users can view historical event data and tests can validate past events.

#### Scenario: Method returns dates for events that ended in the past

- **WHEN** `getAllEventDates()` is called for a date range that includes dates in the past (e.g., 2024)
- **THEN** the method returns dates from events whose `endDate` is before the current date (`DateTime.now()`)
- **AND** the method does not skip events based on whether their `endDate` is in the past
- **AND** the method correctly generates recurrence dates for past events within the requested range

#### Scenario: Method returns dates for events that end in the future

- **WHEN** `getAllEventDates()` is called for a date range that includes future dates
- **THEN** the method returns dates from events whose `endDate` is after the current date
- **AND** the method correctly generates recurrence dates for future events within the requested range

#### Scenario: Method returns dates for events spanning across the current date

- **WHEN** `getAllEventDates()` is called for events that started before and end after the current date
- **THEN** the method returns all relevant dates for such events within the requested range
- **AND** the method does not exclude these events based on the early termination check

### Requirement: Date range filtering via endDate parameter must remain functional

The existing `endDate` parameter for forward-looking optimizations must continue to function as intended, allowing callers to limit the returned dates to a specific range.

- **WHEN** `getAllEventDates()` is called with an `endDate` parameter
- **THEN** the method only returns dates that fall on or before the specified `endDate`
- **AND** the method does not return dates beyond the specified `endDate`
- **AND** the method is optimized to avoid unnecessary computation beyond the specified range

#### Scenario: Filtering events by endDate parameter

- **WHEN** a caller requests event dates with `endDate` set to a specific date
- **THEN** only events and their dates that occur on or before that date are returned
- **AND** events ending after the specified `endDate` are correctly filtered out
- **AND** this filtering operates independently of the event's inherent `endDate` property

### Requirement: Event.occursOnDate() behavior must remain consistent

The `Event.occursOnDate()` method already correctly handles past events and must continue to do so, maintaining consistency across the codebase.

- **WHEN** `occursOnDate()` is called with a date in the past
- **THEN** the method correctly determines whether the event occurs on that date
- **AND** the method does not exclude events based on whether they have ended

#### Scenario: Consistent past event handling

- **WHEN** checking if a past event occurs on a past date
- **THEN** `occursOnDate()` returns the correct result
- **AND** this behavior matches the expected behavior of `getAllEventDates()` after the fix

### Requirement: Event storage and retrieval must support historical data

Events are stored as individual Markdown files in the application's documents directory, and the system must correctly handle retrieval of historical event data.

- **WHEN** events are stored as Markdown files in the documents directory
- **THEN** the file format includes `startDate`, `endDate`, and recurrence information
- **AND** events from any time period (past, present, future) can be retrieved correctly
- **AND** the storage format supports events that have already ended

#### Scenario: Storing events with recurrence rules

- **WHEN** a recurring event is created and stored
- **THEN** the Markdown file contains the original event details including recurrence rules
- **AND** the `getAllEventDates()` method correctly generates all occurrence dates regardless of the event's end date
- **AND** past occurrences can be retrieved and displayed

### Requirement: Calendar display must support historical event viewing

The calendar UI component (using table_calendar library) must be able to display events from any time period, including dates in the past.

- **WHEN** the calendar view is navigated to a past month or year
- **THEN** all events (including past events) are displayed correctly
- **AND** users can scroll back to view historical event data
- **AND** event markers and indicators appear for all past events within the visible range

#### Scenario: Viewing past events on calendar

- **WHEN** a user navigates to a date in 2024 (past)
- **THEN** events from 2024 are visible on the calendar
- **AND** recurring events that ended in 2024 show their occurrences
- **AND** the user can interact with past events normally

### Requirement: Test suite must validate past event functionality

The test suite must include coverage for past event scenarios to prevent regression of the bug fix.

- **WHEN** the test suite runs
- **THEN** tests for `getAllEventDates()` include scenarios with past events
- **AND** tests verify that events ending before the current date are correctly included
- **AND** all tests pass successfully including historical date scenarios

#### Scenario: Unit tests for past event date generation

- **WHEN** unit tests create events with dates in the past (e.g., 2024)
- **THEN** `getAllEventDates()` returns the correct dates for those events
- **AND** tests do not fail with "Actual: <0>" due to past events being filtered out
- **AND** the test suite validates both past and future event scenarios
