import 'package:mcal/models/event.dart';

class TestFixtures {
  static Event createSampleEvent({DateTime? date, String? title}) {
    return Event(
      title: title ?? 'Test Event',
      startDate: date ?? DateTime(2024, 1, 15),
      startTime: '14:00',
      endTime: '15:00',
      description: 'Test event description',
    );
  }

  static Event createRecurringEvent({String recurrence = 'weekly'}) {
    return Event(
      title: 'Weekly Meeting',
      startDate: DateTime(2024, 1, 15),
      startTime: '14:00',
      endTime: '15:00',
      recurrence: recurrence,
      description: 'Recurring meeting',
    );
  }

  static Event createAllDayEvent({DateTime? date}) {
    return Event(
      title: 'All Day Event',
      startDate: date ?? DateTime(2024, 1, 15),
      description: 'All day event description',
    );
  }

  static Event createMultiDayEvent({DateTime? startDate, DateTime? endDate}) {
    final start = startDate ?? DateTime(2024, 1, 15);
    final end = endDate ?? start.add(const Duration(days: 3));
    return Event(
      title: 'Multi-Day Event',
      startDate: start,
      endDate: end,
      description: 'Multi-day event description',
    );
  }

  static List<Event> createLargeEventSet({int count = 100}) {
    final events = <Event>[];
    for (int i = 0; i < count; i++) {
      events.add(
        Event(
          title: 'Event $i',
          startDate: DateTime(2024, 1, 1 + (i % 30)),
          startTime: '${(9 + (i % 8))}:00',
          endTime: '${(10 + (i % 8))}:00',
          description: 'Test event $i',
        ),
      );
    }
    return events;
  }

  static Event createWeeklyMeeting() {
    return Event(
      title: 'Team Meeting',
      startDate: DateTime(2024, 1, 15),
      startTime: '14:00',
      endTime: '15:00',
      recurrence: 'weekly',
      description: 'Weekly sync with team',
    );
  }

  static Event createBirthdayEvent() {
    return Event(
      title: 'Birthday',
      startDate: DateTime(1990, 5, 20),
      recurrence: 'yearly',
      description: 'Birthday celebration',
    );
  }

  static Event createVacationEvent() {
    final start = DateTime(2024, 7, 1);
    return Event(
      title: 'Vacation',
      startDate: start,
      endDate: start.add(const Duration(days: 7)),
      description: 'Annual vacation',
    );
  }

  static Event createDailyStandup() {
    return Event(
      title: 'Daily Standup',
      startDate: DateTime(2024, 1, 15),
      startTime: '09:00',
      endTime: '09:15',
      recurrence: 'daily',
      description: 'Daily team standup meeting',
    );
  }

  static Event createMonthlyReview() {
    return Event(
      title: 'Monthly Review',
      startDate: DateTime(2024, 1, 15),
      startTime: '10:00',
      endTime: '11:00',
      recurrence: 'monthly',
      description: 'Monthly performance review',
    );
  }

  static Event createFutureEvent() {
    return Event(
      title: 'Future Event',
      startDate: DateTime.now().add(const Duration(days: 30)),
      startTime: '14:00',
      endTime: '15:00',
      description: 'Event in the future',
    );
  }

  static Event createPastEvent() {
    return Event(
      title: 'Past Event',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      startTime: '14:00',
      endTime: '15:00',
      description: 'Event in the past',
    );
  }

  static Event createTodayEvent() {
    final now = DateTime.now();
    return Event(
      title: 'Today Event',
      startDate: DateTime(now.year, now.month, now.day),
      startTime: '14:00',
      endTime: '15:00',
      description: 'Event for today',
    );
  }

  static Event createTimedEventWithNotification() {
    final now = DateTime.now();
    return Event(
      title: 'Timed Event',
      startDate: DateTime(now.year, now.month, now.day),
      startTime: '14:00',
      endTime: '15:00',
      description: 'Event with scheduled notification',
    );
  }

  static List<Event> createEventsForSameDay({int count = 5}) {
    final events = <Event>[];
    final date = DateTime(2024, 1, 15);
    for (int i = 0; i < count; i++) {
      events.add(
        Event(
          title: 'Event $i',
          startDate: date,
          startTime: '${(9 + i)}:00',
          endTime: '${(10 + i)}:00',
          description: 'Test event $i on same day',
        ),
      );
    }
    return events;
  }

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
}
