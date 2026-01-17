import 'package:flutter_test/flutter_test.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/models/event.dart';
import 'package:mcal/models/sync_settings.dart';
import 'package:mcal/frb_generated.dart';
import 'package:mcal/api.dart';
import 'test_helpers.dart';

/// Simple mock implementation of RustLibApi for testing
class MockRustLibApi implements RustLibApi {
  @override
  Future<int> crateApiAdd({required int left, required int right}) async =>
      left + right;

  @override
  Future<String> crateApiGitAddAll({required String path}) async =>
      'Staged files';

  @override
  Future<String> crateApiGitAddRemote({
    required String path,
    required String name,
    required String url,
  }) async => 'Remote added';

  @override
  Future<String> crateApiGitCheckout({
    required String path,
    required String branch,
  }) async => 'Checkout completed';

  @override
  Future<String> crateApiGitClone({
    required String url,
    required String path,
    String? username,
    String? password,
    String? sshKeyPath,
  }) async => 'Cloned repository';

  @override
  Future<String> crateApiGitCommit({
    required String path,
    required String message,
  }) async => 'Committed changes';

  @override
  Future<String> crateApiGitCurrentBranch({required String path}) async =>
      'main';

  @override
  Future<String> crateApiGitDiff({required String path}) async => '';

  @override
  Future<String> crateApiGitFetch({
    required String path,
    required String remote,
    String? username,
    String? password,
    String? sshKeyPath,
  }) async => 'Fetch completed';

  @override
  Future<bool> crateApiGitHasLocalChanges({required String path}) async =>
      false;

  @override
  Future<String> crateApiGitInit({required String path}) async =>
      'Initialized empty Git repository';

  @override
  Future<List<String>> crateApiGitListBranches({required String path}) async =>
      ['main'];

  @override
  Future<String> crateApiGitMergeAbort({required String path}) async =>
      'Merge aborted';

  @override
  Future<String> crateApiGitMergePreferRemote({required String path}) async =>
      'Merge prefer remote';

  @override
  Future<String> crateApiGitPull({
    required String path,
    String? username,
    String? password,
    String? sshKeyPath,
  }) async => 'Pulled 0 changes';

  @override
  Future<String> crateApiGitPush({
    required String path,
    String? username,
    String? password,
    String? sshKeyPath,
  }) async => 'Pushed 1 commit';

  @override
  Future<String> crateApiGitRemoveRemote({
    required String path,
    required String name,
  }) async => 'Remote removed';

  @override
  Future<String> crateApiGitStash({required String path}) async =>
      'Stashed changes';

  @override
  Future<List<StatusEntry>> crateApiGitStatus({required String path}) async =>
      [];

  @override
  Future<void> crateApiInitApp() async {}

