   import "package:flutter/material.dart";
import "dart:async";
import "dart:io";
import "dart:developer";
import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";
import "package:workmanager/workmanager.dart";
import "../models/event.dart";
import "../models/sync_settings.dart";
import "../services/event_storage.dart";
import "../services/sync_service.dart";
import "../services/notification_service.dart";

class EventProvider extends ChangeNotifier {
  final EventStorage _storage = EventStorage();
  final SyncService _syncService = SyncService();
  final NotificationService _notificationService = NotificationService();
  List<Event> _allEvents = [];
  Set<DateTime> _eventDates = {};
  bool _isLoading = false;
  bool _isSyncing = false;
  DateTime? _selectedDate;
  int _refreshCounter = 0;
  Timer? _notificationTimer;
  final Set<String> _notifiedIds = {};
  SyncSettings _syncSettings = const SyncSettings();
  DateTime? _lastSyncTime;
  Timer? _periodicSyncTimer;

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  DateTime? get selectedDate => _selectedDate;
  int get refreshCounter => _refreshCounter;
  SyncSettings get syncSettings => _syncSettings;
  Set<DateTime> get eventDates => _eventDates;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void _computeEventDates() {
    _eventDates = Event.getAllEventDates(_allEvents);
  }

  Future<void> loadSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('syncSettings');
    if (settingsJson != null) {
      _syncSettings = SyncSettings.fromJson(jsonDecode(settingsJson));
    }
    _lastSyncTime = DateTime.tryParse(prefs.getString('lastSyncTime') ?? '');
    notifyListeners();
  }

  Future<void> saveSyncSettings(SyncSettings settings) async {
    _syncSettings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('syncSettings', jsonEncode(settings.toJson()));
    notifyListeners();
    _updatePeriodicSync();
  }

  void _updatePeriodicSync() {
    _periodicSyncTimer?.cancel();
    if (Platform.isLinux) {
      if (_syncSettings.autoSyncEnabled) {
        _periodicSyncTimer = Timer.periodic(
          Duration(minutes: _syncSettings.syncFrequencyMinutes),
          (_) => autoSyncPeriodic(),
        );
      }
    } else {
      if (_syncSettings.autoSyncEnabled) {
        Workmanager().registerPeriodicTask(
          'periodicSync',
          'sync',
          frequency: Duration(minutes: _syncSettings.syncFrequencyMinutes),
        );
      } else {
        Workmanager().cancelByUniqueName('periodicSync');
      }
    }
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
      _computeEventDates();
      await loadSyncSettings();
      // Schedule notifications for all loaded events
      for (final event in _allEvents) {
        if (!Platform.isLinux) {
          await _notificationService.scheduleNotificationForEvent(event);
        }
      }
      if (Platform.isLinux) {
        _startNotificationTimer();
        _updatePeriodicSync();
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
      final filename = await _storage.addEvent(event);
      final eventWithFilename = event.copyWith(filename: filename);
      _allEvents.add(eventWithFilename);
      _computeEventDates();
      if (!Platform.isLinux) {
        await _notificationService.scheduleNotificationForEvent(eventWithFilename);
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
      final newFilename = await _storage.updateEvent(oldEvent, newEvent);
      final index = _allEvents.indexWhere((e) => e == oldEvent);
      final newEventWithFilename = newEvent.copyWith(filename: newFilename);
      if (index != -1) {
        _allEvents[index] = newEventWithFilename;
      }
      _computeEventDates();
      if (!Platform.isLinux) {
        await _notificationService.scheduleNotificationForEvent(newEventWithFilename);
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
      _computeEventDates();
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
    return _eventDates;
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
    if (await _syncService.isSyncInitialized() && _syncSettings.resumeSyncEnabled) {
      try {
        await syncPull();
      } catch (e) {
        log('Auto pull failed: $e');
      }
    }
  }

  Future<void> autoSyncPeriodic() async {
    if (await _syncService.isSyncInitialized() && _syncSettings.autoSyncEnabled) {
      final now = DateTime.now();
      if (_lastSyncTime == null || now.difference(_lastSyncTime!).inMinutes >= _syncSettings.syncFrequencyMinutes) {
        try {
          await syncPull();
          _lastSyncTime = now;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('lastSyncTime', now.toIso8601String());
        } catch (e) {
          log('Auto periodic pull failed: $e');
        }
      }
    }
  }

  Future<void> autoSyncOnResume() async {
    if (await _syncService.isSyncInitialized() && _syncSettings.resumeSyncEnabled) {
      final now = DateTime.now();
      if (_lastSyncTime == null || now.difference(_lastSyncTime!).inMinutes > 5) {
        try {
          await syncPull();
          _lastSyncTime = now;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('lastSyncTime', now.toIso8601String());
        } catch (e) {
          log('Auto resume pull failed: $e');
        }
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
          notificationTime = DateTime(dayBefore.year, dayBefore.month, dayBefore.day, Event.allDayNotificationHour, 0);
        } else {
          notificationTime = instance.startDateTime.subtract(const Duration(minutes: Event.notificationOffsetMinutes));
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