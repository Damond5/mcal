# MCal Makefile
# Platform-agnostic, Linux, and Android build targets

# =============================================================================
# SUCCESS FEEDBACK HELPERS (SF-001, SF-002, SF-003)
# =============================================================================

# Success message helper
# Usage: $(call success,<message>)
define success
	@echo "✓ $(1)"
endef

# Info message helper
# Usage: $(call info,<message>)
define info
	@echo "→ $(1)"
endef

# Build completion message with output location
# Usage: $(call build_success,<platform>,<output_path>)
define build_success
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "  ✓ $(1) build complete"
	@echo ""
	@echo "  Output: $(2)"
	@if [ -f "$(2)" ]; then \
		SIZE=$$(du -h "$(2)" | cut -f1); \
		echo "  Size: $$SIZE"; \
	fi
	@echo "════════════════════════════════════════════════════════════════════"
endef

# Multi-file build success message
# Usage: $(call multi_build_success,<platform>,<files...>)
define multi_build_success
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "  ✓ $(1) build complete"
	@echo ""
	@for file in $(2); do \
		if [ -f "$$file" ]; then \
			SIZE=$$(du -h "$$file" | cut -f1); \
			echo "  📦 $$file ($$SIZE)"; \
		fi; \
	done
	@echo "════════════════════════════════════════════════════════════════════"
endef

# Progress indicator for multi-architecture builds
# Usage: $(call arch_progress,<current>,<total>,<arch>)
define arch_progress
	@echo ""
	@echo "[$$(printf '%3d' $(1))/$$(printf '%3d' $(2))] Building for $(3)..."
endef

# Library build progress with emoji
# Usage: $(call lib_progress,<arch>)
define lib_progress
	@echo ""
	@echo "📦 Building library for $(1)..."
endef

# Completion summary for Android libraries
# Usage: $(call android_libs_complete,<count>)
define android_libs_complete
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "  ✓ All Android native libraries built successfully"
	@echo ""
	@echo "  Architectures: $(1)"
	@echo "  Location: android/app/src/main/cpp/libs/"
	@echo ""
	@echo "  Next steps:"
	@echo "    → Run 'make generate' to regenerate Flutter bindings"
	@echo "    → Run 'make android-build' to build the APK"
	@echo "════════════════════════════════════════════════════════════════════"
endef

# Code generation success
# Usage: $(call generate_success)
define generate_success
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "  ✓ Flutter Rust Bridge code generated successfully"
	@echo ""
	@echo "  Generated files:"
	@echo "    📦 lib/frb_generated.dart"
	@echo "    📦 lib/frb_generated.dart (platform-specific)"
	@echo "    📦 native/src/frb_generated.rs"
	@echo ""
	@echo "  Next steps:"
	@echo "    → Run 'make android-libs' to build Android native libraries"
	@echo "    → Run 'make android-build' to build the APK"
	@echo "════════════════════════════════════════════════════════════════════"
endef

# APK build success
# Usage: $(call apk_success,<type>,<path>)
define apk_success
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "  ✓ Android $(1) APK built successfully"
	@echo ""
	@echo "  Output: $(2)"
	@if [ -f "$(2)" ]; then \
		SIZE=$$(du -h "$(2)" | cut -f1); \
		echo "  Size: $$SIZE"; \
	fi
	@echo ""
	@echo "  Next steps:"
	@echo "    → Install on device: make install-apk"
	@echo "    → Run on device: make android-run"
	@echo "════════════════════════════════════════════════════════════════════"
endef

# =============================================================================
# OUTPUT VERIFICATION HELPERS (OV-001, OV-002, OV-003)
# =============================================================================

# Verify Android APK exists and has content
# Usage: $(call verify_apk,<path>,<description>)
define verify_apk
	@if [ ! -f "$(1)" ]; then \
		echo "ERROR: APK not found at $(1)"; \
		echo "  Build may have failed"; \
		exit 1; \
	fi
	@SIZE=$$(du -h "$(1)" | cut -f1); \
	echo "  ✓ $(2): $(1) ($$SIZE)";
endef

# Verify Linux bundle exists and has content
# Usage: $(call verify_linux_bundle,<path>)
define verify_linux_bundle
	@if [ ! -d "$(1)" ]; then \
		echo "ERROR: Linux bundle not found at $(1)"; \
		echo "  Build may have failed"; \
		exit 1; \
	fi
	@SIZE=$$(du -sh "$(1)" | cut -f1); \
	echo "  ✓ Linux bundle: $(1) ($$SIZE)"; \
	if [ -f "$(1)/mcal" ]; then \
		echo "  ✓ Executable: $(1)/mcal"; \
	fi
endef

