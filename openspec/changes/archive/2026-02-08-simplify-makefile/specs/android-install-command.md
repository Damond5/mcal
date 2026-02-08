## ADDED Requirements

### Requirement: New android-install command for APK installation

Description: A new `make android-install` command is introduced specifically for installing debug APKs on connected devices after a complete from-scratch build.

#### Scenario: Install APK on connected device
- **WHEN** developer runs `make android-install`
- **THEN** the command first performs a complete from-scratch build
- **AND** installs the resulting debug APK on the connected Android device

#### Scenario: Separate installation from development workflow
- **WHEN** developer has already built the APK and just wants to install it
- **THEN** they can run `make android-install` which handles the build and installation
- **AND** they do NOT need to manually locate and install the APK file
