# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Debug logging for GUI errors to console output, enabling easier troubleshooting of user-facing errors during development.
- Custom `GitError` enum for type-safe error handling in Git operations.
- `StatusEntry` struct for structured Git status output.
- Dynamic branch detection using `remote.default_branch()` for flexible repository support.
- `git_stash` and `git_diff` functions added to the Rust Git implementation.

### Changed
- Enhanced logging in SyncService for better debugging of sync operations, including success logs and detailed conflict detection messages.
- Updated error handling in Git operations for improved reliability and user feedback.
- Migrated Flutter Rust Bridge from v1 to v2, updating dependencies, configuration, and codegen process for improved performance and compatibility.

### Fixed
- Removed invalid `flutter_rust_bridge_build` dependency from pubspec.yaml dev_dependencies.
- Added platform check to only initialize workmanager on Android/iOS, preventing UnimplementedError on Linux where Timer is used for periodic sync.
- Fixed GUI crash on app start due to sync pull failing on repositories without HEAD by updating Rust git functions (git_pull_impl, git_push_impl, git_fetch_impl) to use remote default branch instead of requiring repo.head(), resolving issues with uninitialized git repos.

## [1.0.1] - 2025-11-02

### Fixed
- Fixed compilation issues in the Rust git2 implementation.
- Updated bridge code for improved integration and compatibility.
- Fixed test failures related to the Rust git2 implementation.
- Ensured successful builds across all supported platforms.
- Updated flutter_rust_bridge to resolve integration test failures.
- Built Android libraries for improved compatibility and test reliability.
- Fixed integration test setup to ensure proper execution and coverage.
- Implemented proper conflict resolution in sync operations, replacing unimplemented placeholders with functional Git merge handling.

## [1.0.0] - 2025-10-25

### Added
- Added integration tests for app workflows (calendar display, theme toggle) using integration_test package. Implemented hybrid testing: units for logic, integrations for UI/real deps.
- Git sync on Android now supported using custom-built Rust library with vendored OpenSSL, eliminating need for Termux installation.
- Unit tests for NotificationService, SyncService, and SyncSettings models.
- Event date caching in EventProvider to improve performance by precomputing Set<DateTime> of all event dates.
- Notification constants (notificationOffsetMinutes = 30, allDayNotificationHour = 12) extracted to Event model for better maintainability and consistency.
- SSH authentication support for Git sync with configurable key paths.
- Dynamic branch handling in Git operations, supporting modern repositories with "main" or custom branch names.
- Programmatic conflict resolution in Rust, replacing shell Git dependencies for better security and consistency.

### Changed
- Changed Git synchronization implementation from using `Process.run` to Rust + git2 + flutter_rust_bridge for improved cross-platform compatibility and performance.
- Updated workmanager to version 0.9.0 for better compatibility with newer Flutter versions.
- Enabled core library desugaring in Android build to support flutter_local_notifications v17.2.2 requirements.
- Upgraded flutter_secure_storage from ^9.0.0 to ^9.2.4 for latest fixes and improvements.

### Fixed
- Fixed lint warnings in auto-generated bridge code by adding ignore comments for unused import and field.
- Fixed Android CMake build error caused by duplicate target names in CMakeLists.txt.
- Android APK build now succeeds after CMake fix.
- Integration tests now pass after resolving build dependencies.
- Fixed Linux build warnings by suppressing deprecated literal operator warnings in CMakeLists.txt.

## [1.0.0] - 2025-10-25

### Added
- Full alignment with rcal event specification: individual Markdown files per event, support for multi-day events, start/end times, all-day events, and recurrence (none/daily/weekly/monthly).
- Expanded recurring events automatically for display.
- Enhanced event creation/editing dialogs with all new fields.
- Updated event storage to use one file per event with sanitized titles and collision handling.
- Automatic syncing: pulls changes on app start if sync is initialized, pushes changes after event add/update/delete operations.
- Auto sync enhancements: configurable sync settings (enable/disable, frequency 5-60 min, sync on resume), periodic background sync (workmanager on mobile, timer on Linux), conflict resolution UI for merge conflicts.
- Added week numbers display on the left side of the calendar.

### Changed
- Event model now includes endDate, startTime, endTime, recurrence fields.
- Event storage migrated from date-based files to event-based files.
- Event provider refactored to load all events once and filter on demand.
- Event list and details display updated to show new fields.
- Removed ID field from event format to align with rcal specification.
- Calendar now starts weeks on Monday instead of Sunday.

### Fixed
- Parsing and generation of rcal-compatible Markdown format.
- GUI updates after sync by adding refresh counter to force calendar rebuilds.
- Improved input validation: title sanitization, time order checks, date ranges.
- Performance: capped recurrence expansion to 1 year ahead.
- Security: enhanced URL validation for sync, prevented path traversal in titles.
- Notifications on Linux: implemented timer-based checking for upcoming events to show notifications, as scheduled notifications may not work reliably on Linux.
- Event deletion bug: events were not deleted from filesystem when multiple events had similar titles due to incorrect filename lookup; fixed by storing actual filename in Event model.

### Removed
- Old date-based event storage format.
