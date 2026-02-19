# Build Windows Setup Installer
# This script builds an optimized Windows executable and creates an installer

Write-Host "Building Windows Executable with obfuscation..." -ForegroundColor Green
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

# Build Windows executable with obfuscation enabled
Write-Host "Building Windows executable..." -ForegroundColor Yellow
flutter build windows `
    --release `
    --obfuscate `
    --split-debug-info=build\windows\symbols

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed with error code $LASTEXITCODE" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Windows executable build completed successfully!" -ForegroundColor Green
Write-Host "Output: build\windows\runner\Release" -ForegroundColor Cyan
Write-Host ""

# Check if Inno Setup compiler exists
$isccPath = Get-Command iscc -ErrorAction SilentlyContinue
if ($isccPath) {
    Write-Host "Building installer using Inno Setup..." -ForegroundColor Yellow
    & iscc installers\grade_vault_installer.iss
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Installer creation failed!" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host "Installer created successfully!" -ForegroundColor Green
    Write-Host "Check installers\Output folder for the setup executable." -ForegroundColor Cyan
}
else {
    Write-Host "Inno Setup compiler (iscc.exe) not found in PATH." -ForegroundColor Yellow
    Write-Host "Windows executable is ready in build\windows\runner\Release" -ForegroundColor Cyan
    Write-Host "You can manually create an installer using Inno Setup Studio or another installer tool." -ForegroundColor Cyan
}

Read-Host "Press Enter to exit"
