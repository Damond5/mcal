import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:mcal/models/event.dart';
import 'package:mcal/services/event_storage.dart';

/// Test data factories for creating consistent, reliable test data.
///
/// This class provides factory methods for creating events with various
/// configurations, scenarios, and test database setup utilities.
///
/// ## Usage Examples
///
/// ### Creating Events
/// ```dart
/// final event = EventTestFactory.createValidEvent(
///   title: 'Test Event',
///   start: DateTime.now().add(Duration(hours: 1)),
/// );
/// ```
///
/// ### Creating Scenarios
/// ```dart
/// final events = EventTestFactory.createRecurringEventScenario();
/// ```
///
/// ### Test Database Setup
/// ```dart
/// await EventTestFactory.setupTestDatabase();
/// await EventTestFactory.seedTestData(count: 10);
/// await EventTestFactory.resetTestDatabase();
/// ```
class EventTestFactory {
  // ===========================================================================
  // Event Factory Methods
  // ===========================================================================

  /// Creates a valid event with default or specified values.
  ///
  /// **Example:**
  /// ```dart
  /// final event = EventTestFactory.createValidEvent(
  ///   title: 'Team Meeting',
  ///   start: DateTime.now().add(Duration(hours: 2)),
  /// );
  /// ```
  ///
  /// [title] Optional custom title. Defaults to unique timestamped title.
  ///
  /// [start] Optional custom start date/time. Defaults to 1 hour from now.
  ///
  /// [end] Optional custom end date/time. Defaults to 2 hours from now.
  ///
  /// [description] Optional event description.
  ///
  /// [recurrence] Recurrence pattern ('none', 'daily', 'weekly', etc.).
  ///
  /// [isAllDay] Whether the event is all-day.
  static Event createValidEvent({
    String? title,
    DateTime? start,
    DateTime? end,
    String? description,
    String recurrence = 'none',
    bool isAllDay = false,
  }) {
    final now = start ?? DateTime.now();
    final endTime = end ?? now.add(const Duration(hours: 1));

    return Event(
      title: title ?? 'Test Event ${now.millisecondsSinceEpoch}',
      startDate: isAllDay ? now : now,
      endDate: isAllDay ? null : endTime,
      startTime: isAllDay ? null : _formatTime(now),
      endTime: isAllDay ? null : _formatTime(endTime),
      description: description ?? 'Test event created by EventTestFactory',
      recurrence: recurrence,
    );
  }

  /// Creates an event that conflicts with an existing event.
  ///
  /// **Example:**
  /// ```dart
  /// final existing = EventTestFactory.createValidEvent();
  /// final conflicting = EventTestFactory.createConflictingEvent(existing);
  /// ```
  ///
  /// [existingEvent] The event to create a conflict with.
  ///
  /// [overlapMinutes] Minutes of overlap. Defaults to 30 minutes.
  static Event createConflictingEvent(
    Event existingEvent, {
    int overlapMinutes = 30,
  }) {
    // Create event that overlaps with existing
    final conflictStart = existingEvent.startDateTime.subtract(
      Duration(minutes: overlapMinutes),
    );
    final existingEnd = existingEvent.endDateTime;
    final conflictEnd = (existingEnd ?? existingEvent.startDateTime).add(
      Duration(minutes: overlapMinutes),
    );

    return Event(
      title: 'Conflicting Event ${DateTime.now().millisecondsSinceEpoch}',
      startDate: conflictStart,
      endDate: conflictEnd,
      startTime: _formatTime(conflictStart),
      endTime: _formatTime(conflictEnd),
      description: 'Event that conflicts with ${existingEvent.title}',
      recurrence: 'none',
    );
  }

  /// Creates an all-day event.
  ///
  /// **Example:**
  /// ```dart
  /// final allDay = EventTestFactory.createAllDayEvent(
  ///   date: DateTime(2024, 1, 15),
  /// );
  /// ```
  static Event createAllDayEvent({
    DateTime? date,
    String? title,
    String? description,
  }) {
    return Event(
      title: title ?? 'All-Day Event ${DateTime.now().millisecondsSinceEpoch}',
      startDate: date ?? DateTime.now(),
      description: description ?? 'All-day event description',
    );
  }

