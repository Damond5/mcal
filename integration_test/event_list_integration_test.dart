import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mcal/main.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/providers/theme_provider.dart';
import 'package:mcal/frb_generated.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mcal/widgets/event_list.dart';
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

  group('Event List Integration Tests - Task 5.1: Empty State', () {
    testWidgets('"No events for this day" message when no events', (
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

      expect(find.byType(EventList), findsOneWidget);
      expect(find.text('No events for this day'), findsOneWidget);
    });

    testWidgets('Event card shows event time (formatted)', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Time Test Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Time Test Event'), findsOneWidget);
      expect(find.textContaining('OK'), findsNothing);
    });

    testWidgets('Event card shows event description (if present)', (
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Description Test Event',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_description_field')),
        'Test description',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Description Test Event'));
      await tester.pumpAndSettle();

      expect(find.text('Description: Test description'), findsOneWidget);
    });

    testWidgets('All-day events show "All day" time', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'All Day Test Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('All day'), findsOneWidget);
    });

    testWidgets('Multi-day events show date range', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Multi-Day Test Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('All day'), findsOneWidget);
    });
  });

  group('Event List Integration Tests - Task 5.3: Event Details Dialog', () {
    testWidgets('Tapping event card opens details dialog', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Details Dialog Test Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Details Dialog Test Event'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('Details dialog shows event title', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Title Test Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Title Test Event'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('Details dialog shows event date and time', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Date Time Test Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Date Time Test Event'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Date:'), findsOneWidget);
      expect(find.textContaining('Time:'), findsOneWidget);
    });

    testWidgets('Details dialog shows event description', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Description Details Test Event',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_description_field')),
        'Test description',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Description Details Test Event'));
      await tester.pumpAndSettle();

      expect(find.text('Description: Test description'), findsOneWidget);
    });

    testWidgets('Details dialog shows recurrence (if set)', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Weekly Test Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('none'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('weekly'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weekly Test Event'));
      await tester.pumpAndSettle();

      expect(find.text('Recurrence: weekly'), findsOneWidget);
    });
  });

  group('Event List Integration Tests - Task 5.4: Event Delete Action', () {
    testWidgets('Delete button appears on event card', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Delete Button Test Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('Tapping delete shows confirmation dialog', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Delete Confirm Test Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Delete Event'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to delete "Delete Confirm Test Event"?',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Confirming delete removes event', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Delete Confirm Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Confirm Event'), findsNothing);
    });

    testWidgets('Cancelling delete keeps event', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Cancel Delete Test Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Delete Test Event'), findsOneWidget);
    });
  });

  group('Event List Integration Tests - Task 5.5: Multiple Events', () {
    testWidgets('Event list shows multiple events for same day', (
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

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
        ); // Wait for dialog

        // Check if All Day checkbox exists and tap it to make event all-day
        final allDayCheckbox = find.byWidgetPredicate(
          (widget) =>
              widget is CheckboxListTile &&
              (widget as CheckboxListTile).title.toString().contains('All Day'),
        );
        if (allDayCheckbox.evaluate().isNotEmpty) {
          await tester.tap(allDayCheckbox);
          await tester.pumpAndSettle();
        }

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Event $i',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
        ); // Wait for dialog close
      }

      await tester.pumpAndSettle();

      expect(find.text('Event 0'), findsOneWidget);
      expect(find.text('Event 1'), findsOneWidget);
      expect(find.text('Event 2'), findsOneWidget);
    });

    testWidgets('Events are ordered by time (chronological)', (tester) async {
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

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Event $i',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      }

      await tester.pumpAndSettle();

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Deleting one event does not affect others', (tester) async {
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

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Event $i',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      }

      await tester.pumpAndSettle();

      final event0Card = find.ancestor(
        of: find.text('Event 0'),
        matching: find.byType(Card),
      );
      final deleteButton0 = find.descendant(
        of: event0Card,
        matching: find.byIcon(Icons.delete),
      );

      await tester.tap(deleteButton0);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Event 0'), findsNothing);
      expect(find.text('Event 1'), findsOneWidget);
      expect(find.text('Event 2'), findsOneWidget);
    });

    testWidgets('Editing one event does not affect others', (tester) async {
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

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Event $i',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      }

      await tester.pumpAndSettle();

      await tester.tap(find.text('Event 0').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Updated Event 0',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Updated Event 0'), findsOneWidget);
      expect(find.text('Event 1'), findsOneWidget);
      expect(find.text('Event 2'), findsOneWidget);
    });
  });
}
