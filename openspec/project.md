# Project Context

## Purpose
MCAL is a cross-platform Flutter application for calendar management, designed to be consistent with the rcal project (https://github.com/Damond5/rcal). It provides event management with support for recurring events, Git-based synchronization across devices, local notifications, and a user-friendly GUI for viewing and editing calendar events. The app aims to offer a simple, reliable calendar experience with offline-first functionality and secure sync capabilities.

## Tech Stack
- **Flutter**: Framework for building cross-platform UI (Android, iOS, Linux, Web)
- **Dart**: Programming language for Flutter development
- **Rust**: Used for performance-critical operations like Git synchronization via flutter_rust_bridge
- **Android/iOS/Linux**: Target platforms with native builds
- **Key Libraries**:
  - table_calendar: For calendar widget
  - shared_preferences: For local storage
  - flutter_local_notifications: For notifications
  - workmanager: For background sync on mobile
  - provider: For state management
  - intl: For date formatting
  - flutter_rust_bridge: For Dart-Rust interop

## Project Conventions

### Code Style
- **Imports**: Group flutter/material first, then third-party packages, then local imports
- **Quotes**: Use double quotes for strings
- **Naming**: camelCase for variables/methods, PascalCase for classes/widgets
- **Constructors**: Use `const` for stateless widgets and immutable objects
- **Null safety**: Use `!` for non-null assertions, `?` for nullable types
- **Error handling**: Add null checks to prevent crashes, display user-friendly messages
- **Formatting**: Follow flutter_lints rules, 2-space indentation
- **Types**: Explicitly type variables when not obvious from context

### Architecture Patterns
- **State Management**: StatefulWidget for simple state, Provider with ChangeNotifier for app-level state (themes, events)
- **Modularity**: Separate widgets, providers, services, and models directories
- **Event Storage**: Individual Markdown files per event in app's documents directory
- **Sync**: Git-based synchronization with Rust backend for operations
- **Notifications**: Singleton service for scheduling local notifications
- **Themes**: Provider-based theme system with persistence

### Testing Strategy
Comprehensive test suite including:
- Widget tests for GUI functionality (app loading, calendar display, interactions)
- Unit tests for business logic (providers, services, models)
- Integration tests for end-to-end workflows
- Use Flutter's testing framework with mockito for mocking
- Run tests with `fvm flutter test`

### Git Workflow
- Project uses Git for version control and synchronization
- Sync operations handled via Rust Git library
- Branch handling supports dynamic detection of current/default branches
- Commit messages follow conventional format for changes

## Domain Context
Calendar application with event management:
- Events stored as Markdown files with date, time, description, recurrence
- Recurrence support: none, daily, weekly, monthly
- All-day events supported
- Calendar weeks start on Monday
- Week numbers displayed for navigation
- Notifications: 30 minutes before timed events, midday before all-day events

## Important Constraints
- Consistency with rcal specification for event format and features
- Cross-platform compatibility (Android, iOS, Linux)
- Secure Git sync with authentication support
- Offline-first functionality
- Performance: Lightweight app with efficient state updates

## External Dependencies
- Git repositories for synchronization
- Local notification systems (platform-specific)
- File system access for event storage
- Background task scheduling (workmanager on mobile)
