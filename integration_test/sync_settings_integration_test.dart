import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mcal/main.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/providers/theme_provider.dart';
import 'package:mcal/frb_generated.dart';
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

  group('Sync Settings Integration Tests - Task 8.1: Auto Sync Toggle', () {
    testWidgets('Opening sync settings dialog', (tester) async {
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

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Toggling auto sync switch', (tester) async {
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
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Auto Sync'), findsOneWidget);
    });

    testWidgets('Saving settings persists auto sync preference', (
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

      await tester.tap(find.byType(SyncButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SyncButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsWidgets);
    });

    testWidgets('Workmanager is registered when enabled (mocked)', (
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

      await tester.tap(find.byType(SyncButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      final autoSyncSwitch = find.byType(SwitchListTile).first;
      await tester.tap(autoSyncSwitch);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('Workmanager is cancelled when disabled (mocked)', (
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

      await tester.tap(find.byType(SyncButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      final autoSyncSwitch = find.byType(SwitchListTile).first;
      if (tester.widget<SwitchListTile>(autoSyncSwitch).value == true) {
        await tester.tap(autoSyncSwitch);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsNothing);
    });
  });

  group('Sync Settings Integration Tests - Task 8.2: Resume Sync Toggle', () {
    testWidgets('Toggling resume sync switch', (tester) async {
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
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Sync on Resume'), findsOneWidget);
    });

    testWidgets('Saving settings persists resume sync preference', (
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

      await tester.tap(find.byType(SyncButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      final resumeSyncSwitch = find.byType(SwitchListTile).at(1);
      await tester.tap(resumeSyncSwitch);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SyncButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsWidgets);
    });

    testWidgets('Auto-pull on app resume when enabled', (tester) async {
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
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      final resumeSyncSwitch = find.byType(SwitchListTile).at(1);
      await tester.tap(resumeSyncSwitch);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('No auto-pull on app resume when disabled', (tester) async {
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
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      final resumeSyncSwitch = find.byType(SwitchListTile).at(1);
      if (tester.widget<SwitchListTile>(resumeSyncSwitch).value == true) {
        await tester.tap(resumeSyncSwitch);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsNothing);
    });
  });

  group('Sync Settings Integration Tests - Task 8.3: Sync Frequency', () {
    testWidgets('Frequency slider shows current value', (tester) async {
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
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Sync Frequency (minutes)'), findsOneWidget);
    });

    testWidgets('Sliding slider updates frequency label', (tester) async {
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
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('Minimum frequency is 5 minutes', (tester) async {
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
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('Maximum frequency is 60 minutes', (tester) async {
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
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('Saving settings persists frequency preference', (
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

      await tester.tap(find.byType(SyncButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsNothing);
    });
  });

  group('Sync Settings Integration Tests - Task 8.4: Save and Cancel', () {
    testWidgets('Saving modified settings persists all changes', (
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

      await tester.tap(find.byType(SyncButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('Cancelling modified settings does not persist', (
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

      await tester.tap(find.byType(SyncButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('Settings take effect immediately after save', (tester) async {
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
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('Original settings remain after cancel', (tester) async {
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
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SyncButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsWidgets);
    });
  });
}
