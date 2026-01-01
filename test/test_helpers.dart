import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/services/event_storage.dart';

/// Sets up test directory path (platform-independent)
String getTestDirectoryPath() =>
    '${Directory.systemTemp.path}${Platform.pathSeparator}mcal_test_docs';

/// Sets up test environment with clean state and mocked dependencies.
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
          debugPrint('path_provider mock: ${methodCall.method}');
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            final testPath = getTestDirectoryPath();
            debugPrint('Returning test directory: $testPath');
            return testPath;
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

/// Cleans up test environment by removing test directory and all contents.
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

    // Clear test directory from EventStorage
    EventStorage.clearTestDirectory();

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
/// - Returns to configured EventProvider
///
/// Useful for tests that need an EventProvider with event storage functionality.
Future<EventProvider> setupTestEventProvider() async {
  await setupTestEnvironment();

  final eventProvider = EventProvider();
  await eventProvider.loadAllEvents();

  return eventProvider;
}

/// Combined setup for all integration test mocks.
///
/// This function sets up all required mocks in one call to prevent conflicts:
/// - Mocks path_provider for test directory (platform-independent)
/// - Mocks flutter_secure_storage for secure credential storage
/// - Mocks Git operations (init, add, commit, pull, push, status, credentials)
/// - Mocks notifications (initialize, permissions, schedule, cancel)
/// - Mocks certificate loading
/// - Cleans up any existing test directory
/// - Initializes SharedPreferences with empty values
Future<void> setupAllIntegrationMocks() async {
  // Mock path_provider to use test directory
  // Try multiple possible channel names
  for (final channelName in [
    'plugins.flutter.io/path_provider',
    'plugins.flutter.io/path_provider_linux',
    'dev.fluttercommunity.plus/path_provider',
  ]) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(channelName), (
          MethodCall methodCall,
        ) async {
          debugPrint('[$channelName] ${methodCall.method}');
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            final testPath = getTestDirectoryPath();
            debugPrint('Returning test directory: $testPath');
            return testPath;
          }
          return null;
        });
  }

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

  // Mock all Git operations in single handler (prevents channel conflicts)
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('mcal_flutter/rust_lib'), (
        MethodCall methodCall,
      ) async {
        if (methodCall.method == 'gitInit') {
          return 'Initialized empty Git repository';
        }
        if (methodCall.method == 'gitAdd') {
          return 'Staged files';
        }
        if (methodCall.method == 'gitAddRemote') {
          return 'Remote added';
        }
        if (methodCall.method == 'gitCommit') {
          return 'Committed changes';
        }
        if (methodCall.method == 'gitPull') {
          return 'Pulled 0 changes';
        }
        if (methodCall.method == 'gitPush') {
          return 'Pushed 1 commit';
        }
        if (methodCall.method == 'gitStatus') {
          return 'Clean working directory';
        }
        if (methodCall.method == 'gitFetch') {
          return 'Fetch completed';
        }
        if (methodCall.method == 'gitCheckout') {
          return 'Checkout completed';
        }
        if (methodCall.method == 'getCredentials') {
          return null;
        }
        if (methodCall.method == 'setCredentials') {
          return true;
        }
        if (methodCall.method == 'clearCredentials') {
          return true;
        }
        return null;
      });

  // Mock notifications
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'initialize') {
            return true;
          }
          if (methodCall.method == 'requestNotificationsPermission') {
            return true;
          }
          if (methodCall.method == 'zonedSchedule') {
            return null;
          }
          if (methodCall.method == 'cancel') {
            return null;
          }
          if (methodCall.method == 'cancelAll') {
            return null;
          }
          return null;
        },
      );

  // Clear SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  SharedPreferences.setMockInitialValues({});
}

/// Cleans up test events between tests.
///
/// This function:
/// - Clears all events from EventProvider
/// - Deletes all event files from storage
/// - Ensures test isolation
/// - Should be called in setUp() for each test
///
/// Usage example:
/// ```dart
/// setUp(() async {
///   await cleanTestEvents();
/// });
/// ```
Future<void> cleanTestEvents() async {
  debugPrint('cleanTestEvents: Starting cleanup');
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  SharedPreferences.setMockInitialValues({});

  final testDir = Directory(getTestDirectoryPath());
  final calendarDir = Directory('${testDir.path}/calendar');

  debugPrint('cleanTestEvents: testDir path is ${testDir.path}');

  if (await calendarDir.exists()) {
    try {
      final files = await calendarDir.list().toList();
      debugPrint(
        'cleanTestEvents: Found ${files.length} files in calendar directory',
      );

      final mdFiles = files.whereType<File>().where(
        (f) => f.path.endsWith('.md'),
      );
      debugPrint(
        'cleanTestEvents: Found ${mdFiles.length} .md files to delete',
      );

      for (final file in mdFiles) {
        try {
          await file.delete();
          debugPrint('cleanTestEvents: Deleted ${file.path}');
        } catch (e) {
          debugPrint('Warning: Failed to delete event file ${file.path}: $e');
        }
      }
      debugPrint('cleanTestEvents: Cleanup complete');
    } catch (e) {
      debugPrint('Warning: Failed to clean calendar directory: $e');
    }
  } else {
    debugPrint('cleanTestEvents: Calendar directory does not exist');
    try {
      await calendarDir.create(recursive: true);
      debugPrint('cleanTestEvents: Created calendar directory');
    } catch (e) {
      debugPrint('Warning: Failed to create calendar directory: $e');
    }
  }

  // Set test directory for EventStorage
  EventStorage.setTestDirectory(getTestDirectoryPath());
  debugPrint('cleanTestEvents: Set test directory in EventStorage');
}

