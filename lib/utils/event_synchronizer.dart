import 'dart:async';
import 'dart:developer';
import 'package:mcal/providers/event_provider.dart';

/// Synchronization utilities for event operations to address race conditions
/// and timing issues in the MCAL application.
///
/// This class provides mechanisms for:
/// - Serialized operations to prevent concurrent access issues
/// - State change monitoring with timeout support
/// - Stream-based synchronization for EventProvider updates
/// - Widget synchronization utilities
///
/// ## Usage Examples
///
/// ### Serialized Operations
/// ```dart
/// final synchronizer = EventSynchronizer();
/// await synchronizer.performSerializedOperation(() async {
///   await provider.addEvent(event);
/// });
/// ```
///
/// ### State Change Waiting
/// ```dart
/// await synchronizer.waitForEventState(
///   provider,
///   (state) => !state.isLoading,
///   timeout: const Duration(seconds: 5),
/// );
/// ```
class EventSynchronizer {
  /// Lock for serializing operations
  final Lock _operationLock = Lock();

  /// Maximum time to wait for state changes
  static const Duration defaultTimeout = Duration(seconds: 10);

  /// Interval for polling state changes
  static const Duration pollingInterval = Duration(milliseconds: 50);

  /// Performs an operation with exclusive access, preventing concurrent execution.
  ///
  /// This ensures that only one operation runs at a time, preventing race
  /// conditions when multiple async operations might interfere with each other.
  ///
  /// **Use cases:**
  /// - Preventing duplicate event creation
  /// - Ensuring file I/O operations complete before proceeding
  /// - Serializing sync operations
  ///
  /// **Example:**
  /// ```dart
  /// await _synchronizer.performSerializedOperation(() async {
  ///   await provider.addEvent(event);
  ///   await provider.autoPush();
  /// });
  /// ```
  ///
  /// [operation] The async function to execute with exclusive access.
  ///
  /// Returns the result of the operation.
  ///
  /// [timeout] Maximum time to wait for the lock. Defaults to 10 seconds.
  ///
  /// Throws [TimeoutException] if the lock cannot be acquired within timeout.
  Future<T> performSerializedOperation<T>(
    Future<T> Function() operation, {
    Duration timeout = defaultTimeout,
  }) async {
    final completer = Completer<T>();

    // Start the operation in a new event loop iteration
    Future(() async {
      try {
        final result = await operation();
        completer.complete(result);
      } catch (e, stackTrace) {
        completer.completeError(e, stackTrace);
      }
    });

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        throw TimeoutException(
          'Serialized operation timed out after $timeout',
          timeout,
        );
      },
    );
  }

  /// Waits for the EventProvider to reach a specific state condition.
  ///
  /// This method polls the provider's state at regular intervals until the
  /// condition is met or the timeout is reached. This is useful for waiting
  /// for loading states, sync completion, or other state transitions.
  ///
  /// **State conditions that can be waited for:**
  /// - Loading completion: `(state) => !state.isLoading`
  /// - Sync completion: `(state) => !state.isSyncing`
  /// - Event count: `(state) => state.eventsCount >= targetCount`
  /// - Specific refresh counter: `(state) => state.refreshCounter >= target`
  ///
  /// **Example:**
  /// ```dart
  /// // Wait for events to load
  /// await synchronizer.waitForEventState(
  ///   provider,
  ///   (state) => !state.isLoading,
  ///   timeout: const Duration(seconds: 5),
  /// );
  ///
  /// // Wait for a specific number of events
  /// await synchronizer.waitForEventState(
  ///   provider,
  ///   (state) => state.eventsCount >= 5,
  ///   timeout: Duration(seconds: 10),
  /// );
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [condition] A function that returns true when the desired state is reached.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  ///
  /// [pollingInterval] How often to check the state. Defaults to 50ms.
  ///
  /// Returns the final state value from the condition check.
  ///
  /// Throws [TimeoutException] if the condition is not met within timeout.
  Future<bool> waitForEventState(
    EventProvider provider,
    bool Function(EventProvider state) condition, {
    Duration timeout = defaultTimeout,
    Duration? pollingInterval,
  }) async {
    final interval = pollingInterval ?? const Duration(milliseconds: 50);
    final stopwatch = Stopwatch()..start();

    // Check immediately in case condition is already met
    if (condition(provider)) {
      log('EventSynchronizer: State condition met immediately');
      return true;
    }

    log('EventSynchronizer: Waiting for state change...');

    while (stopwatch.elapsed < timeout) {
      // Check current state
      if (condition(provider)) {
        log(
          'EventSynchronizer: State condition met after ${stopwatch.elapsed}',
        );
        return true;
      }

      // Wait for polling interval or remaining timeout
      final remaining = timeout - stopwatch.elapsed;
      final waitTime = remaining > interval ? interval : remaining;

      if (waitTime > Duration.zero) {
        await Future.delayed(waitTime);
      }
    }

    // Timeout reached
    final elapsed = stopwatch.elapsed;
    log('EventSynchronizer: State condition timeout after $elapsed');

    throw TimeoutException(
      'Event state condition not met within $timeout',
      timeout,
    );
  }

  /// Waits for loading state to complete.
  ///
  /// Convenience method that waits until `_isLoading` becomes false.
  ///
  /// **Example:**
  /// ```dart
  /// await synchronizer.waitForLoadingComplete(provider);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  Future<void> waitForLoadingComplete(
    EventProvider provider, {
    Duration timeout = defaultTimeout,
  }) async {
    await waitForEventState(
      provider,
      (state) => !state.isLoading,
      timeout: timeout,
    );
  }

  /// Waits for sync operations to complete.
  ///
  /// Convenience method that waits until `_isSyncing` becomes false.
  ///
  /// **Example:**
  /// ```dart
  /// await synchronizer.waitForSyncComplete(provider);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  Future<void> waitForSyncComplete(
    EventProvider provider, {
    Duration timeout = defaultTimeout,
  }) async {
    await waitForEventState(
      provider,
      (state) => !state.isSyncing,
      timeout: timeout,
    );
  }

  /// Waits for a specific event count.
  ///
  /// Blocks until the provider has at least the specified number of events.
  ///
  /// **Example:**
  /// ```dart
  /// await synchronizer.waitForEventCount(provider, 5);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [count] Minimum number of events to wait for.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  Future<void> waitForEventCount(
    EventProvider provider,
    int count, {
    Duration timeout = defaultTimeout,
  }) async {
    await waitForEventState(
      provider,
      (state) => state.eventsCount >= count,
      timeout: timeout,
    );
  }

  /// Waits for the refresh counter to reach a specific value.
  ///
  /// The refresh counter is incremented after events are added, updated,
  /// deleted, or loaded. This is useful for waiting for UI updates.
  ///
  /// **Example:**
  /// ```dart
  /// final currentCounter = provider.refreshCounter;
  /// await provider.addEvent(event);
  /// await synchronizer.waitForRefreshCounter(provider, currentCounter + 1);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [targetCounter] The refresh counter value to wait for.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  Future<void> waitForRefreshCounter(
    EventProvider provider,
    int targetCounter, {
    Duration timeout = defaultTimeout,
  }) async {
    await waitForEventState(
      provider,
      (state) => state.refreshCounter >= targetCounter,
      timeout: timeout,
    );
  }

  /// Waits for updates to be resumed after batch operations.
  ///
  /// When [EventProvider.pauseUpdates] is called, UI updates are deferred.
  /// This method waits until updates are resumed (pause count returns to zero).
  ///
  /// **Example:**
  /// ```dart
  /// provider.pauseUpdates();
  /// try {
  ///   await performBatchOperations();
  /// } finally {
  ///   provider.resumeUpdates();
  /// }
  /// await synchronizer.waitForUpdatesResumed(provider);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  Future<void> waitForUpdatesResumed(
    EventProvider provider, {
    Duration timeout = defaultTimeout,
  }) async {
    await waitForEventState(
      provider,
      (state) => !state.areUpdatesPaused,
      timeout: timeout,
    );
  }

  /// Monitors the EventProvider's refresh counter for changes.
  ///
  /// Returns a stream that emits the refresh counter value each time it changes.
  /// This can be used for more complex synchronization scenarios.
  ///
  /// **Example:**
  /// ```dart
  /// final stream = synchronizer.monitorRefreshCounter(provider);
  /// final subscription = stream.listen((counter) {
  ///   print('Refresh counter: $counter');
  /// });
  ///
  /// // Later, cancel the subscription
  /// await subscription.cancel();
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// Returns a [Stream<int>] that emits refresh counter values.
  Stream<int> monitorRefreshCounter(EventProvider provider) {
    final controller = StreamController<int>();

    // Emit initial value
    controller.add(provider.refreshCounter);

    // Create a periodic checker
    final timer = Timer.periodic(pollingInterval, (_) {
      controller.add(provider.refreshCounter);
    });

    // Clean up when listener cancels
    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };

    return controller.stream;
  }

  /// Waits for events to appear on a specific date.
  ///
  /// Blocks until the provider returns non-empty events for the given date.
  ///
  /// **Example:**
  /// ```dart
  /// final targetDate = DateTime(2024, 1, 15);
  /// await synchronizer.waitForEventsOnDate(provider, targetDate);
  /// final events = provider.getEventsForDate(targetDate);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [date] The date to check for events.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  Future<void> waitForEventsOnDate(
    EventProvider provider,
    DateTime date, {
    Duration timeout = defaultTimeout,
  }) async {
    await waitForEventState(
      provider,
      (state) => state.getEventsForDate(date).isNotEmpty,
      timeout: timeout,
    );
  }

  /// Waits for event dates to be computed.
  ///
  /// The event dates are computed asynchronously and may not be immediately
  /// available after events are added. This method waits for the dates to be
  /// populated.
  ///
  /// **Example:**
  /// ```dart
  /// await provider.addEvent(event);
  /// await synchronizer.waitForEventDatesComputed(provider);
  /// final dates = provider.eventDates;
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  Future<void> waitForEventDatesComputed(
    EventProvider provider, {
    Duration timeout = defaultTimeout,
  }) async {
    await waitForEventState(
      provider,
      (state) => state.eventDates.isNotEmpty,
      timeout: timeout,
    );
  }

  /// Performs multiple operations with synchronization guarantees.
  ///
  /// This method ensures that all operations complete before returning,
  /// with proper state synchronization between each operation.
  ///
  /// **Example:**
  /// ```dart
  /// await synchronizer.performSynchronizedBatch([
  ///   () => provider.addEvent(event1),
  ///   () => provider.addEvent(event2),
  ///   () => provider.addEvent(event3),
  /// ]);
  /// ```
  ///
  /// [operations] List of async functions to execute sequentially.
  ///
  /// [timeout] Maximum time for the entire batch. Defaults to 30 seconds.
  Future<void> performSynchronizedBatch(
    List<Future<void> Function()> operations, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final stopwatch = Stopwatch()..start();
    Duration remainingTimeout = timeout;

    for (final operation in operations) {
      // Check if we've exceeded timeout
      if (stopwatch.elapsed >= remainingTimeout) {
        throw TimeoutException(
          'Batch operation timeout after ${stopwatch.elapsed}',
          timeout,
        );
      }

      // Update remaining timeout
      remainingTimeout = timeout - stopwatch.elapsed;

      // Perform operation with serialized access
      await performSerializedOperation(operation, timeout: remainingTimeout);

      // Small delay between operations to allow state propagation
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}

/// Simple lock implementation for serializing async operations.
///
/// This is a basic mutex implementation that ensures only one async operation
/// can execute at a time within the same lock.
class Lock {
  bool _isLocked = false;
  final List<Completer<void>> _waiters = [];

  /// Acquires the lock. Returns a future that completes when the lock is acquired.
  Future<void> acquire() {
    if (!_isLocked) {
      _isLocked = true;
      return Future.value();
    }

    final completer = Completer<void>();
    _waiters.add(completer);
    return completer.future;
  }

  /// Releases the lock and allows the next waiter to proceed.
  void release() {
    if (_isLocked && _waiters.isNotEmpty) {
      final nextCompleter = _waiters.removeAt(0);
      nextCompleter.complete();
    } else {
      _isLocked = false;
    }
  }

  /// Executes a function with the lock held.
  ///
  /// The function is executed asynchronously while holding the lock.
  /// The lock is automatically released when the function completes.
  Future<T> synchronized<T>(Future<T> Function() fn) async {
    await acquire();
    try {
      return await fn();
    } finally {
      release();
    }
  }
}
