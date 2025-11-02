import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mcal/main.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/providers/theme_provider.dart';
import 'package:mcal/frb_generated.dart';
import 'package:mcal/widgets/theme_toggle_button.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await RustLib.init();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('dexterous.com/flutter/local_notifications'), (MethodCall methodCall) async {
      if (methodCall.method == 'initialize') {
        return true;
      }
      if (methodCall.method == 'requestNotificationsPermission') {
        return true;
      }
      if (methodCall.method == 'zonedSchedule') {
        return null;
      }
      if (methodCall.method == 'cancel') {
        return null;
      }
      if (methodCall.method == 'cancelAll') {
        return null;
      }
      return null;
    });
  });

  group('App Integration Tests', () {
    testWidgets('App loads and displays calendar', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => EventProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle();

      // Check if calendar is displayed
      expect(find.byType(TableCalendar), findsOneWidget);

      // Check if theme toggle is present
      expect(find.byType(ThemeToggleButton), findsOneWidget);
    });

    testWidgets('Theme toggle changes theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => EventProvider()),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find theme toggle button
      final themeButton = find.byType(ThemeToggleButton);
      expect(themeButton, findsOneWidget);

      // Initially, theme is system, icon should be brightness_6
      expect(find.byIcon(Icons.brightness_6), findsOneWidget);

      // Tap to toggle to opposite of system theme
      await tester.tap(themeButton);
      await tester.pumpAndSettle();

      // Now icon indicates the current theme mode (dark_mode for light theme, light_mode for dark theme)
      // Assuming system is dark, toggle sets to light, icon dark_mode
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    // Add more tests for event CRUD, sync, etc. as needed
  });
}