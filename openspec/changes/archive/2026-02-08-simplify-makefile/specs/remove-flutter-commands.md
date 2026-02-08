## REMOVED Requirements

### Requirement: Separate Flutter analysis and formatting commands removed

Description: `make flutter analyze` and `make flutter format` commands are removed as Makefile targets.

#### Scenario: Code analysis workflow
- **WHEN** developer wants to analyze Flutter/Dart code
- **THEN** there is no `make flutter analyze` command
- **AND** they must run `fvm flutter analyze` directly

#### Scenario: Code formatting workflow
- **WHEN** developer wants to format Dart code
- **THEN** there is no `make flutter format` command
- **AND** they must run `fvm flutter format` directly

#### Scenario: Test command still available
- **WHEN** developer wants to run tests
- **THEN** `make test` is still available as the unified test command
