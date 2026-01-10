# Change: Add Yearly Recurrence Support

## Why
MCAL currently supports recurrence patterns of none, daily, weekly, and monthly, but lacks yearly recurrence which is now supported by rcal (v1.4.0). This incompatibility prevents users from creating and syncing yearly events like birthdays, anniversaries, and annual holidays between rcal and MCAL.

## What Changes
- Add 'yearly' to valid recurrence options in the Event model
- Implement yearly recurrence expansion logic with February 29th fallback to February 28th on non-leap years (following rcal implementation)
- Add 'yearly' option to event form recurrence dropdown
- Add comprehensive test coverage for yearly recurrence including leap year edge cases
- Update all documentation to reflect yearly recurrence support

## Impact
- **Affected specs:** event-management
- **Affected code:**
  - `lib/models/event.dart` (lines 4-9, 20, 293-310)
  - `lib/widgets/event_form_dialog.dart` (lines 268-272)
  - `test/event_provider_test.dart` (new tests)
- **Affected documentation:**
  - `README.md`
  - `CHANGELOG.md`
  - `TODO.md`
  - `openspec/specs/event-management/spec.md`
  - `openspec/project.md`
