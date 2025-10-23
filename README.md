# Simple Calendar App

A lightweight, cross-platform calendar application built with Flutter. This app provides a simple and intuitive interface for viewing and selecting dates on a calendar.

## Description

The Simple Calendar App is a Flutter-based application that displays an interactive calendar widget. Users can navigate through months, select specific days, and view the selected date in a formatted manner. The app leverages the `table_calendar` package for robust calendar functionality and supports multiple platforms including Android, iOS, Linux, macOS, web, and Windows.

## Features

- **Interactive Calendar**: Navigate through months and select days with ease.
- **Date Selection**: Click on any day to select it and see the formatted date displayed below the calendar.
- **Cross-Platform Support**: Runs on mobile (Android/iOS), desktop (Linux/macOS/Windows), and web platforms.
- **Customizable Theme**: Built with Flutter's Material Design, allowing for easy theming.
- **Lightweight and Fast**: Minimal dependencies for quick loading and smooth performance.
- **Localization Ready**: Uses the `intl` package for date formatting, supporting multiple locales.

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
5. The selected date will be displayed below the calendar in a readable format (e.g., "Selected day: 10/23/2025").
6. If no day is selected, it shows "No day selected".

 The app is designed for simplicity, making it easy to integrate into larger projects or use as a standalone date picker.

 ## Testing

 The app includes a suite of tests to ensure functionality and reliability. Tests cover widget interactions, theme management, and core app behavior.

 ### Test Coverage

 - **Widget Tests**: Basic tests for app loading, calendar display, day selection, and theme toggle functionality.
 - **Unit Tests**: Tests for the `ThemeProvider` class, including theme mode setting, toggling, persistence, and dark mode logic.

 ### Test Files

 - `test/widget_test.dart`: Contains widget tests for the main app, calendar widget, and theme toggle button.
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

For a full list, see `pubspec.yaml`.

 ## Project Structure

 ```
 lib/
 ├── main.dart                 # App entry point and main widget
 ├── providers/
 │   └── theme_provider.dart   # Manages app theme state
 ├── themes/
 │   ├── dark_theme.dart       # Dark theme configuration
 │   └── light_theme.dart      # Light theme configuration
 └── widgets/
     ├── calendar_widget.dart  # Calendar implementation
     └── theme_toggle_button.dart # Theme toggle button widget
 test/
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
