# TODO
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
