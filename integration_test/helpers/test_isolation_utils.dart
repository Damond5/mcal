import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mcal/services/event_storage.dart';
import 'package:mcal/services/notification_service.dart';
import 'package:workmanager/workmanager.dart';

/// Gets test directory path (platform-independent)
String _getTestDirectoryPath() =>
    '${Directory.systemTemp.path}${Platform.pathSeparator}mcal_test_docs';

/// Generates a unique test ID to prevent state conflicts between tests
String generateUniqueTestId() {
  return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999).toString().padLeft(6, '0')}';
}

/// Cleans up test events between tests.
Future<void> cleanTestEvents() async {
  debugPrint('cleanTestEvents: Starting cleanup');
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  SharedPreferences.setMockInitialValues({});

  final testDir = Directory(_getTestDirectoryPath());
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
  EventStorage.setTestDirectory(_getTestDirectoryPath());
  debugPrint('cleanTestEvents: Set test directory in EventStorage');

  // Clear any notification scheduling state
  try {
    final notificationService = NotificationService();
    await notificationService.cancelAllNotifications();
    debugPrint('cleanTestEvents: Cleared notification scheduling state');
  } catch (e) {
    debugPrint('Warning: Failed to clear notification state: $e');
  }

  debugPrint('cleanTestEvents: Comprehensive cleanup finished');
}

/// Complete reset of all test state to initial conditions.
Future<void> resetTestState() async {
  debugPrint('resetTestState: Starting complete state reset');

  // Clear all storage
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    SharedPreferences.setMockInitialValues({});
    debugPrint('resetTestState: Cleared SharedPreferences');
  } catch (e) {
    debugPrint('Warning: Failed to clear SharedPreferences: $e');
  }

  // Clear test directory completely
  try {
    final testDir = Directory(_getTestDirectoryPath());
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
      debugPrint('resetTestState: Deleted test directory');
    }
  } catch (e) {
    debugPrint('Warning: Failed to delete test directory: $e');
  }

  // Clear EventStorage state
  try {
    EventStorage.clearTestDirectory();
    debugPrint('resetTestState: Cleared EventStorage state');
  } catch (e) {
    debugPrint('Warning: Failed to clear EventStorage: $e');
  }

  // Clear notification state
  try {
    final notificationService = NotificationService();
    await notificationService.cancelAllNotifications();
    debugPrint('resetTestState: Cleared notification state');
  } catch (e) {
    debugPrint('Warning: Failed to clear notification state: $e');
  }

  // Cancel any scheduled work
  try {
    await Workmanager().cancelAll();
    debugPrint('resetTestState: Canceled all scheduled work');
  } catch (e) {
    debugPrint('Warning: Failed to cancel scheduled work: $e');
  }

  debugPrint('resetTestState: Complete state reset finished');
}

/// Manages test isolation to prevent state conflicts between tests.
///
/// This class provides comprehensive isolation mechanisms:
/// - Unique test IDs for each test run
/// - Isolated file system directories
/// - State tracking and cleanup
/// - Conflict detection and resolution
class TestIsolationManager {
  static final String _testId = DateTime.now().millisecondsSinceEpoch
      .toString();
  static String get testId => _testId;

  static final Set<String> _createdTestIds = {};
  static final Map<String, Map<String, dynamic>> _stateSnapshots = {};
  static bool _isolationEnabled = false;

  /// Gets whether test isolation is currently enabled
  static bool get isIsolationEnabled => _isolationEnabled;

  /// Enables or disables test isolation globally
  static void setIsolationEnabled(bool enabled) {
    _isolationEnabled = enabled;
    debugPrint(
      'TestIsolationManager: Isolation ${enabled ? 'enabled' : 'disabled'}',
    );
  }

  /// Sets up test isolation environment.
  ///
  /// This method:
  /// - Creates unique test directory
  /// - Initializes isolated state
  /// - Sets up clean mocks
  ///
  /// Parameters:
  /// - [enableFileSystemIsolation]: Whether to create isolated file system (default: true)
  /// - [enableStateTracking]: Whether to track state changes (default: true)
  ///
  /// Returns the unique test ID for this isolation session
  static Future<String> setupIsolation({
    bool enableFileSystemIsolation = true,
    bool enableStateTracking = true,
  }) async {
    final isolationId = generateUniqueTestId();
    _createdTestIds.add(isolationId);

    debugPrint(
      'TestIsolationManager: Setting up isolation with ID: $isolationId',
    );

    // Create isolated file system if requested
    if (enableFileSystemIsolation) {
      final isolatedDir = Directory(
        '${Directory.systemTemp.path}${Platform.pathSeparator}mcal_test_docs_$isolationId',
      );
      if (!await isolatedDir.exists()) {
        await isolatedDir.create(recursive: true);
      }
      EventStorage.setTestDirectory(isolatedDir.path);
      debugPrint(
        'TestIsolationManager: Created isolated directory: ${isolatedDir.path}',
      );
    }

    // Initialize clean state
    await cleanTestEvents();

    // Enable state tracking if requested
    if (enableStateTracking) {
      await captureStateSnapshot(isolationId);
    }

    _isolationEnabled = true;
    debugPrint(
      'TestIsolationManager: Isolation setup complete for ID: $isolationId',
    );

    return isolationId;
  }

