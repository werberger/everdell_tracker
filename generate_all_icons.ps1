#!/usr/bin/env pwsh
# Generate launcher icons for all app flavors

Write-Host "Generating Teacher icons..." -ForegroundColor Cyan
flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-teacher.yaml

Write-Host "`nGenerating Badger icons..." -ForegroundColor Cyan
flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-badger.yaml

Write-Host "`nGenerating Evertree icons..." -ForegroundColor Cyan
flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-evertree.yaml

Write-Host "`nGenerating Squirrel icons..." -ForegroundColor Cyan
flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-squirrel.yaml

Write-Host "`n✅ All icons generated successfully!" -ForegroundColor Green
Write-Host "`nIcon files created in:" -ForegroundColor Yellow
Write-Host "  - android/app/src/main/res/mipmap-*/" -ForegroundColor White
