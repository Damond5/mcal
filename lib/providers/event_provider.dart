import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_storage.dart';

class EventProvider extends ChangeNotifier {
  final EventStorage _storage = EventStorage();
  final Map<DateTime, List<Event>> _events = {};
  bool _isLoading = false;
  DateTime? _selectedDate;

  bool get isLoading => _isLoading;
  Map<DateTime, List<Event>> get events => _events;
  DateTime? get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<Event> getEventsForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _events[key] ?? [];
  }

  Future<void> loadEventsForDate(DateTime date) async {
    final key = DateTime(date.year, date.month, date.day);
    if (_events.containsKey(key)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final loadedEvents = await _storage.loadEvents(date);
      _events[key] = loadedEvents;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEvent(Event event) async {
    final key = DateTime(event.date.year, event.date.month, event.date.day);
    await _storage.addEvent(event);

    if (_events.containsKey(key)) {
      _events[key]!.add(event);
    } else {
      _events[key] = [event];
    }

    notifyListeners();
  }

  Future<void> updateEvent(Event event) async {
    final key = DateTime(event.date.year, event.date.month, event.date.day);
    await _storage.updateEvent(event);

    if (_events.containsKey(key)) {
      final index = _events[key]!.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[key]![index] = event;
      }
    }

    notifyListeners();
  }

  Future<void> deleteEvent(String eventId, DateTime date) async {
    final key = DateTime(date.year, date.month, date.day);
    await _storage.deleteEvent(eventId, date);

    if (_events.containsKey(key)) {
      _events[key]!.removeWhere((e) => e.id == eventId);
    }

    notifyListeners();
  }

  Future<void> loadAllEventDates() async {
    final dates = await _storage.getEventDates();
    for (final date in dates) {
      if (!_events.containsKey(date)) {
        await loadEventsForDate(date);
      }
    }
  }
}