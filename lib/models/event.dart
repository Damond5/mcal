 import 'package:uuid/uuid.dart';
import 'dart:developer';

class Event {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime? endDate;
  final String? startTime; // HH:MM format or null for all-day
  final String? endTime; // HH:MM format or null
  final String description;
  final String recurrence; // 'none', 'daily', 'weekly', 'monthly'

  Event({
    String? id,
    required this.title,
    required this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.description = '',
    this.recurrence = 'none',
  }) : id = id ?? const Uuid().v4();

  // Check if event is all-day
  bool get isAllDay => startTime == null;

  // Get the start DateTime (combines date and time)
  DateTime get startDateTime {
    if (startTime == null) return DateTime(startDate.year, startDate.month, startDate.day);
    final parts = startTime!.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(startDate.year, startDate.month, startDate.day, hour, minute);
  }

  // Get the end DateTime if applicable
  DateTime? get endDateTime {
    if (endDate == null && endTime == null) return null;
    final date = endDate ?? startDate;
    if (endTime == null) return DateTime(date.year, date.month, date.day, 23, 59); // End of day
    final parts = endTime!.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // Generate filename based on sanitized title
  String get fileName {
    final sanitized = title
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove invalid chars
        .replaceAll(RegExp(r'\s+'), '_') // Spaces to underscores
        .toLowerCase();
    return '$sanitized.md';
  }

  // Create from rcal markdown format
  factory Event.fromMarkdown(String markdown) {
    try {
      final lines = markdown.split('\n');
      String id = '';
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
        } else if (trimmed.startsWith('- **ID**: ')) {
          id = trimmed.substring(9).trim();
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

      if (startDate == null) throw FormatException('Invalid event markdown: missing start date');
      if (endDate != null && endDate.isBefore(startDate)) throw FormatException('End date before start date');
    if (startTime != null && !_isValidTime(startTime)) throw FormatException('Invalid start time format');
    if (endTime != null && !_isValidTime(endTime)) throw FormatException('Invalid end time format');
      if (!['none', 'daily', 'weekly', 'monthly'].contains(recurrence)) recurrence = 'none';

      return Event(
        id: id.isNotEmpty ? id : null,
        title: title,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        description: description,
        recurrence: recurrence,
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
      if (year < 1900 || year > 2100 || month < 1 || month > 12 || day < 1 || day > 31) return null;
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  static bool _isValidTime(String time) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
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

- **ID**: $id
- **Date**: $dateStr
- **Time**: $timeStr
- **Description**: $description
- **Recurrence**: $recurrence
''';
  }

  Event copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    String? description,
    String? recurrence,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      recurrence: recurrence ?? this.recurrence,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, startDate: $startDate, endDate: $endDate, startTime: $startTime, endTime: $endTime, description: $description, recurrence: $recurrence)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Static utility methods for recurrence handling
  static List<Event> expandRecurring(Event event, DateTime targetDate) {
    final instances = <Event>[];
    instances.add(event); // Base instance

    if (event.recurrence == 'none') return instances;

    // Expand up to target date for performance
    final endDate = targetDate;
    DateTime current = event.startDate;

    while (current.isBefore(endDate)) {
      if (event.recurrence == 'daily') {
        current = current.add(const Duration(days: 1));
      } else if (event.recurrence == 'weekly') {
        current = current.add(const Duration(days: 7));
      } else if (event.recurrence == 'monthly') {
        // Handle invalid dates (e.g., Jan 31 -> Feb 28/29)
        final nextMonth = DateTime(current.year, current.month + 1, 1);
        final daysInNextMonth = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
        final newDay = current.day > daysInNextMonth ? daysInNextMonth : current.day;
        current = DateTime(current.year, current.month + 1, newDay);
      } else {
        break;
      }

      if (current.isAfter(event.startDate)) {
        instances.add(event.copyWith(
          id: '${event.id}_${current.millisecondsSinceEpoch}', // Unique id for instance
          startDate: current,
          endDate: event.endDate != null ? current.add(current.difference(event.startDate)) : null,
        ));
      }
    }

    return instances;
  }

  static bool occursOnDate(Event event, DateTime date) {
    final start = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
    final end = event.endDate ?? event.startDate;
    final endDt = DateTime(end.year, end.month, end.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isAtSameMomentAs(start) || (target.isAfter(start) && target.isBefore(endDt.add(const Duration(days: 1))));
  }
}