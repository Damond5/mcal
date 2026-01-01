# Tasks: Fix Certificate Integration Tests

## Implementation Tasks

- [x] 1. Add certificate mocking utilities to test_helpers.dart (including platform detection)
   - Add `setupCertificateMocks()` function to `test/test_helpers.dart`
   - Add `clearCertificateMocks()` function to `test/test_helpers.dart`
   - Add `platformSupportsCertificates()` helper function to `test/test_helpers.dart`
   - Function returns true for Android/iOS, false for other platforms
   - Add documentation comments explaining usage
   - Follow project code style (imports, naming, formatting)
    - Ensure functions handle edge cases (null certificates, various exception types)

- [x] 2. Create tests for certificate mocking utilities
   - Create test cases in `test/test_helpers_test.dart` for `setupCertificateMocks()`
   - Create test cases in `test/test_helpers_test.dart` for `clearCertificateMocks()`
   - Test that mock channel returns correct certificates
   - Test that mock channel throws specified exceptions
   - Test that clearing mocks removes mock handlers
    - Verify all utility tests pass

- [x] 3. Rewrite certificate service unit tests
   - Delete placeholder tests from `test/certificate_service_test.dart`
   - Import certificate mocking utilities from `test/test_helpers.dart`
   - Write test for successful certificate reading with mocked channel
   - Write test for certificate caching behavior (verify channel called once)
   - Write test for `clearCache()` method forcing re-reading
   - Write test for PlatformException handling (verify empty list returned)
   - Write test for empty certificate list handling
    - Write test for generic exception handling
    - Write test for SyncService integration (mock SyncService and verify call)
    - Add `setUp()` and `tearDown()` methods to ensure cache is cleared between tests
    - Verify all unit tests pass

- [x] 4. Rewrite certificate integration tests (Android/iOS)
   - Delete all skipped tests from `integration_test/certificate_integration_test.dart`
   - Use `platformSupportsCertificates()` helper (from Task 1) to skip tests on unsupported platforms
   - **Important**: Integration tests on Android/iOS should NOT use `setupCertificateMocks()` - use real platform channel
   - Integration tests on Linux/macOS/Windows should skip entirely before test execution
   - Integration tests on all platforms should call `setupAllIntegrationMocks()` for other dependencies (path_provider, etc.)
   - Write test for reading real system certificates on Android
   - Write test for reading real system certificates on iOS
   - Write test for certificate format validation on real devices
   - Write test for Rust backend receiving certificates on real devices (verify GIT_SSL_CAINFO environment variable set)
   - Write test for platform failure handling on real devices
   - Add test metadata to indicate platform-specific execution (tags: `@TestOn('android')`, `@TestOn('ios')`)
   - Ensure tests use actual SyncService on real devices (not mocked)
   - Verify integration tests skip on Linux, macOS, Windows, Web
   - Verify integration tests pass on Android device/emulator
   - Verify integration tests pass on iOS device/simulator

- [ ] 5. Verify sync operations work with real certificates
   - Write integration test that initializes sync with a mock HTTPS repository
   - Verify git fetch completes without SSL errors when certificates are loaded
   - Verify certificates were loaded (check logs or verify environment variable)
   - Test on both Android and iOS devices
    - Verify sync fails appropriately when certificate reading is disabled

- [x] 6. Analyze certificate service code to verify >90% coverage target is achievable
   - Analyze CertificateService code paths (lines in lib/services/certificate_service.dart)
   - Identify hard-to-test branches (e.g., PlatformException catch blocks)
    - Confirm >90% coverage is realistic
    - Adjust target if necessary (if certain paths are unreachable)
    - **Expected**: >90% coverage is achievable or target adjusted

- [x] 7. Run unit tests to verify implementation
   - Run `flutter test test/certificate_service_test.dart` to execute certificate unit tests
   - Verify all new unit tests pass
   - Verify certificate mocking utility tests pass
   - Verify test_helpers_test.dart passes with new certificate tests
   - Check test coverage for CertificateService (>90% target)
   - **Expected**: All unit tests pass, coverage >90%

- [x] 8. Run integration tests on Android
    - Run `flutter test integration_test/certificate_integration_test.dart --platform android`
    - Verify all integration tests pass on Android device/emulator
    - Verify tests skip appropriately (should not skip on Android)
    - Verify real certificates are read from AndroidCAStore
    - Verify certificate format is valid PEM
   - Verify logs show certificate loading information
   - **Expected**: All integration tests pass on Android

- [ ] 9. Run integration tests on iOS
   - Run `flutter test integration_test/certificate_integration_test.dart --platform ios`
   - Verify all integration tests pass on iOS device/simulator
   - Verify tests skip appropriately (should not skip on iOS)
    - Verify real certificates are read from SecTrustCopyAnchorCertificates
    - Verify certificate format is valid PEM
    - Verify logs show certificate loading information
    - **Expected**: All integration tests pass on iOS

