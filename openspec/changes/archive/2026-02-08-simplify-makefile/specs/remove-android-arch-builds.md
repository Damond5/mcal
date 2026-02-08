## REMOVED Requirements

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
