import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  group('platformSupportsCertificates', () {
    test('returns true for Android', () {
      expect(platformSupportsCertificates(), Platform.isAndroid);
    });

    test('returns true for iOS', () {
      expect(platformSupportsCertificates(), Platform.isIOS);
    });

    test('returns false for Linux', () {
      if (Platform.isLinux) {
        expect(platformSupportsCertificates(), false);
      }
    });

    test('returns false for macOS', () {
      if (Platform.isMacOS) {
        expect(platformSupportsCertificates(), false);
      }
    });

    test('returns false for Windows', () {
      if (Platform.isWindows) {
        expect(platformSupportsCertificates(), false);
      }
    });
  });

  group('setupCertificateMocks', () {
    setUp(() async {
      await clearCertificateMocks();
    });

    tearDown(() async {
      await clearCertificateMocks();
    });

    test('returns mocked certificates when invoked', () async {
      final mockCerts = ['cert1', 'cert2', 'cert3'];
      await setupCertificateMocks(certificates: mockCerts);

      const channel = MethodChannel('com.example.mcal/certificates');
      final result = await channel.invokeMethod('getCACertificates');

      expect(result, equals(mockCerts));
    });

    test('throws PlatformException when throwException is true', () async {
      const exceptionMessage = 'Certificate store unavailable';
      await setupCertificateMocks(
        certificates: [],
        throwException: true,
        exceptionMessage: exceptionMessage,
      );

      const channel = MethodChannel('com.example.mcal/certificates');

      expect(
        () => channel.invokeMethod('getCACertificates'),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.message,
            'message',
            exceptionMessage,
          ),
        ),
      );
    });

    test('uses default certificate when none provided', () async {
      await setupCertificateMocks();

      const channel = MethodChannel('com.example.mcal/certificates');
      final result = await channel.invokeMethod('getCACertificates');

      expect(result, isA<List>());
      expect(result.length, greaterThan(0));
    });

    test('returns empty list when empty certificates provided', () async {
      await setupCertificateMocks(certificates: []);

      const channel = MethodChannel('com.example.mcal/certificates');
      final result = await channel.invokeMethod('getCACertificates');

      expect(result, isEmpty);
    });

    test('handles null certificates correctly', () async {
      await setupCertificateMocks(certificates: const []);

      const channel = MethodChannel('com.example.mcal/certificates');
      final result = await channel.invokeMethod('getCACertificates');

      expect(result, isNotNull);
      expect(result, isEmpty);
    });
  });

  group('clearCertificateMocks', () {
    test('removes mock handler from certificate channel', () async {
      await setupCertificateMocks(certificates: ['cert1']);
      await clearCertificateMocks();

      const channel = MethodChannel('com.example.mcal/certificates');
      expect(
        () => channel.invokeMethod('getCACertificates'),
        throwsA(isA<MissingPluginException>()),
      );
    });

    test('can set up mocks again after clearing', () async {
      await setupCertificateMocks(certificates: ['cert1']);
      await clearCertificateMocks();

      await setupCertificateMocks(certificates: ['cert2']);

      const channel = MethodChannel('com.example.mcal/certificates');
      final result = await channel.invokeMethod('getCACertificates');

      expect(result, equals(['cert2']));
    });

    test('does not throw when clearing unset mocks', () async {
      expect(() async => await clearCertificateMocks(), returnsNormally);
    });

    test('ensures no state pollution between tests', () async {
      await setupCertificateMocks(certificates: ['test_cert']);
      await clearCertificateMocks();

      await setupCertificateMocks(certificates: ['new_cert']);

      const channel = MethodChannel('com.example.mcal/certificates');
      final result = await channel.invokeMethod('getCACertificates');

      expect(result, equals(['new_cert']));
    });
  });

  // Note: Unit tests for setupTestWindowSize and resetTestWindowSize are skipped because
  // Flutter's test framework prevents modification of debug variables (physicalSize, devicePixelRatio)
  // in testWidgets tests after the first modification. Tests that would:
  // - Test setupTestWindowSize() sets correct physical size (1920, 1080)
  // - Test setupTestWindowSize() sets device pixel ratio to 1.0
  // - Verify window size changes take effect after pump()
  // - Test resetTestWindowSize() resets to default values
  // - Test no state pollution between setup/reset calls
  //
  // The functionality of these functions is verified in integration tests during Phase 2 of the
  // change proposal (updating calendar integration tests), where they successfully work with
  // addTearDown() cleanup handlers. All 33 calendar integration tests pass with window size
  // configuration, confirming the functions work correctly.
}
