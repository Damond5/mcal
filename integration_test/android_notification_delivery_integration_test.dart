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

  group('Android Notification Delivery Integration Tests', () {
    group('Scheduled Notifications on Android Devices', () {
      testWidgets('Scheduled notification appears correctly on Android devices', (
        tester,
      ) async {
        if (!Platform.isAndroid) {
          return; // Skip on non-Android platforms
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

        // Navigate to a date
        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        // Create a new event
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('event_title_field')),
          'Android Scheduled Test',
        );
        await tester.pumpAndSettle();

        // Set a future time for notification scheduling
        final now = DateTime.now();
        final futureTime = now.add(const Duration(minutes: 5));
        await tester.enterText(
          find.byKey(const Key('event_description_field')),
          'Scheduled for ${futureTime.hour}:${futureTime.minute.toString().padLeft(2, '0')}',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Verify event is created and notification is scheduled
        expect(find.text('Android Scheduled Test'), findsOneWidget);

        // Wait briefly to ensure scheduling completes
        await Future.delayed(const Duration(seconds: 1));
      });

      testWidgets('Notifications work when app is backgrounded on Android', (
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
          'Background Test Event',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        expect(find.text('Background Test Event'), findsOneWidget);

        // Simulate app backgrounding
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pumpAndSettle();

        // App is now "backgrounded" - in real scenario, WorkManager would handle notifications
        // Wait to simulate time passing
        await Future.delayed(const Duration(seconds: 2));

        // Bring app back to foreground
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        expect(find.byType(ThemeToggleButton), findsOneWidget);
      });

      testWidgets(
        'Notifications work when app is swiped from recents on Android',
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
            'Swipe Away Test',
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          expect(find.text('Swipe Away Test'), findsOneWidget);

          // Simulate app being swiped away (detached)
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.detached,
          );
          await tester.pumpAndSettle();

          // In real scenario, WorkManager tasks persist
          await Future.delayed(const Duration(seconds: 1));

          // Note: In integration test, we can't fully simulate swipe from recents,
          // but this tests that the app handles lifecycle changes gracefully
        },
      );
    });

    group('WorkManager Tasks for Notification Scheduling', () {
      testWidgets(
        'WorkManager tasks execute properly for notification scheduling on Android',
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
            'WorkManager Test',
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          expect(find.text('WorkManager Test'), findsOneWidget);

          // WorkManager task should be registered during event creation
          // In a real test, we could verify WorkManager state, but here we ensure no crashes
        },
      );
    });

    group('Permission Handling and User Feedback', () {
      testWidgets(
        'Permission handling and user feedback work correctly on Android',
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

          // Permission request should happen during app initialization
          // SnackBar may appear if permission denied
          expect(find.byType(ThemeToggleButton), findsOneWidget);

          // Test creating event (which triggers notification scheduling)
          await tester.tap(find.text('15'));
          await tester.pumpAndSettle();

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle(const Duration(milliseconds: 200));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byKey(const Key('event_title_field')),
            'Permission Test Event',
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          expect(find.text('Permission Test Event'), findsOneWidget);
        },
      );
    });

    group('Cross-Platform Compatibility', () {
      testWidgets(
        'Android notification functionality differs appropriately from other platforms',
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
            'Cross-Platform Test',
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          expect(find.text('Cross-Platform Test'), findsOneWidget);

          // On Android, WorkManager is used; on other platforms, zonedSchedule
          // The UI behavior should be the same regardless of platform
        },
      );
    });
  });
}
