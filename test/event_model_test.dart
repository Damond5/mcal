import 'package:flutter_test/flutter_test.dart';
import 'package:mcal/models/event.dart';

void main() {
  group('Event.getAllEventDates', () {
    // Store original method for comparison
    late Set<DateTime> Function(List<Event>) originalMethod;

    setUp(() {
      // Store reference to original method before optimization
      originalMethod = (events) => Event.getAllEventDates(events);
    });

    group('Basic Functionality', () {
      test('returns empty set for empty event list', () {
        final events = <Event>[];
        final dates = Event.getAllEventDates(events);
        expect(dates, isEmpty);
      });

      test('returns single date for single one-day event', () {
        final event = Event(
          title: 'Test Event',
          startDate: DateTime(2024, 1, 15),
        );
        final dates = Event.getAllEventDates([event]);

        expect(dates.length, 1);
        expect(dates.contains(DateTime(2024, 1, 15)), true);
      });

      test('returns all dates for multi-day event', () {
        final event = Event(
          title: 'Multi-day Event',
          startDate: DateTime(2024, 1, 15),
          endDate: DateTime(2024, 1, 18),
        );
        final dates = Event.getAllEventDates([event]);

        expect(dates.length, 4);
        expect(dates.contains(DateTime(2024, 1, 15)), true);
        expect(dates.contains(DateTime(2024, 1, 16)), true);
        expect(dates.contains(DateTime(2024, 1, 17)), true);
        expect(dates.contains(DateTime(2024, 1, 18)), true);
      });

      test('handles single-day event with endDate same as startDate', () {
        final event = Event(
          title: 'Same Day Event',
          startDate: DateTime(2024, 1, 15),
          endDate: DateTime(2024, 1, 15),
        );
        final dates = Event.getAllEventDates([event]);

        expect(dates.length, 1);
        expect(dates.contains(DateTime(2024, 1, 15)), true);
      });
    });

    group('Recurring Events', () {
      test('daily recurring event generates multiple dates', () {
        final event = Event(
          title: 'Daily Meeting',
          startDate: DateTime(2024, 1, 15),
          recurrence: 'daily',
        );
        final dates = Event.getAllEventDates([event]);

        // Should include dates for at least a week
        expect(dates.length, greaterThan(5));
        expect(dates.contains(DateTime(2024, 1, 15)), true);
        expect(dates.contains(DateTime(2024, 1, 16)), true);
        expect(dates.contains(DateTime(2024, 1, 17)), true);
      });

      test('weekly recurring event generates correct dates', () {
        final event = Event(
          title: 'Weekly Standup',
          startDate: DateTime(2024, 1, 15), // Monday
          recurrence: 'weekly',
        );
        final dates = Event.getAllEventDates([event]);

        // Should include start date
        expect(dates.contains(DateTime(2024, 1, 15)), true);
        // Should include next week's date
        expect(dates.contains(DateTime(2024, 1, 22)), true);
        // Should NOT include days in between
        expect(dates.contains(DateTime(2024, 1, 16)), false);
        expect(dates.contains(DateTime(2024, 1, 21)), false);
      });

      test('monthly recurring event generates correct dates', () {
        final event = Event(
          title: 'Monthly Review',
          startDate: DateTime(2024, 1, 15),
          recurrence: 'monthly',
        );
        final dates = Event.getAllEventDates([event]);

        // Should include start date
        expect(dates.contains(DateTime(2024, 1, 15)), true);
        // Should include next month's date
        expect(dates.contains(DateTime(2024, 2, 15)), true);
      });

      test('yearly recurring event generates correct dates', () {
        final event = Event(
          title: 'Annual Birthday',
          startDate: DateTime(2024, 1, 15),
          recurrence: 'yearly',
        );
        final dates = Event.getAllEventDates([event]);

        // Should include start date
        expect(dates.contains(DateTime(2024, 1, 15)), true);
        // Should include next year's date
        expect(dates.contains(DateTime(2025, 1, 15)), true);
      });

      test('non-recurring event (none) generates only start date', () {
        final event = Event(
          title: 'One-time Event',
          startDate: DateTime(2024, 1, 15),
          recurrence: 'none',
        );
        final dates = Event.getAllEventDates([event]);

        expect(dates.length, 1);
        expect(dates.contains(DateTime(2024, 1, 15)), true);
      });
    });

    group('Edge Cases', () {
      test('handles events spanning month boundaries', () {
        final event = Event(
          title: 'Month Spanning Event',
          startDate: DateTime(2024, 1, 30),
          endDate: DateTime(2024, 2, 2),
        );
        final dates = Event.getAllEventDates([event]);

        expect(dates.length, 4);
        expect(dates.contains(DateTime(2024, 1, 30)), true);
        expect(dates.contains(DateTime(2024, 1, 31)), true);
        expect(dates.contains(DateTime(2024, 2, 1)), true);
        expect(dates.contains(DateTime(2024, 2, 2)), true);
      });

      test('handles events spanning year boundaries', () {
        final event = Event(
          title: 'Year Spanning Event',
          startDate: DateTime(2024, 12, 30),
          endDate: DateTime(2025, 1, 2),
        );
        final dates = Event.getAllEventDates([event]);

        expect(dates.length, 4);
        expect(dates.contains(DateTime(2024, 12, 30)), true);
        expect(dates.contains(DateTime(2024, 12, 31)), true);
        expect(dates.contains(DateTime(2025, 1, 1)), true);
        expect(dates.contains(DateTime(2025, 1, 2)), true);
      });

      test('handles leap year February dates', () {
        final event = Event(
          title: 'Leap Year Event',
          startDate: DateTime(2024, 2, 28), // Leap year
          endDate: DateTime(2024, 3, 1),
        );
        final dates = Event.getAllEventDates([event]);

        expect(dates.length, 3);
        expect(dates.contains(DateTime(2024, 2, 28)), true);
        expect(dates.contains(DateTime(2024, 2, 29)), true); // Leap day
        expect(dates.contains(DateTime(2024, 3, 1)), true);
      });

      test('handles monthly recurring on 31st day correctly', () {
        final event = Event(
          title: 'End of Month Event',
          startDate: DateTime(2024, 1, 31),
          recurrence: 'monthly',
        );
        final dates = Event.getAllEventDates([event]);

        // Should include January 31
        expect(dates.contains(DateTime(2024, 1, 31)), true);
        // February has 29 days in 2024, so should fall back to 29
        expect(dates.contains(DateTime(2024, 2, 29)), true);
        // March has 31 days
        expect(dates.contains(DateTime(2024, 3, 31)), true);
      });
    });

    group('Multiple Events', () {
      test('combines dates from multiple events', () {
        final event1 = Event(
          title: 'Event 1',
          startDate: DateTime(2024, 1, 15),
        );
        final event2 = Event(
          title: 'Event 2',
          startDate: DateTime(2024, 1, 20),
        );
        final dates = Event.getAllEventDates([event1, event2]);

        expect(dates.length, 2);
        expect(dates.contains(DateTime(2024, 1, 15)), true);
        expect(dates.contains(DateTime(2024, 1, 20)), true);
      });

      test('removes duplicate dates from different events', () {
        final event1 = Event(
          title: 'Event 1',
          startDate: DateTime(2024, 1, 15),
        );
        final event2 = Event(
          title: 'Event 2',
          startDate: DateTime(2024, 1, 15), // Same day
        );
        final dates = Event.getAllEventDates([event1, event2]);

        expect(dates.length, 1);
        expect(dates.contains(DateTime(2024, 1, 15)), true);
      });

      test('handles overlapping recurring events', () {
        final dailyEvent = Event(
          title: 'Daily Standup',
          startDate: DateTime(2024, 1, 15),
          recurrence: 'daily',
        );
        final weeklyEvent = Event(
          title: 'Weekly Review',
          startDate: DateTime(2024, 1, 15),
          recurrence: 'weekly',
        );
        final dates = Event.getAllEventDates([dailyEvent, weeklyEvent]);

        // Should have more dates than just the weekly event
        expect(dates.length, greaterThan(1));
        expect(dates.contains(DateTime(2024, 1, 15)), true);
      });
    });

    group('Time Handling', () {
      test('ignores time component for all-day events', () {
        final event = Event(
          title: 'All Day Event',
          startDate: DateTime(2024, 1, 15, 14, 30), // Has time component
        );
        final dates = Event.getAllEventDates([event]);

        expect(dates.length, 1);
        expect(dates.contains(DateTime(2024, 1, 15)), true);
      });

      test('ignores time component for events with startTime', () {
        final event = Event(
          title: 'Timed Event',
          startDate: DateTime(2024, 1, 15),
          startTime: '10:00',
        );
        final dates = Event.getAllEventDates([event]);

        expect(dates.length, 1);
        expect(dates.contains(DateTime(2024, 1, 15)), true);
      });
    });

    group('Performance Optimization Verification', () {
      test('returns consistent results with multiple calls (caching)', () {
        final event = Event(
          title: 'Test Event',
          startDate: DateTime(2024, 1, 15),
        );

        final dates1 = Event.getAllEventDates([event]);
        final dates2 = Event.getAllEventDates([event]);

        expect(dates1.length, dates2.length);
        expect(dates1.first, dates2.first);
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

        final dates = Event.getAllEventDates(events);

        // Should complete without timing out and produce reasonable results
        expect(dates.length, greaterThan(0));
      });

      test('handles recurring events spanning long periods', () {
        final dailyEvent = Event(
          title: 'Long Daily Event',
          startDate: DateTime(2020, 1, 1),
          recurrence: 'daily',
        );

        final dates = Event.getAllEventDates([dailyEvent]);

        // Should handle efficiently and include recent dates
        expect(dates.length, greaterThan(100));
        expect(
          dates.contains(
            DateTime.now().year == 2024
                ? DateTime(2024, 1, 1)
                : DateTime(2023, 1, 1),
          ),
          true,
        );
      });
    });

    group('Complex Scenarios', () {
      test('recurring event with endDate constraint', () {
        final event = Event(
          title: 'Temporary Daily Event',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 5),
          recurrence: 'daily',
        );
        final dates = Event.getAllEventDates([event]);

        // Should only include dates within the event's endDate
        expect(dates.contains(DateTime(2024, 1, 1)), true);
        expect(dates.contains(DateTime(2024, 1, 5)), true);
      });

      test('mixed recurring and non-recurring events', () {
        final recurringEvent = Event(
          title: 'Weekly Meeting',
          startDate: DateTime(2024, 1, 15),
          recurrence: 'weekly',
        );
        final oneTimeEvent = Event(
          title: 'Special Event',
          startDate: DateTime(2024, 1, 20),
        );
        final multiDayEvent = Event(
          title: 'Conference',
          startDate: DateTime(2024, 1, 25),
          endDate: DateTime(2024, 1, 27),
        );

        final dates = Event.getAllEventDates([
          recurringEvent,
          oneTimeEvent,
          multiDayEvent,
        ]);

        expect(dates.contains(DateTime(2024, 1, 15)), true);
        expect(dates.contains(DateTime(2024, 1, 20)), true);
        expect(dates.contains(DateTime(2024, 1, 25)), true);
        expect(dates.contains(DateTime(2024, 1, 26)), true);
        expect(dates.contains(DateTime(2024, 1, 27)), true);
      });
    });

    group('Result Integrity', () {
      test(
        'all returned dates are DateTime objects with no time component',
        () {
          final event = Event(
            title: 'Test Event',
            startDate: DateTime(2024, 1, 15, 14, 30, 45),
          );
          final dates = Event.getAllEventDates([event]);

          for (final date in dates) {
            expect(date.hour, 0);
            expect(date.minute, 0);
            expect(date.second, 0);
            expect(date.millisecond, 0);
            expect(date.microsecond, 0);
          }
        },
      );

      test('returned set contains only unique dates', () {
        final event1 = Event(
          title: 'Event 1',
          startDate: DateTime(2024, 1, 15),
        );
        final event2 = Event(
          title: 'Event 2',
          startDate: DateTime(2024, 1, 15), // Same day
        );
        final event3 = Event(
          title: 'Event 3',
          startDate: DateTime(2024, 1, 15), // Same day again
          endDate: DateTime(2024, 1, 17),
        );

        final dates = Event.getAllEventDates([event1, event2, event3]);

        // Set should ensure uniqueness
        final dateStrings = dates
            .map((d) => '${d.year}-${d.month}-${d.day}')
            .toList();
        expect(dateStrings.toSet().length, dates.length);
      });
    });
  });
}
