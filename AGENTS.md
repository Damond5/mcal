# Agents.md - Development Guidelines

## Build/Lint/Test Commands
- **Install dependencies**: `flutter pub get`
- **Build debug**: `flutter run`
- **Build release APK**: `flutter build apk`
- **Build web**: `flutter build web`
- **Build Linux**: `flutter build linux`
- **Lint**: `flutter analyze`
- **Run all tests**: `flutter test`
- **Run single test**: `flutter test test/widget_test.dart`

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
simple and avoid over-engineering.
- **Modularity**: Created a separate `CalendarWidget` class to
encapsulate calendar logic, making the main app cleaner and
reusable.
- **Date Formatting**: Integrated `intl` package for proper date
formatting (e.g., `DateFormat.yMd()`) instead of string
manipulation, ensuring localization support.
- **UI Layout**: Used a `Column` with `TableCalendar` and a `Text`
widget to display selected day, providing immediate feedback on
user interactions.
- **Error Handling**: Added null checks for selected day to
prevent crashes and display user-friendly messages.
- **Performance**: Kept the app lightweight with no unnecessary
rebuilds; state updates only trigger when needed.
- **Code Quality**: Fixed all lints (e.g., added `key` parameters,
made state class public, ensured dependencies are explicit in
pubspec.yaml).
- **Testing**: No automated tests added yet; manual verification
via `flutter analyze` and build checks.
- **Future Extensibility**: Designed with room for features like
event lists, custom themes, or data persistence by making dates
configurable.
