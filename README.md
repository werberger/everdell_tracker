# Everdell Tracker

Everdell Tracker is a cross-platform scoring and record-keeping app for the
board game Everdell. It supports detailed score breakdowns, expansions, history,
player stats, and local-only storage with export/import.

## Features

- Add unlimited players with name autocomplete
- Detailed scoring breakdown or quick total entry
- Expansion-specific scoring templates
- Automatic total and tiebreaker resource tracking
- Game history with edit/delete, sorting, and filtering
- Player stats (win rate, averages, highest score, breakdowns)
- Export/import game data as JSON via sharing apps
- Optional dark mode

## Requirements

- Flutter SDK (stable channel)
- Android SDK (for building APK)

## Run Locally

```
flutter pub get
flutter run
```

## Build APK (Android)

```
flutter build apk --release
```

APK output:

```
build/app/outputs/flutter-apk/app-release.apk
```

### Install APK on Android

1. Copy the APK to your Android device.
2. Enable “Install unknown apps” in device settings.
3. Open the APK and install.

## iOS Build Notes

Building iOS requires macOS with Xcode. Once on macOS:

```
flutter build ios --release
```

## Export & Import

- Export: Game History → menu → Export → choose All or Filtered
- Import: Game History → menu → Import → select JSON file
- Duplicate handling supports Skip, Overwrite, or Keep Both

## Data Backup

Use export to keep a backup of your game history in case you change devices.

## Roadmap

- Card selection mode for automatic scoring
- iOS build pipeline
