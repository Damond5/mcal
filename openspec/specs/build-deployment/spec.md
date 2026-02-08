# build-deployment Specification

## Purpose
TBD - created by archiving change incorporate-existing-docs. Update Purpose after archive.

## Requirements

---

## ADDED Requirements (from 2026-02-08-simplify-makefile change)

### Requirement: Complete Build Process

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

### Requirement: Android Build Consolidation

Description: The `make android-build` command consolidates all Android build functionality into a single command that builds for all Android architectures as part of a complete from-scratch build.

#### Scenario: Android build produces APKs for all architectures
- **WHEN** developer runs `make android-build`
- **THEN** the command builds Rust libraries for all Android architectures (arm64-v8a, armeabi-v7a, x86_64)
- **AND** produces a complete Flutter APK ready for deployment

#### Scenario: No need for architecture-specific build commands
- **WHEN** developer needs to build for Android
- **THEN** they use a single `make android-build` command
- **AND** they do NOT need to run separate commands for different architectures

### Requirement: Android Run Command

Description: The `make android-run` command first performs a complete from-scratch build (same as `make android-build`), then runs the resulting APK on the connected Android device/emulator.

#### Scenario: Android run command builds before running
- **WHEN** developer runs `make android-run`
- **THEN** the command first executes a complete from-scratch build (deps, generate, Rust compilation for all Android architectures, Flutter APK build)
- **AND** after successful build, the APK is installed and run on the connected Android device/emulator

### Requirement: Android Install Command

Description: A new `make android-install` command is introduced specifically for installing debug APKs on connected devices after a complete from-scratch build.

#### Scenario: Install APK on connected device
- **WHEN** developer runs `make android-install`
- **THEN** the command first performs a complete from-scratch build
- **AND** installs the resulting debug APK on the connected Android device

#### Scenario: Separate installation from development workflow
- **WHEN** developer has already built the APK and just wants to install it
- **THEN** they can run `make android-install` which handles the build and installation
- **AND** they do NOT need to manually locate and install the APK file

---

## REMOVED Requirements (from 2026-02-08-simplify-makefile change)

### Requirement: Individual Android Architecture Build Commands Removed

Description: Android architecture-specific build targets (arm64-v8a, armeabi-v7a, x86_64) are removed and handled internally by the unified `android-build` command.

#### Scenario: No architecture-specific build targets
- **WHEN** developer wants to build for a specific Android architecture
- **THEN** there is no separate Makefile target for each architecture
- **AND** all architectures are built automatically by `make android-build`

#### Scenario: Simplified Android build process
- **WHEN** developer needs to build for Android
- **THEN** they use one command: `make android-build`
- **AND** the command handles all architecture-specific builds transparently

### Requirement: Code Quality Commands Removed

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

### Requirement: Cross-Platform Commands for Unsupported Platforms Removed

Description: Commands for platforms not currently supported or rarely used are removed from the Makefile.

#### Scenario: Platform-specific commands limited to supported platforms
- **WHEN** developer looks at available Makefile targets
- **THEN** only commands for actively supported platforms (Linux, Android) are present
- **AND** no commands for other platforms (iOS, macOS, Windows) are available

#### Scenario: Focus on primary development platforms
- **WHEN** developer is working on the project
- **THEN** they have access to commands for their target platform (Linux or Android)
- **AND** commands for unused platforms are not cluttering the Makefile

### Requirement: Dependency Management Commands Removed

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

### Requirement: Separate Flutter Analysis and Formatting Commands Removed

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

### Requirement: Rust-Only Build Commands Removed

Description: Commands like `native-build`, `native-release`, and `native-test` are removed from the Makefile.

#### Scenario: No standalone Rust build commands available
- **WHEN** developer wants to build Rust libraries only
- **THEN** there is no dedicated `make native-build` or `make native-release` command
- **AND** Rust builds are only performed as part of complete build commands

#### Scenario: Testing Rust libraries
- **WHEN** developer wants to test Rust libraries
- **THEN** there is no dedicated `make native-test` command
- **AND** they must use Flutter/Rust testing tools directly or through platform-specific commands

### Requirement: Verification Commands Removed

Description: `make verify-deps` and `make verify-sync` commands are removed from the Makefile.

#### Scenario: Dependency verification
- **WHEN** developer wants to verify development environment dependencies
- **THEN** there is no `make verify-deps` command
- **AND** they must check dependencies manually or use platform-specific tools

#### Scenario: Build synchronization verification
- **WHEN** developer wants to verify build artifacts are in sync with source
- **THEN** there is no `make verify-sync` command
- **AND** they must perform manual verification or use other means to check sync status

---

### Requirement: The application SHALL Environment Setup
Java OpenJDK 17 (or 11) SHALL be required for Android builds, avoiding development versions.

#### Scenario: Java version check
Given build environment
When doctor command runs
Then appropriate Java version is verified

### Requirement: The application SHALL Flutter Rust Bridge Codegen
Flutter Rust Bridge v2 SHALL be used with `flutter_rust_bridge_codegen generate --config-file frb.yaml` to generate bridge code.

#### Scenario: Code generation
Given Rust code changes
When generate command runs
Then Dart bridge code is updated

### Requirement: The application SHALL build Rust libraries for supported platforms
Rust libraries SHALL be built for supported Android ABIs and stored in the appropriate native library directories.

#### Scenario: Android library build
Given native code changes
When build process runs
Then native libraries are generated for supported ABIs

