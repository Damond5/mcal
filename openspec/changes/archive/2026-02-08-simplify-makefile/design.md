## Context

The MCAL project Makefile has grown organically over time with an extensive list of platform-specific commands. This complexity makes the build system difficult to maintain, understand, and use. Many commands are redundant, some are rarely used, and the proliferation of targets creates confusion about which commands are actually needed for common development workflows.

This design document outlines the technical approach for simplifying and refactoring the Makefile to include only bare minimum commands that cover essential development tasks.

## Goals / Non-Goals

**Goals:**
- Reduce the Makefile to essential commands only
- Eliminate redundant, rarely-used, or duplicate commands
- Consolidate platform-specific commands into unified targets
- Ensure all build commands perform complete from-scratch builds
- Improve developer onboarding with a clear, focused set of options
- Make the build process more intuitive for new contributors

**Non-Goals:**
- Add new capabilities beyond current functionality
- Change the underlying build logic or processes
- Modify Flutter or Rust code (only Makefile changes)
- Support platforms beyond Linux and Android
- Change the project's tech stack or architecture

## Decisions

### 1. Decision: General Commands Consolidation

**Description:** Consolidate all general-purpose commands into two essential targets.

**Implementation:**
```makefile
# General cleanup of all build artifacts across all platforms
clean:
	fvm flutter clean
	cd native && cargo clean
	rm -rf build/

# Full build from scratch for current platform
build: deps generate native-build
	@if [ $(uname -s) = "Linux" ]; then \
		fvm flutter build linux --release; \
	elif [ $(uname -s) = "Darwin" ] || [ $(uname -s) = *"Android"* ]; then \
		fvm flutter build apk --debug; \
	else \
		echo "Error: Unsupported platform $(uname -s)"; \
		exit 1; \
	fi
```

**Rationale:** Developers need a simple way to clean and build without multiple redundant commands.

**Alternatives considered:**
- Keep separate platform-specific clean commands: Rejected as unnecessary verbosity
- Separate deps/generate targets: Rejected as they should be internal to build process
- Static APK build: Rejected - build should be platform-aware

### 2. Decision: Development Commands

**Description:** Provide unified development commands that include complete build process.

**Implementation:**
```makefile
# Run app on current platform
run: deps generate native-build
	fvm flutter run

# Run tests on current platform
test:
	fvm flutter test
```

**Rationale:** Developers need simple commands for the most common development tasks without manual prerequisite steps.

**Alternatives considered:**
- Separate run without build: Rejected as stale builds cause confusion
- Multiple test variants: Rejected as over-engineering for current needs
- External test configuration: Rejected for simplicity

### 3. Decision: Linux-Specific Build Command

**Description:** Provide a complete from-scratch build command for Linux platform.

**Implementation:**
```makefile
# Full from-scratch build for Linux platform
linux-build: deps generate native-build
	fvm flutter build linux --release
```

**Rationale:** Linux builds require specificFlutter build command and should include all prerequisites.

**Alternatives considered:**
- Platform detection and auto-selection: Rejected as less explicit
- Separate debug/release builds: Rejected as not currently needed
- Architecture-specific Linux builds: Rejected as over-engineering

### 4. Decision: Android Build Consolidation

**Description:** Consolidate all Android build functionality into a single command that builds for all architectures.

**Implementation:**
```makefile
# Full from-scratch build for Android (all architectures)
android-build: deps generate native-android-build
	fvm flutter build apk --debug
```

**Rationale:** Developers should not need to manage architecture-specific builds manually.

**Alternatives considered:**
- Separate debug/release builds: Rejected as not currently differentiated in requirements
- Individual architecture targets: Rejected as unnecessary complexity
- Configurable architecture selection: Rejected for simplicity

### 5. Decision: Android Run Command

**Description:** Complete from-scratch build first, then run on connected Android device.

**Implementation:**
```makefile
# Full build first, then run on Android device
android-run: android-build
	fvm flutter run
```

**Rationale:** Ensures fresh build before running, avoiding stale code issues.

**Alternatives considered:**
- Run without build: Rejected as stale builds cause confusion
- Separate device selection: Rejected as handled by Flutter
- Parallel build and run: Rejected for potential race conditions

### 6. Decision: Android Install Command

**Description:** Complete from-scratch build first, then install debug APK on connected device.

**Implementation:**
```makefile
# Full build first, then install debug APK
android-install: android-build
	fvm flutter install
```

**Rationale:** Provides simple APK installation without manual APK path management.

**Alternatives considered:**
- Direct adb install: Rejected as Flutter handles this better
- Installation without build: Rejected as would install stale APK
- Multiple installation targets: Rejected for simplicity

### 7. Decision: Complete Build Process Requirement

**Description:** ALL build commands perform complete from-scratch builds including all prerequisites.