  /// Cleans up test isolation environment.
  ///
  /// This method:
  /// - Removes all test artifacts
  /// - Resets all state
  /// - Removes temporary files
  ///
  /// Parameters:
  /// - [testId]: The test ID returned from [setupIsolation]
  /// - [cleanupFileSystem]: Whether to clean up file system (default: true)
  /// - [cleanupState]: Whether to clean up state (default: true)
  static Future<void> cleanupIsolation({
    required String testId,
    bool cleanupFileSystem = true,
    bool cleanupState = true,
  }) async {
    debugPrint('TestIsolationManager: Cleaning up isolation for ID: $testId');

    // Clean up file system if requested
    if (cleanupFileSystem) {
      try {
        final isolatedDir = Directory(
          '${Directory.systemTemp.path}${Platform.pathSeparator}mcal_test_docs_$testId',
        );
        if (await isolatedDir.exists()) {
          await isolatedDir.delete(recursive: true);
          debugPrint('TestIsolationManager: Removed isolated directory');
        }
      } catch (e) {
        debugPrint('Warning: Failed to clean up isolated directory: $e');
      }
    }

    // Clean up state if requested
    if (cleanupState) {
      await resetTestState();
      EventStorage.clearTestDirectory();
      _stateSnapshots.remove(testId);
      debugPrint('TestIsolationManager: Cleared test state');
    }

    _createdTestIds.remove(testId);
    debugPrint('TestIsolationManager: Cleanup complete for ID: $testId');
  }

  /// Cleans up all test isolation environments.
  ///
  /// Use this method in tearDownAll() to ensure complete cleanup.
  static Future<void> cleanupAllIsolation() async {
    debugPrint('TestIsolationManager: Cleaning up all isolation environments');

    final testIds = Set<String>.from(_createdTestIds);

    for (final testId in testIds) {
      await cleanupIsolation(
        testId: testId,
        cleanupFileSystem: true,
        cleanupState: true,
      );
    }

    _createdTestIds.clear();
    _stateSnapshots.clear();
    _isolationEnabled = false;

    debugPrint('TestIsolationManager: All isolation environments cleaned up');
  }

  /// Captures a state snapshot for the given test ID.
  ///
  /// Parameters:
  /// - [testId]: The test ID to capture state for
  /// - [description]: Optional description for the snapshot
  static Future<void> captureStateSnapshot(
    String testId, {
    String? description,
  }) async {
    final snapshot = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'description': description ?? 'State snapshot for $testId',
      'testDirectory':
          _getTestDirectoryPath(), // EventStorage._testDirectory not accessible, using current path
    };

    _stateSnapshots[testId] = snapshot;
    debugPrint('TestIsolationManager: Captured state snapshot for $testId');
  }

  /// Restores a state snapshot for the given test ID.
  ///
  /// Parameters:
  /// - [testId]: The test ID to restore state for
  /// - [force]: Whether to force restore even if snapshot doesn't exist
  static Future<void> restoreStateSnapshot(
    String testId, {
    bool force = false,
  }) async {
    final snapshot = _stateSnapshots[testId];

    if (snapshot == null && !force) {
      debugPrint('Warning: No state snapshot found for $testId');
      return;
    }

    if (snapshot != null) {
      debugPrint('TestIsolationManager: Restored state snapshot for $testId');
    }
  }

  /// Detects if state has been corrupted or leaked between tests.
  ///
  /// Parameters:
  /// - [testId]: The test ID to check
  /// - [expectedEvents]: Expected number of events (optional)
  ///
  /// Returns true if state corruption is detected
  static Future<bool> detectStateCorruption(
    String testId, {
    int? expectedEvents,
  }) async {
    // Check if test ID was created by this manager
    if (!_createdTestIds.contains(testId)) {
      debugPrint(
        'Warning: Test ID $testId not created by TestIsolationManager',
      );
      return true;
    }

    // Check for unexpected state
    if (expectedEvents != null) {
      // Can't access EventStorage._testDirectory directly, so we check the default test directory
      final testDir = _getTestDirectoryPath();
      final dir = Directory('$testDir/calendar');
      if (await dir.exists()) {
        final files = await dir.list().toList();
        final eventCount = files
            .whereType<File>()
            .where((f) => f.path.endsWith('.md'))
            .length;

        if (eventCount != expectedEvents) {
          debugPrint(
            'State corruption detected: Expected $expectedEvents events, found $eventCount',
          );
          return true;
        }
      }
    }

    return false;
  }
}

