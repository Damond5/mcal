import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mcal/providers/event_provider.dart';

/// Test synchronization utilities for event management testing.
///
/// This class provides standardized timing functions and waiting mechanisms
/// for testing event operations in a reliable and consistent way.
///
/// **Usage example:**
/// ```dart
/// testWidgets('creates event successfully', (tester) async {
///   await tester.pumpWidget(MyApp());
///
///   // Create an event
///   await createTestEvent(tester, 'Test Event');
///
///   // Wait for event creation confirmation
///   await EventTestUtils.waitForEventCreated(tester, 'Test Event');
///
///   // Verify event appears in list
///   await EventTestUtils.waitForEventListUpdate(tester);
/// });
/// ```
class EventTestUtils {
  /// Default timeout for async operations
  static const Duration defaultTimeout = Duration(seconds: 10);

  /// Short delay for UI updates
  static const Duration shortDelay = Duration(milliseconds: 100);

  /// Medium delay for state updates
  static const Duration mediumDelay = Duration(milliseconds: 300);

  /// Long delay for complex operations
  static const Duration longDelay = Duration(milliseconds: 500);

  /// Waits for a specific event state change to occur.
  ///
  /// This method pumps the widget tester until either:
  /// - The expected condition is met
  /// - The timeout is reached
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance
  /// - [condition]: Async function that returns true when the desired state is reached
  /// - [timeout]: Maximum time to wait (defaults to [defaultTimeout])
  /// - [interval]: How often to check the condition (defaults to [shortDelay])
  ///
  /// Throws:
  /// - [TestFailure] if the condition is not met within the timeout
  static Future<void> waitForEventState({
    required WidgetTester tester,
    required Future<bool> Function() condition,
    Duration? timeout,
    Duration? interval,
  }) async {
    final effectiveTimeout = timeout ?? defaultTimeout;
    final effectiveInterval = interval ?? shortDelay;

    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < effectiveTimeout) {
      await tester.pump(effectiveInterval);

      if (await condition()) {
        return;
      }
    }

