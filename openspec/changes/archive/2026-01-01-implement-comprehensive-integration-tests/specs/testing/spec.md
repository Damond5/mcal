# ADDED|MODIFIED|REMOVED Requirements

## ADDED Requirements

### Requirement: The application SHALL Include Event CRUD Integration Tests

The application SHALL include integration tests in `integration_test/event_crud_integration_test.dart` for end-to-end event management workflows to verify complete user workflows for creating, editing, and deleting events through GUI, complementing existing unit tests in `test/event_provider_test.dart` (see also: `specs/event-management/spec.md`).

#### Scenario: Adding event via FAB button
Given the app is loaded and displaying the calendar
When the user taps the floating action button (FAB)
Then the event form dialog opens
And the form is empty with default values

#### Scenario: Filling and saving event form
Given the event form dialog is open
When the user enters a title "Team Meeting"
And the user selects a start date
And the user enters a start time "14:00"
And the user enters an end time "15:00"
And the user enters a description "Weekly sync"
And the user selects recurrence "weekly"
And the user taps "Save"
Then the event is saved to storage
And an event marker appears on the calendar date
And the event appears in the event list for that date
And the event persists after app restart

#### Scenario: Event appears in event list after creation
Given an event was created for today
When the user selects today on the calendar
Then the event is displayed in the event list below the calendar
And the event list shows the event title
And the event list shows the event time "14:00 - 15:00"
And the event list shows the description

#### Scenario: Form validation prevents invalid events
Given the event form dialog is open
And the title field is empty
When the user taps "Save"
Then an error message is displayed
And the event is not saved
And the form remains open

#### Scenario: Creating recurring daily event
Given the event form dialog is open
When the user creates an event with recurrence "daily"
Then the event is saved
And event markers appear on subsequent days in the calendar
And the event list shows the event for each day

#### Scenario: Creating recurring yearly event
Given the event form dialog is open
When the user creates an event on February 29th with recurrence "yearly"
Then the event is saved
And event markers appear on February 29th on leap years
And event markers appear on February 28th on non-leap years
And the event list shows the event for each year

#### Scenario: Creating multi-day event
Given the event form dialog is open
When the user creates an event with start date "2025-11-10"
And end date "2025-11-12"
Then the event is saved
And event markers appear on November 10th, 11th, and 12th
And the event list shows the event for each day in the range

### Requirement: The application SHALL Include Calendar Interactions Integration Tests

The application SHALL include integration tests in `integration_test/calendar_integration_test.dart` for calendar navigation, day selection, and visual feedback to verify complete user interactions with the calendar widget (see also: `specs/ui-calendar/spec.md`).

#### Scenario: Selecting calendar day
Given the app is loaded and displaying the calendar
When the user taps a calendar day
Then the selected day is highlighted with a circular decoration
And the event list is updated to show events for the selected day
And the EventProvider selectedDate is updated

#### Scenario: Navigating to previous month
Given the app is displaying the current month
When the user taps the previous month button
Then the calendar displays the previous month
And the focusedDay is updated to the previous month
And event markers are updated for the new month

#### Scenario: Navigating to next month
Given the app is displaying the current month
When the user taps the next month button
Then the calendar displays the next month
And the focusedDay is updated to the next month
And event markers are updated for the new month

#### Scenario: Event markers display on calendar
Given multiple events exist on different days
When the calendar is displayed
Then each day with an event shows a marker
And markers use the theme's secondary color
And markers appear as circular decorations

#### Scenario: Today is highlighted
Given today's date is visible on the calendar
When the calendar is displayed
Then today is highlighted with a distinct decoration
And today's decoration uses the theme's primary color with 30% opacity
And today's text is bold

#### Scenario: Selected day remains highlighted after navigation
Given a day is selected on the calendar
When the user navigates to a different month
And navigates back to the original month
Then the selected day is still highlighted
And the event list still shows events for the selected day

### Requirement: The application SHALL Include Event Form Dialog Integration Tests

The application SHALL include integration tests in `integration_test/event_form_integration_test.dart` for the event form dialog to verify form functionality, input handling, and validation (see also: `specs/event-management/spec.md`).

#### Scenario: All-day checkbox toggles time fields
Given the event form dialog is open
When the user taps the "All Day" checkbox
Then the start time field is hidden
And the end time field is hidden
And when the user unchecks "All Day"
Then the start time field becomes visible
And the end time field becomes visible

#### Scenario: Date picker for start date
Given the event form dialog is open
When the user taps the start date button
Then a date picker dialog opens
And when the user selects a date
Then the start date field displays the selected date

#### Scenario: Date picker for end date
Given the event form dialog is open
When the user taps the end date button
Then a date picker dialog opens
And when the user selects a date
Then the end date field displays the selected date
And if the selected end date is before the start date
Then the end date is automatically adjusted to the start date

#### Scenario: Time picker for start time
Given the event form dialog is open with "All Day" unchecked
When the user taps the start time button
Then a time picker dialog opens
And when the user selects a time
Then the start time field displays the selected time in HH:MM format

#### Scenario: Time picker for end time
Given the event form dialog is open with "All Day" unchecked
When the user taps the end time button
Then a time picker dialog opens
And when the user selects a time
Then the end time field displays the selected time in HH:MM format

#### Scenario: Recurrence dropdown selection
Given the event form dialog is open
When the user taps the recurrence dropdown
Then all options are displayed: none, daily, weekly, monthly, yearly
And when the user selects "weekly"
Then the recurrence field displays "weekly"