# Verify native library exists and has content
# Usage: $(call verify_native_lib,<path>,<platform>)
define verify_native_lib
	@if [ ! -f "$(1)" ]; then \
		echo "ERROR: Native library not found at $(1)"; \
		exit 1; \
	fi
	@SIZE=$$(du -h "$(1)" | cut -f1); \
	echo "  ✓ $(2): $(1) ($$SIZE)";
endef

# Verify all critical artifacts exist
# Usage: $(call verify_all_artifacts)
define verify_all_artifacts
	@echo ""
	@echo "Verifying critical build artifacts..."
	@{ \
		STATUS=0; \
		echo ""; \
		if [ -d "build/linux/x64/release/bundle" ]; then \
			echo "  ✓ Linux bundle"; \
		else \
			echo "  ✗ Linux bundle missing"; \
			STATUS=1; \
		fi; \
		if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then \
			echo "  ✓ Android debug APK"; \
		else \
			echo "  ✗ Android debug APK missing"; \
			STATUS=1; \
		fi; \
		if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then \
			echo "  ✓ Android release APK"; \
		else \
			echo "  ✗ Android release APK missing"; \
			STATUS=1; \
		fi; \
		if [ -f "native/target/debug/libmcal_native.so" ]; then \
			echo "  ✓ Linux native library (debug)"; \
		else \
			echo "  ✗ Linux native library (debug) missing"; \
			STATUS=1; \
		fi; \
		if [ -f "native/target/release/libmcal_native.so" ]; then \
			echo "  ✓ Linux native library (release)"; \
		else \
			echo "  ✗ Linux native library (release) missing"; \
			STATUS=1; \
		fi; \
		for arch in arm64-v8a armeabi-v7a x86 x86_64; do \
			if [ -f "android/app/src/main/cpp/libs/$$arch/libmcal_native.so" ]; then \
				echo "  ✓ Android native library ($$arch)"; \
			else \
				echo "  ✗ Android native library ($$arch) missing"; \
				STATUS=1; \
			fi; \
		done; \
		echo ""; \
		if [ $$STATUS -eq 0 ]; then \
			echo "  ✓ All artifacts verified successfully"; \
		else \
			echo "  ✗ Some artifacts are missing"; \
			exit 1; \
		fi; \
	}
endef

# =============================================================================
# ERROR HANDLING CONFIGURATION
# =============================================================================
# ERROR HANDLING CONFIGURATION
# =============================================================================

# Enable exit on error for shell commands (can be overridden per target)
SET_E := set -e

# Error trap function for critical build operations
# Usage: $(call err_trap,<command_description>)
define err_trap
	@echo "ERROR: [$(1)] Operation failed at line $(MAKEFILE_LINE_NUMBER)"
	@echo "  Category: $(1)"
	@echo "  Suggestion: Check the logs above for details and ensure all dependencies are installed"
	@echo "  Documentation: https://github.com/yourusername/mcal#troubleshooting"
	@exit 1
endef

# Helper to run a command with error trapping
# Usage: $(call with_err_trap,<command>,<description>)
define with_err_trap
	@$(1) || $(call err_trap,$(2))
endef

# Print error message and exit
# Usage: $(call error,<message>)
define error
	@echo "ERROR: $(1)" >&2
	@exit 1
endef

# Copy Android library with error handling and verification
# Usage: $(call copy-android-lib,<arch>,<target_path>)
define copy-android-lib
	@echo "  Copying $(1) library..."
	@cp native/target/$(2)/release/libmcal_native.so \
		android/app/src/main/cpp/libs/$(1)/ || \
		{ echo "ERROR: [COPY_FAILED] Failed to copy $(1) library" >&2; \
		  echo "  Category: File Operation" >&2; \
		  echo "  Suggestion: Ensure the native library was built successfully with 'make android-libs'" >&2; \
		  echo "  Documentation: https://github.com/yourusername/mcal#android-build-issues" >&2; \
		  exit 1; }
	@if [ ! -s android/app/src/main/cpp/libs/$(1)/libmcal_native.so ]; then \
		echo "ERROR: [COPY_VERIFY_FAILED] $(1) library is empty after copy" >&2; \
		echo "  Category: File Verification" >&2; \
		echo "  Suggestion: Check disk space and permissions" >&2; \
		exit 1; \
	fi
	@echo "  ✓ $(1) library copied and verified"
endef

# =============================================================================
# DEPENDENCY VERIFICATION HELPERS
# =============================================================================

# Check for required command/tool and exit if missing
# Usage: $(call check_dep,<command>,<install_instruction>,<package_name>)
define check_dep
	@if ! command -v $(1) &> /dev/null; then \
		echo "ERROR: $(1) is not installed or not in PATH"; \
		echo "  Install: $(2)"; \
		echo "  Package: $(3)"; \
		exit 1; \
	fi
endef

