import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mcal/providers/event_provider.dart';

/// Sets up test directory path (platform-independent)
String getTestDirectoryPath() =>
    '${Directory.systemTemp.path}${Platform.pathSeparator}mcal_test_docs';

/// Sets up the test environment with clean state and mocked dependencies.
///
/// This function:
/// - Mocks path_provider to use test directory (platform-independent)
/// - Mocks flutter_secure_storage for secure credential storage
/// - Cleans up any existing test directory
/// - Initializes SharedPreferences with empty values
Future<void> setupTestEnvironment() async {
  // Mock path_provider to use test directory
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return getTestDirectoryPath();
          }
          return null;
        },
      );

  // Mock flutter_secure_storage
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'read') return null;
          if (methodCall.method == 'write') return null;
          if (methodCall.method == 'delete') return null;
          return null;
        },
      );

  // Clean up any existing test directory
  await cleanupTestEnvironment();

  // Initialize SharedPreferences with empty values
  SharedPreferences.setMockInitialValues({});
}

/// Cleans up the test environment by removing the test directory and all contents.
///
/// Uses MCAL_TEST_CLEANUP environment variable to allow disabling cleanup for debugging.
/// If cleanup fails, errors are logged but do not cause test failures.
///
/// To disable cleanup for debugging:
/// ```bash
/// flutter test --dart-define=MCAL_TEST_CLEANUP=false
/// ```
Future<void> cleanupTestEnvironment() async {
  const bool enableCleanup = bool.fromEnvironment(
    'MCAL_TEST_CLEANUP',
    defaultValue: true,
  );

  try {
    if (!enableCleanup) {
      debugPrint('Test cleanup disabled for debugging');
      return;
    }

    final testDir = Directory(getTestDirectoryPath());

    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
      debugPrint('Test directory cleaned: ${testDir.path}');
    }
  } catch (e, stackTrace) {
    // Log error but don't fail test
    debugPrint('Warning: Failed to clean up test environment: $e');
    debugPrint('$stackTrace');
    // Don't throw - cleanup failures shouldn't mask test failures
  }
}

/// Sets up a test EventProvider with clean environment.
///
/// This function:
/// - Calls setupTestEnvironment() to ensure clean state
/// - Creates a new EventProvider instance
/// - Loads all events (should be empty in clean state)
/// - Returns the configured EventProvider
///
/// Useful for tests that need an EventProvider with event storage functionality.
Future<EventProvider> setupTestEventProvider() async {
  await setupTestEnvironment();

  final eventProvider = EventProvider();
  await eventProvider.loadAllEvents();

  return eventProvider;
}
