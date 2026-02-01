## ADDED Requirements

### Requirement: Makefile provides build targets for all supported platforms

Description: The Makefile must contain build, test, and run targets for Android and Linux platforms. Each target should handle platform-specific build steps including Rust native library compilation, Flutter-Rust bridge regeneration, and platform-specific build commands.

#### Scenario: Agent builds Android APK
- **WHEN** an agent runs `make android-build`
- **THEN** the Makefile executes native library compilation for all Android architectures (armeabi-v7a, arm64-v8a, x86, x86_64)
- **THEN** Flutter-Rust bridge code is regenerated
- **THEN** Flutter build produces a debug APK

#### Scenario: Agent builds Linux desktop application
- **WHEN** an agent runs `make linux-build`
- **THEN** the Makefile compiles Rust native libraries for Linux (x86_64-unknown-linux-gnu)
- **THEN** Flutter-Rust bridge code is regenerated if Rust sources changed
- **THEN** Flutter build produces a Linux desktop application

#### Scenario: Agent runs tests for a specific platform
- **WHEN** an agent runs `make android-test` or `make linux-test`
- **THEN** the Makefile executes platform-appropriate test commands
- **THEN** test results are displayed with clear pass/fail status

### Requirement: Makefile includes utility targets for development workflow

Description: The Makefile must include utility targets for cleaning build artifacts, verifying build state, and managing native library builds independently.

#### Scenario: Agent cleans all build artifacts
- **WHEN** an agent runs `make android-clean` or `make linux-clean`
- **THEN** all Flutter build cache is cleared
- **THEN** all Rust build artifacts are removed
- **THEN** regenerated files (FRB bindings) are preserved or marked for regeneration

#### Scenario: Agent rebuilds native libraries only
- **WHEN** an agent runs `make android-libs` or `make linux-libs`
- **THEN** Rust libraries are compiled without rebuilding Flutter application
- **THEN** compiled libraries are copied to appropriate platform directories

### Requirement: Makefile comments document essential workflows

Description: Each Makefile target must include comments explaining its purpose, usage context, and any prerequisites. This documentation replaces the content being removed from docs/platforms/.

#### Scenario: Agent reads Makefile to understand build process
- **WHEN** an agent reads the Makefile
- **THEN** each target has a descriptive comment block
- **THEN** comments indicate which platforms the target applies to
- **THEN** comments reference any dependencies or prerequisites

### Requirement: Makefile provides platform-agnostic targets leveraging Flutter's detection

Description: The Makefile must include generic targets (build, test, clean) that leverage Flutter's built-in platform detection. Flutter's CLI automatically builds for the current host platform when no `-d` flag is specified.

#### Scenario: Agent runs generic build command
- **WHEN** an agent runs `make build` on any platform
- **THEN** the Makefile executes `fvm flutter build`
- **THEN** Flutter auto-detects the host platform and builds accordingly
- **THEN** the build completes successfully for the current platform

#### Scenario: Agent runs generic test command
- **WHEN** an agent runs `make test` on any platform
- **THEN** the Makefile executes `fvm flutter test`
- **THEN** tests run against the current platform's Flutter environment

#### Scenario: Agent runs generic clean command
- **WHEN** an agent runs `make clean` on any platform
- **THEN** the Makefile executes `fvm flutter clean`
- **THEN** the Flutter build cache is cleared

#### Scenario: Agent needs platform-specific native libraries
- **WHEN** an agent needs to compile Rust native libraries
- **THEN** the agent uses explicit targets: `make android-libs` or `make linux-libs`
- **THEN** these targets compile Rust for the appropriate target architecture

**Note:** The `libs` target remains platform-specific because Rust compilation requires different commands for Android (cross-compilation via cargo-ndk) versus Linux (direct compilation).
