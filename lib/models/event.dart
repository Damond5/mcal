import 'dart:developer';

import 'package:mcal/api.dart' as rcal_api;

class Event {
  static const List<String> validRecurrences = [
    'none',
    'daily',
    'weekly',
    'monthly',
    'yearly',
  ];
  static const int minYear = 1900;
  static const int maxYear = 2100;
  static const int notificationOffsetMinutes = 30;
  static const int allDayNotificationHour = 12;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final String? startTime; // HH:MM format or null for all-day
  final String? endTime; // HH:MM format or null
  final String description;
  final String recurrence; // 'none', 'daily', 'weekly', 'monthly', 'yearly'
  final String?
  filename; // Title-based filename for display/identification only

  Event({
    required this.title,
    required this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.description = '',
    this.recurrence = 'none',
    this.filename,
  }) {
    // Validate using rcal API
    final validationError = Event.validate(
      title: title,
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      recurrence: recurrence,
    );
    if (validationError != null) {
      throw ArgumentError(validationError);
    }
  }

  /// Validates event fields using the rcal API.
  /// Returns null if valid, or an error message string if invalid.
  static String? validate({
    required String title,
    required DateTime startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    required String recurrence,
  }) {
    // Basic validation that can be done synchronously
    // The rcal API's validate_event will be called for more comprehensive validation
    if (title.isEmpty) return 'Title cannot be empty';
    if (title.length > 100) return 'Title must be 100 characters or less';
    if (!validRecurrences.contains(recurrence)) {
      return 'Invalid recurrence: $recurrence';
    }
    if (endDate != null && endDate.isBefore(startDate)) {
      return 'End date cannot be before start date';
    }

    // Time format validation (HH:MM)
    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (startTime != null && !timeRegex.hasMatch(startTime)) {
      return 'Invalid start time format';
    }
    if (endTime != null && !timeRegex.hasMatch(endTime)) {
      return 'Invalid end time format';
    }

    // End time must be after start time on same day when no end date
    if (startTime != null && endTime != null && endDate == null) {
      final parts1 = startTime.split(':').map(int.parse).toList();
      final parts2 = endTime.split(':').map(int.parse).toList();
      final total1 = parts1[0] * 60 + parts1[1];
      final total2 = parts2[0] * 60 + parts2[1];
      if (total2 <= total1) {
        return 'End time must be after start time on the same day';
      }
    }

    return null;
  }

  /// Validates an Event using the rcal API (async).
  /// Throws ArgumentError if validation fails.
  static Future<void> validateWithApi(Event event) async {
    // Convert DateTime to string format for the API
    final startDateStr = _dateToString(event.startDate);
    final endDateStr = event.endDate != null
        ? _dateToString(event.endDate!)
        : null;

    try {
      await rcal_api.validateEvent(
        title: event.title,
        startDate: startDateStr,
        endDate: endDateStr,
        startTime: event.startTime,
        endTime: event.endTime,
      );
    } catch (e) {
      // The rcal API throws an error with the validation message
      throw ArgumentError(e.toString());
    }
  }

  /// Converts a DateTime to YYYY-MM-DD string format.
  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Converts this Event to an EventDto for the rcal API.
  rcal_api.EventDto toEventDto({String? id}) {
    return rcal_api.EventDto(
      id:
          id ??
          title
              .replaceAll(RegExp(r'[^\w\s-]'), '')
              .replaceAll(' ', '-')
              .toLowerCase(),
      title: title,
      description: description,
      startDate: _dateToString(startDate),
      endDate: endDate != null ? _dateToString(endDate!) : null,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      recurrence: recurrence,
      isRecurringInstance: false,
    );
  }

  /// Creates an Event from an EventDto.
  factory Event.fromEventDto(rcal_api.EventDto dto) {
    // If endDate equals startDate, treat it as null
    final endDate = dto.endDate != null && dto.endDate != dto.startDate
        ? _parseDate(dto.endDate!)
        : null;

    return Event(
      title: dto.title,
      startDate: _parseDate(dto.startDate)!,
      endDate: endDate,
      startTime: dto.startTime,
      endTime: dto.endTime,
      description: dto.description,
      recurrence: dto.recurrence,
    );
  }