/// Checks if the current platform supports certificate operations.
///
/// Returns true for Android and iOS platforms, false for Linux, macOS, Windows, and Web.
/// This helper is used to conditionally run certificate tests only on supported platforms.
bool platformSupportsCertificates() {
  return Platform.isAndroid || Platform.isIOS;
}

/// Sets up mock certificate channel for testing.
///
/// This function mocks the 'com.example.mcal/certificates' MethodChannel to:
/// - Return a list of mock certificates when 'getCACertificates' is called
/// - Optionally throw exceptions to test error handling
///
/// Parameters:
/// - [certificates]: List of PEM-formatted certificate strings to return
/// - [throwException]: If true, throws a PlatformException instead of returning certificates
/// - [exceptionCode]: The exception code to use (default: 'CERTIFICATE_ERROR')
/// - [exceptionMessage]: The exception message to use (default: 'Failed to read certificates')
///
/// Usage example:
/// ```dart
/// // Mock successful certificate reading
/// await setupCertificateMocks(['cert1', 'cert2']);
///
/// // Mock certificate failure
/// await setupCertificateMocks(
///   [],
///   throwException: true,
///   exceptionMessage: 'Certificate store unavailable',
/// );
/// ```
Future<void> setupCertificateMocks({
  List<String> certificates = const [
    '-----BEGIN CERTIFICATE-----\nMock certificate\n-----END CERTIFICATE-----',
  ],
  bool throwException = false,
  String exceptionCode = 'CERTIFICATE_ERROR',
  String exceptionMessage = 'Failed to read certificates',
}) async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('com.example.mcal/certificates'),
        (MethodCall methodCall) async {
          debugPrint('Certificate mock: ${methodCall.method}');
          if (methodCall.method == 'getCACertificates') {
            if (throwException) {
              throw PlatformException(
                code: exceptionCode,
                message: exceptionMessage,
              );
            }
            return certificates;
          }
          return null;
        },
      );
}

/// Clears mock certificate channel handlers.
///
/// This function removes all mock handlers from the certificate channel,
/// allowing tests to use a fresh state or the real platform implementation.
/// Should be called in tearDown() or after each test that uses certificate mocks.
///
/// Usage example:
/// ```dart
/// setUp(() async {
///   await setupCertificateMocks();
/// });
///
/// tearDown(() async {
///   await clearCertificateMocks();
/// });
/// ```
Future<void> clearCertificateMocks() async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('com.example.mcal/certificates'),
        null,
      );
}

/// Configures test window size for integration and widget tests.
///
/// Sets the test viewport to 1200x800 pixels to ensure all UI elements
/// (including AppBar action buttons) are visible and tappable during tests.
///
/// This is particularly important for tests that interact with AppBar buttons
/// that may be positioned beyond the default 800x600 test window size.
///
/// Must be called in setUp() or before pumpWidget() for each test.
///
/// Parameters:
/// - [tester]: The WidgetTester instance to configure
///
/// Example:
/// ```dart
/// setUp(() {
///   setupTestWindowSize(tester);
/// });
///
/// testWidgets('My test', (tester) async {
///   await tester.pumpWidget(MyApp());
///   // ThemeToggleButton is now visible at x=835.0
///   await tester.tap(find.byType(ThemeToggleButton));
/// });
///
/// tearDown(() {
///   resetTestWindowSize(tester);
/// });
/// ```
void setupTestWindowSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
}

/// Resets test window size to default values.
///
/// Must be called in tearDown() or addTearDown() to prevent
/// test state pollution between tests.
///
/// Parameters:
/// - [tester]: The WidgetTester instance to reset
///
/// Example:
/// ```dart
/// setUp(() {
///   setupTestWindowSize(tester);
/// });
///
/// testWidgets('My test', (tester) async {
///   await tester.pumpWidget(MyApp());
/// });
///
/// tearDown(() {
///   resetTestWindowSize(tester);
/// });
/// ```
void resetTestWindowSize(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}
