// ignore_for_file: unused_import, invalid_use_of_internal_member, unused_element

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../api.dart';
import '../frb_generated.dart';
import '../models/event.dart';

/// Exception thrown when Rcal operations fail.
class RcalException implements Exception {
  final String message;

  const RcalException(this.message);

  @override
  String toString() => 'RcalException: $message';
}

/// Adapter that wraps the Flutter Rust Bridge generated code
/// to provide a clean interface for Event operations.
///
/// This adapter converts between the FRB's EventDto and the app's Event model,
/// handling DateTime to String conversions and error handling.
class RcalAdapter {
  /// Creates a new RcalAdapter.
  ///
  /// The [api] parameter allows injection of a custom API instance for testing.
  /// If not provided, uses the default RustLib API.
  RcalAdapter({RustLibApi? api}) : _api = api;

  final RustLibApi? _api;

  /// Gets the Rust API instance.
  RustLibApi get api => _api ?? RustLib.instance.api;

  /// Gets the calendar directory path.
  ///
  /// This is a helper method to get the directory where calendar files are stored.
  /// Returns the path to the calendar directory.
  Future<String> getCalendarDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final calendarDir = Directory('${appDir.path}/calendar');
    if (!await calendarDir.exists()) {
      await calendarDir.create(recursive: true);
    }
    return calendarDir.path;
  }

  /// Converts a DateTime to a YYYY-MM-DD string format.
  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Converts a String in YYYY-MM-DD format to a DateTime.
  ///
  /// Validates that the date is not before 1970 (Unix epoch).
  /// Dates before 1970 are clamped to 1970-01-01 to prevent
  /// assertion failures in the event provider.
  DateTime _stringToDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) {
      throw RcalException('Invalid date format: $dateStr');
    }
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    // Clamp dates before 1970 to 1970-01-01 to prevent validation errors
    final minDate = DateTime.fromMillisecondsSinceEpoch(0);
    if (date.isBefore(minDate)) {
      return minDate;
    }

    return date;
  }

  /// Converts a String in HH:MM format to a DateTime (time only).
  /// Uses an arbitrary date, as we only care about the time.
  DateTime _stringToTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) {
      throw RcalException('Invalid time format: $timeStr');
    }
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Converts an EventDto to an Event model.
  Event _dtoToEvent(EventDto dto) {
    try {
      // If endDate equals startDate, treat it as null (no end date specified)
      final endDate = dto.endDate != null && dto.endDate != dto.startDate
          ? _stringToDate(dto.endDate!)
          : null;

      return Event(
        title: dto.title,
        startDate: _stringToDate(dto.startDate),
        endDate: endDate,
        startTime: dto.startTime,
        endTime: dto.endTime,
        description: dto.description,
        recurrence: dto.recurrence,
        filename: dto.id, // Use id as filename since it's the unique identifier
      );
    } catch (e) {
      throw RcalException('Failed to convert EventDto to Event: $e');
    }
  }

  /// Converts an Event model to an EventDto for sending to Rust.
  EventDto _eventToDto(Event event, {String? id}) {
    return EventDto(
      id: id ?? event.filename?.replaceAll('.md', '') ?? '',
      title: event.title,
      description: event.description,
      startDate: _dateToString(event.startDate),
      endDate: event.endDate != null ? _dateToString(event.endDate!) : null,
      startTime: event.startTime,
      endTime: event.endTime,
      isAllDay: event.isAllDay,
      recurrence: event.recurrence,
      isRecurringInstance: false,
    );
  }

  /// Loads all events from the specified calendar directory.
  ///
  /// Throws [RcalException] if the operation fails.
  Future<List<Event>> loadEvents(String calendarDir) async {
    try {
      final dtos = await api.crateApiGetAllEvents(calendarDir: calendarDir);
      return dtos.map(_dtoToEvent).toList();
    } catch (e) {
      throw RcalException('Failed to load events: $e');
    }
  }

  /// Gets events within the specified date range from the calendar directory.
  ///
  /// [start] - The start date of the range (inclusive).
  /// [end] - The end date of the range (inclusive).
  /// [calendarDir] - The path to the calendar directory.
  ///
  /// Returns events that occur on or after [start] and on or before [end].
  ///
  /// Throws [RcalException] if the operation fails.
  Future<List<Event>> getEventsInRange(
    DateTime start,
    DateTime end,
    String calendarDir,
  ) async {
    try {
      final dtos = await api.crateApiGetEventsInRange(
        startDate: _dateToString(start),
        endDate: _dateToString(end),
        calendarDir: calendarDir,
      );
      return dtos.map(_dtoToEvent).toList();
    } catch (e) {
      throw RcalException('Failed to get events in range: $e');
    }
  }

  /// Saves an event to the specified calendar directory.
  ///
  /// If the event already has an ID (filename), it will be updated.
  /// Otherwise, a new event will be created.
  ///
  /// Returns the ID/filename of the saved event.
  ///
  /// Throws [RcalException] if the operation fails.
  Future<String> saveEvent(Event event, String calendarDir) async {
    try {
      // Check if this is an update (event has existing filename) or create
      final existingId = event.filename?.replaceAll('.md', '');

      if (existingId != null && existingId.isNotEmpty) {
        // Update existing event
        await api.crateApiUpdateEvent(
          id: existingId,
          title: event.title,
          description: event.description,
          startDate: _dateToString(event.startDate),
          endDate: event.endDate != null ? _dateToString(event.endDate!) : null,
          startTime: event.startTime,
          endTime: event.endTime,
          isAllDay: event.isAllDay,
          recurrence: event.recurrence,
          calendarDir: calendarDir,
        );
        return '$existingId.md';
      } else {
        // Create new event
        final id = await api.crateApiCreateEvent(
          title: event.title,
          description: event.description,
          startDate: _dateToString(event.startDate),
          endDate: event.endDate != null ? _dateToString(event.endDate!) : null,
          startTime: event.startTime,
          endTime: event.endTime,
          isAllDay: event.isAllDay,
          recurrence: event.recurrence,
          calendarDir: calendarDir,
        );
        return '$id.md';
      }
    } catch (e) {
      throw RcalException('Failed to save event: $e');
    }
  }

  /// Deletes an event from the specified calendar directory.
  ///
  /// [id] - The ID (filename without .md extension) of the event to delete.
  /// [calendarDir] - The path to the calendar directory.
  ///
  /// Throws [RcalException] if the operation fails, including if the event
  /// is not found in storage (which may indicate a state mismatch).
  Future<void> deleteEvent(String id, String calendarDir) async {
    // Remove .md extension if present
    final eventId = id.replaceAll('.md', '');
    try {
      await api.crateApiDeleteEvent(id: eventId, calendarDir: calendarDir);
    } on RcalException {
      rethrow;
    } catch (e) {
      final errorStr = e.toString();
      // Check if this is a "not found" error from Rust
      if (errorStr.contains("not found")) {
        throw RcalException(
          'Event with id \'$eventId\' not found in storage. '
          'This may indicate a state mismatch between Dart and Rust. '
          'Original error: $e',
        );
      }
      throw RcalException('Failed to delete event: $e');
    }
  }

  // ============================================================================
  // Compatibility wrappers for EventStorage interface
  // ============================================================================

  /// Loads all events from the calendar directory.
  ///
  /// This is a convenience wrapper around [loadEvents] that automatically
  /// determines the calendar directory.
  ///
  /// Throws [RcalException] if the operation fails.
  Future<List<Event>> loadAllEvents() async {
    final calendarDir = await getCalendarDirectory();
    return loadEvents(calendarDir);
  }

  /// Adds a new event to the calendar.
  ///
  /// Convenience wrapper that calls [saveEvent] to create a new event.
  ///
  /// Returns the filename of the added event.
  ///
  /// Throws [RcalException] if the operation fails.
  Future<String> addEvent(Event event) async {
    final calendarDir = await getCalendarDirectory();
    return saveEvent(event, calendarDir);
  }

  /// Updates an existing event in the calendar.
  ///
  /// Convenience wrapper that calls [saveEvent] to update an existing event.
  /// The [oldEvent] is used to determine the existing event ID for the update.
  ///
  /// Returns the filename of the updated event.
  ///
  /// Throws [RcalException] if the operation fails.
  Future<String> updateEvent(Event oldEvent, Event newEvent) async {
    final calendarDir = await getCalendarDirectory();
    // Preserve the old event's filename for the update
    final eventWithFilename = newEvent.copyWith(filename: oldEvent.filename);
    return saveEvent(eventWithFilename, calendarDir);
  }

  /// Deletes an event from the calendar.
  ///
  /// Convenience wrapper that extracts the event ID from the Event object.
  ///
  /// Throws [RcalException] if the operation fails.
  Future<void> deleteEventByEvent(Event event) async {
    final calendarDir = await getCalendarDirectory();
    final id = event.filename ?? '';
    await deleteEvent(id, calendarDir);
  }
}
