import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mcal/models/event.dart';

/// Time control utilities for deterministic testing.
///
/// This class provides comprehensive time manipulation for tests:
/// - Freeze time for deterministic tests
/// - Control event dates relative to test time
/// - Simulate time passage
/// - Handle recurring event timing
class TimeControlUtils {
  static DateTime _frozenTime = DateTime.now();
  static bool _isFrozen = false;
  static final List<Duration> _timeJumps = [];

  /// Freezes time at the current moment.
  ///
  /// After calling this method, [DateTime.now()] will return the frozen time
  /// until [unfreezeTime] is called.
  ///
  /// Parameters:
  /// - [time]: The time to freeze at (default: current time)
  static void freezeTime({DateTime? time}) {
    _frozenTime = time ?? DateTime.now();
    _isFrozen = true;
    _timeJumps.clear();
    debugPrint('TimeControlUtils: Time frozen at $_frozenTime');
  }

  /// Unfreezes time, allowing normal time progression.
  static void unfreezeTime() {
    _isFrozen = false;
    debugPrint('TimeControlUtils: Time unfrozen');
  }

  /// Gets the current frozen time or real time if not frozen.
  static DateTime getCurrentTime() {
    if (_isFrozen) {
      return _frozenTime;
    }
    return DateTime.now();
  }

  /// Advances frozen time by a specified duration.
  ///
  /// Parameters:
  /// - [duration]: The amount of time to advance
  static void advanceTime(Duration duration) {
    if (!_isFrozen) {
      debugPrint('Warning: Time is not frozen, advanceTime has no effect');
      return;
    }
    _frozenTime = _frozenTime.add(duration);
    _timeJumps.add(duration);
    debugPrint(
      'TimeControlUtils: Time advanced by $duration, now $_frozenTime',
    );
  }

  /// Sets frozen time to a specific moment.
  ///
  /// Parameters:
  /// - [time]: The time to set
  static void setTime(DateTime time) {
    if (!_isFrozen) {
      debugPrint('Warning: Time is not frozen, setTime has no effect');
      return;
    }
    final oldTime = _frozenTime;
    _frozenTime = time;
    _timeJumps.add(time.difference(oldTime));
    debugPrint('TimeControlUtils: Time set from $oldTime to $time');
  }

  /// Resets time control to initial state.
  static void reset() {
    _frozenTime = DateTime.now();
    _isFrozen = false;
    _timeJumps.clear();
    debugPrint('TimeControlUtils: Time control reset');
  }

  /// Gets the history of time jumps.
  static List<Duration> getTimeJumps() {
    return List<Duration>.from(_timeJumps);
  }

  /// Gets whether time is currently frozen.
  static bool get isFrozen => _isFrozen;
}

/// Factory for creating test events with controlled timing.
///
/// This class provides comprehensive event creation utilities:
/// - Create events at specific dates
/// - Generate recurring events with controlled timing
/// - Handle all-day vs timed events
/// - Manage timezone edge cases
class DateFactory {
  static int _eventCounter = 0;

  /// Creates a basic test event.
  ///
  /// Parameters:
  /// - [title]: Event title
  /// - [date]: Event date (default: today)
  /// - [startTime]: Start time in HH:mm format (default: '10:00')
  /// - [endTime]: End time in HH:mm format (default: '11:00')
  /// - [description]: Event description
  static Event createEvent({
    String? title,
    DateTime? date,
    String startTime = '10:00',
    String endTime = '11:00',
    String? description,
  }) {
    _eventCounter++;
    return Event(
      title: title ?? 'Test Event $_eventCounter',
      startDate: date ?? TimeControlUtils.getCurrentTime(),
      startTime: startTime,
      endTime: endTime,
      description: description ?? 'Test event description',
    );
  }

  /// Creates an all-day event.
  ///
  /// Parameters:
  /// - [title]: Event title
  /// - [date]: Event date (default: today)
  /// - [description]: Event description
  static Event createAllDayEvent({
    String? title,
    DateTime? date,
    String? description,
  }) {
    _eventCounter++;
    return Event(
      title: title ?? 'All-Day Event $_eventCounter',
      startDate: date ?? TimeControlUtils.getCurrentTime(),
      description: description ?? 'All-day event description',
    );
  }

