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
fvm dart flutter_rust_bridge_codegen --version

# Verify Android device
adb devices
```

#### Android 13+ Notification Permissions

**Important**: Android 13 (API 33) and later requires the `POST_NOTIFICATIONS` permission to display notifications. This permission is already declared in `android/app/src/main/AndroidManifest.xml`.

**Permission Request Flow**:
- On first app launch, users will see a system permission dialog
- Users can grant or deny notification permission
- If denied, the app will display a SnackBar warning
- Users can enable notifications later in device Settings

**For Developers**:
- The permission is automatically requested when the app initializes
- No additional code changes are required for permission handling
- The permission is safely ignored on Android 12 and earlier versions

### Complete Development Cycle

Once the Rust side is ready, you can build the complete Android app with a single command:

```bash
make android-build
```

This will:
1. Regenerate FRB bindings
2. Build native libraries for all Android architectures
3. Copy libraries to the Android project
4. Clean and build the Flutter APK

To run tests:
```bash
make android-test
```

To install on a connected device:
```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

```bash
make android-build
```

This will:
1. Regenerate FRB bindings
2. Build native libraries for all Android architectures
3. Copy libraries to the Android project
4. Clean and build the Flutter APK

To run tests:
```bash
make android-test
```

To install on a connected device:
```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### Building the Android App

To build the Android APK, use Flutter Version Management (fvm) to ensure the correct Flutter version. fvm is a tool for managing Flutter SDK versions per project, avoiding global version conflicts.

#### Build Output Locations

The APK output location depends on whether you build a debug or release variant:

**Debug Builds** (using `--debug` flag):
- Output directory: `build/app/outputs/flutter-apk/`
- Example APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Use for: Development and testing with full debugging capabilities

**Release Builds** (using `--release` flag or default):
- Output directory: `android/app/build/outputs/apk/release/`
- Example APK: `android/app/build/outputs/apk/release/app-release.apk`
- Use for: Production distribution and performance testing

#### Build Commands

**Debug APK (recommended for development):**
```bash
fvm flutter build apk --debug
```

**Release APK:**
```bash
fvm flutter build apk --release
```

**Note**: The `--debug` and `--release` flags determine the output location. Debug builds use Flutter's optimized output path (`build/app/outputs/flutter-apk/`), while release builds use the standard Android build output path (`android/app/build/outputs/apk/release/`).

On success, you'll see output indicating the built APK location. This may take several minutes depending on your machine.

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

#### Option 1: Shell Script (DEPRECATED - REMOVED)
> ⚠️ **Note:** The shell script (`scripts/build-android.sh`) has been removed. Please use the Makefile option instead.

See [Option 2: Makefile](#option-2-makefile) below for the current recommended build method.

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

#### Notification Permission Issues

**Notifications Not Appearing on Android 13+**

If notifications are not displaying on Android 13 (API 33) or later devices:

1. **Check Permission Status**:
   ```bash
   # Check if permission is declared in manifest
   grep POST_NOTIFICATIONS android/app/src/main/AndroidManifest.xml
   # Should return: <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
   ```

2. **Verify User Granted Permission**:
   - Go to device Settings → Apps → MCAL → Notifications
   - Ensure "Notifications" is enabled
   - If disabled, toggle it to enable

3. **Check App Logs**:
   ```bash
   # Filter for notification-related errors
   adb logcat | grep -i "notification\|permission"
   ```

4. **Reinstall App**:
   ```bash
   adb uninstall com.example.mcal
   fvm flutter install
   ```
   - This will trigger the permission request dialog again

**Permission Denied Scenario**:
- If user denies notification permission, app displays: "Notification permissions denied. Events will not notify."
- User can enable notifications later in Settings → Apps → MCAL → Notifications
- No app restart is required after enabling in settings

**For Developers Testing Permission Flow**:
```bash
# Reset app data to trigger fresh permission request
adb shell pm clear com.example.mcal

# Reinstall app
fvm flutter install

# App will show permission dialog on first launch
```

#### Certificate Reading Functionality

When testing certificate-related features, ensure app has proper permissions in Android manifest. Test on physical devices for accurate results, as emulators may not fully simulate certificate stores. Never hardcode private keys or sensitive certificate data in code; use Android's KeyStore for secure storage.

#### FRB Bindings Regeneration

Always regenerate FRB bindings after modifying Rust API definitions in `native/src/api.rs` or related files. On success, you'll see updated files in `frb_generated/` directories. If regeneration fails, check for syntax errors in Rust code.

#### Version Management

Use `fvm` consistently to avoid version conflicts. Check the project's Flutter version with `fvm flutter --version`. If fvm commands fail, ensure it's installed globally.

#### Build Failures

If builds fail due to Rust compilation, verify that `cargo ndk` is installed (`cargo install cargo-ndk`) and that Android SDK/NDK paths are correctly set in your environment variables.

#### Network Issues

If `fvm flutter pub get` fails, check your internet connection, firewall settings, and proxy configuration.

#### Device Connection Problems

For physical devices, enable USB debugging in developer options. For emulators, ensure Android Studio/AVD Manager is running and emulator is started. If `flutter devices` shows no devices, restart device/emulator or check USB cables.

#### Emulator Performance

Emulators can be slow; consider using physical devices for testing certificate and performance-critical features.