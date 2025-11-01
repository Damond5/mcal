import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer';
import 'dart:io';
import '../models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Set<String> _scheduledNotificationIds = {};

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open notification');
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap - could navigate to event, but for now just log
        log('Notification tapped: ${response.payload}');
      },
    );
    log('NotificationService initialized');
  }

  Future<bool> requestPermissions() async {
    final androidGranted = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission() ?? false;

    final iosGranted = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true) ?? false;

    // Linux doesn't require explicit permissions
    final linuxGranted = !Platform.isLinux || true;

    return androidGranted || iosGranted || linuxGranted;
  }

  Future<void> scheduleNotificationForEvent(Event event) async {
    if (Platform.isLinux) return; // Use timer for Linux

    // Cancel existing notifications for this event
    await cancelNotificationsForEvent(event);

    // Expand recurring events up to 30 days ahead for performance
    final maxDate = DateTime.now().add(const Duration(days: 30));
    final instances = Event.expandRecurring(event, maxDate, maxDate: maxDate);

    for (final instance in instances) {
      await _scheduleNotificationForInstance(instance);
    }
  }

  Future<void> _scheduleNotificationForInstance(Event event) async {
    final notificationId = _getNotificationId(event);
    if (_scheduledNotificationIds.contains(notificationId)) {
      return; // Already scheduled
    }

    DateTime? notificationTime;
    String title;
    String body;

    if (event.isAllDay) {
      // All-day event: notify at midday the day before
      final dayBefore = event.startDate.subtract(const Duration(days: 1));
      notificationTime = DateTime(dayBefore.year, dayBefore.month, dayBefore.day, Event.allDayNotificationHour, 0);
      title = 'Upcoming All-Day Event';
      body = '${event.title} starts tomorrow';
    } else {
      // Timed event: notify 30 minutes before
      final eventStart = event.startDateTime;
      notificationTime = eventStart.subtract(const Duration(minutes: Event.notificationOffsetMinutes));
      title = 'Upcoming Event';
      body = '${event.title} starts at ${event.startTime}';
    }

    // Only schedule if notification time is in the future
    if (notificationTime.isBefore(DateTime.now())) {
      return;
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

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails, linux: linuxDetails);

    try {
      await _notifications.zonedSchedule(
        notificationId.hashCode,
        title,
        body,
        tz.TZDateTime.from(notificationTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      _scheduledNotificationIds.add(notificationId);
      log('Scheduled notification for event ${event.title} at $notificationTime');
    } catch (e) {
      log('Failed to schedule notification for event ${event.title}: $e');
    }
  }

  Future<void> cancelNotificationsForEvent(Event event) async {
    final baseId = _getNotificationId(event).split('_')[0]; // Get base part before date
    final idsToRemove = _scheduledNotificationIds.where((id) => id.startsWith(baseId)).toList();
    for (final id in idsToRemove) {
      await _notifications.cancel(id.hashCode);
      _scheduledNotificationIds.remove(id);
    }
    log('Cancelled notifications for event ${event.title}');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    _scheduledNotificationIds.clear();
    log('Cancelled all notifications');
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

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails, linux: linuxDetails);

    try {
      await _notifications.show(
        event.title.hashCode,
        title,
        body,
        details,
      );
      log('Showed notification for event ${event.title}');
    } catch (e) {
      log('Failed to show notification for event ${event.title}: $e');
    }
  }

  String _getNotificationId(Event event) {
    return '${event.title}_${event.startDate.millisecondsSinceEpoch}';
  }
}