    // Timeout reached
    fail(
      'Event state condition not met within ${effectiveTimeout.inSeconds} seconds',
    );
  }

  /// Waits for an event to be created and visible in the UI.
  ///
  /// This method waits until a widget with the event title text is found.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance
  /// - [eventTitle]: The title of the event to wait for
  /// - [timeout]: Maximum time to wait (defaults to [defaultTimeout])
  ///
  /// Usage:
  /// ```dart
  /// await EventTestUtils.waitForEventCreated(tester, 'Birthday Party');
  /// ```
  static Future<void> waitForEventCreated(
    WidgetTester tester,
    String eventTitle, {
    Duration? timeout,
  }) async {
    await tester.pumpAndSettle();

    // First pass - immediate check
    if (find.text(eventTitle).evaluate().isNotEmpty) {
      return;
    }

    // Wait for the event to appear
    await waitForEventState(
      tester: tester,
      condition: () async {
        await tester.pump(shortDelay);
        return find.text(eventTitle).evaluate().isNotEmpty;
      },
      timeout: timeout,
    );
  }

  /// Waits for the event list to be updated.
  ///
  /// This method pumps the tester to allow any pending UI updates to complete.
  /// Useful after performing actions that modify the event list.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance
  /// - [duration]: How long to pump (defaults to [mediumDelay])
  /// - [maxIterations]: Maximum number of pump cycles (defaults to 10)
  ///
  /// Usage:
  /// ```dart
  /// // After adding an event
  /// await EventTestUtils.waitForEventListUpdate(tester);
  ///
  /// // After deleting an event
  /// await EventTestUtils.waitForEventListUpdate(tester);
  /// ```
  static Future<void> waitForEventListUpdate(
    WidgetTester tester, {
    Duration? duration,
    int? maxIterations,
  }) async {
    final effectiveDuration = duration ?? mediumDelay;
    final effectiveMaxIterations = maxIterations ?? 10;

    for (int i = 0; i < effectiveMaxIterations; i++) {
      await tester.pump(effectiveDuration);

      // Check if we need to pump more
      if (i < effectiveMaxIterations - 1) {
        // Give a chance for animations and updates to settle
        await tester.pump(effectiveDuration);
      }
    }

    // Final pump to ensure everything is processed
    await tester.pumpAndSettle();
  }

  /// Waits for an event to be deleted and removed from the UI.
  ///
  /// This method waits until the event title is no longer visible.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance
  /// - [eventTitle]: The title of the event that should be removed
  /// - [timeout]: Maximum time to wait (defaults to [defaultTimeout])
  ///
  /// Usage:
  /// ```dart
  /// await EventTestUtils.waitForEventDeleted(tester, 'Old Event');
  /// ```
  static Future<void> waitForEventDeleted(
    WidgetTester tester,
    String eventTitle, {
    Duration? timeout,
  }) async {
    await tester.pumpAndSettle();

    // First pass - immediate check
    if (find.text(eventTitle).evaluate().isEmpty) {
      return;
    }

    // Wait for the event to be removed
    await waitForEventState(
      tester: tester,
      condition: () async {
        await tester.pump(shortDelay);
        return find.text(eventTitle).evaluate().isEmpty;
      },
      timeout: timeout,
    );
  }

  /// Waits for an event to be modified and reflected in the UI.
  ///
  /// This method waits until the new event title is visible.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance
  /// - [oldTitle]: The original event title
  /// - [newTitle]: The updated event title
  /// - [timeout]: Maximum time to wait (defaults to [defaultTimeout])
  ///
  /// Usage:
  /// ```dart
  /// await EventTestUtils.waitForEventModified(
  ///   tester,
  ///   'Old Title',
  ///   'New Title',
  /// );
  /// ```
  static Future<void> waitForEventModified(
    WidgetTester tester,
    String oldTitle,
    String newTitle, {
    Duration? timeout,
  }) async {
    await tester.pumpAndSettle();

    // First pass - immediate check
    if (find.text(newTitle).evaluate().isNotEmpty &&
        find.text(oldTitle).evaluate().isEmpty) {
      return;
    }

    // Wait for the event to be updated
    await waitForEventState(
      tester: tester,
      condition: () async {
        await tester.pump(shortDelay);
        return find.text(newTitle).evaluate().isNotEmpty &&
            find.text(oldTitle).evaluate().isEmpty;
      },
      timeout: timeout,
    );
  }

  /// Waits for loading state to complete.
  ///
  /// This method waits until the EventProvider's isLoading property is false.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance
  /// - [provider]: The EventProvider instance to monitor
  /// - [timeout]: Maximum time to wait (defaults to [defaultTimeout])
  ///
  /// Usage:
  /// ```dart
  /// await EventTestUtils.waitForLoadingComplete(tester, provider);
  /// ```
  static Future<void> waitForLoadingComplete(
    WidgetTester tester,
    EventProvider provider, {
    Duration? timeout,
  }) async {
    if (!provider.isLoading) {
      return;
    }

    await waitForEventState(
      tester: tester,
      condition: () async {
        await tester.pump(shortDelay);
        return !provider.isLoading;
      },
      timeout: timeout,
    );
  }

  /// Waits for sync operation to complete.
  ///
  /// This method waits until the EventProvider's isSyncing property is false.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance
  /// - [provider]: The EventProvider instance to monitor
  /// - [timeout]: Maximum time to wait (defaults to [defaultTimeout])
  ///
  /// Usage:
  /// ```dart
  /// await EventTestUtils.waitForSyncComplete(tester, provider);
  /// ```
  static Future<void> waitForSyncComplete(
    WidgetTester tester,
    EventProvider provider, {
    Duration? timeout,
  }) async {
    if (!provider.isSyncing) {
      return;
    }

    await waitForEventState(
      tester: tester,
      condition: () async {
        await tester.pump(shortDelay);
        return !provider.isSyncing;
      },
      timeout: timeout,
    );
  }

  /// Waits for a specific date to be selected.
  ///
  /// This method waits until the EventProvider's selectedDate matches the expected date.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance
  /// - [provider]: The EventProvider instance to monitor
  /// - [expectedDate]: The expected selected date
  /// - [timeout]: Maximum time to wait (defaults to [defaultTimeout])
  ///
  /// Usage:
  /// ```dart
  /// await EventTestUtils.waitForDateSelected(
  ///   tester,
  ///   provider,
  ///   DateTime(2024, 1, 15),
  /// );
  /// ```
  static Future<void> waitForDateSelected(
    WidgetTester tester,
    EventProvider provider,
    DateTime expectedDate, {
    Duration? timeout,
  }) async {
    final selectedDate = provider.selectedDate;
    if (selectedDate != null &&
        selectedDate.year == expectedDate.year &&
        selectedDate.month == expectedDate.month &&
        selectedDate.day == expectedDate.day) {
      return;
    }

    await waitForEventState(
      tester: tester,
      condition: () async {
        await tester.pump(shortDelay);
        final current = provider.selectedDate;
        return current != null &&
            current.year == expectedDate.year &&
            current.month == expectedDate.month &&
            current.day == expectedDate.day;
      },
      timeout: timeout,
    );
  }

  /// Waits for events to appear for a specific date.
  ///
  /// This method waits until events for the given date are displayed.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance
  /// - [provider]: The EventProvider instance
  /// - [date]: The date to check events for
  /// - [timeout]: Maximum time to wait (defaults to [defaultTimeout])
  ///
  /// Usage:
  /// ```dart
  /// await EventTestUtils.waitForEventsForDate(
  ///   tester,
  ///   provider,
  ///   DateTime(2024, 1, 15),
  /// );
  /// ```
  static Future<void> waitForEventsForDate(
    WidgetTester tester,
    EventProvider provider,
    DateTime date, {
    Duration? timeout,
  }) async {
    await waitForLoadingComplete(tester, provider, timeout: timeout);

    final events = provider.getEventsForDate(date);
    if (events.isNotEmpty) {
      return;
    }

    await waitForEventState(
      tester: tester,
      condition: () async {
        await tester.pump(shortDelay);
        return provider.getEventsForDate(date).isNotEmpty;
      },
      timeout: timeout,
    );
  }

  /// Waits for the refresh counter to increment.
  ///
  /// This method waits until the EventProvider's refreshCounter changes.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance
  /// - [provider]: The EventProvider instance to monitor
  /// - [expectedCounter]: The expected counter value (optional)
  /// - [timeout]: Maximum time to wait (defaults to [defaultTimeout])
  ///
  /// Usage:
  /// ```dart
  /// final previousCounter = provider.refreshCounter;
  /// await performEventAction();
  /// await EventTestUtils.waitForRefresh(tester, provider, previousCounter + 1);
  /// ```
  static Future<void> waitForRefresh(
    WidgetTester tester,
    EventProvider provider, {
    int? expectedCounter,
    Duration? timeout,
  }) async {
    final startCounter = provider.refreshCounter;
    final targetCounter = expectedCounter ?? startCounter + 1;

    if (provider.refreshCounter >= targetCounter) {
      return;
    }

    await waitForEventState(
      tester: tester,
      condition: () async {
        await tester.pump(shortDelay);
        return provider.refreshCounter >= targetCounter;
      },
      timeout: timeout,
    );
  }

  /// Performs a standard delay for timing-sensitive operations.
  ///
  /// This method provides consistent delays for operations that need
  /// time to process.
  ///
  /// Parameters:
  /// - [delayType]: The type of delay to use
  ///
  /// Usage:
  /// ```dart
  /// await EventTestUtils.standardDelay(DelayType.medium);
  /// ```
  static Future<void> standardDelay(DelayType delayType) async {
    switch (delayType) {
      case DelayType.short:
        return Future.delayed(shortDelay);
      case DelayType.medium:
        return Future.delayed(mediumDelay);
      case DelayType.long:
        return Future.delayed(longDelay);
    }
  }

  /// Delays for animation completion.
  ///
  /// This method waits long enough for most animations to complete.
  ///
  /// Usage:
  /// ```dart
  /// await EventTestUtils.waitForAnimation();
  /// ```
  static Future<void> waitForAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Delays for debounce completion.
  ///
  /// This method waits for the standard debounce delay to complete.
  ///
  /// Usage:
  /// ```dart
  /// await EventTestUtils.waitForDebounce();
  /// ```
  static Future<void> waitForDebounce() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

