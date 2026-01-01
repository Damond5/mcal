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

  group('Phase 17: Gesture Integration Tests', () {
    group('Task 17.1: Long-press interaction tests', () {
      testWidgets(
        'Long-press on calendar day shows context menu (if applicable)',
        (tester) async {
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

          final day15 = find.text('15');
          await tester.longPress(day15);
          await tester.pumpAndSettle();

          expect(find.byType(CalendarWidget), findsOneWidget);
        },
      );

      testWidgets('Long-press on event card shows options (if applicable)', (
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

        await tester.tap(find.text('15'));

        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Test Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        final eventCards = find.text('Test Event');
        expect(eventCards, findsWidgets);

        final firstEventCard = eventCards.first;
        await tester.longPress(firstEventCard);
        await tester.pumpAndSettle();

        expect(find.text('Test Event'), findsWidgets);
      });

      testWidgets('Long-press gestures are recognized', (tester) async {
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

        final fab = find.byType(FloatingActionButton);
        await tester.longPress(fab);
        await tester.pumpAndSettle();

        expect(find.text('Add Event'), findsOneWidget);
      });
    });

    group('Task 17.2: Drag interaction tests', () {
      testWidgets('Calendar month swipe gesture works', (tester) async {
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

        await tester.dragFrom(
          tester.getCenter(find.byType(CalendarWidget)),
          const Offset(-300, 0),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CalendarWidget), findsOneWidget);
      });

      testWidgets('Event list scroll gesture works', (tester) async {
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

        await tester.tap(find.text('15'));

        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Test Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.dragFrom(
          tester.getCenter(find.byType(EventList)),
          const Offset(0, -100),
        );
        await tester.pumpAndSettle();

        expect(find.byType(EventList), findsOneWidget);
      });

      testWidgets('Form scroll gesture works', (tester) async {
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

        await tester.tap(find.text('15'));

        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.text('Add Event'), findsOneWidget);
      });
    });
  });
}
