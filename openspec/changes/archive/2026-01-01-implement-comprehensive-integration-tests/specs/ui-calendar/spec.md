# ADDED|MODIFIED|REMOVED Requirements

## ADDED Requirements

### Requirement: The application SHALL Include Calendar Interactions Integration Tests

The application SHALL include integration tests in `integration_test/calendar_integration_test.dart` to verify calendar navigation, day selection, event markers, and visual feedback, complementing existing widget tests in `test/widget_test.dart` (see also: `specs/testing/spec.md`).

#### Scenario: Day selection updates event list
Given app is displaying calendar
When user taps a specific calendar day
Then selected day is highlighted with a circular decoration
And event list is updated to show events for selected day
And EventProvider selectedDate is updated to tapped day
And event list scrolls into view

#### Scenario: Selected day persists across month navigation
Given a day is selected on calendar
When user navigates to a different month
And navigates back to original month
Then selected day is still highlighted
And event list still shows events for selected day
And selected day decoration is visible

#### Scenario: Month navigation updates focusedDay and event markers
Given app is displaying November 2025
When user taps next month button
Then calendar displays December 2025
And focusedDay is updated to a day in December
And event markers are updated to show events in December
And when user taps previous month button
Then calendar displays November 2025
And focusedDay is updated to a day in November
And event markers show events in November

#### Scenario: Event markers display on days with events
Given multiple events exist on different dates: November 5th, 12th, 20th
When calendar is displayed for November 2025
Then event markers appear as small circles on November 5th, 12th, and 20th
And markers use theme's secondary color
And markers are positioned at bottom of date cell
And days without events do not show markers

#### Scenario: Event marker disappears when event deleted
Given an event exists on November 15th with a visible marker
When user deletes the event
Then event marker disappears from November 15th
And no marker is visible on that day
And other event markers remain visible

#### Scenario: Event marker appears when event added
Given no events exist on November 15th
When user adds an event for November 15th
Then an event marker appears on November 15th
And marker is visible immediately
And marker is styled with theme's secondary color

#### Scenario: Today is highlighted with distinct decoration
Given today's date is December 5th and calendar is displaying December 2025
When calendar is displayed
Then today (December 5th) is highlighted with a distinct decoration
And today's decoration uses theme's primary color with 30% opacity
And today's text is bold
And today can still be selected independently of today decoration

#### Scenario: Multiple events on same day show single marker
Given three events exist on November 10th
When calendar is displayed for November 2025
Then a single event marker appears on November 10th
And marker indicates events exist but not the count
And all three events are displayed in event list when day is selected

#### Scenario: Recurring events show markers on all instances
Given a weekly recurring event starts on Monday, November 10th
When calendar is displayed for November 2025
Then event markers appear on Monday, Tuesday, Wednesday, Thursday, Friday of that week
And markers appear on subsequent Mondays in the month
And each day with a recurring instance shows the marker

#### Scenario: Multi-day events show markers on all days in range
Given a multi-day event spans November 15th to November 17th
When calendar is displayed for November 2025
Then event markers appear on November 15th, 16th, and 17th
And event is displayed in event list for each day in range
And all markers are styled consistently

#### Scenario: Calendar responds to theme changes
Given calendar is displayed in light mode
When user toggles theme to dark mode
Then calendar background updates to dark theme background
And calendar text updates to dark theme text color
And event marker colors update to dark theme secondary color
And today's decoration updates to dark theme primary color with opacity
And selected day decoration updates to dark theme primary color
And week numbers update to dark theme text color

#### Scenario: Week numbers are displayed and styled correctly
Given calendar is displayed
When user views the calendar
Then week numbers are displayed on left side of calendar
And week numbers use theme's text color with 70% opacity
And week numbers update their color when theme changes
And week numbers are correctly calculated for each week
