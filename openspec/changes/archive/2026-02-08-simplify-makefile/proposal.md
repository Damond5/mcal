## Why

The current Makefile contains an extensive list of platform-specific commands that has grown organically over time. This complexity makes the build system difficult to maintain, understand, and use. Many commands are redundant, some are rarely used, and the proliferation of targets creates confusion about which commands are actually needed for common development workflows.

By severely simplifying the Makefile to only include bare minimum commands that cover essential development tasks, we can:
- Reduce maintenance burden and potential for errors
- Improve developer onboarding by presenting a clear, focused set of options
- Eliminate rarely-used or duplicate commands that add noise without value
- Make the build process more intuitive for new contributors
- Align the Makefile with actual development needs rather than accommodating every possible edge case

## What Changes

The Makefile will be completely refactored to include only the following commands:

**General Commands:**
- `make clean` - General cleanup of all build artifacts across all platforms
- `make build` - Full build from scratch for current platform (includes frb generation, Rust library compilation, and Flutter app build)

**Development Commands:**
- `make run` - Run app on current platform using `fvm flutter run`
- `make test` - Run tests on current platform (fvm flutter test)

**Linux Commands:**
- `make linux-build` - Full from-scratch build for Linux platform (includes deps, frb generation, Rust library compilation, and Flutter app build)

**Android Commands:**
- `make android-build` - Full from-scratch build for Android (includes deps, frb generation, Rust library compilation for all Android architectures, and Flutter app build for debug variant)
- `make android-run` - Full from-scratch build first, then run app on connected Android device/emulator
- `make android-install` - Full from-scratch build first, then install debug APK on connected Android device

> **Note on Build Completeness**: ALL build-related commands perform a complete build from scratch. There are no partial builds or assume-already-built scenarios. Each command includes ALL necessary build steps:
> - Dependency resolution (`make deps` equivalent)
> - Flutter Rust Bridge code generation (`make generate` equivalent)
> - Rust library compilation (platform-specific)
> - Flutter application build

All other existing Makefile targets will be removed, including:
- Separate Rust build targets (native-build, native-release, native-test)
- Individual architecture-specific Android builds
- Separate Flutter test and analyze commands
- Utility commands like deps, generate, format, lint
- Multiple variant targets (release variants, etc.)

## Capabilities

### New Capabilities

No new capabilities will be added. This change is purely about reduction and simplification.

### Modified Capabilities

- **Complete Build Process**: ALL build commands (`make build`, `make linux-build`, `make android-build`) perform a complete build from scratch, including:
  - Dependency resolution (`make deps`)
  - Flutter Rust Bridge code generation (`make generate`)
  - Rust library compilation (platform-specific)
  - Flutter application build
- **Android Run/Install**: The `make android-run` and `make android-install` commands first perform a complete from-scratch build (same as `make android-build`), then run or install the resulting APK
- **Android Build**: Consolidated from multiple architecture-specific targets into a single `android-build` command that builds for all Android architectures as part of a complete from-scratch build
- **Android Installation**: New `android-install` command specifically for installing debug APKs on connected devices (after complete from-scratch build)

### Removed Capabilities

- **Rust-only Builds**: Commands like `native-build`, `native-release`, and `native-test` are removed
- **Individual Architecture Builds**: Android architecture-specific builds (arm64-v8a, armeabi-v7a, x86_64) are now handled internally by the unified `android-build` command
- **Separate Flutter Commands**: `flutter analyze`, `flutter format` are removed as Makefile targets; however, `make test` is retained as the unified test command
- **Dependency Management**: `make deps` and `make generate` are removed
- **Code Quality Commands**: `make lint`, `make rust-lint`, `make format` are removed
- **Cross-platform Commands**: Commands for platforms not currently supported or rarely used are removed
- **Verification Commands**: `make verify-deps`, `make verify-sync` are removed

## Impact

**On Developers:**
- Developers will need to run Flutter/Dart/Rust commands directly for tasks like linting or dependency management (testing is available via `make test`)
- The development workflow becomes simpler with fewer, more focused options
- New contributors face less confusion about which command to use

**On CI/CD:**
- CI/CD pipelines may need to be updated to call Flutter/Dart/Rust commands directly instead of Makefile targets
- Build scripts that previously relied on specific Makefile targets will need refactoring

**On Documentation:**
- AGENTS.md will be updated to reflect the simplified Makefile structure
- README.md build instructions will be revised to use the new simplified commands
- Any other documentation referencing removed Makefile targets will need updates

**On Build Process:**
- The build process remains functionally equivalent for common development tasks
- The full build pipeline (`make build`) still produces complete, deployable artifacts
- Platform-specific builds work exactly as before, just through consolidated commands
- **All build commands are self-contained**: Every build command (linux-build, android-build, android-run, android-install) includes ALL necessary build steps from scratch. There are no partial builds or assume-already-built scenarios. Developers never need to manually run deps, generate, or Rust builds before using these commands.

**Risk Assessment:**
- Low risk for day-to-day development workflows (core commands preserved)
- Medium risk for automation and CI/CD (may need updates to call underlying tools directly)
- Low risk for code correctness (no functional changes to build logic)
