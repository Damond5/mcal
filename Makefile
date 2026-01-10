.PHONY: android-build android-libs android-clean android-test android-verify

android-libs:
	cd native && cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 build --release
	cp native/target/aarch64-linux-android/release/libmcal_native.so android/app/src/main/cpp/libs/arm64-v8a/
	cp native/target/armv7-linux-androideabi/release/libmcal_native.so android/app/src/main/cpp/libs/armeabi-v7a/
	cp native/target/i686-linux-android/release/libmcal_native.so android/app/src/main/cpp/libs/x86/
	cp native/target/x86_64-linux-android/release/libmcal_native.so android/app/src/main/cpp/libs/x86_64/

android-build: android-libs
	flutter_rust_bridge_codegen generate --config-file frb.yaml
	fvm flutter clean && fvm flutter build apk --debug

android-test:
	fvm flutter test integration_test/app_integration_test.dart

android-verify:
	@echo "Checking FRB generated file timestamps..."
	ls -la lib/frb_generated.dart native/src/frb_generated.rs
	@echo "Checking Android native library timestamps..."
	ls -la android/app/src/main/cpp/libs/*/libmcal_native.so

android-clean:
	fvm flutter clean
	cd native && cargo clean

.PHONY: test-integration-linux test-integration-android test-integration-all
test-integration-linux:
	@echo "Running integration tests on Linux..."
	./scripts/test-integration-linux.sh

test-integration-android:
	@echo "Running integration tests on Android..."
	./scripts/test-integration-android.sh

test-integration-all: test-integration-linux test-integration-android
	@echo "Running integration tests on all platforms..."
	@echo "Note: This will run tests on both Linux and Android sequentially"