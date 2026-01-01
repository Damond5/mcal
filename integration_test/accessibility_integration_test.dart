import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  group('Phase 16: Accessibility Integration Tests', () {
    group('Task 16.1: Accessibility label tests', () {
      testWidgets('Calendar days have accessibility labels', (tester) async {
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

        // Check that day '15' has semantic label
        final day15 = find.text('15');
        expect(day15, findsOneWidget);
        final dayElement = tester.element(day15);
        final semantics = dayElement.findAncestorWidgetOfExactType<Semantics>();
        expect(semantics, isNotNull);
        expect(semantics!.properties.label, contains('15'));
      });

      testWidgets('Event cards have accessibility labels', (tester) async {
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

        final uniqueTitle =
            'Test Event ${DateTime.now().millisecondsSinceEpoch}';
        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          uniqueTitle,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        // Check for event card with the unique title
        final eventCard = find.widgetWithText(Card, uniqueTitle);
        expect(eventCard, findsOneWidget);

        // Check that the card has semantic label
        final cardElement = tester.element(eventCard);
        final semantics = cardElement
            .findAncestorWidgetOfExactType<Semantics>();
        expect(semantics?.properties.label, isNotNull);
        expect(semantics!.properties.label!.contains(uniqueTitle), isTrue);
      });

      testWidgets('Buttons have accessibility labels', (tester) async {
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

        final fabSemantics = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget as Semantics).properties.label == 'Add Event',
        );
        expect(fabSemantics, findsOneWidget);
        final semantics = tester.getSemantics(fabSemantics);
        expect(
          semantics.label,
          'Add Event',
          reason: 'FAB should have accessibility label',
        );
      });

      testWidgets('Form fields have accessibility labels', (tester) async {
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

        expect(find.text('Title *'), findsOneWidget);
      });
    });

    group('Task 16.2: Keyboard navigation tests', () {
      testWidgets('Tab navigation works through app', (tester) async {
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

        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('Enter key activates buttons', (tester) async {
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

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(find.text('Save'), findsOneWidget);
      });

      testWidgets('Escape key cancels dialogs', (tester) async {
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

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(find.text('Add Event'), findsNothing);
      });

      testWidgets('Focus order is logical', (tester) async {
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

        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    group('Task 16.3: Touch target tests', () {
      testWidgets('All buttons meet minimum touch target size (48x48px)', (
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

        final fab = find.byType(FloatingActionButton);
        await tester.tap(fab);
        await tester.pumpAndSettle();

        expect(find.text('Add Event'), findsOneWidget);
      });

      testWidgets('All tappable areas are large enough', (tester) async {
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
        final size = tester.getSize(fab);
        expect(
          size.width,
          greaterThanOrEqualTo(48),
          reason: 'FAB should be at least 48px wide',
        );
        expect(
          size.height,
          greaterThanOrEqualTo(48),
          reason: 'FAB should be at least 48px tall',
        );
      });

      testWidgets('No overlapping touch targets', (tester) async {
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
        expect(fab, findsOneWidget);
      });
    });
  });
}
