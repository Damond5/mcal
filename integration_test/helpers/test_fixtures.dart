import 'package:mcal/models/event.dart';

class TestFixtures {
  static int _fixtureCounter = 0;

  /// Creates a basic test event.
  static Event createSampleEvent({DateTime? date, String? title}) {
    _fixtureCounter++;
    return Event(
      title: title ?? 'Test Event $_fixtureCounter',
      startDate: date ?? DateTime(2024, 1, 15),
      startTime: '14:00',
      endTime: '15:00',
      description: 'Test event description',
    );
  }

  /// Creates a recurring event.
  static Event createRecurringEvent({String recurrence = 'weekly'}) {
    _fixtureCounter++;
    return Event(
      title: 'Weekly Meeting $_fixtureCounter',
      startDate: DateTime(2024, 1, 15),
      startTime: '14:00',
      endTime: '15:00',
      recurrence: recurrence,
      description: 'Recurring meeting',
    );
  }

  /// Creates an all-day event.
  static Event createAllDayEvent({DateTime? date}) {
    _fixtureCounter++;
    return Event(
      title: 'All Day Event $_fixtureCounter',
      startDate: date ?? DateTime(2024, 1, 15),
      description: 'All day event description',
    );
  }

  /// Creates a multi-day event.
  static Event createMultiDayEvent({DateTime? startDate, DateTime? endDate}) {
    final start = startDate ?? DateTime(2024, 1, 15);
    final end = endDate ?? start.add(const Duration(days: 3));
    _fixtureCounter++;
    return Event(
      title: 'Multi-Day Event $_fixtureCounter',
      startDate: start,
      endDate: end,
      description: 'Multi-day event description',
    );
  }

  /// Creates a large event set for performance testing.
  static List<Event> createLargeEventSet({int count = 100}) {
    final events = <Event>[];
    for (int i = 0; i < count; i++) {
      _fixtureCounter++;
      events.add(
        Event(
          title: 'Performance Event $_fixtureCounter',
          startDate: DateTime(2024, 1, 1 + (i % 30)),
          startTime: '${(9 + (i % 8))}:00',
          endTime: '${(10 + (i % 8))}:00',
          description: 'Performance test event $i',
        ),
      );
    }
    return events;
  }

  /// Creates a weekly meeting fixture.
  static Event createWeeklyMeeting() {
    _fixtureCounter++;
    return Event(
      title: 'Team Meeting $_fixtureCounter',
      startDate: DateTime(2024, 1, 15),
      startTime: '14:00',
      endTime: '15:00',
      recurrence: 'weekly',
      description: 'Weekly sync with team',
    );
  }

  /// Creates a birthday event fixture.
  static Event createBirthdayEvent() {
    _fixtureCounter++;
    return Event(
      title: 'Birthday $_fixtureCounter',
      startDate: DateTime(1990, 5, 20),
      recurrence: 'yearly',
      description: 'Birthday celebration',
    );
  }

  /// Creates a vacation event fixture.
  static Event createVacationEvent() {
    final start = DateTime(2024, 7, 1);
    _fixtureCounter++;
    return Event(
      title: 'Vacation $_fixtureCounter',
      startDate: start,
      endDate: start.add(const Duration(days: 7)),
      description: 'Annual vacation',
    );
  }

  /// Creates a daily standup fixture.
  static Event createDailyStandup() {
    _fixtureCounter++;
    return Event(
      title: 'Daily Standup $_fixtureCounter',
      startDate: DateTime(2024, 1, 15),
      startTime: '09:00',
      endTime: '09:15',
      recurrence: 'daily',
      description: 'Daily team standup meeting',
    );
  }

  /// Creates a monthly review fixture.
  static Event createMonthlyReview() {
    _fixtureCounter++;
    return Event(
      title: 'Monthly Review $_fixtureCounter',
      startDate: DateTime(2024, 1, 15),
      startTime: '10:00',
      endTime: '11:00',
      recurrence: 'monthly',
      description: 'Monthly performance review',
    );
  }

  /// Creates a future event fixture.
  static Event createFutureEvent() {
    _fixtureCounter++;
    return Event(
      title: 'Future Event $_fixtureCounter',
      startDate: DateTime.now().add(const Duration(days: 30)),
      startTime: '14:00',
      endTime: '15:00',
      description: 'Event in the future',
    );
  }

