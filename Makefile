# MCal Makefile
# Platform-agnostic, Linux, and Android build targets

.PHONY: help clean deps generate analyze test test-cov build \
    native-build native-test native-release \
    linux-run linux-build linux-test linux-analyze linux-clean \
    android-build android-test android-run android-libs android-clean \
    all android-release install-apk

# Configuration
ANDROID_NDK_PATH ?= $(ANDROID_NDK_HOME)
ANDROID_TARGETS ?= armeabi-v7a arm64-v8a x86 x86_64

# =============================================================================
# PLATFORM-AGNOSTIC TARGETS
# =============================================================================

help:
	@echo "MCal Build System"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Platform-agnostic targets:"
	@echo "  help          - Show this help message"
	@echo "  clean         - Clean Flutter and Rust build artifacts"
	@echo "  deps          - Install/update dependencies"
	@echo "  generate      - Generate Flutter Rust Bridge code"
	@echo "  analyze       - Run Flutter analyzer"
	@echo "  test          - Run all tests"
	@echo "  test-cov      - Run tests with coverage"
	@echo "  build         - Build for current platform"
	@echo ""
	@echo "Linux-specific targets:"
	@echo "  linux-run       - Run app on Linux"
	@echo "  linux-build     - Build app for Linux"
	@echo "  linux-test      - Run tests on Linux"
	@echo "  linux-analyze   - Analyze Flutter code on Linux"
	@echo "  linux-clean     - Clean Linux build artifacts"
	@echo "  native-build    - Build Rust native library (debug)"
	@echo "  native-release  - Build Rust native library (release)"
	@echo "  native-test     - Run Rust tests"
	@echo ""
	@echo "Android-specific targets:"
	@echo "  android-build     - Build complete Android APK (debug)"
	@echo "  android-release   - Build complete Android APK (release)"
	@echo "  android-test      - Run tests on Android"
	@echo "  android-run       - Run app on Android device/emulator"
	@echo "  android-libs      - Build Rust libraries for all Android architectures"
	@echo "  android-clean     - Clean Android build artifacts"
	@echo "  install-apk       - Install debug APK on connected device"
	@echo ""
	@echo "Utility targets:"
	@echo "  all              - Build everything (native libs + Flutter app)"

clean:
	@echo "Cleaning all build artifacts..."
	fvm flutter clean
	cd native && cargo clean

deps:
	@echo "Installing Flutter dependencies..."
	fvm flutter pub get

generate:
	@echo "Generating Flutter Rust Bridge bindings..."
	flutter_rust_bridge_codegen generate --config-file frb.yaml

analyze:
	@echo "Running Flutter analyzer..."
	fvm flutter analyze

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

linux-run:
	@echo "Running app on Linux..."
	fvm flutter run -d linux

linux-build:
	@echo "Building app for Linux..."
	fvm flutter build linux

linux-test:
	@echo "Running tests on Linux..."
	fvm flutter test -d linux

linux-analyze:
	@echo "Analyzing Flutter code on Linux..."
	fvm flutter analyze -d linux

linux-clean:
	@echo "Cleaning Linux build artifacts..."
	fvm flutter clean

# Native Rust library targets
native-build:
	@echo "Building Rust native library (debug)..."
	cd native && cargo build

native-release:
	@echo "Building Rust native library (release)..."
	cd native && cargo build --release

native-test:
	@echo "Running Rust tests..."
	cd native && cargo test

# =============================================================================
# ANDROID-SPECIFIC TARGETS
# =============================================================================

android-libs:
	@echo "Building Rust libraries for all Android architectures..."
	@for target in $(ANDROID_TARGETS); do \
		echo "  Building for $$target..."; \
		cd native && cargo ndk -t $$target build --release; \
		cd ..; \
	done
	@echo "Copying libraries to Android project..."
	cp native/target/aarch64-linux-android/release/libmcal_native.so android/app/src/main/cpp/libs/arm64-v8a/ 2>/dev/null || true
	cp native/target/armv7-linux-androideabi/release/libmcal_native.so android/app/src/main/cpp/libs/armeabi-v7a/ 2>/dev/null || true
	cp native/target/i686-linux-android/release/libmcal_native.so android/app/src/main/cpp/libs/x86/ 2>/dev/null || true
	cp native/target/x86_64-linux-android/release/libmcal_native.so android/app/src/main/cpp/libs/x86_64/ 2>/dev/null || true
	@echo "Android native libraries built successfully"

android-build: android-libs generate
	@echo "Building Android APK (debug)..."
	fvm flutter clean
	fvm flutter pub get
	fvm flutter build apk --debug
	@echo ""
	@echo "APK built successfully!"
	@echo "Output: build/app/outputs/flutter-apk/app-debug.apk"

android-release: android-libs generate
	@echo "Building Android APK (release)..."
	fvm flutter clean
	fvm flutter pub get
	fvm flutter build apk --release
	@echo ""
	@echo "APK built successfully!"
	@echo "Output: android/app/build/outputs/apk/release/app-release.apk"

android-test:
	@echo "Running tests on Android..."
	fvm flutter test
	@echo ""
	@echo "Running integration tests..."
	fvm flutter test integration_test/app_integration_test.dart

android-run:
	@echo "Listing available Android devices..."
	fvm flutter devices
	@echo ""
	@echo "Run 'make android-run device=<device_id>' to run on specific device"
	@fvm flutter run -d $$(fvm flutter devices --machine | grep -o '"id": *"[^"]*"' | head -1 | cut -d'"' -f4)

android-clean:
	@echo "Cleaning Android build artifacts..."
	fvm flutter clean
	cd native && cargo clean
	rm -rf android/app/build
	rm -rf build

install-apk:
	@echo "Installing debug APK on connected device..."
	adb install -r build/app/outputs/flutter-apk/app-debug.apk

# =============================================================================
# UTILITY TARGETS
# =============================================================================

all: android-libs generate
	@echo "Building all components..."
	fvm flutter build

# Verify build synchronization
verify-sync:
	@echo "Verifying build synchronization..."
	@echo ""
	@echo "FRB generated files:"
	ls -la lib/frb_generated.dart native/src/frb_generated.rs 2>/dev/null || echo "  FRB files not found - run 'make generate'"
	@echo ""
	@echo "Android native libraries:"
	ls -la android/app/src/main/cpp/libs/*/libmcal_native.so 2>/dev/null || echo "  Android libs not found - run 'make android-libs'"
	@echo ""
	@echo "Build verification complete"

# Show device information
devices:
	@echo "Available Flutter devices:"
	fvm flutter devices
	@echo ""
	@echo "Android devices:"
	adb devices

# Lint targets
lint:
	@echo "Running Dart linter..."
	fvm flutter analyze lib/
	fvm flutter test

rust-lint:
	@echo "Running Rust linter..."
	cd native && cargo clippy

# Format targets
format:
	@echo "Formatting Dart code..."
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