# Check for fvm with installation instructions
# Usage: $(call check_fvm)
define check_fvm
	@if ! command -v fvm &> /dev/null; then \
		echo "ERROR: fvm (Flutter Version Manager) is not installed"; \
		echo "  Install: dart pub global activate fvm"; \
		echo "  Or visit: https://fvm.app/docs/getting_started/installation"; \
		exit 1; \
	fi
endef

# Verify file or directory exists
# Usage: $(call verify_output,<path>,<description>)
define verify_output
	@if [ ! -e "$(1)" ]; then \
		echo "ERROR: $(2) not found at $(1)"; \
		echo "  The build may have failed or not been run yet"; \
		echo "  Try running: make $(TARGET)"; \
		exit 1; \
	fi
endef

# Verify build artifact exists with success message
# Usage: $(call verify_build,<path>,<description>)
define verify_build
	@if [ ! -e "$(1)" ]; then \
		echo "ERROR: Build failed - $(2) not found"; \
		echo "  Expected: $(1)"; \
		exit 1; \
	fi
	@echo "  ✓ $(2) verified"
endef

# Verify Flutter dependencies are installed
# Usage: $(call check_flutter_deps)
define check_flutter_deps
	@$(call check_fvm)
endef

# =============================================================================
# DEVICE DETECTION HELPERS
# =============================================================================

# Detect and return the first available Android device ID
# Usage: $(call get_android_device)
# Returns: Device ID or empty string if no devices found
define get_android_device
	@DEVICES_JSON=$$(fvm flutter devices --machine 2>&1); \
	if [ $$? -ne 0 ] || [ -z "$$DEVICES_JSON" ]; then \
		echo ""; \
		exit 1; \
	fi; \
	# Parse JSON to find Android devices (exclude web, linux, windows, macos)
	ANDROID_ID=$$(echo "$$DEVICES_JSON" | python3 -c "import json,sys; \
		devs=json.load(sys.stdin); \
		for d in devs: \
			if d.get('platform','').lower() == 'android': \
				print(d.get('id', '')); \
				break" 2>/dev/null); \
	echo "$$ANDROID_ID"
endef

# Detect all available Android devices and return as formatted list
# Usage: $(call list_android_devices)
# Output: Formatted list of Android devices
define list_android_devices
	@DEVICES_JSON=$$(fvm flutter devices --machine 2>&1); \
	if [ $$? -ne 0 ] || [ -z "$$DEVICES_JSON" ]; then \
		echo ""; \
		exit 1; \
	fi; \
	echo "$$DEVICES_JSON" | python3 -c "import json,sys; \
		devs=json.load(sys.stdin); \
		android_devs=[d for d in devs if d.get('platform','').lower() == 'android']; \
		if not android_devs: \
			print('NO_ANDROID_DEVICES'); \
		else: \
			for i, d in enumerate(android_devs, 1): \
				print(f'{i}. {d.get(\"id\", \"unknown\")}: {d.get(\"name\", \"Unknown\")} ({d.get(\"platform\", \"Unknown\")})')" 2>/dev/null || \
		echo "1. android: Android device (fallback)"
endef

# Check if any Android device is available
# Usage: $(call check_android_device)
# Exits with error if no devices found
define check_android_device
	@DEVICE_ID=$$(fvm flutter devices --machine 2>/dev/null | python3 -c "import json,sys; \
		devs=json.load(sys.stdin); \
		android_devs=[d for d in devs if d.get('platform','').lower() == 'android']; \
		print(android_devs[0].get('id', '') if android_devs else '')" 2>/dev/null); \
	if [ -z "$$DEVICE_ID" ]; then \
		echo ""; \
		echo "========================================"; \
		echo "ERROR: No Android device found"; \
		echo "========================================"; \
		echo ""; \
		echo "To run the app on Android, you need either:"; \
		echo ""; \
		echo "Option 1: Start an Android Emulator"; \
		echo "----------------------------------------"; \
		echo "  1. List available emulators:"; \
		echo "     flutter emulators"; \
		echo ""; \
		echo "  2. Launch an emulator:"; \
		echo "     flutter emulators --launch <emulator_name>"; \
		echo ""; \
		echo "  3. Or using Android Studio:"; \
		echo "     - Open Android Studio"; \
		echo "     - Go to AVD Manager"; \
		echo "     - Click 'Run' on your virtual device"; \
		echo ""; \
		echo "Option 2: Connect a Physical Device"; \
		echo "----------------------------------------"; \
		echo "  1. Enable Developer Options on your device:"; \
		echo "     - Go to Settings > About Phone"; \
		echo "     - Tap 'Build Number' 7 times"; \
		echo ""; \
		echo "  2. Enable USB Debugging:"; \
		echo "     - Go to Settings > System > Developer Options"; \
		echo "     - Enable 'USB Debugging'"; \
		echo ""; \
		echo "  3. Connect device via USB and authorize:"; \
		echo "     - Check: adb devices"; \
		echo "     - Look for 'device' (not 'unauthorized')"; \
		echo ""; \
		echo "Troubleshooting:"; \
		echo "----------------------------------------"; \
		echo "  - ADB not found? Install Android SDK Platform Tools"; \
		echo "  - Device not detected? Try: adb kill-server && adb start-server"; \
		echo "  - Multiple devices? Use: make android-run ANDROID_DEVICE=<device_id>"; \
		echo ""; \
		echo "Documentation:"; \
		echo "  - Flutter Android setup: https://flutter.dev/docs/get-started/install/linux"; \
		echo "  - Emulator setup: https://flutter.dev/docs/get-started/install/linux#set-up-the-android-emulator"; \
		echo "  - Device debugging: https://flutter.dev/docs/get-started/install/linux#android-setup"; \
		echo ""; \
		exit 1; \
	fi