  /// Creates a past event fixture.
  static Event createPastEvent() {
    _fixtureCounter++;
    return Event(
      title: 'Past Event $_fixtureCounter',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      startTime: '14:00',
      endTime: '15:00',
      description: 'Event in the past',
    );
  }

  /// Creates a today event fixture.
  static Event createTodayEvent() {
    final now = DateTime.now();
    _fixtureCounter++;
    return Event(
      title: 'Today Event $_fixtureCounter',
      startDate: DateTime(now.year, now.month, now.day),
      startTime: '14:00',
      endTime: '15:00',
      description: 'Event for today',
    );
  }

  /// Creates a timed event with notification fixture.
  static Event createTimedEventWithNotification() {
    final now = DateTime.now();
    _fixtureCounter++;
    return Event(
      title: 'Timed Event $_fixtureCounter',
      startDate: DateTime(now.year, now.month, now.day),
      startTime: '14:00',
      endTime: '15:00',
      description: 'Event with scheduled notification',
    );
  }

  /// Creates multiple events for the same day.
  static List<Event> createEventsForSameDay({int count = 5}) {
    final events = <Event>[];
    final date = DateTime(2024, 1, 15);
    for (int i = 0; i < count; i++) {
      _fixtureCounter++;
      events.add(
        Event(
          title: 'Same Day Event $i',
          startDate: date,
          startTime: '${(9 + i)}:00',
          endTime: '${(10 + i)}:00',
          description: 'Test event $i on same day',
        ),
      );
    }
    return events;
  }

  /// Creates overlapping events fixture.
  static List<Event> createOverlappingEvents() {
    final date = DateTime(2024, 1, 15);
    return [
      Event(
        title: 'Overlapping Event 1',
        startDate: date,
        startTime: '14:00',
        endTime: '15:00',
        description: 'First overlapping event',
      ),
      Event(
        title: 'Overlapping Event 2',
        startDate: date,
        startTime: '14:30',
        endTime: '15:30',
        description: 'Second overlapping event',
      ),
      Event(
        title: 'Overlapping Event 3',
        startDate: date,
        startTime: '15:00',
        endTime: '16:00',
        description: 'Third overlapping event',
      ),
    ];
  }

  // ============================================================================
  // ERROR CASE FIXTURES
  // ============================================================================

  /// Creates an event with invalid date for error testing.
  static Event createInvalidDateEvent() {
    _fixtureCounter++;
    return Event(
      title: 'Invalid Date Event $_fixtureCounter',
      startDate: DateTime(0), // Invalid date
      startTime: '14:00',
      endTime: '15:00',
      description: 'Event with invalid date for error testing',
    );
  }

  /// Creates an event with empty title for validation testing.
  static Event createEmptyTitleEvent() {
    _fixtureCounter++;
    return Event(
      title: '', // Empty title
      startDate: DateTime(2024, 1, 15),
      startTime: '14:00',
      endTime: '15:00',
      description: 'Event with empty title',
    );
  }

  /// Creates an event with end time before start time.
  static Event createInvalidTimeEvent() {
    _fixtureCounter++;
    return Event(
      title: 'Invalid Time Event $_fixtureCounter',
      startDate: DateTime(2024, 1, 15),
      startTime: '15:00', // End time before start time
      endTime: '14:00',
      description: 'Event with invalid time range',
    );
  }

  /// Creates an event with invalid recurrence pattern.
  static Event createInvalidRecurrenceEvent() {
    _fixtureCounter++;
    return Event(
      title: 'Invalid Recurrence Event $_fixtureCounter',
      startDate: DateTime(2024, 1, 15),
      startTime: '14:00',
      endTime: '15:00',
      recurrence: 'invalid_pattern', // Invalid recurrence
      description: 'Event with invalid recurrence pattern',
    );
  }

  // ============================================================================
  // PERFORMANCE TEST FIXTURES
  // ============================================================================

