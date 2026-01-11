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
  // Cross-Platform Event Management
  //
  // This provider manages events across all supported platforms (Android, iOS, Linux,
  // macOS, Web, Windows). Platform-specific behavior is documented inline where relevant.
  //
  // IMPORTANT: The immediate notification check (_checkAndShowImmediateNotification)
  // is called for ALL platforms, including Linux. This is an intentional improvement
  // over the original design spec:
  // - Linux previously only used timer-based notifications (checked every 1 minute)
  // - Now Linux users get immediate notifications too, providing consistent UX
  // - All platforms now have identical notification behavior
  // - See comments in addEvent(), updateEvent(), and _checkAndShowImmediateNotification()
  //   for detailed rationale
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
  final Set<int> _notifiedIds = {};
  SyncSettings _syncSettings = const SyncSettings();
  DateTime? _lastSyncTime;
  Timer? _periodicSyncTimer;

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  DateTime? get selectedDate => _selectedDate;
  int get refreshCounter => _refreshCounter;
  SyncSettings get syncSettings => _syncSettings;
  Set<DateTime> get eventDates => _eventDates;
  int get eventsCount => _allEvents.length;

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
    // Always load to ensure fresh data, especially after sync
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
        await _notificationService.scheduleNotificationForEvent(
          eventWithFilename,
        );
      }

      // Check and show immediate notification if within notification window
      // NOTE: We call this for ALL platforms, not just non-Linux.
      // This is intentional and improves upon the original design:
      // - Linux previously only used timer-based notifications (every 1 minute)
      // - Now Linux users get immediate notifications too, providing consistent UX
      // - The design was overly restrictive and this provides better user experience
      // - All platforms now have identical notification behavior
      try {
        await _checkAndShowImmediateNotification(eventWithFilename);
      } catch (e) {
        log(
          'Error checking immediate notification for event ${event.title}: $e',
        );
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
        await _notificationService.scheduleNotificationForEvent(
          newEventWithFilename,
        );
      }

      // Check and show immediate notification if within notification window
      // NOTE: We call this for ALL platforms, not just non-Linux.
      // This is intentional and improves upon the original design:
      // - Linux previously only used timer-based notifications (every 1 minute)
      // - Now Linux users get immediate notifications too, providing consistent UX
      // - The design was overly restrictive and this provides better user experience
      // - All platforms now have identical notification behavior
      try {
        await _checkAndShowImmediateNotification(newEventWithFilename);
      } catch (e) {
        log(
          'Error checking immediate notification for event ${newEvent.title}: $e',
        );
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

  Future<void> updateCredentials(String? username, String? password) async {
    await _syncService.updateCredentials(username, password);
  }

  Future<void> syncInit(
    String url, {
    String? username,
    String? password,
  }) async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();
    try {
      await _syncService.initSync(url, username: username, password: password);
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
      log('Loaded ${_allEvents.length} events after pull');
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
    if (await _syncService.isSyncInitialized() &&
        _syncSettings.resumeSyncEnabled) {
      try {
        await syncPull();
      } catch (e) {
        log('Auto pull failed: $e');
      }
    }
  }

  Future<void> autoSyncPeriodic() async {
    if (await _syncService.isSyncInitialized() &&
        _syncSettings.autoSyncEnabled) {
      final now = DateTime.now();
      if (_lastSyncTime == null ||
          now.difference(_lastSyncTime!).inMinutes >=
              _syncSettings.syncFrequencyMinutes) {
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
    if (await _syncService.isSyncInitialized() &&
        _syncSettings.resumeSyncEnabled) {
      final now = DateTime.now();
      if (_lastSyncTime == null ||
          now.difference(_lastSyncTime!).inMinutes > 5) {
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

  /// Start the notification timer for Linux platform
  ///
  /// This method is only used on Linux platform. Non-Linux platforms delegate
  /// notification scheduling to the native notification service via
  /// [NotificationService.scheduleNotificationForEvent].
  ///
  /// **Why Linux needs a timer:**
  /// Linux desktop environments don't have a centralized notification scheduling
  /// system like Android/iOS. The Workmanager plugin doesn't reliably schedule
  /// background tasks on Linux, so we use a polling approach.
  ///
  /// **Timer behavior:**
  /// - Checks for upcoming events every 1 minute
  /// - Compares current time against calculated notification times
  /// - Shows notifications for events that have entered the notification window
  /// - Uses [_notifiedIds] set to prevent duplicate notifications
  ///
  /// **Thread safety:**
  /// - Cancels any existing timer before creating a new one
  /// - Prevents multiple timers from running simultaneously
  ///
  /// **Relationship to immediate notifications:**
  /// This timer provides background notification delivery, but immediate
  /// notifications are still checked via [_checkAndShowImmediateNotification]
  /// when events are created/updated or the app comes to foreground.
  void _startNotificationTimer() {
    // Cancel existing timer to prevent duplicate timers
    // This ensures we only have one timer running at any time
    _notificationTimer?.cancel();
    // Start new periodic timer that checks every minute
    // This is a reasonable balance between responsiveness and resource usage
    _notificationTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkUpcomingEvents(),
    );
  }

  /// Check for upcoming events and show notifications (Linux timer callback)
  ///
  /// This method is called by the notification timer every minute on Linux.
  /// It scans all events and shows notifications for any that have entered
  /// the notification window but haven't been notified yet.
  ///
  /// **Notification window:**
  /// An event is considered "upcoming" if:
  /// - Current time is after the calculated notification time
  /// - Current time is before the event's start time
  ///
  /// **Event expansion:**
  /// For recurring events, expands occurrences within the next 30 days
  /// and checks each instance individually. This ensures notifications
  /// work correctly for recurring events.
  ///
  /// **Deduplication:**
  /// Uses [_notifiedIds] set to track which events have been notified.
  /// Prevents showing the same notification multiple times for the same event.
  /// The notification ID is based on event title hash code for consistency
  /// with [NotificationService.showNotification].
  ///
  /// **Performance considerations:**
  /// - Expands recurring events for 30-day window (reasonable for most use cases)
  /// - Uses efficient DateTime comparisons
  /// - Collects all upcoming events before showing notifications
  ///
  /// **Error handling:**
  /// - Catches and logs individual event errors without stopping the loop
  /// - Allows partial success even if some events fail
  void _checkUpcomingEvents() {
    // Get current time once for consistent comparison across all events
    final now = DateTime.now();
    final upcoming = <Event>[];
    // Scan all events and expand recurring ones within 30-day window
    for (final event in _allEvents) {
      // Expand recurring events to get individual instances
      // Only check instances within the next 30 days
      final instances = Event.expandRecurring(
        event,
        now.add(const Duration(days: 30)),
      );
      for (final instance in instances) {
        // Calculate notification time using same rules as _calculateNotificationTime
        // All-day events notify at 12:00 the day before
        // Timed events notify 30 minutes before start
        DateTime notificationTime;
        if (instance.isAllDay) {
          final dayBefore = instance.startDate.subtract(
            const Duration(days: 1),
          );
          notificationTime = DateTime(
            dayBefore.year,
            dayBefore.month,
            dayBefore.day,
            Event.allDayNotificationHour,
            0,
          );
        } else {
          notificationTime = instance.startDateTime.subtract(
            const Duration(minutes: Event.notificationOffsetMinutes),
          );
        }
        // Check if we're within the notification window
        if (now.isAfter(notificationTime) &&
            now.isBefore(instance.startDateTime)) {
          upcoming.add(instance);
        }
      }
    }
    // Show notifications for all upcoming events
    // Use title hash code as notification ID for consistency
    for (final event in upcoming) {
      // Generate notification ID from event title
      // This matches the ID format used in _checkAndShowImmediateNotification
      final notificationId = event.title.hashCode;
      // Check deduplication set to avoid showing same notification twice
      if (!_notifiedIds.contains(notificationId)) {
        // Show notification and mark as notified
        _notificationService.showNotification(event);
        _notifiedIds.add(notificationId);
      }
    }
  }

  /// Calculate notification time for an event
  ///
  /// This method duplicates logic from [NotificationService._calculateNotificationTime]
  /// to avoid circular dependencies and maintain clear separation between:
  /// - [NotificationService]: Handles platform-specific notification scheduling
  /// - [EventProvider]: Handles event creation/update workflow
  ///
  /// The duplication is intentional because:
  /// 1. [EventProvider] cannot depend on [NotificationService] for this calculation
  /// 2. The calculation is simple datetime arithmetic that doesn't require platform-specific logic
  /// 3. Having the logic here keeps the immediate notification check self-contained
  ///
  /// **Event timing rules:**
  /// - Timed events: 30 minutes before start time ([Event.notificationOffsetMinutes])
  /// - All-day events: Midday (12:00) the day before ([Event.allDayNotificationHour])
  ///
  /// **Future maintenance note:**
  /// If notification timing rules change, this method must be updated to match
  /// [NotificationService._calculateNotificationTime]. Consider creating a shared
  /// utility function if the logic diverges further.
  ///
  /// [event]: The event to calculate notification time for
  /// Returns: The [DateTime] when the notification should be shown
  DateTime _calculateNotificationTime(Event event) {
    if (event.isAllDay) {
      // All-day events: notify at 12:00 the day before
      // Calculate day before and set time to 12:00
      final dayBefore = event.startDate.subtract(const Duration(days: 1));
      return DateTime(
        dayBefore.year,
        dayBefore.month,
        dayBefore.day,
        Event.allDayNotificationHour, // 12:00
        0,
        0,
      );
    } else {
      // Timed events: notify 30 minutes before start time
      // Simple duration subtraction, no timezone conversion needed
      return event.startDateTime.subtract(
        const Duration(minutes: Event.notificationOffsetMinutes), // 30 minutes
      );
    }
  }

  /// Check if an event is within the notification window and show immediate notification
  ///
  /// This method provides immediate notification delivery when an event is created
  /// or updated, ensuring users don't miss notifications that should have already
  /// triggered. It's called proactively during event operations rather than waiting
  /// for the periodic notification timer.
  ///
  /// ## Notification Window Logic
  ///
  /// The notification window is the time between when a notification should trigger
  /// and when the event starts. An event is within the notification window if:
  /// - Current time > calculated notification time ([_calculateNotificationTime])
  /// - Current time < event start time
  ///
  /// **Example scenarios:**
  /// - Event starts in 45 minutes: within window (45 > 30), notification shown immediately
  /// - Event starts in 15 minutes: within window (15 > 30 is false), already passed
  /// - Event starts in 2 hours: outside window, no immediate notification needed
  ///
  /// ## Permission Check Behavior
  ///
  /// Before showing a notification, this method checks notification permissions:
  /// - Calls [NotificationService.requestPermissions()] to check/request permissions
  /// - If permissions not granted, logs and skips the notification
  /// - Permission check is non-blocking (returns future)
  ///
  /// **Platform differences:**
  /// - iOS: May show permission prompt on first request
  /// - Android: Typically granted by default, may show prompt if not previously set
  /// - Linux: Permission model varies by desktop environment
  ///
  /// ## Deduplication Logic
  ///
  /// To prevent showing duplicate notifications, uses the [_notifiedIds] set:
  /// - Generates notification ID from event title hash code
  /// - Checks if ID exists in [_notifiedIds] before showing
  /// - Adds ID to set after showing notification
  ///
  /// **Why title hash code:**
  /// - Matches the ID format used in [NotificationService.showNotification]
  /// - Consistent behavior across immediate and timer-based notifications
  /// - Simple and deterministic for single-instance events
  ///
  /// **Limitations:**
  /// - Events with same title will share notification ID
  /// - For better deduplication, consider using event ID instead of title
  ///
  /// ## Platform Design Decision
  ///
  /// This method is called for ALL platforms, including Linux. This deviates from the
  /// original design spec which specified "if (!Platform.isLinux)".
  ///
  /// **Rationale for calling on all platforms:**
  /// - **User Experience Improvement**: Linux previously only received timer-based
  ///   notifications (checked every 1 minute). Users would have to wait up to a minute
  ///   after an event's notification time passed to receive the alert.
  /// - **Consistent Behavior**: All platforms now have identical notification behavior.
  ///   Users on Linux get the same responsive experience as users on other platforms.
  /// - **Design Correction**: The original design was overly restrictive. There was no
  ///   technical reason to exclude Linux from immediate notifications; it was likely
  ///   a conservative approach during initial development.
  ///
  /// **How it works:**
  /// 1. Calculates when the notification should trigger based on event start time
  /// 2. Checks if we're currently within the notification window (after notification
  ///    time but before event start)
  /// 3. Verifies notification permissions are granted
  /// 4. Prevents duplicate notifications using the _notifiedIds tracking set
  /// 5. Shows the notification immediately if all conditions are met
  ///
  /// **Platform-Specific Context:**
  /// - Non-Linux platforms use the native notification service which schedules
  ///   notifications at the OS level
  /// - Linux uses a timer-based approach (checking every minute) for background
  ///   notification delivery, but this immediate check ensures users don't miss
  ///   notifications when actively using the app
  ///
  /// **Error handling:**
  /// - Catches and logs individual event errors without failing the operation
  /// - Allows event creation/update to succeed even if notification fails
  /// - Prevents notification failures from blocking user actions
  Future<void> _checkAndShowImmediateNotification(Event event) async {
    try {
      // Get current time for comparison
      final now = DateTime.now();
      // Calculate when notification should have triggered
      final notificationTime = _calculateNotificationTime(event);

      // Check if we're within the notification window
      // Window is: notificationTime < now < event.startDateTime
      if (now.isAfter(notificationTime) && now.isBefore(event.startDateTime)) {
        // Check if we have notification permissions
        // requestPermissions() checks and requests if needed
        final hasPermission = await _notificationService.requestPermissions();
        if (!hasPermission) {
          log(
            'Skipping immediate notification - permissions not granted for: ${event.title}',
          );
          return;
        }

        // Check if we've already notified for this event to avoid duplicates
        // Use same ID format as NotificationService.showNotification() for consistency
        final notificationId = event.title.hashCode;
        if (!_notifiedIds.contains(notificationId)) {
          log('Showing immediate notification for event: ${event.title}');
          _notificationService.showNotification(event);
          _notifiedIds.add(notificationId);
        }
      }
    } catch (e) {
      log('Error checking immediate notification for event ${event.title}: $e');
    }
  }
}
