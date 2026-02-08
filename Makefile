# MCal Makefile - Simplified Build System

# =============================================================================
# ERROR HANDLING
# =============================================================================

# Enable exit on error for shell commands (can be overridden per target)
SET_E := set -e

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Success message helper
define success
	@echo "✓ $(1)"
endef

# Info message helper
define info
	@echo "→ $(1)"
endef

# Build completion message
define build_success
	@echo ""
	@echo "════════════════════════════════════════════════════════════"
	@echo "  ✓ $(1) build complete"
	@echo ""
	@echo "  Output: $(2)"
	@if [ -f "$(2)" ]; then \
		SIZE=$$(du -h "$(2)" | cut -f1); \
		echo "  Size: $$SIZE"; \
	fi
	@echo "════════════════════════════════════════════════════════════"
endef

# =============================================================================
# DEPENDENCY VERIFICATION HELPERS
# =============================================================================

# Check for fvm with installation instructions
define check_fvm
	@if ! command -v fvm &> /dev/null; then \
		echo "ERROR: fvm (Flutter Version Manager) is not installed"; \
		echo "  Install: dart pub global activate fvm"; \
		exit 1; \
	fi
endef

# Check for required command
define check_dep
	@if ! command -v $(1) &> /dev/null; then \
		echo "ERROR: $(1) is not installed or not in PATH"; \
		echo "  Install: $(2)"; \
		exit 1; \
	fi
endef

# =============================================================================
# INTERNAL DEPENDENCY TARGETS
# =============================================================================

# Install Flutter dependencies
deps:
	@echo "Installing Flutter dependencies..."
	$(call check_fvm)
	fvm flutter pub get

# Generate Flutter Rust Bridge code
generate:
	@echo "Generating Flutter Rust Bridge code..."
	$(call check_fvm)
	$(call check_dep,flutter_rust_bridge_codegen,Install FRB codegen,dart pub global activate flutter_rust_bridge_codegen)
	@flutter_rust_bridge_codegen generate --config-file frb.yaml || \
		{ echo "ERROR: FRB code generation failed"; exit 1; }
	$(call success,"Flutter Rust Bridge code generated")

# Build Rust native library for Linux
native-build:
	@echo "Building Rust native library for Linux..."
	$(call check_dep,cargo,Install Rust,cargo)
	cd native && cargo build --release
	$(call success,"Linux native library built")

# Build Rust native libraries for all Android architectures
native-android-build:
	@echo "Building Android native libraries..."
	$(call check_dep,cargo,Install Rust,cargo)
	$(call check_dep,cargo ndk,Install cargo-ndk,cargo install cargo-ndk)
	@cd native && cargo ndk -t aarch64-linux-android build --release
	@cd native && cargo ndk -t armeabi-v7a build --release
	@cd native && cargo ndk -t x86_64-linux-android build --release
	$(call success,"All Android native libraries built")

	@echo "Copying libraries to Android project..."
	@mkdir -p android/app/src/main/cpp/libs/arm64-v8a
	@mkdir -p android/app/src/main/cpp/libs/armeabi-v7a
	@mkdir -p android/app/src/main/cpp/libs/x86_64
	@cp native/target/aarch64-linux-android/release/libmcal_native.so \
		android/app/src/main/cpp/libs/arm64-v8a/ || echo "Warning: arm64-v8a copy failed"
	@cp native/target/armv7-linux-androideabi/release/libmcal_native.so \
		android/app/src/main/cpp/libs/armeabi-v7a/ || echo "Warning: armeabi-v7a copy failed"
	@cp native/target/x86_64-linux-android/release/libmcal_native.so \
		android/app/src/main/cpp/libs/x86_64/ || echo "Warning: x86_64 copy failed"
	$(call success,"Android libraries copied")

# =============================================================================
# GENERAL COMMANDS
# =============================================================================

# Clean all build artifacts
clean:
	@echo "Cleaning all build artifacts..."
	fvm flutter clean
	cd native && cargo clean
	rm -rf build/
	$(call success,"All build artifacts cleaned")

# Full build from scratch for current platform
build:
	@{ \
		if [ "$$(uname -s)" = "Linux" ]; then \
			echo "Linux detected. Building for Linux..."; \
			$(MAKE) linux-build; \
		elif [ "$$(uname -o 2>/dev/null || uname -s)" = "Android" ]; then \
			echo "Android detected. Building for Android..."; \
			$(MAKE) android-build; \
		else \
			echo "Error: Unsupported platform $$(uname -s)"; \
			exit 1; \
		fi \
	}

# =============================================================================
# DEVELOPMENT COMMANDS
# =============================================================================

# Run app on current platform (includes complete build)
run: deps generate native-build
	fvm flutter run

# Run tests on current platform
test:
	@echo "Running tests..."
	$(call check_fvm)
	fvm flutter test

# =============================================================================
# LINUX COMMANDS
# =============================================================================

# Full from-scratch build for Linux platform
linux-build: deps generate native-build
	@echo "Building Linux application..."
	$(call check_fvm)
	fvm flutter build linux --release
	$(call build_success,"Linux","build/linux/x64/release/bundle/mcal")

# =============================================================================
# ANDROID COMMANDS
# =============================================================================

# Full from-scratch build for Android (all architectures)
android-build: deps generate native-android-build
	@echo "Building Android APK (debug)..."
	$(call check_fvm)
	fvm flutter pub get
	fvm flutter build apk --debug
	$(call build_success,"Android","build/app/outputs/flutter-apk/app-debug.apk")

# Full build first, then run on Android device
android-run: android-build
	@echo "Detecting connected Android device..."
	@DEVICE_ID=$$(fvm flutter devices | grep -E "android" | head -1 | awk '{print $$1}'); \
	if [ -z "$$DEVICE_ID" ]; then \
		echo "ERROR: No connected Android device found"; \
		echo "Run 'fvm flutter devices' to see available devices"; \
		exit 1; \
	fi; \
	echo "Running on device: $$DEVICE_ID"; \
	fvm flutter run -d $$DEVICE_ID

# Full build first, then install debug APK on connected device
android-install: android-build
	@echo "Detecting connected Android device..."
	@DEVICE_ID=$$(fvm flutter devices | grep -E "android" | head -1 | awk '{print $$1}'); \
	if [ -z "$$DEVICE_ID" ]; then \
		echo "ERROR: No connected Android device found"; \
		echo "Run 'fvm flutter devices' to see available devices"; \
		exit 1; \
	fi; \
	echo "Installing APK on device: $$DEVICE_ID"; \
	fvm flutter install -d $$DEVICE_ID

# =============================================================================
# UTILITY
# =============================================================================

help:
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║                     MCAL - Makefile Help                ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "General Commands:"
	@echo "  make clean       - Clean all build artifacts"
	@echo "  make build      - Full build for current platform"
	@echo ""
	@echo "Development Commands:"
	@echo "  make run        - Run app on current platform"
	@echo "  make test       - Run tests"
	@echo ""
	@echo "Linux Commands:"
	@echo "  make linux-build - Build Linux application"
	@echo ""
	@echo "Android Commands:"
	@echo "  make android-build  - Build Android APK"
	@echo "  make android-run    - Build and run on Android"
	@echo "  make android-install - Build and install APK"
	@echo ""

.PHONY: help clean build run test linux-build \
    android-build android-run android-install \
    deps generate native-build native-android-build
