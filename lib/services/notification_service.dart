import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'dart:developer';
import 'dart:io';
import '../models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Set<String> _scheduledNotificationIds = {};

  Future<void> initialize() async {
    log('NotificationService.initialize() called');
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    try {
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (response) {
          // Handle notification tap - could navigate to event, but for now just log
          log('Notification tapped: ${response.payload}');
        },
      );
      log('NotificationService initialized');
    } catch (e, stack) {
      log('Failed to initialize NotificationService: $e');
      log('Stack trace: $stack');
      rethrow;
    }
  }

  Future<bool> requestPermissions() async {
    final androidGranted =
        await _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;

    final iosGranted =
        await _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;

    // Linux doesn't require explicit permissions
    final linuxGranted = !Platform.isLinux || true;

    return androidGranted || iosGranted || linuxGranted;
  }

  Future<void> scheduleNotificationForEvent(Event event) async {
    if (Platform.isLinux) return; // Use timer for Linux

    // Cancel existing notifications for this event
    await cancelNotificationsForEvent(event);

    // Expand recurring events up to 30 days ahead for performance, limit to 100 instances max
    final maxDate = DateTime.now().add(const Duration(days: 30));
    final instances = Event.expandRecurring(event, maxDate, maxDate: maxDate);
    final limitedInstances = instances.take(
      100,
    ); // Prevent excessive notifications

    for (final instance in limitedInstances) {
      final success = await _scheduleNotificationForInstance(instance);
      if (!success) {
        log(
          'Failed to schedule notification for instance: ${instance.title} at ${instance.startDate}',
        );
      }
    }
  }

  /// Calculate the notification time for an event instance
  DateTime _calculateNotificationTime(Event event) {
    // For all-day events, notify at midday the day before
    if (event.startTime == null) {
      final dayBefore = event.startDate.subtract(const Duration(days: 1));
      return DateTime(
        dayBefore.year,
        dayBefore.month,
        dayBefore.day,
        Event.allDayNotificationHour,
      );
    }

    // For timed events, notify 30 minutes before start time
    final startTimeParts = event.startTime!.split(':');
    final startHour = int.parse(startTimeParts[0]);
    final startMinute = int.parse(startTimeParts[1]);

    var notificationTime = DateTime(
      event.startDate.year,
      event.startDate.month,
      event.startDate.day,
      startHour,
      startMinute,
    ).subtract(const Duration(minutes: Event.notificationOffsetMinutes));

    // If notification time is in the past, don't schedule
    if (notificationTime.isBefore(DateTime.now())) {
      return notificationTime; // Will be filtered out later
    }

    return notificationTime;
  }

  /// Create WorkManager input data for notification task
  Map<String, dynamic> _createWorkManagerInputData(Event event) {
    return {
      'title': event.title,
      'startDate': event.startDate.toIso8601String(),
      'startTime': event.startTime,
      'description': event.description,
      'recurrence': event.recurrence,
    };
  }

  Future<bool> _scheduleNotificationForInstance(Event event) async {
    final notificationTime = _calculateNotificationTime(event);

    // Only schedule if notification time is in the future
    if (notificationTime.isBefore(DateTime.now())) {
      return false;
    }

    // Create notification content
    final title = 'Upcoming Event';
    final body = event.startTime == null
        ? '${event.title} starts today'
        : '${event.title} starts at ${event.startTime}';

    // Create notification details
    const androidDetails = AndroidNotificationDetails(
      'event_channel',
      'Event Notifications',
      channelDescription: 'Notifications for upcoming calendar events',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final linuxDetails = LinuxNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );

    final notificationId = _getNotificationId(event);

    try {
      if (Platform.isAndroid) {
        final delay = notificationTime.difference(DateTime.now());
        final inputData = _createWorkManagerInputData(event);

        await Workmanager().registerOneOffTask(
          notificationId,
          'showNotification',
          inputData: inputData,
          initialDelay: delay,
          existingWorkPolicy: ExistingWorkPolicy.replace,
          constraints: Constraints(
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
          backoffPolicy: BackoffPolicy.exponential,
          backoffPolicyDelay: const Duration(seconds: 30),
        );
      } else {
        // Fallback for other platforms
        await _notifications.zonedSchedule(
          notificationId.hashCode,
          title,
          body,
          tz.TZDateTime.from(notificationTime, tz.local),
          details,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      _scheduledNotificationIds.add(notificationId);
      return true;
    } catch (e) {
      log('Failed to schedule notification for event ${event.title}: $e');
      return false;
    }
  }

  Future<void> cancelNotificationsForEvent(Event event) async {
    final baseId = _getNotificationId(
      event,
    ).split('_')[0]; // Get base part before date
    final idsToRemove = _scheduledNotificationIds
        .where((id) => id.startsWith(baseId))
        .toList();
    for (final id in idsToRemove) {
      if (Platform.isAndroid) {
        await Workmanager().cancelByUniqueName(id);
      } else {
        await _notifications.cancel(id.hashCode);
      }
      _scheduledNotificationIds.remove(id);
    }
  }

  Future<void> cancelAllNotifications() async {
    if (Platform.isAndroid) {
      await Workmanager().cancelAll();
    } else {
      await _notifications.cancelAll();
    }
    _scheduledNotificationIds.clear();
  }

  Future<void> showNotification(Event event) async {
    String title;
    String body;

    if (event.isAllDay) {
      title = 'Upcoming All-Day Event';
      body = '${event.title} starts tomorrow';
    } else {
      title = 'Upcoming Event';
      body = '${event.title} starts at ${event.startTime}';
    }

    final androidDetails = AndroidNotificationDetails(
      'event_channel',
      'Event Notifications',
      channelDescription: 'Notifications for upcoming events',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final linuxDetails = LinuxNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );

    try {
      await _notifications.show(event.title.hashCode, title, body, details);
      log('Showed notification for event ${event.title}');
    } catch (e) {
      log('Failed to show notification for event ${event.title}: $e');
    }
  }

  String _getNotificationId(Event event) {
    // Use hash of title + start date + time to avoid collisions
    final idString =
        '${event.title}_${event.startDate.toIso8601String()}_${event.startTime ?? ''}';
    return idString.hashCode.toString();
  }

  static Future<bool> showNotificationFromWork(
    Map<String, dynamic>? inputData,
  ) async {
    if (inputData == null) {
      log('WorkManager notification task failed: inputData is null');
      return false;
    }

    try {
      // Validate required fields
      final title = inputData['title'] as String?;
      final startDateStr = inputData['startDate'] as String?;
      final startTime = inputData['startTime'] as String?;
      final description = inputData['description'] as String?;
      final recurrence = inputData['recurrence'] as String?;

      if (title == null || title.isEmpty) {
        log('WorkManager notification task failed: missing or empty title');
        return false;
      }

      if (startDateStr == null || startDateStr.isEmpty) {
        log('WorkManager notification task failed: missing startDate');
        return false;
      }

      DateTime startDate;
      try {
        startDate = DateTime.parse(startDateStr);
      } catch (e) {
        log(
          'WorkManager notification task failed: invalid startDate format: $startDateStr, error: $e',
        );
        return false;
      }

      final event = Event(
        title: title,
        startDate: startDate,
        startTime: startTime,
        description: description ?? '',
        recurrence: recurrence ?? 'none',
      );

      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.showNotification(event);
      log(
        'WorkManager notification task completed successfully for event: ${event.title}',
      );
      return true;
    } catch (e, stackTrace) {
      log(
        'WorkManager notification task failed with error: $e\nStack trace: $stackTrace',
      );
      return false;
    }
  }
}
