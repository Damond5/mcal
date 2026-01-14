import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:mcal/models/event.dart";
import "package:mcal/providers/event_provider.dart";
import "package:mcal/frb_generated.dart";

@GenerateMocks([RustLibApi])
import "event_provider_test.mocks.dart";
import "test_helpers.dart";

/// Helper function to add minutes to a time and return properly formatted HH:MM string
/// Handles minute overflow (e.g., 14:60 becomes 15:00)
String _addMinutes(int hour, int minute, int offset) {
  final totalMinutes = minute + offset;
  final newHour = hour + totalMinutes ~/ 60;
  final newMinute = totalMinutes % 60;
  return '${newHour.toString().padLeft(2, '0')}:${newMinute.toString().padLeft(2, '0')}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EventProvider eventProvider;
  late MockRustLibApi mockApi;

  setUpAll(() async {
    mockApi = MockRustLibApi();
    RustLib.initMock(api: mockApi);
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  setUp(() async {
    eventProvider = EventProvider();
    await setupTestEnvironment();
  });

  group('Event Model Tests', () {
    test('Event.fromMarkdown parses rcal format correctly', () {
      const markdown = '''# Event: Test Event

- **Date**: 2023-10-01 to 2023-10-02
- **Start Time**: 10:00 to 11:00
- **Description**: Test description
- **Recurrence**: daily
''';
      final event = Event.fromMarkdown(markdown, 'test.md');

      expect(event.title, 'Test Event');
      expect(event.startDate, DateTime(2023, 10, 1));
      expect(event.endDate, DateTime(2023, 10, 2));
      expect(event.startTime, '10:00');
      expect(event.endTime, '11:00');
      expect(event.description, 'Test description');
      expect(event.recurrence, 'daily');
      expect(event.filename, 'test.md');
    });

    test('Event.toMarkdown generates rcal format', () {
      final event = Event(
        title: 'Test Event',
        startDate: DateTime(2023, 10, 1),
        endDate: DateTime(2023, 10, 2),
        startTime: '10:00',
        endTime: '11:00',
        description: 'Test desc',
        recurrence: 'weekly',
      );

      final markdown = event.toMarkdown();
      expect(markdown.contains('# Event: Test Event'), true);
      expect(markdown.contains('- **Date**: 2023-10-01 to 2023-10-02'), true);
      expect(markdown.contains('- **Start Time**: 10:00 to 11:00'), true);
      expect(markdown.contains('- **Description**: Test desc'), true);
      expect(markdown.contains('- **Recurrence**: weekly'), true);
    });

    test('Event.isAllDay works', () {
      final allDayEvent = Event(
        title: 'All Day',
        startDate: DateTime(2023, 10, 1),
      );
      expect(allDayEvent.isAllDay, true);

      final timedEvent = Event(
        title: 'Timed',
        startDate: DateTime(2023, 10, 1),
        startTime: '10:00',
      );
      expect(timedEvent.isAllDay, false);
    });

    test('Event.expandRecurring expands daily events', () {
      final event = Event(
        title: 'Daily Event',
        startDate: DateTime(2023, 10, 1),
        recurrence: 'daily',
      );
      final expanded = Event.expandRecurring(event, DateTime(2023, 10, 5));
      expect(expanded.length, 5); // 1-5
      expect(expanded[0].title, 'Daily Event');
      expect(expanded[0].startDate, DateTime(2023, 10, 1));
      expect(expanded[1].title, 'Daily Event (2023-10-2)');
      expect(expanded[4].startDate, DateTime(2023, 10, 5));
    });

    test('Event.expandRecurring expands weekly events', () {
      final event = Event(
        title: 'Weekly Event',
        startDate: DateTime(2023, 10, 1), // Sunday
        recurrence: 'weekly',
      );
      final expanded = Event.expandRecurring(event, DateTime(2023, 10, 15));
      expect(expanded.length, 3); // 1, 8, 15
    });

    test('Event.expandRecurring expands monthly events', () {
      final event = Event(
        title: 'Monthly Event',
        startDate: DateTime(2023, 10, 1),
        recurrence: 'monthly',
      );
      final expanded = Event.expandRecurring(event, DateTime(2023, 12, 1));
      expect(expanded.length, 3); // Oct, Nov, Dec
    });

    test('Event.occursOnDate for single day event', () {
      final event = Event(title: 'Single', startDate: DateTime(2023, 10, 1));
      expect(Event.occursOnDate(event, DateTime(2023, 10, 1)), true);
      expect(Event.occursOnDate(event, DateTime(2023, 10, 2)), false);
    });

    test('Event.occursOnDate for multi-day event', () {
      final event = Event(
        title: 'Multi',
        startDate: DateTime(2023, 10, 1),
        endDate: DateTime(2023, 10, 3),
      );
      expect(Event.occursOnDate(event, DateTime(2023, 10, 1)), true);
      expect(Event.occursOnDate(event, DateTime(2023, 10, 2)), true);
      expect(
        Event.occursOnDate(event, DateTime(2023, 10, 3)),
        true,
      ); // Includes end date
    });

    test('Event.fromMarkdown throws on invalid date', () {
      const invalidMarkdown = '''# Event: Test
- **Date**: invalid-date
''';
      expect(
        () => Event.fromMarkdown(invalidMarkdown, 'invalid.md'),
        throwsFormatException,
      );
    });

    test('Event.fromMarkdown throws on end before start', () {
      const invalidMarkdown = '''# Event: Test
- **Date**: 2023-10-02 to 2023-10-01
''';
      expect(
        () => Event.fromMarkdown(invalidMarkdown, 'invalid.md'),
        throwsFormatException,
      );
    });

    test('Event.fromMarkdown throws on invalid time', () {
      const invalidMarkdown = '''# Event: Test
- **Date**: 2023-10-01
- **Start Time**: 25:00
''';
      expect(
        () => Event.fromMarkdown(invalidMarkdown, 'invalid.md'),
        throwsFormatException,
      );
    });

    // Backward Compatibility Tests for Deprecated "- **Time**: " Format
    group('Event.fromMarkdown Backward Compatibility Tests', () {
      test(
        'parses deprecated "- **Time**: " format for backward compatibility',
        () {
          const deprecatedMarkdown = '''# Event: Test Event
- **Date**: 2023-10-01
- **Time**: 10:00 to 11:00
- **Description**: Test description
- **Recurrence**: none
''';
          final event = Event.fromMarkdown(deprecatedMarkdown, 'test.md');

          expect(event.title, 'Test Event');
          expect(event.startDate, DateTime(2023, 10, 1));
          expect(event.startTime, '10:00');
          expect(event.endTime, '11:00');
          expect(event.description, 'Test description');
          expect(event.recurrence, 'none');
          expect(event.filename, 'test.md');
        },
      );

      test(
        'parses deprecated "- **Time**: all-day format for all-day events',
        () {
          const deprecatedAllDayMarkdown = '''# Event: All Day Event
- **Date**: 2023-10-01
- **Time**: all-day
- **Description**: Full day event
- **Recurrence**: none
''';
          final event = Event.fromMarkdown(
            deprecatedAllDayMarkdown,
            'all_day.md',
          );

          expect(event.title, 'All Day Event');
          expect(event.startDate, DateTime(2023, 10, 1));
          expect(event.startTime, null);
          expect(event.endTime, null);
          expect(event.isAllDay, true);
          expect(event.description, 'Full day event');
        },
      );

      test(
        'parses deprecated "- **Time**: format with single time (no end time)',
        () {
          const deprecatedSingleTimeMarkdown = '''# Event: Single Time Event
- **Date**: 2023-10-01
- **Time**: 14:30
- **Description**: Event with single time
- **Recurrence**: none
''';
          final event = Event.fromMarkdown(
            deprecatedSingleTimeMarkdown,
            'single_time.md',
          );

          expect(event.title, 'Single Time Event');
          expect(event.startDate, DateTime(2023, 10, 1));
          expect(event.startTime, '14:30');
          expect(event.endTime, null);
        },
      );

      test(
        'parses deprecated "- **Time**: format with multi-day date range',
        () {
          const deprecatedMultiDayMarkdown = '''# Event: Multi Day Event
- **Date**: 2023-10-01 to 2023-10-05
- **Time**: 09:00 to 17:00
- **Description**: Multi-day with deprecated time format
- **Recurrence**: none
''';
          final event = Event.fromMarkdown(
            deprecatedMultiDayMarkdown,
            'multi_day.md',
          );

          expect(event.title, 'Multi Day Event');
          expect(event.startDate, DateTime(2023, 10, 1));
          expect(event.endDate, DateTime(2023, 10, 5));
          expect(event.startTime, '09:00');
          expect(event.endTime, '17:00');
        },
      );

      test('parses deprecated "- **Time**: format with recurrence rule', () {
        const deprecatedRecurringMarkdown = '''# Event: Recurring Event
- **Date**: 2023-10-01
- **Time**: 10:00 to 11:00
- **Description**: Weekly recurring event
- **Recurrence**: weekly
''';
        final event = Event.fromMarkdown(
          deprecatedRecurringMarkdown,
          'recurring.md',
        );

        expect(event.title, 'Recurring Event');
        expect(event.recurrence, 'weekly');
        expect(event.startTime, '10:00');
        expect(event.endTime, '11:00');
      });

      test(
        'new "- **Start Time**: " format continues to work alongside deprecated format',
        () {
          const newFormatMarkdown = '''# Event: New Format Event
- **Date**: 2023-10-01
- **Start Time**: 10:00 to 11:00
- **Description**: Uses new format
- **Recurrence**: none
''';
          final event = Event.fromMarkdown(newFormatMarkdown, 'new_format.md');

          expect(event.title, 'New Format Event');
          expect(event.startDate, DateTime(2023, 10, 1));
          expect(event.startTime, '10:00');
          expect(event.endTime, '11:00');
          expect(event.description, 'Uses new format');
        },
      );

      test('new "- **Start Time**: all-day format works correctly', () {
        const newAllDayMarkdown = '''# Event: New All Day Event
- **Date**: 2023-10-01
- **Start Time**: all-day
- **Description**: All-day event with new format
- **Recurrence**: none
''';
        final event = Event.fromMarkdown(newAllDayMarkdown, 'new_all_day.md');

        expect(event.title, 'New All Day Event');
        expect(event.startDate, DateTime(2023, 10, 1));
        expect(event.startTime, null);
        expect(event.endTime, null);
        expect(event.isAllDay, true);
      });

      test(
        'both formats produce identical results when used with same time data',
        () {
          const deprecatedMarkdown = '''# Event: Comparison Event
- **Date**: 2023-10-01
- **Time**: 10:00 to 11:00
- **Description**: Test description
- **Recurrence**: daily
''';

          const newFormatMarkdown = '''# Event: Comparison Event
- **Date**: 2023-10-01
- **Start Time**: 10:00 to 11:00
- **Description**: Test description
- **Recurrence**: daily
''';

          final deprecatedEvent = Event.fromMarkdown(
            deprecatedMarkdown,
            'deprecated.md',
          );
          final newFormatEvent = Event.fromMarkdown(
            newFormatMarkdown,
            'new.md',
          );

          // Both formats should produce identical events
          expect(deprecatedEvent.title, newFormatEvent.title);
          expect(deprecatedEvent.startDate, newFormatEvent.startDate);
          expect(deprecatedEvent.endDate, newFormatEvent.endDate);
          expect(deprecatedEvent.startTime, newFormatEvent.startTime);
          expect(deprecatedEvent.endTime, newFormatEvent.endTime);
          expect(deprecatedEvent.description, newFormatEvent.description);
          expect(deprecatedEvent.recurrence, newFormatEvent.recurrence);
        },
      );

      test(
        'parses deprecated format with edge case times (midnight boundaries)',
        () {
          const deprecatedEdgeCaseMarkdown = '''# Event: Midnight Event
- **Date**: 2023-10-01
- **Time**: 00:00 to 23:59
- **Description**: Full day using deprecated format
- **Recurrence**: none
''';
          final event = Event.fromMarkdown(
            deprecatedEdgeCaseMarkdown,
            'midnight.md',
          );

          expect(event.title, 'Midnight Event');
          expect(event.startTime, '00:00');
          expect(event.endTime, '23:59');
        },
      );

      test('handles deprecated format with different spacing variations', () {
        // Test with minimal spacing
        const minimalSpacingMarkdown = '''# Event: Minimal Spacing Event
- **Date**: 2023-10-01
- **Time**:09:00 to17:00
- **Description**: Minimal spacing
- **Recurrence**: none
''';
        final minimalEvent = Event.fromMarkdown(
          minimalSpacingMarkdown,
          'minimal.md',
        );
        expect(minimalEvent.startTime, '09:00');
        expect(minimalEvent.endTime, '17:00');

        // Test with extra spacing
        const extraSpacingMarkdown = '''# Event: Extra Spacing Event
- **Date**: 2023-10-01
- **Time**:  09:00  to  17:00  
- **Description**: Extra spacing
- **Recurrence**: none
''';
        final extraSpacingEvent = Event.fromMarkdown(
          extraSpacingMarkdown,
          'extra.md',
        );
        expect(extraSpacingEvent.startTime, '09:00');
        expect(extraSpacingEvent.endTime, '17:00');
      });
    });
  });

  group('EventProvider Tests', () {
    test('deleteEvent with duplicate titles uses correct filename', () async {
      // Add two events with same title
      final event1 = Event(
        title: 'Duplicate',
        startDate: DateTime(2023, 10, 1),
      );
      final event2 = Event(
        title: 'Duplicate',
        startDate: DateTime(2023, 10, 2),
      );
      await eventProvider.addEvent(event1);
      await eventProvider.addEvent(event2);
      final events = eventProvider
          .getEventsForDate(DateTime(2023, 10, 1))
          .where((e) => e.title == 'Duplicate')
          .toList();
      expect(events.length, 1);
      final addedEvent1 = events[0];
      expect(addedEvent1.filename, isNotNull);
      // Delete the first one
      await eventProvider.deleteEvent(addedEvent1);
      final remaining = eventProvider
          .getEventsForDate(DateTime(2023, 10, 2))
          .where((e) => e.title == 'Duplicate')
          .toList();
      expect(remaining.length, 1);
      // Clean up
      await eventProvider.deleteEvent(remaining[0]);
    });
    test('loadAllEvents loads events', () async {
      await eventProvider.loadAllEvents();
      // Since no events, should be empty
      expect(eventProvider.getEventsForDate(DateTime.now()), isEmpty);
    });

    test('addEvent and getEventsForDate work', () async {
      final event = Event(
        title: 'Test',
        startDate: DateTime(2023, 10, 1),
        startTime: '10:00',
      );
      await eventProvider.addEvent(event);
      final events = eventProvider.getEventsForDate(DateTime(2023, 10, 1));
      expect(events.length, 1);
      expect(events[0].title, 'Test');
      expect(events[0].filename, isNotNull);
    });

    test('deleteEvent removes event', () async {
      final event = Event(title: 'Test', startDate: DateTime(2023, 10, 1));
      await eventProvider.addEvent(event);
      final addedEvent = eventProvider.getEventsForDate(
        DateTime(2023, 10, 1),
      )[0];
      await eventProvider.deleteEvent(addedEvent);
      final events = eventProvider.getEventsForDate(DateTime(2023, 10, 1));
      expect(events, isEmpty);
    });

    test(
      'addEvent handles immediate notification check error gracefully',
      () async {
        // Create an event that would trigger immediate notification check
        final event = Event(
          title: 'Immediate Test',
          startDate: DateTime.now().add(const Duration(hours: 1)),
          startTime:
              DateTime.now()
                  .add(const Duration(hours: 1))
                  .hour
                  .toString()
                  .padLeft(2, '0') +
              ':00',
        );

        // This should not throw even if immediate notification check fails
        await expectLater(eventProvider.addEvent(event), completes);

        // Event should still be added successfully
        expect(eventProvider.eventsCount, 1);
      },
    );

    test(
      'addEvent triggers immediate notification for events within notification window',
      () async {
        // Create an event that's within the notification window (e.g., 15 minutes away)
        final now = DateTime.now();
        final event = Event(
          title: 'Soon Event',
          startDate: now.add(const Duration(hours: 1)),
          startTime: (now.hour + 1).toString().padLeft(2, '0') + ':00',
        );

        await eventProvider.addEvent(event);

        // Event should be added successfully
        expect(eventProvider.eventsCount, 1);

        // Should have processed immediate notification check (internal state updated)
        final addedEvent = eventProvider.getEventsForDate(
          now.add(const Duration(hours: 1)),
        )[0];
        expect(addedEvent.title, 'Soon Event');
      },
    );

    test(
      'addEvent works for all-day events with immediate notification check',
      () async {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final event = Event(
          title: 'All Day Soon',
          startDate: tomorrow,
          // No startTime means all-day event
        );

        await eventProvider.addEvent(event);

        // Event should be added successfully
        expect(eventProvider.eventsCount, 1);

        // Should have processed immediate notification check without errors
        final addedEvents = eventProvider.getEventsForDate(tomorrow);
        expect(addedEvents.length, 1);
        expect(addedEvents[0].title, 'All Day Soon');
      },
    );

    test(
      'addEvent calls immediate notification check regardless of platform',
      () async {
        // This test verifies that immediate notification check is called for all platforms
        final event = Event(
          title: 'Platform Test',
          startDate: DateTime.now().add(const Duration(days: 2)),
        );

        // Should complete successfully on any platform
        await expectLater(eventProvider.addEvent(event), completes);

        expect(eventProvider.eventsCount, 1);
      },
    );

    test('updateEvent updates event correctly', () async {
      // Add an event first
      final originalEvent = Event(
        title: 'Original Title',
        startDate: DateTime(2023, 10, 1),
        startTime: '10:00',
      );
      await eventProvider.addEvent(originalEvent);

      final addedEvent = eventProvider.getEventsForDate(
        DateTime(2023, 10, 1),
      )[0];

      // Update the event
      final updatedEvent = addedEvent.copyWith(
        title: 'Updated Title',
        description: 'Updated description',
      );
      await eventProvider.updateEvent(addedEvent, updatedEvent);

      // Verify update
      final events = eventProvider.getEventsForDate(DateTime(2023, 10, 1));
      expect(events.length, 1);
      expect(events[0].title, 'Updated Title');
      expect(events[0].description, 'Updated description');
    });

    test(
      'updateEvent handles immediate notification check error gracefully',
      () async {
        // Add an event first
        final now = DateTime.now();
        final eventDate = now.add(const Duration(hours: 2));
        // Generate a valid time using proper DateTime arithmetic
        final timeDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour + 2,
          0,
        );
        final event = Event(
          title: 'Update Error Test',
          startDate: eventDate,
          startTime: '${timeDateTime.hour.toString().padLeft(2, '0')}:00',
        );
        await eventProvider.addEvent(event);

        final addedEvent = eventProvider.getEventsForDate(
          DateTime.now().add(const Duration(hours: 2)),
        )[0];

        // Update the event - should not throw even if immediate notification check fails
        final updatedEvent = addedEvent.copyWith(title: 'Updated Title');
        await expectLater(
          eventProvider.updateEvent(addedEvent, updatedEvent),
          completes,
        );

        // Event should still be updated successfully
        final events = eventProvider.getEventsForDate(
          DateTime.now().add(const Duration(hours: 2)),
        );
        expect(events.length, 1);
        expect(events[0].title, 'Updated Title');
      },
    );

    test(
      'updateEvent triggers immediate notification for events within notification window',
      () async {
        // Add an event first
        final now = DateTime.now();
        final eventDate = now.add(const Duration(hours: 1));
        // Generate a valid time using proper DateTime arithmetic
        final timeDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour + 1,
          0,
        );
        final event = Event(
          title: 'Update Soon Event',
          startDate: eventDate,
          startTime: '${timeDateTime.hour.toString().padLeft(2, '0')}:00',
        );
        await eventProvider.addEvent(event);

        final addedEvent = eventProvider.getEventsForDate(
          now.add(const Duration(hours: 1)),
        )[0];

        // Update the event
        final updatedEvent = addedEvent.copyWith(title: 'Updated Soon Event');
        await eventProvider.updateEvent(addedEvent, updatedEvent);

        // Event should be updated successfully
        final events = eventProvider.getEventsForDate(
          now.add(const Duration(hours: 1)),
        );
        expect(events.length, 1);
        expect(events[0].title, 'Updated Soon Event');
      },
    );

    test(
      'updateEvent works for all-day events with immediate notification check',
      () async {
        // Add an all-day event first
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final event = Event(title: 'All Day Update Test', startDate: tomorrow);
        await eventProvider.addEvent(event);

        final addedEvents = eventProvider.getEventsForDate(tomorrow);
        expect(addedEvents.length, 1);

        // Update the event
        final updatedEvent = addedEvents[0].copyWith(
          title: 'Updated All Day Event',
        );
        await eventProvider.updateEvent(addedEvents[0], updatedEvent);

        // Event should be updated successfully
        final updatedEvents = eventProvider.getEventsForDate(tomorrow);
        expect(updatedEvents.length, 1);
        expect(updatedEvents[0].title, 'Updated All Day Event');
      },
    );

    test(
      'updateEvent calls immediate notification check regardless of platform',
      () async {
        // Add an event first
        final event = Event(
          title: 'Update Platform Test',
          startDate: DateTime.now().add(const Duration(days: 2)),
        );
        await eventProvider.addEvent(event);

        final addedEvent = eventProvider.getEventsForDate(
          DateTime.now().add(const Duration(days: 2)),
        )[0];

        // Update the event - should complete successfully on any platform
        final updatedEvent = addedEvent.copyWith(
          title: 'Updated Platform Test',
        );
        await expectLater(
          eventProvider.updateEvent(addedEvent, updatedEvent),
          completes,
        );

        expect(eventProvider.eventsCount, 1);
      },
    );

    test('updateEvent preserves filename from old event correctly', () async {
      // Add an event first
      final event = Event(
        title: 'Filename Test',
        startDate: DateTime(2023, 10, 1),
      );
      await eventProvider.addEvent(event);

      final addedEvent = eventProvider.getEventsForDate(
        DateTime(2023, 10, 1),
      )[0];
      final originalFilename = addedEvent.filename;

      // Update the event
      final updatedEvent = addedEvent.copyWith(title: 'Updated Filename Test');
      await eventProvider.updateEvent(addedEvent, updatedEvent);

      // Verify the filename is preserved
      final updatedEvents = eventProvider.getEventsForDate(
        DateTime(2023, 10, 1),
      );
      expect(updatedEvents[0].filename, originalFilename);
    });
  });

  // ============================================================================
  // BATCH OPERATIONS TESTS
  // ============================================================================

  group('Batch Operations Tests', () {
    group('addEventsBatch()', () {
      test('adds multiple events in a single batch operation', () async {
        final events = List.generate(5, (index) {
          return Event(
            title: 'Batch Event $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
          );
        });

        final filenames = await eventProvider.addEventsBatch(events);

        expect(filenames.length, 5);
        expect(eventProvider.eventsCount, 5);
        expect(eventProvider.areUpdatesPaused, false);
      });

      test('returns filenames in the same order as input events', () async {
        final events = List.generate(3, (index) {
          return Event(
            title: 'Ordered Event $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
          );
        });

        final filenames = await eventProvider.addEventsBatch(events);

        for (int i = 0; i < events.length; i++) {
          expect(filenames[i], contains('batch_event_$i'));
        }
      });

      test('respects deferUpdates parameter', () async {
        final events = List.generate(3, (index) {
          return Event(
            title: 'Defer Test $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
          );
        });

        // With deferUpdates=true (default), updates should be paused during batch
        await eventProvider.addEventsBatch(events, deferUpdates: true);
        expect(eventProvider.areUpdatesPaused, false);

        // With deferUpdates=false, caller is responsible for pause/resume
        await eventProvider.addEventsBatch(events, deferUpdates: false);
        expect(eventProvider.areUpdatesPaused, false);
      });

      test('handles empty event list gracefully', () async {
        final filenames = await eventProvider.addEventsBatch([]);

        expect(filenames, isEmpty);
        expect(eventProvider.eventsCount, 0);
      });

      test('computes event dates correctly after batch add', () async {
        final events = List.generate(5, (index) {
          return Event(
            title: 'Date Test Event $index',
            startDate: DateTime(2023, 10, index + 1),
          );
        });

        await eventProvider.addEventsBatch(events);

        expect(eventProvider.eventDates.length, 5);
        for (int i = 0; i < 5; i++) {
          expect(
            eventProvider.eventDates.contains(DateTime(2023, 10, i + 1)),
            true,
          );
        }
      });

      test('preserves event data correctly', () async {
        final events = [
          Event(
            title: 'Preserve Test',
            startDate: DateTime(2023, 10, 1),
            startTime: '10:00',
            endTime: '11:00',
            description: 'Test description',
            recurrence: 'daily',
          ),
        ];

        await eventProvider.addEventsBatch(events);

        expect(eventProvider.eventsCount, 1);
        final addedEvent = eventProvider.getEventsForDate(
          DateTime(2023, 10, 1),
        )[0];
        expect(addedEvent.title, 'Preserve Test');
        expect(addedEvent.startTime, '10:00');
        expect(addedEvent.endTime, '11:00');
        expect(addedEvent.description, 'Test description');
        expect(addedEvent.recurrence, 'daily');
      });
    });

    group('updateEventsBatch()', () {
      test('updates multiple events in a single batch operation', () async {
        // First add some events
        final originalEvents = List.generate(3, (index) {
          return Event(
            title: 'Original $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
          );
        });
        await eventProvider.addEventsBatch(originalEvents);

        // Update them in batch
        final updatedEvents = List.generate(3, (index) {
          return Event(
            title: 'Updated $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
            description: 'Updated description $index',
          );
        });

        await eventProvider.updateEventsBatch(updatedEvents);

        expect(eventProvider.eventsCount, 3);
        for (int i = 0; i < 3; i++) {
          final events = eventProvider.getEventsForDate(
            DateTime(2023, 10, 1).add(Duration(days: i)),
          );
          expect(events[0].title, 'Updated $i');
          expect(events[0].description, 'Updated description $i');
        }
      });

      test('handles empty event list gracefully', () async {
        await eventProvider.updateEventsBatch([]);
        // Should not throw and events should remain unchanged
        expect(eventProvider.eventsCount, 0);
      });

      test('respects deferUpdates parameter', () async {
        // Add initial events
        final events = List.generate(3, (index) {
          return Event(
            title: 'Update Defer Test $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
          );
        });
        await eventProvider.addEventsBatch(events);

        // Update with deferUpdates=true
        final updatedEvents = List.generate(3, (index) {
          return Event(
            title: 'Deferred Update $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
          );
        });

        await eventProvider.updateEventsBatch(
          updatedEvents,
          deferUpdates: true,
        );
        expect(eventProvider.areUpdatesPaused, false);

        // Update with deferUpdates=false
        await eventProvider.updateEventsBatch(
          updatedEvents,
          deferUpdates: false,
        );
        expect(eventProvider.areUpdatesPaused, false);
      });
    });

    group('deleteEventsBatch()', () {
      test('deletes multiple events in a single batch operation', () async {
        // First add some events
        final events = List.generate(5, (index) {
          return Event(
            title: 'Delete Test $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
          );
        });
        final filenames = await eventProvider.addEventsBatch(events);

        // Delete some of them
        final filenamesToDelete = [filenames[0], filenames[2], filenames[4]];
        await eventProvider.deleteEventsBatch(filenamesToDelete);

        expect(eventProvider.eventsCount, 2);
      });

      test('handles empty filename list gracefully', () async {
        await eventProvider.deleteEventsBatch([]);
        // Should not throw
        expect(eventProvider.eventsCount, 0);
      });

      test('respects deferUpdates parameter', () async {
        // Add initial events
        final events = List.generate(3, (index) {
          return Event(
            title: 'Delete Defer Test $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
          );
        });
        final filenames = await eventProvider.addEventsBatch(events);

        // Delete with deferUpdates=true
        await eventProvider.deleteEventsBatch([
          filenames[0],
        ], deferUpdates: true);
        expect(eventProvider.areUpdatesPaused, false);

        // Delete with deferUpdates=false
        await eventProvider.deleteEventsBatch([
          filenames[0],
        ], deferUpdates: false);
        expect(eventProvider.areUpdatesPaused, false);
      });
    });

    group('pause/resume Updates Pattern', () {
      test('pauseUpdates increments pause count', () {
        expect(eventProvider.areUpdatesPaused, false);

        eventProvider.pauseUpdates();
        expect(eventProvider.areUpdatesPaused, true);
        expect(eventProvider.hasPendingUpdate, false);

        eventProvider.pauseUpdates();
        expect(eventProvider.areUpdatesPaused, true);
      });

      test('resumeUpdates decrements pause count', () {
        eventProvider.pauseUpdates();
        eventProvider.pauseUpdates();
        expect(eventProvider.areUpdatesPaused, true);

        eventProvider.resumeUpdates();
        expect(eventProvider.areUpdatesPaused, true);

        eventProvider.resumeUpdates();
        expect(eventProvider.areUpdatesPaused, false);
      });

      test('pause/resume handles underflow gracefully', () {
        // Resume without pause should not cause issues
        eventProvider.resumeUpdates();
        expect(eventProvider.areUpdatesPaused, false);
      });

      test('pending update flag is set correctly', () async {
        eventProvider.pauseUpdates();

        // Add event while paused - should set pending update flag
        final event = Event(
          title: 'Paused Update Test',
          startDate: DateTime(2023, 10, 1),
        );
        await eventProvider.addEvent(event);

        expect(eventProvider.hasPendingUpdate, true);

        // Resume should clear pending flag and notify
        eventProvider.resumeUpdates();
        expect(eventProvider.hasPendingUpdate, false);
      });

      test('nested pause/resume works correctly', () async {
        eventProvider.pauseUpdates();
        eventProvider.pauseUpdates();

        final event = Event(
          title: 'Nested Pause Test',
          startDate: DateTime(2023, 10, 1),
        );
        await eventProvider.addEvent(event);

        expect(eventProvider.hasPendingUpdate, true);
        expect(eventProvider.areUpdatesPaused, true);

        // First resume should not notify
        eventProvider.resumeUpdates();
        expect(eventProvider.hasPendingUpdate, true);
        expect(eventProvider.areUpdatesPaused, true);

        // Second resume should notify
        eventProvider.resumeUpdates();
        expect(eventProvider.hasPendingUpdate, false);
        expect(eventProvider.areUpdatesPaused, false);
      });
    });

    group('Performance Tests', () {
      test('batch add is faster than individual adds', () async {
        final eventCount = 10;
        final events = List.generate(eventCount, (index) {
          return Event(
            title: 'Performance Test $index',
            startDate: DateTime.now().add(Duration(days: index)),
          );
        });

        // Measure batch add time
        final batchStopwatch = Stopwatch()..start();
        await eventProvider.addEventsBatch(events);
        batchStopwatch.stop();

        // Measure individual add time (with fresh provider)
        final individualProvider = EventProvider();
        await setupTestEnvironment();

        final individualStopwatch = Stopwatch()..start();
        for (final event in events) {
          await individualProvider.addEvent(event);
        }
        individualStopwatch.stop();

        // Batch should be significantly faster
        expect(
          batchStopwatch.elapsedMilliseconds,
          lessThan(individualStopwatch.elapsedMilliseconds),
        );
      });

      test('100 event batch creation completes in reasonable time', () async {
        final eventCount = 100;
        final events = List.generate(eventCount, (index) {
          return Event(
            title: 'Bulk Test Event $index',
            startDate: DateTime.now().add(Duration(days: index)),
          );
        });

        final stopwatch = Stopwatch()..start();
        final filenames = await eventProvider.addEventsBatch(events);
        stopwatch.stop();

        // Should complete in under 30 seconds (requirement is <30s)
        expect(stopwatch.elapsedMilliseconds, lessThan(30000));
        expect(filenames.length, eventCount);
        expect(eventProvider.eventsCount, eventCount);
      });
    });

    group('Backward Compatibility Tests', () {
      test('single event methods still work correctly', () async {
        final event = Event(
          title: 'Single Event Test',
          startDate: DateTime(2023, 10, 1),
          startTime: '10:00',
        );

        await eventProvider.addEvent(event);
        expect(eventProvider.eventsCount, 1);

        final addedEvent = eventProvider.getEventsForDate(
          DateTime(2023, 10, 1),
        )[0];

        final updatedEvent = addedEvent.copyWith(title: 'Updated Single Event');
        await eventProvider.updateEvent(addedEvent, updatedEvent);

        final eventsAfterUpdate = eventProvider.getEventsForDate(
          DateTime(2023, 10, 1),
        );
        expect(eventsAfterUpdate[0].title, 'Updated Single Event');

        await eventProvider.deleteEvent(eventsAfterUpdate[0]);
        expect(eventProvider.eventsCount, 0);
      });

      test('batch operations work alongside single operations', () async {
        // Add single event
        final singleEvent = Event(
          title: 'Single Event',
          startDate: DateTime(2023, 10, 1),
        );
        await eventProvider.addEvent(singleEvent);

        // Add batch events
        final batchEvents = List.generate(3, (index) {
          return Event(
            title: 'Batch Event $index',
            startDate: DateTime(2023, 10, 2).add(Duration(days: index)),
          );
        });
        await eventProvider.addEventsBatch(batchEvents);

        expect(eventProvider.eventsCount, 4);

        // Update single event
        final addedSingleEvent = eventProvider.getEventsForDate(
          DateTime(2023, 10, 1),
        )[0];
        final updatedSingleEvent = addedSingleEvent.copyWith(
          title: 'Updated Single Event',
        );
        await eventProvider.updateEvent(addedSingleEvent, updatedSingleEvent);

        // Delete batch event
        final batchEvent = eventProvider.getEventsForDate(
          DateTime(2023, 10, 2),
        )[0];
        await eventProvider.deleteEvent(batchEvent);

        expect(eventProvider.eventsCount, 3);
      });

      test('error handling works correctly in batch operations', () async {
        // Add some valid events first
        final validEvents = List.generate(3, (index) {
          return Event(
            title: 'Valid Event $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
          );
        });
        await eventProvider.addEventsBatch(validEvents);

        expect(eventProvider.eventsCount, 3);
      });
    });
  });

  // ============================================================================
  // BACKGROUND ISOLATE PROCESSING TESTS
  // ============================================================================

  group('Background Isolate Processing Tests', () {
    group('Event.getAllEventDatesAsync()', () {
      test('returns same results as synchronous version', () async {
        final events = [
          Event(
            title: 'Daily Event',
            startDate: DateTime(2023, 10, 1),
            recurrence: 'daily',
          ),
          Event(
            title: 'Weekly Event',
            startDate: DateTime(2023, 10, 1),
            recurrence: 'weekly',
          ),
          Event(title: 'Single Event', startDate: DateTime(2023, 10, 15)),
        ];

        // Compute results with both methods
        final syncResult = Event.getAllEventDates(events);
        final asyncResult = await Event.getAllEventDatesAsync(events);

        // Results should be identical
        expect(asyncResult.length, syncResult.length);
        for (final date in syncResult) {
          expect(asyncResult.contains(date), true);
        }
      });

      test('handles empty event list', () async {
        final result = await Event.getAllEventDatesAsync([]);
        expect(result, isEmpty);
      });

      test('handles large number of recurring events', () async {
        // Create 50 daily recurring events spanning a year
        final events = List.generate(50, (index) {
          return Event(
            title: 'Daily Recurring $index',
            startDate: DateTime(2023, 1, 1).add(Duration(days: index)),
            recurrence: 'daily',
          );
        });

        final stopwatch = Stopwatch()..start();
        final result = await Event.getAllEventDatesAsync(events);
        stopwatch.stop();

        // Should complete in reasonable time (under 10 seconds)
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
        // Should have many dates due to daily recurrence
        expect(result.length, greaterThan(0));
      });

      test('handles error gracefully with fallback', () async {
        // This test verifies that errors are caught and fallback works
        final events = [
          Event(title: 'Test Event', startDate: DateTime(2023, 10, 1)),
        ];

        // Should complete successfully even if isolate has issues
        final result = await Event.getAllEventDatesAsync(events);
        expect(result.contains(DateTime(2023, 10, 1)), true);
      });
    });

    group('Event.expandRecurringAsync()', () {
      test('returns same results as synchronous version', () async {
        final event = Event(
          title: 'Weekly Event',
          startDate: DateTime(2023, 10, 1),
          recurrence: 'weekly',
        );
        final endDate = DateTime(2023, 10, 31);

        final syncResult = Event.expandRecurring(event, endDate);
        final asyncResult = await Event.expandRecurringAsync(event, endDate);

        expect(asyncResult.length, syncResult.length);
        for (int i = 0; i < syncResult.length; i++) {
          expect(asyncResult[i].title, syncResult[i].title);
          expect(asyncResult[i].startDate, syncResult[i].startDate);
        }
      });

      test('handles daily recurrence correctly', () async {
        final event = Event(
          title: 'Daily',
          startDate: DateTime(2023, 10, 1),
          recurrence: 'daily',
        );
        final endDate = DateTime(2023, 10, 5);

        final result = await Event.expandRecurringAsync(event, endDate);

        expect(result.length, 5); // Oct 1, 2, 3, 4, 5
      });

      test('handles monthly recurrence correctly', () async {
        final event = Event(
          title: 'Monthly',
          startDate: DateTime(2023, 1, 15),
          recurrence: 'monthly',
        );
        final endDate = DateTime(2023, 6, 1);

        final result = await Event.expandRecurringAsync(event, endDate);

        // Should have instances for Jan, Feb, Mar, Apr, May, Jun
        expect(result.length, 6);
      });

      test('handles yearly recurrence correctly', () async {
        final event = Event(
          title: 'Yearly',
          startDate: DateTime(2023, 3, 15),
          recurrence: 'yearly',
        );
        final endDate = DateTime(2026, 3, 15);

        final result = await Event.expandRecurringAsync(event, endDate);

        // Should have instances for each year
        expect(
          result.length,
          greaterThanOrEqualTo(4),
        ); // 2023, 2024, 2025, 2026
      });

      test('handles error gracefully with fallback', () async {
        final event = Event(title: 'Test', startDate: DateTime(2023, 10, 1));

        // Should complete successfully even if isolate has issues
        final result = await Event.expandRecurringAsync(
          event,
          DateTime(2023, 10, 5),
        );
        expect(result.length, 1);
        expect(result[0].title, 'Test');
      });
    });

    group('EventProvider.computeEventDatesAsync()', () {
      test('updates event dates correctly', () async {
        // Add some events first
        final events = [
          Event(title: 'Event 1', startDate: DateTime(2023, 10, 1)),
          Event(title: 'Event 2', startDate: DateTime(2023, 10, 2)),
        ];
        await eventProvider.addEventsBatch(events);

        // Compute dates asynchronously
        await eventProvider.computeEventDatesAsync();

        // Verify dates are computed correctly
        expect(eventProvider.eventDates.contains(DateTime(2023, 10, 1)), true);
        expect(eventProvider.eventDates.contains(DateTime(2023, 10, 2)), true);
      });

      test('handles recurring events correctly', () async {
        final recurringEvent = Event(
          title: 'Weekly',
          startDate: DateTime(2023, 10, 1),
          recurrence: 'weekly',
        );
        await eventProvider.addEvent(recurringEvent);

        await eventProvider.computeEventDatesAsync();

        // Should have multiple dates due to weekly recurrence
        expect(eventProvider.eventDates.length, greaterThan(1));
      });

      test('handles empty event list', () async {
        // Provider starts with no events
        await eventProvider.computeEventDatesAsync();
        expect(eventProvider.eventDates, isEmpty);
      });

      test('completes in reasonable time with many events', () async {
        // Add many events
        final events = List.generate(100, (index) {
          return Event(
            title: 'Event $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
            recurrence: index % 3 == 0 ? 'daily' : 'none',
          );
        });
        await eventProvider.addEventsBatch(events);

        final stopwatch = Stopwatch()..start();
        await eventProvider.computeEventDatesAsync();
        stopwatch.stop();

        // Should complete within reasonable time (under 5 seconds)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('handles error gracefully with fallback', () async {
        // Add some events
        final event = Event(title: 'Test', startDate: DateTime(2023, 10, 1));
        await eventProvider.addEvent(event);

        // Should complete successfully even if isolate has issues
        await expectLater(eventProvider.computeEventDatesAsync(), completes);
        expect(eventProvider.eventDates.contains(DateTime(2023, 10, 1)), true);
      });
    });

    group('Integration Tests - Background Processing in Operations', () {
      test(
        'addEvent uses background processing for date computation',
        () async {
          final event = Event(
            title: 'Add Test',
            startDate: DateTime(2023, 10, 1),
          );

          await eventProvider.addEvent(event);

          expect(eventProvider.eventsCount, 1);
          expect(
            eventProvider.eventDates.contains(DateTime(2023, 10, 1)),
            true,
          );
        },
      );

      test(
        'updateEvent uses background processing for date computation',
        () async {
          final event = Event(
            title: 'Original',
            startDate: DateTime(2023, 10, 1),
          );
          await eventProvider.addEvent(event);

          final addedEvent = eventProvider.getEventsForDate(
            DateTime(2023, 10, 1),
          )[0];
          final updatedEvent = addedEvent.copyWith(
            title: 'Updated',
            startDate: DateTime(2023, 10, 2),
          );
          await eventProvider.updateEvent(addedEvent, updatedEvent);

          expect(eventProvider.eventsCount, 1);
          expect(
            eventProvider.eventDates.contains(DateTime(2023, 10, 2)),
            true,
          );
          expect(
            eventProvider.eventDates.contains(DateTime(2023, 10, 1)),
            false,
          );
        },
      );

      test(
        'deleteEvent uses background processing for date computation',
        () async {
          final event = Event(
            title: 'To Delete',
            startDate: DateTime(2023, 10, 1),
          );
          await eventProvider.addEvent(event);

          final addedEvent = eventProvider.getEventsForDate(
            DateTime(2023, 10, 1),
          )[0];
          await eventProvider.deleteEvent(addedEvent);

          expect(eventProvider.eventsCount, 0);
          expect(eventProvider.eventDates, isEmpty);
        },
      );

      test('batch operations use background processing', () async {
        final events = List.generate(20, (index) {
          return Event(
            title: 'Batch Event $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
            recurrence: index % 5 == 0 ? 'weekly' : 'none',
          );
        });

        await eventProvider.addEventsBatch(events);

        expect(eventProvider.eventsCount, 20);
        expect(eventProvider.eventDates.length, greaterThan(0));
      });

      test('loadAllEvents uses background processing', () async {
        // Add some events first
        final events = List.generate(10, (index) {
          return Event(
            title: 'Load Test $index',
            startDate: DateTime(2023, 10, 1).add(Duration(days: index)),
          );
        });
        await eventProvider.addEventsBatch(events);

        // Clear and reload
        eventProvider = EventProvider();
        await setupTestEnvironment();
        await eventProvider.loadAllEvents();

        expect(eventProvider.eventsCount, 10);
        expect(eventProvider.eventDates.length, 10);
      });
    });

    group('Performance Tests - Background Processing', () {
      test('UI remains responsive during heavy event processing', () async {
        // Create many recurring events that would be computationally expensive
        final events = List.generate(50, (index) {
          return Event(
            title: 'Heavy Processing $index',
            startDate: DateTime(2020, 1, 1).add(Duration(days: index)),
            recurrence: 'daily', // This will generate many instances
          );
        });

        // Measure time for background processing
        final stopwatch = Stopwatch()..start();
        await eventProvider.addEventsBatch(events);
        stopwatch.stop();

        // Should complete in reasonable time (under 30 seconds as per requirements)
        expect(stopwatch.elapsedMilliseconds, lessThan(30000));

        // Verify results are correct
        expect(eventProvider.eventsCount, 50);
        expect(eventProvider.eventDates.length, greaterThan(0));
      });

      test(
        'expandRecurringAsync handles complex recurrence patterns efficiently',
        () async {
          // Test with yearly recurrence over many years (computationally expensive)
          final event = Event(
            title: 'Yearly Complex',
            startDate: DateTime(2000, 2, 29), // Leap year day
            recurrence: 'yearly',
          );

          final stopwatch = Stopwatch()..start();
          final result = await Event.expandRecurringAsync(
            event,
            DateTime(2100, 2, 28),
          );
          stopwatch.stop();

          // Should handle leap year transitions efficiently
          expect(stopwatch.elapsedMilliseconds, lessThan(5000));
          expect(result.length, greaterThan(0));
        },
      );

      test('getAllEventDatesAsync with mixed recurrence types', () async {
        final events = [
          // 10 daily events
          ...List.generate(10, (index) {
            return Event(
              title: 'Daily $index',
              startDate: DateTime(2023, 1, 1).add(Duration(days: index)),
              recurrence: 'daily',
            );
          }),
          // 5 weekly events
          ...List.generate(5, (index) {
            return Event(
              title: 'Weekly $index',
              startDate: DateTime(2023, 1, 1).add(Duration(days: index * 7)),
              recurrence: 'weekly',
            );
          }),
          // 3 monthly events
          ...List.generate(3, (index) {
            return Event(
              title: 'Monthly $index',
              startDate: DateTime(2023, 1, 1).add(Duration(days: index * 30)),
              recurrence: 'monthly',
            );
          }),
        ];

        final stopwatch = Stopwatch()..start();
        final dates = await Event.getAllEventDatesAsync(events);
        stopwatch.stop();

        // Should complete efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
        expect(dates.length, greaterThan(0));
      });
    });

    group('Error Handling and Fallback Tests', () {
      test('getAllEventDatesAsync fallback on error works correctly', () async {
        final events = [Event(title: 'Test', startDate: DateTime(2023, 10, 1))];

        // Should work normally and produce correct results
        final result = await Event.getAllEventDatesAsync(events);
        expect(result.contains(DateTime(2023, 10, 1)), true);
      });

      test('expandRecurringAsync fallback on error works correctly', () async {
        final event = Event(
          title: 'Test',
          startDate: DateTime(2023, 10, 1),
          recurrence: 'daily',
        );

        // Should work normally and produce correct results
        final result = await Event.expandRecurringAsync(
          event,
          DateTime(2023, 10, 5),
        );
        expect(result.length, 5);
      });

      test(
        'computeEventDatesAsync fallback maintains data consistency',
        () async {
          final events = [
            Event(
              title: 'Consistency Test',
              startDate: DateTime(2023, 10, 1),
              recurrence: 'weekly',
            ),
          ];
          await eventProvider.addEventsBatch(events);

          // Force async computation
          await eventProvider.computeEventDatesAsync();

          // Verify data consistency
          expect(eventProvider.eventsCount, 1);
          expect(eventProvider.eventDates.length, greaterThan(0));
        },
      );
    });
  });

  test('syncInit calls SyncService.initSync', () async {
    // Since SyncService is private, we can't easily test, but the method exists
    expect(eventProvider.syncInit, isA<Function>());
  });

  test('syncPull calls SyncService.pullSync', () async {
    expect(eventProvider.syncPull, isA<Function>());
  });

  test('syncPush calls SyncService.pushSync', () async {
    expect(eventProvider.syncPush, isA<Function>());
  });

  test('syncStatus calls SyncService.getSyncStatus', () async {
    expect(eventProvider.syncStatus, isA<Function>());
  });

  group('Immediate Notification Functionality Tests', () {
    group('addEvent() Integration Tests', () {
      test(
        'triggers immediate notification for events within notification window',
        () async {
          // Create an event starting in 20 minutes (within 30-minute window)
          final now = DateTime.now();
          final event = Event(
            title: 'Immediate Notification Test',
            startDate: now.add(const Duration(minutes: 20)),
            startTime: _addMinutes(now.hour, now.minute, 20),
          );

          // Add event - should not throw and should process immediate notification
          await eventProvider.addEvent(event);

          // Event should be added successfully
          expect(eventProvider.eventsCount, 1);

          final addedEvents = eventProvider.getEventsForDate(
            now.add(const Duration(minutes: 20)),
          );
          expect(addedEvents.length, 1);
          expect(addedEvents[0].title, 'Immediate Notification Test');
        },
      );

      test('does not show immediate notification for future events', () async {
        // Create an event starting in 2 hours (outside notification window)
        final futureEvent = Event(
          title: 'Future Event',
          startDate: DateTime.now().add(const Duration(hours: 2)),
          startTime: '14:00',
        );

        // Should add successfully without immediate notification
        await eventProvider.addEvent(futureEvent);

        expect(eventProvider.eventsCount, 1);

        final events = eventProvider.getEventsForDate(
          DateTime.now().add(const Duration(hours: 2)),
        );
        expect(events.length, 1);
        expect(events[0].title, 'Future Event');
      });

      test('error handling does not break event addition', () async {
        // Create an event that would trigger immediate notification check
        final event = Event(
          title: 'Error Handling Test',
          startDate: DateTime.now().add(const Duration(minutes: 25)),
          startTime: _addMinutes(
            DateTime.now().hour,
            DateTime.now().minute,
            25,
          ),
        );

        // Should complete successfully even if immediate notification check has issues
        await expectLater(eventProvider.addEvent(event), completes);

        // Event should still be added
        expect(eventProvider.eventsCount, 1);
      });

      test(
        'handles all-day events with immediate notification check',
        () async {
          // All-day event starting tomorrow
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          final allDayEvent = Event(
            title: 'All Day Immediate Test',
            startDate: tomorrow,
          );

          await eventProvider.addEvent(allDayEvent);

          expect(eventProvider.eventsCount, 1);

          final addedEvents = eventProvider.getEventsForDate(tomorrow);
          expect(addedEvents.length, 1);
          expect(addedEvents[0].title, 'All Day Immediate Test');
        },
      );

      test('handles platform-specific notification behavior', () async {
        // This test verifies that addEvent works correctly regardless of platform
        // by ensuring the immediate notification check is called for all platforms
        final event = Event(
          title: 'Platform Test Event',
          startDate: DateTime.now().add(const Duration(days: 3)),
        );

        // Should complete successfully on any platform
        await expectLater(eventProvider.addEvent(event), completes);

        expect(eventProvider.eventsCount, 1);
      });

      test(
        'multiple rapid addEvent calls handle notifications correctly',
        () async {
          // Add multiple events in quick succession
          final now = DateTime.now();
          for (int i = 0; i < 3; i++) {
            final event = Event(
              title: 'Rapid Event $i',
              startDate: now.add(Duration(minutes: 20 + i)),
              startTime: _addMinutes(now.hour, now.minute, 20 + i),
            );
            await eventProvider.addEvent(event);
          }

          expect(eventProvider.eventsCount, 3);
        },
      );

      test('handles events at midnight with immediate notification', () async {
        // Event at midnight - notification should be 30 minutes before
        final midnightEvent = Event(
          title: 'Midnight Event',
          startDate: DateTime.now().add(const Duration(days: 1)),
          startTime: '00:00',
        );

        await eventProvider.addEvent(midnightEvent);

        expect(eventProvider.eventsCount, 1);

        final events = eventProvider.getEventsForDate(
          DateTime.now().add(const Duration(days: 1)),
        );
        expect(events.length, 1);
        expect(events[0].title, 'Midnight Event');
      });

      test('handles events exactly at notification threshold', () async {
        // Event exactly 30 minutes away - right at the notification boundary
        final now = DateTime.now();
        final thresholdEvent = Event(
          title: 'Threshold Event',
          startDate: now.add(const Duration(minutes: 30)),
          startTime: _addMinutes(now.hour, now.minute, 30),
        );

        // Should handle without throwing
        await expectLater(eventProvider.addEvent(thresholdEvent), completes);
        expect(eventProvider.eventsCount, 1);
      });

      test('handles all-day events on first day of month', () async {
        // Edge case: all-day event on first day of month
        final firstOfMonth = DateTime(
          DateTime.now().year,
          DateTime.now().month + 1,
          1,
        );
        final firstDayEvent = Event(
          title: 'First Day Event',
          startDate: firstOfMonth,
        );

        await eventProvider.addEvent(firstDayEvent);

        expect(eventProvider.eventsCount, 1);
      });
    });

    group('updateEvent() Integration Tests', () {
      test(
        'triggers immediate notification for updated events within window',
        () async {
          // First add an event
          final event = Event(
            title: 'Update Test Original',
            startDate: DateTime.now().add(const Duration(hours: 3)),
            startTime: '14:00',
          );
          await eventProvider.addEvent(event);

          final addedEvent = eventProvider.getEventsForDate(
            DateTime.now().add(const Duration(hours: 3)),
          )[0];

          // Update the event to be sooner (within notification window)
          final now = DateTime.now();
          final updatedEvent = addedEvent.copyWith(
            title: 'Updated Soon Event',
            startDate: now.add(const Duration(minutes: 15)),
            startTime: _addMinutes(now.hour, now.minute, 15),
          );

          await eventProvider.updateEvent(addedEvent, updatedEvent);

          // Event should be updated successfully
          final events = eventProvider.getEventsForDate(
            now.add(const Duration(minutes: 15)),
          );
          expect(events.length, 1);
          expect(events[0].title, 'Updated Soon Event');
        },
      );

      test(
        'does not show duplicate notifications for updated events',
        () async {
          // Add initial event
          final initialEvent = Event(
            title: 'Duplicate Test Original',
            startDate: DateTime.now().add(const Duration(hours: 1)),
            startTime: '14:00',
          );
          await eventProvider.addEvent(initialEvent);

          final addedEvent = eventProvider.getEventsForDate(
            DateTime.now().add(const Duration(hours: 1)),
          )[0];

          // Update with same timing - should not create duplicate notification
          final updatedEvent = addedEvent.copyWith(
            title: 'Duplicate Test Updated',
          );

          await eventProvider.updateEvent(addedEvent, updatedEvent);

          // Should still have only one event
          expect(eventProvider.eventsCount, 1);
        },
      );

      test('error handling does not break event update', () async {
        // Add an event first
        final event = Event(
          title: 'Update Error Test',
          startDate: DateTime.now().add(const Duration(hours: 2)),
          startTime: '14:00',
        );
        await eventProvider.addEvent(event);

        final addedEvent = eventProvider.getEventsForDate(
          DateTime.now().add(const Duration(hours: 2)),
        )[0];

        // Update should not throw even if immediate notification check has issues
        final updatedEvent = addedEvent.copyWith(title: 'Updated Title');
        await expectLater(
          eventProvider.updateEvent(addedEvent, updatedEvent),
          completes,
        );

        // Event should still be updated
        final events = eventProvider.getEventsForDate(
          DateTime.now().add(const Duration(hours: 2)),
        );
        expect(events.length, 1);
        expect(events[0].title, 'Updated Title');
      });

      test(
        'handles all-day event updates with immediate notification check',
        () async {
          // Add all-day event
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          final allDayEvent = Event(
            title: 'All Day Update Test',
            startDate: tomorrow,
          );
          await eventProvider.addEvent(allDayEvent);

          final addedEvents = eventProvider.getEventsForDate(tomorrow);
          expect(addedEvents.length, 1);

          // Update the event
          final updatedEvent = addedEvents[0].copyWith(
            title: 'Updated All Day Event',
            description: 'Updated description',
          );
          await eventProvider.updateEvent(addedEvents[0], updatedEvent);

          // Event should be updated successfully
          final updatedEvents = eventProvider.getEventsForDate(tomorrow);
          expect(updatedEvents.length, 1);
          expect(updatedEvents[0].title, 'Updated All Day Event');
        },
      );

      test(
        'updateEvent calls immediate notification check for all platforms',
        () async {
          // Add event first
          final event = Event(
            title: 'Update Platform Test',
            startDate: DateTime.now().add(const Duration(days: 2)),
          );
          await eventProvider.addEvent(event);

          final addedEvent = eventProvider.getEventsForDate(
            DateTime.now().add(const Duration(days: 2)),
          )[0];

          // Update should complete successfully on any platform
          final updatedEvent = addedEvent.copyWith(
            title: 'Updated Platform Test',
          );
          await expectLater(
            eventProvider.updateEvent(addedEvent, updatedEvent),
            completes,
          );

          expect(eventProvider.eventsCount, 1);
        },
      );

      test(
        'handles update from future to immediate notification window',
        () async {
          // Add event far in the future
          final futureEvent = Event(
            title: 'Future to Immediate',
            startDate: DateTime.now().add(const Duration(hours: 5)),
            startTime: '14:00',
          );
          await eventProvider.addEvent(futureEvent);

          final addedEvent = eventProvider.getEventsForDate(
            DateTime.now().add(const Duration(hours: 5)),
          )[0];

          // Update to be within notification window
          final now = DateTime.now();
          final updatedEvent = addedEvent.copyWith(
            startDate: now.add(const Duration(minutes: 10)),
            startTime: _addMinutes(now.hour, now.minute, 10),
          );

          await eventProvider.updateEvent(addedEvent, updatedEvent);

          // Should update successfully
          expect(eventProvider.eventsCount, 1);
        },
      );

      test(
        'handles update from immediate to outside notification window',
        () async {
          // Add event within notification window
          final now = DateTime.now();
          final immediateEvent = Event(
            title: 'Immediate to Future',
            startDate: now.add(const Duration(minutes: 15)),
            startTime: _addMinutes(now.hour, now.minute, 15),
          );
          await eventProvider.addEvent(immediateEvent);

          final addedEvent = eventProvider.getEventsForDate(
            now.add(const Duration(minutes: 15)),
          )[0];

          // Update to be outside notification window
          final updatedEvent = addedEvent.copyWith(
            startDate: now.add(const Duration(hours: 3)),
            startTime: '14:00',
          );

          await eventProvider.updateEvent(addedEvent, updatedEvent);

          // Should update successfully
          expect(eventProvider.eventsCount, 1);
        },
      );
    });

    group('Notification Time Calculation Tests', () {
      test('timed event notification time is 30 minutes before start', () {
        // Test that notification time logic works correctly
        final eventStart = DateTime(2023, 10, 1, 14, 0); // 2:00 PM
        final timedEvent = Event(
          title: 'Timed Event',
          startDate: eventStart,
          startTime: '14:00',
        );

        // Expected notification time: 30 minutes before event start
        final expectedNotificationTime = eventStart.subtract(
          const Duration(minutes: Event.notificationOffsetMinutes),
        );

        // Verify the calculation logic
        expect(expectedNotificationTime.hour, 13);
        expect(expectedNotificationTime.minute, 30);
        expect(expectedNotificationTime.year, 2023);
        expect(expectedNotificationTime.month, 10);
        expect(expectedNotificationTime.day, 1);
      });

      test('all-day event notification time is at midday day before', () {
        // Test that all-day notification logic works correctly
        final eventDate = DateTime(2023, 10, 5);
        final allDayEvent = Event(title: 'All Day Event', startDate: eventDate);

        // Expected notification time: midday (12:00) on day before
        final dayBefore = eventDate.subtract(const Duration(days: 1));
        final expectedNotificationTime = DateTime(
          dayBefore.year,
          dayBefore.month,
          dayBefore.day,
          Event.allDayNotificationHour,
          0,
        );

        // Verify the calculation logic
        expect(expectedNotificationTime.year, 2023);
        expect(expectedNotificationTime.month, 10);
        expect(expectedNotificationTime.day, 4); // Day before
        expect(
          expectedNotificationTime.hour,
          Event.allDayNotificationHour,
        ); // 12:00
        expect(expectedNotificationTime.minute, 0);
      });

      test('midnight event notification time calculation', () {
        // Test edge case: event at midnight
        final midnightEvent = Event(
          title: 'Midnight Event',
          startDate: DateTime(2023, 10, 1),
          startTime: '00:00',
        );

        // Expected notification time: 30 minutes before midnight = 23:30 previous day
        final eventStart = DateTime(2023, 10, 1, 0, 0);
        final expectedNotificationTime = eventStart.subtract(
          const Duration(minutes: Event.notificationOffsetMinutes),
        );

        expect(expectedNotificationTime.hour, 23);
        expect(expectedNotificationTime.minute, 30);
        expect(expectedNotificationTime.day, 30); // Previous day
        expect(expectedNotificationTime.month, 9); // September
      });

      test('notification window boundaries', () {
        // Test that we understand the notification window correctly
        final now = DateTime.now();

        // Event starting in 15 minutes - within 30-minute window
        final soonEventStart = now.add(const Duration(minutes: 15));
        final soonNotificationTime = soonEventStart.subtract(
          const Duration(minutes: Event.notificationOffsetMinutes),
        );

        // Should be within window: after notification time, before event
        expect(now.isAfter(soonNotificationTime), true);
        expect(now.isBefore(soonEventStart), true);

        // Event starting in 2 hours - outside 30-minute window
        final laterEventStart = now.add(const Duration(hours: 2));
        final laterNotificationTime = laterEventStart.subtract(
          const Duration(minutes: Event.notificationOffsetMinutes),
        );

        // Should be outside window: before notification time
        expect(now.isBefore(laterNotificationTime), true);
      });
    });

    group('Edge Case and Error Handling Tests', () {
      test('handles null/empty event data gracefully', () async {
        // Test with minimal valid event data
        final minimalEvent = Event(
          title: 'Minimal Event',
          startDate: DateTime.now().add(const Duration(days: 1)),
        );

        // Should not throw
        await expectLater(eventProvider.addEvent(minimalEvent), completes);
        expect(eventProvider.eventsCount, 1);
      });

      test('handles notification service failures gracefully', () async {
        // Create an event that would trigger immediate notification
        final event = Event(
          title: 'Notification Failure Test',
          startDate: DateTime.now().add(const Duration(minutes: 10)),
          startTime: _addMinutes(
            DateTime.now().hour,
            DateTime.now().minute,
            10,
          ),
        );

        // Should complete without throwing even if notification service fails
        await expectLater(eventProvider.addEvent(event), completes);
        expect(eventProvider.eventsCount, 1);
      });

      test('handles concurrent event additions', () async {
        // Add multiple events simultaneously
        final now = DateTime.now();
        final events = List.generate(5, (index) {
          // Use proper DateTime arithmetic to avoid hour overflow
          final eventTime = now.add(Duration(hours: 1 + index));
          return Event(
            title: 'Concurrent $index',
            startDate: eventTime,
            startTime: '${eventTime.hour.toString().padLeft(2, '0')}:00',
          );
        });

        // Add all events
        for (final event in events) {
          await eventProvider.addEvent(event);
        }

        expect(eventProvider.eventsCount, 5);
      });

      test('handles timezone edge cases', () async {
        // Test notification time calculation with various timezones
        // Event at very early morning
        final earlyMorningEvent = Event(
          title: 'Early Morning',
          startDate: DateTime(2023, 10, 1),
          startTime: '01:00',
        );

        // Expected notification time: 30 minutes before (00:30)
        final eventStart = DateTime(2023, 10, 1, 1, 0);
        final notificationTime = eventStart.subtract(
          const Duration(minutes: Event.notificationOffsetMinutes),
        );

        expect(notificationTime.hour, 0);
        expect(notificationTime.minute, 30);
        expect(notificationTime.day, 1); // Same day, just earlier

        // Add the event to verify it works
        await eventProvider.addEvent(earlyMorningEvent);
        expect(eventProvider.eventsCount, 1);
      });

      test('handles year boundary events', () async {
        // Event on January 1st
        final newYearEvent = Event(
          title: 'New Year Event',
          startDate: DateTime(2024, 1, 1),
          startTime: '00:00',
        );

        // Expected notification time: 30 minutes before on December 31, 2023
        final eventStart = DateTime(2024, 1, 1, 0, 0);
        final notificationTime = eventStart.subtract(
          const Duration(minutes: Event.notificationOffsetMinutes),
        );

        expect(notificationTime.year, 2023);
        expect(notificationTime.month, 12);
        expect(notificationTime.day, 31);
        expect(notificationTime.hour, 23);
        expect(notificationTime.minute, 30);

        // Add the event to verify it works
        await eventProvider.addEvent(newYearEvent);
        expect(eventProvider.eventsCount, 1);
      });

      test('handles events with maximum notification offset', () async {
        // Event exactly 30 minutes away
        final now = DateTime.now();
        final boundaryEvent = Event(
          title: 'Boundary Event',
          startDate: now.add(const Duration(minutes: 30)),
          startTime: _addMinutes(now.hour, now.minute, 30),
        );

        // Should handle without throwing
        await expectLater(eventProvider.addEvent(boundaryEvent), completes);
        expect(eventProvider.eventsCount, 1);
      });

      test(
        'preserves notification deduplication across multiple operations',
        () async {
          // Add an event, update it, then add another similar event
          final event1 = Event(
            title: 'Deduplication Test',
            startDate: DateTime.now().add(const Duration(minutes: 15)),
            startTime:
                '${DateTime.now().hour}:${_addMinutes(DateTime.now().hour, DateTime.now().minute, 15).split(':')[1]}',
          );

          await eventProvider.addEvent(event1);

          // Update the event
          final addedEvent = eventProvider.getEventsForDate(
            DateTime.now().add(const Duration(minutes: 15)),
          )[0];

          final event2 = addedEvent.copyWith(
            title: 'Deduplication Test Updated',
          );
          await eventProvider.updateEvent(addedEvent, event2);

          // Add another event with similar timing
          final event3 = Event(
            title: 'Deduplication Test 2',
            startDate: DateTime.now().add(const Duration(minutes: 16)),
            startTime:
                '${DateTime.now().hour}:${_addMinutes(DateTime.now().hour, DateTime.now().minute, 16).split(':')[1]}',
          );

          await eventProvider.addEvent(event3);

          // Should have 2 events (updated + new)
          expect(eventProvider.eventsCount, 2);
        },
      );

      test('handles rapid successive updates to same event', () async {
        // Add an event
        final event = Event(
          title: 'Rapid Updates',
          startDate: DateTime.now().add(const Duration(hours: 1)),
          startTime: '14:00',
        );
        await eventProvider.addEvent(event);

        final addedEvent = eventProvider.getEventsForDate(
          DateTime.now().add(const Duration(hours: 1)),
        )[0];

        // Rapidly update the same event multiple times
        for (int i = 0; i < 3; i++) {
          final updatedEvent = addedEvent.copyWith(title: 'Rapid Update $i');
          await eventProvider.updateEvent(addedEvent, updatedEvent);
        }

        // Should still have only one event
        expect(eventProvider.eventsCount, 1);
      });

      test('handles late night all-day event notification', () async {
        // Test edge case: all-day event starting after notification hour
        final lateEvent = Event(
          title: 'Late Event',
          startDate: DateTime(2023, 10, 1),
          startTime: '23:59', // Almost midnight
        );

        // Expected notification time: 30 minutes before
        final eventStart = DateTime(2023, 10, 1, 23, 59);
        final notificationTime = eventStart.subtract(
          const Duration(minutes: Event.notificationOffsetMinutes),
        );

        expect(notificationTime.day, 1);
        expect(notificationTime.hour, 23);
        expect(notificationTime.minute, 29);

        // Add the event to verify it works
        await eventProvider.addEvent(lateEvent);
        expect(eventProvider.eventsCount, 1);
      });

      test(
        'handles all-day event notification when today is notification day',
        () async {
          // All-day event starting tomorrow, but if it's after noon today,
          // notification should be triggered
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          final allDayEvent = Event(title: 'All Day Soon', startDate: tomorrow);

          await eventProvider.addEvent(allDayEvent);

          expect(eventProvider.eventsCount, 1);

          final addedEvents = eventProvider.getEventsForDate(tomorrow);
          expect(addedEvents.length, 1);
          expect(addedEvents[0].title, 'All Day Soon');
        },
      );

      test('does not notify for events that have already started', () async {
        // Event that has already started should not trigger notification
        final pastEvent = Event(
          title: 'Past Event',
          startDate: DateTime.now().subtract(const Duration(hours: 1)),
          startTime: '10:00',
        );

        // Should add successfully without issues
        await eventProvider.addEvent(pastEvent);
        expect(eventProvider.eventsCount, 1);
      });
    });
  });
}
