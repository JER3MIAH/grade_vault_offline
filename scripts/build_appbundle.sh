#!/bin/bash
# Build App Bundle with Obfuscation
# This script builds an optimized App Bundle for Android with code obfuscation
# Note: App Bundle is used for Google Play Store distribution

echo "Building App Bundle with obfuscation..."
echo ""

# Change to project root
cd "$(dirname "$0")/.."

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build App Bundle with obfuscation enabled
echo "Building App Bundle..."
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "App Bundle build completed successfully!"
echo "Output: build/app/outputs/app-release.aab"
echo ""
echo "Note: This file can be uploaded to Google Play Console for distribution."
