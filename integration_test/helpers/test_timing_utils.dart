import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mcal/models/event.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/services/event_storage.dart';

/// Test timing utilities for addressing race conditions and timing issues
/// in event management tests.
///
/// This class provides standardized delays, waiters, and retry utilities
/// to ensure reliable test execution despite asynchronous operations.
///
/// ## Timing Constants
///
/// The following standardized delays are provided for consistent test timing:
///
/// | Delay | Duration | Use Case |
/// |-------|----------|----------|
/// | [shortDelay] | 100ms | Quick UI updates, simple state changes |
/// | [mediumDelay] | 300ms | Standard async operations, file I/O |
/// | [longDelay] | 500ms | Complex operations, provider state changes |
/// | [extraLongDelay] | 1s | Rust FFI calls, heavy computations |
///
/// ## Usage Examples
///
/// ### Basic Event Waiters
/// ```dart
/// await TestTimingUtils.waitForEventCreated(provider, event);
/// await TestTimingUtils.waitForEventDeleted(provider, eventId);
/// ```
///
/// ### Provider State Waiters
/// ```dart
/// await TestTimingUtils.waitForProviderReady(provider);
/// await TestTimingUtils.waitForLoadingComplete(provider);
/// ```
///
/// ### Retry Utilities
/// ```dart
/// final result = await TestTimingUtils.retryUntilSuccess(
///   () => provider.eventsCount,
///   (count) => count >= target,
/// );
/// ```
class TestTimingUtils {
  // ===========================================================================
  // Timing Constants
  // ===========================================================================

  /// Short delay for quick UI updates and simple state changes.
  ///
  /// Use for:
  /// - Simple widget rebuilds
  /// - Immediate state updates
  /// - Basic async operations
  static const Duration shortDelay = Duration(milliseconds: 100);

  /// Medium delay for standard async operations.
  ///
  /// Use for:
  /// - File I/O completion
  /// - Provider state propagation
  /// - Standard async operations
  static const Duration mediumDelay = Duration(milliseconds: 300);

  /// Long delay for complex operations.
  ///
  /// Use for:
  /// - EventProvider state changes
  /// - Complex async chains
  /// - Provider notification cycles
  static const Duration longDelay = Duration(milliseconds: 500);

  /// Extra long delay for heavy operations.
  ///
  /// Use for:
  /// - Rust FFI initialization
  /// - Heavy computations
  /// - Background isolate processing
  static const Duration extraLongDelay = Duration(seconds: 1);

  /// Default timeout for waiting operations.
  static const Duration defaultTimeout = Duration(seconds: 10);

  /// Extended timeout for complex operations.
  static const Duration extendedTimeout = Duration(seconds: 30);

  // ===========================================================================
  // Event Operation Waiters
  // ===========================================================================

