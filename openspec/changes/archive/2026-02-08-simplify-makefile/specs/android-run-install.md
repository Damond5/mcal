## ADDED Requirements

### Requirement: Android run and install commands perform complete build first

Description: The `make android-run` and `make android-install` commands first perform a complete from-scratch build (same as `make android-build`), then run or install the resulting APK.

#### Scenario: Android run command builds before running
- **WHEN** developer runs `make android-run`
- **THEN** the command first executes a complete from-scratch build (deps, generate, Rust compilation for all Android architectures, Flutter APK build)
- **AND** after successful build, the APK is installed and run on the connected Android device/emulator

#### Scenario: Android install command builds before installing
- **WHEN** developer runs `make android-install`
- **THEN** the command first executes a complete from-scratch build (deps, generate, Rust compilation for all Android architectures, Flutter APK build)
- **AND** after successful build, the debug APK is installed on the connected Android device
