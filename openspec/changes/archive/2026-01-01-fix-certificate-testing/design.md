# Design: Fix Certificate Integration Tests

## Architectural Approach

This change implements a **hybrid testing strategy** for certificate functionality, recognizing the platform-specific nature of certificate reading while ensuring comprehensive test coverage.

### Why Hybrid Testing?

The certificate functionality spans three distinct layers:
1. **Platform layer** (Android/iOS native code): Reads system CA certificates
2. **Dart layer** (CertificateService): Manages caching, error handling, API surface
3. **Rust layer** (git2 backend): Configures certificates for Git operations

Each layer requires different testing approaches:

| Layer | Testing Need | Best Approach |
|-------|--------------|----------------|
| Platform (Android/iOS) | Verify native certificate reading works on real devices | Integration tests on real devices |
| Dart (CertificateService) | Test caching, error handling, API contract | Unit tests with full mocking |
| Integration across layers | Verify end-to-end flow from platform to Rust | Integration tests on Android/iOS |

### Unit Test Design (Cross-Platform)

**Purpose**: Test CertificateService logic in isolation, runs on all platforms during `flutter test`

**Mocking Strategy**:
- Mock `com.example.mcal/certificates` MethodChannel using `TestDefaultBinaryMessengerBinding`
- Return controlled test data (certificate PEM strings, empty lists, exceptions)
- Simulate platform-specific failures without requiring actual platform code

**Test Scenarios**:
1. **Success case**: Verify channel is called, certificates returned, cached correctly
2. **Caching**: Verify first call reads from channel, second call returns cached value
3. **Clear cache**: Verify `clearCache()` forces re-reading from channel
4. **PlatformException**: Verify graceful error handling, empty list returned
5. **Empty certificates**: Verify empty list handling, logged message
6. **SyncService integration**: Verify SyncService calls CertificateService during `initSync()`

**Test Location**: `test/certificate_service_test.dart`

### Integration Test Design (Platform-Specific)

**Purpose**: Verify actual platform certificate reading works on real devices

**Platform Detection**:
```dart
// Skip tests on platforms without certificate channel
if (!Platform.isAndroid && !Platform.isIOS) {
  return; // Skip test
}
```

**Important: Mock vs Real Channel Usage**:

Integration tests on **Android/iOS** (platforms with certificate channel implementation) should:
- **NOT** use `setupCertificateMocks()` - use real platform channel
- Use platform detection (`platformSupportsCertificates()`) to skip on unsupported platforms
- Call `setupAllIntegrationMocks()` for other dependencies (path_provider, flutter_secure_storage, etc.)

Integration tests on **Linux/macOS/Windows/Web** (platforms without certificate channel) should:
- Skip entirely before test execution using platform detection
- **NOT** attempt to run tests (platform channel will fail)
- **NOT** use `setupCertificateMocks()` for integration tests (only for unit tests)

**Test Scenarios (Android/iOS only)**:
1. **Read system certificates**: Verify platform channel returns real CA certificates
2. **Certificate format**: Verify certificates are valid PEM format
3. **Rust backend integration**: Verify certificates are passed to `set_ssl_ca_certs()`
4. **Error handling**: Verify graceful fallback on platform failures
5. **End-to-end sync**: Verify sync init loads certificates and configures git2

**Test Location**: `integration_test/certificate_integration_test.dart`

## Test Infrastructure Updates

### Certificate Mocking Utilities (`test/test_helpers.dart`)

Add the following utilities for consistent mock setup:

```dart
/// Mock certificate channel for unit tests
void setupCertificateMocks({
  List<String>? certificates,
  Exception? error,
}) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('com.example.mcal/certificates'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getCACertificates') {
            if (error != null) throw error;
            return certificates ?? ['-----BEGIN CERTIFICATE-----\n...'];
          }
          return null;
        },
      );
}

/// Clear certificate mocks (for cleanup)
void clearCertificateMocks() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('com.example.mcal/certificates'),
        null,
      );
}
```

### Platform Detection Helper

Add utility to skip tests on unsupported platforms:

```dart
/// Returns true if platform has certificate channel implementation
bool platformSupportsCertificates() {
  return Platform.isAndroid || Platform.isIOS;
}
```

## Integration Points

### SyncService Integration

