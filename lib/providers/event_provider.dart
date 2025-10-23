import "package:flutter/material.dart";
import "../models/event.dart";
import "../services/event_storage.dart";
import "../services/sync_service.dart";

class EventProvider extends ChangeNotifier {
  final EventStorage _storage = EventStorage();
  final SyncService _syncService = SyncService();
  final Map<DateTime, List<Event>> _events = {};
  bool _isLoading = false;
  bool _isSyncing = false;
  DateTime? _selectedDate;

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
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

  Future<void> syncInit(String url) async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();
    try {
      await _syncService.initSync(url);
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncPull() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();
    try {
      await _syncService.pullSync();
      // Reload events after pull
      _events.clear();
      await loadAllEventDates();
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      rethrow;
    }
    _isSyncing = false;
    notifyListeners();
  }

  Future<void> syncPush() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();
    try {
      await _syncService.pushSync();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<String> syncStatus() async {
    if (_isSyncing) return "syncing";
    _isSyncing = true;
    notifyListeners();
    try {
      return await _syncService.getSyncStatus();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}