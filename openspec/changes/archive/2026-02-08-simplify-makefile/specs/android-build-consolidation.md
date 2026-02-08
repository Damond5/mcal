## ADDED Requirements

### Requirement: Android build consolidated into single unified command

Description: The `make android-build` command consolidates all Android build functionality into a single command that builds for all Android architectures as part of a complete from-scratch build.

#### Scenario: Android build produces APKs for all architectures
- **WHEN** developer runs `make android-build`
- **THEN** the command builds Rust libraries for all Android architectures (arm64-v8a, armeabi-v7a, x86_64)
- **AND** produces a complete Flutter APK ready for deployment

#### Scenario: No need for architecture-specific build commands
- **WHEN** developer needs to build for Android
- **THEN** they use a single `make android-build` command
- **AND** they do NOT need to run separate commands for different architectures
