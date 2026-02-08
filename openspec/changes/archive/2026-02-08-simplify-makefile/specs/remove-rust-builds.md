## REMOVED Requirements

### Requirement: Rust-only build commands removed

Description: Commands like `native-build`, `native-release`, and `native-test` are removed from the Makefile.

#### Scenario: No standalone Rust build commands available
- **WHEN** developer wants to build Rust libraries only
- **THEN** there is no dedicated `make native-build` or `make native-release` command
- **AND** Rust builds are only performed as part of complete build commands

#### Scenario: Testing Rust libraries
- **WHEN** developer wants to test Rust libraries
- **THEN** there is no dedicated `make native-test` command
- **AND** they must use Flutter/Rust testing tools directly or through platform-specific commands
