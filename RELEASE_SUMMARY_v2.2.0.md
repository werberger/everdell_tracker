# Release v2.2.0: Web App & Release Signing

## 🌐 Major New Feature: Web App Support

The Everdell Tracker is now available as a Progressive Web App (PWA)!

### What This Means
- ✅ Access the app from any web browser (desktop or mobile)
- ✅ Install on mobile devices without downloading an APK
- ✅ Works on iPhone/iPad (via browser)
- ✅ Automatic updates (no manual APK installation)
- ✅ Cross-platform data export/import

### Deployment
- Hosted on Render (free tier)
- URL: `https://everdell-tracker-web.onrender.com` (or your custom domain)
- Auto-deploys from GitHub `main` branch

## 🔐 Release Keystore Implementation

### What Changed
- **v2.1.0 and earlier**: Used debug signing keys
- **v2.2.0 and later**: Use release signing keys

### Impact on Users
- **One-time reinstall required** for existing users
- Users must export data before uninstalling v2.1.0
- Install v2.2.0 and import data
- After this, all future updates will work seamlessly (no data loss)

### Why This Matters
- Updates will now work in-place (no uninstall needed)
- User data persists across app updates
- Professional app signing

## 📦 New Features in v2.2.0

### 1. Web Platform Support
- Browser-based storage using SharedPreferences
- Responsive design for all screen sizes
- PWA installation support
- Offline capability (after first load)

### 2. Cross-Platform Data Portability
- Export data as JSON file
- Import data from any platform
- Works between web and Android versions
- Preserves all game history and settings

### 3. Platform-Agnostic Storage
- Automatically uses correct storage for each platform
- Web: SharedPreferences (localStorage)
- Mobile: Hive (local database)
- Transparent to the user

### 4. Release Signing
- Proper APK signing for production
- Enables seamless app updates
- Data persistence across updates

## 🚀 Deployment Options

### Option 1: Android APK (Existing)
- Download from GitHub Releases
- 4 icon variants available
- Install manually on device

### Option 2: Web App (NEW!)
- Visit URL in browser
- Add to Home Screen on mobile
- Works like a native app

### Option 3: iPhone/iPad (NEW!)
- Open web URL in Safari
- Tap Share → Add to Home Screen
- Full PWA experience

## 📋 Migration Guide

### For Existing v2.1.0 Users

1. **Export your data**:
   - Open Everdell Tracker v2.1.0
   - Go to Settings
   - Tap "Export Data"
   - Save the JSON file

2. **Uninstall v2.1.0**:
   - Long-press app icon
   - Select "Uninstall"

3. **Install v2.2.0**:
   - Download APK from GitHub Releases
   - Install on device

4. **Import your data**:
   - Open Everdell Tracker v2.2.0
   - Go to Settings
   - Tap "Import Data"
   - Select the saved JSON file

### For New Users
- Just install and start using!
- No migration needed

## 🔧 Technical Changes

### Dependencies Added
- `shared_preferences: ^2.2.2` - Web storage
- `flutter_web_plugins` - Web platform support

### New Services
- `PlatformStorageService` - Platform detection and routing
- `WebStorageService` - Web-specific storage
- `DataExportService` - Cross-platform data export/import

### New Files
- `render.yaml` - Render deployment config
- `WEB_DEPLOYMENT.md` - Web deployment guide
- `KEYSTORE_SETUP.md` - Keystore documentation
- Various web helper files

### Configuration Updates
- Updated `web/index.html` for PWA
- Updated `web/manifest.json` with branding
- Modified `android/app/build.gradle.kts` for release signing
- Updated all providers to use `PlatformStorageService`

## 📊 Build Information

### Android APKs
- **Version**: 2.2.0+7
- **Signing**: Release keystore
- **Size**: ~80MB per APK
- **Variants**: Teacher, Badger, Evertree, Squirrel icons

### Web App
- **Version**: 2.2.0+7
- **Renderer**: CanvasKit
- **Initial Load**: ~80MB
- **Cached**: Minimal on subsequent visits

## 🔮 Future Plans

### Potential Enhancements
- Service workers for better offline support
- Background sync
- Push notifications (web)
- Cloud sync (optional, requires backend)
- iPhone native app (if demand exists)

## 📝 Documentation

- **`WEB_DEPLOYMENT.md`**: Complete web deployment guide
- **`KEYSTORE_SETUP.md`**: Release signing documentation
- **`KEYSTORE_BACKUP.txt`**: Backup instructions
- **GitHub Actions**: Updated for release signing

## 🙏 Testing Needed

Before widespread release, test:
1. ✅ Android v2.1.0 → v2.2.0 migration (uninstall/reinstall)
2. ⏳ Web app on desktop browser
3. ⏳ Web app on mobile browser
4. ⏳ PWA installation on Android
5. ⏳ PWA installation on iPhone
6. ⏳ Export from Android → Import to web
7. ⏳ Export from web → Import to Android
8. ⏳ All scoring features on web
9. ⏳ Rulebook viewer on web
10. ⏳ Settings persistence on web

## 🐛 Known Issues

None at this time.

## 📞 Support

If you encounter issues:
1. Check the documentation (`WEB_DEPLOYMENT.md`, `KEYSTORE_SETUP.md`)
2. Verify data was exported before migration
3. Try clearing browser cache (web)
4. Reinstall app (mobile)

---

**Build Date**: January 22, 2026  
**Flutter Version**: 3.38.7  
**Platforms**: Android, Web (iOS via web)
