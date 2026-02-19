#!/bin/bash
# Build Web Release
# This script builds an optimized web release

echo "Building Web Release..."
echo ""

# Change to project root
cd "$(dirname "$0")/.."

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build Web release
echo "Building Web release..."
flutter build web

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "Build completed successfully!"
echo "Output location: build/web"
echo ""
