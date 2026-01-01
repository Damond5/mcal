import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mcal/main.dart';
import 'package:mcal/models/event.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/providers/theme_provider.dart';
import 'package:mcal/frb_generated.dart';
import 'package:mcal/widgets/theme_toggle_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../test/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await RustLib.init();
    await setupAllIntegrationMocks();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          (MethodCall methodCall) async {
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
          },
        );
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  group('App Integration Tests', () {
    testWidgets('App loads and displays calendar', (WidgetTester tester) async {
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

      expect(find.byType(TableCalendar), findsOneWidget);
      expect(find.byType(ThemeToggleButton), findsOneWidget);
    });

    testWidgets('Yearly recurrence is valid in Event model', (
      WidgetTester tester,
    ) async {
      final validRecurrences = Event.validRecurrences;
      expect(validRecurrences, contains('yearly'));
    });

    testWidgets('Yearly event expansion works correctly', (
      WidgetTester tester,
    ) async {
      final event = Event(
        title: 'Leap Day Event',
        startDate: DateTime(2020, 2, 29),
        recurrence: 'yearly',
      );

      final expanded = Event.expandRecurring(event, DateTime(2021, 12, 31));

      expect(expanded.length, greaterThan(1));

      final nonLeapInstance = expanded.firstWhere(
        (e) => e.startDate.year == 2021,
        orElse: () => throw StateError('No 2021 instance found'),
      );

      expect(nonLeapInstance.startDate.day, 28);
      expect(nonLeapInstance.startDate.month, 2);
    });

    testWidgets('Yearly recurrence preserves time across years', (
      WidgetTester tester,
    ) async {
      final event = Event(
        title: 'Timed Yearly Event',
        startDate: DateTime(2023, 6, 15, 14, 30),
        recurrence: 'yearly',
      );

      final expanded = Event.expandRecurring(event, DateTime(2025, 12, 31));
      final nextYearInstance = expanded.firstWhere(
        (e) => e.startDate.year == 2024,
        orElse: () => throw StateError('No 2024 instance found'),
      );

      expect(nextYearInstance.startDate.hour, 14);
      expect(nextYearInstance.startDate.minute, 30);
    });
  });
}