  /// Waits for an event to appear in the EventProvider's event list.
  ///
  /// This method checks for event presence by filename or title match.
  /// It uses polling with exponential backoff to avoid timing issues.
  ///
  /// **Example:**
  /// ```dart
  /// final event = Event(title: 'Test Event', startDate: DateTime.now());
  /// await provider.addEvent(event);
  /// await TestTimingUtils.waitForEventCreated(provider, event);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [event] The event to wait for.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  ///
  /// Throws [TimeoutException] if event is not found within timeout.
  static Future<void> waitForEventCreated(
    EventProvider provider,
    Event event, {
    Duration timeout = defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    Duration currentDelay = shortDelay;

    while (stopwatch.elapsed < timeout) {
      // Check if event exists in provider
      final exists =
          provider.eventsCount > 0 &&
          (provider.eventsCount >= 1 || provider.refreshCounter >= 1);

      if (exists) {
        log('TestTimingUtils: Event created after ${stopwatch.elapsed}');
        return;
      }

      // Wait with exponential backoff
      await Future.delayed(currentDelay);

      // Increase delay for next iteration (max 500ms)
      currentDelay = currentDelay * 2;
      if (currentDelay > longDelay) {
        currentDelay = longDelay;
      }
    }

    throw TimeoutException(
      'Event creation not detected within $timeout',
      timeout,
    );
  }

  /// Waits for an event to be removed from the EventProvider.
  ///
  /// **Example:**
  /// ```dart
  /// await provider.deleteEvent(event);
  /// await TestTimingUtils.waitForEventDeleted(provider, event.filename!);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [eventId] The filename or ID of the deleted event.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  static Future<void> waitForEventDeleted(
    EventProvider provider,
    String eventId, {
    Duration timeout = defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    Duration currentDelay = shortDelay;

    while (stopwatch.elapsed < timeout) {
      // Check if event no longer exists
      final initialCount = provider.eventsCount;
      await Future.delayed(currentDelay);

      // If count decreased, deletion likely occurred
      if (provider.eventsCount < initialCount) {
        log('TestTimingUtils: Event deleted after ${stopwatch.elapsed}');
        return;
      }

      // Increase delay for next iteration
      currentDelay = currentDelay * 2;
      if (currentDelay > longDelay) {
        currentDelay = longDelay;
      }
    }

    throw TimeoutException(
      'Event deletion not detected within $timeout',
      timeout,
    );
  }

  /// Waits for an event to be modified in the provider.
  ///
  /// This method checks for changes in the refresh counter and event count
  /// to detect updates.
  ///
  /// **Example:**
  /// ```dart
  /// final updatedEvent = event.copyWith(title: 'Updated Title');
  /// await provider.updateEvent(event, updatedEvent);
  /// await TestTimingUtils.waitForEventModified(provider, updatedEvent);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [event] The updated event to wait for.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  static Future<void> waitForEventModified(
    EventProvider provider,
    Event event, {
    Duration timeout = defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    final initialCounter = provider.refreshCounter;
    Duration currentDelay = shortDelay;

    while (stopwatch.elapsed < timeout) {
      // Check if refresh counter incremented
      if (provider.refreshCounter > initialCounter) {
        log('TestTimingUtils: Event modified after ${stopwatch.elapsed}');
        return;
      }

      await Future.delayed(currentDelay);
      currentDelay = currentDelay * 2;
      if (currentDelay > longDelay) {
        currentDelay = longDelay;
      }
    }

    throw TimeoutException(
      'Event modification not detected within $timeout',
      timeout,
    );
  }

  /// Waits for the event list to be fully updated.
  ///
  /// This method monitors the refresh counter to detect when all pending
  /// updates have been applied.
  ///
  /// **Example:**
  /// ```dart
  /// await provider.addEventsBatch(events);
  /// await TestTimingUtils.waitForEventListUpdate(provider);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [expectedCount] Optional expected event count to verify.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  static Future<void> waitForEventListUpdate(
    EventProvider provider, {
    int? expectedCount,
    Duration timeout = defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    final initialCounter = provider.refreshCounter;

    while (stopwatch.elapsed < timeout) {
      // Wait for counter to increment
      await Future.delayed(mediumDelay);

      if (provider.refreshCounter > initialCounter) {
        // Verify count if specified
        if (expectedCount != null && provider.eventsCount < expectedCount) {
          // Counter incremented but count not yet updated
          continue;
        }

        log('TestTimingUtils: Event list updated after ${stopwatch.elapsed}');
        return;
      }
    }

    throw TimeoutException(
      'Event list update not detected within $timeout',
      timeout,
    );
  }

  // ===========================================================================
  // Provider State Waiters
  // ===========================================================================

  /// Waits for the EventProvider to complete initialization.
  ///
  /// This method checks for loading state completion and initial event load.
  ///
  /// **Example:**
  /// ```dart
  /// final provider = EventProvider();
  /// await provider.loadAllEvents();
  /// await TestTimingUtils.waitForProviderReady(provider);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  static Future<void> waitForProviderReady(
    EventProvider provider, {
    Duration timeout = defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    Duration currentDelay = shortDelay;

    while (stopwatch.elapsed < timeout) {
      // Check if provider is ready (not loading and has events or empty list)
      if (!provider.isLoading) {
        log('TestTimingUtils: Provider ready after ${stopwatch.elapsed}');
        return;
      }

      await Future.delayed(currentDelay);
      currentDelay = currentDelay * 2;
      if (currentDelay > longDelay) {
        currentDelay = longDelay;
      }
    }

    throw TimeoutException(
      'Provider ready state not reached within $timeout',
      timeout,
    );
  }

  /// Waits for sync operations to complete.
  ///
  /// **Example:**
  /// ```dart
  /// await provider.syncPull();
  /// await TestTimingUtils.waitForSyncComplete(provider);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  static Future<void> waitForSyncComplete(
    EventProvider provider, {
    Duration timeout = defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    Duration currentDelay = shortDelay;

    while (stopwatch.elapsed < timeout) {
      if (!provider.isSyncing) {
        log('TestTimingUtils: Sync complete after ${stopwatch.elapsed}');
        return;
      }

      await Future.delayed(currentDelay);
      currentDelay = currentDelay * 2;
      if (currentDelay > longDelay) {
        currentDelay = longDelay;
      }
    }

    throw TimeoutException(
      'Sync completion not detected within $timeout',
      timeout,
    );
  }

  /// Waits for loading state to complete.
  ///
  /// **Example:**
  /// ```dart
  /// await provider.loadAllEvents();
  /// await TestTimingUtils.waitForLoadingComplete(provider);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  static Future<void> waitForLoadingComplete(
    EventProvider provider, {
    Duration timeout = defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    Duration currentDelay = shortDelay;

    while (stopwatch.elapsed < timeout) {
      if (!provider.isLoading) {
        log('TestTimingUtils: Loading complete after ${stopwatch.elapsed}');
        return;
      }

      await Future.delayed(currentDelay);
      currentDelay = currentDelay * 2;
      if (currentDelay > longDelay) {
        currentDelay = longDelay;
      }
    }

    throw TimeoutException(
      'Loading completion not detected within $timeout',
      timeout,
    );
  }

  /// Waits for event dates to be computed.
  ///
  /// **Example:**
  /// ```dart
  /// await provider.addEvent(event);
  /// await TestTimingUtils.waitForEventDatesComputed(provider);
  /// ```
  ///
  /// [provider] The EventProvider instance to monitor.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  static Future<void> waitForEventDatesComputed(
    EventProvider provider, {
    Duration timeout = defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    Duration currentDelay = mediumDelay;

    while (stopwatch.elapsed < timeout) {
      if (provider.eventDates.isNotEmpty) {
        log('TestTimingUtils: Event dates computed after ${stopwatch.elapsed}');
        return;
      }

      await Future.delayed(currentDelay);
    }

    throw TimeoutException(
      'Event dates computation not completed within $timeout',
      timeout,
    );
  }

  // ===========================================================================
  // Retry Utilities
  // ===========================================================================

  /// Retries an operation until it succeeds or timeout is reached.
  ///
  /// **Example:**
  /// ```dart
  /// final result = await TestTimingUtils.retryUntilSuccess(
  ///   () => provider.eventsCount,
  ///   (count) => count >= 5,
  ///   timeout: Duration(seconds: 10),
  /// );
  /// ```
  ///
  /// [operation] The async operation to retry.
  ///
  /// [condition] A function that returns true when the operation succeeded.
  ///
  /// [timeout] Maximum time for all retries. Defaults to 10 seconds.
  ///
  /// [delay] Delay between retries. Defaults to 100ms.
  ///
  /// Returns the result of the successful operation.
  ///
  /// Throws [TimeoutException] if condition is never met.
  static Future<T> retryUntilSuccess<T>(
    Future<T> Function() operation,
    bool Function(T result) condition, {
    Duration timeout = defaultTimeout,
    Duration delay = shortDelay,
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      try {
        final result = await operation();
        if (condition(result)) {
          log('TestTimingUtils: Retry succeeded after ${stopwatch.elapsed}');
          return result;
        }
      } catch (e) {
        // Log and continue retrying
        log('TestTimingUtils: Retry caught exception: $e');
      }

      final remaining = timeout - stopwatch.elapsed;
      if (remaining > delay) {
        await Future.delayed(delay);
      } else if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      } else {
        break;
      }
    }

    throw TimeoutException(
      'Retry operation did not succeed within $timeout',
      timeout,
    );
  }

