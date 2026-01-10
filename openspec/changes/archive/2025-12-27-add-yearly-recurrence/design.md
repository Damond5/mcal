# Design: Yearly Recurrence Implementation

## Context
MCAL is a cross-platform calendar application designed for compatibility with rcal. rcal v1.4.0 added yearly recurrence support including proper handling of February 29th events on non-leap years (fallback to February 28th). MCAL must implement this to maintain specification alignment.

**Current State:**
- Recurrence supports: none, daily, weekly, monthly
- Event expansion logic in `lib/models/event.dart:277-331`
- Uses fixed 1-year cap for all recurrence patterns
- No leap year handling implemented

**Target State:**
- Recurrence supports: none, daily, weekly, monthly, yearly
- Yearly expansion with Feb 29th fallback to Feb 28th on non-leap years
- Comprehensive test coverage for leap year edge cases

## Goals / Non-Goals

**Goals:**
- Add yearly recurrence to validRecurrences list
- Implement year advancement logic matching rcal's behavior
- Use Dart's built-in DateTime methods for leap year detection
- Add UI option for yearly recurrence
- Provide test coverage for normal and edge case scenarios
- Maintain rcal specification compatibility

**Non-Goals:**
- Modify existing recurrence patterns (daily, weekly, monthly)
- Change event storage format (Markdown format remains unchanged)
- Modify sync behavior (no changes to Git sync logic)
- Implement lazy loading (keep existing 1-year cap approach)

## Decisions

### Decision 1: Leap Year Detection Method
**Choice:** Use Dart's built-in DateTime methods

**Rationale:**
- Dart's DateTime constructor validates dates automatically
- `DateTime(year, 2, 29).month == 2` efficiently checks if Feb 29 exists
- Simpler and more reliable than manual calculation
- Leverages platform's built-in calendar logic

**Implementation:**
```dart
static bool _isLeapYear(int year) {
  // Try creating Feb 29; if month is not 2, it doesn't exist (non-leap year)
  return DateTime(year, 2, 29).month == 2;
}
```

### Decision 2: February 29th Fallback Behavior
**Choice:** Follow rcal's approach - fallback to February 28th on non-leap years

**Rationale:**
- Ensures annual consistency (e.g., birthday occurs every year)
- Matches rcal specification for cross-compatibility
- Standard industry practice for date-based annual events

**Alternatives Considered:**
1. **Skip the year** (no event on non-leap years)
   - Rejected: Breaks annual event semantics
   - Use case: Users expect birthdays/anniversaries every year
2. **March 1st fallback**
   - Rejected: Deviates from rcal implementation
   - Less intuitive than Feb 28th (same month)

### Decision 3: Recurrence Expansion Strategy
**Choice:** Use existing expandRecurring() pattern with 1-year cap

**Rationale:**
- Maintains consistency with existing daily/weekly/monthly logic
- Simple, predictable behavior
- Sufficient for calendar display (shows events within 1-year view)
- Avoids complexity of lazy loading implementation

**Alternatives Considered:**
1. **Lazy loading with buffer (rcal approach)**
   - Rejected: Significant refactoring required
   - Would change expansion strategy for all recurrence patterns
   - Current 1-year cap works well for MCAL's use case

## Risks / Trade-offs

### Risk 1: Date Boundary Edge Cases
**Risk:** Month/day combinations may behave unexpectedly when advancing years (e.g., Feb 30th doesn't exist)

**Mitigation:**
- Use Dart's DateTime which handles edge cases automatically
- Tests cover Feb 29th on leap/non-leap years
- Validation in Event constructor already prevents invalid dates

### Risk 2: Performance Impact of Yearly Expansion
**Risk:** Yearly events spanning decades could generate many instances

**Mitigation:**
- Existing 1-year cap naturally limits expansion
- Typical use cases (birthdays, holidays) have modest timeframes
- Current expansion approach is O(n) where n = years in range (small with 1-year cap)

### Risk 3: Time Component Loss in Yearly Advancement
**Risk:** When advancing years, time component could be lost or altered

**Mitigation:**
- Preserve hour/minute/second when creating new DateTime
- Use DateTime constructor with explicit time parameters
- Tests verify time preservation across year boundaries

## Migration Plan

### No Migration Required
This is an additive change only. Existing events and data are unaffected:
- Existing Markdown files remain valid
- No database schema changes (file-based storage)
- Backwards compatible (old events without yearly support still work)

### Deployment Steps
1. Implement Event model changes
2. Add UI dropdown option
3. Write comprehensive tests
4. Update documentation
5. Validate all tests pass
6. Deploy to all platforms (no platform-specific code changes)

## Open Questions

None - requirements are clear based on rcal specification and implementation.