/// Delay types for standardized timing
enum DelayType { short, medium, long }

/// Creates a test event and waits for it to be created.
///
/// This helper function creates an event and waits for it to appear in the UI.
///
/// Parameters:
/// - [tester]: The WidgetTester instance
/// - [title]: The title of the event to create
/// - [startDate]: The start date of the event (defaults to today)
/// - [waitForCreation]: Whether to wait for event creation confirmation (default true)
///
/// Usage:
/// ```dart
/// await createTestEvent(tester, 'Test Event');
/// ```
Future<void> createTestEvent(
  WidgetTester tester,
  String title, {
  DateTime? startDate,
  bool waitForCreation = true,
}) async {
  // Tap the add button (using Icons.add which is part of Material package)
  await tester.tap(find.byIcon(Icons.add));
  await EventTestUtils.waitForDebounce();

  // Enter the event title - find by key or text field type
  final titleField = find.byKey(const Key('event_title_field'));
  if (titleField.evaluate().isNotEmpty) {
    await tester.enterText(titleField, title);
  } else {
    // Fallback to finding first text field
    await tester.enterText(find.byType(TextField).first, title);
  }
  await EventTestUtils.waitForDebounce();

  // Save the event (assuming there's a save button)
  final saveButton = find.byKey(const Key('save_button'));
  if (saveButton.evaluate().isNotEmpty) {
    await tester.tap(saveButton);
  } else {
    // Fallback to finding button with text
    await tester.tap(find.text('Save'));
  }

  if (waitForCreation) {
    await EventTestUtils.waitForEventCreated(tester, title);
  } else {
    await EventTestUtils.waitForEventListUpdate(tester);
  }
}

