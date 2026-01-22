# GitHub Secrets Setup for Release Signing

## Overview

To enable automatic release signing in GitHub Actions, you need to add the keystore and passwords as GitHub Secrets.

## Required Secrets

You need to add 4 secrets to your GitHub repository:

1. **`KEYSTORE_BASE64`**: The base64-encoded keystore file
2. **`KEYSTORE_PASSWORD`**: `everdell2026`
3. **`KEY_ALIAS`**: `everdell-release`
4. **`KEY_PASSWORD`**: `everdell2026`

## Step-by-Step Instructions

### 1. Get the Base64 Keystore

The keystore has been encoded to base64 and saved in:
```
keystore-base64.txt
```

**Open this file and copy the entire contents** (it will be a very long string).

### 2. Add Secrets to GitHub

1. Go to your GitHub repository: `https://github.com/werberger/everdell_tracker`

2. Click **Settings** (top right, requires admin access)

3. In the left sidebar, click **Secrets and variables** → **Actions**

4. Click **New repository secret** and add each secret:

   **Secret 1: KEYSTORE_BASE64**
   - Name: `KEYSTORE_BASE64`
   - Value: Paste the entire contents of `keystore-base64.txt`
   - Click **Add secret**

   **Secret 2: KEYSTORE_PASSWORD**
   - Name: `KEYSTORE_PASSWORD`
   - Value: `everdell2026`
   - Click **Add secret**

   **Secret 3: KEY_ALIAS**
   - Name: `KEY_ALIAS`
   - Value: `everdell-release`
   - Click **Add secret**

   **Secret 4: KEY_PASSWORD**
   - Name: `KEY_PASSWORD`
   - Value: `everdell2026`
   - Click **Add secret**

### 3. Verify Secrets

After adding all 4 secrets, you should see them listed on the **Secrets** page:
- ✅ KEYSTORE_BASE64
- ✅ KEYSTORE_PASSWORD
- ✅ KEY_ALIAS
- ✅ KEY_PASSWORD

### 4. Test the Build

Push a commit to the `main` branch and GitHub Actions will:
1. Download and decode the keystore
2. Build APKs with release signing
3. Create a GitHub Release with 4 APKs

## Security Notes

### ⚠️ IMPORTANT
- **Never commit `keystore-base64.txt` to GitHub**
- The file is already in `.gitignore`
- Delete the file after adding the secret (or store it securely elsewhere)
- The actual keystore (`android/app/everdell-release-key.jks`) is also gitignored

### 🔒 Safe to Commit
The following files are already properly gitignored:
- ✅ `android/app/everdell-release-key.jks` (the keystore)
- ✅ `android/key.properties` (contains passwords)
- ✅ `keystore-base64.txt` (the base64 encoding)

### 📦 What Gets Committed
Only configuration files are committed:
- ✅ `android/app/build.gradle.kts` (build configuration)
- ✅ `.github/workflows/android-release.yml` (workflow)
- ✅ Documentation files

## Troubleshooting

### Build Fails with "keystore not found"
- Verify `KEYSTORE_BASE64` secret is set correctly
- Check the secret value doesn't have extra spaces or newlines

### Build Fails with "incorrect password"
- Verify `KEYSTORE_PASSWORD` is exactly: `everdell2026`
- Verify `KEY_PASSWORD` is exactly: `everdell2026`
- Check there are no extra spaces in the secret values

### Build Fails with "alias not found"
- Verify `KEY_ALIAS` is exactly: `everdell-release`

### APKs not signed with release key
- Check the GitHub Actions logs
- Look for the "Decode and setup keystore" step
- Verify it completes successfully

## Updating the Keystore

If you ever need to change the keystore:

1. Generate a new keystore (see `KEYSTORE_SETUP.md`)
2. Encode to base64:
   ```powershell
   $bytes = [System.IO.File]::ReadAllBytes("android\app\everdell-release-key.jks")
   $base64 = [System.Convert]::ToBase64String($bytes)
   $base64 | Out-File "keystore-base64.txt"
   ```
3. Update the `KEYSTORE_BASE64` secret in GitHub
4. Update passwords if changed

## After Setup

Once the secrets are configured:
- ✅ Every push to `main` builds release-signed APKs
- ✅ APKs can be updated in-place on user devices
- ✅ No data loss on updates
- ✅ Professional app distribution

## What Happens in CI/CD

When you push to `main`, GitHub Actions will:

1. Check out your code
2. Set up Flutter environment
3. Get dependencies
4. **Decode the keystore from base64**
5. **Create `key.properties` with passwords**
6. Run code generation
7. Generate app icons
8. **Build 4 APKs with release signing**
9. Create GitHub Release
10. Upload signed APKs

The keystore and properties files are created during build and discarded after.
They never appear in your repository.