  /// Generates recurring event instances using rcal API.
  /// Returns list of event instances up to the end date.
  static Future<List<Event>> generateInstances(
    Event event,
    DateTime endDate,
  ) async {
    // Convert dates to string format
    final startDateStr = _dateToString(event.startDate);
    final endDateStr = _dateToString(endDate);

    // Convert event to EventDto
    final eventDto = event.toEventDto();

    try {
      final dtos = await rcal_api.generateInstances(
        events: [eventDto],
        startDate: startDateStr,
        endDate: endDateStr,
      );

      // Convert back to Event objects
      return dtos.map((dto) => Event.fromEventDto(dto)).toList();
    } catch (e) {
      // If API fails, fall back to returning just the base event
      return [event];
    }
  }

  /// Checks if an event occurs on a specific date using rcal API.
  /// Returns true if the event (or any of its recurring instances) occurs on the date.
  static Future<bool> occursOnDate(Event event, DateTime date) async {
    // Convert date to string format
    final dateStr = _dateToString(date);

    // Convert event to EventDto
    final eventDto = event.toEventDto();

    try {
      return await rcal_api.eventOccursOn(event: eventDto, date: dateStr);
    } catch (e) {
      // Fall back to basic occurrence check if API fails
      return _basicOccursOnDate(event, date);
    }
  }

  /// Basic occurrence check - used as fallback when rcal API is unavailable.
  static bool _basicOccursOnDate(Event event, DateTime date) {
    // Normalize dates to midnight for comparison
    final start = DateTime(
      event.startDate.year,
      event.startDate.month,
      event.startDate.day,
    );
    final end = event.endDate ?? event.startDate;
    final endDt = DateTime(end.year, end.month, end.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    // Check if target date falls within the event's date range
    if (targetDate.isAtSameMomentAs(start) ||
        (targetDate.isAfter(start) &&
            targetDate.isBefore(endDt.add(const Duration(days: 1))))) {
      return true;
    }

    return false;
  }

  // Check if event is all-day
  bool get isAllDay => startTime == null;

  // Get the start DateTime (combines date and time)
  DateTime get startDateTime {
    if (startTime == null) {
      return DateTime(startDate.year, startDate.month, startDate.day);
    }
    final parts = startTime!.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      hour,
      minute,
    );
  }

