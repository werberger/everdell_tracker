# Multi-Flavor APK Setup

## Overview

The app now builds **4 separate APKs** with different app icons, allowing users to choose their favorite Everdell character.

## The 4 Flavors

| Flavor | Icon | Application ID |
|--------|------|----------------|
| Teacher | `teacher-logo.png` | `com.example.everdell_tracker.teacher` |
| Badger | `badger-logo.png` | `com.example.everdell_tracker.badger` |
| Evertree | `evertree-logo.png` | `com.example.everdell_tracker.evertree` |
| Squirrel | `squirrel-logo.png` | `com.example.everdell_tracker.squirrel` |

Each flavor:
- Has a unique app icon
- Uses a different application ID (can install multiple on same device)
- Has the same functionality
- Gets built and released automatically

## Files Created

### Icon Configuration Files
1. `flutter_launcher_icons-teacher.yaml` - Teacher icon config
2. `flutter_launcher_icons-badger.yaml` - Badger icon config
3. `flutter_launcher_icons-evertree.yaml` - Evertree icon config
4. `flutter_launcher_icons-squirrel.yaml` - Squirrel icon config

### Build Scripts
1. `generate_all_icons.ps1` - Generates all 4 icon sets
2. `build_all_flavors.ps1` - Builds all 4 APKs locally

### Configuration Files
1. `android/app/build.gradle.kts` - Added product flavors configuration

### Workflow
1. `.github/workflows/android-release.yml` - Updated to build all 4 flavors

## How It Works

### Product Flavors in build.gradle.kts
```kotlin
flavorDimensions += "icon"
productFlavors {
    create("teacher") {
        dimension = "icon"
        applicationIdSuffix = ".teacher"
        versionNameSuffix = "-teacher"
    }
    // ... badger, evertree, squirrel ...
}
```

### Icon Generation
Each flavor gets its own launcher icon:
- `ic_launcher_teacher`
- `ic_launcher_badger`
- `ic_launcher_evertree`
- `ic_launcher_squirrel`

Icons are generated from the respective PNG files in `assets/images/`.

### GitHub Actions Workflow
On push to main:
1. Generates all 4 icon sets
2. Builds 4 APKs + 4 AABs
3. Uploads to GitHub Release:
   - `everdell-tracker-teacher-v2.0.0.apk`
   - `everdell-tracker-badger-v2.0.0.apk`
   - `everdell-tracker-evertree-v2.0.0.apk`
   - `everdell-tracker-squirrel-v2.0.0.apk`
   - (+ 4 AAB files for Play Store)

## Local Testing

### Generate Icons
```powershell
.\generate_all_icons.ps1
```

### Build Specific Flavor
```powershell
# Teacher
flutter build apk --release --flavor teacher

# Badger
flutter build apk --release --flavor badger

# Evertree
flutter build apk --release --flavor evertree

# Squirrel
flutter build apk --release --flavor squirrel
```

### Build All Flavors
```powershell
.\build_all_flavors.ps1
```

### Run Specific Flavor in Debug
```powershell
flutter run --flavor teacher
```

## Output Files

### APKs
```
build/app/outputs/flutter-apk/
├── app-teacher-release.apk
├── app-badger-release.apk
├── app-evertree-release.apk
└── app-squirrel-release.apk
```

### App Bundles (for Play Store)
```
build/app/outputs/bundle/
├── teacherRelease/app-teacher-release.aab
├── badgerRelease/app-badger-release.aab
├── evertreeRelease/app-evertree-release.aab
└── squirrelRelease/app-squirrel-release.aab
```

## Installation Notes

### Multiple Installs
Because each flavor has a different application ID, users can:
- Install multiple flavors on the same device
- Each appears as a separate app with different icon
- Each maintains its own data/settings

### Single Install
Most users will only want one flavor:
- Choose favorite icon
- Install that APK
- Done!

## GitHub Release

When you push, GitHub Actions will:
1. Take ~10-15 minutes to build all flavors
2. Create release with 8 downloadable files
3. Users can download their preferred icon variant

## Future Enhancements

Potential additions:
- [ ] App names per flavor (e.g., "Everdell Tracker - Teacher")
- [ ] Different color schemes per flavor
- [ ] Flavor-specific features
- [ ] Icon selection in-app (dynamic icons)

---

## Summary

✅ **4 APKs with different icons**  
✅ **Automated builds via GitHub Actions**  
✅ **Local build scripts for testing**  
✅ **Each flavor installable independently**  

**Ready to build and release!** 🎉
