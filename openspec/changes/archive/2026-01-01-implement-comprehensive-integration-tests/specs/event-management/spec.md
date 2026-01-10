# ADDED|MODIFIED|REMOVED Requirements

## ADDED Requirements

### Requirement: The application SHALL Include Event CRUD Integration Tests

The application SHALL include integration tests in `integration_test/event_crud_integration_test.dart` to verify end-to-end event management workflows through GUI, complementing existing unit tests in `test/event_provider_test.dart` (see also: `specs/testing/spec.md`).

#### Scenario: Adding event through complete form workflow
Given app is displaying calendar
When user taps floating action button
And user fills in event form with title, date, time, description, and recurrence
And user taps Save
Then event is saved to storage
And an event marker appears on calendar date
And event appears in event list for that date
And event persists after app restart

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

#### Scenario: Deleting event through confirmation dialog workflow
Given an event exists on calendar
When user selects event date and taps delete button on event card
And user confirms deletion in confirmation dialog
Then event is removed from storage
And event marker disappears from calendar
And event is removed from event list
And deletion persists after app restart

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
