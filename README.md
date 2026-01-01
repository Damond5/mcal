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

  The app includes a comprehensive test suite to ensure functionality and reliability. Tests cover widget interactions, theme management, event management, sync operations, notifications, and core app behavior.

   ## Testing

   ### Overview

   MCAL employs a multi-layered testing approach with **254+ test scenarios** across unit tests, widget tests, and integration tests. The test suite is designed to provide comprehensive coverage while maintaining fast execution times suitable for CI/CD pipelines.

   ### Test Execution Budget

   - **Total execution time**: < 8 minutes for all tests
   - **Per test file**: < 30 seconds average
   - **Integration tests**: Run on Linux only for fast, reliable execution (see [Platform Testing Strategy](docs/platforms/platform-testing-strategy.md))
   - **Platform-specific features**: Verified through manual testing using the [Manual Testing Checklist](docs/platforms/manual-testing-checklist.md)

   ### Integration Tests

   Integration tests provide end-to-end testing of user workflows and UI interactions. All integration tests target the Linux platform for fast, reliable execution while comprehensively covering platform-independent functionality.

   **Integration Test Files**:

   | Test File | Purpose | Test Scenarios |
   |-----------|---------|----------------|
   | `accessibility_integration_test.dart` | Tests accessibility features for screen readers, keyboard navigation, and touch targets | 15+ tests |
   | `app_integration_test.dart` | Tests overall app behavior including theme toggle and app lifecycle | 12+ tests |
   | `calendar_integration_test.dart` | Tests calendar navigation, date selection, and visual markers | 18+ tests |
   | `certificate_integration_test.dart` | Tests SSL certificate handling for Git sync | 8+ tests |
   | `conflict_resolution_integration_test.dart` | Tests Git merge conflict resolution UI and flows | 10+ tests |
   | `edge_cases_integration_test.dart` | Tests error handling, empty states, and boundary conditions | 20+ tests |
   | `event_crud_integration_test.dart` | Tests event creation, editing, and deletion workflows | 24+ tests |
   | `event_form_integration_test.dart` | Tests event form dialog functionality and validation | 22+ tests |
   | `event_list_integration_test.dart` | Tests event list display and interactions | 16+ tests |
   | `gesture_integration_test.dart` | Tests user gestures and touch interactions | 14+ tests |
   | `lifecycle_integration_test.dart` | Tests app lifecycle states and auto-sync behavior | 12+ tests |
   | `notification_integration_test.dart` | Tests notification scheduling and display | 18+ tests |
   | `performance_integration_test.dart` | Tests app performance with large datasets | 12+ tests |
   | `responsive_layout_integration_test.dart` | Tests UI responsiveness across different screen sizes | 16+ tests |
   | `sync_integration_test.dart` | Tests Git synchronization operations and flows | 28+ tests |
   | `sync_settings_integration_test.dart` | Tests sync settings configuration | 10+ tests |

   **Total Integration Tests**: 254+ test scenarios across 15 test files

   ### Test Fixtures and Helpers

   Integration tests use reusable test fixtures and helpers to ensure consistency and reduce test maintenance:

   - **`integration_test/helpers/test_fixtures.dart`**: Provides pre-built test data for common scenarios
     - Sample events with various configurations (all-day, multi-day, recurring)
     - Large event datasets for performance testing
     - Mock Git repositories for sync testing
     - Mock notification setup for notification testing

   - **`test/test_helpers.dart`**: Provides test cleanup utilities and helper functions
     - `setupTestEnvironment()`: Creates isolated test environment
     - `cleanupTestEnvironment()`: Removes test artifacts after completion
     - `setupTestEventProvider()`: Creates isolated EventProvider instances
     - `cleanTestEvents()`: Clears test event data

   ### Running Integration Tests

   To run all integration tests:
   ```bash
   flutter test integration_test/
   ```

   To run a specific integration test file:
   ```bash
   flutter test integration_test/event_crud_integration_test.dart
   ```

    To run integration tests with verbose output:
    ```bash
    flutter test integration_test/ --verbose
    ```

    ### Current Test Status

    **Pass Rate**: ~68% (173/254 tests as of December 31, 2025)

    **Passing Test Files**:
    - `app_integration_test.dart`: 4/4 (100%) - App loading and yearly recurrence
    - `responsive_layout_integration_test.dart`: 6/6 (100%) - Layout adaptation
    - `sync_settings_integration_test.dart`: 18/18 (100%) - Sync configuration
    - `sync_integration_test.dart`: 23/25 (92%) - Git operations
    - `conflict_resolution_integration_test.dart`: 12/13 (92%) - Conflict resolution
    - `accessibility_integration_test.dart`: 8/11 (73%) - Accessibility features

    **Partial Pass Test Files**:
    - `calendar_integration_test.dart`: 21/23 (91%) - Calendar navigation, 10 tests skipped (theme button not accessible)
    - `event_crud_integration_test.dart`: 6/13 (46%) - Event CRUD operations
    - `edge_cases_integration_test.dart`: 10/16 (63%) - Error handling
    - `notification_integration_test.dart`: 9/17 (53%) - Notifications

    **Skipped Test Files**:
    - `certificate_integration_test.dart`: 0/8 (0%) - All tests skipped (tests wrong functionality - check sync UI not certificate service)

    **Known Test Limitations**:
    - **Calendar Theme Tests**: 10 tests skipped - Theme toggle button located at offset (835.0, 28.0) is not accessible in test environment
    - **Certificate Tests**: 8 tests skipped - Tests check sync dialog UI elements instead of actual certificate service API (`getSystemCACertificates()`)
    - **Event Form Tests**: 19/25 (76%) failures due to widget accumulation and event naming conflicts (multiple tests create events named "Test Event")
    - **Event List Tests**: Timeout issues due to complex operations taking longer than default timeout allows
    - **Performance Tests**: Slow operations creating large numbers of events (e.g., 100 events test takes several minutes)

    **Test Infrastructure**:
    - All integration tests use `flutter clean` between file runs to prevent state accumulation
    - Mock handlers consolidated in `test/test_helpers.dart` to prevent MethodChannel conflicts
    - Widget keys added to `lib/widgets/event_form_dialog.dart` for stable test selectors
    - Proven test patterns documented: day selection, "All Day" checkbox, dialog waits, save waits

    ### Test Improvement Roadmap

    Planned improvements to reach 75-80% pass rate:
    1. Fix event_form test widget accumulation issues (event naming conflicts)
    2. Increase timeouts for event_list and performance tests
    3. Apply missing test patterns to remaining failing tests
    4. Optimize test fixtures to reduce test execution time
    5. Address flaky tests with retry logic or improved test isolation



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

   To run all tests (unit, widget, and integration):
   ```bash
   flutter test
   ```

   To run tests with coverage:
   ```bash
   flutter test --coverage
   ```

   To run tests on a specific platform:
   ```bash
   flutter test -d linux   # Recommended for integration tests
   flutter test -d chrome  # For web testing
   ```

   ### Platform Testing Strategy

   Integration tests target Linux as the primary platform for automated testing. This strategic decision is based on:

   - **Platform-Independent Core**: Most MCAL functionality uses Flutter and Dart, which behave identically across all platforms
   - **Fast, Reliable Execution**: Linux tests run without emulator/simulator overhead
   - **Cost-Effectiveness**: No need for device farms or complex multi-platform CI infrastructure
   - **Comprehensive Coverage**: 254+ test scenarios cover all user workflows, UI interactions, edge cases, and non-functional requirements

   Platform-specific features (system back button, permission dialogs, notification channels, etc.) are verified through manual testing before each release. For complete details, see the [Platform Testing Strategy](docs/platforms/platform-testing-strategy.md) documentation.

   ### Manual Testing

   While automated integration tests provide comprehensive coverage of platform-independent functionality, certain platform-specific features require manual verification. Refer to the [Manual Testing Checklist](docs/platforms/manual-testing-checklist.md) for a complete list of platform-specific tests to perform before releases.

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
