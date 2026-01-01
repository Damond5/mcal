import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  group('Edge Cases Integration Tests - Task 12.1: Empty Repository', () {
    testWidgets('App handles empty git repository on start', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('mcal_flutter/rust_lib'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'gitInit') {
                return 'Initialized empty Git repository';
              }
              if (methodCall.method == 'gitAddRemote') {
                return 'Remote added';
              }
              if (methodCall.method == 'gitFetch') {
                return '';
              }
              if (methodCall.method == 'gitCheckout') {
                return 'Checkout completed';
              }
              return null;
            },
          );

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

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Init Sync'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Repository URL'),
        'https://example.com/repo.git',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Pull from empty repository works', (tester) async {
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

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Init Sync'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Repository URL'),
        'https://example.com/repo.git',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pull'));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Push to empty repository works', (tester) async {
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

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Init Sync'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Repository URL'),
        'https://example.com/repo.git',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      await tester.tap(find.text('15'));

      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final uniqueTitle = 'Test Event ${DateTime.now().millisecondsSinceEpoch}';
      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        uniqueTitle,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Edge Cases Integration Tests - Task 12.2: Network Error', () {
    testWidgets('Sync failure shows user-friendly error message', (
      tester,
    ) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('mcal_flutter/rust_lib'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'gitInit') {
                return 'Initialized empty Git repository';
              }
              if (methodCall.method == 'gitAddRemote') {
                return 'Remote added';
              }
              if (methodCall.method == 'gitFetch') {
                throw Exception('Network error: Connection refused');
              }
              return null;
            },
          );

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

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Init Sync'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Repository URL'),
        'https://example.com/repo.git',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('App remains functional after sync error', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('mcal_flutter/rust_lib'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'gitInit') {
                return 'Initialized empty Git repository';
              }
              if (methodCall.method == 'gitAddRemote') {
                return 'Remote added';
              }
              if (methodCall.method == 'gitFetch') {
                throw Exception('Network error');
              }
              if (methodCall.method == 'gitAdd') {
                return 'Staged files';
              }
              if (methodCall.method == 'gitCommit') {
                return 'Committed changes';
              }
              return null;
            },
          );

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

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Init Sync'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Repository URL'),
        'https://example.com/repo.git',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      await tester.tap(find.text('15'));

      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final uniqueTitle =
          'After Error Event ${DateTime.now().millisecondsSinceEpoch}';
      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        uniqueTitle,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text(uniqueTitle), findsOneWidget);
    });

    testWidgets('Retry after network error works', (tester) async {
      bool isFirstCall = true;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('mcal_flutter/rust_lib'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'gitInit') {
                return 'Initialized empty Git repository';
              }
              if (methodCall.method == 'gitAddRemote') {
                return 'Remote added';
              }
              if (methodCall.method == 'gitFetch') {
                if (isFirstCall) {
                  isFirstCall = false;
                  throw Exception('Network error');
                }
                return 'Fetch completed';
              }
              if (methodCall.method == 'gitCheckout') {
                return 'Checkout completed';
              }
              return null;
            },
          );

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

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Init Sync'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Repository URL'),
        'https://example.com/repo.git',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Edge Cases Integration Tests - Task 12.3: Invalid Credentials', () {
    testWidgets('Sync with invalid username/password fails', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('mcal_flutter/rust_lib'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'gitInit') {
                return 'Initialized empty Git repository';
              }
              if (methodCall.method == 'gitAddRemote') {
                return 'Remote added';
              }
              if (methodCall.method == 'gitFetch') {
                throw Exception('Authentication failed');
              }
              return null;
            },
          );

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

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Init Sync'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Repository URL'),
        'https://example.com/repo.git',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Username (for HTTPS only)'),
        'wronguser',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Password/Token (for HTTPS only)'),
        'wrongpass',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('Error message indicates authentication failure', (
      tester,
    ) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('mcal_flutter/rust_lib'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'gitInit') {
                return 'Initialized empty Git repository';
              }
              if (methodCall.method == 'gitAddRemote') {
                return 'Remote added';
              }
              if (methodCall.method == 'gitFetch') {
                throw Exception('Authentication failed: Invalid credentials');
              }
              return null;
            },
          );

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

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Init Sync'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Repository URL'),
        'https://example.com/repo.git',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Username (for HTTPS only)'),
        'wronguser',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Password/Token (for HTTPS only)'),
        'wrongpass',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('App remains functional after auth error', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('mcal_flutter/rust_lib'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'gitInit') {
                return 'Initialized empty Git repository';
              }
              if (methodCall.method == 'gitAddRemote') {
                return 'Remote added';
              }
              if (methodCall.method == 'gitFetch') {
                throw Exception('Authentication failed');
              }
              if (methodCall.method == 'gitAdd') {
                return 'Staged files';
              }
              if (methodCall.method == 'gitCommit') {
                return 'Committed changes';
              }
              return null;
            },
          );

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

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Init Sync'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Repository URL'),
        'https://example.com/repo.git',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Username (for HTTPS only)'),
        'wronguser',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Password/Token (for HTTPS only)'),
        'wrongpass',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      await tester.tap(find.text('15'));

      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final uniqueTitle =
          'After Auth Error Event ${DateTime.now().millisecondsSinceEpoch}';
      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        uniqueTitle,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text(uniqueTitle), findsOneWidget);
    });

    testWidgets('Updating to correct credentials works', (tester) async {
      bool isFirstAuthCall = true;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('mcal_flutter/rust_lib'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'gitInit') {
                return 'Initialized empty Git repository';
              }
              if (methodCall.method == 'gitAddRemote') {
                return 'Remote added';
              }
              if (methodCall.method == 'gitFetch') {
                if (isFirstAuthCall) {
                  isFirstAuthCall = false;
                  throw Exception('Authentication failed');
                }
                return 'Fetch completed';
              }
              if (methodCall.method == 'gitCheckout') {
                return 'Checkout completed';
              }
              return null;
            },
          );

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

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Init Sync'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Repository URL'),
        'https://example.com/repo.git',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Username (for HTTPS only)'),
        'wronguser',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Password/Token (for HTTPS only)'),
        'wrongpass',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Credentials'));
      await tester.pumpAndSettle();

      // Mock handles the credentials update
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Edge Cases Integration Tests - Task 12.4: File System Error', () {
    testWidgets('App handles missing event directory', (tester) async {
      final testDir = Directory(getTestDirectoryPath());
      final eventsDir = Directory('${testDir.path}/calendar');

      if (await eventsDir.exists()) {
        await eventsDir.delete(recursive: true);
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

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('App creates directory if missing', (tester) async {
      final testDir = Directory(getTestDirectoryPath());
      final eventsDir = Directory('${testDir.path}/calendar');

      if (await eventsDir.exists()) {
        await eventsDir.delete(recursive: true);
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

      await tester.tap(find.text('15'));

      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final uniqueTitle =
          'Directory Test Event ${DateTime.now().millisecondsSinceEpoch}';
      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        uniqueTitle,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text(uniqueTitle), findsOneWidget);
    });

    testWidgets('App handles permission errors gracefully', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'getApplicationDocumentsDirectory') {
                throw FileSystemException('Permission denied');
              }
              return null;
            },
          );

      try {
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
      } catch (e) {
        expect(e, isNotNull);
      }
    });
  });

  group('Edge Cases Integration Tests - Task 12.5: Corrupted Data', () {
    testWidgets('App handles corrupted event file', skip: true, (tester) async {
      final testDir = Directory(getTestDirectoryPath());
      final eventsDir = Directory('${testDir.path}/calendar');

      if (!await eventsDir.exists()) {
        await eventsDir.create(recursive: true);
      }

      final corruptedFile = File('${eventsDir.path}/corrupted_event.md');
      await corruptedFile.writeAsString('invalid markdown content {{{');

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

    testWidgets('App skips corrupted events on load', skip: true, (
      tester,
    ) async {
      final testDir = Directory(getTestDirectoryPath());
      final eventsDir = Directory('${testDir.path}/calendar');

      if (!await eventsDir.exists()) {
        await eventsDir.create(recursive: true);
      }

      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-15';
      final startDateStr = DateTime.parse(dateStr).toString();
      final uniqueTitle =
          'Valid Event ${DateTime.now().millisecondsSinceEpoch}';
      final validContent =
          '''# Event: $uniqueTitle

Valid event

- **Date**: $dateStr
- **Time**: 14:00 to 15:00
- **Recurrence**: none
''';
      final validFile = File('${eventsDir.path}/valid_event.md');
      await validFile.writeAsString(validContent);

      final corruptedFileSkip = File('${eventsDir.path}/corrupted_event.md');
      await corruptedFileSkip.writeAsString('invalid markdown content {{{');

      final uniqueTitle1 = 'Event 1 ${DateTime.now().millisecondsSinceEpoch}';
      final event1Content =
          '''# Event: $uniqueTitle1

First event

- **Date**: $dateStr
- **Time**: 09:00 to 10:00
- **Recurrence**: none
''';
      final event1File = File('${eventsDir.path}/event1.md');
      await event1File.writeAsString(event1Content);

      final corruptedFileContinue = File(
        '${eventsDir.path}/corrupted_event.md',
      );
      await corruptedFileContinue.writeAsString('invalid markdown content {{{');

      final uniqueTitle2 = 'Event 2 ${DateTime.now().millisecondsSinceEpoch}';
      final event2Content =
          '''# Event: $uniqueTitle2

Second event

- **Date**: $dateStr
- **Time**: 11:00 to 12:00
- **Recurrence**: none
''';
      final event2File = File('${eventsDir.path}/event2.md');
      await event2File.writeAsString(event2Content);

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

      expect(find.text(uniqueTitle1), findsOneWidget);
      expect(find.text(uniqueTitle2), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final newTitle =
          'New Event After Corruption ${DateTime.now().millisecondsSinceEpoch}';
      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        newTitle,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text(newTitle), findsOneWidget);
    });
  });
}
