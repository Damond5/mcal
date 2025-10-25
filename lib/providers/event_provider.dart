   import "package:flutter/material.dart";
import "dart:async";
import "dart:io";
import "dart:developer";
import "../models/event.dart";
import "../services/event_storage.dart";
import "../services/sync_service.dart";
import "../services/notification_service.dart";

class EventProvider extends ChangeNotifier {
  final EventStorage _storage = EventStorage();
  final SyncService _syncService = SyncService();
  final NotificationService _notificationService = NotificationService();
  List<Event> _allEvents = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  DateTime? _selectedDate;
  int _refreshCounter = 0;
  Timer? _notificationTimer;
  final Set<String> _notifiedIds = {};

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  DateTime? get selectedDate => _selectedDate;
  int get refreshCounter => _refreshCounter;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<Event> getEventsForDate(DateTime date) {
    final expanded = <Event>[];
    for (final event in _allEvents) {
      expanded.addAll(Event.expandRecurring(event, date));
    }
    return expanded.where((e) => Event.occursOnDate(e, date)).toList();
  }



  Future<void> loadAllEvents() async {
    if (_allEvents.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      _allEvents = await _storage.loadAllEvents();
      // Schedule notifications for all loaded events
      for (final event in _allEvents) {
        if (!Platform.isLinux) {
          await _notificationService.scheduleNotificationForEvent(event);
        }
      }
      if (Platform.isLinux) {
        _startNotificationTimer();
      }
      _refreshCounter++;
    } catch (e) {
      log('Error loading all events: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEvent(Event event) async {
    try {
      await _storage.addEvent(event);
      _allEvents.add(event);
      if (!Platform.isLinux) {
        await _notificationService.scheduleNotificationForEvent(event);
      }
      _refreshCounter++;
      notifyListeners();
      await autoPush();
    } catch (e) {
      log('Error adding event: $e');
      rethrow;
    }
  }

  Future<void> updateEvent(Event oldEvent, Event newEvent) async {
    try {
      await _storage.updateEvent(oldEvent, newEvent);
      final index = _allEvents.indexWhere((e) => e == oldEvent);
      if (index != -1) {
        _allEvents[index] = newEvent;
      }
      if (!Platform.isLinux) {
        await _notificationService.scheduleNotificationForEvent(newEvent);
      }
      _refreshCounter++;
      notifyListeners();
      await autoPush();
    } catch (e) {
      log('Error updating event: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(Event event) async {
    try {
      await _storage.deleteEvent(event);
      _allEvents.removeWhere((e) => e == event);
      if (!Platform.isLinux) {
        await _notificationService.cancelNotificationsForEvent(event);
      }
      _refreshCounter++;
      notifyListeners();
      await autoPush();
    } catch (e) {
      log('Error deleting event: $e');
      rethrow;
    }
  }

  Future<Set<DateTime>> getEventDates() async {
    await loadAllEvents();
    final dates = <DateTime>{};

    for (final event in _allEvents) {
      final expanded = Event.expandRecurring(event, DateTime.now());
      for (final e in expanded) {
        dates.add(DateTime(e.startDate.year, e.startDate.month, e.startDate.day));
        if (e.endDate != null) {
          DateTime current = e.startDate;
          while (current.isBefore(e.endDate!) || current.isAtSameMomentAs(e.endDate!)) {
            dates.add(DateTime(current.year, current.month, current.day));
            current = current.add(const Duration(days: 1));
          }
        }
      }
    }

    return dates;
  }

  Future<void> syncInit(String url) async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();
    try {
      await _syncService.initSync(url);
    } catch (e) {
      log('Sync init failed: $e');
      rethrow;
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
      _allEvents.clear();
      await loadAllEvents();
      // _refreshCounter incremented in loadAllEvents
    } catch (e) {
       log('Sync pull failed: $e');
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
    } catch (e) {
      log('Sync push failed: $e');
      rethrow;
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
    } catch (e) {
      log('Sync status failed: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> autoSyncOnStart() async {
    if (await _syncService.isSyncInitialized()) {
      try {
        await syncPull();
      } catch (e) {
        log('Auto pull failed: $e');
      }
    }
  }

  Future<void> autoPush() async {
    if (await _syncService.isSyncInitialized()) {
      try {
        await syncPush();
      } catch (e) {
        log('Auto push failed: $e');
      }
    }
  }

  void _startNotificationTimer() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(const Duration(minutes: 1), (_) => _checkUpcomingEvents());
  }

  void _checkUpcomingEvents() {
    final now = DateTime.now();
    final upcoming = <Event>[];
    for (final event in _allEvents) {
      final instances = Event.expandRecurring(event, now.add(const Duration(days: 30)));
      for (final instance in instances) {
        DateTime notificationTime;
        if (instance.isAllDay) {
          final dayBefore = instance.startDate.subtract(const Duration(days: 1));
          notificationTime = DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 12, 0);
        } else {
          notificationTime = instance.startDateTime.subtract(const Duration(minutes: 30));
        }
        if (now.isAfter(notificationTime) && now.isBefore(instance.startDateTime)) {
          upcoming.add(instance);
        }
      }
    }
    for (final event in upcoming) {
      final id = '${event.title}_${event.startDate.millisecondsSinceEpoch}';
      if (!_notifiedIds.contains(id)) {
        _notificationService.showNotification(event);
        _notifiedIds.add(id);
      }
    }
  }
}