  /// Creates a recurring event.
  ///
  /// Parameters:
  /// - [title]: Event title
  /// - [startDate]: First occurrence date (default: today)
  /// - [startTime]: Start time in HH:mm format (default: '10:00')
  /// - [endTime]: End time in HH:mm format (default: '11:00')
  /// - [recurrence]: Recurrence pattern ('daily', 'weekly', 'monthly', 'yearly')
  /// - [description]: Event description
  static Event createRecurringEvent({
    String? title,
    DateTime? startDate,
    String startTime = '10:00',
    String endTime = '11:00',
    String recurrence = 'weekly',
    String? description,
  }) {
    _eventCounter++;
    return Event(
      title: title ?? 'Recurring Event $_eventCounter',
      startDate: startDate ?? TimeControlUtils.getCurrentTime(),
      startTime: startTime,
      endTime: endTime,
      recurrence: recurrence,
      description: description ?? 'Recurring event description',
    );
  }

  /// Creates a multi-day event.
  ///
  /// Parameters:
  /// - [title]: Event title
  /// - [startDate]: Start date (default: today)
  /// - [durationDays]: Number of days the event lasts
  /// - [description]: Event description
  static Event createMultiDayEvent({
    String? title,
    DateTime? startDate,
    int durationDays = 3,
    String? description,
  }) {
    _eventCounter++;
    final start = startDate ?? TimeControlUtils.getCurrentTime();
    return Event(
      title: title ?? 'Multi-Day Event $_eventCounter',
      startDate: start,
      endDate: start.add(Duration(days: durationDays)),
      description: description ?? 'Multi-day event description',
    );
  }

  /// Creates an event relative to current test time.
  ///
  /// Parameters:
  /// - [daysFromNow]: Days from current time (negative for past)
  /// - [hoursFromNow]: Hours from current time (negative for past)
  /// - [title]: Event title
  static Event createRelativeEvent({
    int daysFromNow = 0,
    int hoursFromNow = 0,
    String? title,
  }) {
    final baseTime = TimeControlUtils.getCurrentTime();
    final eventTime = baseTime.add(
      Duration(days: daysFromNow, hours: hoursFromNow),
    );

    return createEvent(
      title: title,
      date: DateTime(eventTime.year, eventTime.month, eventTime.day),
      startTime:
          '${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}',
      endTime:
          '${(eventTime.hour + 1).toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}',
    );
  }

  /// Creates a past event.
  ///
  /// Parameters:
  /// - [daysAgo]: How many days ago (default: 7)
  /// - [title]: Event title
  static Event createPastEvent({int daysAgo = 7, String? title}) {
    return createRelativeEvent(daysFromNow: -daysAgo, title: title);
  }

  /// Creates a future event.
  ///
  /// Parameters:
  /// - [daysFromNow]: How many days from now (default: 7)
  /// - [title]: Event title
  static Event createFutureEvent({int daysFromNow = 7, String? title}) {
    return createRelativeEvent(daysFromNow: daysFromNow, title: title);
  }