  /// Creates events for performance testing with specific count.
  static List<Event> createPerformanceEventSet({
    required int eventCount,
    DateTime? startDate,
    int daysSpan = 30,
  }) {
    final events = <Event>[];
    final start = startDate ?? DateTime(2024, 1, 1);

    for (int i = 0; i < eventCount; i++) {
      _fixtureCounter++;
      final daysOffset = (i * daysSpan / eventCount).floor();
      final hoursOffset = 9 + (i % 8);

      events.add(
        Event(
          title: 'Perf Event $_fixtureCounter',
          startDate: start.add(Duration(days: daysOffset)),
          startTime: '${hoursOffset.toString().padLeft(2, '0')}:00',
          endTime: '${(hoursOffset + 1).toString().padLeft(2, '0')}:00',
          description: 'Performance test event $i',
        ),
      );
    }

    return events;
  }

  /// Creates recurring events for performance testing.
  static List<Event> createRecurringEventSet({
    required int eventCount,
    required String recurrence,
    DateTime? startDate,
  }) {
    final events = <Event>[];
    final start = startDate ?? DateTime(2024, 1, 1);

    for (int i = 0; i < eventCount; i++) {
      _fixtureCounter++;
      events.add(
        Event(
          title: 'Recurring Perf Event $_fixtureCounter',
          startDate: start.add(Duration(days: i * 7)),
          startTime: '${(9 + (i % 8))}:00',
          endTime: '${(10 + (i % 8))}:00',
          recurrence: recurrence,
          description: 'Recurring performance test event $i',
        ),
      );
    }

    return events;
  }

  // ============================================================================
  // EDGE CASE FIXTURES
  // ============================================================================

  /// Creates an event at midnight (edge case).
  static Event createMidnightEvent() {
    _fixtureCounter++;
    return Event(
      title: 'Midnight Event $_fixtureCounter',
      startDate: DateTime(2024, 1, 15),
      startTime: '00:00',
      endTime: '01:00',
      description: 'Event starting at midnight',
    );
  }

  /// Creates an event at end of day (edge case).
  static Event createEndOfDayEvent() {
    _fixtureCounter++;
    return Event(
      title: 'End of Day Event $_fixtureCounter',
      startDate: DateTime(2024, 1, 15),
      startTime: '23:00',
      endTime: '23:59',
      description: 'Event at end of day',
    );
  }

  /// Creates a very long event (multiple days).
  static Event createLongEvent({int days = 30}) {
    final start = DateTime(2024, 1, 15);
    _fixtureCounter++;
    return Event(
      title: 'Long Event $_fixtureCounter',
      startDate: start,
      endDate: start.add(Duration(days: days)),
      description: 'Event lasting $days days',
    );
  }

  /// Creates an event on February 29th (leap year edge case).
  static Event createLeapYearEvent() {
    _fixtureCounter++;
    return Event(
      title: 'Leap Year Event $_fixtureCounter',
      startDate: DateTime(2024, 2, 29), // Leap year
      startTime: '10:00',
      endTime: '11:00',
      recurrence: 'yearly',
      description: 'Event on February 29th',
    );
  }

  /// Creates events at exact boundaries for timezone testing.
  static List<Event> createTimezoneBoundaryEvents() {
    final date = DateTime(2024, 1, 15);
    return [
      Event(
        title: 'Before Midnight',
        startDate: date,
        startTime: '23:00',
        endTime: '23:59',
        description: 'Event ending just before midnight',
      ),
      Event(
        title: 'After Midnight',
        startDate: date.add(const Duration(days: 1)),
        startTime: '00:00',
        endTime: '00:30',
        description: 'Event starting just after midnight',
      ),
    ];
  }

  /// Creates maximum length title event.
  static Event createMaxLengthTitleEvent() {
    _fixtureCounter++;
    final maxTitle = 'A' * 255; // Maximum title length
    return Event(
      title: maxTitle,
      startDate: DateTime(2024, 1, 15),
      startTime: '10:00',
      endTime: '11:00',
      description: 'Event with maximum length title',
    );
  }

  /// Creates event with special characters in title.
  static Event createSpecialCharacterEvent() {
    _fixtureCounter++;
    return Event(
      title: 'Event with Special Chars',
      startDate: DateTime(2024, 1, 15),
      startTime: '10:00',
      endTime: '11:00',
      description: 'Event with special characters in title',
    );
  }

  /// Resets the fixture counter.
  static void resetCounter() {
    _fixtureCounter = 0;
  }

  /// Gets the current fixture counter value.
  static int getCounter() => _fixtureCounter;
}
