## Context

The MCAL application has a bug in the `Event.getAllEventDates()` method that incorrectly filters out events whose `endDate` is before `DateTime.now()`. This early termination check at line 460 prevents users from viewing historical event data and causes unit tests to fail with "Actual: <0>" when testing past events (since the current date is 2026 and test events are from 2024).

The issue contradicts the existing `Event.occursOnDate()` method which correctly handles past events. The fix requires removing the early termination filter while preserving the existing `endDate` parameter-based filtering for forward-looking optimizations.

MCAL is a cross-platform Flutter calendar application using the Provider pattern with ChangeNotifier for state management. Events are stored as individual Markdown files in the application's documents directory.

## Goals / Non-Goals

**Goals:**
- Remove the early termination check that skips events where `event.endDate` is before `DateTime.now()`
- Preserve the existing `endDate` parameter filtering functionality for query optimization
- Update method documentation to clarify the method returns dates for all events regardless of their end date
- Add test coverage for past event scenarios to prevent regression
- Ensure consistency with `Event.occursOnDate()` method behavior

**Non-Goals:**
- Do not modify the event storage format or Markdown file structure
- Do not change the recurrence rule parsing logic
- Do not alter the calendar display logic or UI components
- Do not remove the `endDate` parameter from `getAllEventDates()` - it serves as an optimization for limiting returned dates
- Do not modify the Git sync functionality

## Decisions

### 1. Remove Early Termination Filter in Event.getAllEventDates()

**Description:**
The method currently has an early return check that skips events ending before `DateTime.now()`. This needs to be removed entirely.

**Current problematic code (line ~460):**
```dart
if (event.endDate.isBefore(DateTime.now())) {
  return; // or continue to next event
}
```

**Rationale:**
- Users need access to historical event data for viewing past events on the calendar
- Unit tests require the ability to validate past events without them being filtered out
- The existing `endDate` parameter already provides a cleaner mechanism for limiting date ranges when needed
- Removing this check maintains consistency with `Event.occursOnDate()` which doesn't filter based on current date
- The fix aligns with the offline-first architecture where all event data should be accessible locally

**Implementation approach:**
```dart
// Remove the early termination check entirely
// Keep the existing endDate parameter filtering logic which operates on the query range, not current date
Iterable<DateTime> getAllEventDates({
  DateTime? startDate,
  DateTime? endDate,
}) {
  // ... existing logic for handling startDate and endDate parameters
  // ... existing recurrence date generation logic
  // DO NOT add: if (event.endDate.isBefore(DateTime.now())) return;
}
```

**Alternatives considered:**
- Conditional filtering based on a parameter: Rejected because it adds complexity and the default behavior should support all events
- Moving the check to callers: Rejected because callers shouldn't need to know about this filtering logic; the method should handle it correctly internally

### 2. Preserve endDate Parameter-Based Filtering

**Description:**
The `endDate` parameter in `getAllEventDates()` allows callers to limit the returned dates to a specific range. This optimization must remain functional.

**Rationale:**
- Provides performance optimization for calendar displays that only show a window of dates
- Maintains backward compatibility for existing callers
- Follows the principle of separating query optimization from data access rules

**Implementation approach:**
```dart
Iterable<DateTime> getAllEventDates({
  DateTime? startDate,
  DateTime? endDate,
}) {
  // Existing parameter-based filtering logic remains unchanged
  if (endDate != null) {
    // Filter dates to those on or before endDate
  }
  // This operates on the requested query range, not DateTime.now()
}
```

**Alternatives considered:**
- Removing the endDate parameter entirely: Rejected because it breaks existing optimizations and caller expectations

### 3. Update Method Documentation

**Description:**
The method's documentation should clearly state that it returns dates for all events regardless of when they end.

**Current documentation (approximate):**
```dart
/// Returns all dates for this event within the specified range.
Iterable<DateTime> getAllEventDates({DateTime? startDate, DateTime? endDate});
```

**Updated documentation:**
```dart
/// Returns all occurrence dates for this event within the specified range.
///
/// This method returns dates for all events regardless of their [endDate] property,
/// allowing access to historical event data. The [startDate] and [endDate] parameters
/// filter the returned dates to the specified query range.
///
/// Unlike calendar displays that may want to focus on future events, this method
/// provides complete access to event occurrences across all time periods.
Iterable<DateTime> getAllEventDates({DateTime? startDate, DateTime? endDate});
```

**Rationale:**
- Prevents future developers from accidentally re-introducing the bug
- Documents the expected behavior clearly for testing and usage
- Differentiates this method's behavior from display-focused optimizations

### 4. Add Unit Test Coverage for Past Events

**Description:**
Add test cases that verify `getAllEventDates()` works correctly with past events to prevent regression.

**Test scenarios to add:**
```dart
test('getAllEventDates returns dates for past events', () {
  final event = Event(
    id: 'test-event',
    title: 'Past Event',
    startDate: DateTime(2024, 1, 15),
    endDate: DateTime(2024, 1, 16),
    // ... other properties
  );

  // Create a date range that includes the past event dates
  final startDate = DateTime(2024, 1, 1);
  final endDate = DateTime(2024, 12, 31);

  final dates = event.getAllEventDates(startDate: startDate, endDate: endDate);

  // Verify past event dates are returned
  expect(dates, contains(DateTime(2024, 1, 15)));
  expect(dates, contains(DateTime(2024, 1, 16)));
});

test('getAllEventDates handles recurring past events', () {
  final event = Event(
    id: 'recurring-event',
    title: 'Weekly Meeting',
    startDate: DateTime(2024, 1, 1),
    endDate: DateTime(2024, 6, 30),
    recurrenceRule: 'FREQ=WEEKLY',
    // ... other properties
  );

  final dates = event.getAllEventDates(
    startDate: DateTime(2024, 1, 1),
    endDate: DateTime(2024, 6, 30),
  );

  // Verify all recurrence dates are returned
  expect(dates.length, equals(26)); // Weekly for 6 months
});
```

**Rationale:**
- Prevents regression of the bug fix
- Validates the fix works for both single and recurring events
- Ensures tests can pass with dates from the past (like 2024 test fixtures)

**Alternatives considered:**
- Only testing with future dates: Rejected because it wouldn't catch the specific bug being fixed

## Risks / Trade-offs

**Risks:**
- **Performance impact for large historical datasets:** If users have many past events, returning all historical dates could impact performance when no `endDate` is specified. Mitigation: The `endDate` parameter provides a mechanism to limit results; documentation should encourage its use for display scenarios.
- **Unexpected behavior for existing callers:** Callers that relied on the early termination behavior may need updates. Mitigation: The behavior change is a bug fix; the previous behavior was incorrect and inconsistent with other methods like `occursOnDate()`.

**Trade-offs:**
- **Consistency vs. backward compatibility:** Choosing to fix the bug and maintain consistency with `occursOnDate()` over preserving the (incorrect) previous behavior
- **Complete access vs. display optimization:** Providing complete access to all event data through `getAllEventDates()` while letting display components use the `endDate` parameter for their specific optimization needs
- **Test coverage vs. test execution time:** Adding comprehensive past event tests increases test coverage but may slightly increase test execution time

**Mitigation strategies:**
- Update documentation to clarify proper usage patterns
- Add integration tests that verify calendar display works with past events
- Monitor performance in real-world usage scenarios
- Ensure the `endDate` parameter remains the recommended approach for display optimizations
