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