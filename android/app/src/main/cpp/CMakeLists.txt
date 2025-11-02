cmake_minimum_required(VERSION 3.10)

# Pre-built Rust library for Android
add_library(mcal_native SHARED IMPORTED)
set_target_properties(mcal_native PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/libs/${CMAKE_ANDROID_ARCH_ABI}/libmcal_native.so)