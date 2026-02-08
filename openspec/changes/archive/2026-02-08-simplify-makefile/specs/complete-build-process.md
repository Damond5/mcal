## ADDED Requirements

### Requirement: All build commands perform complete from-scratch builds

Description: ALL build commands (`make build`, `make linux-build`, `make android-build`) perform a complete build from scratch, including dependency resolution, Flutter Rust Bridge code generation, Rust library compilation, and Flutter application build. There are no partial builds or assume-already-built scenarios.

#### Scenario: Build command includes all necessary steps
- **WHEN** developer runs any build command (`make build`, `make linux-build`, `make android-build`)
- **THEN** the command automatically executes:
  - Dependency resolution (`make deps` equivalent)
  - Flutter Rust Bridge code generation (`make generate` equivalent)
  - Rust library compilation (platform-specific)
  - Flutter application build

#### Scenario: No manual prerequisite steps required
- **WHEN** developer runs a build command
- **THEN** they do NOT need to manually run `make deps`, `make generate`, or Rust build commands first
- **AND** the build command handles all prerequisites automatically

#### Scenario: Build produces complete deployable artifacts
- **WHEN** a build command completes successfully
- **THEN** the output is a complete, ready-to-deploy artifact for the target platform
