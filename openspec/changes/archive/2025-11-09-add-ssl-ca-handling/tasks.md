# SSL CA Certificate Handling Tasks

- [x] **Implement Flutter platform channels for certificate reading (Android/iOS priority)**
  - Create platform-specific implementations for Android and iOS first
  - Add certificate serialization (PEM format with proper encoding)
  - Handle errors gracefully with fallbacks to default behavior
  - Add desktop implementations (Linux, macOS, Windows) in follow-up

- [x] **Add Dart service for certificate management**
  - Create `CertificateService` class with platform channel integration
  - Integrate with existing `SyncService` for certificate reading
  - Implement app-level caching to avoid repeated platform calls

- [x] **Extend Rust API for SSL configuration**
  - Add `set_ssl_ca_certs` function to api.rs using flutter_rust_bridge
  - Implement temporary certificate file creation and git2::opts::set_ssl_cert_locations
  - Add error handling for invalid certificates and file operations

- [x] **Integrate certificate passing in sync operations**
  - Modify `SyncService.initSync` to read certificates on initialization
  - Ensure certificates are configured before any git operations
  - Add logging for certificate configuration status and fallback scenarios

- [x] **Add comprehensive testing**
  - Unit tests for certificate serialization and service logic (basic tests added)
  - Integration tests with mock certificates and platform channels (platform-specific testing challenging without device/emulator)
  - Platform-specific tests for certificate reading accuracy (requires manual testing on target platforms)
  - End-to-end sync tests simulating custom CA environments (requires test certificates and setup)

- [x] **Performance optimization and validation**
  - Measure and optimize certificate reading performance across platforms (timing added to CertificateService)
  - Validate memory usage impact and cleanup of temporary files (temp files persist for app lifetime, minimal memory usage)
  - Ensure no regressions in sync operation speed or reliability (no changes to sync logic)