Current code at `lib/services/sync_service.dart:119-130`:
```dart
try {
  final caCerts = await _certificateService.getSystemCACertificates();
  if (caCerts.isNotEmpty) {
    await _api.crateApiSetSslCaCerts(pemCerts: caCerts);
    log('Configured ${caCerts.length} CA certificates for SSL validation');
  }
} catch (e) {
  log('Failed to configure CA certificates: $e, falling back to default');
}
```

**Testing strategy**:
- Unit test: Mock CertificateService to return test certificates, mock Rust API
- Integration test: Use real CertificateService on device, verify Rust API receives certificates

### Rust Backend Integration

Rust function at `native/src/api.rs:530-540`:
```rust
pub fn set_ssl_ca_certs(pem_certs: Vec<String>) -> Result<(), GitError> {
    let mut temp_file = tempfile::NamedTempFile::new()?;
    for cert in pem_certs {
        std::io::Write::write_all(&mut temp_file, cert.as_bytes())?;
    }
    let path = temp_file.path().to_str().unwrap();
    std::env::set_var("GIT_SSL_CAINFO", path);
    std::mem::forget(temp_file);
    Ok(())
}
```

**Testing strategy**:
- Unit test: Mock Rust API via flutter_rust_bridge mock
- Integration test: Use real Rust API on device, verify environment variable is set

## Trade-offs and Decisions

### Why Mock Instead of Fake?

**Decision**: Use full mocking instead of creating a fake CertificateService

**Rationale**:
- CertificateService is simple (single method, caching, error handling)
- Full mocking provides complete control over test scenarios
- No need to maintain separate fake implementation
- Simpler test setup, clearer test intent

### Why Platform-Specific Integration Tests?

**Decision**: Run integration tests only on Android/iOS

**Rationale**:
- Certificate reading is platform-specific (uses AndroidCAStore on Android, SecTrustCopyAnchorCertificates on iOS)
- No certificate channel implementation on Linux/macOS/Windows
- Running tests on all platforms would require implementing certificate reading for all platforms (out of scope)
- Testing on actual devices validates real platform behavior

### Why Not Add Linux/macOS/Windows Support?

**Decision**: Out of scope for this change

**Rationale**:
- Requires native code development for each platform (Kotlin, Swift, C++, etc.)
- Requires understanding each platform's certificate storage system
- Testing is higher priority than cross-platform feature support
- Can be added in future change if needed

## Testing Coverage Goals

### Target Coverage
- **CertificateService**: >90% line coverage
- **Certificate mocking utilities**: 100% line coverage
- **SyncService integration**: >80% of certificate-related code paths

### Test Execution Platforms
| Test Type | Linux | macOS | Windows | Android | iOS | Web |
|-----------|-------|-------|---------|---------|-----|-----|
| Unit tests (certificate_service_test.dart) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Integration tests (certificate_integration_test.dart) | ⏭️ | ⏭️ | ⏭️ | ✅ | ✅ | ⏭️ |
| (⏭️ = skipped, ✅ = executed) |

## Implementation Notes

### Test Data Management

Use fixed test certificates for consistent testing:
```dart
const testCertificates = [
  '-----BEGIN CERTIFICATE-----\nMIID...\n-----END CERTIFICATE-----',
  '-----BEGIN CERTIFICATE-----\nMIID...\n-----END CERTIFICATE-----',
];
```

### Error Simulation

Test both specific exception types:
```dart
// PlatformException
PlatformException(code: 'ERROR', message: 'Failed to load')

// Generic exception
Exception('Unexpected error')
```

### State Isolation

Ensure certificate cache is cleared between tests:
```dart
setUp(() {
  certificateService.clearCache();
});
```

## Future Considerations

### Potential Enhancements
1. **Add Linux certificate support**: Read from `/etc/ssl/certs/ca-certificates.crt`
2. **Add macOS certificate support**: Read from system keychain
3. **Add Windows certificate support**: Read from Windows certificate store
4. **Certificate rotation testing**: Test certificates update when system certificates change
5. **Performance testing**: Measure certificate loading time and verify caching effectiveness

### Test Evolution
- If Linux/macOS/Windows support is added, extend integration tests to those platforms
- Consider property-based testing for certificate validation logic
- Add contract tests to verify certificate format consistency across platforms
