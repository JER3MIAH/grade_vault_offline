# Build APK with Obfuscation
# This script builds an optimized APK for Android with code obfuscation

Write-Host "Building APK with obfuscation..." -ForegroundColor Green
Write-Host ""

# Change to project root
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: flutter clean returned code $LASTEXITCODE" -ForegroundColor Yellow
}

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: flutter pub get failed with code $LASTEXITCODE" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Build APK with obfuscation enabled
Write-Host "Building APK..." -ForegroundColor Yellow
flutter build apk `
  --release `
  --obfuscate `
  --split-debug-info=build/app/outputs/symbols

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed with error code $LASTEXITCODE" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "APK build completed successfully!" -ForegroundColor Green
Write-Host "Output: build\app\outputs\app-release.apk" -ForegroundColor Cyan
Read-Host "Press Enter to exit"
