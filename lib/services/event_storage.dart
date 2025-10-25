import 'dart:io';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import '../models/event.dart';

class EventStorage {
  static const String _calendarDir = 'calendar';

  Future<String> _getCalendarDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final calendarDir = Directory('${appDir.path}/$_calendarDir');
    if (!await calendarDir.exists()) {
      await calendarDir.create(recursive: true);
    }
    return calendarDir.path;
  }

  Future<List<Event>> loadAllEvents() async {
    final dir = await _getCalendarDirectory();
    final calendarDir = Directory(dir);
    final events = <Event>[];

    if (await calendarDir.exists()) {
      final files = calendarDir.listSync().whereType<File>().where((f) => f.path.endsWith('.md'));
      for (final file in files) {
        try {
          final content = await file.readAsString();
          final event = Event.fromMarkdown(content);
          events.add(event);
        } catch (e) {
          log('Error parsing event file ${file.path}: $e');
          // Skip invalid files
        }
      }
    }

    return events;
  }

  Future<List<Event>> loadEvents(DateTime date) async {
    final allEvents = await loadAllEvents();
    final expandedEvents = <Event>[];

    for (final event in allEvents) {
      expandedEvents.addAll(Event.expandRecurring(event, date));
    }

    // Filter events that occur on the given date
    return expandedEvents.where((e) => Event.occursOnDate(e, date)).toList();
  }

  Future<String> _getUniqueFileName(Event event) async {
    final dir = await _getCalendarDirectory();
    final baseName = event.fileName.replaceAll('.md', '');
    String fileName = '$baseName.md';
    int counter = 1;

    while (await File('$dir/$fileName').exists()) {
      // Check if the existing file is for the same event (by id)
      try {
        final content = await File('$dir/$fileName').readAsString();
        final existingEvent = Event.fromMarkdown(content);
        if (existingEvent.id == event.id) {
          return fileName; // Same event, can overwrite
        }
      } catch (e) {
        // Invalid file, treat as collision
      }
      fileName = '${baseName}_$counter.md';
      counter++;
    }

    return fileName;
  }

  Future<void> saveEvent(Event event) async {
    final dir = await _getCalendarDirectory();
    final fileName = await _getUniqueFileName(event);
    final file = File('$dir/$fileName');
    await file.writeAsString(event.toMarkdown());
  }

  Future<void> addEvent(Event event) async {
    await saveEvent(event);
  }

  Future<void> updateEvent(Event event) async {
    // Find and delete old file
    final allEvents = await loadAllEvents();
    final oldEvent = allEvents.firstWhere((e) => e.id == event.id, orElse: () => throw Exception('Event not found'));
    final oldFileName = await _getUniqueFileName(oldEvent);
    final dir = await _getCalendarDirectory();
    final oldFile = File('$dir/$oldFileName');
    if (await oldFile.exists()) {
      await oldFile.delete();
    }
    // Save new
    await saveEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    final allEvents = await loadAllEvents();
    final event = allEvents.firstWhere((e) => e.id == eventId, orElse: () => throw Exception('Event not found'));
    final fileName = await _getUniqueFileName(event);
    final dir = await _getCalendarDirectory();
    final file = File('$dir/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Set<DateTime>> getEventDates() async {
    final allEvents = await loadAllEvents();
    final dates = <DateTime>{};

    for (final event in allEvents) {
      final expanded = Event.expandRecurring(event, DateTime.now()); // Expand around now
      for (final e in expanded) {
        dates.add(DateTime(e.startDate.year, e.startDate.month, e.startDate.day));
        if (e.endDate != null) {
          DateTime current = e.startDate;
          while (current.isBefore(e.endDate!) || current.isAtSameMomentAs(e.endDate!)) {
            dates.add(DateTime(current.year, current.month, current.day));
            current = current.add(const Duration(days: 1));
          }
        }
      }
    }

    return dates;
  }
}