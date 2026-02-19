#!/bin/bash
# Build All Releases
# This script builds APK, App Bundle, and Windows Setup with obfuscation

echo ""
echo "========================================"
echo "   GRADE VAULT - Complete Build Script"
echo "========================================"
echo ""

# Change to project root
cd "$(dirname "$0")/.."

# Clear previous builds
echo "Cleaning previous builds..."
flutter clean
flutter pub get
echo ""

# Build APK
echo "========================================"
echo "Step 1: Building APK with obfuscation"
echo "========================================"
echo ""
flutter build apk \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

if [ $? -ne 0 ]; then
    echo "APK build failed!"
    exit 1
fi
echo "APK build completed successfully!"
echo ""

# Build App Bundle
echo "========================================"
echo "Step 2: Building App Bundle with obfuscation"
echo "========================================"
echo ""
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols

if [ $? -ne 0 ]; then
    echo "App Bundle build failed!"
    exit 1
fi
echo "App Bundle build completed successfully!"
echo ""

# Build Windows
echo "========================================"
echo "Step 3: Building Windows executable with obfuscation"
echo "========================================"
echo ""
flutter build windows \
  --release \
  --obfuscate \
  --split-debug-info=build/windows/symbols

if [ $? -ne 0 ]; then
    echo "Windows build failed!"
    exit 1
fi
echo "Windows build completed successfully!"
echo ""

# Build Web
echo "========================================"
echo "Step 4: Building Web release"
echo "========================================"
echo ""
flutter build web

if [ $? -ne 0 ]; then
    echo "Web build failed!"
    exit 1
fi
echo "Web build completed successfully!"
echo ""

# Try to build Windows installer
if command -v iscc &> /dev/null; then
    echo "========================================"
    echo "Step 5: Building Windows Installer"
    echo "========================================"
    echo ""
    iscc installers/grade_vault_installer.iss
    if [ $? -ne 0 ]; then
        echo "Warning: Installer creation had issues."
    else
        echo "Installer created successfully!"
    fi
else
    echo "Note: Inno Setup compiler not found. Skipping installer creation."
fi

echo ""
echo "========================================"
echo "   Build Complete!"
echo "========================================"
echo ""
echo "Output locations:"
echo "   APK:           build/app/outputs/app-release.apk"
echo "   App Bundle:    build/app/outputs/app-release.aab"
echo "   Windows Exe:   build/windows/runner/Release"
echo "   Web:           build/web"
echo "   Symbols:       build/app/outputs/symbols (Android)"
echo "                  build/windows/symbols (Windows)"
echo ""
