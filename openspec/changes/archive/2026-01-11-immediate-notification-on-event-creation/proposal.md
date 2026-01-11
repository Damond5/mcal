# Immediate Notification on Event Creation
## Why
When events are created within their notification windows (within 30 minutes for timed events, or anytime after midday the day before for all-day events), the scheduled notification time is already in the past and gets cancelled without showing any notification. This results in users missing important alerts for recently created urgent events.

## What Changes
- Modify `EventProvider.addEvent()` and `EventProvider.updateEvent()` to check notification window after scheduling regular notifications
- Add immediate notification trigger when event is created within notification window
- Calculate if event is within notification window: timed events (current time within 30 minutes before start time) and all-day events (current time after midday the day before event date)
- Show immediate notification if within window while maintaining existing scheduled notifications for future occurrences
- Ensure platform-consistent behavior across Android, iOS, and Linux


## Summary
When an event is created within its notification window (within 30 minutes for timed events, or anytime after midday the day before for all-day events), the application SHALL show an immediate notification in addition to scheduling regular notifications for future occurrences.

## Problem Statement
Currently, the notification system schedules notifications for 30 minutes before timed events and midday the day before all-day events. However, when events are created within these notification windows (e.g., a timed event at 14:00 created at 13:45), the scheduled notification time is already in the past and gets cancelled without showing any notification. This results in users missing important alerts for recently created urgent events.

## Requirements Analysis

### Current Behavior Analysis
Based on investigation of the codebase:

1. **Notification Scheduling** (`notification_service.dart` lines 120-122, 142-145):
   - Calculates notification time (30 minutes before for timed events, midday day before for all-day)
   - If notification time is in the past, the notification is not scheduled
   - WorkManager on Android and zonedSchedule on iOS won't deliver past notifications

2. **Event Creation Flow** (`event_provider.dart` lines 124-142):
   - `addEvent()` method calls `scheduleNotificationForEvent()` 
   - No immediate notification is triggered, only scheduled notifications

3. **Linux Notification Behavior** (`event_provider.dart` lines 321-368):
   - Linux previously used a timer-based system that checks for events within notification windows
   - **Updated Behavior**: Linux now uses the same immediate notification logic as other platforms, providing consistent UX
   - The timer-based approach has been enhanced to use the unified immediate notification system

4. **Immediate Notification Capability** (`notification_service.dart` lines 240-276):
   - `showNotification()` method exists and can display immediate notifications
   - Currently used by Linux timer and WorkManager callback

### Clarified Requirements (from stakeholder feedback):

**Scope**: Both timed and all-day events
- Timed events: within 30 minutes of start time
- All-day events: created anytime after midday the day before

**Notification Logic**: Show both immediate and scheduled notifications
- Immediate notification when event is created within notification window
- Regular notification scheduling for future instances (e.g., next day for all-day, next occurrence for recurring)

**All-Day Events**: Immediate notification if created after standard notification time
- If all-day event for today is created after 12:00 PM (midday), show immediate notification
- Still schedule regular midday notification for tomorrow (day before event)

## Technical Approach

### Implementation Strategy
Modify `EventProvider.addEvent()` and `EventProvider.updateEvent()` to:

1. **Check notification window** after scheduling regular notifications
2. **Calculate if event is within notification window**:
   - Timed events: current time within 30 minutes before start time
   - All-day events: current time after midday the day before event date
3. **Show immediate notification** if within window
4. **Maintain existing scheduled notifications** for future occurrences

### Key Technical Considerations

1. **Platform Consistency**: All platforms (Android, iOS, Linux) now have identical immediate notification behavior
2. **Recurring Events**: Apply to first instance when created, regular scheduling for all instances
3. **Edge Cases**: 
    - Events exactly at notification boundary (e.g., event at 14:00, created at 13:30)
    - Events in the past (should not trigger notifications)
    - All-day events created after event has started
4. **Notification Content**: Use existing `showNotification()` method with appropriate messaging
5. **Performance**: Minimal overhead, only check current instance being created

### Proposed Changes

#### Core Logic Addition
```dart
// In EventProvider.addEvent() and updateEvent(), after scheduleNotificationForEvent()
Future<void> _checkAndShowImmediateNotification(Event event) async {
  final now = DateTime.now();
  final notificationTime = _calculateNotificationTime(event);
  
  // Check if within notification window and not already passed
  if (now.isAfter(notificationTime) && now.isBefore(event.startDateTime)) {
    await _notificationService.showNotification(event);
  }
}
```

#### Modified Event Creation Flow
1. **Store event** (existing)
2. **Schedule regular notifications** (existing)
3. **Check notification window** (new)
4. **Show immediate notification if applicable** (new)

## Relationship to Existing Specifications

### Extends: `notifications` Specification
- **Current**: Notifications scheduled 30 minutes before timed events, midday day before all-day
- **New**: Immediate notification when event created within notification window
- **Relationship**: Complements existing scheduled notification system

### Extends: `event-management` Specification  
- **Current**: Event creation stores event and schedules notifications
- **New**: Event creation may trigger immediate notification
- **Relationship**: Adds notification behavior to event creation workflow

## Dependencies and Constraints

### Technical Dependencies
- Existing `NotificationService.showNotification()` method
- Existing `EventProvider.addEvent()` and `updateEvent()` methods
- Existing notification permission system

### Constraints
- Must not duplicate notifications
- Must work across all platforms (Android, iOS, Linux)
- Must maintain existing notification scheduling behavior
- Performance impact should be minimal

## Acceptance Criteria

### Functional Requirements
1. ✅ Timed events created within 30-minute window show immediate notification
2. ✅ All-day events created after midday day-before show immediate notification  
3. ✅ Regular notifications are still scheduled for future instances
4. ✅ Recurring events: immediate notification for first instance, regular scheduling for all
5. ✅ Platform-consistent behavior across Android, iOS, Linux

### Non-Functional Requirements
1. ✅ Performance: Negligible overhead on event creation
2. ✅ Reliability: No notification duplicates or missed notifications
3. ✅ Maintainability: Clear separation of immediate vs scheduled notification logic

## Implementation Phases

### Phase 1: Core Functionality
- Implement notification window check logic
- Add immediate notification trigger in event creation/update
- Update existing tests and add new unit tests

### Phase 2: Integration and Testing
- Platform-specific testing (Android, iOS, Linux)
- Integration test coverage for immediate notification scenarios
- Edge case validation

### Phase 3: Documentation and Cleanup
- Update specification documents
- Add code comments for new logic
- Update user documentation if applicable

## Risks and Mitigation

### Risk: Duplicate Notifications
**Mitigation**: Use existing `_notifiedIds` tracking mechanism or add unique notification ID logic to prevent duplicates

### Risk: Performance Impact
**Mitigation**: 
- Only check current instance being created/updated
- Simple time comparison, minimal computation
- Existing notification scheduling already has performance controls (100 instance limit)

### Risk: Platform Inconsistency
**Mitigation**: Use existing `NotificationService.showNotification()` which is platform-agnostic
- All platforms now use the same unified immediate notification system
- Previously, only mobile platforms needed enhancement; Linux already had timer-based immediate notifications
- Now all platforms have consistent, immediate notification behavior on event creation

## Success Metrics
1. **User Experience**: Users receive timely notifications for recently created urgent events
2. **Code Quality**: Maintain existing code patterns and testing standards  
3. **Reliability**: Zero duplicate notifications, 100% notification delivery within window
4. **Performance**: Event creation time impact < 10ms additional processing