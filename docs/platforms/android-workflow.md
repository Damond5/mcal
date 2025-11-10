## Android Development Workflow

**Breadcrumb:** [Project Root](../../README.md) > [Docs](../) > [Platforms](.) > Android Workflow

**Navigation:** [Platforms Overview](README.md) | [AGENTS.md](../../AGENTS.md#platform-instruction-access-for-ai-agents) | [Project Root](../../README.md)

---

This section provides guidelines for Android-specific development tasks in the MCAL project, which uses Flutter with Rust integration via Flutter Rust Bridge (FRB). For general project setup, see the [project README](../README.md).

## Table of Contents
- [Prerequisites](#prerequisites)
- [Complete Development Cycle](#complete-development-cycle)
- [Building the Android App](#building-the-android-app)
- [Testing on Android Devices](#testing-on-android-devices)
- [Verifying Build Synchronization](#verifying-build-synchronization)
- [Running Tests](#running-tests)
- [Handling Flutter Rust Bridge Content Hash Mismatches](#handling-flutter-rust-bridge-content-hash-mismatches)
- [Cross-Compiling Rust for Android](#cross-compiling-rust-for-android)
- [Build Automation](#build-automation)
- [Preventing Common Issues](#preventing-common-issues)
- [Additional Troubleshooting](#additional-troubleshooting)

### Prerequisites

Before starting Android development, ensure:

- **Flutter Version Management**: `fvm` installed and configured
- **Android SDK/NDK**: Properly configured with environment variables
- **Rust Toolchain**: `cargo` and `cargo ndk` installed
- **FRB Codegen**: `flutter_rust_bridge_codegen` available globally or via pub
- **Device/Emulator**: Android device connected or emulator running

#### Environment Verification:
```bash
# Verify fvm
fvm flutter --version

# Verify cargo ndk
cargo ndk --version

# Verify FRB codegen
flutter_rust_bridge_codegen --version

# Verify Android device
adb devices
```

### Complete Development Cycle

When making changes to Rust code (`native/src/api.rs`) or Flutter-Rust Bridge interfaces, follow this complete workflow to prevent hash mismatches and build failures:

1. **Make Rust Code Changes**
2. **Regenerate FRB Bindings**
3. **Rebuild Android Native Libraries**
4. **Clean and Rebuild Flutter APK**
5. **Test on Device**

#### Step-by-Step Commands:
```bash
# 1. Make your Rust code changes in native/src/api.rs

# 2. Regenerate Flutter Rust Bridge bindings
flutter_rust_bridge_codegen generate --config-file frb.yaml

# 3. Rebuild Android native libraries for all architectures
cd native && cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 build --release

# 4. Copy updated libraries to Android project
cp target/aarch64-linux-android/release/libmcal_native.so ../android/app/src/main/cpp/libs/arm64-v8a/
cp target/armv7-linux-androideabi/release/libmcal_native.so ../android/app/src/main/cpp/libs/armeabi-v7a/
cp target/i686-linux-android/release/libmcal_native.so ../android/app/src/main/cpp/libs/x86/
cp target/x86_64-linux-android/release/libmcal_native.so ../android/app/src/main/cpp/libs/x86_64/

# 5. Clean and rebuild Flutter APK
cd .. && fvm flutter clean && fvm flutter build apk --debug

# 6. Install and test
adb install -r build/app/outputs/flutter-apk/app-debug.apk
fvm flutter test integration_test/app_integration_test.dart
```

### Building the Android App

To build the Android APK, use Flutter Version Management (fvm) to ensure the correct Flutter version. fvm is a tool for managing Flutter SDK versions per project, avoiding global version conflicts.

```bash
fvm flutter build apk
```

This command builds a release APK in the `android/app/build/outputs/apk/release/` directory. On success, you'll see output like "Built build/app/outputs/apk/release/app-release.apk". This may take several minutes depending on your machine.

**Important**: After making changes to Rust code, always follow the Complete Development Cycle above to ensure proper synchronization.

### Testing on Android Devices

To run the app on a specific Android device or emulator:

1. List available devices:
   ```bash
   fvm flutter devices
   ```
   Example output:
   ```
   1 connected device:

   sdk gphone x86 (mobile) • emulator-5554 • android-x86 • Android 11 (API 30) (emulator)
   ```

2. Run on a specific device:
   ```bash
   fvm flutter run --device-id <device_id>
   ```
   Replace `<device_id>` with the ID from the devices list (e.g., emulator-5554 or a physical device ID). If no devices are found, ensure USB debugging is enabled on physical devices or start an emulator.

### Verifying Build Synchronization

Before building, verify that all components are synchronized to prevent hash mismatches:

```bash
# Check FRB generated file timestamps (should be recent)
ls -la lib/frb_generated.dart native/src/frb_generated.rs

# Check Android native library timestamps (should match recent builds)
ls -la android/app/src/main/cpp/libs/*/libmcal_native.so

# Quick hash verification (run after build to confirm sync)
fvm flutter build apk --debug > /dev/null && echo "Build successful - hashes synchronized"
```

### Running Tests

Execute the test suite using:

```bash
fvm flutter test
```

This runs all unit and widget tests in the project. For integration tests specific to Android, use:

```bash
fvm flutter test integration_test/app_integration_test.dart
```

### Handling Flutter Rust Bridge Content Hash Mismatches

Content hash mismatches occur when Dart and Rust bridge code are out of sync. Follow this complete resolution process:

#### Complete Resolution Steps:

1. **Regenerate FRB Bindings:**
   ```bash
   flutter_rust_bridge_codegen generate --config-file frb.yaml
   ```

2. **Rebuild Android Native Libraries:**
   ```bash
   cd native
   cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 build --release
   cp target/aarch64-linux-android/release/libmcal_native.so ../android/app/src/main/cpp/libs/arm64-v8a/
   cp target/armv7-linux-androideabi/release/libmcal_native.so ../android/app/src/main/cpp/libs/armeabi-v7a/
   cp target/i686-linux-android/release/libmcal_native.so ../android/app/src/main/cpp/libs/x86/
   cp target/x86_64-linux-android/release/libmcal_native.so ../android/app/src/main/cpp/libs/x86_64/
   cd ..
   ```

3. **Clean and Rebuild:**
   ```bash
   fvm flutter clean
   fvm flutter pub get
   fvm flutter build apk --debug
   ```

4. **Verify Resolution:**
   ```bash
   adb install -r build/app/outputs/flutter-apk/app-debug.apk
   fvm flutter test integration_test/app_integration_test.dart
   ```

#### Prevention Measures:
- Always follow the complete development cycle when modifying Rust code
- Run verification commands before building
- Keep native libraries synchronized with FRB generated code

### Cross-Compiling Rust for Android

The project uses Rust code that needs to be compiled for Android architectures. Use `cargo ndk` (a cargo extension for easy Android cross-compilation) for this:

1. Ensure Android NDK is installed and configured in your environment.

2. Build for all Android architectures (release mode):
   ```bash
   cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 build --release
   ```
   On success, compiled libraries will be in `target/` subdirectories.

3. For debugging builds:
   ```bash
   cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 build
   ```

**Note**: After building native libraries, copy them to the Android project as shown in the Complete Development Cycle section.

### Build Automation

To reduce manual errors, consider these automation approaches:

#### Option 1: Shell Script
A build script is available at `scripts/build-android.sh`:
```bash
#!/bin/bash
set -e

echo "🔧 Regenerating FRB bindings..."
flutter_rust_bridge_codegen generate --config-file frb.yaml

echo "🏗️ Building Android native libraries..."
cd native
cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 build --release

echo "📦 Copying libraries..."
cp target/aarch64-linux-android/release/libmcal_native.so ../android/app/src/main/cpp/libs/arm64-v8a/
cp target/armv7-linux-androideabi/release/libmcal_native.so ../android/app/src/main/cpp/libs/armeabi-v7a/
cp target/i686-linux-android/release/libmcal_native.so ../android/app/src/main/cpp/libs/x86/
cp target/x86_64-linux-android/release/libmcal_native.so ../android/app/src/main/cpp/libs/x86_64/
cd ..

echo "🧹 Cleaning and building APK..."
fvm flutter clean
fvm flutter build apk --debug

echo "✅ Build complete!"
```

#### Option 2: Make Integration
A Makefile with Android build targets is available in the project root:
```makefile
.PHONY: android-build android-libs android-clean

android-libs:
	cd native && cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 build --release
	cp native/target/aarch64-linux-android/release/libmcal_native.so android/app/src/main/cpp/libs/arm64-v8a/
	cp native/target/armv7-linux-androideabi/release/libmcal_native.so android/app/src/main/cpp/libs/armeabi-v7a/
	cp native/target/i686-linux-android/release/libmcal_native.so android/app/src/main/cpp/libs/x86/
	cp native/target/x86_64-linux-android/release/libmcal_native.so android/app/src/main/cpp/libs/x86_64/

android-build: android-libs
	flutter_rust_bridge_codegen generate --config-file frb.yaml
	fvm flutter clean && fvm flutter build apk --debug
```

#### Option 3: Git Hooks
Add pre-commit hook to verify synchronization:
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check if FRB files are up to date
if [ "native/src/api.rs" -nt "lib/frb_generated.dart" ]; then
    echo "❌ FRB bindings may be outdated. Run 'flutter_rust_bridge_codegen generate'"
    exit 1
fi

# Check if Android libs are up to date
if [ "native/src/api.rs" -nt "android/app/src/main/cpp/libs/arm64-v8a/libmcal_native.so" ]; then
    echo "❌ Android native libraries may be outdated. Run Android build process"
    exit 1
fi

echo "✅ Build synchronization verified"
```

### Preventing Common Issues

#### Hash Mismatches:
- Always follow the Complete Development Cycle when modifying Rust code
- Run verification commands before building to catch synchronization issues early
- Keep native libraries synchronized with FRB generated code

#### Build Failures:
- Ensure all prerequisites are installed and environment variables are set
- Check that Android NDK paths are correctly configured
- Verify no stale build artifacts remain from previous builds

#### Test Failures:
- Run tests on physical devices for certificate-related features
- Ensure emulator has necessary permissions and APIs
- Check logcat output for detailed error information

### Additional Troubleshooting

- **Certificate Reading Functionality**: When testing certificate-related features, ensure the app has proper permissions in the Android manifest. Test on physical devices for accurate results, as emulators may not fully simulate certificate stores. Never hardcode private keys or sensitive certificate data in the code; use Android's KeyStore for secure storage.

- **FRB Bindings Regeneration**: Always regenerate FRB bindings after modifying Rust API definitions in `native/src/api.rs` or related files. On success, you'll see updated files in `frb_generated/` directories. If regeneration fails, check for syntax errors in Rust code.

- **Version Management**: Use `fvm` consistently to avoid version conflicts. Check the project's Flutter version with `fvm flutter --version`. If fvm commands fail, ensure it's installed globally.

- **Build Failures**: If builds fail due to Rust compilation, verify that `cargo ndk` is installed (`cargo install cargo-ndk`) and that Android SDK/NDK paths are correctly set in your environment variables.

- **Network Issues**: If `fvm flutter pub get` fails, check your internet connection, firewall settings, and proxy configuration.

- **Device Connection Problems**: For physical devices, enable USB debugging in developer options. For emulators, ensure Android Studio/AVD Manager is running and the emulator is started. If `flutter devices` shows no devices, restart the device/emulator or check USB cables.

- **Emulator Performance**: Emulators can be slow; consider using physical devices for testing certificate and performance-critical features.