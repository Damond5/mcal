# Enhanced Test Helpers and Isolation Utilities

This document describes the comprehensive test enhancement system implemented for the MCAL project to ensure complete test isolation and eliminate test failures caused by state leakage.

## Overview

The test enhancement system consists of four main components:

1. **Enhanced Test Helpers** (`/home/nikv/workspace/mcal/test/test_helpers.dart`) - Core utilities for test setup and cleanup
2. **Test Isolation Utilities** (`/home/nikv/workspace/mcal/integration_test/helpers/test_isolation_utils.dart`) - Advanced isolation mechanisms
3. **Enhanced Mock System** (`/home/nikv/workspace/mcal/integration_test/helpers/test_mock_enhancements.dart`) - Comprehensive mocking for FFI, notifications, and Git operations
4. **Test Time Utilities** (`/home/nikv/workspace/mcal/integration_test/helpers/test_time_utils.dart`) - Time control and date factory utilities

## Core Test Helpers

### Enhanced `cleanTestEvents()` Method

The enhanced `cleanTestEvents()` method now provides comprehensive cleanup:

```dart
Future<void> cleanTestEvents() async {
  // Clears SharedPreferences
  // Deletes all event files from calendar directory
  // Clears notification scheduling state
  // Sets up test directory in EventStorage
}
```

**What it cleans:**
- SharedPreferences state
- Event files (*.md) in calendar directory
- Notification scheduling state
- Test directory setup

### New `resetTestState()` Method

Complete state reset for full test isolation:

```dart
Future<void> resetTestState() async {
  // Clears all SharedPreferences
  // Deletes entire test directory
  // Clears EventStorage state
  // Cancels all notifications
  // Cancels all scheduled work (Workmanager)
  // Reinitializes secure storage mock
}
```

### New `isolateTestEnvironment()` Method

Provides complete test isolation with unique identifiers:

```dart
Future<String> isolateTestEnvironment({
  String? testId,
  bool isolateFileSystem = true,
  bool resetMocks = true,
}) async {
  // Generates unique test ID
  // Creates isolated file system directory
  // Resets all mocks
  // Clears existing state
  return isolationId;
}
```

**Returns:** A unique test ID for tracking and cleanup

### New `cleanupIsolation()` Method

Cleans up isolation environment:

```dart
Future<void> cleanupIsolation({
  required String testId,
  bool cleanupFileSystem = true,
  bool cleanupState = true,
}) async {
  // Removes isolated directory
  // Clears test state
}
```

## Test Isolation Utilities

### `TestIsolationManager` Class

Manages comprehensive test isolation:

```dart
class TestIsolationManager {
  static String get testId => _testId;
  
  static Future<String> setupIsolation({
    bool enableFileSystemIsolation = true,
    bool enableStateTracking = true,
  }) async { ... }
  
  static Future<void> cleanupIsolation({
    required String testId,
    bool cleanupFileSystem = true,
    bool cleanupState = true,
  }) async { ... }
  
  static Future<void> cleanupAllIsolation() async { ... }
}
```

### `EventIdGenerator` Class

Generates unique event IDs to prevent conflicts:

```dart
class EventIdGenerator {
  static String generateUniqueId();
  static String generateUniqueFilename(String title);
  static void resetCounter();
}
```

### `StateSnapshotManager` Class

Captures and restores state snapshots:

```dart
class StateSnapshotManager {
  static Future<void> capture({required String testId, String? description});
  static Future<void> restore({required String testId, bool restoreDirectory = true});
  static void remove(String testId);
  static void clearAll();
}
```

### `runIsolatedTest()` Helper

Convenience function for running isolated tests:

```dart
Future<void> runIsolatedTest(
  Future<void> Function(String testId) testFunction, {
  bool enableFileSystemIsolation = true,
  bool enableStateTracking = true,
  bool cleanupFileSystem = true,
  bool cleanupState = true,
}) async {
  final testId = await TestIsolationManager.setupIsolation();
  try {
    await testFunction(testId);
  } finally {
    await TestIsolationManager.cleanupIsolation(testId: testId);
  }
}
```

## Enhanced Mock System

### `EnhancedFFIMock` Class

Comprehensive mocking for Rust FFI calls:

```dart
class EnhancedFFIMock {
  void initialize();
  void setDelay(String operation, Duration delay);
  void simulateError(String operation, Exception error);
  void clearError(String operation);
  List<Map<String, dynamic>> getCallHistory(String operation);
  MethodChannelHandler createHandler();
}
```

