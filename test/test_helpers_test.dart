import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mcal/frb_generated.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await RustLib.init();
  });

  late List<String> debugLog;

  setUp(() {
    debugLog = [];
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        debugLog.add(message);
      }
    };
  });

  group('setupTestEnvironment', () {
    test('cleans up existing test directory', () async {
      // Use same path as test_helpers.dart
      final testDir = Directory(getTestDirectoryPath());
      await testDir.create(recursive: true);
      final testFile = File('${getTestDirectoryPath()}/test.txt');
      await testFile.writeAsString('test content');

      expect(await testFile.exists(), true);

      // Setup should clean up existing directory
      await setupTestEnvironment();

      expect(await testFile.exists(), false);
      expect(await testDir.exists(), false);
    });

    test('initializes SharedPreferences with empty values', () async {
      await setupTestEnvironment();

      // SharedPreferences should be initialized with empty values
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.get('test_key'), null);
    });
  });

  group('cleanupTestEnvironment', () {
    setUp(() async {
      // Ensure cleanup is enabled (default behavior)
    });

    test('removes test directory when it exists', () async {
      // Create test directory with a file
      final testDir = Directory(getTestDirectoryPath());
      await testDir.create(recursive: true);
      final testFile = File('${getTestDirectoryPath()}/test.txt');
      await testFile.writeAsString('test content');

      expect(await testFile.exists(), true);

      await cleanupTestEnvironment();

      expect(await testFile.exists(), false);
      expect(await testDir.exists(), false);
    });

    test('does not fail when directory does not exist', () async {
      // Ensure directory doesn't exist
      final testDir = Directory(getTestDirectoryPath());
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }

      expect(await testDir.exists(), false);

      // Should not throw
      await cleanupTestEnvironment();

      expect(debugLog, isEmpty);
    });

    test('removes nested directory structure correctly', () async {
      // Create directory with subdirectory
      final testDir = Directory(getTestDirectoryPath());
      await testDir.create(recursive: true);
      final subDir = Directory('${getTestDirectoryPath()}/subdir');
      await subDir.create();

      // Create a file
      final testFile = File('${getTestDirectoryPath()}/test.txt');
      await testFile.writeAsString('test content');

      expect(await testFile.exists(), true);

      // Cleanup should not throw, just log warning if error occurs
      await cleanupTestEnvironment();

      expect(await testFile.exists(), false);
      expect(await testDir.exists(), false);
    });
  });

  group('setupTestEventProvider', () {
    test('creates EventProvider with clean environment', () async {
      final eventProvider = await setupTestEventProvider();

      expect(eventProvider, isNotNull);
      expect(eventProvider.getEventsForDate(DateTime.now()), isEmpty);
    });

    test('loads events from EventStorage', () async {
      final eventProvider = await setupTestEventProvider();

      // Should have called loadAllEvents during setup
      expect(eventProvider.eventsCount, 0);
    });
  });
}
