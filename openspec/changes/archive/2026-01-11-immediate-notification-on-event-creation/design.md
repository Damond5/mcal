# Design: Immediate Notification on Event Creation

## Architecture Overview

### Current System Architecture

The current notification system follows a platform-specific pattern:

```
┌─────────────────────────────────────────────────────────────┐
│                    Event Creation Flow                       │
│  ┌──────────────┐    ┌──────────────────┐    ┌────────────┐ │
│  │ EventForm    │───▶│ EventProvider    │───▶│ Event      │ │
│  │ Dialog       │    │ .addEvent()      │    │ Storage    │ │
│  └──────────────┘    │                  │    └────────────┘ │
│                      │ ┌────────────────┴──────────────┐   │
│                      │ │ scheduleNotificationForEvent()│   │
│                      │ │                              │   │
│                      │ │ • Calculate notification time │   │
│                      │ │ • Check if in future         │   │
│                      │ │ • Schedule (or skip if past) │   │
│                      │ └──────────────────────────────┘   │
│                      └──────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Platform-Specific Delivery                  │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │ Android        │  │ iOS            │  │ Linux          │ │
│  │ WorkManager    │  │ zonedSchedule  │  │ Timer + Check  │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Proposed Architecture

The new architecture adds an immediate notification check after the existing scheduled notification logic:

```
┌─────────────────────────────────────────────────────────────┐
│                  Enhanced Event Creation Flow                │
│  ┌──────────────┐    ┌──────────────────┐    ┌────────────┐ │
│  │ EventForm    │───▶│ EventProvider    │───▶│ Event      │ │
│  │ Dialog       │    │ .addEvent()      │    │ Storage    │ │
│  └──────────────┘    └──────────────────┘    └────────────┘ │
│                            │                               │
│                            ▼                               │
│                   ┌──────────────────┐                     │
│                   │ scheduleNotifi-  │                     │
│                   │ cationForEvent() │                     │
│                   │ (existing)       │                     │
│                   └────────┬─────────┘                     │
│                            │                               │
│                            ▼                               │
│                   ┌──────────────────┐                     │
│                   │ _checkImmediate- │                     │
│                   │ Notification()   │                     │
│                   │ (NEW)            │                     │
│                   │                  │                     │
│                   │ • Calculate      │                     │
│                   │   notification   │                     │
│                   │   window         │                     │
│                   │ • Check if now   │                     │
│                   │   within window  │                     │
│                   │ • Show immediate │                     │
│                   │   if applicable  │                     │
│                   └──────────────────┘                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Unified Notification Delivery             │
│         (All platforms use showNotification() for           │
│          immediate notifications)                           │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ NotificationService.showNotification()                  ││
│  │ • Platform-agnostic implementation                      ││
│  │ • Uses flutter_local_notifications                      ││
│  │ • Consistent across Android, iOS, Linux                 ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Design Decisions

### 1. Immediate Notification Logic Placement

**Decision**: Add immediate notification check in `EventProvider` after `scheduleNotificationForEvent()`

**Rationale**:
- **Separation of Concerns**: NotificationService handles WHEN and HOW to schedule notifications, while EventProvider orchestrates the event creation workflow. Immediate notification is a user experience enhancement triggered by event creation, not a scheduling concern.
- **Platform Consistency**: EventProvider implements the immediate notification logic that works identically across all platforms (Android, iOS, Linux), providing a unified user experience.
- **Existing Pattern**: The immediate notification logic in EventProvider provides consistent behavior across all platforms, replacing the previous platform-specific timer approach on Linux.
- **Workflow Integration**: Event creation/update is the natural trigger point for immediate notifications - it happens once when the event is created, not on a schedule.

**Alternative Considered**: Add logic in `NotificationService.scheduleNotificationForEvent()`
- **Rejected**: Would mix immediate and scheduled notification concerns in same method, violating single responsibility principle
- **Rejected**: Would require either modifying existing method to have side effects or adding duplicate platform detection logic
- **Rejected**: Would create tight coupling between scheduling and immediate notification behavior

**Alternative Considered**: Add new method in NotificationService
- **Rejected**: Would require EventProvider to call into NotificationService just to check if notification should be immediate, adding unnecessary abstraction layer
- **Rejected**: NotificationService doesn't have access to the event creation context and timing

### 2. Notification Window Calculation

**Decision**: Delegate to existing `NotificationService.calculateNotificationTime()` method to eliminate code duplication

