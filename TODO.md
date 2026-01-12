# TODO
- fix unit tests
  - Test framework compatibility issues with expectLater (10 failures)
  - Other time generation bugs (generating hours > 23, like 25:00) 
  - Parsing edge cases

## Other Tasks
- Integration Testing: Perform end-to-end tests with actual Git repos (initialized and uninitialized) to ensure sync operations (init, pull, push, status) handle all edge cases
- Android specific integration tests
- Potential Enhancements: If needed, add features like improved error messaging for sync failures or support for additional Git auth methods
- Deployment Verification: Build for production (e.g., APK, Linux desktop) to confirm Rust linking works across platforms
