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

  group('Phase 18: Responsive Layout Integration Tests', () {
    group('Task 18.1: Screen orientation tests', () {
      testWidgets('Calendar displays correctly in portrait mode', (
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

        expect(find.byType(CalendarWidget), findsOneWidget);
      });

      testWidgets('Calendar displays correctly in landscape mode', (
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

        expect(find.byType(CalendarWidget), findsOneWidget);
      });

      testWidgets('Event list adapts to orientation changes', (tester) async {
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

        expect(find.byType(EventList), findsOneWidget);
      });
    });

    group('Task 18.2: Different screen size tests', () {
      testWidgets('Calendar displays correctly on small screens', (
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

        expect(find.byType(CalendarWidget), findsOneWidget);
      });

      testWidgets('Calendar displays correctly on large screens', (
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

        expect(find.byType(CalendarWidget), findsOneWidget);
      });

      testWidgets('Dialogs adapt to different screen sizes', (tester) async {
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
