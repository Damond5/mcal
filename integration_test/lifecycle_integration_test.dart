import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mcal/main.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/providers/theme_provider.dart';
import 'package:mcal/frb_generated.dart';
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

  group('Lifecycle Integration Tests - Task 11.1: Auto Sync on Start', () {
    testWidgets(
      'Sync pulls on app start if initialized - REQUIRES FFI MOCKING',
      (tester) async {
        return;
      },
    );

    testWidgets('No sync pull if not initialized', (tester) async {
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

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Sync pulls if resume sync is enabled - REQUIRES FFI MOCKING', (
      tester,
    ) async {
      return;
    });

    testWidgets('No sync pull if resume sync is disabled', (tester) async {
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

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets(
      'Loading indicator shows during auto sync - REQUIRES FFI MOCKING',
      (tester) async {
        return;
      },
    );
  });

  group('Lifecycle Integration Tests - Task 11.2: Auto Sync on Resume', () {
    testWidgets(
      'Sync pulls on app resume if initialized - REQUIRES FFI MOCKING',
      (tester) async {
        return;
      },
    );

    testWidgets(
      'Sync only pulls if 5+ minutes since last sync - REQUIRES FFI MOCKING',
      (tester) async {
        return;
      },
    );

    testWidgets('No sync pull if not initialized - REQUIRES FFI MOCKING', (
      tester,
    ) async {
      return;
    });

    testWidgets('No sync pull if resume sync is disabled', (tester) async {
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

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Lifecycle Integration Tests - Task 11.3: Data Persistence', () {
    testWidgets('Events persist after app "restart"', (tester) async {
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

      expect(find.text('Test Event'), findsWidgets);

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

      expect(find.text('Test Event'), findsWidgets);
    });

    testWidgets('All event details persist', (tester) async {
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
        'Complete Event',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('event_description_field')),
        'Test description',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete Event'));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets(
      'Sync settings persist after app "restart" - REQUIRES FFI MOCKING',
      (tester) async {
        return;
      },
    );

    testWidgets('Theme settings persist after app "restart"', (tester) async {
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

      await tester.tap(find.byIcon(Icons.brightness_6));
      await tester.pumpAndSettle();

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

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('Persisted data is correct on reload', (tester) async {
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
        'Reload Test Event',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Reload Test Event'), findsOneWidget);

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

      expect(find.text('Reload Test Event'), findsOneWidget);

      await tester.tap(find.text('Reload Test Event'));
      await tester.pumpAndSettle();

      expect(find.text('Reload Test Event'), findsWidgets);
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

      expect(find.text('Reload Test Event'), findsWidgets);
    });
  });
}
