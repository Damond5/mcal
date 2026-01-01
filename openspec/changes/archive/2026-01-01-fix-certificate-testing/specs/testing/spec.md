# testing Specification Delta

## ADDED Requirements

### Requirement: The application SHALL Certificate Service Unit Tests
The application SHALL include comprehensive unit tests in `test/certificate_service_test.dart` for the certificate service functionality, using full mocking to run cross-platform during `flutter test`:

- Tests for successful certificate reading from mocked platform channel
- Tests for certificate caching behavior (`clearCache()` method forces re-reading)
- Tests for PlatformException handling (graceful fallback to empty list)
- Tests for empty certificate list handling (logged message, no crash)
- Tests for generic exception handling (unexpected errors handled gracefully)
- Tests for SyncService integration (certificate service called during `initSync()`)

Unit tests SHALL use `TestDefaultBinaryMessengerBinding` to mock the `com.example.mcal/certificates` MethodChannel and provide controlled test data.

#### Scenario: Successful certificate reading with mock channel
Given a unit test is running on any platform
And certificate channel is mocked to return test certificates
When `getSystemCACertificates()` is called
Then channel method `getCACertificates` is invoked exactly once
And returned certificate list matches mocked data
And subsequent calls return cached certificates without invoking channel

#### Scenario: Certificate caching prevents re-reading
Given a unit test is running
And `getSystemCACertificates()` has been called once
And the result is cached
When `getSystemCACertificates()` is called a second time
Then the channel method `getCACertificates` is NOT invoked
And the cached certificate list is returned immediately
And the cache is verified to be non-null

#### Scenario: Clear cache forces re-reading from channel
Given a unit test is running
And `getSystemCACertificates()` has been called and cached
When `clearCache()` is invoked
Then the internal cache is set to null
And when `getSystemCACertificates()` is called again
Then the channel method `getCACertificates` is invoked again

#### Scenario: PlatformException handling returns empty list
Given a unit test is running
And certificate channel is mocked to throw `PlatformException`
When `getSystemCACertificates()` is called
Then the exception is caught and logged
And an empty list is returned (no crash)
And the cache is set to empty list

#### Scenario: Empty certificate list handling
Given a unit test is running
And certificate channel is mocked to return empty list
When `getSystemCACertificates()` is called
Then an empty list is returned
And a message is logged indicating zero certificates loaded
And the cache is set to empty list

#### Scenario: Generic exception handling
Given a unit test is running
And certificate channel is mocked to throw generic `Exception`
When `getSystemCACertificates()` is called
Then the exception is caught and logged
And an empty list is returned (no crash)
And the cache is set to empty list

#### Scenario: SyncService integration calls certificate service
Given a unit test is running
And SyncService is mocked with CertificateService
And certificate service is mocked to return test certificates
When `initSync()` is called on SyncService
Then `getSystemCACertificates()` is invoked on CertificateService
And if certificates are returned, `setSslCaCerts()` is invoked on Rust API
And if no certificates are returned, fallback to default SSL behavior occurs

## ADDED Requirements

### Requirement: The application SHALL Certificate Integration Tests (Platform-Specific)
The application SHALL include platform-specific integration tests in `integration_test/certificate_integration_test.dart` that run on Android and iOS devices to verify actual platform certificate reading and end-to-end integration with Rust git2 backend:

- Tests SHALL verify actual system CA certificate reading from platform (AndroidCAStore on Android, SecTrustCopyAnchorCertificates on iOS)
- Tests SHALL verify certificate format is valid PEM
- Tests SHALL verify certificates are passed to Rust `set_ssl_ca_certs()` function
- Tests SHALL verify error handling on platform failures (graceful fallback to default SSL behavior)
- Tests SHALL verify end-to-end flow: platform → CertificateService → SyncService → Rust backend

Integration tests SHALL skip execution on platforms without certificate channel implementations (Linux, macOS, Windows, Web).

#### Scenario: Read real system certificates on Android
Given the test is running on Android device or emulator
And sync is initialized with a test repository URL
When the sync initialization process completes
Then system CA certificates are read from AndroidCAStore
And the certificate list is not empty
 And certificates are in valid PEM format
And log message indicates number of certificates loaded

#### Scenario: Read real system certificates on iOS
Given the test is running on iOS device or simulator
And sync is initialized with a test repository URL
When the sync initialization process completes
Then system CA certificates are read from SecTrustCopyAnchorCertificates
And the certificate list is not empty
And certificates are in valid PEM format
And log message indicates number of certificates loaded

#### Scenario: Certificate format validation on real device
Given the test is running on Android or iOS
And certificates have been loaded from platform
When certificates are examined
Then each certificate begins with "-----BEGIN CERTIFICATE-----"
And each certificate ends with "-----END CERTIFICATE-----"
And certificates contain valid base64-encoded content
And certificates can be parsed by x509-parser in Rust backend

#### Scenario: Rust backend receives certificates on real device
Given the test is running on Android or iOS
And certificates have been loaded from platform
And sync initialization continues
Then the `set_ssl_ca_certs()` Rust function is invoked
And PEM certificates are passed to Rust backend
And the GIT_SSL_CAINFO environment variable is configured
And no SSL errors occur during subsequent git operations

#### Scenario: Platform failure handling on real device
Given the test is running on Android or iOS
And certificate channel implementation throws exception
When sync initialization is attempted
Then the exception is caught and logged
And the application falls back to default SSL behavior
And sync initialization does not fail
And the application remains functional

#### Scenario: Integration tests skip on unsupported platforms
Given the test is running on Linux, macOS, Windows, or Web
And the platform does not have certificate channel implementation
When certificate integration tests execute
Then tests are skipped before execution
And no errors are logged for skipping
And test suite continues to next test

## ADDED Requirements

### Requirement: The application SHALL Certificate Mocking Utilities
The application SHALL provide utility functions in `test/test_helpers.dart` for mocking the certificate MethodChannel in unit tests, enabling consistent and maintainable test setups:

- `setupCertificateMocks()` function to configure mock channel with test data
- `clearCertificateMocks()` function to remove mock handlers for test cleanup
- Optional parameters to return certificates, throw exceptions, or simulate various error conditions
- Documentation comments explaining usage and purpose

These utilities SHALL be used by certificate unit tests and SHALL have their own tests in `test/test_helpers_test.dart`.

#### Scenario: Setup certificate mocks for unit tests
Given a unit test needs to test CertificateService
When `setupCertificateMocks(certificates: testCerts)` is called
Then the `com.example.mcal/certificates` MethodChannel is mocked
And `getCACertificates` returns the provided test certificates
And CertificateService can be tested without platform dependencies

#### Scenario: Setup certificate mocks to simulate errors
Given a unit test needs to test error handling
When `setupCertificateMocks(error: testException)` is called
Then the `com.example.mcal/certificates` MethodChannel is mocked
And `getCACertificates` throws the provided test exception
And CertificateService error handling can be verified

#### Scenario: Clear certificate mocks after test
Given a unit test has configured certificate mocks
When `clearCertificateMocks()` is called in `tearDown()`
Then the mock handler for certificate channel is removed
And subsequent tests start with clean mock state
And no test state pollution occurs between tests

#### Scenario: Certificate mocking utilities are tested
Given the test helpers file is being tested
When tests for certificate mocking utilities run
Then `setupCertificateMocks()` is verified to configure channel correctly
Then `clearCertificateMocks()` is verified to remove mock handlers
Then utility functions themselves have >90% test coverage
