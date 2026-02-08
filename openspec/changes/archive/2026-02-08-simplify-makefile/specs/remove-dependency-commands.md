## REMOVED Requirements

### Requirement: Dependency management commands removed

Description: `make deps` and `make generate` commands are removed from the Makefile.

#### Scenario: Dependency resolution
- **WHEN** developer needs to install dependencies
- **THEN** there is no `make deps` command
- **AND** they must run `fvm flutter pub get` and any other dependency commands directly

#### Scenario: Flutter Rust Bridge code generation
- **WHEN** developer needs to regenerate Flutter Rust Bridge code
- **THEN** there is no `make generate` command
- **AND** they must run the flutter_rust_bridge code generator directly

#### Scenario: Build commands handle dependencies automatically
- **WHEN** developer runs a build command (`make build`, `make linux-build`, `make android-build`)
- **THEN** dependencies are handled automatically as part of the complete build process
- **AND** manual dependency management is not required for standard builds
