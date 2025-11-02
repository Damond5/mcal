import 'dart:developer';

class Event {
  static const List<String> validRecurrences = [
    'none',
    'daily',
    'weekly',
    'monthly',
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
  final String recurrence; // 'none', 'daily', 'weekly', 'monthly'
  final String? filename;

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
    if (title.isEmpty) throw ArgumentError('Title cannot be empty');
    if (title.length > 100) {
      throw ArgumentError('Title must be 100 characters or less');
    }
    if (!validRecurrences.contains(recurrence)) {
      throw ArgumentError('Invalid recurrence: $recurrence');
    }
    if (endDate != null && endDate!.isBefore(startDate)) {
      throw ArgumentError('End date cannot be before start date');
    }
    if (startTime != null && !_isValidTime(startTime!)) {
      throw ArgumentError('Invalid start time format');
    }
    if (endTime != null && !_isValidTime(endTime!)) {
      throw ArgumentError('Invalid end time format');
    }
    if (startTime != null &&
        endTime != null &&
        endDate == null &&
        _compareTimes(startTime!, endTime!) >= 0) {
      throw ArgumentError('End time must be after start time on the same day');
    }
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

  // Generate filename based on sanitized title
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
        if (trimmed.startsWith('# Event: ')) {
          title = trimmed.substring(9).trim();
        } else if (trimmed.startsWith('- **Date**: ')) {
          final dateStr = trimmed.substring(11).trim();
          final parts = dateStr.split(' to ');
          startDate = _parseDate(parts[0]);
          if (parts.length > 1) endDate = _parseDate(parts[1]);
        } else if (trimmed.startsWith('- **Time**: ')) {
          final timeStr = trimmed.substring(11).trim();
          if (timeStr == 'all-day') {
            startTime = null;
            endTime = null;
          } else {
            final parts = timeStr.split(' to ');
            startTime = parts[0];
            if (parts.length > 1) endTime = parts[1];
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
      if (startTime != null && !_isValidTime(startTime)) {
        throw FormatException('Invalid start time format');
      }
      if (endTime != null && !_isValidTime(endTime)) {
        throw FormatException('Invalid end time format');
      }
      if (!validRecurrences.contains(recurrence)) recurrence = 'none';

      return Event(
        title: title,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        description: description,
        recurrence: recurrence,
        filename: filename,
      );
    } catch (e) {
      log('Error parsing event markdown: $e');
      rethrow;
    }
  }

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

  static bool _isValidTime(String time) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  static int _compareTimes(String t1, String t2) {
    final parts1 = t1.split(':').map(int.parse).toList();
    final parts2 = t2.split(':').map(int.parse).toList();
    final total1 = parts1[0] * 60 + parts1[1];
    final total2 = parts2[0] * 60 + parts2[1];
    return total1.compareTo(total2);
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
- **Time**: $timeStr
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
    return other is Event &&
        other.title == title &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.description == description &&
        other.recurrence == recurrence &&
        other.filename == filename;
  }

  @override
  int get hashCode =>
      title.hashCode ^
      startDate.hashCode ^
      (endDate?.hashCode ?? 0) ^
      (startTime?.hashCode ?? 0) ^
      (endTime?.hashCode ?? 0) ^
      description.hashCode ^
      recurrence.hashCode ^
      (filename?.hashCode ?? 0);

  // Static utility methods for recurrence handling
  static List<Event> expandRecurring(
    Event event,
    DateTime targetDate, {
    DateTime? maxDate,
  }) {
    final instances = <Event>[];
    instances.add(event); // Base instance

    if (event.recurrence == 'none') return instances;

    // Expand up to target date for performance, capped at maxDate
    final endDate = targetDate;
    final capDate = maxDate ?? targetDate.add(const Duration(days: 365));
    DateTime current = event.startDate;

    while (current.isBefore(endDate) && current.isBefore(capDate)) {
      if (event.recurrence == 'daily') {
        current = current.add(const Duration(days: 1));
      } else if (event.recurrence == 'weekly') {
        current = current.add(const Duration(days: 7));
      } else if (event.recurrence == 'monthly') {
        // Handle invalid dates (e.g., Jan 31 -> Feb 28/29)
        final nextMonth = DateTime(current.year, current.month + 1, 1);
        final daysInNextMonth = DateTime(
          nextMonth.year,
          nextMonth.month + 1,
          0,
        ).day;
        final newDay = current.day > daysInNextMonth
            ? daysInNextMonth
            : current.day;
        current = DateTime(current.year, current.month + 1, newDay);
      } else {
        break;
      }

      if (event.endDate != null && current.isAfter(event.endDate!)) break;

      if (current.isAfter(event.startDate)) {
        instances.add(
          event.copyWith(
            title:
                '${event.title} (${current.year}-${current.month}-${current.day})', // Unique title for instance
            startDate: current,
            endDate: event.endDate != null
                ? current.add(current.difference(event.startDate))
                : null,
          ),
        );
      }
    }

    return instances;
  }

  static bool occursOnDate(Event event, DateTime date) {
    final start = DateTime(
      event.startDate.year,
      event.startDate.month,
      event.startDate.day,
    );
    final end = event.endDate ?? event.startDate;
    final endDt = DateTime(end.year, end.month, end.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isAtSameMomentAs(start) ||
        (target.isAfter(start) &&
            target.isBefore(endDt.add(const Duration(days: 1))));
  }

  static Set<DateTime> getAllEventDates(List<Event> events) {
    final dates = <DateTime>{};
    for (final event in events) {
      final expanded = Event.expandRecurring(
        event,
        DateTime.now().add(const Duration(days: 365)),
      );
      for (final e in expanded) {
        dates.add(
          DateTime(e.startDate.year, e.startDate.month, e.startDate.day),
        );
        if (e.endDate != null) {
          DateTime current = e.startDate;
          while (current.isBefore(e.endDate!) ||
              current.isAtSameMomentAs(e.endDate!)) {
            dates.add(DateTime(current.year, current.month, current.day));
            current = current.add(const Duration(days: 1));
          }
        }
      }
    }
    log('Computed event dates: ${dates.map((d) => '${d.year}-${d.month}-${d.day}').join(', ')}');
    return dates;
  }
}