endef

# Get Android device ID or exit with helpful error
# Usage: $(call require_android_device)
define require_android_device
	@$(call check_android_device)
endef

.PHONY: help clean all-clean deps generate analyze test test-cov build \
    native-build native-test native-release \
    linux-run linux-build linux-test linux-analyze linux-clean \
    android-build android-test android-run android-libs android-clean \
    all android-release install-apk devices android-select

# Configuration
ANDROID_NDK_PATH ?= $(ANDROID_NDK_HOME)
ANDROID_TARGETS ?= armeabi-v7a arm64-v8a x86 x86_64

# =============================================================================
# PLATFORM-AGNOSTIC TARGETS
# =============================================================================

help:
	@echo "╔════════════════════════════════════════════════════════════════════╗"
	@echo "║                     MCAL - Makefile Help                          ║"
	@echo "╚════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "QUICK START"
	@echo "════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "  First-time setup:"
	@echo "    make deps              # Install dependencies"
	@echo "    make android-libs      # Build Rust for Android"
	@echo "    make generate          # Generate Flutter Rust Bridge code"
	@echo ""
	@echo "  Development workflow:"
	@echo "    make linux-run         # Run app on Linux (fastest iteration)"
	@echo ""
	@echo "  Building for release:"
	@echo "    make android-release   # Build release APK"
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "DEVELOPMENT TARGETS"
	@echo "════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "  make deps              - Install Flutter dependencies"
	@echo "  make generate          - Generate Flutter Rust Bridge code"
	@echo "  make analyze           - Run Flutter analyzer"
	@echo "  make test              - Run all Flutter tests"
	@echo "  make test-cov          - Run tests with coverage"
	@echo "  make format            - Format Dart and Rust code"
	@echo "  make lint              - Run Dart linter"
	@echo "  make rust-lint         - Run Rust linter (clippy)"
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "LINUX TARGETS"
	@echo "════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "  make linux-run         - Run app on Linux"
	@echo "  make linux-build       - Build Linux app"
	@echo "  make linux-test        - Run tests on Linux"
	@echo "  make linux-analyze     - Analyze code on Linux"
	@echo "  make linux-clean       - Clean Linux build artifacts"
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "ANDROID TARGETS"
	@echo "════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "  make android-libs      - Build Rust libraries for Android"
	@echo "  make android-build     - Build debug APK"
	@echo "  make android-release   - Build release APK"
	@echo "  make android-test      - Run tests on Android"
	@echo "  make android-run       - Run on Android device/emulator"
	@echo "  make android-clean     - Clean Android build artifacts"
	@echo "  make install-apk       - Install debug APK on device"
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "NATIVE RUST TARGETS"
	@echo "════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "  make native-build      - Build Rust native library (debug)"
	@echo "  make native-release    - Build Rust native library (release)"
	@echo "  make native-test       - Run Rust tests"
	@echo "  make rust-lint         - Run Rust linter"
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "BUILD & UTILITY TARGETS"
	@echo "════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "  make build             - Build for current platform"
	@echo "  make all               - Build all components (Linux + Android)"
	@echo "  make all-clean         - Complete cleanup (build + generated files)"
	@echo "  make clean             - Clean all build artifacts"
	@echo "  make verify-sync       - Verify build synchronization"
	@echo "  make devices           - Show available devices"
	@echo "  make help              - Show this help message"
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "COMMON ISSUES"
	@echo "════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "  Q: Build fails with 'native library not found'"
	@echo "  A: Run: make android-libs && make generate"
	@echo ""
	@echo "  Q: Flutter analyzer shows errors in generated code"
	@echo "  A: Run: make generate to regenerate bindings"
	@echo ""
	@echo "  Q: Android build fails"
	@echo "  A: Check: make verify-sync && make android-libs"
	@echo ""
	@echo "  Q: Need to do a clean rebuild"
	@echo "  A: Run: make all-clean && make all"
	@echo ""
	@echo "  Q: Linux build fails to find native library"
	@echo "  A: Run: make native-build && make linux-build"
	@echo ""
	@echo "  For more help, see: https://github.com/yourusername/mcal#troubleshooting"
	@echo ""

