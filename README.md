# MCal: Mobile Calendar

A lightweight, cross-platform calendar application built with Flutter. This app provides a simple and intuitive interface for viewing and selecting dates on a calendar, with comprehensive event management features.

## Description

The MCal: Mobile Calendar is a Flutter-based application that displays an interactive calendar widget. Users can navigate through months and select specific days. The app leverages the `table_calendar` package for robust calendar functionality and supports multiple platforms including Android, iOS, Linux, macOS, web, and Windows. Additionally, it includes an event management system allowing users to add, view, edit, and delete events associated with specific dates.

## Features

- **Interactive Calendar**: Navigate through months and select days with ease.
- **Date Selection**: Click on any day to select it graphically on the calendar.
- **Cross-Platform Support**: Runs on mobile (Android/iOS), desktop (Linux/macOS/Windows), and web platforms.
- **Customizable Theme**: Built with Flutter's Material Design, allowing for easy theming.
- **Lightweight and Fast**: Minimal dependencies for quick loading and smooth performance.
- **Localization Ready**: Uses the `intl` package for date formatting, supporting multiple locales.
- **Event Management**: Create, view, edit, and delete events with full details including title, start/end dates, start/end times, description, and recurrence (none/daily/weekly/monthly/yearly). Supports all-day events and multi-day spans.
- **Calendar Integration**: Events are visually marked on calendar days and listed for the selected date, with recurring events expanded automatically.
- **Data Persistence**: Events are stored locally in individual Markdown files per event, following the rcal specification for compatibility and portability.
- **Git Synchronization**: Sync events across devices using Git repositories. Supports comprehensive Git operations including initialization, cloning, branching management, pulling, pushing, status checking, remote management, fetching, checkout, staging, committing, conflict resolution, stashing, and diffing. Includes automatic syncing with configurable settings and conflict resolution.
- **Notifications**: Receive local notifications for upcoming events. Timed events notify 30 minutes before start time, all-day events notify at midday the day before. Additionally, when events are created within their notification window (within 30 minutes for timed events, or anytime after midday the day before for all-day events), an immediate notification is shown at the moment of creation. On Linux, notifications are shown while the app is running using a background timer.
- **Performance Optimized**: Bulk operations have been optimized for speed, with bulk event creation achieving ~1000x improvement over previous implementation. Event loading is ~1800x faster, and single event operations are ~6x faster than baseline performance.

## Setup Instructions

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.9.2 or later)
- A compatible IDE (e.g., Android Studio, VS Code) with Flutter extensions
- For mobile development: Android SDK (for Android) or Xcode (for iOS)
- For desktop/web: Appropriate development tools for your target platform

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd mcal
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate Rust bridge code**:
   ```bash
   flutter_rust_bridge_codegen generate --config-file frb.yaml
   ```

4. **Run the app**:
   - For mobile/emulator:
     ```bash
     flutter run
     ```
   - For web:
     ```bash
     flutter run -d chrome
     ```
   - For desktop (e.g., Linux):
     ```bash
     flutter run -d linux
     ```

### Building for Production

- **Android APK**:
  ```bash
  flutter build apk
  ```

- **iOS**:
  ```bash
  flutter build ios
  ```

- **Web**:
  ```bash
  flutter build web
  ```
  Note: Web builds are not supported due to FFI incompatibility with Rust-based Git sync. The app will fail to build for web platforms.

- **Desktop**:
  ```bash
  flutter build linux  # or macos, windows
  ```

### Rebuilding After Rust Changes

If you make changes to the Rust code in the `native/` directory, the rebuild process varies by platform:

