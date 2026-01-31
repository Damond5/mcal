## REMOVED Requirements

### Requirement: The application SHALL Web Build Limitations
**Reason**: This requirement is superseded by the new "The application SHALL document web builds as not supported" requirement, which takes a stronger position by removing misleading command references rather than just documenting failure.
**Migration**: The new requirement ensures web builds are clearly documented as not supported with prominent warnings, preventing user confusion.

## MODIFIED Requirements

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

## ADDED Requirements

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
The application SHALL use the Makefile as the primary automation tool for build processes. Alternative shell scripts (e.g., `scripts/build-android.sh`) SHALL be marked as deprecated with a warning directing users to use the equivalent Makefile target.

#### Scenario: Using Makefile for Android builds
- **GIVEN** a developer wants to build the Android application
- **WHEN** they execute `make android-build`
- **THEN** the complete build process executes: FRB codegen, Rust cross-compilation, library copying, and Flutter APK build
- **AND** all Flutter commands use the `fvm` prefix

#### Scenario: Developer finds deprecated build script
- **GIVEN** a developer considers using `scripts/build-android.sh`
- **WHEN** they read the script
- **THEN** they see a deprecation warning at the top of the file
- **AND** the warning directs them to use `make android-build` instead

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
