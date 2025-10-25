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
- **Git Synchronization**: Sync events across devices using Git repositories with init, pull, push, and status operations.
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

3. **Run the app**:
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

- **Desktop**:
  ```bash
  flutter build linux  # or macos, windows
  ```

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
    - For manual sync, tap the Sync button in the app bar to open the sync dialog.
    - Use Init Sync to initialize with a Git remote URL.
    - Use Pull to fetch latest events from remote, Push to upload local changes, Status to check repository state.

 The app is designed for simplicity, making it easy to integrate into larger projects or use as a standalone date picker with event management.

 ## Testing

 The app includes a suite of tests to ensure functionality and reliability. Tests cover widget interactions, theme management, and core app behavior.

 ### Test Coverage

 - **Widget Tests**: Basic tests for app loading, calendar display, day selection, and theme toggle functionality.
  - **Unit Tests**: Tests for the `ThemeProvider` and `EventProvider` classes, including theme mode setting, toggling, persistence, dark mode logic, and event management and storage.

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
- **process_run**: Executes system commands for Git synchronization.

For a full list, see `pubspec.yaml`.

 ## Project Structure

  ```
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
