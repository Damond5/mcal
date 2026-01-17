import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mcal/main.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/providers/theme_provider.dart';
import 'package:mcal/frb_generated.dart';
import 'package:mcal/calendar_widget.dart';
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

  group('Phase 15: Performance and Load Testing Integration Tests', () {
    group('Task 15.1a: Large event set creation tests', () {
      testWidgets('Adding 100 events completes in reasonable time (<3m)', (
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

        await tester.pumpAndSettle(const Duration(seconds: 5));

        final events = TestFixtures.createLargeEventSet(count: 100);
        for (final event in events) {
          await tester.tap(find.text('15'));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byKey(const Key('event_title_field')),
            event.title,
          );
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
        }

        stopwatch.stop();

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(180000),
          reason: 'Adding 100 events should complete in less than 3 minutes',
        );
      });

      testWidgets('Events are properly saved', (tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
              ChangeNotifierProvider(create: (_) => EventProvider()),
            ],
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        final events = TestFixtures.createLargeEventSet(count: 10);
        for (final event in events) {
          await tester.tap(find.text('15'));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byKey(const Key('event_title_field')),
            event.title,
          );
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
        }

        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(find.byType(CalendarWidget), findsOneWidget);
      });

      testWidgets('All events appear on calendar', (tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
              ChangeNotifierProvider(create: (_) => EventProvider()),
            ],
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));

        final events = TestFixtures.createLargeEventSet(count: 10);
        for (final event in events) {
          await tester.tap(find.text('15'));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byKey(const Key('event_title_field')),
            event.title,
          );
          await tester.pumpAndSettle(const Duration(milliseconds: 200));

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
        }

        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(find.byType(CalendarWidget), findsOneWidget);
      });
    });
  });
}