**Implementation:**
```makefile
# Every build target includes all necessary steps
android-build: deps generate native-android-build
	fvm flutter build apk --debug

linux-build: deps generate native-build
	fvm flutter build linux --release

build: deps generate native-build
	fvm flutter build apk --debug
```

**Rationale:** Developers should never need to manually run prerequisite commands. The Makefile handles all dependencies internally.

**Alternatives considered:**
- Partial builds for speed: Rejected as causes confusion and stale builds
- Dependency detection at runtime: Rejected for complexity
- External build orchestration: Rejected for Makefile simplicity

### 8. Decision: Native Build Integration

**Description:** Native builds (Rust libraries) are incorporated into platform-specific build commands.

**Implementation:**
```makefile
# Linux native build
native-build:
	cd native && cargo build --release

# Android native build (all architectures)
native-android-build:
	cd native && cargo ndk -t aarch64-linux-android build --release
	cd native && cargo ndk -t armeabi-v7a build --release
	cd native && cargo ndk -t x86_64-linux-android build --release
```

**Rationale:** Rust compilation is platform-specific and should be handled by dedicated targets integrated into build commands.

**Alternatives considered:**
- Separate Rust build commands: Rejected as creates unnecessary complexity
- Automatic platform detection: Rejected for less explicit control
- External Rust build script: Rejected for Makefile portability

### 9. Decision: Removed Commands

**Description:** Remove all commands not aligned with the simplified target set.

**Removed Commands:**
- `native-build`, `native-release`, `native-test` - Consolidated into build commands
- Architecture-specific Android builds - Handled internally
- `flutter analyze`, `flutter format` - Call directly if needed
- `deps`, `generate` - Internal to build process
- `lint`, `rust-lint`, `format` - Call directly if needed
- `verify-deps`, `verify-sync` - Removed for simplicity
- Cross-platform commands - Not currently supported
- Multiple variant targets - Not currently needed

**Rationale:** Eliminates noise and reduces maintenance burden while preserving core functionality.

**Alternatives considered:**
- Deprecate with warnings: Rejected as doesn't simplify the Makefile
- Move to separate file: Rejected as still creates complexity
- Keep but hide: Rejected as confusing for developers

### 10. Decision: Error Handling Approach

**Description:** Use bash error handling for reliable command execution.

**Implementation:**
```makefile
# Enable error handling
set -e

# For commands that may fail but shouldn't stop execution
@command || echo "Warning: command failed but continuing..."
```

**Rationale:** Ensures failures are caught and reported appropriately.

**Alternatives considered:**
- No error handling: Rejected as silent failures are problematic
- Complex error trapping: Rejected for simplicity
- External error handling: Rejected for portability

## Risks / Trade-offs

**Risk: Breaking Existing Workflows**
- **Mitigation:** Core development commands (build, run, test) are preserved
- **Mitigation:** Developers can still call Flutter/Dart/Rust commands directly
- **Mitigation:** Documentation will be updated to reflect changes

**Risk: CI/CD Pipeline Updates Required**
- **Mitigation:** Clear documentation of direct tool invocations
- **Mitigation:** Changes are documented in CHANGELOG.md
- **Mitigation:** Gradual migration path available

**Trade-off: Simplicity vs. Flexibility**
- **Decision:** Prioritize simplicity over maximum flexibility
- **Rationale:** Core development tasks are preserved; edge cases can use direct tool calls

**Trade-off: Build Time vs. Convenience**
- **Decision:** Always perform complete builds
- **Rationale:** Avoids stale build issues; developers don't need to manage dependencies manually

**Trade-off: Number of Targets vs. Clarity**
- **Decision:** Minimal set of clear, focused targets
- **Rationale:** Reduces confusion and maintenance burden

## Implementation Summary

### Makefile Changes

1. **General Commands**: `clean`, `build` (complete from-scratch build)
2. **Development Commands**: `run`, `test` (complete build before run)
3. **Linux Commands**: `linux-build` (complete from-scratch Linux build)
4. **Android Commands**: `android-build`, `android-run`, `android-install`
5. **Internal Targets**: `deps`, `generate`, `native-build`, `native-android-build`

### Removed Commands

1. Rust-only build commands
2. Architecture-specific Android builds
3. Separate Flutter utility commands
4. Dependency management commands
5. Code quality commands
6. Verification commands
7. Cross-platform commands

### Documentation Updates Required

1. Update AGENTS.md with new Makefile commands
2. Update README.md with simplified build instructions
3. Update CHANGELOG.md with removal of old commands

### Testing Approach

1. Verify all preserved commands work correctly
2. Confirm complete build process for each target
3. Test error handling for missing dependencies
4. Verify build artifacts are produced correctly
5. Test on both Linux and Android platforms
