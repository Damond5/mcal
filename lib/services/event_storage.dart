import 'dart:io';
import 'dart:developer';
import 'package:path/path.dart' as path;
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
      final files = (await calendarDir.list().toList()).whereType<File>().where((f) => f.path.endsWith('.md'));
      for (final file in files) {
        try {
          final content = await file.readAsString();
          final filename = path.basename(file.path);
          final event = Event.fromMarkdown(content, filename);
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
      fileName = '${baseName}_$counter.md';
      counter++;
    }

    return fileName;
  }

  Future<String> saveEvent(Event event) async {
    final dir = await _getCalendarDirectory();
    final fileName = await _getUniqueFileName(event);
    final file = File('$dir/$fileName');
    await file.writeAsString(event.toMarkdown());
    return fileName;
  }

  Future<String> addEvent(Event event) async {
    return await saveEvent(event);
  }

  Future<String> updateEvent(Event oldEvent, Event newEvent) async {
    final dir = await _getCalendarDirectory();
    // Use old event's filename if available
    final oldFileName = oldEvent.filename ?? await _getUniqueFileName(oldEvent);
    final oldFile = File('$dir/$oldFileName');
    if (await oldFile.exists()) {
      await oldFile.delete();
    }
    // Save new
    return await saveEvent(newEvent);
  }

  Future<void> deleteEvent(Event event) async {
    final fileName = event.filename ?? await _getUniqueFileName(event);
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