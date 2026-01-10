# Design: Fix Calendar Integration Tests - Test Window Size Configuration

## Architectural Approach

This change addresses a **test environment configuration issue** that causes integration tests to fail/skip when attempting to interact with off-screen UI elements.

### Root Cause Analysis

The ThemeToggleButton is inaccessible during integration tests due to viewport constraints:

```
AppBar Layout (width required):
┌────────────────────────────────────────────────────────┐
│ MCal: Mobile Calendar (title) │ Sync │ Theme  │
│              (~550px)        │ (~100px)│ (~100px)│
└────────────────────────────────────────────────────────┘
Total width required: ~750px+ (with margins and spacing)

Default test window: 800x600
ThemeToggleButton position: x=835.0, y=28.0
Result: Button is clipped at right edge (835 > 800 - margins)
```

**Why ensureVisible() Fails**:

Flutter's `tester.ensureVisible()` method works by:
1. Finding a scrollable ancestor (ListView, ScrollView, etc.)
2. Calculating scroll distance to bring element into viewport
3. Scrolling the scrollable ancestor

However, AppBar elements are:
- **NOT** scrollable (AppBar is fixed at top)
- **NOT** in a scrollable container (outside body content)
- **NOT** affected by body scrolling (independent scroll context)

Therefore, `ensureVisible()` **cannot** bring AppBar buttons into view and has no effect on clipped elements.

### Solution: Configure Test Window Size

Configure the test environment viewport to be wide enough for all AppBar elements:

```dart
// In test setup (setUp() or before pumpWidget)
tester.view.physicalSize = const Size(1200, 800);
tester.view.devicePixelRatio = 1.0;

// In test cleanup (tearDown() or addTearDown)
tester.view.resetPhysicalSize();
tester.view.resetDevicePixelRatio();
```

**Why 1200x800?**
- Width 1200px: Provides 400px buffer beyond required ~800px (50% margin)
- Height 800px: Provides sufficient space for calendar + event list without scrolling
- Standard test size: Commonly used in Flutter testing examples and docs
- Device pixel ratio 1.0: Ensures consistent sizing across platforms

## Test Infrastructure Design

### Helper Functions (test/test_helpers.dart)

Add reusable utilities for test window configuration:

```dart
/// Configures test window size for integration and widget tests
///
/// Sets the test viewport to 1200x800 pixels to ensure all UI elements
/// (including AppBar action buttons) are visible and tappable during tests.
///
/// Must be called in setUp() or before pumpWidget() for each test.
///
/// Example:
/// ```dart
/// setUp(() {
///   setupTestWindowSize(tester);
/// });
/// ```
void setupTestWindowSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1.0;
}

/// Resets test window size to default values
///
/// Must be called in tearDown() or addTearDown() to prevent
/// test state pollution between tests.
///
/// Example:
/// ```dart
/// addTearDown(() {
///   resetTestWindowSize(tester);
/// });
/// ```
void resetTestWindowSize(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}
```

**Design Decisions**:

| Decision | Rationale |
|----------|-----------|
| Use Size(1200, 800) | Standard test size, provides 50% width buffer, works for all current and future AppBar layouts |
| Set devicePixelRatio to 1.0 | Ensures consistent sizing across platforms; logical pixels match physical pixels |
| Separate reset function | Allows explicit cleanup; prevents state pollution; can be used with addTearDown() |
| Helper functions vs inline code | Reusable across tests; easier to maintain; centralizes test environment configuration |

## Test Application Strategy

### Affected Test Files

1. **integration_test/calendar_integration_test.dart** (primary target)
   - 10+ tests skipped due to off-screen ThemeToggleButton
   - All tests in Task 3.4 (Calendar Theme)
   - All tests in Phase 14 (Theme Integration)

2. **Other integration tests** (preventive measure)
   - Check for similar issues in other test files
   - Apply window size configuration if needed
   - Ensure consistent test environment across all integration tests

### Test Modifications

**Before (current - ineffective)**:
```dart
testWidgets(
  'Calendar updates when theme changes',
  skip: true,  // Theme toggle button not accessible (off-screen)
  (tester) async {
    await tester.pumpWidget(/*...*/);
    await tester.ensureVisible(find.byType(ThemeToggleButton)); // Doesn't work!
    await tester.tap(find.byType(ThemeToggleButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarWidget), findsOneWidget);
  },
);
```

**After (proposed - effective)**:
```dart
setUp(() {
  setupTestWindowSize(tester);
});

testWidgets(
  'Calendar updates when theme changes',
  (tester) async {
    await tester.pumpWidget(/*...*/);
    // Button is visible at x=~835, window is 1200px wide
    await tester.tap(find.byType(ThemeToggleButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarWidget), findsOneWidget);
  },
);

