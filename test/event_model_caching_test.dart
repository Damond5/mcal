import 'package:flutter_test/flutter_test.dart';
import 'package:mcal/models/event.dart';

void main() {
  group('Event.getAllEventDates Caching', () {
    setUp(() {
      // Clear cache before each test
      Event.clearDateCache();
    });

    tearDown(() {
      // Clean up after each test
      Event.clearDateCache();
    });

    test('cache is initially empty', () {
      expect(Event.cacheSize, equals(0));
    });

    test('caches results after first computation', () {
      final events = [
        Event(title: 'Test Event', startDate: DateTime(2024, 1, 15)),
      ];

      final dates1 = Event.getAllEventDates(events);
      expect(Event.cacheSize, equals(1));
      expect(dates1.length, equals(1));
    });

    test('returns cached results on subsequent calls', () {
      final events = [
        Event(title: 'Test Event', startDate: DateTime(2024, 1, 15)),
      ];

      // First call
      final dates1 = Event.getAllEventDates(events);

      // Second call with same events should use cache
      final dates2 = Event.getAllEventDates(events);

      expect(dates1, equals(dates2));
      expect(Event.cacheSize, equals(1)); // Should still be 1
    });

    test('different event sets create different cache entries', () {
      final events1 = [
        Event(title: 'Event 1', startDate: DateTime(2024, 1, 15)),
      ];

      final events2 = [
        Event(title: 'Event 2', startDate: DateTime(2024, 1, 16)),
      ];

      Event.getAllEventDates(events1);
      Event.getAllEventDates(events2);

      expect(Event.cacheSize, equals(2));
    });

    test('cache can be cleared', () {
      final events = [
        Event(title: 'Test Event', startDate: DateTime(2024, 1, 15)),
      ];

      Event.getAllEventDates(events);
      expect(Event.cacheSize, equals(1));

      Event.clearDateCache();
      expect(Event.cacheSize, equals(0));
    });

    test('explicit cacheKey bypasses auto-generation', () {
      final events = [
        Event(title: 'Test Event', startDate: DateTime(2024, 1, 15)),
      ];

      final cacheKey = DateTime(2024, 6, 1);
      final dates = Event.getAllEventDates(events, cacheKey: cacheKey);

      expect(dates.length, equals(1));
      expect(Event.cacheSize, equals(1));
    });

    test('custom endDate parameter works with caching', () {
      final events = [
        Event(title: 'Test Event', startDate: DateTime(2024, 1, 15)),
      ];

      final dates1 = Event.getAllEventDates(
        events,
        endDate: DateTime(2024, 6, 1),
      );

      final dates2 = Event.getAllEventDates(
        events,
        endDate: DateTime(2024, 6, 1),
      );

      expect(dates1, equals(dates2));
    });
  });

  group('Event.getAllEventDates Performance', () {
    setUp(() {
      Event.clearDateCache();
    });

    tearDown(() {
      Event.clearDateCache();
    });

    test('handles large number of events efficiently', () {
      final events = <Event>[];
      for (int i = 0; i < 100; i++) {
        events.add(
          Event(
            title: 'Event $i',
            startDate: DateTime(2024, 1, 1).add(Duration(days: i % 30)),
            recurrence: i % 3 == 0 ? 'daily' : 'none',
          ),
        );
      }

      final stopwatch = Stopwatch()..start();
      final dates = Event.getAllEventDates(events);
      stopwatch.stop();

      // Should complete within reasonable time (less than 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(dates.length, greaterThan(0));
    });

    test('caching improves performance on repeated calls', () {
      final events = <Event>[];
      for (int i = 0; i < 50; i++) {
        events.add(
          Event(
            title: 'Event $i',
            startDate: DateTime(2024, 1, 1).add(Duration(days: i)),
          ),
        );
      }

      // First call (no cache)
      final stopwatch1 = Stopwatch()..start();
      Event.getAllEventDates(events);
      stopwatch1.stop();
      final firstCallTime = stopwatch1.elapsedMicroseconds;

      // Second call (should use cache)
      final stopwatch2 = Stopwatch()..start();
      Event.getAllEventDates(events);
      stopwatch2.stop();
      final secondCallTime = stopwatch2.elapsedMicroseconds;

      // Cached call should be significantly faster
      expect(secondCallTime, lessThan(firstCallTime));
    });

    test('handles recurring events with long durations', () {
      final dailyEvent = Event(
        title: 'Daily Meeting',
        startDate: DateTime(2020, 1, 1),
        recurrence: 'daily',
      );

      final stopwatch = Stopwatch()..start();
      final dates = Event.getAllEventDates([dailyEvent]);
      stopwatch.stop();

      // Should handle efficiently and include recent dates
      expect(dates.length, greaterThan(365));
      expect(stopwatch.elapsedMilliseconds, lessThan(500)); // Should be fast
    });
  });
}
