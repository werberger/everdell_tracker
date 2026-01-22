# Scoring System Fixes

## ✅ All Four Issues Fixed

### 1. Basic Events Calculation and Labels
**Problem:** Basic events were calculating as count x1 instead of count x3, and labels didn't clarify the difference between count and points.

**Fix:**
- Updated label to "Basic Events (count)" with helper text "x3 points each"
- Updated label to "Special Events (points)" with helper text "Total points"
- Fixed calculation: `basicEvents * 3` instead of `basicEvents * 1`
- Now matches the "basic input" mode behavior

**Files Changed:**
- `lib/widgets/player_input_card.dart` - Updated labels and helper text
- `lib/screens/new_game_screen.dart` - Fixed calculation from x1 to x3

---

### 2. Architect No Longer Prompts
**Problem:** Architect was prompting for pebbles/resin count even though these are entered on the scoring screen.

**Fix:**
- Card selection screen now accepts `leftoverPebbles`, `leftoverResin`, `leftoverBerries`, `leftoverWood` parameters
- Automatically calculates `pebbles_resin = leftoverPebbles + leftoverResin` for Architect
- Removed the resource count dialog prompt for Architect
- Uses values from new game screen input fields

**How It Works:**
1. User enters leftover resources on new game screen
2. These values are passed to card selection screen
3. Architect automatically uses these for calculation
4. No dialog popup needed

**Files Changed:**
- `lib/screens/card_selection_screen_example.dart` - Added resource parameters, removed dialog call
- `lib/screens/new_game_screen.dart` - Pass leftover resources to card selection

---

### 3. King Uses Event Counts + Special Events Count Field Added
**Problem:** King was prompting for events, and there was no way to track special events count separately from special events points.

**Fix:**
- Added new field: **"Special Events (count)"**
- King now uses basic events count and special events count from new game screen
- Removed the event count dialog prompt for King
- Special events now tracked as both:
  - **Count**: How many special events achieved (for King, Rugwort)
  - **Points**: Total points from special events

**New Field Layout:**
```
Basic Events (count)     x3 points each

Special Events (count)   |  Special Events (points)
[input field]           |  [input field]
```

**Files Changed:**
- `lib/screens/new_game_screen.dart` - Added `specialEventsCountController`
- `lib/widgets/player_input_card.dart` - Added special events count input field
- `lib/screens/card_selection_screen_example.dart` - Removed dialog call for King

---

### 4. Rugwort the Ruler Updated
**Problem:** Rugwort needs to count events from OTHER players, which is complex.

**Fix:**
- Updated Rugwort's conditional scoring type to `simple` with a note
- User must manually calculate and add points via "Point Tokens" field
- Note: "1 VP per event (basic or special) OTHER players achieved"

**Why Manual:**
Rugwort's ability requires knowing other players' event counts, which would need:
- Access to all players' data
- Cross-player calculations
- More complex scoring system

For now, users can:
1. After all players enter scores, calculate Rugwort bonus
2. Add the bonus to the "Point Tokens" field
3. Example: If other players achieved 8 total events, add 8 to Point Tokens

**Files Changed:**
- `assets/cards_data.json` - Updated Rugwort conditional scoring

---

## Testing

```powershell
flutter run -d windows
```

### Test Checklist

**Basic Events:**
- [ ] Enter 2 basic events → Should add 6 points (2 x 3)
- [ ] Label shows "(count)" and "x3 points each"

**Special Events:**
- [ ] Two separate fields now: count and points
- [ ] Enter count of 2 and points of 10 → Should add 10 points

**Architect:**
- [ ] Select Architect card
- [ ] Enter 3 pebbles, 2 resin on new game screen
- [ ] No dialog should pop up
- [ ] Architect should automatically get 5 bonus points (up to max 6)

**King:**
- [ ] Select King card
- [ ] Enter 2 basic events, 1 special event (count)
- [ ] No dialog should pop up
- [ ] King should get 1 point per basic event + 2 points per special event

**Rugwort:**
- [ ] Select Rugwort the Ruler
- [ ] Manually calculate other players' events
- [ ] Add that number to "Point Tokens" field

---

## New Scoring Flow

### When Using Card Selection Mode:

1. **Select Cards** - Click button, pick your cards
2. **Additional Scoring** section appears:
   - Point Tokens (if enabled)
   - Basic Events (count) - x3 points
   - Special Events (count) - for King calculation
   - Special Events (points) - raw points
   - Journey Points
3. **Leftover Resources:**
   - Berries, Resin, Pebbles, Wood
   - Used for Architect calculation automatically

4. **Calculated Total** updates in real-time

---

**All four issues resolved!** 🎉