tearDown(() {
  resetTestWindowSize(tester);
});
```

## Integration Points

### Flutter Test Framework

Flutter's WidgetTester provides methods to control test environment:

```dart
// Set viewport size (logical pixels become physical pixels)
tester.view.physicalSize = const Size(1200, 800);

// Set device pixel ratio (controls how logical pixels map to physical pixels)
tester.view.devicePixelRatio = 1.0;

// Trigger layout update after size change
await tester.pump();
```

**Important**: Changes to `tester.view` properties take effect immediately but require `pump()` to update layout.

### Test Isolation

Each test must have clean window state:

```dart
setUp(() {
  // Ensure consistent window size for each test
  setupTestWindowSize(tester);
});

tearDown(() {
  // Reset to default to prevent state pollution
  resetTestWindowSize(tester);
});
```

**Why Reset in tearDown?**
- Tests may modify window size (future changes)
- Subsequent tests may expect different sizes
- Prevents flaky tests due to inconsistent window state

## Trade-offs and Decisions

### Why Configure Window Size Instead of Modifying UI?

**Decision**: Keep production UI unchanged, configure test environment only

**Rationale**:
- AppBar layout is intentional (title + sync + theme buttons)
- Production users have various screen sizes, not just test constraints
- Changing UI for tests reduces clarity (shorter title, fewer buttons)
- Test environment should adapt to production, not the reverse
- Cleaner separation of concerns: production = user experience, tests = validation

### Why 1200x800 Instead of Dynamic Sizing?

**Decision**: Use fixed size instead of calculating required width dynamically

**Rationale**:
- Fixed size is simpler, more maintainable, less fragile
- Dynamic sizing requires measuring AppBar layout before each test
- 1200x800 provides ample buffer for all current and likely future layouts
- Consistency across tests (no variance in test environment)
- Follows Flutter testing best practices (standard test sizes)

### Why Remove ensureVisible() Instead of Fixing It?

**Decision**: Remove ineffective calls, solve root cause with window size

**Rationale**:
- `ensureVisible()` CANNOT work for AppBar elements (not scrollable)
- Keeping it creates false confidence (appears to solve problem, doesn't)
- Clutters test code with ineffective workarounds
- Root cause (window size) is simpler to fix
- Cleaner test code with proper solution

## Testing Coverage Impact

### Previously Skipped Tests (10+ tests)

| Test Group | Test Name | Reason for Skip |
|-----------|------------|-----------------|
| Task 3.4 | Calendar updates when theme changes | Button off-screen (835.0, 28.0) |
| Task 3.4 | Week numbers update color on theme change | Button off-screen |
| Task 14.1 | Theme toggle works while event form is open | Button off-screen |
| Task 14.1 | Theme toggle works while event details are open | Button off-screen |
| Task 14.1 | Theme toggle works while sync settings are open | Button off-screen |
| Task 14.1 | Dialogs update colors on theme change | Button off-screen |
| Task 14.2 | Calendar colors update on theme change | Button off-screen |
| Task 14.2 | Event list colors update on theme change | Button off-screen |
| Task 14.2 | Buttons and icons update on theme change | Button off-screen |
| Task 14.2 | All widgets respond consistently to theme | Button off-screen |

**Coverage Impact**: +10 test scenarios, restoring full coverage for theme integration with calendar interactions.

## Implementation Notes

### Window Size Configuration Timing

**Must happen before pumpWidget()**:
```dart
// Correct
setupTestWindowSize(tester);
await tester.pumpWidget(MyApp());

// Incorrect
await tester.pumpWidget(MyApp());
setupTestWindowSize(tester); // Too late, layout already calculated
await tester.pump(); // Requires extra pump
```

### Platform Considerations

Window size configuration works across all platforms:
- **Linux**: ✅ Primary integration test platform
- **Android**: ✅ Works in integration tests on device/emulator
- **iOS**: ✅ Works in integration tests on device/simulator
- **macOS**: ✅ Works if platform supports integration tests
- **Windows**: ✅ Works if platform supports integration tests
- **Web**: ✅ Works in web integration tests

Note: Integration tests typically run on Linux for speed and consistency, but window size configuration is platform-agnostic.

### Future Considerations

### Potential Enhancements
1. **Per-test window sizes**: Allow tests to specify different sizes (e.g., small screen tests)
2. **Window size matrix**: Run tests at multiple sizes (800x600, 1200x800, 1920x1080)
3. **Responsive layout tests**: Explicitly test app behavior at different window sizes
4. **Automated size detection**: Calculate minimum required width automatically based on AppBar layout

### Test Evolution
- If AppBar adds more action buttons in future, increase window size accordingly
- Consider responsive layout testing as first-class feature (screen sizes, orientations)
- Add window size configuration to test documentation and onboarding guides
- Monitor test execution time impact (minimal expected: ~1ms per test for size configuration)
