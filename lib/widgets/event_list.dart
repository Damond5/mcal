import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import 'event_form_dialog.dart';

class EventList extends StatelessWidget {
  final DateTime selectedDate;

  const EventList({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final events = eventProvider.getEventsForDate(selectedDate);
        log('Building EventList for $selectedDate with ${events.length} events');

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
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: ListTile(
                title: Text(event.title),
                subtitle: Text(
                  _formatEventTime(event) +
                      (event.description.isNotEmpty
                          ? ' - ${event.description}'
                          : ''),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      _showDeleteDialog(context, eventProvider, event),
                ),
                onTap: () => _showEventDetails(context, event, eventProvider),
              ),
            );
          },
        );
      },
    );
  }

  String _formatEventTime(Event event) {
    if (event.isAllDay) {
      if (event.endDate == null) {
        return 'All day';
      } else {
        return 'All day (${event.startDate.month}/${event.startDate.day} - ${event.endDate!.month}/${event.endDate!.day})';
      }
    } else {
      final start =
          '${event.startTime!.split(':')[0]}:${event.startTime!.split(':')[1]}';
      if (event.endTime != null) {
        final end =
            '${event.endTime!.split(':')[0]}:${event.endTime!.split(':')[1]}';
        return '$start - $end';
      } else {
        return start;
      }
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    EventProvider eventProvider,
    Event event,
  ) {
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
              eventProvider.deleteEvent(event);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(
    BuildContext context,
    Event event,
    EventProvider eventProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${event.startDate.month}/${event.startDate.day}/${event.startDate.year}${event.endDate != null ? ' - ${event.endDate!.month}/${event.endDate!.day}/${event.endDate!.year}' : ''}',
            ),
            const SizedBox(height: 8),
            Text('Time: ${_formatEventTime(event)}'),
            const SizedBox(height: 8),
            if (event.description.isNotEmpty) ...[
              Text('Description: ${event.description}'),
              const SizedBox(height: 8),
            ],
            if (event.recurrence != 'none')
              Text('Recurrence: ${event.recurrence}'),
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
              showDialog(
                context: context,
                builder: (context) => EventFormDialog(
                  event: event,
                  onSave: (updated) =>
                      eventProvider.updateEvent(event, updated),
                ),
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}
