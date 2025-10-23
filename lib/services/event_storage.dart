import 'dart:io';
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

  String _getFileName(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}.md';
  }

  Future<File> _getFile(DateTime date) async {
    final dir = await _getCalendarDirectory();
    final fileName = _getFileName(date);
    return File('$dir/$fileName');
  }

  Future<List<Event>> loadEvents(DateTime date) async {
    final file = await _getFile(date);
    if (!await file.exists()) {
      return [];
    }

    final content = await file.readAsString();
    final sections = content.split('\n## ').where((s) => s.trim().isNotEmpty);

    final events = <Event>[];
    for (final section in sections) {
      final fullSection = section.startsWith('## ') ? section : '## $section';
      try {
        final event = Event.fromMarkdown(fullSection, date);
        events.add(event);
      } catch (e) {
        // Skip invalid sections
      }
    }

    return events;
  }

  Future<void> saveEvents(DateTime date, List<Event> events) async {
    final file = await _getFile(date);
    final content = events.map((e) => e.toMarkdown()).join('\n');
    await file.writeAsString(content);
  }

  Future<void> addEvent(Event event) async {
    final events = await loadEvents(event.date);
    events.add(event);
    await saveEvents(event.date, events);
  }

  Future<void> updateEvent(Event event) async {
    final events = await loadEvents(event.date);
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await saveEvents(event.date, events);
    }
  }

  Future<void> deleteEvent(String eventId, DateTime date) async {
    final events = await loadEvents(date);
    events.removeWhere((e) => e.id == eventId);
    await saveEvents(date, events);
  }

  Future<Set<DateTime>> getEventDates() async {
    final dir = await _getCalendarDirectory();
    final calendarDir = Directory(dir);
    final dates = <DateTime>{};

    if (await calendarDir.exists()) {
      final files = calendarDir.listSync().whereType<File>();
      for (final file in files) {
        final fileName = file.uri.pathSegments.last;
        if (fileName.endsWith('.md')) {
          final dateStr = fileName.replaceAll('.md', '');
          try {
            final parts = dateStr.split('-');
            if (parts.length == 3) {
              final year = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final day = int.parse(parts[2]);
              dates.add(DateTime(year, month, day));
            }
          } catch (e) {
            // Skip invalid files
          }
        }
      }
    }

    return dates;
  }
}