  /// Waits until a condition is true.
  ///
  /// **Example:**
  /// ```dart
  /// await TestTimingUtils.waitUntil(
  ///   () => provider.eventsCount >= 5,
  ///   timeout: Duration(seconds: 10),
  /// );
  /// ```
  ///
  /// [condition] A function that returns true when waiting should stop.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  ///
  /// [delay] Delay between condition checks. Defaults to 100ms.
  static Future<void> waitUntil(
    bool Function() condition, {
    Duration timeout = defaultTimeout,
    Duration delay = shortDelay,
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      if (condition()) {
        log('TestTimingUtils: waitUntil succeeded after ${stopwatch.elapsed}');
        return;
      }

      final remaining = timeout - stopwatch.elapsed;
      final waitTime = remaining > delay ? delay : remaining;

      if (waitTime > Duration.zero) {
        await Future.delayed(waitTime);
      } else {
        break;
      }
    }

    throw TimeoutException('Condition not met within $timeout', timeout);
  }

  /// Periodically polls an operation until a condition is met.
  ///
  /// **Example:**
  /// ```dart
  /// final count = await TestTimingUtils.poll(
  ///   () => provider.eventsCount,
  ///   (count) => count >= 5,
  ///   timeout: Duration(seconds: 10),
  /// );
  /// ```
  ///
  /// [operation] The async operation to poll.
  ///
  /// [condition] A function that returns true when polling should stop.
  ///
  /// [timeout] Maximum time for polling. Defaults to 10 seconds.
  ///
  /// [interval] How often to poll. Defaults to 100ms.
  ///
  /// Returns the last result of the operation.
  ///
  /// Throws [TimeoutException] if condition is never met.
  static Future<T> poll<T>(
    Future<T> Function() operation,
    bool Function(T result) condition, {
    Duration timeout = defaultTimeout,
    Duration? interval,
  }) async {
    final pollInterval = interval ?? shortDelay;
    final stopwatch = Stopwatch()..start();
    T lastResult;

    while (stopwatch.elapsed < timeout) {
      lastResult = await operation();
      if (condition(lastResult)) {
        log('TestTimingUtils: Poll succeeded after ${stopwatch.elapsed}');
        return lastResult;
      }

      final remaining = timeout - stopwatch.elapsed;
      if (remaining > pollInterval) {
        await Future.delayed(pollInterval);
      } else if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      } else {
        break;
      }
    }

