# Card Carousel / Fan Interface

## Overview

Implemented a beautiful carousel/fan card selection interface as an alternative to the grid view.

## Features

### Visual Effects

1. **Fan/Stack Layout**
   - Center card is largest and fully visible
   - Adjacent cards are scaled down (80-50% size)
   - Cards rotate slightly for fan effect (±15°)
   - Vertical arc creates depth (cards rise/fall from center)
   - Smooth opacity fade for distant cards

2. **Smooth Animations**
   - PageView with 0.35 viewport fraction (shows parts of adjacent cards)
   - Animated transformations with perspective
   - Smooth transitions when swiping between cards
   - Auto-scroll to center when tapping side cards

3. **Interaction**
   - **Swipe left/right** to browse through cards
   - **Tap center card** to select/deselect
   - **Tap side card** to scroll it to center first
   - Selection indicator (green checkmark) on selected cards

### UI Components

1. **View Toggle**
   - Icon button in top right (carousel  ⇄ grid)
   - Preserves selection when switching views
   - Remembers last used view

2. **Color Filters** (Carousel Mode)
   - Filter chips at top: All, Production, Governance, Destination, Traveller, Prosperity
   - Color-coded chips matching card types
   - Instant filtering without losing selection

3. **Card Display**
   - Shows card image (or placeholder for missing images)
   - Card name and base points
   - Card type indicator
   - Color-coded footer matching card category
   - Border highlight when selected (green)

4. **Common Cards Dialog**
   - Tap common card in carousel → dialog appears
   - Shows current count
   - Buttons to add/remove
   - Grid view still has +/- buttons directly on cards

## Technical Implementation

### Files Created

1. `lib/widgets/card_carousel_widget.dart`
   - Reusable carousel widget
   - PageView-based with transform animations
   - Calculates scale, rotation, offset based on position
   - Handles tap gestures and scrolling

### Files Modified

1. `lib/screens/card_selection_screen_example.dart`
   - Added `_useCarouselView` state flag
   - Added `_selectedColorFilter` for carousel filtering
   - Split display into `_buildCarouselView()` and `_buildGridView()`
   - Added view toggle button
   - Added color filter chips for carousel
   - Added common card selection dialog

## Usage

### For Users

1. **Switch Views**
   - Tap the carousel/grid icon in top right

2. **Browse Cards (Carousel)**
   - Swipe left/right to browse
   - Or tap a side card to bring it to center

3. **Select Cards (Carousel)**
   - Tap center card to select unique cards
   - Common cards show a dialog to choose quantity

4. **Filter by Type (Carousel)**
   - Tap a color chip to show only that type
   - Tap "All" to show all cards again

### Animation Math

```dart
// Distance from center (0 = center, 1 = one card away)
difference = (index - currentPage).abs()

// Scale: 100% at center, down to 50% at edges
scale = 1.0 - (difference × 0.2).clamp(0.0, 0.5)

// Rotation: ±15° fan effect
rotation = (index - currentPage) × 0.15

// Vertical offset: arc effect (0-60px)
verticalOffset = (difference × 30).clamp(0.0, 60.0)

// Opacity: 100% at center, down to 30% at edges  
opacity = (1.0 - (difference × 0.3)).clamp(0.3, 1.0)
```

## Future Enhancements

Potential improvements:
- [ ] 3D flip animation when selecting
- [ ] Haptic feedback on selection
- [ ] Custom card order (e.g., sort by points, alphabetically)
- [ ] Favorites/pinning cards
- [ ] Zoom on center card for details
- [ ] Gesture to quick-select (long press?)
- [ ] Background blur effect for depth

## Testing

To test the carousel:
1. Open card selection screen
2. Toggle to carousel view (icon in top right)
3. Swipe through cards
4. Try tapping center vs side cards
5. Test color filters
6. Select multiple common cards
7. Switch back to grid view - selection persists

---

**Carousel is now live!** 🎉 Enjoy the beautiful card browsing experience!
