# Design: Add Test Cleanup for Event Persistence

## Overview
This design describes the implementation of test cleanup mechanisms to prevent event file accumulation in test directories, ensuring test isolation and reliability.

## Current Implementation

### Test Setup
Tests mock `path_provider` to return `/tmp/test_docs` as the application documents directory:
```dart
TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
  .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '/tmp/test_docs';
      }
      return null;
    },
  );
```

### Event Storage
`EventStorage` creates real Markdown files in the calendar directory:
- Directory: `/tmp/test_docs/calendar/`
- Files: Individual Markdown files per event
- Methods that create files:
  - `saveEvent()` (line 78-83)
  - `addEvent()` (line 86-88)
  - `updateEvent()` (line 90-100)

### Problem Areas
1. **No cleanup**: Tests create events but never delete them
2. **Accumulation**: Event files persist across test runs
3. **Interference**: State from one test can affect subsequent tests

## Test Helper Design

### Helper File Structure
Create `test/test_helpers.dart` with the following utilities:

#### setupTestEnvironment()
Initializes test environment with clean state:
```dart
Future<void> setupTestEnvironment() async {
  // Mock path_provider to use test directory
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '/tmp/test_docs';
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
```

#### cleanupTestEnvironment()
Removes all test artifacts:
```dart
// Environment variable for debugging: set to false to disable cleanup
const bool _enableCleanup = bool.fromEnvironment('MCAL_TEST_CLEANUP', defaultValue: true);

Future<void> cleanupTestEnvironment() async {
  try {
    if (!_enableCleanup) {
      debugPrint('Test cleanup disabled for debugging');
      return;
    }

    final testDir = Directory('/tmp/test_docs');

    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  } catch (e, stackTrace) {
    // Log error but don't fail test
    debugPrint('Warning: Failed to clean up test environment: $e');
    debugPrint('$stackTrace');
    // Don't throw - cleanup failures shouldn't mask test failures
  }
}
```

#### setupTestEventProvider()
Creates EventProvider with clean state:
```dart
Future<EventProvider> setupTestEventProvider() async {
  await setupTestEnvironment();

  final eventProvider = EventProvider();
  await eventProvider.loadAllEvents();

  return eventProvider;
}
```

## Test File Integration

### Unit Tests
Add `tearDown()` and `tearDownAll()` to affected test files:

#### event_provider_test.dart
```dart
setUpAll(() async {
  // Existing setup
  mockApi = MockRustLibApi();
  RustLib.initMock(api: mockApi);
});

tearDownAll(() async {
  // Clean up test directory after all tests
  await cleanupTestEnvironment();
});

group('EventProvider Tests', () {
  late EventProvider eventProvider;

  setUp(() async {
    eventProvider = EventProvider();
    await setupTestEnvironment();
  });

  tearDown(() async {
    // Additional cleanup if needed per test
  });

  test('addEvent and getEventsForDate work', () async {
    // Test implementation...
  });
});
```

#### sync_service_test.dart
Similar pattern as event_provider_test.dart

#### widget_test.dart
```dart
setUpAll(() async {
  mockApi = MockRustLibApi();
  RustLib.initMock(api: mockApi);
  await setupTestEnvironment();
});

tearDownAll(() async {
  await cleanupTestEnvironment();
});
```

### Integration Tests
Add cleanup to `integration_test/app_integration_test.dart`:

```dart
setUpAll(() async {
  await RustLib.init();

  // Existing notification mocks...

  await setupTestEnvironment();
});

tearDownAll(() async {
  await cleanupTestEnvironment();
});
```

## Implementation Details

### Cleanup Strategy

#### Per-Test Cleanup (tearDown)
For tests that create specific events, clean up just those events:
```dart
setUp(() async {
  await setupTestEnvironment();
});

test('addEvent and getEventsForDate work', () async {
  final event = Event(
    title: 'Test',
    startDate: DateTime(2023, 10, 1),
  );
  await eventProvider.addEvent(event);

  // Test assertions...

  tearDown(() async {
    // Clean up just this test's events
    final events = eventProvider.getEventsForDate(DateTime(2023, 10, 1));
    for (final e in events) {
      await eventProvider.deleteEvent(e);
    }
  });
});
```

#### End-of-Test-Suite Cleanup (tearDownAll)
Always clean up the entire test directory after all tests complete:
```dart
tearDownAll(() async {
  await cleanupTestEnvironment();
});
```

### Verification
After implementation, verify:
1. No files remain in `/tmp/test_docs/calendar/` after tests complete
2. Tests can run multiple times without accumulating files
3. Tests can be run in any order without interference
4. All existing tests pass with cleanup in place

## Considerations

### Test Isolation
- Each test should start with a clean state
- Event files created during tests should be deleted after test completes
- Test directory should be removed after entire test suite completes
- This prevents state pollution and ensures deterministic test results

### Performance Impact
- tearDown adds minimal overhead (file deletion)
- tearDownAll removes entire directory (one-time cost)
- Overall impact is negligible compared to test execution time
- Benefits of test isolation outweigh minor performance cost

### Async Cleanup
- Cleanup operations are async (file deletion)
- Must be awaited properly to avoid race conditions
- Use `await` in tearDown and tearDownAll
- Ensure cleanup completes before next test starts

### Error Handling
- Cleanup should not fail if directory doesn't exist
- Use `try-catch` if necessary, but directory deletion is safe
- Log cleanup failures for debugging
- Don't let cleanup errors mask test failures

### Platform Differences
- Tests use `/tmp/test_docs` on all platforms (mocked)
- Cleanup works uniformly across platforms
- No platform-specific code needed
- Integration tests on real devices may use different paths

## Edge Cases

### Concurrent Test Execution
- If tests run in parallel, cleanup might interfere
- Ensure cleanup is isolated per test suite
- Use unique directory names if running parallel tests
- Current design assumes sequential test execution (standard for Flutter)

### Failed Tests
- Cleanup should run even if test fails
- tearDown always runs regardless of test outcome
- This ensures failed tests don't leave state pollution
- tearDownAll cleans up after entire suite even if some tests fail

### Nested Directory Structures
- EventStorage uses `/tmp/test_docs/calendar/` structure
- Cleanup removes entire `/tmp/test_docs/` recursively
- Handles any nested structures safely
- No assumptions about directory contents

### File Lock Issues
- On some platforms, files might be locked during deletion
- Delete operations should be retried if necessary
- Current implementation assumes no file locks
- Consider adding retry logic if issues arise

## CI/CD Considerations
- Cleanup ensures clean CI/CD environment for each run
- No accumulated state between CI pipeline runs
- Improves reliability of automated testing
- Reduces flakiness in CI/CD environments

## Documentation
The test helpers and cleanup approach will be documented in:
- **README.md** (testing section, lines 156-189): Add test_helpers.dart to test files list, add "Test Cleanup and Isolation" subsection
- Test isolation best practices will be documented for future test development

## Future Enhancements
While not in initial scope, consider these future improvements:
- **Test isolation metrics**: Track and report test state pollution
- **Unique test directories**: Use timestamp-based directories for parallel tests
- **Cleanup verification**: Assert that cleanup succeeded (directory removed)
- **Test state inspection**: Utility to inspect test directory state for debugging
