## Android Development Workflow

This section provides guidelines for Android-specific development tasks in the MCAL project, which uses Flutter with Rust integration via Flutter Rust Bridge (FRB). For general project setup, see the [project README](../README.md).

### Building the Android App

To build the Android APK, use Flutter Version Management (fvm) to ensure the correct Flutter version. fvm is a tool for managing Flutter SDK versions per project, avoiding global version conflicts.

```bash
fvm flutter build apk
```

This command builds a release APK in the `android/app/build/outputs/apk/release/` directory. On success, you'll see output like "Built build/app/outputs/apk/release/app-release.apk". This may take several minutes depending on your machine.

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

When Rust code changes affect the FRB bindings, you may encounter content hash mismatches. To resolve:

1. Regenerate the bindings:
   ```bash
   flutter_rust_bridge_codegen generate
   ```

2. If issues persist, clean and rebuild:
   ```bash
   fvm flutter clean
   flutter_rust_bridge_codegen generate
   fvm flutter pub get
   ```

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

### Additional Troubleshooting

- **Certificate Reading Functionality**: When testing certificate-related features, ensure the app has proper permissions in the Android manifest. Test on physical devices for accurate results, as emulators may not fully simulate certificate stores. Never hardcode private keys or sensitive certificate data in the code; use Android's KeyStore for secure storage.

- **FRB Bindings Regeneration**: Always regenerate FRB bindings after modifying Rust API definitions in `native/src/api.rs` or related files. On success, you'll see updated files in `frb_generated/` directories. If regeneration fails, check for syntax errors in Rust code.

- **Version Management**: Use `fvm` consistently to avoid version conflicts. Check the project's Flutter version with `fvm flutter --version`. If fvm commands fail, ensure it's installed globally.

- **Build Failures**: If builds fail due to Rust compilation, verify that `cargo ndk` is installed (`cargo install cargo-ndk`) and that Android SDK/NDK paths are correctly set in your environment variables.

- **Network Issues**: If `fvm flutter pub get` fails, check your internet connection, firewall settings, and proxy configuration.

- **Device Connection Problems**: For physical devices, enable USB debugging in developer options. For emulators, ensure Android Studio/AVD Manager is running and the emulator is started. If `flutter devices` shows no devices, restart the device/emulator or check USB cables.

- **Emulator Performance**: Emulators can be slow; consider using physical devices for testing certificate and performance-critical features.