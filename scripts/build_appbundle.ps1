# Build App Bundle with Obfuscation
# This script builds an optimized App Bundle for Android with code obfuscation
# Note: App Bundle is used for Google Play Store distribution

Write-Host "Building App Bundle with obfuscation..." -ForegroundColor Green
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

# Build App Bundle with obfuscation enabled
Write-Host "Building App Bundle..." -ForegroundColor Yellow
flutter build appbundle `
  --release `
  --obfuscate `
  --split-debug-info=build/app/outputs/symbols

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed with error code $LASTEXITCODE" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "App Bundle build completed successfully!" -ForegroundColor Green
Write-Host "Output: build\app\outputs\app-release.aab" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: This file can be uploaded to Google Play Console for distribution." -ForegroundColor Cyan
Read-Host "Press Enter to exit"