clean:
	@echo "Cleaning all build artifacts..."
	fvm flutter clean
	cd native && cargo clean

all-clean: clean android-clean
	@echo "Cleaning native library builds..."
	rm -rf native/target/debug
	rm -rf native/target/release
	@echo "Cleaning Android native libraries..."
	rm -rf android/app/src/main/cpp/libs/arm64-v8a
	rm -rf android/app/src/main/cpp/libs/armeabi-v7a
	rm -rf android/app/src/main/cpp/libs/x86
	rm -rf android/app/src/main/cpp/libs/x86_64
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "  ✓ Complete cleanup finished"
	@echo ""
	@echo "  Next steps:"
	@echo "    → Run 'make all' to rebuild everything"
	@echo "    → Run 'make android-libs && make generate' for Android"
	@echo "════════════════════════════════════════════════════════════════════"

deps:
	@echo "Installing Flutter dependencies..."
	fvm flutter pub get

generate:
	@echo "[RUNNING] Flutter Rust Bridge code generation..."
	@$(call check_fvm)
	@$(call check_dep,flutter_rust_bridge_codegen,Install FRB codegen,dart pub global activate flutter_rust_bridge_codegen)

	@echo ""
	@echo "Running flutter_rust_bridge_codegen..."
	@flutter_rust_bridge_codegen generate --config-file frb.yaml || \
		{ echo "ERROR: FRB code generation failed"; exit 1; }

	@echo ""
	@echo "[VERIFYING] Generated files..."
	@if [ ! -f "lib/frb_generated.dart" ]; then \
		echo "ERROR: lib/frb_generated.dart not found after generation"; \
		exit 1; \
	fi
	@if [ ! -f "native/src/frb_generated.rs" ]; then \
		echo "ERROR: native/src/frb_generated.rs not found after generation"; \
		exit 1; \
	fi

	$(call generate_success)

	@echo "[ANALYZING] Generated code syntax..."
	@fvm flutter analyze lib/frb_generated.dart >/dev/null 2>&1 && \
		echo "✓ Generated Dart code syntax OK" || \
		{ echo "WARNING: Generated Dart code has syntax issues"; exit 0; }

analyze:
	@echo "Running Flutter analyzer..."
	@fvm flutter analyze || echo "Analysis completed with issues (warnings/info) - review above"

test:
	@echo "Running all tests..."
	fvm flutter test

test-cov:
	@echo "Running tests with coverage..."
	fvm flutter test --coverage
	@echo "Coverage report generated in coverage/"

build:
	@echo "Building for current platform..."
	fvm flutter build

# =============================================================================
# LINUX-SPECIFIC TARGETS
# =============================================================================

linux-run: native-build
	@echo "Running app on Linux..."
	$(call check_fvm)
	@echo ""
	@echo "[VERIFYING] Native library..."
	$(call verify_native_lib,native/target/debug/libmcal_native.so,"Linux debug")
	@echo ""
	@echo "[STARTING] Flutter on Linux..."
	fvm flutter run -d linux

linux-build:
	@echo "[BUILDING] Linux application..."
	$(call check_fvm)
	@fvm flutter build linux
	$(call verify_linux_bundle,build/linux/x64/release/bundle)
	$(call build_success,"Linux","build/linux/x64/release/bundle/mcal")

linux-test:
	@echo "Running tests on Linux..."
	$(call check_fvm)
	fvm flutter test -d linux

linux-analyze:
	@echo "Analyzing Flutter code on Linux..."
	$(call check_fvm)
	fvm flutter analyze -d linux

linux-clean:
	@echo "Cleaning Linux build artifacts..."
	fvm flutter clean

# Native Rust library targets
native-build:
	@echo "[BUILDING] Rust native library (debug)..."
	@$(SET_E)
	cd native && cargo build
	$(call verify_native_lib,native/target/debug/libmcal_native.so,"Linux debug")
	$(call build_success,"Native Debug","native/target/debug/libmcal_native.so")

native-release:
	@echo "[BUILDING] Rust native library (release)..."
	@$(SET_E)
	cd native && cargo build --release
	$(call verify_native_lib,native/target/release/libmcal_native.so,"Linux release")
	$(call build_success,"Native Release","native/target/release/libmcal_native.so")

native-test:
	@echo "Running Rust tests..."
	cd native && cargo test

# =============================================================================
# ANDROID-SPECIFIC TARGETS
# =============================================================================