**Implementation**:
```dart
/// Calculate notification time for an event (delegates to NotificationService)
DateTime _calculateNotificationTime(Event event) {
  return _notificationService.calculateNotificationTime(event);
}

/// Check if event is within notification window and show immediate notification
Future<void> _checkAndShowImmediateNotification(Event event) async {
  final now = DateTime.now();
  final notificationTime = _calculateNotificationTime(event);
  
  // Check if within notification window and event hasn't started
  if (now.isAfter(notificationTime) && now.isBefore(event.startDateTime)) {
    // Check notification permissions before showing
    final hasPermission = await _notificationService.hasPermissions();
    if (!hasPermission) {
      log('Notification permissions not granted, skipping immediate notification for: ${event.title}');
      return;
    }
    
    try {
      await _notificationService.showNotification(event);
      log('Showed immediate notification for event: ${event.title}');
    } catch (e, stack) {
      log('Error showing immediate notification: $e');
      log('Stack trace: $stack');
      // Continue - notification failure shouldn't fail event creation
    }
  }
}
```

**Rationale for Delegation**:
- **DRY Principle**: Eliminates code duplication between NotificationService and EventProvider
- **Maintainability**: Changes to notification time calculation only need to be made in one place
- **Consistency**: Both immediate and scheduled notifications use the same calculation logic
- **Existing Method**: NotificationService already has `calculateNotificationTime()` method (lines 95-126) that handles all edge cases properly

**Alternative Considered**: Duplicate the calculation logic
- **Rejected**: Violates DRY principle and creates maintenance burden
- **Rejected**: Risk of drift between implementations over time
- **Rejected**: Existing implementation already handles edge cases (null times, timezone, etc.)

**Rationale**:
- **Consistency**: Uses same calculation as scheduled notifications
- **Correctness**: Matches user expectation of "within notification time"
- **Simplicity**: Single time comparison, easy to test and understand

### 3. All-Day Event Logic

**Decision**: For all-day events, immediate notification if created after midday the day before OR if created on the same day after midday

**Example Scenarios**:
- Event: All-day on Nov 10
- Standard notification time: Nov 9 at 12:00
- If created Nov 9 at 13:00 → immediate notification (after standard time)
- If created Nov 9 at 11:00 → no immediate notification (before standard time)
- If created Nov 10 at 14:00 → immediate notification (same day, event is active)
- If created Nov 10 at 10:00 → no immediate notification (before midday on event day)

**Updated Implementation with Edge Case Handling**:
```dart
DateTime _calculateNotificationTime(Event event) {
  if (event.isAllDay) {
    final now = DateTime.now();
    final dayBefore = event.startDate.subtract(const Duration(days: 1));
    final standardNotificationTime = DateTime(
      dayBefore.year, 
      dayBefore.month, 
      dayBefore.day, 
      Event.allDayNotificationHour, 
      0
    );
    
    // For all-day events on the same day or later
    if (event.startDate.isAfter(now) || 
        (event.startDate.isAtSameMomentAs(now) && now.hour < Event.allDayNotificationHour)) {
      // Event hasn't started yet today, use standard notification time
      return standardNotificationTime;
    } else {
      // Event is today and either started or it's past midday - immediate notification
      // Return a time in the past so now.isAfter() will be true
      return now.subtract(const Duration(seconds: 1));
    }
  } else {
    // For timed events, delegate to NotificationService
    return _notificationService.calculateNotificationTime(event);
  }
}
```

**Rationale**:
- **User Expectation**: If you create an all-day event for today in the afternoon, you want to be reminded
- **Consistency**: Mirrors timed event logic (within window before event)
- **Practicality**: Users don't need reminder if event already passed (past midnight)
- **Edge Case Coverage**: Handles same-day events created after midday

### 4. Recurring Event Handling

**Decision**: Immediate notification only for the first instance being created, regular scheduling for all instances

**Implementation**:
- `EventProvider.addEvent()`: Create single event, check immediate for this instance
- `scheduleNotificationForEvent()`: Expand recurring and schedule all instances
- First instance gets immediate notification (if within window)
- All instances get scheduled notifications (including first instance, but it will be filtered as past)

**Rationale**:
- **User Experience**: Immediate notification for "this instance" creation
- **System Consistency**: Regular scheduling already handles recurring expansion
- **Performance**: Avoids re-expanding recurring events for immediate check

### 5. Platform Consistency Strategy

**Decision**: Use `NotificationService.showNotification()` for immediate notifications on all platforms

**Rationale**:
- **Unified API**: `showNotification()` is already platform-agnostic
- **Existing Implementation**: Properly handles Android, iOS, Linux differences
- **Enhanced Behavior**: All platforms now use the same immediate notification logic, providing consistent UX
- **Improvement Over Original Design**: The original design specified `if (!Platform.isLinux)` for mobile platforms only, but the implementation was enhanced to work on ALL platforms including Linux, providing:
  - Consistent user experience across all platforms
  - Immediate notifications for Linux users (previously only timer-based with 1-minute delay)
  - Simplified platform-specific code