**Features:**
- Proper return values (not null)
- Simulated delays for realistic timing
- Error simulation for testing error handling
- Call tracking for verification

### `EnhancedNotificationMock` Class

Complete notification service mocking:

```dart
class EnhancedNotificationMock {
  void setPermissionsGranted(bool granted);
  List<Map<String, dynamic>> getScheduledNotifications();
  List<Map<String, dynamic>> getDisplayedNotifications();
  void clearScheduledNotifications();
  MethodChannelHandler createHandler();
}
```

### `EnhancedGitOperationMock` Class

Full Git operation simulation:

```dart
class EnhancedGitOperationMock {
  void setSimulateNetworkErrors(bool simulate);
  void setSimulateConflicts(bool simulate);
  void setSimulatedDelay(Duration delay);
  Map<String, dynamic> getRepositoryState();
  MethodChannelHandler createHandler();
}
```

### `EnhancedMockSetup` Class

Utility for setting up all mocks at once:

```dart
class EnhancedMockSetup {
  static void setupAll();
  static void resetAll();
  static void clearAllHistory();
}
```

## Test Time Utilities

### `TimeControlUtils` Class

Time control for deterministic testing:

```dart
class TimeControlUtils {
  static void freezeTime({DateTime? time});
  static void unfreezeTime();
  static DateTime getCurrentTime();
  static void advanceTime(Duration duration);
  static void setTime(DateTime time);
  static void reset();
}
```

**Usage:**
```dart
TimeControlUtils.freezeTime();
try {
  // Test with frozen time
  final event = DateFactory.createTodayEvent();
  expect(event.startDate, equals(TimeControlUtils.getCurrentTime()));
} finally {
  TimeControlUtils.unfreezeTime();
}
```

### `DateFactory` Class

Comprehensive event creation utilities:

```dart
class DateFactory {
  static Event createEvent({String? title, DateTime? date, String startTime, ...});
  static Event createAllDayEvent({String? title, DateTime? date, ...});
  static Event createRecurringEvent({String recurrence, ...});
  static Event createMultiDayEvent({int durationDays, ...});
  static Event createRelativeEvent({int daysFromNow, int hoursFromNow, ...});
  static Event createPastEvent({int daysAgo, ...});
  static Event createFutureEvent({int daysFromNow, ...});
  static Event createTodayEvent({int hour, int minute, ...});
  static List<Event> createEventsForSameDay({int count, ...});
  static List<Event> createOverlappingEvents({DateTime? date, ...});
  static List<Event> createLargeEventSet({int count, ...});
}
```

### `createEventTimeline()` Function

Creates events at specific intervals:

```dart
List<Event> createEventTimeline({
  int eventCount = 10,
  Duration interval = const Duration(hours: 2),
  DateTime? startTime,
  String titlePrefix = 'Timeline Event',
})
```

## Enhanced Test Fixtures

### Basic Fixtures

Standard event fixtures for common test scenarios:

- `createSampleEvent()` - Basic event with default values
- `createAllDayEvent()` - All-day event fixture
- `createRecurringEvent()` - Recurring event fixture
- `createMultiDayEvent()` - Multi-day event fixture
- `createWeeklyMeeting()` - Weekly recurring meeting
- `createBirthdayEvent()` - Yearly recurring birthday
- `createDailyStandup()` - Daily recurring standup

### Error Case Fixtures

Fixtures for testing error handling and validation:

- `createInvalidDateEvent()` - Event with invalid date (DateTime(0))
- `createEmptyTitleEvent()` - Event with empty title
- `createInvalidTimeEvent()` - Event with end time before start time
- `createInvalidRecurrenceEvent()` - Event with invalid recurrence pattern

### Performance Test Fixtures

Fixtures for performance and load testing:

- `createPerformanceEventSet()` - Large set of events for performance testing
- `createRecurringEventSet()` - Large set of recurring events

### Edge Case Fixtures

Fixtures for testing edge cases and boundary conditions:

- `createMidnightEvent()` - Event starting at midnight (00:00)
- `createEndOfDayEvent()` - Event at end of day (23:00-23:59)
- `createLongEvent()` - Very long event (30+ days)
- `createLeapYearEvent()` - Event on February 29th
- `createTimezoneBoundaryEvents()` - Events at midnight boundary
- `createMaxLengthTitleEvent()` - Event with maximum title length (255 chars)
- `createSpecialCharacterEvent()` - Event with special characters in title

## Usage Examples

### Basic Test Setup