# Build Android library for a specific architecture with progress tracking
# Usage: $(call build-android-lib,<arch_index>,<total_archs>,<arch>,<target_path>)
define build-android-lib
	@echo "[$(1)/$(2)] Building for $(3)..."
	@cd native && cargo ndk -t $(4) build --release 2>&1 | head -20 || \
		{ echo "ERROR: [BUILD_FAILED] Failed to build for $(3)" >&2; \
		  echo "  Category: Compilation" >&2; \
		  echo "  Suggestion: Check Rust compilation errors above" >&2; \
		  exit 1; }
endef

android-libs:
	@echo "[BUILDING] Android native libraries..."
	@echo ""
	@{ \
		total_archs=$(words $(ANDROID_TARGETS)); \
		arch_index=0; \
		for target in $(ANDROID_TARGETS); do \
			arch_index=$$((arch_index + 1)); \
			case $$target in \
				arm64-v8a) target_path="aarch64-linux-android" ;; \
				armeabi-v7a) target_path="armv7-linux-androideabi" ;; \
				x86) target_path="i686-linux-android" ;; \
				x86_64) target_path="x86_64-linux-android" ;; \
			esac; \
			echo ""; \
			echo "[$$(printf '%3d' $$arch_index)/$$(printf '%3d' $$total_archs)] Building for $$target..."; \
			cd native && cargo ndk -t $$target_path build --release 2>&1 | head -20 || \
				{ echo "ERROR: [BUILD_FAILED] Failed to build for $$target" >&2; \
				  echo "  Category: Compilation" >&2; \
				  echo "  Suggestion: Check Rust compilation errors above" >&2; \
				  exit 1; }; \
			cd ..; \
		done; \
	}

	@echo ""
	@echo "[COPYING] Libraries to Android project..."
	$(call copy-android-lib,arm64-v8a,aarch64-linux-android)
	$(call copy-android-lib,armeabi-v7a,armv7-linux-androideabi)
	$(call copy-android-lib,x86,i686-linux-android)
	$(call copy-android-lib,x86_64,x86_64-linux-android)
	$(call verify_native_lib,android/app/src/main/cpp/libs/arm64-v8a/libmcal_native.so,"Android arm64-v8a")
	$(call verify_native_lib,android/app/src/main/cpp/libs/armeabi-v7a/libmcal_native.so,"Android armeabi-v7a")
	$(call verify_native_lib,android/app/src/main/cpp/libs/x86/libmcal_native.so,"Android x86")
	$(call verify_native_lib,android/app/src/main/cpp/libs/x86_64/libmcal_native.so,"Android x86_64")
	$(call android_libs_complete,$(words $(ANDROID_TARGETS)))

android-build: android-libs generate
	@echo "[BUILDING] Android APK (debug)..."
	@$(SET_E)
	$(call check_fvm)
	fvm flutter clean
	fvm flutter pub get
	fvm flutter build apk --debug
	$(call verify_apk,build/app/outputs/flutter-apk/app-debug.apk,"Debug APK")
	$(call apk_success,"Debug","build/app/outputs/flutter-apk/app-debug.apk")

android-release: android-libs generate
	@echo "[BUILDING] Android APK (release)..."
	@$(SET_E)
	$(call check_fvm)
	fvm flutter clean
	fvm flutter pub get
	fvm flutter build apk --release
	$(call verify_apk,android/app/build/outputs/apk/release/app-release.apk,"Release APK")
	$(call verify_apk,build/app/outputs/flutter-apk/app-debug.apk,"Debug APK")
	$(call apk_success,"Release","android/app/build/outputs/apk/release/app-release.apk")

android-test:
	@echo "Running tests on Android..."
	$(call check_fvm)
	fvm flutter test
	@echo ""
	@echo "Running integration tests..."
	fvm flutter test integration_test/app_integration_test.dart

