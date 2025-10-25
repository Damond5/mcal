import 'package:flutter/material.dart';
import '../models/event.dart';

class EventFormDialog extends StatefulWidget {
  final Event? event; // null for add, existing for edit
  final Function(Event) onSave;

  const EventFormDialog({super.key, this.event, required this.onSave});

  @override
  EventFormDialogState createState() => EventFormDialogState();
}

class EventFormDialogState extends State<EventFormDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime selectedStartDate;
  DateTime? selectedEndDate;
  String? selectedStartTime;
  String? selectedEndTime;
  late String selectedRecurrence;
  late bool isAllDay;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    titleController = TextEditingController(text: event?.title ?? '');
    descriptionController = TextEditingController(text: event?.description ?? '');
    selectedStartDate = event?.startDate ?? DateTime.now();
    selectedEndDate = event?.endDate;
    selectedStartTime = event?.startTime;
    selectedEndTime = event?.endTime;
    selectedRecurrence = event?.recurrence ?? 'none';
    isAllDay = event?.isAllDay ?? false;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _toggleAllDay(bool value) {
    setState(() {
      isAllDay = value;
      if (isAllDay) {
        selectedStartTime = null;
        selectedEndTime = null;
      }
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? selectedStartDate : (selectedEndDate ?? selectedStartDate);
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          selectedStartDate = date;
          if (selectedEndDate != null && selectedEndDate!.isBefore(date)) {
            selectedEndDate = date;
          }
        } else {
          selectedEndDate = date;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart
        ? (selectedStartTime != null
            ? TimeOfDay(hour: int.parse(selectedStartTime!.split(':')[0]), minute: int.parse(selectedStartTime!.split(':')[1]))
            : TimeOfDay.now())
        : (selectedEndTime != null
            ? TimeOfDay(hour: int.parse(selectedEndTime!.split(':')[0]), minute: int.parse(selectedEndTime!.split(':')[1]))
            : TimeOfDay.now());
    final time = await showTimePicker(context: context, initialTime: initial);
    if (time != null) {
      final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          selectedStartTime = timeStr;
        } else {
          selectedEndTime = timeStr;
        }
      });
    }
  }

  bool _validate() {
    if (titleController.text.trim().isEmpty) {
      setState(() => errorMessage = 'Title is required');
      return false;
    }
    if (selectedEndDate != null && selectedEndDate!.isBefore(selectedStartDate)) {
      setState(() => errorMessage = 'End date must be after start date');
      return false;
    }
    if (!isAllDay && selectedStartTime == null) {
      setState(() => errorMessage = 'Start time is required for timed events');
      return false;
    }
    setState(() => errorMessage = null);
    return true;
  }

  void _save() {
    if (!_validate()) return;

    final event = Event(
      id: widget.event?.id,
      title: titleController.text.trim(),
      startDate: selectedStartDate,
      endDate: selectedEndDate,
      startTime: selectedStartTime,
      endTime: selectedEndTime,
      description: descriptionController.text.trim(),
      recurrence: selectedRecurrence,
    );
    widget.onSave(event);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title *'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Start Date: '),
                TextButton(
                  onPressed: () => _pickDate(true),
                  child: Text('${selectedStartDate.month}/${selectedStartDate.day}/${selectedStartDate.year}'),
                ),
              ],
            ),
            Row(
              children: [
                const Text('End Date: '),
                TextButton(
                  onPressed: () => _pickDate(false),
                  child: Text(selectedEndDate != null ? '${selectedEndDate!.month}/${selectedEndDate!.day}/${selectedEndDate!.year}' : 'None'),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => selectedEndDate = null),
                ),
              ],
            ),
            CheckboxListTile(
              title: const Text('All Day'),
              value: isAllDay,
              onChanged: (value) => _toggleAllDay(value ?? false),
            ),
            if (!isAllDay) ...[
              Row(
                children: [
                  const Text('Start Time: '),
                  TextButton(
                    onPressed: () => _pickTime(true),
                    child: Text(selectedStartTime ?? 'Select'),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('End Time: '),
                  TextButton(
                    onPressed: () => _pickTime(false),
                    child: Text(selectedEndTime ?? 'None'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => selectedEndTime = null),
                  ),
                ],
              ),
            ],
            DropdownButtonFormField<String>(
              initialValue: selectedRecurrence,
              decoration: const InputDecoration(labelText: 'Recurrence'),
              items: ['none', 'daily', 'weekly', 'monthly'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (value) => setState(() => selectedRecurrence = value ?? 'none'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}