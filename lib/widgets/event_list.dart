import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class EventList extends StatelessWidget {
  final DateTime selectedDate;

  const EventList({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final events = eventProvider.getEventsForDate(selectedDate);

        if (events.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No events for this day'),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: ListTile(
                title: Text(event.title),
                subtitle: Text('${event.time.hour}:${event.time.minute.toString().padLeft(2, '0')} - ${event.description}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteDialog(context, eventProvider, event),
                ),
                onTap: () => _showEventDetails(context, event, eventProvider),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, EventProvider eventProvider, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              eventProvider.deleteEvent(event.id, event.date);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(BuildContext context, Event event, EventProvider eventProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${event.time.hour}:${event.time.minute.toString().padLeft(2, '0')}'),
            const SizedBox(height: 8),
            Text('Description: ${event.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditEventDialog(context, event, eventProvider);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, Event event, EventProvider eventProvider) {
    final titleController = TextEditingController(text: event.title);
    final descriptionController = TextEditingController(text: event.description);
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(event.time);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Time: '),
                TextButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      selectedTime = time;
                    }
                  },
                  child: Text('${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                ),
              ],
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedTime = DateTime(
                event.date.year,
                event.date.month,
                event.date.day,
                selectedTime.hour,
                selectedTime.minute,
              );
              final updatedEvent = event.copyWith(
                title: titleController.text,
                time: updatedTime,
                description: descriptionController.text,
              );
              eventProvider.updateEvent(updatedEvent);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}