# Proposal: Fix Calendar Integration Tests - Test Window Size Configuration

## Why
Calendar integration tests are failing/skipped because the ThemeToggleButton is positioned off-screen at offset (835.0, 28.0), preventing 10+ tests from verifying theme toggle functionality during calendar interactions.

## What Changes
Configure integration test window size to ensure sufficient width for displaying all AppBar action buttons, enabling skipped tests to pass and provide full test coverage for theme integration with calendar interactions.

### Current Issues

Calendar integration tests in `integration_test/calendar_integration_test.dart` have **10+ tests skipped** with comment: `"Theme toggle button not accessible in test environment (off-screen at offset 835.0, 28.0)"`.

The root cause is:
1. **Default test window width < 835px**: Integration tests use a default window size that's too narrow
2. **AppBar layout constraints**: AppBar contains `"MCal: Mobile Calendar"` title + `SyncButton()` + `ThemeToggleButton()`, requiring > 800px width
3. **ThemeToggleButton clipped**: Button positioned at x=835.0, which is beyond default viewport width
4. **ensureVisible doesn't work**: `tester.ensureVisible(find.byType(ThemeToggleButton))` only works for scrollable content (ListView), NOT for AppBar buttons clipped by viewport
5. **10 tests affected**: Tests in Task 3.4 (Calendar Theme) and Phase 14 (Theme Integration) are all skipped

This represents a **test coverage gap** for theme integration with calendar:
- Critical theme toggle functionality during calendar interactions is untested
- Theme persistence across calendar navigation is unverified
- Theme changes during dialog interactions are not tested
- False confidence from skipped tests (test suite appears complete but has holes)

## Proposed Solution

Configure integration test window size to 1200x800 pixels (or larger) to ensure all AppBar actions are visible and tappable:

1. **Add test window size configuration helper** to `test/test_helpers.dart`:
   - Function `setupTestWindowSize(tester)` sets `tester.view.physicalSize = const Size(1200, 800)`
   - Function `resetTestWindowSize(tester)` resets to default in tearDown
   - Works for both integration tests and widget tests

2. **Apply window size in affected tests**:
   - Call `setupTestWindowSize(tester)` in `setUp()` or before `pumpWidget()`
   - Call `resetTestWindowSize(tester)` in `tearDown()` or `addTearDown()`
   - Removes ineffective `ensureVisible()` calls for ThemeToggleButton

3. **Remove skip flags from tests**:
   - Remove `skip: true` from 10+ calendar integration tests
   - Remove SKIP comments about off-screen button
   - Enable full test coverage for theme integration

## Documentation Updates

- **CHANGELOG.md**: Will be updated under "Fixed" section to document test window configuration
- **README.md**: Testing section will document test window size requirements
- **AGENTS.md**: Platform-specific instructions will note test window configuration needs

## Scope

This change is focused on test environment configuration:

- **In scope**:
  - Adding test window size configuration helper to `test/test_helpers.dart`
  - Updating all affected integration tests to use window size helper
  - Removing skip flags from 10+ calendar integration tests
  - Removing ineffective `ensureVisible()` calls for ThemeToggleButton
  - Verifying all previously skipped tests now pass

- **Out of scope**:
  - Modifying production AppBar layout or widget positioning
  - Changing ThemeToggleButton widget implementation
  - Modifying theme provider logic
  - Changing app title length or content
  - Adding responsive layout logic to production code

## Acceptance Criteria

- Test window size helper in `test/test_helpers.dart` includes:
  - `setupTestWindowSize(WidgetTester tester)` function sets size to 1200x800
  - `resetTestWindowSize(WidgetTester tester)` function resets to default
  - Functions work with both integration and widget tests
  - Proper cleanup with `addTearDown()` prevents state pollution
- All previously skipped tests in `calendar_integration_test.dart` pass:
  - Task 3.4: "Calendar updates when theme changes"
  - Task 3.4: "Week numbers update color on theme change"
  - Task 14.1: "Theme toggle works while event form is open"
  - Task 14.1: "Theme toggle works while event details are open"
  - Task 14.1: "Theme toggle works while sync settings are open"
  - Task 14.1: "Dialogs update colors on theme change"
  - Task 14.2: "Calendar colors update on theme change"
  - Task 14.2: "Event list colors update on theme change"
  - Task 14.2: "Buttons and icons update on theme change"
  - Task 14.2: "All widgets respond consistently to theme"
- All ineffective `ensureVisible()` calls for ThemeToggleButton are removed
- Test coverage for theme integration increases by 10+ scenarios
- All existing tests continue to pass (no regressions)

## Impact

- **Testing**: Restores test coverage for 10+ previously skipped theme integration tests
- **Test Quality**: Removes ineffective workarounds (`ensureVisible()`) that don't solve root cause
- **Test Reliability**: Tests no longer rely on off-screen elements or partial coverage
- **Risk**: Low - test-only changes, no production code modifications
- **Dependencies**: None - uses existing Flutter test infrastructure
- **Performance**: Minimal - adds simple helper function, reduces test flakiness
- **Maintainability**: Improves test reliability and provides reusable utility for future tests

## Alternatives Considered

1. **Option 2: Modify AppBar Layout** (Alternative)
   - *Rejected*: Changes production code for test issue; affects real users; shortening title reduces clarity
2. **Option 3: Use OverflowMenu for Actions** (Alternative)
   - *Rejected*: Changes user interaction pattern; requires more clicks; affects production UX
3. **Option 4: Keep Tests Skipped** (Alternative)
   - *Rejected*: Skipped tests provide false coverage; critical theme integration remains untested
4. **Option 5: Use Smaller Font in Title** (Alternative)
   - *Rejected*: Affects readability; production code change for test issue; less maintainable
5. **Option 6: Move SyncButton to PopupMenu** (Alternative)
   - *Rejected*: Changes production UX; reduces discoverability; requires user research

## Notes

- ThemeToggleButton is positioned at x=835.0 based on AppBar title "MCal: Mobile Calendar" + SyncButton width
- Default Flutter test window size is 800x600 (insufficient for this layout)
- Flutter's `tester.ensureVisible()` only works for scrollable widgets (ListView, ScrollView), not clipped AppBar elements
- Integration test window size is independent of device screen size - simulated environment for consistent test execution
- Window size of 1200x800 provides 400px additional width, ensuring button visibility with margin
- Window size can be adjusted if future tests require larger dimensions (e.g., more AppBar actions)
