#!/usr/bin/env pwsh
# Build all app flavors (4 APKs with different icons)

Write-Host "Building Everdell Tracker - All Flavors" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Clean build
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "`nGetting dependencies..." -ForegroundColor Yellow
flutter pub get

# Generate code
Write-Host "`nGenerating Hive adapters..." -ForegroundColor Yellow
flutter pub run build_runner build --delete-conflicting-outputs

# Generate all icons
Write-Host "`nGenerating app icons..." -ForegroundColor Yellow
& .\generate_all_icons.ps1

# Build each flavor
Write-Host "`nBuilding Teacher APK..." -ForegroundColor Cyan
flutter build apk --release --flavor teacher
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Teacher APK built successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Teacher APK build failed" -ForegroundColor Red
    exit 1
}

Write-Host "`nBuilding Badger APK..." -ForegroundColor Cyan
flutter build apk --release --flavor badger
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Badger APK built successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Badger APK build failed" -ForegroundColor Red
    exit 1
}

Write-Host "`nBuilding Evertree APK..." -ForegroundColor Cyan
flutter build apk --release --flavor evertree
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Evertree APK built successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Evertree APK build failed" -ForegroundColor Red
    exit 1
}

Write-Host "`nBuilding Squirrel APK..." -ForegroundColor Cyan
flutter build apk --release --flavor squirrel
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Squirrel APK built successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Squirrel APK build failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✅ All APKs built successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nAPK files location:" -ForegroundColor Yellow
Write-Host "  build/app/outputs/flutter-apk/" -ForegroundColor White
Write-Host "`nAPK files:" -ForegroundColor Yellow
Write-Host "  - app-teacher-release.apk" -ForegroundColor White
Write-Host "  - app-badger-release.apk" -ForegroundColor White
Write-Host "  - app-evertree-release.apk" -ForegroundColor White
Write-Host "  - app-squirrel-release.apk" -ForegroundColor White
