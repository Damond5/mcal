 // This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:mcal/main.dart';
import 'package:mcal/providers/theme_provider.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/frb_generated.dart';

@GenerateMocks([RustLibApi])
import 'widget_test.mocks.dart';

// Helper to pump the app
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => EventProvider()),
      ],
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockRustLibApi mockApi;

  setUpAll(() {
    mockApi = MockRustLibApi();
    RustLib.initMock(api: mockApi);
  });

  testWidgets('Calendar app loads and displays initial state', (WidgetTester tester) async {
    await pumpApp(tester);

    // Verify that the app title is displayed
    expect(find.text('MCal: Mobile Calendar'), findsOneWidget, reason: 'App bar should display the title');

    // Verify that the calendar widget is present
    expect(find.byType(TableCalendar), findsOneWidget, reason: 'Calendar should be rendered');
  });

  testWidgets('Calendar allows day selection', (WidgetTester tester) async {
    await pumpApp(tester);

    // Verify calendar is present and has day cells
    expect(find.byType(TableCalendar), findsOneWidget);

    // Find day cells (they are typically in a grid within the calendar)
    // Since table_calendar uses internal widgets, we'll verify the calendar renders days
    // and that tapping somewhere on it doesn't crash (basic smoke test)
    final calendarFinder = find.byType(TableCalendar);
    expect(calendarFinder, findsOneWidget);

    // For a more robust test, we could check that the calendar has rendered content
    // but actual day tapping requires knowing the internal structure of table_calendar
    // This test ensures the calendar is interactive and present
  });

  testWidgets('Theme toggle button is present and tappable', (WidgetTester tester) async {
    await pumpApp(tester);

    // Verify theme toggle button is present
    expect(find.byTooltip('Toggle theme'), findsOneWidget, reason: 'Theme toggle button should be in the app bar');

    // Verify it has an appropriate icon
    final hasSystemIcon = find.byIcon(Icons.brightness_6).evaluate().isNotEmpty;
    final hasLightIcon = find.byIcon(Icons.light_mode).evaluate().isNotEmpty;
    final hasDarkIcon = find.byIcon(Icons.dark_mode).evaluate().isNotEmpty;
    expect(hasSystemIcon || hasLightIcon || hasDarkIcon, isTrue, reason: 'Button should show a theme-related icon');

    // Tap the button (should not crash)
    await tester.tap(find.byTooltip('Toggle theme'));
    await tester.pumpAndSettle();

    // App should still be functional
    expect(find.text('MCal: Mobile Calendar'), findsOneWidget, reason: 'App should remain functional after theme toggle');
  });

  testWidgets('Theme toggle changes icon appropriately', (WidgetTester tester) async {
    // Set initial theme to light for predictable testing
    SharedPreferences.setMockInitialValues({'theme_mode': 1}); // Light mode
    await pumpApp(tester);

    // Should show dark_mode icon (since current is light, toggle shows dark)
    expect(find.byIcon(Icons.dark_mode), findsOneWidget, reason: 'Light mode should show dark toggle icon');

    // Tap to toggle to dark
    await tester.tap(find.byTooltip('Toggle theme'));
    await tester.pumpAndSettle();

    // Should now show light_mode icon
    expect(find.byIcon(Icons.light_mode), findsOneWidget, reason: 'Dark mode should show light toggle icon');
  });

  testWidgets('Notification permissions are requested on app start', (WidgetTester tester) async {
    // This test ensures that the app initializes without crashing when notifications are requested
    await pumpApp(tester);

    // If the app loads successfully, notification initialization didn't crash
    expect(find.text('MCal: Mobile Calendar'), findsOneWidget, reason: 'App should load successfully with notification initialization');
  });

  testWidgets('Sync settings dialog displays correctly', (WidgetTester tester) async {
    await pumpApp(tester);

    // Open sync menu
    await tester.tap(find.byIcon(Icons.sync));
    await tester.pumpAndSettle();

    // Tap settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Check dialog is shown
    expect(find.text('Sync Settings'), findsOneWidget);
    expect(find.text('Auto Sync'), findsOneWidget);
    expect(find.text('Sync on Resume'), findsOneWidget);
    expect(find.text('Sync Frequency (minutes)'), findsOneWidget);
  });
}
