# Proposal: Fix Certificate Integration Tests

## Why
Certificate integration tests are all skipped and ineffective, leaving critical SSL certificate handling functionality untested despite being essential for secure Git synchronization.

## What Changes
Implement hybrid testing approach with unit tests (cross-platform) and platform-specific integration tests (Android/iOS) to verify SSL certificate functionality end-to-end.

### Current Issues
The certificate integration tests in `integration_test/certificate_integration_test.dart` are currently **all skipped** and do not actually test the certificate functionality. The tests exist but are ineffective because:

1. **Tests check UI, not certificate API**: Tests navigate sync dialog UI and verify "Initializing sync..." text, but don't test `CertificateService.getSystemCACertificates()` or certificate caching logic
2. **Unit tests are placeholder**: `test/certificate_service_test.dart` contains only `expect(true, true)` placeholder tests
3. **Mocking is incorrect**: Tests mock `com.example.mcal/certificates` MethodChannel but don't verify it's actually called or return values are processed correctly
4. **No platform-specific testing**: Tests can't run on Linux/macOS/Windows because certificate channel only implemented for Android/iOS
5. **Certificate integration unverified**: The complete flow from platform certificate reading → Rust git2 backend configuration is not tested end-to-end

This represents a **testing quality and coverage gap** for SSL certificate handling in Git synchronization:
- Critical security functionality (certificate validation) has no effective tests
- Platform-specific implementations (Android/iOS) are never validated
- Certificate caching and error handling logic is untested
- Integration between Dart, Rust, and platform layers is unverified

## Proposed Solution
Implement **Option 2: Hybrid Testing Approach** to provide comprehensive certificate test coverage:

1. **Rewrite unit tests** with full mocking for cross-platform execution:
   - Mock `com.example.mcal/certificates` MethodChannel
   - Test `CertificateService.getSystemCACertificates()` directly
   - Verify certificate caching behavior (`clearCache()` method)
   - Test error handling (PlatformException, empty results)
   - Verify integration with SyncService calling certificate service

2. **Create platform-specific integration tests** for Android/iOS:
   - Tests that run on real devices/emulators
   - Verify actual platform certificate reading (AndroidCAStore, SecTrustCopyAnchorCertificates)
   - Test end-to-end flow: platform certificates → CertificateService → Rust `set_ssl_ca_certs()`
   - Validate certificates are properly formatted and passed to git2 backend
   - Skip these tests on Linux/macOS/Windows (platform channel not implemented)

3. **Ensure proper test infrastructure**:
   - Update `test/test_helpers.dart` with certificate mocking utilities
   - Add platform detection for test execution
   - Document platform-specific test requirements

## Documentation Updates
- **CHANGELOG.md**: Will be updated under "Fixed" section to document certificate testing improvements
- **README.md**: Testing section will be updated to document certificate testing approach and platform-specific requirements

## Scope
This change is focused on certificate testing infrastructure and coverage:

- **In scope**:
  - Rewriting `test/certificate_service_test.dart` with real tests
  - Rewriting `integration_test/certificate_integration_test.dart` with platform-specific tests
  - Adding certificate mocking utilities to `test/test_helpers.dart`
  - Testing certificate caching logic
  - Testing error handling scenarios
  - Testing integration with SyncService and Rust backend
  - Creating tests for certificate service only (not platform implementations)

- **Out of scope**:
  - Adding certificate reading support to Linux/macOS/Windows platforms
  - Modifying `CertificateService` implementation (unless tests reveal bugs)
  - Modifying Rust backend (`set_ssl_ca_certs()` function)
  - Modifying Android/iOS platform implementations
  - Changing sync workflow or UI

## Acceptance Criteria
- Unit tests in `test/certificate_service_test.dart` pass with:
  - Tests for successful certificate reading with mock channel
  - Tests for certificate caching (clearCache prevents re-reading)
  - Tests for PlatformException handling
  - Tests for empty certificate list handling
  - Tests for SyncService integration (certificate service called during initSync)
- Integration tests in `integration_test/certificate_integration_test.dart` pass on Android:
  - Tests verify actual certificate reading from AndroidCAStore
  - Tests verify certificates are passed to Rust backend
  - Tests verify error handling on platform failures
- Integration tests in `integration_test/certificate_integration_test.dart` pass on iOS:
  - Tests verify actual certificate reading from SecTrustCopyAnchorCertificates
  - Tests verify certificates are passed to Rust backend
  - Tests verify error handling on platform failures
- All tests skip appropriately on unsupported platforms (Linux, macOS, Windows, Web)
- Mock utility tests in `test/test_helpers_test.dart` pass with:
  - Tests for `setupCertificateMocks()` returning correct certificates
  - Tests for `setupCertificateMocks()` throwing specified exceptions
  - Tests for `clearCertificateMocks()` removing mock handlers
  - Tests for mock isolation (no state pollution between tests)
- Test coverage for certificate service is >90%
- All existing tests continue to pass (no regressions)

## Impact
- **Testing**: Significantly improves test coverage for critical certificate functionality
- **Risk**: Low - test-only changes, no production code modifications
- **Dependencies**: None - uses existing test infrastructure
- **Performance**: Minimal - adds a few unit and integration tests
- **Maintainability**: Improves test quality and enables future certificate feature development

## Alternatives Considered
1. **Option 1: Mock-based tests only (cross-platform)**
   - *Rejected*: Doesn't validate actual platform implementations; critical security code would be untested on real devices

2. **Option 3: Extend platform support to all platforms**
   - *Rejected*: Significant native code development effort required; certificate testing is higher priority than cross-platform feature support

3. **Delete certificate tests entirely**
   - *Rejected*: Certificate functionality is critical for security; removing tests would reduce code quality

4. **Keep tests as-is (all skipped)**
   - *Rejected*: Tests provide no value; skipped tests create false confidence in code coverage

## Notes
- Android certificate channel implemented in `android/app/src/main/kotlin/com/example/mcal/MainActivity.kt`
- iOS certificate channel implemented in `ios/Runner/AppDelegate.swift`
- Certificate service called by SyncService during `initSync()` at `lib/services/sync_service.dart:119-130`
- Rust backend accepts certificates via `set_ssl_ca_certs()` at `native/src/api.rs:530-540`
- Current unit tests are placeholder with `expect(true, true)` statements
- Current integration tests verify UI elements instead of certificate functionality
