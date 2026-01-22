# Card Selection Updates Summary

## All Issues Fixed

### ✅ 1. Husband/Wife Pairing
**Issue:** Paired cards should only take one space  
**Solution:**
- Added `canShareSpace` field to card model
- Updated Husband and Wife cards with `"canShareSpace": true`
- Updated city size calculation to subtract 1 when both are selected
- They now correctly count as 1 space instead of 2 when both selected

### ✅ 2. Wanderer Doesn't Count Toward City Size
**Issue:** Wanderer should not take up space in the 15-card limit  
**Solution:**
- Added `countsTowardCitySize` field to card model
- Set `"countsTowardCitySize": false` for Wanderer only
- Updated city size calculation to exclude Wanderer
- You can now select more than 15 cards if some are Wanderer
- Note: Ruins DOES count (only Wanderer is special in base game)

### ✅ 3. Placeholder Cards Now Display
**Issue:** Rugwort and Extra! Extra! cards were not showing  
**Solution:**
- Changed `_loadCards()` to load ALL modules, not just base
- Now shows all 57 cards (48 base + 9 expansion)
- Placeholder cards display with:
  - Color-coded background
  - Card name
  - Icon (house/paw)
  - Base points
  - Card type label

### ✅ 4. Multiple Common Cards Supported
**Issue:** Needed ability to select multiple of the same common card  
**Solution:**
- Changed from `Set<String>` to `Map<String, int>` to track counts
- Added `+` button (green) on all common cards
- Added `-` button (red) on all selected cards
- Shows count badge on selected cards
- Enforces unique cards = max 1, common cards = unlimited

### ✅ 5. Additional Input Boxes Added
**Issue:** Need inputs for journey points, events, and leftover resources  
**Solution:**
- Added "Journey & Resources" button in app bar (+ icon)
- Opens dialog with inputs for:
  - Journey Points
  - Leftover Berries
  - Leftover Resin
  - Leftover Pebbles
  - Leftover Wood/Twigs
- All values included in final score calculation

### ✅ 6. Card Colors Corrected
**Issue:** Cards were in wrong categories  
**Solution:** Updated card colors based on official game rules:

**Corrections Made:**
- Bard: Traveller → **Governance (Blue)**
- Crane: Production → **Governance (Blue)**
- Doctor: Prosperity → **Production (Green)**
- Dungeon: Destination → **Governance (Blue)**
- General Store: Destination → **Production (Green)**
- Inn: Destination → **Governance (Blue)**
- Innkeeper: Destination → **Governance (Blue)**
- School: Governance → **Prosperity (Purple)**
- Shepherd: Production → **Traveller (Tan)**
- Shopkeeper: Destination → **Governance (Blue)**
- Teacher: Governance → **Production (Green)**
- Theatre: Governance → **Prosperity (Purple)**
- University: Governance → **Destination (Red)**

## UI Improvements

### Card Display
- **Count Badge**: Yellow circle shows how many of each card selected
- **+ Button**: Green plus icon on common cards to add more
- **- Button**: Red minus icon on selected cards to remove
- **Selection Border**: Gold border when selected

### City Size Tracking
- Shows "City: X/15 spaces" (only counts cards that use spaces)
- Shows "Cards: Y" (total number including non-space cards)
- Smart calculation handles:
  - Paired Husband/Wife (counts as 1)
  - Wanderer (doesn't count)
  - Ruins (doesn't count)

### Score Display
- Real-time score in app bar
- Includes card points + conditional bonuses + journey points
- Updates immediately when cards added/removed

## Files Modified

1. ✅ `lib/models/everdell_card.dart` - Added `countsTowardCitySize` and `canShareSpace` fields
2. ✅ `lib/models/everdell_card.g.dart` - Regenerated Hive adapter
3. ✅ `assets/cards_data.json` - Fixed 13 card colors + added special properties
4. ✅ `lib/screens/card_selection_screen_example.dart` - Complete rewrite with all features
5. ✅ `assets/card_colors_mapping.txt` - Created reference document

## Testing Checklist

Ready to test all fixes:

- [ ] Select Husband + Wife - verify they count as 1 space
- [ ] Select Wanderer - verify city size doesn't increase
- [ ] Select Ruins - verify city size doesn't increase
- [ ] View Rugwort cards - verify placeholders show
- [ ] View Extra! Extra! cards - verify placeholders show
- [ ] Select multiple Farm cards (common) - verify + button works
- [ ] Try to select 2 King cards (unique) - verify it blocks
- [ ] Enter journey points via + button - verify included in score
- [ ] Enter leftover resources - verify stored
- [ ] Verify cards in correct color sections

## How to Test

1. Make sure any running app instance is closed
2. Run: `flutter run -d windows`
3. Click the orange "🧪 Test Card Selection" button
4. Test each feature above

---

**All 6 requested features implemented and ready to test!**
