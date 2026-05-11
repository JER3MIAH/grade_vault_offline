#!/bin/bash
# Build Windows Setup Installer
# This script builds an optimized Windows executable and creates an installer

echo "Building Windows Executable with obfuscation..."
echo ""

# Change to project root
cd "$(dirname "$0")/.."

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build Windows executable with obfuscation enabled
echo "Building Windows executable..."
flutter build windows \
  --release \
  --obfuscate \
  --split-debug-info=build/windows/symbols

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "Windows executable build completed successfully!"
echo "Output: build/windows/runner/Release"
echo ""

# Check if Inno Setup compiler exists (for Windows systems)
if command -v iscc &> /dev/null; then
    echo "Building installer using Inno Setup..."
    iscc installers/windows_installer.iss
    if [ $? -eq 0 ]; then
        echo "Installer created successfully!"
        echo "Check installers/Output folder for the setup executable."
    else
        echo "Installer creation failed!"
        exit 1
    fi
else
    echo "Inno Setup compiler (iscc) not found."
    echo "Windows executable is ready in build/windows/runner/Release"
    echo "You can manually create an installer using Inno Setup Studio or another installer tool."
fi
