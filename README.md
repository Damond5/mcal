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
- **Event Management**: Create, view, edit, and delete events with full details including title, start/end dates, start/end times, description, and recurrence (none/daily/weekly/monthly). Supports all-day events and multi-day spans.
- **Calendar Integration**: Events are visually marked on calendar days and listed for the selected date, with recurring events expanded automatically.
- **Data Persistence**: Events are stored locally in individual Markdown files per event, following the rcal specification for compatibility and portability.
- **Git Synchronization**: Sync events across devices using Git repositories. Supports comprehensive Git operations including initialization, cloning, branching management, pulling, pushing, status checking, remote management, fetching, checkout, staging, committing, conflict resolution, stashing, and diffing. Includes automatic syncing with configurable settings and conflict resolution.
- **Notifications**: Receive local notifications for upcoming events. Timed events notify 30 minutes before start time, all-day events notify at midday the day before. On Linux, notifications are shown while the app is running using a background timer.

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
    - Receive notifications for upcoming events (30 minutes before timed events, midday the day before for all-day events).
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

## Troubleshooting

- **GUI Launch Issues**: If the app crashes on sync pull during launch, ensure the Git repository is properly initialized. The app handles empty repositories without a HEAD by using the remote default branch, preventing crashes in partial sync initialization scenarios.

 The app includes a suite of tests to ensure functionality and reliability. Tests cover widget interactions, theme management, and core app behavior.

 ### Test Coverage

 - **Widget Tests**: Basic tests for app loading, calendar display, day selection, and theme toggle functionality.
  - **Unit Tests**: Tests for the `ThemeProvider`, `EventProvider`, `NotificationService`, `SyncService`, and `SyncSettings` classes, including theme mode setting, toggling, persistence, dark mode logic, event management and storage, notification scheduling, sync operations, and settings persistence.

 ### Test Files

 - `test/widget_test.dart`: Contains widget tests for the main app, calendar widget, and theme toggle button.
  - `test/event_provider_test.dart`: Contains unit tests for the `EventProvider` class.
  - `test/theme_provider_test.dart`: Contains unit tests for the `ThemeProvider` class.

 ### Running Tests

 To run all tests:
 ```bash
 flutter test
 ```

 To run a specific test file:
 ```bash
 flutter test test/widget_test.dart
 ```

 To run tests with coverage (requires `flutter_test` and coverage tools):
 ```bash
 flutter test --coverage
 ```

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
  ├── event_provider_test.dart  # Unit tests for EventProvider
  ├── notification_service_test.dart # Unit tests for NotificationService
  ├── sync_service_test.dart    # Unit tests for SyncService
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