  // Get the end DateTime if applicable
  DateTime? get endDateTime {
    if (endDate == null && endTime == null) return null;
    final date = endDate ?? startDate;
    if (endTime == null) {
      return DateTime(date.year, date.month, date.day, 23, 59); // End of day
    }
    final parts = endTime!.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // Persistence key for rcal-lib: (title, start_date)
  // This is used as the unique identifier for events in storage.
  // Same title+date will replace existing events.
  String get persistenceKey =>
      '${title}_${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

  // Generate filename based on sanitized title
  // Note: This is now for display/identification only, not for persistence
  String get fileName {
    final sanitized = title
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove invalid chars
        .toLowerCase();
    if (sanitized.contains('..') || sanitized.startsWith('/')) {
      throw ArgumentError('Invalid title: contains invalid path characters');
    }
    return '$sanitized.md';
  }

  // Create from rcal markdown format
  factory Event.fromMarkdown(String markdown, String filename) {
    print('DEBUG fromMarkdown: filename=$filename');
    log('DEBUG fromMarkdown: filename=$filename');
    try {
      final lines = markdown.split('\n');
      String title = '';
      DateTime? startDate;
      DateTime? endDate;
      String? startTime;
      String? endTime;
      String description = '';
      String recurrence = 'none';

      for (final line in lines) {
        final trimmed = line.trim();
        print('DEBUG: Processing line: "$trimmed"');
        if (trimmed.startsWith('# Event: ')) {
          title = trimmed.substring(9).trim();
        } else if (trimmed.startsWith('- **Date**: ')) {
          final dateStr = trimmed.substring(11).trim();
          final parts = dateStr.split(' to ');
          startDate = _parseDate(parts[0]);
          if (parts.length > 1) endDate = _parseDate(parts[1]);
        } else if (trimmed.startsWith('- **Start Time**: ')) {
          print('DEBUG: Matched new time format');
          // New format
          log('DEBUG: New time format matched, trimmed = "$trimmed"');
          final timeStr = trimmed.substring(17).trim();
          if (timeStr == 'all-day') {
            startTime = null;
            endTime = null;
          } else {
            // Use regex to handle flexible spacing around "to"
            final timeRangeMatch = RegExp(
              r'^(\d{2}:\d{2})\s*to\s*(\d{2}:\d{2})$',
            ).firstMatch(timeStr);
            if (timeRangeMatch != null) {
              startTime = timeRangeMatch.group(1);
              endTime = timeRangeMatch.group(2);
            } else {
              // Fallback to simple split for backward compatibility
              final parts = timeStr.split(' to ');
              startTime = parts[0].trim();
              if (parts.length > 1) endTime = parts[1].trim();
            }
          }
        } else if (trimmed.startsWith('- **Time**: ') ||
            trimmed.startsWith('- **Time**:')) {
          print('DEBUG: Matched deprecated time format!');
          print('DEBUG: Deprecated time format matched, trimmed = "$trimmed"');
          log('DEBUG: Deprecated time format matched, trimmed = "$trimmed"');
          log(
            'Warning: Deprecated time format detected. Please use "- **Start Time**: " instead.',
          );
          // Handle both "- **Time**: " (with space) and "- **Time**:" (without space)
          final timeStr = trimmed.startsWith('- **Time**: ')
              ? trimmed.substring(11).trim()
              : trimmed.substring(10).trim();
          print('DEBUG: timeStr = "$timeStr"');
          print(
            'DEBUG: trimmed.startsWith("- **Time**: ") = ${trimmed.startsWith("- **Time**: ")}',
          );
          log('DEBUG: timeStr = "$timeStr"');
          if (timeStr == 'all-day') {
            startTime = null;
            endTime = null;
          } else {
            // Use regex to handle flexible spacing around "to"
            final timeRangeMatch = RegExp(
              r'^(\d{2}:\d{2})\s*to\s*(\d{2}:\d{2})$',
            ).firstMatch(timeStr);
            if (timeRangeMatch != null) {
              startTime = timeRangeMatch.group(1);
              endTime = timeRangeMatch.group(2);
            } else {
              // Fallback to simple split for backward compatibility
              final parts = timeStr.split(' to ');
              startTime = parts[0].trim();
              if (parts.length > 1) endTime = parts[1].trim();
            }
          }
        } else if (trimmed.startsWith('- **Description**: ')) {
          description = trimmed.substring(18).trim();
        } else if (trimmed.startsWith('- **Recurrence**: ')) {
          recurrence = trimmed.substring(17).trim();
        }
      }

      if (startDate == null) {
        throw FormatException('Invalid event markdown: missing start date');
      }
      if (endDate != null && endDate.isBefore(startDate)) {
        throw FormatException('End date before start date');
      }

      // Validate times using the time regex
      final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
      if (startTime != null && !timeRegex.hasMatch(startTime)) {
        throw FormatException('Invalid start time format');
      }
      if (endTime != null && !timeRegex.hasMatch(endTime)) {
        throw FormatException('Invalid end time format');
      }
      if (!validRecurrences.contains(recurrence)) recurrence = 'none';

      // Generate title-based filename from the parsed title
      // Note: ID is no longer stored in files - filename is derived from title
      final event = Event(
        title: title,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        description: description,
        recurrence: recurrence,
      );

      // Return event with title-based filename
      return event.copyWith(filename: event.fileName);
    } catch (e) {
      log('Error parsing event markdown: $e');
      rethrow;
    }
  }

  /// Parses a date string in YYYY-MM-DD format to DateTime.
  /// Returns null if the date string is invalid.
  static DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      // Validate range
      if (year < minYear ||
          year > maxYear ||
          month < 1 ||
          month > 12 ||
          day < 1 ||
          day > 31) {
        return null;
      }
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  // Convert to rcal markdown format
  String toMarkdown() {
    final dateStr = endDate == null
        ? '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}'
        : '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')} to ${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';

    final timeStr = startTime == null
        ? 'all-day'
        : endTime == null
        ? startTime!
        : '$startTime to $endTime';

    return '''# Event: $title

- **Date**: $dateStr
- **Start Time**: $timeStr
- **Description**: $description
- **Recurrence**: $recurrence
''';
  }

  Event copyWith({
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    String? description,
    String? recurrence,
    String? filename,
  }) {
    return Event(
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      recurrence: recurrence ?? this.recurrence,
      filename: filename ?? this.filename,
    );
  }

  @override
  String toString() {
    return 'Event(title: $title, startDate: $startDate, endDate: $endDate, startTime: $startTime, endTime: $endTime, description: $description, recurrence: $recurrence, filename: $filename)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // Note: filename is NOT included in equality since it's now display-only
    // The persistence key is (title, startDate)
    return other is Event &&
        other.title == title &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.description == description &&
        other.recurrence == recurrence;
  }

  @override
  int get hashCode =>
      title.hashCode ^
      startDate.hashCode ^
      (endDate?.hashCode ?? 0) ^
      (startTime?.hashCode ?? 0) ^
      (endTime?.hashCode ?? 0) ^
      description.hashCode ^
      recurrence.hashCode;
}