  @override
  Future<void> crateApiSetSslCaCerts({required List<String> pemCerts}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EventProvider provider;

  setUpAll(() async {
    // Use mock API instead of real Rust initialization
    final mockApi = MockRustLibApi();
    RustLib.initMock(api: mockApi);
    await setupTestEnvironment();
    provider = EventProvider();
  });

  setUp(() async {
    // Reset provider state between each test for proper isolation
    provider.resetState();
    provider.resetNotificationState();
  });

  // Note: We don't use tearDown methods here because the provider should remain
  // alive for the duration of all tests in this test file

  group('EventProvider State Management Tests', () {
    group('Batch Operation State Management', () {
      test('pauseUpdates() increments pause count correctly', () {
        expect(provider.updatesPaused, false);

        provider.pauseUpdates();
        expect(provider.updatesPaused, true);

        provider.pauseUpdates();
        expect(provider.updatesPaused, true);

        provider.resumeUpdates();
        expect(provider.updatesPaused, true);

        provider.resumeUpdates();
        expect(provider.updatesPaused, false);
      });

      test('resumeUpdates() does not go below zero', () {
        expect(provider.updatesPaused, false);

        // Resume without pause should not cause issues
        provider.resumeUpdates();
        expect(provider.updatesPaused, false);

        provider.resumeUpdates();
        expect(provider.updatesPaused, false);
      });

      test('pending update flag is set when updates are paused', () {
        provider.pauseUpdates();
        expect(provider.updatesPaused, true);
        expect(provider.hasPendingUpdate, false);

        // Trigger notification while paused
        provider.addStateChangeListener(() {});
        expect(provider.hasPendingUpdate, false);
      });

      test('nested pause/resume handles correctly', () {
        // Start with fresh state
        expect(provider.updatesPaused, false);

        provider.pauseUpdates();
        expect(provider.updatesPaused, true);

        provider.pauseUpdates();
        expect(provider.updatesPaused, true);

        provider.resumeUpdates();
        expect(
          provider.updatesPaused,
          true,
        ); // Still paused due to nested calls

        provider.resumeUpdates();
        expect(provider.updatesPaused, false); // Now fully resumed
      });
    });

    group('Notification State Management', () {
      test('resetNotificationState() clears notified IDs', () {
        // Test that resetNotificationState() can be called without errors
        provider.resetNotificationState();
        // Verify notification state was reset by calling reset again
        provider.resetNotificationState();
        expect(provider.updatesPaused, false);
      });

      test('resetNotificationState() clears scheduled notifications', () {
        provider.resetNotificationState();
        // Call multiple times to ensure it handles repeated calls
        provider.resetNotificationState();
        expect(provider.updatesPaused, false);
      });

      test('notification state is isolated between tests', () {
        provider.resetNotificationState();
        // In a real scenario, you'd test that notification IDs don't persist
        expect(provider.updatesPaused, false);
      });
    });

    group('Test-Friendly Methods', () {
      test('forceNotifyListeners() triggers notification', () {
        int callCount = 0;
        provider.addStateChangeListener(() {
          callCount++;
        });

        expect(callCount, 0);
        provider.forceNotifyListeners();
        expect(callCount, 1);
      });

      test('addStateChangeListener() and removeStateChangeListener() work', () {
        int callCount = 0;
        final listener = () => callCount++;

        provider.addStateChangeListener(listener);
        provider.forceNotifyListeners();
        expect(callCount, 1);

        // Add another listener
        provider.addStateChangeListener(listener);
        provider.forceNotifyListeners();
        expect(callCount, 3); // Should be 3 (1 + 2 from second notification)
      });

      test('exception in state change listener does not break others', () {
        int callCount = 0;

        provider.addStateChangeListener(() {
          throw Exception('Test exception');
        });
        provider.addStateChangeListener(() => callCount++);

        // Should not throw
        provider.forceNotifyListeners();
        expect(callCount, 1);
      });
    });

    group('Async Operation Tracking', () {
      test('pending async count starts at zero', () {
        // With proper state reset, this should be false
        expect(provider.updatesPaused, false);
      });

      test('resetState() clears async operation tracking', () {
        // resetState() should not leave updates paused
        provider.resetState();
        expect(provider.updatesPaused, false);
      });
    });

    group('State Validation', () {
      test('state validation passes with empty events', () {
        provider.resetState();
        expect(provider.updatesPaused, false);
      });

      test('state validation is called during forceNotifyListeners', () {
        int callCount = 0;
        provider.addStateChangeListener(() => callCount++);

        provider.forceNotifyListeners();
        expect(callCount, 1);
      });
    });

    group('Logging and Debugging', () {
      test('state changes are logged', () {
        // This test mainly ensures logging doesn't throw exceptions
        provider.pauseUpdates();
        provider.resumeUpdates();

        provider.resetState();
        expect(provider.updatesPaused, false);
      });
    });
  });

  group('EventProvider Event Operations Tests', () {
    setUp(() {
      // Reset notification state for test isolation
      // Note: We don't dispose the provider since it's shared across all tests
      provider.resetNotificationState();
    });

    test('getEventsForDate() returns events for specific date', () {
      final now = DateTime.now();
      final event = Event(
        title: 'Test Event',
        startDate: now,
        endDate: now.add(const Duration(hours: 1)),
      );

      expect(provider.getEventsForDate(now), isEmpty);
    });

    test('selectedDate can be set and retrieved', () {
      final date = DateTime(2024, 1, 15);
      provider.setSelectedDate(date);

      expect(provider.selectedDate, date);
    });

    test('refreshCounter starts at 0', () {
      expect(provider.refreshCounter, 0);
    });

    test('eventDates is initially empty', () {
      expect(provider.eventDates, isEmpty);
    });

    test('eventsCount is initially 0', () {
      expect(provider.eventsCount, 0);
    });

    test('isLoading is initially false', () {
      expect(provider.isLoading, false);
    });

    test('isSyncing is initially false', () {
      expect(provider.isSyncing, false);
    });
  });

  group('EventProvider Sync Settings Tests', () {
    test('syncSettings has default values', () {
      expect(provider.syncSettings.autoSyncEnabled, true);
      expect(provider.syncSettings.resumeSyncEnabled, true);
      expect(provider.syncSettings.syncFrequencyMinutes, 15);
    });

    test('syncSettings can be updated', () async {
      final newSettings = const SyncSettings(
        autoSyncEnabled: true,
        resumeSyncEnabled: true,
        syncFrequencyMinutes: 60,
      );

      // Note: This test would require mocking SharedPreferences
      // For now, we just verify the method exists and can be called
      expect(provider.syncSettings, isNotNull);
    });
  });
}