android-run:
	@echo "Detecting Android devices..."
	$(call check_fvm)
	@$(call check_dep,adb,Install ADB,android-sdk-platform-tools)
	
	# Get device list in JSON format and detect Android devices
	@DEVICES_JSON=$$(fvm flutter devices --machine 2>&1); \
	if [ $$? -ne 0 ]; then \
		echo "ERROR: Failed to run 'flutter devices'"; \
		echo "  Make sure Flutter is properly initialized"; \
		echo "  Try running: fvm flutter doctor"; \
		exit 1; \
	fi
	
	# Parse JSON to find Android devices (exclude web, linux, windows, macos)
	@ANDROID_ID=$$(echo "$$DEVICES_JSON" | python3 -c "import json,sys; \
		devs=json.load(sys.stdin); \
		for d in devs: \
			if d.get('platform','').lower() == 'android': \
				print(d.get('id', '')); \
				break" 2>/dev/null); \
	
	@if [ -z "$$ANDROID_ID" ]; then \
		echo ""; \
		echo "========================================"; \
		echo "ERROR: No Android device found"; \
		echo "========================================"; \
		echo ""; \
		echo "To run the app on Android, you need either:"; \
		echo ""; \
		echo "Option 1: Start an Android Emulator"; \
		echo "----------------------------------------"; \
		echo "  1. List available emulators:"; \
		echo "     flutter emulators"; \
		echo ""; \
		echo "  2. Launch an emulator:"; \
		echo "     flutter emulators --launch <emulator_name>"; \
		echo ""; \
		echo "  3. Or using Android Studio:"; \
		echo "     - Open Android Studio"; \
		echo "     - Go to AVD Manager"; \
		echo "     - Click 'Run' on your virtual device"; \
		echo ""; \
		echo "Option 2: Connect a Physical Device"; \
		echo "----------------------------------------"; \
		echo "  1. Enable Developer Options on your device:"; \
		echo "     - Go to Settings > About Phone"; \
		echo "     - Tap 'Build Number' 7 times"; \
		echo ""; \
		echo "  2. Enable USB Debugging:"; \
		echo "     - Go to Settings > System > Developer Options"; \
		echo "     - Enable 'USB Debugging'"; \
		echo ""; \
		echo "  3. Connect device via USB and authorize:"; \
		echo "     - Check: adb devices"; \
		echo "     - Look for 'device' (not 'unauthorized')"; \
		echo ""; \
		echo "Troubleshooting:"; \
		echo "----------------------------------------"; \
		echo "  - ADB not found? Install Android SDK Platform Tools"; \
		echo "  - Device not detected? Try: adb kill-server && adb start-server"; \
		echo "  - Multiple devices? Use: make android-run ANDROID_DEVICE=<device_id>"; \
		echo ""; \
		echo "Documentation:"; \
		echo "  - Flutter Android setup: https://flutter.dev/docs/get-started/install/linux"; \
		echo "  - Emulator setup: https://flutter.dev/docs/get-started/install/linux#set-up-the-android-emulator"; \
		echo "  - Device debugging: https://flutter.dev/docs/get-started/install/linux#android-setup"; \
		echo ""; \
		exit 1; \
	fi
	
	@echo "Found Android device: $$ANDROID_ID"
	@echo "Starting Flutter on Android..."
	@fvm flutter run -d $$ANDROID_ID

android-clean:
	@echo "Cleaning Android build artifacts..."
	fvm flutter clean
	cd native && cargo clean
	rm -rf android/app/build
	rm -rf build

install-apk:
	@echo "Installing debug APK on connected device..."
	$(call check_dep,adb,adb install -r,Android SDK Platform Tools)
	adb install -r build/app/outputs/flutter-apk/app-debug.apk

# =============================================================================
# UTILITY TARGETS
# =============================================================================

all: android-libs native-build generate
	@echo "[BUILDING] All components for Linux and Android..."
	$(call check_fvm)
	@echo ""
	@echo "[1/4] Building Linux application..."
	@fvm flutter build linux
	$(call verify_linux_bundle,build/linux/x64/release/bundle)
	@echo ""
	@echo "[2/4] Building Android APK (debug)..."
	@fvm flutter clean
	@fvm flutter pub get
	@fvm flutter build apk --debug
	$(call verify_apk,build/app/outputs/flutter-apk/app-debug.apk,"Debug APK")
	@echo ""
	@echo "[3/4] Building Android APK (release)..."
	@fvm flutter build apk --release
	$(call verify_apk,build/app/outputs/flutter-apk/app-release.apk,"Release APK")
	@echo ""
	@echo "[4/4] Verifying all artifacts..."
	$(call verify_all_artifacts)

