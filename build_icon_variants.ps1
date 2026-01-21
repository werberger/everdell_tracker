# Script to build APKs with different icon variants
# Usage: powershell -ExecutionPolicy Bypass -File build_icon_variants.ps1

$icons = @(
    @{name="teacher"; path="assets/images/teacher-logo.png"},
    @{name="badger"; path="assets/images/badger-logo.png"},
    @{name="evertree"; path="assets/images/evertree-logo.png"},
    @{name="squirrel"; path="assets/images/squirrel-logo.png"}
)

# Get current version from pubspec.yaml
$pubspecContent = Get-Content "pubspec.yaml" -Raw
$versionMatch = [regex]::Match($pubspecContent, 'version:\s+(\d+\.\d+\.\d+)')
$version = $versionMatch.Groups[1].Value

Write-Host "Building APKs for version $version" -ForegroundColor Cyan
Write-Host ""

$originalPubspec = Get-Content "pubspec.yaml" -Raw

foreach ($icon in $icons) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Building APK with $($icon.name) icon..." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Update pubspec.yaml with new icon path
    $modifiedPubspec = $originalPubspec -replace 'image_path: "assets/images/.*-logo\.png"', "image_path: `"$($icon.path)`""
    $modifiedPubspec = $modifiedPubspec -replace 'adaptive_icon_foreground: "assets/images/.*-logo\.png"', "adaptive_icon_foreground: `"$($icon.path)`""
    $modifiedPubspec | Set-Content "pubspec.yaml"
    
    # Generate new icons
    Write-Host "Generating $($icon.name) launcher icons..." -ForegroundColor Yellow
    flutter pub run flutter_launcher_icons
    
    # Build APK
    Write-Host ""
    Write-Host "Building APK..." -ForegroundColor Yellow
    flutter build apk --release
    
    # Rename APK
    $apkName = "everdell-tracker-$($icon.name)-v$version.apk"
    Copy-Item "build\app\outputs\flutter-apk\app-release.apk" "build\app\outputs\flutter-apk\$apkName"
    Write-Host ""
    Write-Host "Created: $apkName" -ForegroundColor Green
}

# Restore original pubspec.yaml
$originalPubspec | Set-Content "pubspec.yaml"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "All APKs built successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "APKs are in: build\app\outputs\flutter-apk\" -ForegroundColor Cyan
Get-ChildItem "build\app\outputs\flutter-apk\everdell-tracker-*-v$version.apk"
