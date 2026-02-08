## REMOVED Requirements

### Requirement: Code quality commands removed

Description: `make lint`, `make rust-lint`, and `make format` commands are removed from the Makefile.

#### Scenario: Dart linting
- **WHEN** developer wants to run Dart linter
- **THEN** there is no `make lint` command
- **AND** they must run `fvm flutter lint` or the linter directly

#### Scenario: Rust linting
- **WHEN** developer wants to run Rust linter
- **THEN** there is no `make rust-lint` command
- **AND** they must run `cargo clippy` directly

#### Scenario: Code formatting
- **WHEN** developer wants to format code
- **THEN** there is no `make format` command
- **AND** they must run `fvm flutter format` for Dart and `cargo fmt` for Rust directly
