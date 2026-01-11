# TODO
- fix unit tests
  - The unit test failures are caused by test code that doesn't handle minute overflow properly (e.g., "14:65" instead of "15:05"). These are unrelated to the rename implementation.

## Other Tasks
- Integration Testing: Perform end-to-end tests with actual Git repos (initialized and uninitialized) to ensure sync operations (init, pull, push, status) handle all edge cases
- Android specific integration tests
- Potential Enhancements: If needed, add features like improved error messaging for sync failures or support for additional Git auth methods
- Deployment Verification: Build for production (e.g., APK, Linux desktop) to confirm Rust linking works across platforms