**Original Design vs. Implementation**:
- **Original**: Mobile platforms only, Linux used separate timer-based system
- **Implementation**: All platforms use unified immediate notification on event creation/update

**Current Linux Behavior** (from `event_provider.dart` lines 329-368):
```dart
void _checkUpcomingEvents() {
  // Timer checks for events within notification window
  // Shows immediate notifications via showNotification()
  if (now.isAfter(notificationTime) && now.isBefore(instance.startDateTime)) {
    _notificationService.showNotification(event);
  }
}
```

**Unified Enhancement**: Apply same logic to all platforms during event creation for immediate notifications

## Class and Method Changes

### Modified Classes

#### EventProvider (`lib/providers/event_provider.dart`)

**Added Method**:
```dart
/// Check if event is within notification window and show immediate notification
Future<void> _checkAndShowImmediateNotification(Event event) async {
  final now = DateTime.now();
  final notificationTime = _calculateNotificationTime(event);
  
  // Within notification window and event hasn't started
  if (now.isAfter(notificationTime) && now.isBefore(event.startDateTime)) {
    await _notificationService.showNotification(event);
  }
}

/// Calculate notification time for an event (mirrors notification_service.dart logic)
DateTime _calculateNotificationTime(Event event) {
  if (event.isAllDay) {
    final dayBefore = event.startDate.subtract(const Duration(days: 1));
    return DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 
                    Event.allDayNotificationHour, 0);
  } else {
    return event.startDateTime.subtract(
      const Duration(minutes: Event.notificationOffsetMinutes)
    );
  }
}
```

**Modified Methods**:

`addEvent()`:
```dart
Future<void> addEvent(Event event) async {
  try {
    final filename = await _storage.addEvent(event);
    final eventWithFilename = event.copyWith(filename: filename);
    _allEvents.add(eventWithFilename);
    _computeEventDates();
    await _notificationService.scheduleNotificationForEvent(eventWithFilename);
    // NEW: Check for immediate notification
    await _checkAndShowImmediateNotification(eventWithFilename);
    _refreshCounter++;
    notifyListeners();
    await autoPush();
  } catch (e) {
    log('Error adding event: $e');
    rethrow;
  }
}
```

`updateEvent()`:
```dart
Future<void> updateEvent(Event oldEvent, Event newEvent) async {
  try {
    final newFilename = await _storage.updateEvent(oldEvent, newEvent);
    final index = _allEvents.indexWhere((e) => e == oldEvent);
    final newEventWithFilename = newEvent.copyWith(filename: newFilename);
    if (index != -1) {
      _allEvents[index] = newEventWithFilename;
    }
    _computeEventDates();
    await _notificationService.scheduleNotificationForEvent(newEventWithFilename);
    // NEW: Check for immediate notification
    await _checkAndShowImmediateNotification(newEventWithFilename);
    _refreshCounter++;
    notifyListeners();
    await autoPush();
  } catch (e) {
    log('Error updating event: $e');
    rethrow;
  }
}
```

## Time Zone Handling

Immediate notifications use the same time zone handling as scheduled notifications:
- Event times are stored in local time (HH:MM format)
- Notification content displays the stored time directly
- No timezone conversion is needed for immediate display
- `DateTime.now()` uses the local device time zone
- The existing `NotificationService.calculateNotificationTime()` method handles timezone-aware scheduling for zonedSchedule, but immediate notifications use the simpler `showNotification()` method which displays time as stored

**Implementation Note**: The notification body displays `event.startTime` directly, which is already in local time format, so no additional timezone handling is required.

## Duplicate Prevention

**Risk**: Users might receive duplicate notifications if:
- Event is updated multiple times
- App is restarted and events are reloaded
- User creates, deletes, then recreates the event quickly

**Mitigation**: The `showNotification()` method uses `event.title.hashCode` as the platform notification ID (notification_service.dart line 271), which inherently prevents duplicate notifications at the system level. Unlike the timer-based approach that uses time-based IDs, immediate notifications are one-time events tied to creation/update actions.

**Implementation**:
```dart
// In _checkAndShowImmediateNotification(), no need for _notifiedIds tracking
// because showNotification() uses event.title.hashCode as notification ID
await _notificationService.showNotification(event);
// Platform will handle deduplication based on notification ID
```

**Why Not Use _notifiedIds**: The existing `_notifiedIds` set in EventProvider is used by the Linux timer approach to prevent repeated notifications for the same event instance. However, for immediate notifications (triggered once on creation/update), this is unnecessary because:
1. Immediate notifications are one-time events, not periodic
2. The platform notification system already handles deduplication via notification IDs
3. Using `_notifiedIds` would prevent legitimate future notifications

