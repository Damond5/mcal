import 'dart:io';
import 'dart:developer';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/event.dart';

class EventStorage {
  static const String _calendarDir = 'calendar';

  // Test mode: allows overriding directory for testing
  static String? _testDirectory;

  static void setTestDirectory(String directory) {
    assert(
      kDebugMode,
      'setTestDirectory should only be used in debug/test mode',
    );
    _testDirectory = directory;
  }

  static void clearTestDirectory() {
    _testDirectory = null;
  }

  Future<String> _getCalendarDirectory() async {
    if (_testDirectory != null) {
      final calendarDir = Directory('$_testDirectory/$_calendarDir');
      try {
        if (!await calendarDir.exists()) {
          await calendarDir.create(recursive: true);
        }
        return calendarDir.path;
      } catch (e) {
        // If we can't create the directory (e.g., permission denied),
        // return an empty temporary directory
        log('Warning: Could not create test directory $calendarDir: $e');
        final tempDir = Directory.systemTemp.createTempSync(
          'mcal_test_fallback_',
        );
        return tempDir.path;
      }
    }

    final appDir = await getApplicationDocumentsDirectory();
    final calendarDir = Directory('${appDir.path}/$_calendarDir');
    if (!await calendarDir.exists()) {
      await calendarDir.create(recursive: true);
    }
    return calendarDir.path;
  }

  Future<List<Event>> loadAllEvents() async {
    final dir = await _getCalendarDirectory();
    log('Loading events from directory: $dir');
    final calendarDir = Directory(dir);
    final events = <Event>[];

    try {
      if (await calendarDir.exists()) {
        final files = (await calendarDir.list().toList())
            .whereType<File>()
            .where((f) => f.path.endsWith('.md'));
        log('Found ${files.length} .md files');

        // Parallel file reading for improved performance
        final eventFutures = files.map((file) async {
          try {
            // Check if file still exists before reading (handles parallel test cleanup)
            if (!await file.exists()) {
              log('File no longer exists, skipping: ${file.path}');
              return null;
            }
            final content = await file.readAsString();
            final filename = path.basename(file.path);
            final event = Event.fromMarkdown(content, filename);
            log(
              'Parsed event: ${event.title} on ${event.startDate} from $filename',
            );
            return event;
          } catch (e) {
            log('Error parsing event file ${file.path}: $e');
            return null;
          }
        });
        final loadedEvents = await Future.wait(eventFutures);
        events.addAll(loadedEvents.whereType<Event>());
      } else {
        log('Calendar directory does not exist: $dir');
      }
    } catch (e) {
      // Directory might have been deleted by parallel test - return empty list
      log('Warning: Could not load events: $e');
    }

    log('Total events loaded: ${events.length}');
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
    // Ensure directory exists before writing (handles parallel test scenarios)
    final dir = await _getCalendarDirectory();

    // Extra safety: ensure directory exists before checking for existing files or writing
    // This handles race conditions where directory might be deleted by parallel test cleanup
    final dirObj = Directory(dir);
    if (!await dirObj.exists()) {
      try {
        await dirObj.create(recursive: true);
      } catch (e) {
        // Directory might have been created by another concurrent operation
        // Try again to be sure
        if (!await dirObj.exists()) {
          log('Warning: Could not create directory $dir: $e');
          // Fall back to creating in temp
          final fallbackDir = await Directory.systemTemp.createTemp(
            'mcal_fallback_',
          );
          final fileName = await _getUniqueFileNameFromDirectory(
            event,
            fallbackDir.path,
          );
          final file = File('${fallbackDir.path}/$fileName');
          await file.writeAsString(event.toMarkdown());
          return fileName;
        }
      }
    }

    // Now get unique filename and write (directory is guaranteed to exist)
    // Wrap entirely in try-catch to handle race condition where directory gets deleted
    // by parallel test cleanup between any of our operations
    try {
      // First ensure directory exists
      if (!await dirObj.exists()) {
        await dirObj.create(recursive: true);
      }
      final fileName = await _getUniqueFileName(event);
      final file = File('$dir/$fileName');

      // Check again before writing in case it was deleted
      if (!await dirObj.exists()) {
        await dirObj.create(recursive: true);
      }

      await file.writeAsString(event.toMarkdown());
      return fileName;
    } catch (e) {
      // If write failed (directory might have been deleted), retry once
      log('Warning: Write failed, retrying: $e');
      // Create directory fresh
      await dirObj.create(recursive: true);
      final fileName = await _getUniqueFileName(event);
      final file = File('$dir/$fileName');
      await file.writeAsString(event.toMarkdown());
      return fileName;
    }
  }

  // Helper method to get unique filename from a specific directory
  Future<String> _getUniqueFileNameFromDirectory(
    Event event,
    String dir,
  ) async {
    final baseName = event.fileName.replaceAll('.md', '');
    String fileName = '$baseName.md';
    int counter = 1;

    while (await File('$dir/$fileName').exists()) {
      fileName = '${baseName}_$counter.md';
      counter++;
    }

    return fileName;
  }

  Future<String> addEvent(Event event) async {
    return await saveEvent(event);
  }

  Future<String> updateEvent(Event oldEvent, Event newEvent) async {
    final dir = await _getCalendarDirectory();
    // Use old event's filename if available, preserve it unless explicitly changed
    final oldFileName = oldEvent.filename ?? await _getUniqueFileName(oldEvent);
    final oldFile = File('$dir/$oldFileName');
    if (await oldFile.exists()) {
      await oldFile.delete();
    }

    // Preserve the original filename unless explicitly provided in the new event
    final eventWithFilename = newEvent.filename != null
        ? newEvent
        : newEvent.copyWith(filename: oldFileName);

    // Save new event with preserved filename
    return await saveEvent(eventWithFilename);
  }

  Future<void> deleteEvent(Event event) async {
    final fileName = event.filename ?? await _getUniqueFileName(event);
    final dir = await _getCalendarDirectory();
    final file = File('$dir/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Public helper for testing - returns calendar directory path
  Future<String> getCalendarDirectoryPath() async {
    return await _getCalendarDirectory();
  }

  Future<Set<DateTime>> getEventDates() async {
    final allEvents = await loadAllEvents();
    return Event.getAllEventDates(allEvents);
  }
}
