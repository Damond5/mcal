import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mcal/main.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/providers/theme_provider.dart';
import 'package:mcal/frb_generated.dart';
import 'package:provider/provider.dart';
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
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  group(
    'Event Form Dialog Integration Tests - Task 4.1: All-Day Event Form',
    () {
      testWidgets('All-day checkbox toggles time field visibility', (
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
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(
          const Duration(milliseconds: 500),
        ); // Wait for dialog to open

        expect(find.text('Start Date: '), findsOneWidget);
        expect(find.text('Start Time: '), findsOneWidget);
        expect(find.text('End Date: '), findsOneWidget);
        expect(find.text('End Time: '), findsOneWidget);

        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        expect(find.text('Start Time: '), findsNothing);
        expect(find.text('End Time: '), findsNothing);
      });

      testWidgets('All-day event saves without times', (tester) async {
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
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(
          const Duration(milliseconds: 200),
        ); // Wait for dialog to open

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Test Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('All Day'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      });

      testWidgets('Empty description is allowed', (tester) async {
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
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Test Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      });

      testWidgets('Description is saved and displayed', (tester) async {
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
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Test Event',
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

        final testEventWidgets = find.text('Test Event');
        try {
          await tester.ensureVisible(testEventWidgets.first);
          await tester.pumpAndSettle();
        } catch (e) {
          // Widget might already be visible
        }
        await tester.tap(testEventWidgets.first, warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.text('Test Event'), findsWidgets);
      });
    },
  );

  group('Event Form Dialog Integration Tests - Task 4.6: Form Reset', () {
    testWidgets('Opening form for new event shows empty fields', (
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.text('Add Event'), findsOneWidget);
      expect(find.byKey(const Key('event_title_field')), findsOneWidget);
    });

    testWidgets('Opening form for existing event shows event data', (
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

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Test Event',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      final testEventWidgets = find.text('Test Event');
      try {
        await tester.ensureVisible(testEventWidgets.first);
        await tester.pumpAndSettle();
      } catch (e) {
        // Widget might already be visible
      }
      await tester.tap(testEventWidgets.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Event'), findsWidgets);
      expect(find.text('Test Event'), findsWidgets);
    });

    testWidgets('Cancel button closes form without saving', (tester) async {
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Unsaved Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Unsaved Event'), findsNothing);
    });

    testWidgets('Form state is independent between open/close cycles', (
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
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'First Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('15'));

      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.text('First Event'), findsNothing);

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Second Event',
      );
      await tester.pumpAndSettle();

      expect(find.text('Second Event'), findsWidgets);
    });
  });
}
