## Implementation Tasks

### 1. Package Name Change
- [x] Update AndroidManifest.xml package attribute
- [x] Create new Kotlin package directory structure
- [x] Update MainActivity.kt package declaration and CHANNEL
- [x] Update build.gradle.kts applicationId
- [x] Remove old package directory

### 2. Calendar App Qualification
- [x] Add SCHEDULE_EXACT_ALARM permission to AndroidManifest.xml
- [x] Add calendar intent filter for vnd.android.cursor.item/event
- [x] Test auto-grant behavior (may require device testing)

### 3. WorkManager Implementation
- [x] Add WorkManager dependency handling
- [x] Modify NotificationService to use WorkManager on Android
- [x] Update callbackDispatcher to handle notification tasks
- [x] Maintain AlarmManager fallback for iOS/Linux
- [x] Update notification cancellation logic

### 4. User Experience Improvements
- [x] Add SnackBar feedback for denied permissions
- [x] Remove debug notification button and logging
- [x] Test permission request flow

### 5. Testing and Validation
- [x] Build and install updated APK
- [x] Test scheduled notifications work when app swiped from recents
- [x] Verify immediate notifications still work
- [x] Test on Android 12+ device

### 6. Code Review and Testing (AGENTS.md Requirements)
- [x] Create unit tests for WorkManager notification scheduling
- [x] Create integration tests for Android notification delivery
- [x] Run @code-review subagent on NotificationService changes
- [x] Update CHANGELOG.md via @docs-writer subagent
- [x] Update README.md via @docs-writer subagent
- [x] Run all tests and verify no regressions</content>
<parameter name="filePath">openspec/changes/fix-android-notifications/proposal.md