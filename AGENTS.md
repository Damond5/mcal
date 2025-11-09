<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

OpenSpec is a specification system used in this project for managing change proposals and project guidelines.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

The @/ notation refers to the project's openspec/ directory.

This block is auto-managed and should not be edited manually.

<!-- OPENSPEC:END -->

## Android Development Workflow

This section provides guidelines for Android-specific development tasks in the MCAL project, which uses Flutter with Rust integration via Flutter Rust Bridge (FRB).

### Building the Android App

To build the Android APK, use Flutter Version Management (fvm) to ensure the correct Flutter version:

```bash
fvm flutter build apk
```

This command builds a release APK in the `android/app/build/outputs/apk/release/` directory.

### Testing on Android Devices

To run the app on a specific Android device or emulator:

1. List available devices:
   ```bash
   fvm flutter devices
   ```

2. Run on a specific device:
   ```bash
   fvm flutter run --device-id <device_id>
   ```
   Replace `<device_id>` with the ID from the devices list (e.g., emulator-5554 or a physical device ID).

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

The project uses Rust code that needs to be compiled for Android architectures. Use `cargo ndk` for cross-compilation:

1. Ensure Android NDK is installed and configured.

2. Build for all Android architectures:
   ```bash
   cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 build --release
   ```

3. For debugging builds:
   ```bash
   cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 build
   ```

### Additional Troubleshooting

- **Certificate Reading Functionality**: When testing certificate-related features, ensure the app has proper permissions. Test on physical devices for accurate results, as emulators may not fully simulate certificate stores.

- **FRB Bindings Regeneration**: Always regenerate FRB bindings after modifying Rust API definitions in `native/src/api.rs` or related files.

- **Version Management**: Use `fvm` consistently to avoid version conflicts. Check the project's Flutter version with `fvm flutter --version`.

- **Build Failures**: If builds fail due to Rust compilation, verify that `cargo ndk` is installed and that the Android SDK/NDK paths are correctly set in your environment.
