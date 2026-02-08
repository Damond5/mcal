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

#### Scenario: Android build consolidated into single unified command
- **WHEN** developer runs `make android-build`
- **THEN** the command builds Rust libraries for all Android architectures (arm64-v8a, armeabi-v7a, x86_64)
- **AND** produces a complete Flutter APK ready for deployment
- **AND** no architecture-specific build commands are needed

#### Scenario: Android run command builds before running
- **WHEN** developer runs `make android-run`
- **THEN** the command first executes a complete from-scratch build (deps, generate, Rust compilation for all Android architectures, Flutter APK build)
- **AND** after successful build, the APK is installed and run on the connected Android device/emulator

#### Scenario: Android install command builds before installing
- **WHEN** developer runs `make android-install`
- **THEN** the command first performs a complete from-scratch build
- **AND** installs the resulting debug APK on the connected Android device
- **AND** they do NOT need to manually locate and install the APK file

### Requirement: Makefile includes utility targets for development workflow

Description: The Makefile must include utility targets for cleaning build artifacts and managing native library builds independently.

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

### Requirement: All build commands perform complete from-scratch builds

Description: ALL build commands (`make build`, `make linux-build`, `make android-build`) perform a complete build from scratch, including dependency resolution, Flutter Rust Bridge code generation, Rust library compilation, and Flutter application build. There are no partial builds or assume-already-built scenarios.

#### Scenario: Build command includes all necessary steps
- **WHEN** developer runs any build command (`make build`, `make linux-build`, `make android-build`)
- **THEN** the command automatically executes:
  - Dependency resolution
  - Flutter Rust Bridge code generation
  - Rust library compilation (platform-specific)
  - Flutter application build

#### Scenario: No manual prerequisite steps required
- **WHEN** developer runs a build command
- **THEN** they do NOT need to manually run dependency or generation commands first
- **AND** the build command handles all prerequisites automatically

#### Scenario: Build produces complete deployable artifacts
- **WHEN** a build command completes successfully
- **THEN** the output is a complete, ready-to-deploy artifact for the target platform

---

## REMOVED Requirements

### Requirement: Verification commands removed

Description: `make verify-deps` and `make verify-sync` commands are removed from the Makefile.

#### Scenario: Dependency verification
- **WHEN** developer wants to verify development environment dependencies
- **THEN** there is no `make verify-deps` command
- **AND** they must check dependencies manually or use platform-specific tools

#### Scenario: Build synchronization verification
- **WHEN** developer wants to verify build artifacts are in sync with source
- **THEN** there is no `make verify-sync` command
- **AND** they must perform manual verification or use other means to check sync status

### Requirement: Cross-platform commands for unsupported platforms removed

Description: Commands for platforms not currently supported or rarely used are removed from the Makefile.

#### Scenario: Platform-specific commands limited to supported platforms
- **WHEN** developer looks at available Makefile targets
- **THEN** only commands for actively supported platforms (Linux, Android) are present
- **AND** no commands for other platforms (iOS, macOS, Windows) are available

#### Scenario: Focus on primary development platforms
- **WHEN** developer is working on the project
- **THEN** they have access to commands for their target platform (Linux or Android)
- **AND** commands for unused platforms are not cluttering the Makefile

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

### Requirement: Individual Android architecture build commands removed

Description: Android architecture-specific build targets (arm64-v8a, armeabi-v7a, x86_64) are removed and handled internally by the unified `android-build` command.

#### Scenario: No architecture-specific build targets
- **WHEN** developer wants to build for a specific Android architecture
- **THEN** there is no separate Makefile target for each architecture
- **AND** all architectures are built automatically by `make android-build`

#### Scenario: Simplified Android build process
- **WHEN** developer needs to build for Android
- **THEN** they use one command: `make android-build`
- **AND** the command handles all architecture-specific builds transparently

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
