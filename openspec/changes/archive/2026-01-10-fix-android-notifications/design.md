## Context
Android 12+ introduced aggressive background execution limits that prevent AlarmManager from reliably delivering notifications when apps are swiped from recents. The original implementation used AlarmManager for exact timing, but this fails on modern Android devices despite proper permissions. This change addresses notification reliability issues reported on Android 12+ devices while maintaining compatibility with existing iOS/Linux implementations.

## Goals / Non-Goals
- **Goals**: Ensure notifications deliver reliably on Android 12+ when app is swiped from recents
- **Goals**: Maintain 1-minute precision within Android constraints
- **Goals**: Preserve cross-platform compatibility (iOS/Linux unchanged)
- **Goals**: Provide better user feedback for permission issues
- **Non-Goals**: Change notification timing (30 min before events)
- **Non-Goals**: Modify user-facing notification content
- **Non-Goals**: Implement push notifications requiring server infrastructure
- **Non-Goals**: Change iOS/Linux notification behavior

## Decisions
- **WorkManager over AlarmManager**: WorkManager provides reliable background execution on Android with proper battery optimization handling, unlike AlarmManager which may be deferred or blocked in Doze mode
- **Package name change**: `com.mcal` qualifies as calendar app for SCHEDULE_EXACT_ALARM auto-grant, following Android calendar app conventions
- **Calendar intent filter**: Enables Android to recognize app as calendar-capable for automatic permission grants
- **Platform-specific implementation**: WorkManager for Android (problematic platform), AlarmManager for others (working platforms)
- **No foreground service**: Avoids user disruption while maintaining reliability through proper WorkManager usage

## Alternatives Considered
- **Foreground service**: Rejected - violates no persistent notification requirement and creates poor UX
- **Push notifications**: Rejected - requires server infrastructure not available and adds complexity
- **Inexact alarms only**: Rejected - doesn't meet 1-minute precision requirement for calendar events
- **Keep AlarmManager with inexact scheduling**: Rejected - would break existing user expectations for timely notifications
- **Custom BroadcastReceiver implementation**: Rejected - WorkManager provides better abstraction and reliability

## Risks / Trade-offs
- **Package name change** → Requires clean app reinstall (breaking change for existing users)
- **WorkManager timing** → May have 10-minute delivery window in extreme cases vs exact AlarmManager, but typically delivers within minutes
- **Permission complexity** → SCHEDULE_EXACT_ALARM auto-grant may not work on all Android versions or custom ROMs
- **Dependency addition** → WorkManager adds one dependency but provides significant reliability improvements

## Migration Plan
1. Deploy with new package name (requires clean app reinstall for existing users)
2. WorkManager automatically handles existing scheduled notifications upon app restart
3. No data migration needed (notifications are re-scheduled on app restart)
4. Rollback: Revert to AlarmManager implementation if critical issues arise (simple revert of NotificationService changes)

## Open Questions
- Does the calendar intent filter guarantee SCHEDULE_EXACT_ALARM auto-grant on all Android versions?
- What is the actual delivery precision of WorkManager expedited work in practice?
- Are there OxygenOS or other manufacturer-specific WorkManager limitations?</content>
<parameter name="filePath">openspec/changes/improve-android-notification-reliability/tasks.md