# Design: Add Theme Toggle Integration Test

## Overview
This design describes the integration test implementation for verifying the theme toggle functionality end-to-end.

## Current Implementation
- Theme toggle button (`ThemeToggleButton`) calls `themeProvider.toggleTheme()` on press
- ThemeProvider persists theme mode to SharedPreferences
- Button icon changes based on current theme mode:
  - `ThemeMode.system`: Icons.brightness_6
  - `ThemeMode.light`: Icons.dark_mode
  - `ThemeMode.dark`: Icons.light_mode

## Integration Test Design

### Test Scenarios

#### Scenario 1: Theme Toggle Button Interaction
**Given** the app is loaded with system theme
**When** the theme toggle button is tapped
**Then** the theme mode changes to the opposite of current system theme
**And** the button icon updates accordingly

#### Scenario 2: Theme Toggle Cycle
**Given** the app is loaded
**When** the theme toggle button is tapped multiple times
**Then** the theme mode cycles between light and dark modes
**And** each tap updates the button icon correctly

#### Scenario 3: Theme Persistence
**Given** the app is loaded and theme is set to dark mode
**When** the app is restarted
**Then** the dark theme is restored
**And** the button icon reflects dark mode state

#### Scenario 4: Visual Theme Changes
**Given** the app is loaded
**When** the theme is toggled between light and dark
**Then** UI elements reflect the current theme colors

### Implementation Details

The integration test will:
1. Use Flutter's `integration_test` framework
2. Follow the existing pattern in `app_integration_test.dart` (lines 43-152)
3. Use `MultiProvider` wrapper with `ThemeProvider` and `EventProvider`
4. Use `tester.pumpWidget()` to render the app
5. Use `find.byType()` to locate the theme toggle button
6. Use `tester.tap()` and `tester.pumpAndSettle()` to interact
7. Use `expect()` to verify theme mode changes and icon updates
8. Restart the app by pumping a new widget instance to test persistence

#### Visual Theme Verification
Visual verification will be accomplished by:
1. **ThemeProvider state access**: Verify provider state reflects expected mode
   - Access provider via `Provider.of<ThemeProvider>(context, listen: false)`
   - Validate `themeMode` and `isDarkMode` properties
2. **Icon verification**: Verify IconButton icon matches expected Icon based on theme state
   - Use `find.byWidgetPredicate((w) => w is Icon && w.icon == Icons.dark_mode)`
   - Check for Icons.brightness_6 (system), Icons.light_mode (dark), Icons.dark_mode (light)
3. **Widget property checks**: Verify theme-specific widget properties
   - Check Material widget's `color` or `backgroundColor` properties
   - Verify text colors match expected theme colors using widget predicates

#### SharedPreferences Mocking
For isolation and test reliability, use SharedPreferences mock:
```dart
setUp(() async {
  SharedPreferences.setMockInitialValues({});
});
```

This ensures:
- Initial theme is known (mocked to specific value)
- Persistence can be verified without relying on platform state
- Tests don't interfere with each other
- Deterministic test outcomes

### Test Structure
```dart
group('Theme Toggle Integration Tests', () {
  testWidgets('Theme toggle button changes theme mode', (WidgetTester tester) async {
    // Test implementation
  });

  testWidgets('Theme toggle button icon updates correctly', (WidgetTester tester) async {
    // Test implementation
  });

  testWidgets('Theme persists across app restarts', (WidgetTester tester) async {
    // Test implementation
  });
});
```

### Verification
The test will verify:
- Button widget exists and is tappable
- ThemeProvider state changes after tap
- Button icon matches current theme mode
- Theme mode persists after app restart
- Visual elements reflect theme changes

## Considerations

### Platform Brightness
The integration test runs on real devices, so `WidgetsBinding.instance.platformDispatcher.platformBrightness` will be real. To ensure deterministic tests:
1. **Initial state**: Start from ThemeMode.system to verify real platform brightness handling
2. **Explicit mode**: After first toggle, explicitly set to light/dark to avoid platform-dependent behavior
3. **Isolation**: Use mocked preferences to ensure each test starts with clean state

This aligns with ThemeProvider.toggleTheme() logic (lib/providers/theme_provider.dart:37-49).

### Test Isolation
- Integration tests run on a real device/emulator, so platform brightness is real
- Need to handle async operations like SharedPreferences loading
- Mock SharedPreferences ensures tests don't interfere with each other
- Test should account for initial ThemeMode.system state

### Helper Methods
Consider creating test helpers for common operations to reduce code duplication:
```dart
Future<ThemeProvider> setupApp(WidgetTester tester) async {
  late ThemeProvider themeProvider;

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: Builder(
        builder: (context) {
          themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          return const MyApp();
        },
      ),
    ),
  );

  await tester.pumpAndSettle();
  return themeProvider;
}
```

### Edge Cases
While not covered in initial scope, consider testing these edge cases in future iterations:
- Theme toggle when SharedPreferences access fails
- Multiple rapid taps on theme toggle button
- Theme toggle during async operations (sync, event loading)
- Platform brightness changes while app is running

### CI/CD Considerations
- Integration tests should be added to CI pipeline for automated verification
- Consider platform-specific test execution (Android emulator, iOS simulator)
- Test timeout may need adjustment for visual verification scenarios
- Ensure test environment has consistent platform brightness or mocks it