- [x] 10. Run integration tests on unsupported platforms
   - Run `flutter test integration_test/certificate_integration_test.dart` on Linux
   - Verify all integration tests skip (platform detection)
    - Verify no errors are logged for skipped tests
    - Verify test suite continues to next test
    - **Expected**: Tests skip cleanly on Linux

- [x] 11. Run all unit tests to check for regressions
   - Run `flutter test` to execute all unit tests
   - Verify all existing unit tests still pass
   - Verify no test failures introduced by certificate test changes
   - Verify test_helpers_test.dart passes with new tests
   - **Expected**: All unit tests pass (59+ tests)

- [ ] 12. Run all integration tests to check for regressions
   - Run `flutter test integration_test/` on appropriate platform
   - Verify all existing integration tests still pass
   - Verify no test failures introduced by certificate integration test changes
    - Verify certificate integration tests are included in test count
    - **Expected**: All integration tests pass

- [x] 13. Verify test coverage
   - Run `flutter test --coverage` to generate coverage report
   - Check coverage for `lib/services/certificate_service.dart` (>90% target)
   - Check coverage for `test/test_helpers.dart` (certificate utilities)
   - Verify all critical code paths are covered
    - Document any gaps in coverage
    - If coverage <90%, add tests for missing paths (create subtask)
    - **Expected**: CertificateService >90% coverage, test_helpers >80% coverage

- [x] 14. Perform code review using @code-review subagent
   - Request code review of certificate_service_test.dart
   - Request code review of certificate_integration_test.dart
   - Request code review of test_helpers.dart modifications
   - Address all feedback from code review
   - Ensure all code follows project conventions (imports, naming, formatting)
   - Verify mocking strategy is correct and doesn't interfere with other tests
   - Confirm platform detection logic is accurate
   - **Expected**: All code review feedback addressed

- [ ] 15. Run linting and type checking
   - Run `flutter analyze` to check for code issues
   - Fix any linting errors or warnings
   - Ensure no type errors exist
   - Verify code follows flutter_lints rules
   - **Expected**: No new linting issues

- [ ] 16. Perform final validation on Android
   - Re-run certificate unit tests: `flutter test test/certificate_service_test.dart`
   - Re-run certificate integration tests on Android: `flutter test integration_test/certificate_integration_test.dart --platform android`
   - Verify all tests pass
   - Verify real certificates are loaded
   - Verify no test files left behind
   - Verify logs show expected certificate operations
   - **Expected**: All tests pass, certificates loaded successfully

- [ ] 17. Perform final validation on iOS
   - Re-run certificate integration tests on iOS: `flutter test integration_test/certificate_integration_test.dart --platform ios`
   - Verify all tests pass
   - Verify real certificates are loaded
   - Verify no test files left behind
    - Verify logs show expected certificate operations
    - **Expected**: All tests pass, certificates loaded successfully

- [x] 18. Update CHANGELOG.md using @docs-writer subagent
   - Add entry under "Fixed" section with version bump
   - Format: "Fixed certificate integration tests - replaced placeholder tests with hybrid testing approach (unit tests + platform-specific integration tests)"
   - Reference this change explicitly
    - Mention hybrid testing approach (unit + platform-specific integration)
    - Add "Certificate Testing" subsection explaining platform-specific requirements

- [x] 19. Update README.md using @docs-writer subagent
   - Update testing section to document certificate testing approach
   - Add certificate tests to test files list
   - Document hybrid testing strategy (unit tests cross-platform, integration tests on Android/iOS)
   - Add "Certificate Testing" subsection explaining platform-specific requirements
    - Document how to run certificate tests on different platforms

- [x] 20. Final openspec validation
   - Run `openspec validate fix-certificate-testing --strict`
   - Ensure all validation checks pass
   - Verify proposal is complete and ready for implementation approval
   - **Expected**: Validation passes with no errors

## Optional Tasks (Recommended)

- [ ] Add certificate loading performance tests
   - Measure time to load certificates on real devices
   - Verify caching effectiveness (second load should be faster)
   - Document certificate loading times for different devices

- [ ] Add certificate rotation testing
   - Test behavior when system certificates change
   - Verify cache invalidation logic
   - Test with simulated certificate updates

- [ ] Document certificate troubleshooting
   - Add documentation on common certificate loading issues
   - Add instructions for debugging certificate failures
   - Add examples of certificate-related errors and solutions

- [ ] Consider property-based testing for certificate validation
   - Generate random certificate strings to test validation logic
   - Test edge cases (malformed certificates, empty strings, etc.)
   - Use test package like `fast_check` or similar

- [ ] Add certificate mock data library
   - Create reusable test certificate data fixtures
   - Include valid certificates, invalid certificates, empty lists
   - Make available for other tests that might need certificate mocking
