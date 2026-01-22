# ⚠️ Test Before Release - Quick Guide

## 🎯 Priority Tests

### 1. Card Image Sizing (MOST IMPORTANT)
**Problem**: Cards were getting cropped on sides  
**Fix**: Changed `BoxFit.cover` → `BoxFit.contain`

**Test**:
1. Open card selection (fan mode)
2. Browse through cards
3. ✅ **Check**: Full image visible (no side cropping)
4. Resize window smaller
5. ✅ **Check**: Cards scale down but maintain aspect ratio
6. ✅ **Check**: Entire image still visible

### 2. Button Consistency
**Problem**: Grid and carousel had different button layouts  
**Fix**: Both now have buttons at top

**Test**:
1. **Fan mode**: Add a common card (e.g., Farm)
   - ✅ Plus at top right
   - ✅ Count at top center
   - ✅ Minus at top left
2. **Grid mode**: Do the same
   - ✅ Same button positions
   - ✅ Matches fan layout exactly

### 3. No Overflow Error
**Problem**: Yellow/black overflow warning  
**Fix**: Wrapped carousel in Expanded

**Test**:
1. Switch to fan mode
2. ✅ **Check**: No overflow warning in console/screen

---

## 🚀 If All Tests Pass

### Test Locally
```powershell
flutter run -d windows
```
Complete the 3 priority tests above.

### Build Test APK (Optional)
```powershell
# Generate icons first
.\generate_all_icons.ps1

# Build one flavor to test
flutter build apk --release --flavor teacher
```
Test APK on phone before releasing all 4.

### When Ready
```powershell
git add .
git commit -m "Release v2.0.0: Visual card selection with carousel/fan interface"
git push
```

---

## 📱 What Gets Built

When you push, GitHub Actions will automatically build:

### 4 APKs (Different Icons)
1. `everdell-tracker-teacher-v2.0.0.apk` 🦔
2. `everdell-tracker-badger-v2.0.0.apk` 🦡
3. `everdell-tracker-evertree-v2.0.0.apk` 🌳
4. `everdell-tracker-squirrel-v2.0.0.apk` 🐿️

### 4 AABs (Play Store)
- Same 4 flavors as .aab files

**Build time**: ~10-15 minutes

---

## 🐛 If Something's Wrong

### Card images still cropped?
- Check `BoxFit.contain` is in carousel widget
- Verify `AspectRatio` is wrapping the card

### Buttons in wrong position?
- Check both carousel and grid layouts
- Should be identical (top left/center/right)

### Overflow still showing?
- Check carousel is wrapped in `Expanded`
- Check Column children structure

---

## ✅ Quick Checklist

- [ ] Card images show fully (no cropping)
- [ ] Cards maintain aspect ratio when resizing
- [ ] Buttons at top (both layouts)
- [ ] No overflow warnings
- [ ] "Your City" section works
- [ ] Score calculates correctly

**All good? Push and let GitHub build the APKs!** 🚀
