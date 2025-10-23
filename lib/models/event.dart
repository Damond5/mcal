import 'package:uuid/uuid.dart';

class Event {
  final String id;
  final String title;
  final DateTime time; // Full DateTime including date and time
  final String description;
  final DateTime date; // The day of the event (date part only)

  Event({
    String? id,
    required this.title,
    required this.time,
    required this.description,
    required this.date,
  }) : id = id ?? const Uuid().v4();

  // Get the date part from time if not provided separately
  DateTime get eventDate => DateTime(date.year, date.month, date.day);

  // Create from markdown section
  factory Event.fromMarkdown(String markdown, DateTime date) {
    final lines = markdown.split('\n');
    String title = '';
    DateTime time = date;
    String description = '';

    for (final line in lines) {
      if (line.startsWith('## ')) {
        title = line.substring(3).trim();
      } else if (line.startsWith('Time: ')) {
        final timeStr = line.substring(6).trim();
        try {
          final timeParts = timeStr.split(':');
          if (timeParts.length == 2) {
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            time = DateTime(date.year, date.month, date.day, hour, minute);
          }
        } catch (e) {
          // Invalid time, use default
        }
      } else if (line.startsWith('Description: ')) {
        description = line.substring(13).trim();
      }
    }

    return Event(
      title: title,
      time: time,
      description: description,
      date: date,
    );
  }

  // Convert to markdown section
  String toMarkdown() {
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return '## $title\nTime: $timeStr\nDescription: $description\n';
  }

  Event copyWith({
    String? id,
    String? title,
    DateTime? time,
    String? description,
    DateTime? date,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, time: $time, description: $description, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}