# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Added integration tests for app workflows (calendar display, theme toggle) using integration_test package. Implemented hybrid testing: units for logic, integrations for UI/real deps.

### Fixed
- Fixed Android build issues by updating workmanager to 0.9.0 and enabling core library desugaring.
- Fixed binding initialization error in main.dart.
- Added proper mocking for path_provider, shared_preferences, and flutter_local_notifications plugins in unit tests to prevent MissingPluginException errors. This ensures tests run successfully in the test environment.
- Fixed failing unit test in sync_service_test.dart by updating initSync test to expect completion instead of exception. Fixed integration test exception by adding MethodChannel mocking for flutter_local_notifications to prevent permission requests in test environment.
- Fixed lint warnings: deprecated setMockMethodCallHandler usage and duplicate import in test files.

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
