# Agents.md - Development Guidelines

## Build/Lint/Test Commands
- **Install dependencies**: `fvm flutter pub get`
- **Build debug**: `fvm flutter run`
- **Build release APK**: `fvm flutter build apk`
- **Build web**: `fvm flutter build web`
- **Build Linux**: `fvm flutter build linux`
- **Lint**: `fvm flutter analyze`
- **Run all tests**: `fvm flutter test`
- **Run single test**: `fvm flutter test test/widget_test.dart`

## Code Style Guidelines
- **Imports**: Group flutter/material first, then third-party packages, then local imports
- **Quotes**: Use double quotes for strings
- **Naming**: camelCase for variables/methods, PascalCase for classes/widgets
- **Constructors**: Use `const` for stateless widgets and immutable objects
- **Null safety**: Use `!` operator for non-null assertions, `?` for nullable types
- **Error handling**: Add null checks to prevent crashes, display user-friendly messages
- **Formatting**: Follow flutter_lints rules, 2-space indentation
- **Types**: Explicitly type variables when not obvious from context
- **State management**: Use StatefulWidget for simple state, consider providers for complex apps

## Design Choices for Simple Calendar App

- **Calendar Library**: Chose `table_calendar` (v3.2.0) for its
highly customizable and feature-packed calendar widget, supporting
month/week views, selection, and formatting.
- **State Management**: Used Flutter's built-in `StatefulWidget`
for managing calendar state (focused day, selected day) to keep it
simple and avoid over-engineering. For app-level state like themes,
implemented `ChangeNotifier` with `Provider` pattern.
- **Theme System**: Implemented comprehensive dark mode support with
`ThemeProvider` for state management, `shared_preferences` for persistence,
and theme-aware styling throughout the app including calendar theming.
- **Modularity**: Created separate `CalendarWidget` class to
encapsulate calendar logic, making the main app cleaner and
reusable. Organized code into logical directories (providers, themes, widgets).
- **Date Formatting**: Integrated `intl` package for proper date
formatting (e.g., `DateFormat.yMd()`) instead of string
manipulation, ensuring localization support.
- **UI Layout**: Used a `Column` with `TableCalendar` and a `Text`
widget to display selected day, providing immediate feedback on
user interactions. Added responsive constraints to prevent overflow.
- **Error Handling**: Added null checks for selected day to
prevent crashes and display user-friendly messages.
- **Performance**: Kept the app lightweight with no unnecessary
rebuilds; state updates only trigger when needed. Used efficient
theme rebuilding with `Consumer` widgets.
- **Code Quality**: Fixed all lints (e.g., added `key` parameters,
made state class public, ensured dependencies are explicit in
pubspec.yaml). Followed Material Design 3 guidelines.
- **Testing**: Comprehensive test suite with widget tests for GUI
functionality (app loading, calendar display, day selection, theme toggle
interactions) and unit tests for business logic (ThemeProvider and EventProvider state
management, persistence). Used Flutter's testing framework with mockito
for SharedPreferences mocking. All tests run via `fvm flutter test` to
ensure reliability and prevent regressions.
 - **Event System**: Implemented event management fully aligned with rcal's event specification,
 using individual Markdown files per event (one file per event with sanitized title as filename) in the app's calendar subdirectory within the documents directory. Each file contains event details in Markdown format: ID (UUID), Date (YYYY-MM-DD or range), Time (HH:MM or all-day), Description, and Recurrence (none/daily/weekly/monthly). Supports add/view/edit/delete
 events with title, start/end dates, start/end times, description, and recurrence. All-day events supported. Events displayed as markers on calendar days,
 with list view for selected day showing expanded recurring instances. CRUD operations via dialogs with full field editing. Extensible for
 notifications and Git sync.
 - **Recurrence Handling**: Recurring events are expanded into individual instances for display and interaction, with each instance having a unique ID derived from the base event ID and date to allow independent editing if needed.
 - **Sync System**: Implemented Git-based synchronization using `SyncService`
 class with `Process.run` for executing git commands in the app's calendar subdirectory within the documents directory.
 Remote URL stored in `shared_preferences`. Supports init, pull, push, and status
 operations with user-friendly error handling. Integrated into `EventProvider`
 for seamless sync functionality. Added Sync UI with `SyncButton` in app bar
 opening a dialog with buttons for Init Sync (with URL text field), Pull, Push, Status.
 Uses async/await with loading indicators and displays results/errors via SnackBar.
- **Future Extensibility**: Designed with room for features like
event lists, custom themes, or data persistence by making dates
configurable. Theme system is extensible for additional themes.
- **Consistency with rcal**: All features should be consistent with https://github.com/Damond5/rcal, adapted for a Flutter GUI app.
