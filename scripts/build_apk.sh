#!/bin/bash
# Build APK with Obfuscation
# This script builds an optimized APK for Android with code obfuscation

echo "Building APK with obfuscation..."
echo ""

# Change to project root
cd "$(dirname "$0")/.."

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build APK with obfuscation enabled
echo "Building APK..."
flutter build apk \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "APK build completed successfully!"
echo "Output: build/app/outputs/app-release.apk"