- **Android**: Follow the [Complete Development Cycle](docs/platforms/android-workflow.md#complete-development-cycle) in the Android workflow documentation to ensure proper synchronization and prevent hash mismatches.

- **Other Platforms**: Follow these general steps:
  1. Build the Rust library:
     ```bash
     cd native && cargo build --release
     ```

  2. Regenerate the Flutter Rust Bridge code:
     ```bash
     flutter_rust_bridge_codegen generate --config-file frb.yaml
     ```

  3. Clean and reinstall Flutter dependencies:
     ```bash
     fvm flutter clean
     fvm flutter pub get
     ```

**Note**: Android builds require additional steps to rebuild native libraries for all architectures. See the [Android workflow documentation](docs/platforms/android-workflow.md) for complete instructions.

## Usage

1. Launch the app on your device or in the browser.
2. The calendar will display the current month by default.
3. Use the navigation arrows to switch between months.
4. Tap on any day to select it.
5. To manage events:
    - Tap on a day to view existing events or add new ones.
    - Use the event dialogs to create, edit, or delete events with full details: title, start/end dates, times, description, recurrence, and all-day option.
    - Events are marked on the calendar and persist across app sessions.
    - Receive notifications for upcoming events (30 minutes before timed events, midday the day before for all-day events, and immediately when events are created within their notification window).
   6. To sync events:
       - Events are automatically synced: pulls on app start, pushes after changes.
       - Configure auto sync settings via the Sync button menu > Settings: enable/disable auto sync, set sync frequency (5-60 minutes), enable sync on app resume.
        - For manual sync, tap the Sync button in the app bar to open the sync menu.
         - **Init Sync**: Initializes a new Git repository or clones from a remote URL with authentication (HTTPS/SSH). Used to set up sync for the first time.
         - **Pull**: Fetches and merges changes from the remote repository, handling fast-forward merges and conflict resolution.
         - **Push**: Pushes local commits to the remote repository.
         - **Status**: Returns a list of files with their status changes (modified, staged, untracked).
         - **Add Remote**: Adds or updates the remote repository URL.
         - **Fetch**: Fetches changes from the remote without merging.
         - **Checkout**: Switches to the specified branch.
         - **Add All**: Stages all modified and new files for commit.
         - **Commit**: Commits staged changes with a message.
         - **Merge Prefer Remote**: Resolves merge conflicts by preferring remote changes and committing.
         - **Merge Abort**: Aborts an ongoing merge operation.
         - **Stash**: Stashes current working directory changes.
         - **Diff**: Shows differences between the working directory and the last commit.
         - **Current Branch**: Retrieves the name of the current branch.
         - **List Branches**: Lists all branches in the repository.
         - Use Update Credentials to change username/password/SSH key without re-initializing.
         - Security: Credentials are stored securely and separately from URLs. All logs and errors are sanitized to prevent exposure.
          - Android Support: Git sync on Android uses a custom Rust library with vendored OpenSSL; no additional setup required.
          - SSL Certificates: For HTTPS repositories, the app automatically reads system CA certificates to validate server certificates, supporting custom CA setups in corporate environments. Falls back to default SSL behavior if certificate reading fails.
          - Troubleshooting: If sync fails, check URL format, credentials, and network. For SSH, ensure the key path is correct and the key is in OpenSSH format. Conflicts during pull can be resolved via the UI options. SSL certificate issues may occur in custom CA environments; the app logs certificate configuration status for debugging.

   The app is designed for simplicity, making it easy to integrate into larger projects or use as a standalone date picker with event management.

## Platform-Specific Notes

### Android 13+ Notifications Permission

This app targets Android SDK 36 (Android 14) and is qualified as a calendar application. It requires the `POST_NOTIFICATIONS` permission on Android 13+ (API 33+) and uses the `SCHEDULE_EXACT_ALARM` permission for precise event reminders.

**Background Delivery (Android 12+):**
- Uses WorkManager for reliable background notification scheduling and delivery when the app is not actively running
- Ensures notifications are delivered even if the app is swiped from recent apps or the device is in battery optimization mode
- WorkManager handles scheduling constraints and retries automatically for improved reliability

**User Experience:**
- On first app launch, Android 13+ users will see a permission request dialog asking to allow notifications
- If permission is granted, the app can display event reminders as expected
- If permission is denied, a SnackBar warning appears, and users can enable notifications later through device settings (Settings > Apps > mcal > Notifications)

**For Developers:**
- Permissions are declared in `android/app/src/main/AndroidManifest.xml`
- The app is registered as a calendar app via intent filters for event MIME types, allowing `SCHEDULE_EXACT_ALARM` without restrictions
- Permission requests are handled automatically by the `flutter_local_notifications` plugin
- WorkManager integration provides cross-platform background task management for Android
- No additional configuration is required beyond ensuring the permissions are included in the manifest

**Immediate Notifications:**
- When events are created within their notification window, an immediate notification is shown right away
- Timed events: Immediate notification if created within 30 minutes of start time
- All-day events: Immediate notification if created after midday the day before
- Same-day all-day events: Immediate notification if created after midday on the event day
- Immediate notifications work alongside scheduled notifications to ensure you never miss important reminders
- Permission checks ensure notifications only appear when appropriate permissions are granted
- Advanced deduplication prevents duplicate notifications when multiple events are created in quick succession
- Cross-platform consistent implementation across all supported platforms (Android, iOS, Linux)

 ## Troubleshooting

    - **Android Notification Issues**: If notifications are not appearing on Android devices, ensure the app has notification permissions granted in device settings (Settings > Apps > mcal > Notifications). On Android 12+, WorkManager handles background delivery - if issues persist, try clearing app data and reinstalling to reset WorkManager tasks.

  The app includes a comprehensive test suite to ensure functionality and reliability. Tests cover widget interactions, theme management, event management, sync operations, notifications, and core app behavior.

   ## Testing

### Overview

   MCAL employs a comprehensive testing approach covering widget interactions, theme management, event management, sync operations, notifications, and core app behavior.

   ### Unit Tests

   Unit tests verify individual components in isolation:

    | Test File | Purpose |
    |-----------|---------|
    | `test/test_helpers_test.dart` | Tests test cleanup utilities |
    | `test/event_provider_test.dart` | Tests EventProvider state management |
    | `test/theme_provider_test.dart` | Tests ThemeProvider state and persistence |
    | `test/sync_service_test.dart` | Tests Git sync service operations |
    | `test/notification_service_test.dart` | Tests notification scheduling service |
    | `test/sync_settings_test.dart` | Tests SyncSettings model |
    | `test/certificate_service_test.dart` | Tests SSL certificate retrieval and caching |

### Certificate Testing

     Certificate testing employs a comprehensive approach to ensure SSL certificate functionality for Git synchronization.

     **Testing Strategy:**

     - **Unit Tests** (`test/certificate_service_test.dart`): Use a mocked certificate channel to verify the CertificateService logic, including certificate retrieval,, and cache clearing. These tests run caching, error handling on all platforms (Android, iOS, Linux, macOS, Windows, Web) without requiring real certificate access.

     **Test Behavior:**

     - Certificate caching behavior is verified in unit tests
     - PEM format validation ensures certificates are properly formatted for Git SSL connections
     - Rust backend integration is verified by calling `setSslCaCerts()` with retrieved certificates

    ### Widget Tests

   Widget tests verify UI components and interactions:

   | Test File | Purpose |
   |-----------|---------|
   | `test/widget_test.dart` | Tests main app, calendar widget, and theme toggle button |

   ### Test Cleanup and Isolation

   All test suites use comprehensive cleanup utilities from `test/test_helpers.dart` to ensure tests don't interfere with each other and don't pollute the filesystem:

   - **`setupTestEnvironment()`**: Creates a temporary test directory and sets up required test infrastructure
   - **`cleanupTestEnvironment()`**: Removes all test artifacts after test completion
   - **`setupTestEventProvider()`**: Creates an isolated `EventProvider` instance with temporary storage
   - **`cleanTestEvents()`**: Clears event data between tests

   All test files include `tearDownAll()` callbacks that automatically clean up test artifacts when the test suite completes. Test artifacts are stored in `Directory.systemTemp` for platform-independent cleanup.

   **Debugging Tests**: To preserve test artifacts for debugging (useful when investigating failures), set the environment variable:
   ```bash
   MCAL_TEST_CLEANUP=false flutter test
   ```

   This will keep the test directories and files in the system temp directory for manual inspection.

### Running All Tests

    To run all tests (unit and widget):
    ```bash
    flutter test
    ```

    To run tests with coverage:
    ```bash
    flutter test --coverage
    ```

    To run tests on a specific platform:
    ```bash
    flutter test -d linux
    flutter test -d chrome  # For web testing
    ```

### Platform Testing Strategy

    The MCAL project targets Linux as the primary platform for automated testing. This strategic decision is based on:

    - **Platform-Independent Core**: Most MCAL functionality uses Flutter and Dart, which behave identically across all platforms
    - **Fast, Reliable Execution**: Linux tests run without emulator/simulator overhead
    - **Cost-Effectiveness**: No need for device farms or complex multi-platform CI infrastructure

    Platform-specific features (system back button, permission dialogs, notification channels, etc.) are verified through manual testing before each release. For complete details, see the [Platform Testing Strategy](docs/platforms/platform-testing-strategy.md) documentation.

### Manual Testing

    While automated tests provide comprehensive coverage of platform-independent functionality, certain platform-specific features require manual verification. Refer to the [Manual Testing Checklist](docs/platforms/manual-testing-checklist.md) for a complete list of platform-specific tests to perform before releases.

 ## Dependencies

- **Flutter**: The core framework for building the app.
- **table_calendar**: Provides the calendar widget with selection and navigation features.
- **intl**: Handles date formatting and localization.
- **cupertino_icons**: Includes iOS-style icons (though not heavily used in this app).
- **shared_preferences**: Persists user preferences like theme settings.
- **provider**: Manages app state using the Provider pattern.
- **path_provider**: Accesses platform-specific file directories for data storage.
- **flutter_local_notifications**: Enables local notifications for event reminders.
- **timezone**: Handles timezone-aware scheduling for notifications.
- **uuid**: Generates unique identifiers for events.
- **markdown**: Parses and generates Markdown for event storage.
- **flutter_rust_bridge**: Bridges Dart and Rust for Git synchronization operations.

For a full list, see `pubspec.yaml`.

 ## Project Structure

   ```
docs/
├── platforms/              # Platform-specific workflow files for agents
│   ├── android-workflow.md
│   ├── ios-workflow.md
│   ├── linux-workflow.md
│   ├── macos-workflow.md
│   ├── web-workflow.md
│   └── windows-workflow.md
lib/
  ├── main.dart                 # App entry point and main widget
  ├── models/
  │   └── event.dart            # Event data model
   ├── providers/
   │   ├── event_provider.dart   # Manages event state
   │   └── theme_provider.dart   # Manages app theme state
   ├── services/
   │   ├── event_storage.dart    # Handles event persistence
   │   ├── notification_service.dart # Handles local notifications
   │   └── sync_service.dart     # Handles Git synchronization
   ├── themes/
   │   ├── dark_theme.dart       # Dark theme configuration
   │   └── light_theme.dart      # Light theme configuration
   └── widgets/
       ├── calendar_widget.dart  # Calendar implementation
       ├── event_form_dialog.dart # Event creation/editing dialog
       ├── event_list.dart       # Displays list of events for a day
       ├── sync_button.dart      # Sync button widget
       └── theme_toggle_button.dart # Theme toggle button widget
   test/
   ├── test_helpers.dart         # Test cleanup utilities and helper functions
   ├── test_helpers_test.dart    # Unit tests for test cleanup utilities
   ├── event_provider_test.dart  # Unit tests for EventProvider
   ├── notification_service_test.dart # Unit tests for NotificationService
   ├── sync_service_test.dart    # Unit tests for SyncService
   ├── sync_settings_test.dart   # Unit tests for SyncSettings model
   ├── theme_provider_test.dart  # Unit tests for ThemeProvider
   └── widget_test.dart          # Widget tests for app components
  ```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/new-feature`).
3. Commit your changes (`git commit -am 'Add new feature'`).
4. Push to the branch (`git push origin feature/new-feature`).
5. Create a Pull Request.

Ensure all code passes `flutter analyze` and includes appropriate tests if applicable.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built using [Flutter](https://flutter.dev/)
- Calendar functionality powered by [table_calendar](https://pub.dev/packages/table_calendar)
- Date formatting with [intl](https://pub.dev/packages/intl)
