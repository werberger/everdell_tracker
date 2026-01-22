# Generate Hive Adapters for Everdell Card System
# Run this script after creating or modifying Hive models

Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter pub run build_runner clean

Write-Host "`nGenerating Hive adapters..." -ForegroundColor Yellow
flutter pub run build_runner build --delete-conflicting-outputs

Write-Host "`nDone! Check for any errors above." -ForegroundColor Green
Write-Host "If successful, you should now have:" -ForegroundColor Cyan
Write-Host "  - lib/models/everdell_card.g.dart" -ForegroundColor Cyan

Read-Host "`nPress Enter to close"
