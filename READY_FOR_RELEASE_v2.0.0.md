# Ready for Release v2.0.0 - Testing Guide

## ✅ Changes Made

### 1. Fixed Card Image Sizing ✅
- Changed `BoxFit.cover` to `BoxFit.contain`
- **Full card image now visible** (no cropping on sides)
- Card maintains aspect ratio (2.5:3.5) at all scales
- Responsive sizing - cards scale properly
- Name and description remain readable

### 2. Fixed Carousel Overflow ✅
- Wrapped `CardCarouselWidget` in `Expanded` 
- Removed fixed height
- Now uses all available space
- No more overflow warnings

### 3. Consistent Button Layout (Both Views) ✅
**Grid and Carousel now match:**
- **Minus button**: Top left (red, when selected)
- **Count badge**: Top center (amber, shows quantity)
- **Plus button**: Top right (green, for common cards)
- Semi-transparent gradient background
- Saves screen space

### 4. Multi-Flavor APK Setup ✅
**4 APKs with different icons:**
- Teacher (hedgehog with book)
- Badger (wanderer badger)
- Evertree (Ever Tree)
- Squirrel (squirrel with berries)

**Configuration:**
- Product flavors in `build.gradle.kts`
- Icon configs for each flavor
- Build scripts: `generate_all_icons.ps1` & `build_all_flavors.ps1`
- Updated GitHub Actions workflow

### 5. Prepared for Major Release ✅
- **Version bumped**: 1.3.1+4 → **2.0.0+5**
- **4 APKs + 4 AABs** will be built automatically
- **GitHub Actions workflow** builds all flavors
- **Release notes** with all features documented

---

## 🧪 Testing Checklist

### Test Card Image Sizing (CRITICAL)
- [ ] Open visual card selection
- [ ] Switch to Fan layout
- [ ] Browse through different cards
- [ ] **Verify**: FULL card image visible (not cropped on sides)
- [ ] **Verify**: Image shows completely without cutting
- [ ] Resize window smaller → **Verify**: Cards scale down but maintain ratio
- [ ] Resize window larger → **Verify**: Cards scale up but maintain ratio
- [ ] **Verify**: Name and description always readable

### Test Carousel Layout
- [ ] **Verify**: No yellow/black overflow warning
- [ ] **Verify**: Carousel fits nicely in available space
- [ ] Cards fan out properly
- [ ] Card overlap looks natural (hand-like)

### Test Button Consistency (Both Layouts)
- [ ] **Fan Layout**: Select a common card (e.g., Farm)
  - [ ] Plus button at top right (green)
  - [ ] Minus button at top left (red, when selected)
  - [ ] Count badge at top center (amber)
- [ ] **Grid Layout**: Select a common card
  - [ ] Plus button at top right (green)
  - [ ] Minus button at top left (red, when selected)
  - [ ] Count badge at top center (amber)
- [ ] **Verify**: Button positions identical in both views

### Test Both Layouts
- [ ] **Table Top**: Verify buttons still work
- [ ] **Fan**: Verify all new features work
- [ ] Switch between layouts during card selection
- [ ] **Verify**: Selection persists

### General Functionality
- [ ] Add cards to city
- [ ] Remove cards
- [ ] Multiple common cards
- [ ] "Your City" section shows correct cards
- [ ] Score calculates correctly
- [ ] Save and verify score appears on game screen

---

## 🚀 When Ready to Release

### 1. Final Test
```powershell
flutter run -d windows
```
- Complete the testing checklist above
- Verify everything works as expected

### 2. Build Local APKs (Optional)

**Build all 4 flavors locally:**
```powershell
.\build_all_flavors.ps1
```
This will build:
- `app-teacher-release.apk`
- `app-badger-release.apk`
- `app-evertree-release.apk`
- `app-squirrel-release.apk`

All in `build/app/outputs/flutter-apk/`

**Or build individually:**
```powershell
# First generate icons
.\generate_all_icons.ps1

# Then build specific flavor
flutter build apk --release --flavor teacher
# or badger, evertree, squirrel
```

Test on Android device before pushing

### 3. Commit and Push
```powershell
git add .
git commit -m "Release v2.0.0: Visual card selection with carousel/fan interface"
git push
```

### 4. What Happens Next
1. **GitHub Actions** will automatically:
   - Generate all 4 icon sets
   - Build 4 APKs (teacher, badger, evertree, squirrel)
   - Build 4 AABs (app bundles)
   - Create release tag `v2.0.0`
   - Upload all 8 files to release
   - Add release notes

2. **GitHub Release** will be created at:
   - https://github.com/werberger/everdell_tracker/releases/tag/v2.0.0

3. **Download APKs** from release Assets:
   - `everdell-tracker-teacher-v2.0.0.apk` (Teacher icon)
   - `everdell-tracker-badger-v2.0.0.apk` (Badger icon)
   - `everdell-tracker-evertree-v2.0.0.apk` (Evertree icon)
   - `everdell-tracker-squirrel-v2.0.0.apk` (Squirrel icon)

---

## 📱 Installing on Phone

### From GitHub Release
1. Wait for Actions to complete (~10-15 minutes for 4 builds)
2. Go to https://github.com/werberger/everdell_tracker/releases
3. Find v2.0.0 release
4. **Choose your preferred icon**:
   - `everdell-tracker-teacher-v2.0.0.apk` (Teacher)
   - `everdell-tracker-badger-v2.0.0.apk` (Badger)
   - `everdell-tracker-evertree-v2.0.0.apk` (Evertree)
   - `everdell-tracker-squirrel-v2.0.0.apk` (Squirrel)
5. Transfer to phone
6. Install (may need to allow "Install from unknown sources")

### From Local Build
1. Build: `.\build_all_flavors.ps1`
2. Find: `build/app/outputs/flutter-apk/`
   - `app-teacher-release.apk`
   - `app-badger-release.apk`
   - `app-evertree-release.apk`
   - `app-squirrel-release.apk`
3. Transfer your preferred icon version to phone via USB/cloud
4. Install

---

## 📝 Files Changed

### Modified
- `lib/widgets/card_carousel_widget.dart` - Fixed image fit, buttons at top
- `lib/screens/card_selection_screen_example.dart` - Buttons at top for grid, wrapped carousel
- `lib/models/app_settings.dart` - Added useFanLayout setting
- `lib/providers/settings_provider.dart` - Added setUseFanLayout method
- `lib/screens/settings_screen.dart` - Added layout preference UI
- `android/app/build.gradle.kts` - Added 4 product flavors
- `pubspec.yaml` - Version bump to 2.0.0+5

### Created
- `.github/workflows/android-release.yml` - Automated 4-flavor build workflow
- `flutter_launcher_icons-*.yaml` (×4) - Icon configs for each flavor
- `generate_all_icons.ps1` - Script to generate all icons
- `build_all_flavors.ps1` - Script to build all 4 APKs locally
- `RELEASE_NOTES_v2.0.0.md` - Detailed release notes
- `MULTI_FLAVOR_SETUP.md` - Multi-flavor documentation
- `READY_FOR_RELEASE_v2.0.0.md` - This testing guide

---

## ⚠️ Important Notes

- **DO NOT PUSH** until you've tested locally
- First push will trigger automatic APK build
- Check GitHub Actions tab to see build progress
- Build takes ~5-10 minutes
- If build fails, fix and push again (version stays same)

---

## 🎉 Ready?

Once you've tested everything and are happy:

```powershell
# Commit all changes
git add .
git commit -m "Release v2.0.0: Visual card selection with carousel/fan interface"

# Push to trigger release
git push
```

Then watch the magic happen on GitHub! ✨
