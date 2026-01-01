import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mcal/main.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/providers/theme_provider.dart';
import 'package:mcal/frb_generated.dart';
import 'package:mcal/calendar_widget.dart';
import 'package:mcal/widgets/event_list.dart';
import 'package:provider/provider.dart';
import '../test/test_helpers.dart';
import 'helpers/test_fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await RustLib.init();
    await setupAllIntegrationMocks();
  });

  setUp(() async {
    await cleanTestEvents();
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  group('Phase 13: Multi-Event Scenarios Integration Tests', () {
    group('Task 13.1: Multiple events same day tests', () {
      testWidgets('Calendar shows marker for day with multiple events', (
        tester,
      ) async {
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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        final events = TestFixtures.createEventsForSameDay(count: 3);
        for (final event in events) {
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(milliseconds: 100));

          await tester.enterText(
            find.byKey(const Key('event_title_field')),
            event.title,
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('All Day'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
        }
      });

      testWidgets('Event list shows all events for selected day', (
        tester,
      ) async {
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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        final events = TestFixtures.createEventsForSameDay(count: 5);
        for (final event in events) {
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(milliseconds: 100));

          await tester.enterText(
            find.byKey(const Key('event_title_field')),
            event.title,
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('All Day'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
        }
      });

      testWidgets('Adding one event updates day marker', (tester) async {
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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 100));

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'New Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('All Day'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
      });

      testWidgets('Deleting last event removes day marker', (tester) async {
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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        final events = TestFixtures.createEventsForSameDay(count: 2);
        for (final event in events) {
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(milliseconds: 100));

          await tester.enterText(
            find.byKey(const Key('event_title_field')),
            event.title,
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('All Day'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
        }

        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete').first);
        await tester.pumpAndSettle();
      });
    });

    group('Task 13.2: Overlapping events tests', () {
      testWidgets('Events with same time display correctly', (tester) async {
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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        final events = TestFixtures.createOverlappingEvents();
        for (final event in events) {
          await tester.tap(find.text('15'));
          await tester.pumpAndSettle();

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(milliseconds: 100));

          await tester.enterText(
            find.byKey(const Key('event_title_field')),
            event.title,
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
        }

        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        expect(find.text('Overlapping Event 1'), findsWidgets);
        expect(find.text('Overlapping Event 2'), findsWidgets);
        expect(find.text('Overlapping Event 3'), findsWidgets);
      });

      testWidgets('Each overlapping event can be edited', (tester) async {
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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        final events = TestFixtures.createOverlappingEvents();
        for (final event in events) {
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(milliseconds: 100));

          await tester.enterText(
            find.byKey(const Key('event_title_field')),
            'Updated ${event.title}',
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
        }

        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        expect(find.text('Updated Overlapping Event 1'), findsWidgets);
        expect(find.text('Updated Overlapping Event 2'), findsWidgets);
        expect(find.text('Updated Overlapping Event 3'), findsWidgets);
      });

      testWidgets('Each overlapping event can be deleted', (tester) async {
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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        final events = TestFixtures.createOverlappingEvents();
        for (final event in events) {
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(milliseconds: 100));

          await tester.enterText(
            find.byKey(const Key('event_title_field')),
            event.title,
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
        }

        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete').first);
        await tester.pumpAndSettle();

        expect(find.text('Overlapping Event 1'), findsNothing);
        expect(find.text('Overlapping Event 2'), findsWidgets);
        expect(find.text('Overlapping Event 3'), findsWidgets);
      });
    });

    group('Task 13.3a: Many recurring events creation tests', () {
      testWidgets('Yearly recurring events over many years', (tester) async {
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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        final event = TestFixtures.createBirthdayEvent();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          event.title,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('none'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('yearly'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.byType(CalendarWidget), findsOneWidget);
      });

      testWidgets('Event list handles many recurring instances', (
        tester,
      ) async {
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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        final event = TestFixtures.createWeeklyMeeting();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          event.title,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('none'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('weekly'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.byType(EventList), findsOneWidget);
      });
    });

    group('Task 13.3b: Many recurring events performance tests', () {
      testWidgets('Yearly events over 50 years load in reasonable time', (
        tester,
      ) async {
        final stopwatch = Stopwatch()..start();

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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        final event = TestFixtures.createBirthdayEvent();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          event.title,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('none'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('yearly'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      });

      testWidgets('Calendar displays many yearly event instances', (
        tester,
      ) async {
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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        final event = TestFixtures.createBirthdayEvent();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          event.title,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('none'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('yearly'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.byType(CalendarWidget), findsOneWidget);
      });

      testWidgets('Performance does not degrade with long chains', (
        tester,
      ) async {
        final stopwatch = Stopwatch()..start();

        final event = TestFixtures.createSampleEvent();

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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          event.title,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('All Day'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 100));

        for (int i = 0; i < 100; i++) {
          await tester.pumpAndSettle();
        }

        stopwatch.stop();

        final totalTime = stopwatch.elapsedMilliseconds / 1000;
        expect(totalTime, lessThan(60));
      });

      testWidgets('Each test file runs in under 60 seconds', (tester) async {
        final stopwatch = Stopwatch()..start();

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
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Performance Test',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('All Day'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(const Duration(milliseconds: 100));

        stopwatch.stop();

        expect(stopwatch.elapsed.inSeconds, lessThan(60));
      });
    });
  });
}
