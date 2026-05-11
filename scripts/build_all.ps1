# Build All Releases
# This script builds APK, App Bundle, and Windows Setup with obfuscation

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   GRADE VAULT - Complete Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Change to project root
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

# Clear previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: flutter clean returned code $LASTEXITCODE" -ForegroundColor Yellow
}

flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: flutter pub get failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Build APK
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 1: Building APK with obfuscation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
flutter build apk `
    --release `
    --obfuscate `
    --split-debug-info=build/app/outputs/symbols

if ($LASTEXITCODE -ne 0) {
    Write-Host "APK build failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "APK build completed successfully!" -ForegroundColor Green
Write-Host ""

# Build App Bundle
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 2: Building App Bundle with obfuscation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
flutter build appbundle `
    --release `
    --obfuscate `
    --split-debug-info=build/app/outputs/symbols

if ($LASTEXITCODE -ne 0) {
    Write-Host "App Bundle build failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "App Bundle build completed successfully!" -ForegroundColor Green
Write-Host ""

# Build Windows
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 3: Building Windows executable with obfuscation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
flutter build windows `
    --release `
    --obfuscate `
    --split-debug-info=build\windows\symbols

if ($LASTEXITCODE -ne 0) {
    Write-Host "Windows build failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Windows build completed successfully!" -ForegroundColor Green
Write-Host ""

# Build Web
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 4: Building Web release" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
flutter build web

if ($LASTEXITCODE -ne 0) {
    Write-Host "Web build failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Web build completed successfully!" -ForegroundColor Green
Write-Host ""

# Try to build Windows installer
$isccPath = Get-Command iscc -ErrorAction SilentlyContinue
if ($isccPath) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Step 5: Building Windows Installer" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    & iscc installers\windows_installer.iss
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: Installer creation had issues." -ForegroundColor Yellow
    }
    else {
        Write-Host "Installer created successfully!" -ForegroundColor Green
    }
}
else {
    Write-Host "Note: Inno Setup compiler not found. Skipping installer creation." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Build Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Output locations:" -ForegroundColor Cyan
Write-Host "   APK:           build\app\outputs\app-release.apk" -ForegroundColor Yellow
Write-Host "   App Bundle:    build\app\outputs\app-release.aab" -ForegroundColor Yellow
Write-Host "   Windows Exe:   build\windows\runner\Release" -ForegroundColor Yellow
Write-Host "   Web:           build\web" -ForegroundColor Yellow
Write-Host "   Symbols:       build\app\outputs\symbols (Android)" -ForegroundColor Yellow
Write-Host "                  build\windows\symbols (Windows)" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to exit"
