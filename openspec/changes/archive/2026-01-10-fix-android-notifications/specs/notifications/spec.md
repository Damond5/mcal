## MODIFIED Requirements
### Requirement: The application SHALL Platform-Specific Implementation
On Linux, notifications SHALL use a periodic timer to check for upcoming events and show immediate notifications, as scheduled notifications may not persist when the app is closed. On Android, notifications SHALL use WorkManager for reliable background delivery when the app is swiped from recents.

#### Scenario: Linux notification handling
Given Linux platform
When app is running
Then timer checks for upcoming events and shows notifications

#### Scenario: Android WorkManager scheduling
Given Android platform
When event notification is scheduled
Then WorkManager task is created with event data
And notification delivers reliably when app is not running

#### Scenario: Android WorkManager background delivery
Given Android device with scheduled notification
When app is swiped from recents
Then WorkManager executes in background
And notification appears at scheduled time

## ADDED Requirements
### Requirement: The application SHALL Calendar App Qualification
The application SHALL be recognized as a calendar app by Android for automatic SCHEDULE_EXACT_ALARM permission grant, using appropriate package naming and intent filters. (See: docs/platforms/android-workflow.md)

#### Scenario: Calendar intent filter
Given Android app installation
When system scans manifest
Then calendar intent filter enables calendar app recognition

#### Scenario: Calendar package naming
Given app package name
When SCHEDULE_EXACT_ALARM requested
Then calendar-appropriate naming enables auto-grant

### Requirement: The application SHALL Permission Denial Feedback
When notification permissions are denied, the application SHALL display user-friendly feedback explaining the impact and how to re-enable permissions.

#### Scenario: Permission denied SnackBar
Given notification permission request
When user denies permission
Then SnackBar appears with explanation and re-enable instructions</content>
<parameter name="filePath">openspec/changes/improve-android-notification-reliability/specs/notifications/spec.md