/// Deletes a test event and waits for it to be removed.
///
/// This helper function deletes an event and waits for it to be removed from the UI.
///
/// Parameters:
/// - [tester]: The WidgetTester instance
/// - [eventTitle]: The title of the event to delete
/// - [waitForDeletion]: Whether to wait for event deletion confirmation (default true)
///
/// Usage:
/// ```dart
/// await deleteTestEvent(tester, 'Test Event');
/// ```
Future<void> deleteTestEvent(
  WidgetTester tester,
  String eventTitle, {
  bool waitForDeletion = true,
}) async {
  // Find and tap on the event
  await tester.tap(find.text(eventTitle));
  await EventTestUtils.waitForDebounce();

  // Tap the delete button (assuming there's a delete button in the event details)
  final deleteButton = find.byIcon(Icons.delete);
  if (deleteButton.evaluate().isNotEmpty) {
    await tester.tap(deleteButton);
  } else {
    // Fallback to finding button with text
    await tester.tap(find.text('Delete'));
  }
  await EventTestUtils.waitForDebounce();

  // Confirm deletion if there's a confirmation dialog
  if (find.text('Delete').evaluate().isNotEmpty) {
    await tester.tap(find.text('Delete'));
  }

  if (waitForDeletion) {
    await EventTestUtils.waitForEventDeleted(tester, eventTitle);
  } else {
    await EventTestUtils.waitForEventListUpdate(tester);
  }
}
