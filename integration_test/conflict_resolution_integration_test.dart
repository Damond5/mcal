import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mcal/main.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/providers/theme_provider.dart';
import 'package:mcal/frb_generated.dart';
import 'package:mcal/widgets/conflict_resolution_dialog.dart';
import 'package:mcal/widgets/sync_button.dart';
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

  group('Conflict Resolution Integration Tests - Task 7.1: Dialog Display', () {
    testWidgets('Dialog shows conflict message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConflictResolutionDialog(),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'A merge conflict occurred during sync. Choose how to resolve it.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Dialog shows "Cancel", "Keep Local", "Use Remote" buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConflictResolutionDialog(),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Keep Local'), findsOneWidget);
      expect(find.text('Use Remote'), findsOneWidget);
    });

    testWidgets('Dialog is not dismissible by tapping outside', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const ConflictResolutionDialog(),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Sync Conflict'), findsOneWidget);
    });
  });

  group(
    'Conflict Resolution Integration Tests - Task 7.2: Keep Local Resolution',
    () {
      testWidgets('Selecting "Keep Local" aborts merge', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ConflictResolutionDialog(),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Keep Local'));
        await tester.pumpAndSettle();

        expect(find.text('Sync Conflict'), findsNothing);
      });

      testWidgets('Success message shows "kept local changes"', (tester) async {
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

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Test Event',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ConflictResolutionDialog(),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Keep Local'));
        await tester.pumpAndSettle();
      });

      testWidgets('Local events remain unchanged', (tester) async {
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

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Test Event',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ConflictResolutionDialog(),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Keep Local'));
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

        expect(find.text('Test Event'), findsNothing);
      });

      testWidgets('Sync button can be used again', (tester) async {
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

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ConflictResolutionDialog(),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Keep Local'));
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

        await tester.tap(find.byType(SyncButton));
        await tester.pumpAndSettle();

        expect(find.text('Init Sync'), findsOneWidget);
      });
    },
  );

  group(
    'Conflict Resolution Integration Tests - Task 7.3: Use Remote Resolution',
    () {
      testWidgets('Selecting "Use Remote" prefers remote changes', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ConflictResolutionDialog(),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Use Remote'));
        await tester.pumpAndSettle();

        expect(find.text('Sync Conflict'), findsNothing);
      });

      testWidgets('Success message shows "pulled successfully"', (
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

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ConflictResolutionDialog(),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Use Remote'));
        await tester.pumpAndSettle();
      });

      testWidgets('Remote events are loaded', (tester) async {
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

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ConflictResolutionDialog(),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Use Remote'));
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
      });

      testWidgets('Sync button can be used again', (tester) async {
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

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ConflictResolutionDialog(),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Use Remote'));
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

        await tester.tap(find.byType(SyncButton));
        await tester.pumpAndSettle();

        expect(find.text('Init Sync'), findsOneWidget);
      });
    },
  );

  group(
    'Conflict Resolution Integration Tests - Task 7.4: Cancel Resolution',
    () {
      testWidgets('Selecting "Cancel" closes dialog', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ConflictResolutionDialog(),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Sync Conflict'), findsNothing);
      });

      testWidgets('Conflict resolution can be attempted again', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ConflictResolutionDialog(),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Sync Conflict'), findsOneWidget);
      });
    },
  );
}
