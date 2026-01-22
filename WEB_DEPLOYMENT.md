# Web Deployment Guide

## Overview

The Everdell Tracker app is now configured to run as a Progressive Web App (PWA) on the web, deployable to Render Static Sites.

## Features

### Cross-Platform Compatibility
- ✅ Works on web browsers (desktop and mobile)
- ✅ Works on Android (APK)
- ✅ Data export/import between platforms
- ✅ Responsive design for all screen sizes

### Storage
- **Web**: Uses `SharedPreferences` (browser local storage)
- **Mobile**: Uses `Hive` (local database)
- **Both**: Support JSON export/import for data portability

### PWA Features
- Installable on mobile devices (Add to Home Screen)
- Offline capable (after first load)
- App-like experience
- No app store required

## Deploying to Render

### Prerequisites
1. GitHub repository connected to Render
2. Render account (free Hobby plan is sufficient)

### Setup Steps

1. **Connect Repository to Render**:
   - Go to [Render Dashboard](https://dashboard.render.com/)
   - Click "New +" → "Static Site"
   - Connect your GitHub repository
   - Select the `everdell_tracker` repository

2. **Configure Build Settings**:
   Render will automatically detect the `render.yaml` file with these settings:
   - **Build Command**: `flutter/bin/flutter build web --release --web-renderer canvaskit`
   - **Publish Directory**: `build/web`
   - **Flutter Version**: 3.38.7

3. **Deploy**:
   - Click "Create Static Site"
   - Render will automatically build and deploy
   - First build takes ~15-20 minutes
   - Subsequent builds are faster (~10 minutes)

4. **Custom Domain** (Optional):
   - Go to Settings → Custom Domain
   - Add your domain (e.g., `everdell.yourdomain.com`)
   - Follow DNS instructions

### Auto-Deploy
- Automatic deployment on every push to `main` branch
- No manual intervention required

## Using the Web App

### Accessing the App
- **Render URL**: `https://everdell-tracker-web.onrender.com` (or your custom domain)
- Works on any device with a modern browser

### Installing as PWA

**On Mobile (iOS/Android)**:
1. Open the web app in Safari/Chrome
2. Tap the Share button
3. Select "Add to Home Screen"
4. App appears as a native icon on your home screen

**On Desktop (Chrome/Edge)**:
1. Open the web app
2. Click the install icon in the address bar (⊕)
3. Click "Install"
4. App opens in its own window

### Data Portability

**Export Data**:
1. Open Settings
2. Tap "Export Data"
3. On web: Downloads JSON file
4. On mobile: Share JSON via any app

**Import Data**:
1. Open Settings
2. Tap "Import Data"
3. On web: Select JSON file
4. On mobile: Share JSON file to app

## Architecture

### Platform Detection
```dart
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // Use web-specific code
} else {
  // Use mobile-specific code
}
```

### Storage Services
- `PlatformStorageService`: Automatically chooses correct storage
- `WebStorageService`: SharedPreferences for web
- `StorageService`: Hive for mobile

### File Structure
```
lib/
├── services/
│   ├── platform_storage_service.dart  # Platform router
│   ├── web_storage_service.dart       # Web implementation
│   ├── storage_service.dart           # Mobile implementation
│   ├── data_export_service.dart       # Export/import logic
│   ├── data_export_web.dart           # Web file download
│   └── data_export_stub.dart          # Mobile stub
web/
├── index.html                          # PWA entry point
├── manifest.json                       # PWA configuration
└── icons/                              # PWA icons
```

## Render vs Other Options

### Why Render?
- ✅ Free tier (Hobby plan)
- ✅ Automatic HTTPS
- ✅ CDN included
- ✅ GitHub integration
- ✅ No credit card required for free tier
- ✅ Easy custom domains

### Alternatives
- **Netlify**: Similar features, also has free tier
- **Vercel**: Good for Next.js, also supports static sites
- **GitHub Pages**: Free but requires custom build workflow
- **Firebase Hosting**: Good but requires Google account setup

## Costs

### Free Tier (Hobby)
- **Render**: 100GB bandwidth/month
- **Storage**: No limit for static sites
- **Custom Domain**: Included
- **HTTPS**: Included

### Paid Tier
Only needed if you exceed 100GB bandwidth/month:
- **Starter**: $7/month
- Includes 100GB bandwidth
- $0.10/GB beyond that

## Multi-Tenant Setup

Your Render account can host multiple apps:
- Each app is a separate "Static Site" service
- They don't interfere with each other
- Free tier applies per account (not per site)
- You can have multiple static sites on the free tier

## Testing Locally

### Web Build
```powershell
# Build for web
flutter build web --release

# Serve locally
# Install 'dhttpd' package first: dart pub global activate dhttpd
dhttpd --path build/web
```

Then open `http://localhost:8080` in your browser.

### Testing PWA Features
1. Build for web (release mode)
2. Serve with HTTPS (required for PWA)
3. Test on actual mobile device
4. Use Chrome DevTools → Application → Manifest

## Troubleshooting

### Build Fails on Render
- Check Flutter version matches (`3.38.7`)
- Verify `render.yaml` is in repository root
- Check build logs for specific errors

### PWA Not Installing
- Requires HTTPS (works on Render by default)
- Check `manifest.json` is valid
- Verify icons exist in `web/icons/`

### Data Not Persisting
- Check browser allows local storage
- Try in non-incognito mode
- Check browser console for errors

### Large Initial Load
- First load downloads all assets (~80MB)
- Subsequent loads use browser cache
- Consider reducing image sizes if needed

## Future Enhancements

### Potential Improvements
- Add service worker for better offline support
- Implement background sync for data
- Add push notifications (web)
- Optimize asset loading
- Add analytics (optional)

### Database Integration (Optional)
If you later want cloud sync:
1. Add a Render PostgreSQL database
2. Create a backend API (Node.js/Python)
3. Implement sync logic
4. This would require the paid tier ($7/month + database)

## Support

### Resources
- [Flutter Web](https://docs.flutter.dev/deployment/web)
- [Render Static Sites](https://render.com/docs/static-sites)
- [PWA Documentation](https://web.dev/progressive-web-apps/)

### Common Questions

**Q: Can Android users use the web version instead of APK?**
A: Yes! They can visit the URL and install as PWA.

**Q: Will web and Android share data automatically?**
A: No, but you can export/import JSON to transfer data.

**Q: Does this affect my other Render app?**
A: No, each service is isolated. They won't interfere.

**Q: Can I add a database later?**
A: Yes, but it requires upgrading to a paid plan.

**Q: Will the web version work offline?**
A: After the first load, yes (with service workers configured).
