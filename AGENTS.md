# AGENTS.md

AI agents working on the MCAL project should use the Makefile for all platform-specific development tasks. This file provides direct mappings to Makefile targets.

## Flutter Version Management (fvm)

This project uses **Flutter Version Management (fvm)** to ensure consistent Flutter versions across all developers and CI/CD pipelines.

### Quick Commands

```bash
# Install/activate fvm
dart pub global activate fvm

# Install project Flutter version
fvm install

# Run Flutter commands with fvm
fvm flutter --version
fvm flutter pub get

# List available versions
fvm list
```

### Development Workflow

For all Flutter development tasks, use the **Makefile commands** listed below. They automatically use fvm and handle all platform-specific operations.

---

## Platform-Specific Commands

Use the following `make` commands for platform-specific development:

### Linux
```bash
make linux-run      # Run app on Linux
make linux-build    # Build app for Linux
make linux-test     # Run tests on Linux
make linux-analyze  # Analyze Flutter code on Linux
make linux-clean    # Clean Linux build artifacts
```

### Android
```bash
make android-build    # Build Android APK (debug)
make android-release  # Build Android APK (release)
make android-test     # Run tests on Android
make android-run      # Run app on Android device/emulator
make android-libs     # Build Rust libraries for all Android architectures
make android-clean    # Clean Android build artifacts
make install-apk      # Install debug APK on connected device
```

### Native (Rust)
```bash
make native-build   # Build Rust native library (debug)
make native-release # Build Rust native library (release)
make native-test    # Run Rust tests
```

## Common Tasks

```bash
# Setup
make deps           # Install dependencies
make generate       # Generate Flutter Rust Bridge code

# Development
make analyze        # Run Flutter analyzer
make test           # Run all tests
make test-cov       # Run tests with coverage
make build          # Build for current platform

# Maintenance
make clean          # Clean all build artifacts
make format         # Format Dart and Rust code
make lint           # Run Dart linter
make rust-lint      # Run Rust linter

# Utilities
make help           # Show all available targets
make devices        # Show available devices
make verify-deps    # Verify development environment
make verify-sync    # Verify build synchronization
```

## Full Build Pipeline

```bash
# Build everything
make all

# Or build for specific platform
make android-libs generate && make android-build
```

## Notes

- Always run `make deps` after pulling changes to ensure dependencies are up to date
- Run `make generate` after modifying Rust code to update Flutter bindings
- Use `make verify-sync` to check if build artifacts are in sync with source code