#### Scenario: Multi-line description input
Given the event form dialog is open
When the user enters a long description
Then the description field displays multiple lines
And the field is scrollable
And the description is saved correctly

#### Scenario: Cancel button closes form without saving
Given the event form dialog is open with filled fields
When the user taps "Cancel"
Then the form dialog closes
And the event is not saved
And no event marker appears on the calendar

#### Scenario: Form opens empty for new event
Given the app is loaded and displaying the calendar
When the user taps the FAB to add a new event
Then the event form dialog opens
And all fields are empty or have default values
And the title is "Add Event"

#### Scenario: Form opens with data for existing event
Given an event exists on the calendar
When the user opens the event details and taps "Edit"
Then the event form dialog opens
And all fields contain the event's current values
And the title is "Edit Event"

### Requirement: The application SHALL Include Event List Widget Integration Tests

The application SHALL include integration tests in `integration_test/event_list_integration_test.dart` for the event list widget to verify event display, interactions, and empty state handling (see also: `specs/event-management/spec.md`).

#### Scenario: Empty state shows when no events
Given the app is loaded
When the user selects a day with no events
Then the text "No events for this day" is displayed
And no event cards are shown

#### Scenario: Event card displays event details
Given an event exists for the selected day
When the event list is displayed
Then an event card is shown
And the card displays the event title
And the card displays the event time
And if a description exists, the card displays the description

#### Scenario: All-day event displays correctly
Given an all-day event exists for the selected day
When the event list is displayed
Then the event card shows "All day" instead of a specific time
And if an end date exists, the card shows the date range

#### Scenario: Multi-day event displays date range
Given a multi-day event exists spanning multiple days
When the user selects a day within the event range
Then the event card shows the start and end dates in MM/DD format

#### Scenario: Tapping event card opens details
Given an event card is displayed
When the user taps the event card
Then the event details dialog opens
And the dialog shows the event title
And the dialog shows the event date and time
And the dialog shows the event description
And if recurrence is set, the dialog shows the recurrence

#### Scenario: Delete button on event card
Given an event card is displayed
When the user taps the delete icon
Then a confirmation dialog appears with the message
And the confirmation dialog shows the event title
And the user can confirm or cancel the deletion

#### Scenario: Multiple events displayed in list
Given three events exist for the selected day
When the event list is displayed
Then three event cards are shown
And each card displays a different event
And events are ordered by time (chronological)

#### Scenario: Editing event from details dialog
Given the event details dialog is open
When the user taps "Edit"
Then the event details dialog closes
And the event form dialog opens with the event's current values
And the user can modify and save the event

#### Scenario: Event list updates after deletion
Given two events exist for the selected day
When the user deletes one event
Then the deleted event is removed from the list
And the remaining event is still displayed
And the event list shows only one event

### Requirement: The application SHALL Include Theme Integration Tests

The application SHALL include integration tests in `integration_test/calendar_integration_test.dart` to verify theme changes work correctly during user interactions and all widgets respond appropriately, extending existing unit tests in `test/theme_provider_test.dart` and `integration_test/app_integration_test.dart` (see also: `specs/theme-system/spec.md`).

#### Scenario: Theme toggle changes entire app theme
Given the app is loaded in light mode
When the user taps the theme toggle button
Then the app switches to dark mode
And all UI elements update to dark theme colors
And the theme toggle button icon changes to Icons.light_mode

#### Scenario: Theme toggle during event form open preserves form state
Given the event form dialog is open with filled fields
When the user taps the theme toggle button
Then the theme changes (light ↔ dark)
And the event form dialog colors update to match the new theme
And all form fields retain their values
And the form remains open and functional

#### Scenario: Theme toggle during event details open preserves details
Given the event details dialog is open
When the user taps the theme toggle button
Then the theme changes (light ↔ dark)
And the event details dialog colors update to match the new theme
And all event information remains displayed
And the dialog remains open and functional

#### Scenario: Calendar colors update on theme change
Given the calendar is displayed in light mode
When the user taps the theme toggle button
Then the theme changes to dark mode
And the calendar background color updates to the dark background
And the calendar text color updates to light text
And event marker colors update to the dark theme secondary color
And the selected day decoration updates to the dark theme primary color
And the today decoration updates to the dark theme primary color with opacity

#### Scenario: Event list colors update on theme change
Given the event list is displaying events in light mode
When the user taps the theme toggle button
Then the theme changes to dark mode
And the event list background color updates to the dark background
And the event card background colors update to the dark theme surface color
And the event card text colors update to light text
And all icons and buttons in the event list update colors

#### Scenario: Buttons and icons update on theme change
Given the app is displayed in light mode
When the user taps the theme toggle button
Then the theme changes to dark mode
And the sync button icon color updates to the dark theme on-surface color
And the FAB icon color updates to the dark theme on-primary color
And all other buttons update their colors appropriately
And all icons update their colors appropriately

#### Scenario: Theme persists across app restart
Given the app is in dark mode
When the app widget is reloaded (simulating restart)
Then the dark theme is restored
And all UI elements display in dark mode
And the theme toggle button shows Icons.light_mode icon

#### Scenario: System theme changes are detected
Given the app is in system theme mode
When the system theme changes from light to dark
Then the app switches to dark mode
And all UI elements update to dark theme colors
And the theme toggle button icon updates to Icons.light_mode

#### Scenario: Theme toggle cycles correctly
Given the app is in system theme mode
When the user taps the theme toggle button once
Then the app switches to light mode
And when the user taps the theme toggle button again
Then the app switches to dark mode
And when the user taps the theme toggle button third time
Then the app returns to system theme mode