### Requirement: The application SHALL Platform-Specific Builds
The application SHALL support builds for Android APK, iOS, Linux, macOS, and Windows using the `fvm flutter` prefix for all commands to ensure consistent Flutter SDK versions across development environments. Web platform is NOT supported due to FFI incompatibility with Rust-based Git sync.

#### Scenario: Android APK build
- **GIVEN** the application source code
- **WHEN** `fvm flutter build apk` is executed
- **THEN** an APK is generated successfully in the appropriate output directory

#### Scenario: iOS build
- **GIVEN** the application source code
- **WHEN** `fvm flutter build ios` is executed
- **THEN** an iOS application bundle is generated successfully

#### Scenario: Linux build
- **GIVEN** the application source code
- **WHEN** `fvm flutter build linux` is executed
- **THEN** a Linux executable is generated successfully

#### Scenario: macOS build
- **GIVEN** the application source code
- **WHEN** `fvm flutter build macos` is executed
- **THEN** a macOS application bundle is generated successfully

#### Scenario: Windows build
- **GIVEN** the application source code
- **WHEN** `fvm flutter build windows` is executed
- **THEN** a Windows executable is generated successfully

### Requirement: The application SHALL Build Dependencies
Core library desugaring SHALL be enabled for Android builds supporting flutter_local_notifications.

#### Scenario: Android compatibility
Given build configuration
When APK builds
Then desugaring ensures notification compatibility

### Requirement: The application SHALL CMake Configuration
Custom targets in Android CMakeLists.txt SHALL be renamed to avoid duplicate names.

#### Scenario: CMake build
Given Android project
When built
Then no duplicate target errors occur

### Requirement: The application SHALL Build Validation
All builds SHALL pass lint checks with `fvm flutter analyze`.

#### Scenario: Code analysis
Given source code
When analyze runs
Then no lint errors remain

### Requirement: The application SHALL use fvm prefix for all Flutter commands
All Flutter commands used in documentation, scripts, and Makefile SHALL use the `fvm flutter` prefix to ensure consistent Flutter SDK versions across development environments. This includes `run`, `build`, `test`, `pub get`, `clean`, and `analyze` commands.

#### Scenario: Running Flutter commands with fvm
- **GIVEN** a developer wants to run the application
- **WHEN** they execute `fvm flutter run` or `fvm flutter run -d <platform>`
- **THEN** the application runs using the Flutter version managed by fvm

#### Scenario: Verifying Flutter version with fvm
- **GIVEN** a developer wants to check the Flutter version
- **WHEN** they execute `fvm flutter --version`
- **THEN** the Flutter version managed by fvm is displayed

### Requirement: The application SHALL support platform-specific build methods
The application SHALL provide documented build methods for each supported platform using standardized `fvm flutter build` commands with appropriate platform flags. Each platform's build process SHALL clearly specify debug vs release output locations.

#### Scenario: Building Android APK
- **GIVEN** a developer wants to build an Android APK
- **WHEN** they execute `fvm flutter build apk` for release or `fvm flutter build apk --debug` for debug
- **THEN** the APK is built in the appropriate output directory:
  - Debug: `build/app/outputs/flutter-apk/`
  - Release: `android/app/build/outputs/apk/release/`

#### Scenario: Building Linux executable
- **GIVEN** a developer wants to build a Linux desktop executable
- **WHEN** they execute `fvm flutter build linux`
- **THEN** the Linux executable is built successfully

#### Scenario: Building for macOS and Windows
- **GIVEN** a developer wants to build for macOS or Windows
- **WHEN** they execute `fvm flutter build macos` or `fvm flutter build windows`
- **THEN** the desktop application is built for the specified platform

### Requirement: The application SHALL document web builds as not supported
The application documentation SHALL clearly state that web builds are not supported due to FFI incompatibility with Rust-based Git sync. Any references to `flutter build web` SHALL include a prominent warning or be removed entirely to prevent user confusion.

#### Scenario: User attempts web build
- **GIVEN** a developer reads the documentation and considers building for web
- **WHEN** they check the build documentation
- **THEN** they see a clear statement that web builds are not supported due to FFI incompatibility
- **AND** the `flutter build web` command is either removed or marked as "NOT SUPPORTED" with explanation

### Requirement: The application SHALL use Makefile as primary build automation
The application SHALL use Makefile as the primary build automation tool for all platform builds, including Android.

#### Scenario: Using Makefile for Android builds
- **GIVEN** a developer wants to build the Android application
- **WHEN** they execute `make android-build`
- **THEN** the complete build process executes: FRB codegen, Rust cross-compilation, library copying, and Flutter APK build
- **AND** all Flutter commands use the `fvm` prefix

### Requirement: The application SHALL maintain accurate build documentation
All documentation files SHALL accurately reflect the current build state and capabilities. Documentation SHALL NOT reference deleted scripts, removed features, or non-functional build methods. Build instructions SHALL be consistent across README, platform workflow docs, and OpenSpec specifications.

#### Scenario: Documentation reflects current build state
- **GIVEN** a developer reads the build documentation
- **WHEN** they follow the documented build steps
- **THEN** all commands and references work as documented
- **AND** there are no references to deleted scripts or non-existent features

#### Scenario: Platform documentation matches actual support
- **GIVEN** a developer checks the platform workflow documentation
- **WHEN** they look at the platform status indicators
- **THEN** they see accurate status (Available, Coming soon, or NOT SUPPORTED)
- **AND** the status matches the actual platform support in the project