## Permission Handling

**Requirement**: Check notification permissions before showing immediate notifications

**Implementation**:
```dart
/// Check if notification permissions are granted
Future<bool> _hasNotificationPermissions() async {
  final androidGranted = await _notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission() ??
      false;
  
  final iosGranted = await _notifications
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, badge: true, sound: true) ??
      false;
  
  // Linux doesn't require explicit permissions
  return androidGranted || iosGranted || !Platform.isLinux;
}
```

**Usage in Immediate Notification**:
```dart
Future<void> _checkAndShowImmediateNotification(Event event) async {
  final now = DateTime.now();
  final notificationTime = _calculateNotificationTime(event);
  
  if (now.isAfter(notificationTime) && now.isBefore(event.startDateTime)) {
    // Check permissions before attempting notification
    final hasPermission = await _hasNotificationPermissions();
    if (!hasPermission) {
      log('Notification permissions not granted, skipping immediate notification for: ${event.title}');
      return;
    }
    
    try {
      await _notificationService.showNotification(event);
      log('Showed immediate notification for event: ${event.title}');
    } catch (e, stack) {
      log('Error showing immediate notification: $e');
      log('Stack trace: $stack');
      // Continue - notification failure shouldn't fail event creation
    }
  }
}
```

**Rationale**:
- **Graceful Degradation**: If permissions aren't granted, silently skip the notification rather than showing an error
- **User Control**: Respects user's choice not to receive notifications
- **Consistency**: Matches behavior of scheduled notifications which also require permissions
- **Debugging**: Logs when permissions prevent notifications for debugging purposes

## Testing Strategy

### Unit Tests

**New Tests** (`test/event_provider_test.dart`):

1. **Timed Event - Within Window**
   ```
   Given: Current time is 13:45
   When: Event created for 14:00
   Then: Immediate notification is shown
   ```

2. **Timed Event - Outside Window**  
   ```
   Given: Current time is 13:15
   When: Event created for 14:00
   Then: No immediate notification
   ```

3. **All-Day Event - After Standard Time**
   ```
   Given: Current time is 13:00 on Nov 9
   When: All-day event created for Nov 10
   Then: Immediate notification is shown
   ```

4. **All-Day Event - Before Standard Time**
   ```
   Given: Current time is 11:00 on Nov 9
   When: All-day event created for Nov 10
   Then: No immediate notification
   ```

5. **Event in Past**
   ```
   Given: Current time is 15:00
   When: Event created for 14:00 today
   Then: No immediate notification
   ```

6. **Recurring Event - First Instance Within Window**
   ```
   Given: Current time is Monday 13:45
   When: Weekly event created starting Monday 14:00
   Then: Immediate notification shown for first instance
   And: Regular notifications scheduled for all instances
   ```

### Integration Tests

**New Tests** (`integration_test/notification_integration_test.dart`):

1. **Event Created Within Timed Window**
   ```
   Given: App is running with notifications enabled
   When: User creates timed event within 30-minute window
   Then: Immediate notification appears
   And: Event marker appears on calendar
   ```

2. **Event Created After All-Day Standard Time**
   ```
   Given: App is running with notifications enabled  
   When: User creates all-day event after 12:00 day before
   Then: Immediate notification appears
   ```

3. **No Duplicate Notifications**
   ```
   Given: Event created within notification window
   When: Event creation completes
   Then: Only one notification appears (immediate)
   And: Scheduled notification filtered as past
   ```

## Performance Considerations

### Time Complexity
- **Added**: O(1) time calculation per event creation
- **Comparison**: Simple datetime arithmetic, no iteration

### Memory Impact
- **Added**: Minimal - only stores a few DateTime objects
- **No New Collections**: Uses existing notification service

### Platform-Specific Optimizations
- **All Platforms**: Uses unified `showNotification()` path for immediate notifications
- **Consistent Behavior**: All platforms (Android, iOS, Linux) now have identical immediate notification logic

## Security and Privacy Considerations

### Notification Content
- **Title**: "Upcoming Event" (existing)
- **Body**: Event-specific message (existing)
- **No Sensitive Data**: Follows existing notification content patterns

### Permission Handling
- **Existing**: Uses existing notification permission system
- **No New Permissions**: Immediate notifications use same permissions as scheduled

## Migration and Backward Compatibility

### No Breaking Changes
- **Existing Behavior**: Scheduled notifications unchanged
- **New Behavior**: Only adds immediate notification when applicable
- **Platform Support**: Works on all platforms with unified behavior

### Gradual Rollout
- **Default Enabled**: Immediate notifications enabled by default
- **No Configuration**: No new settings needed
- **User Experience**: Natural enhancement, no user education required