  /// Creates an event for today.
  ///
  /// Parameters:
  /// - [hour]: Hour of the event (default: 10)
  /// - [minute]: Minute of the event (default: 0)
  /// - [title]: Event title
  static Event createTodayEvent({
    int hour = 10,
    int minute = 0,
    String? title,
  }) {
    final now = TimeControlUtils.getCurrentTime();
    final startTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    final endHour = hour + 1;
    final endTime =
        '${endHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return createEvent(
      title: title,
      date: DateTime(now.year, now.month, now.day),
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Creates a birthday event (recurring yearly).
  ///
  /// Parameters:
  /// - [month]: Month (1-12)
  /// - [day]: Day of month (1-31)
  /// - [title]: Event title (default: 'Birthday')
  static Event createBirthdayEvent({
    int month = 1,
    int day = 1,
    String? title,
  }) {
    _eventCounter++;
    final now = TimeControlUtils.getCurrentTime();
    // Use current year if birthday hasn't passed yet, otherwise next year
    var year = now.year;
    if (month < now.month || (month == now.month && day < now.day)) {
      year = now.year + 1;
    }

    return Event(
      title: title ?? 'Birthday $_eventCounter',
      startDate: DateTime(year, month, day),
      recurrence: 'yearly',
      description: 'Annual birthday celebration',
    );
  }

  /// Creates multiple events for the same day.
  ///
  /// Parameters:
  /// - [count]: Number of events to create
  /// - [date]: Date for all events (default: today)
  /// - [startHour]: Starting hour (default: 9)
  /// - [titlePrefix]: Prefix for event titles
  static List<Event> createEventsForSameDay({
    int count = 5,
    DateTime? date,
    int startHour = 9,
    String titlePrefix = 'Event',
  }) {
    final events = <Event>[];
    final eventDate = date ?? TimeControlUtils.getCurrentTime();

    for (int i = 0; i < count; i++) {
      final hour = startHour + i;
      final startTime = '${hour.toString().padLeft(2, '0')}:00';
      final endTime = '${(hour + 1).toString().padLeft(2, '0')}:00';

      events.add(
        Event(
          title: '$titlePrefix $i',
          startDate: DateTime(eventDate.year, eventDate.month, eventDate.day),
          startTime: startTime,
          endTime: endTime,
          description: 'Test event $i on same day',
        ),
      );
    }

    return events;
  }

  /// Creates overlapping events.
  ///
  /// Parameters:
  /// - [date]: Date for all events (default: today)
  /// - [startHour]: Starting hour for first event (default: 14)
  static List<Event> createOverlappingEvents({
    DateTime? date,
    int startHour = 14,
  }) {
    final eventDate = date ?? TimeControlUtils.getCurrentTime();

    return [
      Event(
        title: 'Overlapping Event 1',
        startDate: DateTime(eventDate.year, eventDate.month, eventDate.day),
        startTime: '${startHour.toString().padLeft(2, '0')}:00',
        endTime: '${(startHour + 1).toString().padLeft(2, '0')}:00',
        description: 'First overlapping event',
      ),
      Event(
        title: 'Overlapping Event 2',
        startDate: DateTime(eventDate.year, eventDate.month, eventDate.day),
        startTime: '${(startHour + 0.5).toStringAsFixed(0).padLeft(2, '0')}:30',
        endTime: '${(startHour + 1.5).toStringAsFixed(0).padLeft(2, '0')}:30',
        description: 'Second overlapping event',
      ),
      Event(
        title: 'Overlapping Event 3',
        startDate: DateTime(eventDate.year, eventDate.month, eventDate.day),
        startTime: '${(startHour + 1).toString().padLeft(2, '0')}:00',
        endTime: '${(startHour + 2).toString().padLeft(2, '0')}:00',
        description: 'Third overlapping event',
      ),
    ];
  }

  /// Creates a large set of events for performance testing.
  ///
  /// Parameters:
  /// - [count]: Number of events to create
  /// - [startDate]: Starting date for events (default: today)
  static List<Event> createLargeEventSet({
    int count = 100,
    DateTime? startDate,
  }) {
    final events = <Event>[];
    final start = startDate ?? TimeControlUtils.getCurrentTime();

    for (int i = 0; i < count; i++) {
      final daysOffset = i % 30;
      final hoursOffset = 9 + (i % 8);

      events.add(
        Event(
          title: 'Performance Event $i',
          startDate: start.add(Duration(days: daysOffset)),
          startTime: '${hoursOffset.toString().padLeft(2, '0')}:00',
          endTime: '${(hoursOffset + 1).toString().padLeft(2, '0')}:00',
          description: 'Performance test event $i',
        ),
      );
    }

    return events;
  }

  /// Resets the event counter.
  static void resetCounter() {
    _eventCounter = 0;
  }

  /// Gets the current event counter value.
  static int getCounter() => _eventCounter;
}

/// Helper function to create a timeline of events.
///
/// This function creates events at specific intervals for testing
/// time-based functionality.
///
/// Parameters:
/// - [eventCount]: Number of events to create
/// - [interval]: Interval between events
/// - [startTime]: Starting time for the first event
/// - [titlePrefix]: Prefix for event titles
///
/// Returns a list of events in chronological order
List<Event> createEventTimeline({
  int eventCount = 10,
  Duration interval = const Duration(hours: 2),
  DateTime? startTime,
  String titlePrefix = 'Timeline Event',
}) {
  final events = <Event>[];
  final start = startTime ?? TimeControlUtils.getCurrentTime();

  for (int i = 0; i < eventCount; i++) {
    final eventTime = start.add(interval * i);
    events.add(
      Event(
        title: '$titlePrefix $i',
        startDate: DateTime(eventTime.year, eventTime.month, eventTime.day),
        startTime:
            '${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}',
        endTime:
            '${(eventTime.hour + 1).toString().padLeft(2, '0')}:${eventTime.minute.toString().padLeft(2, '0')}',
        description: 'Timeline event $i at ${eventTime.toIso8601String()}',
      ),
    );
  }

  return events;
}
