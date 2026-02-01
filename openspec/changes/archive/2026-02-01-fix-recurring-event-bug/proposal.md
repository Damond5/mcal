## Why

The MCAL application's `Event.getAllEventDates()` method is incorrectly filtering out events that have already ended, which prevents users from viewing historical event data. This breaks both the calendar display functionality and related test suites that rely on accessing past event dates.

**Root Cause:** The method includes an early termination check at line 460 that skips events where `event.endDate` is before `DateTime.now()`. While this optimization might seem reasonable for future-focused calendar displays, it incorrectly assumes users never need to view past events and breaks existing functionality that depends on accessing historical data.

**Impact:**
- Unit tests for event date generation fail with "Actual: <0>" because all test events from 2024 are filtered out (current date is 2026)
- Users cannot view historical event dates in the calendar
- Test fixtures and validation scenarios that rely on past events cannot function correctly
- The behavior contradicts the existing `Event.occursOnDate()` method which correctly handles past events

## What Changes

1. **Remove the early termination filter** in `Event.getAllEventDates()` that skips events ending before the current date
2. **Preserve existing date range filtering** through the `endDate` parameter for forward-looking optimizations
3. **Update method documentation** to clarify that the method returns dates for all events regardless of their end date
4. **Add test coverage** to verify the fix works for both past and future events

## Capabilities

### New Capabilities
- Users can view historical event dates on the calendar
- Test suites can validate event date generation with past events
- Historical data analysis and reporting becomes possible

### Modified Capabilities
- `Event.getAllEventDates()` now returns dates for all events regardless of their end date
- Calendar display continues to show future events correctly
- Performance optimizations via the `endDate` parameter remain intact

## Impact

- **Positive:** Restores full functionality for viewing event dates across all time periods
- **Positive:** Fixes failing test suite (9 tests currently failing with "Actual: <0>")
- **Positive:** Maintains consistency with `Event.occursOnDate()` method behavior
- **No Breaking Changes:** The change only adds missing functionality; no existing behavior is removed
- **Performance:** Minimal impact - the `endDate` parameter still allows efficient future-date-only queries when needed
