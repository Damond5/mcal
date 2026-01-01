# git-sync Specification Delta

## MODIFIED Requirements

### Requirement: The application SHALL SSL Certificate Handling
Git operations over HTTPS SHALL support custom CA certificates by reading system certificates cross-platform and configuring them in the Rust git2 backend. The certificate handling SHALL be tested with a hybrid testing approach:

- Unit tests with full mocking for cross-platform test execution during `flutter test`
- Platform-specific integration tests for Android and iOS that run on real devices
- Tests verify certificate caching, error handling, and integration with SyncService
- Tests verify end-to-end flow from platform certificate reading to Rust git2 backend configuration
- Tests skip appropriately on platforms without certificate channel implementations (Linux, macOS, Windows, Web)

Unit tests in `test/certificate_service_test.dart` SHALL mock the certificate MethodChannel and test CertificateService logic. Integration tests in `integration_test/certificate_integration_test.dart` SHALL run on Android/iOS devices and verify actual platform certificate reading.

#### Scenario: Unit tests verify certificate caching with mocked channel
Given a unit test is running on any platform
And certificate channel is mocked to return test certificates
When `getSystemCACertificates()` is called
Then platform channel is invoked and returns test data
And result is cached for subsequent calls
And when called again, cached data is returned without channel invocation

#### Scenario: Unit tests verify error handling with mocked channel
Given a unit test is running on any platform
And certificate channel is mocked to throw exception
When `getSystemCACertificates()` is called
Then exception is caught and logged
And empty list is returned
And certificate service does not crash

#### Scenario: Unit tests verify SyncService integration
Given a unit test is running on any platform
And certificate service is mocked to return test certificates
When SyncService.initSync() is called
Then certificate service.getSystemCACertificates() is invoked
And if certificates returned, Rust API set_ssl_ca_certs() is invoked
And if no certificates, fallback to default SSL behavior

#### Scenario: Integration tests verify real certificate reading on Android
Given an integration test is running on Android device or emulator
And sync is initialized
Then system CA certificates are read from AndroidCAStore
And certificates are in valid PEM format
And certificates are passed to Rust set_ssl_ca_certs() function
And log message indicates number of certificates loaded

#### Scenario: Integration tests verify real certificate reading on iOS
Given an integration test is running on iOS device or simulator
And sync is initialized
Then system CA certificates are read from SecTrustCopyAnchorCertificates
And certificates are in valid PEM format
And certificates are passed to Rust set_ssl_ca_certs() function
And log message indicates number of certificates loaded

#### Scenario: Integration tests verify error handling on real devices
Given an integration test is running on Android or iOS
And platform certificate channel throws exception
When sync initialization is attempted
Then exception is caught and logged
And fallback to default SSL behavior occurs
And sync initialization completes successfully
And application remains functional

#### Scenario: Integration tests skip on unsupported platforms
Given an integration test is running on Linux, macOS, Windows, or Web
And platform does not have certificate channel implementation
When certificate integration tests execute
Then tests are skipped before execution
And no errors are logged
And test suite continues to next test