```dart
setUp(() async {
  await isolateTestEnvironment();
});

tearDown(() async {
  // Cleanup is automatic
});
```

### Isolated Test with Custom Logic

```dart
testWidgets('Event creation test', (tester) async {
  await runIsolatedTest((testId) async {
    final event = TestFixtures.createSampleEvent();
    
    await tester.pumpWidget(MyApp());
    await tester.enterText(find.byType(TextField), event.title);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    
    expect(find.text(event.title), findsOneWidget);
  });
});
```

### Using Time Control

```dart
testWidgets('Today event display test', (tester) async {
  TimeControlUtils.freezeTime();
  try {
    final today = TimeControlUtils.getCurrentTime();
    final event = DateFactory.createTodayEvent(hour: 14);
    
    await provider.addEvent(event);
    final todayEvents = provider.getEventsForDate(today);
    
    expect(todayEvents, contains(event));
  } finally {
    TimeControlUtils.unfreezeTime();
  }
});
```

### Using Enhanced Mocks

```dart
setUp(() async {
  EnhancedMockSetup.setupAll();
});

test('Git sync test', () async {
  EnhancedGitOperationMock.gitMock.setSimulateConflicts(true);
  
  expect(
    () => syncService.pullSync(),
    throwsA(isA<SyncConflictException>()),
  );
});
```

### Performance Testing

```dart
test('Bulk event creation performance', () async {
  final events = TestFixtures.createPerformanceEventSet(eventCount: 1000);
  
  final stopwatch = Stopwatch()..start();
  for (final event in events) {
    await provider.addEvent(event);
  }
  
  expect(stopwatch.elapsedMilliseconds, lessThan(30000)); // < 30 seconds
  expect(provider.eventsCount, equals(1000));
});
```

### Edge Case Testing

```dart
test('Leap year event handling', () {
  final leapEvent = TestFixtures.createLeapYearEvent();
  
  expect(leapEvent.startDate.month, equals(2));
  expect(leapEvent.startDate.day, equals(29));
  expect(leapEvent.recurrence, equals('yearly'));
});
```

## Best Practices

1. **Always use `isolateTestEnvironment()`** in `setUp()` for complete isolation
2. **Use `runIsolatedTest()`** for individual test isolation
3. **Use `TimeControlUtils`** for deterministic time-based tests
4. **Use `DateFactory`** for creating events with controlled timing
5. **Use enhanced mocks** for comprehensive FFI and service mocking
6. **Use appropriate fixtures** for different test scenarios:
   - Basic fixtures for standard tests
   - Error fixtures for validation tests
   - Performance fixtures for load tests
   - Edge case fixtures for boundary tests

## Troubleshooting

### Common Issues

1. **Test state leakage**: Ensure `isolateTestEnvironment()` is called in `setUp()`
2. **Mock conflicts**: Use `EnhancedMockSetup.setupAll()` to configure all mocks consistently
3. **Time-dependent failures**: Use `TimeControlUtils.freezeTime()` for deterministic testing
4. **Event ID conflicts**: Use `EventIdGenerator.generateUniqueId()` for unique identifiers

### Debug Mode

To disable cleanup for debugging:

```bash
flutter test --dart-define=MCAL_TEST_CLEANUP=false
```

## Migration from Legacy Helpers

Legacy helpers are still available but deprecated:

```dart
@Deprecated('Use cleanTestEvents() or resetTestState() instead')
Future<void> cleanTestEventsLegacy() async {
  await cleanTestEvents();
}
```

**Migration path:**
1. Replace `cleanTestEvents()` → `cleanTestEvents()` (same function, enhanced)
2. Replace manual cleanup → `isolateTestEnvironment()` + automatic cleanup
3. Add `TimeControlUtils` for time-based tests
4. Add enhanced mocks for complex testing scenarios

## Performance Impact

The enhanced test system adds minimal overhead:

- **Isolation setup**: ~10-50ms (creates directory structure)
- **Cleanup**: ~10-50ms (removes directory structure)
- **Enhanced mocks**: ~1-5ms (initialization only)

The trade-off is worth it for the reliability gained from complete test isolation.

## Future Enhancements

Planned improvements include:

- **Parallel test execution support** with independent isolation
- **Snapshot comparison** for visual regression testing
- **Network condition simulation** for sync tests
- **Battery/performance profiling** integration
- **CI/CD integration** helpers for test environment setup

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the usage examples
3. Check existing test implementations in `/home/nikv/workspace/mcal/test/`
4. Review integration tests in `/home/nikv/workspace/mcal/integration_test/`