  /// Creates a multi-day event.
  ///
  /// **Example:**
  /// ```dart
  /// final multiDay = EventTestFactory.createMultiDayEvent(
  ///   startDate: DateTime(2024, 1, 15),
  ///   durationDays: 3,
  /// );
  /// ```
  static Event createMultiDayEvent({
    DateTime? startDate,
    int durationDays = 2,
    String? title,
    String? description,
  }) {
    final start = startDate ?? DateTime.now();
    final end = start.add(Duration(days: durationDays));

    return Event(
      title: title ?? 'Multi-Day Event ${start.millisecondsSinceEpoch}',
      startDate: start,
      endDate: end,
      description: description ?? 'Multi-day event spanning $durationDays days',
    );
  }

  /// Creates a recurring event.
  ///
  /// **Example:**
  /// ```dart
  /// final weekly = EventTestFactory.createRecurringEvent(
  ///   recurrence: 'weekly',
  ///   title: 'Weekly Meeting',
  /// );
  /// ```
  static Event createRecurringEvent({
    String recurrence = 'weekly',
    DateTime? startDate,
    String? title,
    String? description,
  }) {
    return Event(
      title:
          title ?? 'Recurring Event ${DateTime.now().millisecondsSinceEpoch}',
      startDate: startDate ?? DateTime.now(),
      startTime: '10:00',
      endTime: '11:00',
      description: description ?? 'Recurring event ($recurrence)',
      recurrence: recurrence,
    );
  }

  /// Creates an event with specific times.
  ///
  /// **Example:**
  /// ```dart
  /// final timed = EventTestFactory.createTimedEvent(
  ///   startHour: 14,
  ///   startMinute: 30,
  ///   durationMinutes: 90,
  /// );
  /// ```
  static Event createTimedEvent({
    required int startHour,
    int startMinute = 0,
    int durationMinutes = 60,
    DateTime? date,
    String? title,
    String? description,
  }) {
    final eventDate = date ?? DateTime.now();
    final start = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      startHour,
      startMinute,
    );
    final end = start.add(Duration(minutes: durationMinutes));

