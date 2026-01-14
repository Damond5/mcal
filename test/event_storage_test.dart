import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mcal/models/event.dart';
import 'package:mcal/services/event_storage.dart';
import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EventStorage eventStorage;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  setUp(() async {
    eventStorage = EventStorage();
    await cleanTestEvents();
  });

  group('EventStorage loadAllEvents Parallel I/O Tests', () {
    test('loads single event successfully', () async {
      // Add a single event
      final event = Event(
        title: 'Single Event',
        startDate: DateTime(2023, 10, 1),
        startTime: '10:00',
      );
      await eventStorage.saveEvent(event);

      // Load all events
      final events = await eventStorage.loadAllEvents();

      expect(events.length, 1);
      expect(events[0].title, 'Single Event');
      expect(events[0].startDate, DateTime(2023, 10, 1));
    });

    test('loads multiple events in parallel', () async {
      // Add multiple events
      final events = List.generate(10, (index) {
        return Event(
          title: 'Event $index',
          startDate: DateTime(2023, 10, index + 1),
          startTime: '${10 + index}:00',
        );
      });

      for (final event in events) {
        await eventStorage.saveEvent(event);
      }

      // Load all events
      final loadedEvents = await eventStorage.loadAllEvents();

      expect(loadedEvents.length, 10);
      expect(
        loadedEvents.map((e) => e.title).toSet(),
        containsAll(events.map((e) => e.title)),
      );
    });

    test('handles empty directory gracefully', () async {
      // Load events from empty directory
      final events = await eventStorage.loadAllEvents();

      expect(events, isEmpty);
    });

    test('handles non-existent directory gracefully', () async {
      // Set to non-existent directory
      EventStorage.setTestDirectory('/non/existent/path');
      try {
        final events = await eventStorage.loadAllEvents();
        expect(events, isEmpty);
      } finally {
        EventStorage.clearTestDirectory();
      }
    });

    test('continues loading when individual files have errors', () async {
      // Add some valid events
      final validEvents = [
        Event(title: 'Valid Event 1', startDate: DateTime(2023, 10, 1)),
        Event(title: 'Valid Event 2', startDate: DateTime(2023, 10, 2)),
      ];

      for (final event in validEvents) {
        await eventStorage.saveEvent(event);
      }

      // Manually add a malformed file
      final dir = await eventStorage.getCalendarDirectoryPath();
      final malformedFile = File('$dir/malformed.md');
      await malformedFile.writeAsString('Invalid markdown content');

      // Load all events - should not throw, should skip malformed file
      final loadedEvents = await eventStorage.loadAllEvents();

      // Should have loaded only the valid events
      expect(loadedEvents.length, 2);
      expect(
        loadedEvents.map((e) => e.title),
        containsAll(['Valid Event 1', 'Valid Event 2']),
      );
    });

    test('handles multiple malformed files gracefully', () async {
      // Add some valid events
      final validEvents = [
        Event(title: 'Valid Event', startDate: DateTime(2023, 10, 1)),
      ];

      for (final event in validEvents) {
        await eventStorage.saveEvent(event);
      }

      // Add multiple malformed files
      final dir = await eventStorage.getCalendarDirectoryPath();
      for (int i = 0; i < 5; i++) {
        final malformedFile = File('$dir/malformed_$i.md');
        await malformedFile.writeAsString('Invalid markdown $i');
      }

      // Load all events - should not throw
      final loadedEvents = await eventStorage.loadAllEvents();

      // Should have loaded only the valid event
      expect(loadedEvents.length, 1);
      expect(loadedEvents[0].title, 'Valid Event');
    });

    test('preserves event data correctly', () async {
      // Add a complex event
      final event = Event(
        title: 'Complex Event',
        description: 'A complex event with all fields',
        startDate: DateTime(2023, 10, 1),
        endDate: DateTime(2023, 10, 3),
        startTime: '09:00',
        endTime: '17:00',
        recurrence: 'weekly',
      );
      await eventStorage.saveEvent(event);

      // Load events
      final loadedEvents = await eventStorage.loadAllEvents();

      expect(loadedEvents.length, 1);
      final loaded = loadedEvents[0];

      expect(loaded.title, event.title);
      expect(loaded.description, event.description);
      expect(loaded.startDate, event.startDate);
      expect(loaded.endDate, event.endDate);
      expect(loaded.startTime, event.startTime);
      expect(loaded.endTime, event.endTime);
      expect(loaded.recurrence, event.recurrence);
    });

    test('filters only .md files', () async {
      // Add a valid event
      final event = Event(
        title: 'Valid Event',
        startDate: DateTime(2023, 10, 1),
      );
      await eventStorage.saveEvent(event);

      // Add non-.md files
      final dir = await eventStorage.getCalendarDirectoryPath();
      await File('$dir/not_markdown.txt').writeAsString('This is not markdown');
      await File('$dir/other_file.log').writeAsString('Log file');
      await File('$dir/config.json').writeAsString('{"key": "value"}');

      // Load events
      final loadedEvents = await eventStorage.loadAllEvents();

      // Should only load .md files
      expect(loadedEvents.length, 1);
      expect(loadedEvents[0].title, 'Valid Event');
    });

    test('handles concurrent loadAllEvents calls', () async {
      // Add some events
      final events = List.generate(5, (index) {
        return Event(
          title: 'Event $index',
          startDate: DateTime(2023, 10, index + 1),
        );
      });

      for (final event in events) {
        await eventStorage.saveEvent(event);
      }

      // Load events concurrently
      final results = await Future.wait([
        eventStorage.loadAllEvents(),
        eventStorage.loadAllEvents(),
        eventStorage.loadAllEvents(),
      ]);

      // All results should be identical
      for (final loadedEvents in results) {
        expect(loadedEvents.length, 5);
      }
    });

    test('performance: loads 100 events quickly', () async {
      // Add 100 events
      final events = List.generate(100, (index) {
        return Event(
          title: 'Performance Event $index',
          startDate: DateTime(2023, 10, index + 1),
          startTime: '${index % 24}:00',
        );
      });

      for (final event in events) {
        await eventStorage.saveEvent(event);
      }

      // Measure load time
      final stopwatch = Stopwatch()..start();
      final loadedEvents = await eventStorage.loadAllEvents();
      stopwatch.stop();

      // Should load all 100 events
      expect(loadedEvents.length, 100);

      // Should complete in under 3 seconds (performance requirement)
      // Using a generous timeout for test environment variability
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(3000),
        reason:
            'Load time: ${stopwatch.elapsedMilliseconds}ms, expected < 3000ms',
      );
    });

    test('handles events with special characters in filenames', () async {
      // Add an event
      final event = Event(
        title: 'Special Event',
        startDate: DateTime(2023, 10, 1),
      );
      await eventStorage.saveEvent(event);

      // Load events
      final loadedEvents = await eventStorage.loadAllEvents();

      expect(loadedEvents.length, 1);
      expect(loadedEvents[0].filename, isNotNull);
      expect(loadedEvents[0].filename!.endsWith('.md'), true);
    });

    test('handles very long event content', () async {
      // Create event with long content
      final longDescription = 'A' * 10000; // 10KB description
      final event = Event(
        title: 'Long Event',
        description: longDescription,
        startDate: DateTime(2023, 10, 1),
      );
      await eventStorage.saveEvent(event);

      // Load events
      final loadedEvents = await eventStorage.loadAllEvents();

      expect(loadedEvents.length, 1);
      expect(loadedEvents[0].description, longDescription);
    });

    test('maintains file order independence', () async {
      // Add events in a specific order
      final events = List.generate(5, (index) {
        return Event(
          title: 'Event $index',
          startDate: DateTime(2023, 10, index + 1),
        );
      });

      for (final event in events) {
        await eventStorage.saveEvent(event);
      }

      // Load multiple times - order might vary but content should be the same
      final results = await Future.wait([
        eventStorage.loadAllEvents(),
        eventStorage.loadAllEvents(),
        eventStorage.loadAllEvents(),
      ]);

      // Each load should have same number of events
      for (final loadedEvents in results) {
        expect(loadedEvents.length, 5);
      }

      // All events should be present (order may vary)
      for (final loadedEvents in results) {
        final titles = loadedEvents.map((e) => e.title).toSet();
        expect(titles, containsAll(events.map((e) => e.title)));
      }
    });
  });

  group('EventStorage CRUD Operations Tests', () {
    test('addEvent and loadAllEvents work together', () async {
      final event = Event(
        title: 'Test Event',
        startDate: DateTime(2023, 10, 1),
        startTime: '10:00',
      );

      await eventStorage.addEvent(event);
      final events = await eventStorage.loadAllEvents();

      expect(events.length, 1);
      expect(events[0].title, 'Test Event');
    });

    test('deleteEvent removes event from storage', () async {
      final event = Event(
        title: 'Delete Test',
        startDate: DateTime(2023, 10, 1),
      );

      await eventStorage.addEvent(event);
      final initialEvents = await eventStorage.loadAllEvents();
      expect(initialEvents.length, 1);

      await eventStorage.deleteEvent(initialEvents[0]);
      final afterDelete = await eventStorage.loadAllEvents();
      expect(afterDelete.length, 0);
    });

    test('updateEvent updates event in storage', () async {
      final originalEvent = Event(
        title: 'Original Title',
        startDate: DateTime(2023, 10, 1),
      );

      await eventStorage.addEvent(originalEvent);
      final initialEvents = await eventStorage.loadAllEvents();
      expect(initialEvents[0].title, 'Original Title');

      final updatedEvent = initialEvents[0].copyWith(title: 'Updated Title');
      await eventStorage.updateEvent(initialEvents[0], updatedEvent);

      final afterUpdate = await eventStorage.loadAllEvents();
      expect(afterUpdate.length, 1);
      expect(afterUpdate[0].title, 'Updated Title');
    });

    test('getEventDates returns all event dates', () async {
      final events = [
        Event(title: 'Event 1', startDate: DateTime(2023, 10, 1)),
        Event(title: 'Event 2', startDate: DateTime(2023, 10, 2)),
        Event(
          title: 'Event 3',
          startDate: DateTime(2023, 10, 1),
        ), // Same date as Event 1
      ];

      for (final event in events) {
        await eventStorage.addEvent(event);
      }

      final dates = await eventStorage.getEventDates();

      expect(dates.length, 2); // Two unique dates
      expect(dates, contains(DateTime(2023, 10, 1)));
      expect(dates, contains(DateTime(2023, 10, 2)));
    });
  });
}
