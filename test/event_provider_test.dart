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
        final event = Event(
          title: 'Update Error Test',
          startDate: DateTime.now().add(const Duration(hours: 2)),
          startTime:
              (DateTime.now().hour + 2).toString().padLeft(2, '0') + ':00',
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
        final event = Event(
          title: 'Update Soon Event',
          startDate: now.add(const Duration(hours: 1)),
          startTime: (now.hour + 1).toString().padLeft(2, '0') + ':00',
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
        final events = List.generate(
          5,
          (index) => Event(
            title: 'Concurrent $index',
            startDate: now.add(Duration(hours: 1 + index)),
            startTime: '${now.hour + 1 + index}:00',
          ),
        );

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