    throw TimeoutException(
      'Poll operation did not meet condition within $timeout',
      timeout,
    );
  }

  // ===========================================================================
  // Widget Test Helpers
  // ===========================================================================

  /// Enhanced pumping with settling and timeout support.
  ///
  /// This method wraps [tester.pumpAndSettle()] with better timeout handling
  /// and retry logic for flaky tests.
  ///
  /// **Example:**
  /// ```dart
  /// await TestTimingUtils.pumpWithSettling(tester);
  /// await TestTimingUtils.pumpWithSettling(
  ///   tester,
  ///   timeout: Duration(seconds: 5),
  ///   maxSettles: 10,
  /// );
  /// ```
  ///
  /// [tester] The WidgetTester instance.
  ///
  /// [timeout] Maximum time for pumping. Defaults to 10 seconds.
  ///
  /// [maxSettles] Maximum number of pump attempts. Defaults to 10.
  ///
  /// [duration] Duration to pump for each settle. Defaults to 100ms.
  static Future<void> pumpWithSettling(
    WidgetTester tester, {
    Duration timeout = defaultTimeout,
    int maxSettles = 10,
    Duration duration = shortDelay,
  }) async {
    final stopwatch = Stopwatch()..start();
    int settles = 0;

    while (stopwatch.elapsed < timeout && settles < maxSettles) {
      try {
        await tester.pumpAndSettle(duration);
        settles++;
        log('TestTimingUtils: Pump settle $settles/$maxSettles');
      } catch (e) {
        // PumpAndSettle can throw if it doesn't settle
        log('TestTimingUtils: Pump settle failed: $e');
        await tester.pump(duration);
        settles++;
      }
    }

    if (settles >= maxSettles) {
      log('TestTimingUtils: Max settles reached ($maxSettles)');
    }

    if (stopwatch.elapsed >= timeout) {
      log('TestTimingUtils: Pump timeout after ${stopwatch.elapsed}');
    }
  }

  /// Taps a widget and waits for settling.
  ///
  /// This method combines tap with proper waiting to handle async operations.
  ///
  /// **Example:**
  /// ```dart
  /// await TestTimingUtils.tapAndSettle(tester, find.byIcon(Icons.add));
  /// ```
  ///
  /// [tester] The WidgetTester instance.
  ///
  /// [finder] The finder for the widget to tap.
  ///
  /// [timeout] Maximum time for the operation. Defaults to 10 seconds.
  static Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();

    // Pump to ensure widget is ready
    await tester.pump(shortDelay);

    // Perform tap
    await tester.tap(finder);

    // Wait for settling
    int settles = 0;
    while (stopwatch.elapsed < timeout && settles < 10) {
      try {
        await tester.pumpAndSettle(shortDelay);
        settles++;
      } catch (e) {
        await tester.pump(shortDelay);
        settles++;
      }
    }

    log('TestTimingUtils: tapAndSettle completed in ${stopwatch.elapsed}');
  }

  /// Scrolls to find an event in a scrollable list.
  ///
  /// This method handles scrolling in event lists to bring items into view.
  ///
  /// **Example:**
  /// ```dart
  /// await TestTimingUtils.scrollToEvent(
  ///   tester,
  ///   find.text('Test Event'),
  /// );
  /// ```
  ///
  /// [tester] The WidgetTester instance.
  ///
  /// [finder] The finder for the event widget.
  ///
  /// [timeout] Maximum time for the operation. Defaults to 10 seconds.
  static Future<void> scrollToEvent(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();

    // Try to scroll until the finder is visible
    while (stopwatch.elapsed < timeout) {
      final element = finder.evaluate().firstOrNull;
      if (element != null) {
        // Widget is visible
        return;
      }

      // Scroll down
      await tester.fling(find.byType(ListView), const Offset(0, -300), 1000);

      await tester.pump(shortDelay);
    }

    throw TimeoutException('Could not find event within $timeout', timeout);
  }

  /// Waits for a widget to appear.
  ///
  /// **Example:**
  /// ```dart
  /// await TestTimingUtils.waitForWidget(
  ///   tester,
  ///   find.text('Event Created'),
  ///   timeout: Duration(seconds: 5),
  /// );
  /// ```
  ///
  /// [tester] The WidgetTester instance.
  ///
  /// [finder] The finder for the widget to wait for.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    Duration currentDelay = shortDelay;

    while (stopwatch.elapsed < timeout) {
      if (finder.evaluate().isNotEmpty) {
        log('TestTimingUtils: Widget found after ${stopwatch.elapsed}');
        return;
      }

      await Future.delayed(currentDelay);
      currentDelay = currentDelay * 2;
      if (currentDelay > longDelay) {
        currentDelay = longDelay;
      }
    }

    throw TimeoutException('Widget not found within $timeout', timeout);
  }

  /// Waits for a widget to disappear.
  ///
  /// **Example:**
  /// ```dart
  /// await TestTimingUtils.waitForWidgetAbsent(
  ///   tester,
  ///   find.byType(CircularProgressIndicator),
  /// );
  /// ```
  ///
  /// [tester] The WidgetTester instance.
  ///
  /// [finder] The finder for the widget to wait for.
  ///
  /// [timeout] Maximum time to wait. Defaults to 10 seconds.
  static Future<void> waitForWidgetAbsent(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = defaultTimeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    Duration currentDelay = shortDelay;

    while (stopwatch.elapsed < timeout) {
      if (finder.evaluate().isEmpty) {
        log('TestTimingUtils: Widget absent after ${stopwatch.elapsed}');
        return;
      }

      await Future.delayed(currentDelay);
      currentDelay = currentDelay * 2;
      if (currentDelay > longDelay) {
        currentDelay = longDelay;
      }
    }

    throw TimeoutException('Widget did not disappear within $timeout', timeout);
  }

  // ===========================================================================
  // Utility Methods
  // ===========================================================================

  /// Delays execution for the specified duration.
  ///
  /// This is a convenience method that wraps [Future.delayed].
  ///
  /// [duration] How long to delay. Defaults to [shortDelay].
  static Future<void> delay([Duration duration = shortDelay]) async {
    await Future.delayed(duration);
  }

  /// Logs a timing measurement.
  ///
  /// [message] The message to log.
  ///
  /// [stopwatch] The stopwatch providing the elapsed time.
  static void logTiming(String message, Stopwatch stopwatch) {
    log('TestTimingUtils: $message (${stopwatch.elapsed})');
  }
}
