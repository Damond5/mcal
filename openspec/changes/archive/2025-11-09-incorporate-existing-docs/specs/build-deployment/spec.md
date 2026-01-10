## ADDED Requirements

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
The application SHALL support builds for Android APK, iOS, Web, Linux, macOS, Windows with appropriate commands.

#### Scenario: Android APK build
Given source code
When `flutter build apk` runs
Then APK is generated successfully

#### Scenario: Linux build
Given source code
When `flutter build linux` runs
Then Linux executable is generated

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

### Requirement: The application SHALL Web Build Limitations
Web builds SHALL fail gracefully due to FFI incompatibility with Rust-based Git sync.

#### Scenario: Web build attempt
Given web target
When build runs
Then clear error about FFI incompatibility is shown

### Requirement: The application SHALL Build Validation
All builds SHALL pass lint checks with `fvm flutter analyze`.

#### Scenario: Code analysis
Given source code
When analyze runs
Then no lint errors remain