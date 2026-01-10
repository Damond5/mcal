# Add SSL CA Certificate Handling

## What Changes
- Add platform-specific certificate reading in Flutter using platform channels
- Extend Dart `SyncService` to read and cache system CA certificates
- Add `set_ssl_ca_certs` Rust API function for git2 SSL configuration
- Integrate certificate passing into sync initialization
- Add comprehensive testing for certificate handling
- Update documentation and error messages for SSL scenarios

## Why
Current Git sync operations rely on default system certificate validation, which may fail in environments with custom CA setups (e.g., corporate networks, self-signed certificates). By leveraging Flutter's cross-platform capabilities, we can read system CA certificates and provide them to git2 for proper SSL validation, improving reliability in diverse network environments.

## Impact
- **Affected specs**: git-sync
- **Affected code**: lib/services/sync_service.dart, native/src/api.rs, platform-specific channel implementations
- Enhances security and reliability of Git sync operations
- Maintains cross-platform compatibility
- No breaking changes to existing functionality
- Adds minimal performance overhead (one-time certificate reading ~100-500ms)

## Dependencies
None - this builds on existing git-sync infrastructure.

## Non-Goals
- Client certificate authentication (only CA certificates for server validation)
- Certificate revocation list (CRL) handling
- Real-time certificate updates during app runtime
- Support for non-system certificate stores