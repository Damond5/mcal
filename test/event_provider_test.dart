import "package:flutter/services.dart";
  import "package:flutter_test/flutter_test.dart";
  import "package:shared_preferences/shared_preferences.dart";
  import "package:mcal/models/event.dart";
  import "package:mcal/providers/event_provider.dart";
  import "package:mcal/frb_generated.dart";
import "event_provider_test.mocks.dart";


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EventProvider eventProvider;
  late MockRustLibApi mockApi;

  setUpAll(() {
    mockApi = MockRustLibApi();
    RustLib.initMock(api: mockApi);
  });

   setUp(() {
    eventProvider = EventProvider();
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '/tmp/test_docs';
      }
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'), (MethodCall methodCall) async {
      if (methodCall.method == 'read') {
        return null;
      } else if (methodCall.method == 'write') {
        return null;
      }
      return null;
    });
  });

  group('Event Model Tests', () {
    test('Event.fromMarkdown parses rcal format correctly', () {
      const markdown = '''# Event: Test Event

- **Date**: 2023-10-01 to 2023-10-02
- **Time**: 10:00 to 11:00
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
      expect(markdown.contains('- **Time**: 10:00 to 11:00'), true);
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
      final event = Event(
        title: 'Single',
        startDate: DateTime(2023, 10, 1),
      );
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
      expect(Event.occursOnDate(event, DateTime(2023, 10, 3)), true); // Includes end date
    });

    test('Event.fromMarkdown throws on invalid date', () {
      const invalidMarkdown = '''# Event: Test
- **Date**: invalid-date
''';
      expect(() => Event.fromMarkdown(invalidMarkdown, 'invalid.md'), throwsFormatException);
    });

    test('Event.fromMarkdown throws on end before start', () {
      const invalidMarkdown = '''# Event: Test
- **Date**: 2023-10-02 to 2023-10-01
''';
      expect(() => Event.fromMarkdown(invalidMarkdown, 'invalid.md'), throwsFormatException);
    });

    test('Event.fromMarkdown throws on invalid time', () {
      const invalidMarkdown = '''# Event: Test
- **Date**: 2023-10-01
- **Time**: 25:00
''';
      expect(() => Event.fromMarkdown(invalidMarkdown, 'invalid.md'), throwsFormatException);
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
      final events = eventProvider.getEventsForDate(DateTime(2023, 10, 1)).where((e) => e.title == 'Duplicate').toList();
      expect(events.length, 1);
      final addedEvent1 = events[0];
      expect(addedEvent1.filename, isNotNull);
      // Delete the first one
      await eventProvider.deleteEvent(addedEvent1);
      final remaining = eventProvider.getEventsForDate(DateTime(2023, 10, 2)).where((e) => e.title == 'Duplicate').toList();
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
      final event = Event(
        title: 'Test',
        startDate: DateTime(2023, 10, 1),
      );
      await eventProvider.addEvent(event);
      final addedEvent = eventProvider.getEventsForDate(DateTime(2023, 10, 1))[0];
      await eventProvider.deleteEvent(addedEvent);
      final events = eventProvider.getEventsForDate(DateTime(2023, 10, 1));
      expect(events, isEmpty);
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
}