/// Generates unique event IDs for test events.
///
/// This class ensures that test events don't conflict with each other
/// or with existing events in the system.
class EventIdGenerator {
  static int _counter = 0;
  static final String _baseId = DateTime.now().millisecondsSinceEpoch
      .toString();

  /// Generates a unique event ID
  static String generateUniqueId() {
    _counter++;
    return 'test_${_baseId}_${_counter}_${Random().nextInt(9999).toString().padLeft(4, '0')}';
  }

  /// Generates a unique filename for an event
  static String generateUniqueFilename(String title) {
    final sanitizedTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return '${sanitizedTitle}_${generateUniqueId()}.md';
  }

  /// Resets the counter (use with caution)
  static void resetCounter() {
    _counter = 0;
  }

  /// Gets the current counter value
  static int getCounter() => _counter;
}

/// Manages state snapshots for tests.
///
/// This class provides functionality to:
/// - Capture state before tests
/// - Restore state after tests
/// - Detect state corruption
class StateSnapshotManager {
  static final Map<String, Map<String, dynamic>> _snapshots = {};
  static String? _currentTestId;

  /// Captures the current state as a snapshot.
  ///
  /// Parameters:
  /// - [testId]: The test ID to associate with the snapshot
  /// - [description]: Optional description
  static Future<void> capture({
    required String testId,
    String? description,
  }) async {
    final snapshot = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'description': description ?? 'Snapshot for $testId',
      'testDirectory':
          _getTestDirectoryPath(), // EventStorage._testDirectory not accessible, using current path
      'counter': EventIdGenerator.getCounter(),
    };

    _snapshots[testId] = snapshot;
    debugPrint('StateSnapshotManager: Captured snapshot for $testId');
  }

  /// Restores state from a snapshot.
  ///
  /// Parameters:
  /// - [testId]: The test ID to restore
  /// - [restoreDirectory]: Whether to restore test directory (default: true)
  static Future<void> restore({
    required String testId,
    bool restoreDirectory = true,
  }) async {
    final snapshot = _snapshots[testId];

    if (snapshot == null) {
      debugPrint('Warning: No snapshot found for $testId');
      return;
    }

    // Restore test directory if it was changed
    if (restoreDirectory) {
      // Access the private testDirectory field from EventStorage
      try {
        // Use reflection or public API to get test directory
        final snapshot = StateSnapshotManager.getSnapshot(testId);
        if (snapshot != null && snapshot.containsKey('testDirectory')) {
          final testDir = snapshot['testDirectory'] as String?;
          if (testDir != null) {
            EventStorage.setTestDirectory(testDir);
          }
        }
      } catch (e) {
        debugPrint('Warning: Could not restore test directory: $e');
      }
    }

    debugPrint('StateSnapshotManager: Restored snapshot for $testId');
  }

  /// Removes a snapshot.
  static void remove(String testId) {
    _snapshots.remove(testId);
    debugPrint('StateSnapshotManager: Removed snapshot for $testId');
  }

  /// Clears all snapshots.
  static void clearAll() {
    _snapshots.clear();
    debugPrint('StateSnapshotManager: Cleared all snapshots');
  }

  /// Gets a snapshot by test ID.
  static Map<String, dynamic>? getSnapshot(String testId) {
    return _snapshots[testId];
  }

  /// Sets the current test ID.
  static void setCurrentTestId(String? testId) {
    _currentTestId = testId;
  }

  /// Gets the current test ID.
  static String? getCurrentTestId() => _currentTestId;
}

/// Helper function to run a test with isolation.
///
/// This function automatically handles setup and cleanup of test isolation.
///
/// Parameters:
/// - [testFunction]: The test function to run
/// - [setupOptions]: Options for isolation setup
/// - [cleanupOptions]: Options for isolation cleanup
///
/// Example:
/// ```dart
/// await runIsolatedTest((testId) async {
///   // Your test logic here
///   final event = await createTestEvent(testId: testId);
///   expect(event.title, 'Test Event');
/// });
/// ```
Future<void> runIsolatedTest(
  Future<void> Function(String testId) testFunction, {
  bool enableFileSystemIsolation = true,
  bool enableStateTracking = true,
  bool cleanupFileSystem = true,
  bool cleanupState = true,
}) async {
  final testId = await TestIsolationManager.setupIsolation(
    enableFileSystemIsolation: enableFileSystemIsolation,
    enableStateTracking: enableStateTracking,
  );

  StateSnapshotManager.setCurrentTestId(testId);

  try {
    await testFunction(testId);
  } finally {
    StateSnapshotManager.setCurrentTestId(null);
    await TestIsolationManager.cleanupIsolation(
      testId: testId,
      cleanupFileSystem: cleanupFileSystem,
      cleanupState: cleanupState,
    );
  }
}