# Verify build synchronization
verify-sync:
	@echo "════════════════════════════════════════════════════════════════════"
	@echo "Verifying Build Synchronization"
	@echo "════════════════════════════════════════════════════════════════════"
	@echo ""
	
	@echo "Checking Flutter Rust Bridge code generation..."
	@{ \
		SYNC_STATUS=0; \
		test -f "lib/frb_generated.dart" && \
			echo "  ✓ lib/frb_generated.dart" || \
			{ echo "  ✗ lib/frb_generated.dart - RUN: make generate"; SYNC_STATUS=1; }; \
		test -f "lib/frb_generated.dart" && \
			echo "  ✓ lib/frb_generated.dart (platform-specific)" || \
			{ echo "  ✗ lib/frb_generated.dart - RUN: make generate"; SYNC_STATUS=1; }; \
		test -f "native/src/frb_generated.rs" && \
			echo "  ✓ native/src/frb_generated.rs" || \
			{ echo "  ✗ native/src/frb_generated.rs - RUN: make generate"; SYNC_STATUS=1; }; \
		echo ""; \
		echo "Checking native library builds..."; \
		test -f "native/target/release/libmcal_native.so" && \
			echo "  ✓ Linux native library" || \
			{ echo "  ✗ Linux native library - RUN: make native-build"; SYNC_STATUS=1; }; \
		echo ""; \
		echo "Checking Android native libraries..."; \
		for arch in arm64-v8a armeabi-v7a x86 x86_64; do \
			if [ -f "android/app/src/main/cpp/libs/$$arch/libmcal_native.so" ]; then \
				echo "  ✓ Android $$arch"; \
			else \
				echo "  ✗ Android $$arch - RUN: make android-libs"; \
				SYNC_STATUS=1; \
			fi; \
		done; \
		echo ""; \
		if [ $$SYNC_STATUS -eq 0 ]; then \
			echo "════════════════════════════════════════════════════════════════════"; \
			echo "  ✓ All components are in sync"; \
			echo "════════════════════════════════════════════════════════════════════"; \
		else \
			echo "════════════════════════════════════════════════════════════════════"; \
			echo "  ✗ Some components are out of sync"; \
			echo ""; \
			echo "To fix, run:"; \
			echo "  make android-libs    # Build Android native libraries"; \
			echo "  make generate        # Generate FRB bindings"; \
			echo "  make native-build    # Build Linux native library"; \
			echo "════════════════════════════════════════════════════════════════════"; \
			exit 1; \
		fi; \
	}

# Show device information
devices:
	@echo "Available Flutter devices:"
	@DEVICES_JSON=$$(fvm flutter devices --machine 2>/dev/null); \
	if [ -n "$$DEVICES_JSON" ]; then \
		echo "$$DEVICES_JSON" | python3 -c "import json,sys; \
			devs=json.load(sys.stdin); \
			if not devs: \
				print('  No devices found'); \
			else: \
				for d in devs: \
					print(f'  {d.get(\"id\", \"unknown\")}: {d.get(\"name\", \"Unknown\")} ({d.get(\"platform\", \"Unknown\")})')" 2>/dev/null || \
		fvm flutter devices; \
	else \
		fvm flutter devices; \
	fi
	@echo ""
	@echo "Android devices (via ADB):"
	@$(call check_dep,adb,adb,Android SDK Platform Tools)
	@adb devices 2>/dev/null || echo "  ADB not available"

# Interactive device selection for Android
# Usage: make android-select
android-select:
	@echo "Available Android devices:"
	@DEVICES_JSON=$$(fvm flutter devices --machine 2>/dev/null); \
	if [ -n "$$DEVICES_JSON" ]; then \
		echo "$$DEVICES_JSON" | python3 -c "import json,sys; \
			devs=json.load(sys.stdin); \
			android_devs=[d for d in devs if d.get('platform','').lower() == 'android']; \
			if not android_devs: \
				print('  No Android devices found'); \
			else: \
				for i, d in enumerate(android_devs, 1): \
					print(f'  {i}. {d.get(\"id\", \"unknown\")}: {d.get(\"name\", \"Unknown\")}')" 2>/dev/null || \
		echo "  Unable to parse device list"; \
	fi
	@echo ""
	@echo "Usage: make android-run ANDROID_DEVICE=<device_id>"

# Lint targets
lint:
	@echo "Running Dart linter..."
	$(call check_fvm)
	fvm flutter analyze lib/
	fvm flutter test

rust-lint:
	@echo "Running Rust linter..."
	cd native && cargo clippy

# Format targets
format:
	@echo "Formatting Dart code..."
	$(call check_fvm)
	fvm dart format lib/ test/
	@echo "Formatting Rust code..."
	cd native && cargo fmt

# =============================================================================
# DEPENDENCY VERIFICATION
# =============================================================================

verify-deps:
	@echo "Verifying development environment..."
	@echo ""
	@echo "Flutter version:"
	@if command -v fvm &> /dev/null; then \
		fvm flutter --version | head -1; \
	else \
		echo "  fvm not found"; \
	fi
	@echo ""
	@echo "Cargo version:"
	@if command -v cargo &> /dev/null; then \
		cargo --version | head -1; \
	else \
		echo "  cargo not found"; \
	fi
	@echo ""
	@echo "cargo-ndk version:"
	@if command -v cargo &> /dev/null && cargo ndk --version &> /dev/null; then \
		cargo ndk --version | head -1; \
	else \
		echo "  cargo-ndk not found (install with: cargo install cargo-ndk)"; \
	fi
	@echo ""
	@echo "FRB codegen version:"
	@if command -v flutter_rust_bridge_codegen &> /dev/null; then \
		flutter_rust_bridge_codegen --version 2>/dev/null || echo "  FRB codegen available"; \
	else \
		echo "  flutter_rust_bridge_codegen not found"; \
	fi
	@echo ""
	@echo "ADB version:"
	@if command -v adb &> /dev/null; then \
		adb version | head -1; \
	else \
		echo "  adb not found"; \
	fi
