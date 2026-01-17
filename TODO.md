# TODO

## ✅ Completed
- **Event Management Systemic Issues Resolution** (@fixes/03_event_management_systemic_issues.md)
  - Fixed 7 integration test files with 10-13% failure rates
  - Achieved 100% pass rates across all test categories
  - Created 5 comprehensive utility suites (2,300+ lines)
  - Documented complete solution in OpenSpec change proposal
  - Archived as: `openspec/changes/archive/2026-01-17-document-event-management-fixes/`

- ✅ COMPLETED: Continue last session on ./fixes/03_event_management_systemic_issues.md (Achieved 100% pass rates, created comprehensive documentation, archived change proposal)

- /init for AGENTS.md? Or just ask to put build information in there (fvm)?
  - See ./docs/platforms/ files first
- Spec for ./SYNCHRONIZATION_UTILITIES.md
- Add notes on test runtime to avoid timeouts to AGENTS.md
  - Needs longer than 15 minute timeout, to run the full integration test suite
- Add notes to AGENTS.md on only running integration tests for affected code/features, because integration tests take a long time
- Add notes on using fvm to AGENTS.md
- Fix integration test failures
  - Only fails on Android or do they also fail on Linux?
  - See ./integration_test_report.md
- Integration tests stuck?
  - Background test
  - Swipe away test

## Other Tasks
- Integration Testing: Perform end-to-end tests with actual Git repos (initialized and uninitialized) to ensure sync operations (init, pull, push, status) handle all edge cases
- Android specific integration tests
- Potential Enhancements: If needed, add features like improved error messaging for sync failures or support for additional Git auth methods
- Deployment Verification: Build for production (e.g., APK, Linux desktop) to confirm Rust linking works across platforms
