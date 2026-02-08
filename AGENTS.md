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

## Common Tasks (General Commands)

Use these commands for development on your current platform:

```bash
# Build and run
make build          # Build for current platform (auto-detects Linux/Android)
make run            # Build and run on current platform
make test           # Run all tests

# Maintenance
make clean          # Clean all build artifacts

# Utilities
make help           # Show available targets
```

---

## Platform-Specific Commands

Use these commands to build/run/install for a specific platform different from your host machine:

```bash
# Linux
make linux-build    # Build for Linux

# Android
make android-build  # Build Android APK (debug)
make android-run    # Build and run on Android device/emulator
make android-install # Build and install debug APK on connected device
```

**Note:** All commands perform complete from-scratch builds (deps, generate, native compilation).

---

## Full Build Pipeline

```bash
# Build for current platform
make build

# Or build for specific platform
make linux-build
make android-build
```

## Notes

- All build commands perform complete from-scratch builds (includes deps, generate, native compilation)
- Use `fvm flutter`, `cargo`, or other tools directly for advanced tasks (linting, formatting, etc.)
- Removed commands: `make deps`, `make generate`, `make native-build` are now internal - call them via build commands
