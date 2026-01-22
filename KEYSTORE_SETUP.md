# Android Release Keystore Setup

## What is a Release Keystore?

A release keystore is a cryptographic key used to sign your Android app. It ensures:

1. **App Updates Work**: Users can install new versions over old ones without uninstalling
2. **Data Preservation**: User data (games, scores, settings) is retained across updates
3. **App Identity**: Android recognizes all versions as the same app

## Current Setup

### Keystore Details
- **Location**: `android/app/everdell-release-key.jks`
- **Alias**: `everdell-release`
- **Validity**: 10,000 days (~27 years)
- **Algorithm**: RSA 2048-bit

### Passwords
- **Store Password**: `everdell2026`
- **Key Password**: `everdell2026`

> ⚠️ **IMPORTANT**: These files are gitignored and should NEVER be committed to GitHub!

## Files Created

1. **`android/app/everdell-release-key.jks`** - The keystore file
2. **`android/key.properties`** - Configuration file with passwords
3. **Updated `.gitignore`** - Prevents accidental commits
4. **Updated `android/app/build.gradle.kts`** - Configured to use the keystore

## How It Works

The build configuration automatically:
- Looks for `key.properties` in the `android/` folder
- If found, uses the release keystore for signing
- If not found, falls back to debug keys (for local development)

## GitHub Actions Setup

To enable release signing in GitHub Actions, you need to:

1. **Encode the keystore to base64**:
   ```powershell
   $bytes = [System.IO.File]::ReadAllBytes("android\app\everdell-release-key.jks")
   $base64 = [System.Convert]::ToBase64String($bytes)
   $base64 | Out-File "keystore-base64.txt"
   ```

2. **Add GitHub Secrets**:
   - Go to: GitHub → Settings → Secrets and variables → Actions
   - Add these secrets:
     - `KEYSTORE_BASE64`: Contents of `keystore-base64.txt`
     - `KEYSTORE_PASSWORD`: `everdell2026`
     - `KEY_ALIAS`: `everdell-release`
     - `KEY_PASSWORD`: `everdell2026`

3. **Update `.github/workflows/android-release.yml`**:
   Add these steps before building:
   ```yaml
   - name: Decode and setup keystore
     run: |
       echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/everdell-release-key.jks
       echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
       echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
       echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
       echo "storeFile=app/everdell-release-key.jks" >> android/key.properties
   ```

## ⚠️ CRITICAL: Backup Your Keystore

**YOU MUST BACKUP THE KEYSTORE FILE!**

If you lose `everdell-release-key.jks`:
- You cannot update the app
- Users must uninstall and reinstall (losing all data)
- You'll need to use a new package name

**Backup locations**:
1. Secure cloud storage (Google Drive, OneDrive, etc.)
2. Password manager (1Password, LastPass, etc.)
3. External hard drive
4. USB drive in a safe place

## Testing the Setup

To verify the release signing works:

```powershell
# Build a release APK
flutter build apk --release --flavor teacher

# Check the signature
&"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -printcert -jarfile build\app\outputs\flutter-apk\app-teacher-release.apk
```

You should see:
- Owner: CN=Everdell Tracker
- Issuer: CN=Everdell Tracker

## For Future Developers

If someone else needs to build the app:
1. Get the `everdell-release-key.jks` file from the original developer
2. Get the `key.properties` file or create it with the passwords
3. Place both in the correct locations
4. Build normally with `flutter build apk --release`

## Security Notes

- Never commit the keystore or key.properties to version control
- Never share the keystore publicly
- Keep backups in multiple secure locations
- Consider using a password manager for the passwords
- For production apps, use stronger passwords than the example ones

## Transitioning from Debug to Release Keys

**Current v2.1.0 users will need to uninstall and reinstall once** to switch from debug keys to release keys. After that, all future updates will work seamlessly.

To minimize user impact:
1. Announce the one-time reinstall requirement
2. Remind users to export their game data first
3. Provide clear instructions for reinstalling
