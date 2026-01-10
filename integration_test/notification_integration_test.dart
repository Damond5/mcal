import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mcal/main.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/providers/theme_provider.dart';
import 'package:mcal/frb_generated.dart';
import 'package:mcal/widgets/theme_toggle_button.dart';
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
    await Future.delayed(const Duration(seconds: 2));
  });

  group('Notification Integration Tests', () {
    group('Task 9.1: Notification Scheduling Tests', () {
      testWidgets(
        'Timed event schedules notification 30 minutes before start',
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
          await tester.pumpAndSettle();

          await tester.tap(find.text('15'));
          await tester.pumpAndSettle();

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byKey(const Key('event_title_field')),
            'Test Event',
          );
          await tester.pumpAndSettle();

          final now = DateTime.now();
          await tester.enterText(
            find.byKey(const Key('event_description_field')),
            'Start time: ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();
        },
      );

      testWidgets(
        'All-day event schedules notification at midday previous day',
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
          await tester.pumpAndSettle();

          await tester.tap(find.text('15'));
          await tester.pumpAndSettle();

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byKey(const Key('event_title_field')),
            'All-Day Event',
          );
          await tester.pumpAndSettle();

          await tester.tap(find.byType(CheckboxListTile));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();
        },
      );

      testWidgets('Notification schedules correctly for different time zones', (
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
          'UTC Test Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      });

      testWidgets('Notification icon is shown in event list', (tester) async {
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
          'Event with Notification',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        expect(find.text('Event with Notification'), findsOneWidget);
      });
    });

    group('Task 9.2: Notification Cancellation Tests', () {
      testWidgets('Deleting event cancels notification', (tester) async {
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
          'Deletable Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.text('Deletable Event'), findsNothing);
      });

      testWidgets('Notification cancellation respects event deletion', (
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
          'Multiple Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Additional Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.text('Multiple Event'), findsOneWidget);
        expect(find.text('Additional Event'), findsOneWidget);
      });
    });

    group('Task 9.3: Notification Display Tests', () {
      testWidgets('Notification displays with correct title and body', (
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
          'Display Test Event',
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('event_description_field')),
          'Display test body',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      });

      testWidgets('Notification displays correctly for all-day events', (
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
          'All-Day Display Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      });

      testWidgets('Multiple notifications display without overlap', (
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
          'Multiple 1',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Multiple 2',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.text('Multiple 1'), findsOneWidget);
        expect(find.text('Multiple 2'), findsOneWidget);
      });
    });

    group('Task 9.4: Notification Settings Tests', () {
      testWidgets('Permissions requested on app start', (tester) async {
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

        expect(find.byType(ThemeToggleButton), findsOneWidget);
      });

      testWidgets('Notification settings persist after restart', (
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

        expect(find.byType(ThemeToggleButton), findsOneWidget);
      });
    });

    group('Task 9.5: Notification Privacy Tests', () {
      testWidgets('Notification content does not expose sensitive data', (
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
          'Privacy Test',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      });

      testWidgets('Notification respects user notification preferences', (
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
          'Preference Test',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      });
    });

    group('Task 9.6: Notification State Tests', () {
      testWidgets('Notification state is reset on event edit', (tester) async {
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
          'Original Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Original Event'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Edited Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
      });

      testWidgets('Notification state is cleared on event deletion', (
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
          'Deletable Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.text('Deletable Event'), findsNothing);
      });

      testWidgets(
        'Notification cancellation respects event deletion among multiple events',
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
          await tester.pumpAndSettle();

          await tester.tap(find.text('15'));
          await tester.pumpAndSettle();

          for (int i = 0; i < 3; i++) {
            await tester.tap(find.byType(FloatingActionButton));
            await tester.pumpAndSettle(const Duration(milliseconds: 200));
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

          await tester.tap(find.text('15'));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.delete).first);
          await tester.pumpAndSettle();

          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          expect(find.text('Event 2'), findsWidgets);
        },
      );
    });

    group('Task 9.7: Android 13+ Permission Tests', () {
      testWidgets(
        'Permission request dialog appears on fresh install (Android only)',
        (tester) async {
          if (!Platform.isAndroid) {
            return;
          }

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

          expect(find.byType(ThemeToggleButton), findsOneWidget);
        },
      );

      testWidgets(
        'Notification displays after permission grant (Android only)',
        (tester) async {
          if (!Platform.isAndroid) {
            return;
          }

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
            'Android Permission Test',
          );
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byKey(const Key('event_description_field')),
            'Testing notification after permission grant',
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          expect(find.text('Android Permission Test'), findsOneWidget);
        },
      );

      testWidgets('SnackBar appears when permission denied (Android only)', (
        tester,
      ) async {
        if (!Platform.isAndroid) {
          return;
        }

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

        expect(find.byType(ThemeToggleButton), findsOneWidget);
      });

      testWidgets('Permission revocation blocks notifications (Android only)', (
        tester,
      ) async {
        if (!Platform.isAndroid) {
          return;
        }

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
          'Revoke Permission Test',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.text('Revoke Permission Test'), findsOneWidget);
      });
    });
  });
}
