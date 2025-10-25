# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-25

### Added
- Full alignment with rcal event specification: individual Markdown files per event, support for multi-day events, start/end times, all-day events, and recurrence (none/daily/weekly/monthly).
- Expanded recurring events automatically for display.
- Enhanced event creation/editing dialogs with all new fields.
- Updated event storage to use one file per event with sanitized titles and collision handling.

### Changed
- Event model now includes endDate, startTime, endTime, recurrence fields.
- Event storage migrated from date-based files to event-based files.
- Event provider refactored to load all events once and filter on demand.
- Event list and details display updated to show new fields.

### Fixed
- Parsing and generation of rcal-compatible Markdown format.
- GUI updates after sync by adding refresh counter to force calendar rebuilds.
- Improved input validation: title sanitization, time order checks, date ranges.
- Performance: capped recurrence expansion to 1 year ahead.
- Security: enhanced URL validation for sync, prevented path traversal in titles.
- Notifications on Linux: implemented timer-based checking for upcoming events to show notifications, as scheduled notifications may not work reliably on Linux.

### Removed
- Old date-based event storage format.
