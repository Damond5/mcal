## Context

The MCAL project uses a Makefile as the central orchestration point for cross-platform build workflows, development tasks, and automation. The project uses Flutter Version Management (fvm) for consistent Flutter versions and requires reliable Rust library builds for multiple platforms (Linux, Android). The current Makefile has several issues that need to be addressed:

1. **Reliability concerns**: Some targets may fail silently or lack proper exit code handling
2. **Error message quality**: Error messages need to be more actionable and include diagnostic information
3. **Dependency management**: Some targets have suboptimal dependency chains
4. **Cross-platform consistency**: Need to ensure consistent behavior across Linux, Android, and iOS platforms
5. **Documentation**: While a help target exists, it can be improved with better examples and troubleshooting guidance

This design document outlines the technical approach for fixing and optimizing the Makefile targets to meet all specifications from the completed spec files.

## Goals / Non-Goals

**Goals:**
- Fix all existing Makefile targets to execute reliably without silent failures
- Implement proper exit code handling for all targets
- Improve error messages to be clear, actionable, and include diagnostic information
- Optimize dependency chains for build targets
- Ensure cross-platform consistency for all workflow targets
- Improve inline help and documentation
- Add comprehensive dependency verification before target execution

**Non-Goals:**
- Restructure the Makefile architecture fundamentally
- Add new major features beyond the defined specifications
- Modify Flutter or Rust code (only Makefile changes)
- Support platforms beyond Linux, Android, and iOS
- Change the project's tech stack or architecture

## Decisions

### 1. Decision: Implement Shell Command Error Handling Strategy

**Description:** All Makefile targets will use bash's `set -e` with proper error trapping and meaningful exit codes. Commands that may fail will have explicit error handling with actionable messages.

**Implementation:**
```makefile
# At the start of relevant targets
set -e
trap 'echo "Error: Command failed at line $$LINENO"; exit 1' ERR

# For commands that may fail but shouldn't stop execution
@command || echo "Warning: command failed but continuing..."
```

**Rationale:** This ensures that failures are caught immediately and reported with context, making debugging easier while allowing controlled recovery where appropriate.

**Alternatives considered:**
- Continue without error handling: Rejected because silent failures are a primary concern
- Complex error trapping for all targets: Rejected as overkill for simple targets
- External error handling script: Rejected for simplicity and portability

### 2. Decision: Unified Dependency Verification Approach

**Description:** Create a reusable make include file or function for dependency verification that checks for required tools before executing targets.

**Implementation:**
```makefile
# Helper function for dependency checking
define check_dep
	@if ! command -v $(1) &> /dev/null; then \
		echo "Error: $(1) is not installed or not in PATH"; \
		echo "  Install with: $(2)"; \
		exit 1; \
	fi
endef

# Usage in targets
verify-fvm:
	$(call check_dep,fvm,"dart pub global activate fvm")
```

**Rationale:** Provides consistent dependency checking across all targets while keeping the Makefile DRY and maintainable.

**Alternatives considered:**
- Individual checks in each target: Rejected due to code duplication
- Separate verification target only: Rejected because it doesn't prevent accidental execution without verification
- Shell function with eval: Rejected for complexity

### 3. Decision: Structured Error Message Format

**Description:** Implement a standard error message format across all targets with clear structure: ERROR category, message, suggested action, and reference documentation.

**Implementation:**
```makefile
define error_msg
	@echo "ERROR [$(1)]: $(2)"
	@echo "  Suggestion: $(3)"
	@echo "  See: $(4)"
endef
```

**Rationale:** Consistency in error messages makes it easier for developers to understand and resolve issues quickly.

**Alternatives considered:**
- Free-form error messages: Rejected for inconsistent user experience
- Just exit codes without messages: Rejected as not actionable enough
- External error handling library: Rejected to avoid dependencies

### 4. Decision: Android Library Build Process Improvement

**Description:** Improve the `android-libs` target to use proper error handling, better architecture detection, and more robust file copying with verification.

**Implementation:**
```makefile
android-libs:
	@echo "Building Rust libraries for all Android architectures..."
	@for target in $(ANDROID_TARGETS); do \
		echo "  Building for $$target..."; \
		cd native && cargo ndk -t $$target build --release || { \
			echo "Error: Failed to build for $$target"; \
			exit 1; \
		}; \
		cd ..; \
	done
	@echo "Verifying and copying libraries..."
	@cp native/target/aarch64-linux-android/release/libmcal_native.so \
		android/app/src/main/cpp/libs/arm64-v8a/ || { \
		echo "Error: Failed to copy arm64-v8a library"; \
		exit 1; \
	}
	# ... similar for other architectures
	@echo "Android native libraries built successfully"
```

**Rationale:** The current implementation has error suppression (2>/dev/null) that hides failures. This change makes errors visible while maintaining the loop structure.

**Alternatives considered:**
- Parallel builds: Rejected due to potential race conditions in cargo ndk
- Separate targets per architecture: Rejected for verbosity
- External build script: Rejected for Makefile portability