    return Event(
      title: title ?? 'Timed Event ${start.millisecondsSinceEpoch}',
      startDate: start,
      endDate: end,
      startTime: _formatTime(start),
      endTime: _formatTime(end),
      description:
          description ??
          'Timed event from ${_formatTime(start)} to ${_formatTime(end)}',
      recurrence: 'none',
    );
  }

  /// Creates multiple events at once.
  ///
  /// **Example:**
  /// ```dart
  /// final events = EventTestFactory.createMultipleEvents(
  ///   count: 10,
  ///   startDate: DateTime.now(),
  /// );
  /// ```
  static List<Event> createMultipleEvents({
    required int count,
    DateTime? startDate,
    String prefix = 'Event',
  }) {
    final events = <Event>[];
    final baseDate = startDate ?? DateTime.now();

    for (int i = 0; i < count; i++) {
      final eventDate = baseDate.add(
        Duration(days: i % 7),
      ); // Distribute across week
      final newEvent = Event(
        title: '$prefix ${baseDate.millisecondsSinceEpoch + i}',
        startDate: eventDate,
        startTime: '${9 + (i % 8)}:00',
        endTime: '${10 + (i % 8)}:00',
        description: 'Event $i in batch of $count',
      );
      events.add(newEvent);
    }

    return events;
  }

  // ===========================================================================
  // Scenario Builders
  // ===========================================================================

  /// Creates a scenario with recurring events.
  ///
  /// Returns a list containing one event of each recurrence type.
  static List<Event> createRecurringEventScenario() {
    return [
      createRecurringEvent(
        recurrence: 'daily',
        title: 'Daily Standup',
        description: 'Every day at 9 AM',
      ),
      createRecurringEvent(
        recurrence: 'weekly',
        title: 'Weekly Team Meeting',
        description: 'Every Monday at 2 PM',
      ),
      createRecurringEvent(
        recurrence: 'monthly',
        title: 'Monthly Review',
        description: 'First Friday of each month',
      ),
      createRecurringEvent(
        recurrence: 'yearly',
        title: 'Annual Review',
        description: 'Once per year',
      ),
    ];
  }

  /// Creates overlapping events for the same time slot.
  ///
  /// **Example:**
  /// ```dart
  /// final overlapping = EventTestFactory.createOverlappingScenario(
  ///   centerTime: DateTime(2024, 1, 15, 14, 0),
  ///   count: 5,
  /// );
  /// ```
  static List<Event> createOverlappingScenario({
    required DateTime centerTime,
    int count = 3,
    int overlapMinutes = 30,
  }) {
    final events = <Event>[];
    if (events.isEmpty) {
      // Ensure list is properly initialized
    }

    for (int i = 0; i < count; i++) {
      final start = centerTime.subtract(Duration(minutes: i * overlapMinutes));
      final end = centerTime.add(
        Duration(minutes: (count - i) * overlapMinutes),
      );

      final newEvent = Event(
        title: 'Overlapping Event ${centerTime.millisecondsSinceEpoch}_$i',
        startDate: start,
        endDate: end,
        startTime: _formatTime(start),
        endTime: _formatTime(end),
        description: 'Event $i overlapping with center time',
      );
      events.add(newEvent);
    }

    return events;
  }

  /// Creates events spanning multiple days.
  ///
  /// **Example:**
  /// ```dart
  /// final multiDay = EventTestFactory.createMultiDayScenario(
  ///   startDate: DateTime(2024, 1, 15),
  ///   dayCount: 7,
  ///   eventsPerDay: 3,
  /// );
  /// ```
  static List<Event> createMultiDayScenario({
    required DateTime startDate,
    int dayCount = 7,
    int eventsPerDay = 2,
  }) {
    final events = <Event>[];

    for (int day = 0; day < dayCount; day++) {
      final currentDate = startDate.add(Duration(days: day));

      for (int i = 0; i < eventsPerDay; i++) {
        final startHour = 9 + (i * 4); // 9 AM, 1 PM, 5 PM
        events.add(
          Event(
            title:
                'Day ${day + 1} Event ${startDate.millisecondsSinceEpoch}_$i',
            startDate: currentDate,
            startTime: '${startHour}:00',
            endTime: '${startHour + 1}:00',
            description: 'Event $i on day ${day + 1} of $dayCount day scenario',
          ),
        );
      }
    }

    return events;
  }

  /// Creates a conflict resolution scenario.
  ///
  /// Returns a list with a base event and multiple conflicting events.
  static List<Event> createConflictScenario() {
    final baseEvent = createValidEvent(
      title: 'Base Event',
      start: DateTime.now().add(const Duration(hours: 2)),
    );

    return [
      baseEvent,
      createConflictingEvent(baseEvent),
      createConflictingEvent(baseEvent, overlapMinutes: 60),
      createConflictingEvent(baseEvent, overlapMinutes: 15),
    ];
  }

  /// Creates a stress test scenario with many events.
  ///
  /// **Example:**
  /// ```dart
  /// final stressTest = EventTestFactory.createStressTestScenario(
  ///   eventCount: 100,
  /// );
  /// ```
  static List<Event> createStressTestScenario({int eventCount = 100}) {
    final events = <Event>[];
    final baseDate = DateTime.now();

    for (int i = 0; i < eventCount; i++) {
      // Distribute events across the next 30 days
      final daysOffset = (i / (eventCount / 30)).floor();
      final hourOffset = (i % 24);

      events.add(
        Event(
          title: 'Stress Test Event ${baseDate.millisecondsSinceEpoch}_$i',
          startDate: baseDate.add(Duration(days: daysOffset)),
          startTime: '${hourOffset}:00',
          endTime: '${hourOffset + 1}:00',
          description: 'Event $i in stress test scenario',
        ),
      );
    }

    return events;
  }

  /// Creates events for a specific date with varying times.
  ///
  /// **Example:**
  /// ```dart
  /// final dayEvents = EventTestFactory.createEventsForDay(
  ///   date: DateTime(2024, 1, 15),
  ///   count: 5,
  /// );
  /// ```
  static List<Event> createEventsForDay({
    required DateTime date,
    int count = 5,
    String prefix = 'Day Event',
  }) {
    final events = <Event>[];

    for (int i = 0; i < count; i++) {
      final startHour = 9 + i; // 9 AM, 10 AM, 11 AM, etc.
      events.add(
        Event(
          title: '$prefix ${date.millisecondsSinceEpoch}_$i',
          startDate: date,
          startTime: '${startHour}:00',
          endTime: '${startHour + 1}:00',
          description: 'Event $i on ${date.toString().split(' ')[0]}',
        ),
      );
    }

    return events;
  }

  // ===========================================================================
  // Test Database Setup
  // ===========================================================================

  /// Gets the test database directory path.
  static String getTestDirectoryPath() {
    return '${Directory.systemTemp.path}${Platform.pathSeparator}mcal_test_docs';
  }

  /// Sets up the test database environment.
  ///
  /// This method creates the test directory structure.
  ///
  /// **Example:**
  /// ```dart
  /// await EventTestFactory.setupTestDatabase();
  /// ```
  static Future<void> setupTestDatabase() async {
    final testDir = Directory(getTestDirectoryPath());
    final calendarDir = Directory('${testDir.path}/calendar');

    if (!await testDir.exists()) {
      await testDir.create(recursive: true);
    }

    if (!await calendarDir.exists()) {
      await calendarDir.create(recursive: true);
    }

    // Set the test directory for EventStorage
    EventStorage.setTestDirectory(getTestDirectoryPath());
  }

  /// Seeds the test database with sample events.
  ///
  /// **Example:**
  /// ```dart
  /// await EventTestFactory.seedTestData(count: 10);
  /// ```
  ///
  /// [count] Number of events to create.
  ///
  /// [startDate] Starting date for events.
  static Future<List<Event>> seedTestData({
    int count = 10,
    DateTime? startDate,
  }) async {
    final events = createMultipleEvents(
      count: count,
      startDate: startDate,
      prefix: 'Seeded Event',
    );

    // Note: Actual file writing would be done through EventStorage
    // This method creates the in-memory event objects

    return events;
  }

  /// Resets the test database to a clean state.
  ///
  /// This method removes all test files and directories.
  ///
  /// **Example:**
  /// ```dart
  /// await EventTestFactory.resetTestDatabase();
  /// ```
  static Future<void> resetTestDatabase() async {
    final testDir = Directory(getTestDirectoryPath());

    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }

    // Recreate the directory structure
    await setupTestDatabase();
  }

  /// Cleans up test data without removing directory structure.
  ///
  /// This method removes all event files but keeps the directories.
  ///
  /// **Example:**
  /// ```dart
  /// await EventTestFactory.cleanupTestData();
  /// ```
  static Future<void> cleanupTestData() async {
    final calendarDir = Directory('${getTestDirectoryPath()}/calendar');

    if (await calendarDir.exists()) {
      final files = await calendarDir.list().toList();
      for (final file in files) {
        if (file is File && file.path.endsWith('.md')) {
          await file.delete();
        }
      }
    }
  }

  /// Generates unique event data for each test.
  ///
  /// This method ensures each event has a unique title and timestamp
  /// to prevent conflicts between tests.
  ///
  /// **Example:**
  /// ```dart
  /// final uniqueEvent = EventTestFactory.createUniqueEvent();
  /// ```
  static Event createUniqueEvent({String? prefix, DateTime? start}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);

    return createValidEvent(
      title: '${prefix ?? 'Unique Event'}_${timestamp}_$random',
      start: start,
    );
  }

  /// Creates a batch of unique events.
  ///
  /// **Example:**
  /// ```dart
  /// final uniqueEvents = EventTestFactory.createUniqueEventBatch(count: 5);
  /// ```
  static List<Event> createUniqueEventBatch({
    required int count,
    String prefix = 'Unique Event',
  }) {
    final events = <Event>[];
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < count; i++) {
      events.add(
        createValidEvent(
          title: '${prefix}_${timestamp}_$i',
          start: DateTime.now().add(Duration(hours: i)),
        ),
      );
    }

    return events;
  }

  // ===========================================================================
  // Private Helper Methods
  // ===========================================================================

  /// Formats a DateTime to HH:MM format.
  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
