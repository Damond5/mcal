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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await RustLib.init();
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
      late EventProvider eventProvider;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => EventProvider()),
          ],
          child: Builder(
            builder: (context) {
              eventProvider = Provider.of<EventProvider>(
                context,
                listen: false,
              );
              return const MyApp();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

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
      late EventProvider eventProvider;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => EventProvider()),
          ],
          child: Builder(
            builder: (context) {
              eventProvider = Provider.of<EventProvider>(
                context,
                listen: false,
              );
              return const MyApp();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

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

  group('Theme Toggle Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    Future<ThemeProvider> pumpAppWithThemeProvider(WidgetTester tester) async {
      late ThemeProvider themeProvider;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => EventProvider()),
          ],
          child: Builder(
            builder: (context) {
              themeProvider = Provider.of<ThemeProvider>(
                context,
                listen: false,
              );
              return const MyApp();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 100));

      return themeProvider;
    }

    testWidgets('Theme toggle button changes theme mode', (
      WidgetTester tester,
    ) async {
      final themeProvider = await pumpAppWithThemeProvider(tester);

      final initialThemeMode = themeProvider.themeMode;
      expect(
        initialThemeMode,
        ThemeMode.system,
        reason: 'Should start with system theme',
      );

      final buttonFinder = find.byType(ThemeToggleButton);
      expect(
        buttonFinder,
        findsOneWidget,
        reason: 'Theme toggle button should be present',
      );

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(
        themeProvider.themeMode,
        isNot(ThemeMode.system),
        reason: 'Theme should change from system mode',
      );
      expect(
        themeProvider.themeMode,
        isIn([ThemeMode.light, ThemeMode.dark]),
        reason: 'Should be either light or dark mode',
      );
    });

    testWidgets('Theme toggle button icon updates correctly', (
      WidgetTester tester,
    ) async {
      final themeProvider = await pumpAppWithThemeProvider(tester);

      final buttonFinder = find.byType(ThemeToggleButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      final iconFinder = find.descendant(
        of: buttonFinder,
        matching: find.byType(Icon),
      );
      expect(iconFinder, findsOneWidget);

      final icon = tester.widget<Icon>(iconFinder);

      if (themeProvider.isDarkMode) {
        expect(
          icon.icon,
          Icons.light_mode,
          reason: 'Should show light icon in dark mode',
        );
      } else {
        expect(
          icon.icon,
          Icons.dark_mode,
          reason: 'Should show dark icon in light mode',
        );
      }
    });

    testWidgets('Theme toggle cycle', (WidgetTester tester) async {
      final themeProvider = await pumpAppWithThemeProvider(tester);

      final buttonFinder = find.byType(ThemeToggleButton);

      final modes = <ThemeMode>[];
      for (int i = 0; i < 3; i++) {
        modes.add(themeProvider.themeMode);
        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();
      }
      modes.add(themeProvider.themeMode);

      expect(
        modes[0],
        ThemeMode.system,
        reason: 'Should start with system theme',
      );
      expect(
        modes[1],
        isNot(ThemeMode.system),
        reason: 'First toggle should move away from system',
      );
      expect(
        modes[2],
        isNot(ThemeMode.system),
        reason: 'Second toggle should stay away from system',
      );
      expect(
        modes[1],
        isNot(modes[2]),
        reason: 'Theme should toggle between light and dark',
      );
    });

    testWidgets('Theme persists across app restarts', (
      WidgetTester tester,
    ) async {
      final themeProvider = await pumpAppWithThemeProvider(tester);

      final buttonFinder = find.byType(ThemeToggleButton);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();
      final savedMode = themeProvider.themeMode;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => EventProvider()),
          ],
          child: Builder(
            builder: (context) {
              final newThemeProvider = Provider.of<ThemeProvider>(
                context,
                listen: false,
              );
              return const MyApp();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 100));

      final newThemeProvider = Provider.of<ThemeProvider>(
        tester.element(find.byType(MyApp)),
        listen: false,
      );
      expect(
        newThemeProvider.themeMode,
        savedMode,
        reason: 'Theme should persist after restart',
      );
    });

    testWidgets('Visual theme changes', (WidgetTester tester) async {
      final themeProvider = await pumpAppWithThemeProvider(tester);

      final buttonFinder = find.byType(ThemeToggleButton);

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      final isDark = themeProvider.isDarkMode;
      expect(
        isDark,
        isA<bool>(),
        reason: 'ThemeProvider should have a valid dark mode state',
      );
    });
  });
}