### 5. Decision: fvm Usage Verification and Fallback

**Description:** Ensure all Flutter commands use fvm properly, with verification that fvm is installed and working before execution.

**Implementation:**
```makefile
# fvm wrapper that verifies installation
FVM_FLUTTER = fvm flutter

verify-fvm-installed:
	@if ! command -v fvm &> /dev/null; then \
		echo "Error: fvm (Flutter Version Management) is not installed"; \
		echo "  Install with: dart pub global activate fvm"; \
		echo "  Then run: fvm install"; \
		exit 1; \
	fi
	@if [ ! -d ".fvm/flutter_sdk" ]; then \
		echo "Error: fvm Flutter SDK not found. Run 'fvm install' first."; \
		exit 1; \
	fi
```

**Rationale:** Prevents cryptic errors when fvm is not properly set up and provides clear recovery instructions.

**Alternatives considered:**
- Assume fvm is always available: Rejected as not robust enough
- Only verify on certain targets: Rejected for inconsistency
- Docker container with fvm pre-installed: Rejected as it changes the development environment

### 6. Decision: Help Target Enhancement

**Description:** Enhance the help target to include usage examples, troubleshooting tips, and better organization of targets by category.

**Implementation:**
```makefile
help:
	@echo "MCal Build System"
	@echo ""
	@echo "Quick Start:"
	@echo "  make deps          # Install dependencies (first time setup)"
	@echo "  make generate      # Generate Flutter Rust Bridge code"
	@echo "  make linux-run     # Run app on Linux (development)"
	@echo ""
	@echo "Common Tasks:"
	@echo "  make analyze       # Run Flutter analyzer"
	@echo "  make test          # Run all tests"
	@echo "  make format        # Format Dart and Rust code"
	@echo ""
	@echo "Linux:"
	@echo "  linux-run, linux-build, linux-test, linux-analyze, linux-clean"
	@echo ""
	@echo "Android:"
	@echo "  android-build, android-release, android-test, android-run"
	@echo "  android-libs, android-clean, install-apk"
	@echo ""
	@echo "Rust:"
	@echo "  native-build, native-release, native-test"
	@echo ""
	@echo "Utilities:"
	@echo "  clean, lint, rust-lint, verify-deps, devices"
	@echo ""
	@echo "Troubleshooting:"
	@echo "  Run 'make verify-deps' to check your development environment"
	@echo "  See README.md for platform-specific setup instructions"
```

**Rationale:** Better organized help with examples reduces developer friction and improves onboarding.

**Alternatives considered:**
- Auto-generated help from comments: Rejected for limited information
- External documentation only: Rejected as not self-documenting
- Interactive help wizard: Rejected for complexity

### 7. Decision: Output Path Consistency Strategy

**Description:** Define and document all output paths consistently, with verification steps after builds to confirm artifacts are in expected locations.

**Implementation:**
```makefile
# Define output paths
ANDROID_DEBUG_APK := build/app/outputs/flutter-apk/app-debug.apk
ANDROID_RELEASE_APK := android/app/build/outputs/apk/release/app-release.apk
LINUX_BUILD_DIR := build/linux/

verify-output:
	@echo "Verifying build outputs..."
	@if [ -f "$(ANDROID_DEBUG_APK)" ]; then \
		echo "  Android debug APK: $(ANDROID_DEBUG_APK)"; \
	else \
		echo "Warning: $(ANDROID_DEBUG_APK) not found"; \
	fi
	@echo ""
	@echo "Build verification complete"
```

**Rationale:** Consistent, predictable output paths make automation and CI/CD pipelines more reliable.

**Alternatives considered:**
- Dynamic output paths: Rejected for unpredictability
- Only verify on failure: Rejected for incomplete coverage
- External path configuration: Rejected for simplicity

### 8. Decision: Target Dependency Optimization

**Description:** Optimize the dependency relationships between targets to minimize unnecessary rebuilds while ensuring correctness.

**Implementation:**
```makefile
# Optimized dependencies
android-build: android-libs generate deps
	@echo "Building Android APK (debug)..."
	fvm flutter clean
	fvm flutter pub get
	fvm flutter build apk --debug

android-release: android-libs generate deps
	@echo "Building Android APK (release)..."
	fvm flutter clean
	fvm flutter pub get
	fvm flutter build apk --release
```

**Rationale:** Explicitly declaring deps ensures proper ordering while `flutter clean` is appropriate before full builds to avoid cached issues.

**Alternatives considered:**
- No dependencies: Rejected as it allows incorrect execution order
- All targets depend on all prerequisites: Rejected for excessive rebuilds
- Runtime dependency checking: Rejected for complexity

### 9. Decision: Cross-Platform Path Handling

**Description:** Use consistent path separators and avoid hardcoded platform-specific paths that could cause issues.

**Implementation:**
```makefile
# Use forward slashes which work on both Linux and Windows (via Git Bash/WSL)
# For paths that must be platform-specific, use conditionals
ifeq ($(OS),Windows_NT)
	NDK_PATH := $(ANDROID_NDK_HOME)\\toolchains\\llvm\\prebuilt\\windows-x86_64
else
	NDK_PATH := $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64
endif
```

**Rationale:** While primary development is on Linux, consistent paths improve portability and reduce subtle bugs.

**Alternatives considered:**
- Always use platform-specific paths: Rejected for duplication
- Assume Linux only: Rejected as not cross-platform friendly
- External path resolution script: Rejected for complexity

### 10. Decision: Success Feedback Implementation

**Description:** Provide clear, informative success messages without excessive verbosity, including relevant output information and timing where useful.

**Implementation:**
```makefile
android-build: android-libs generate deps
	@echo "Building Android APK (debug)..."
	fvm flutter clean
	fvm flutter pub get
	fvm flutter build apk --debug
	@echo ""
	@echo "SUCCESS: Android debug APK built"
	@echo "  Output: build/app/outputs/flutter-apk/app-debug.apk"
	@echo "  Size: $$(ls -lh build/app/outputs/flutter-apk/app-debug.apk | awk '{print $$5}')"
```

**Rationale:** Clear success confirmation provides feedback without requiring users to check output locations manually.

**Alternatives considered:**
- No success messages: Rejected as developers don't know if command completed
- Detailed output always shown: Rejected as too verbose
- Log file only: Rejected as not visible enough

### 11. Decision: android-run Device Selection Improvement

**Description:** Improve the android-run target to handle device selection more robustly with better error handling.

**Implementation:**
```makefile
android-run:
	@echo "Checking for connected Android devices..."
	@DEVICE_ID := $$(fvm flutter devices --machine 2>/dev/null | grep -o '"id": *"[^"]*"' | head -1 | cut -d'"' -f4); \
	if [ -z "$$DEVICE_ID" ]; then \
		echo "Error: No Android device found"; \
		echo "  Ensure a device is connected via USB with USB debugging enabled"; \
		echo "  Or start an Android emulator"; \
		exit 1; \
	fi; \
	echo "Running on device: $$DEVICE_ID"; \
	fvm flutter run -d $$DEVICE_ID
```

**Rationale:** The current implementation can fail silently or with unclear errors when no device is available.

**Alternatives considered:**
- Always require explicit device ID: Rejected for convenience
- Show device list and prompt: Rejected for non-interactive compatibility
- Use default device only: Rejected for unpredictability

## Risks / Trade-offs

**Risk: Breaking Existing Workflows**
- **Mitigation:** Changes are primarily additions and improvements; core behavior of existing targets will remain the same
- **Mitigation:** Test all targets thoroughly after changes

**Risk: Increased Makefile Complexity**
- **Mitigation:** Keep error handling patterns consistent and well-documented
- **Mitigation:** Use make functions and includes to reduce duplication

**Risk: Cross-Platform Compatibility Issues**
- **Mitigation:** Test on all supported platforms (Linux, Android, iOS)
- **Mitigation:** Use portable shell constructs and avoid bash-specific features where possible

**Trade-off: Verbosity vs. Conciseness**
- **Decision:** Prioritize clear, actionable output over minimal verbosity
- **Rationale:** Developer experience is more important than terse output

**Trade-off: Error Handling Strictness**
- **Decision:** Use `set -e` with selective opt-outs for commands that may fail but shouldn't stop execution
- **Rationale:** Balances robustness with practical flexibility

**Trade-off: Performance vs. Safety**
- **Decision:** Accept slight performance overhead for reliable error detection
- **Rationale:** Build reliability is more important than marginal speed improvements

## Implementation Summary

### Specific Makefile Changes

1. **Error Handling Layer**: Add `set -e` and trap statements for critical targets
2. **Dependency Verification**: Create reusable `verify-deps` function and integrate into key targets
3. **android-libs Target**: Improve error handling in the architecture build loop with explicit error messages
4. **android-run Target**: Implement robust device detection with clear error messages
5. **generate Target**: Add fvm flutter prefix to ensure consistent Flutter version
6. **help Target**: Reorganize with examples, troubleshooting tips, and better categorization
7. **All Build Targets**: Add success confirmation messages with output locations
8. **verify-sync Target**: Improve error handling for file existence checks
9. **Output Path Verification**: Add verification steps after builds to confirm artifacts exist
10. **Error Message Standardization**: Implement consistent error format across all targets

### Testing Approach

1. **Manual Testing**: Execute each target on each supported platform
2. **Error Scenario Testing**: Verify error messages appear correctly for missing dependencies
3. **Output Verification**: Confirm build artifacts are in expected locations
4. **Exit Code Testing**: Verify non-zero exit codes on failure scenarios
5. **Help Verification**: Confirm help target displays all targets correctly

### Documentation Updates

1. Update help target with enhanced information
2. Add troubleshooting section to help output
3. Document any platform-specific behaviors
4. Ensure error messages reference documentation URLs
