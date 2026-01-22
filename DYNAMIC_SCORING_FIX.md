# Dynamic Scoring Fix

## Problem

The scoring system was storing a **static score** from the card selection screen, which meant:
- Changing events/resources on the new game screen didn't update card bonuses
- King bonus wasn't recalculated when events changed
- Architect bonus wasn't recalculated when resources changed
- Deselecting cards left incorrect scores

## Solution

Implemented **fully dynamic scoring** that recalculates in real-time:

### How It Works Now

1. **visualCardScore** = Base card points + static bonuses (card types, pairing, etc.)
   - This is calculated ONCE when cards are selected
   - Does NOT include King or Architect bonuses

2. **Dynamic calculation** happens every time on new game screen:
   ```
   Total = visualCardScore 
         + Point Tokens
         + (Basic Events × 3)
         + Special Events Points
         + Journey Points
         + King Bonus (if King selected)
         + Architect Bonus (if Architect selected)
   ```

3. **King Bonus** = (Basic Events × 1) + (Special Events Count × 2)
   - Recalculates when you change event counts

4. **Architect Bonus** = min(Pebbles + Resin, 6)
   - Recalculates when you change leftover resources

## What This Fixes

### Scenario 1 - King Issues
- ✅ King selected → 4 points (base)
- ✅ Add 1 special event count → +2 points (King bonus)
- ✅ Add 1 special event points → +1 point
- ✅ Add 1 basic event count → +3 points (event) + 1 point (King bonus)
- ✅ Deselect King → Removes 4 base points, keeps event points
- ✅ Remove all events → 0 points (correct)

### Scenario 2 - Architect Issues
- ✅ Architect selected → 2 points (base)
- ✅ Add 2 resin, 1 pebble → +3 points (Architect bonus)
- ✅ Bonus recalculates IMMEDIATELY when resources change
- ✅ No need to reselect in card selection

## Files Changed

1. **lib/screens/new_game_screen.dart**
   - Added `_calculateVisualScoreSync()` method
   - Dynamically calculates King and Architect bonuses
   - Removes static score calculation

2. **lib/screens/card_selection_screen_example.dart**
   - Added `initialSpecialEventsCount` parameter
   - Tracks special events count separately
   - Returns special events count in result

3. **lib/widgets/player_input_card.dart**
   - Already updated with special events count field

## Testing

```powershell
flutter run -d windows
```

### Test Scenarios

**King:**
1. Select King → Should show 4 points
2. Change Basic Events to 2 → Should add 6 (2×3) + 2 (King bonus) = +8
3. Change Special Events Count to 1 → Should add 2 (King bonus)
4. Deselect King → Should remove 4 + bonuses, keep event points

**Architect:**
1. Select Architect → Should show 2 points
2. Change Pebbles to 2, Resin to 3 → Should add 5 (capped at 6)
3. Change to 4 pebbles, 4 resin → Should add 6 (max)
4. Deselect Architect → Should remove 2 + bonus

**Mixed:**
1. Select King + Architect + other cards
2. Change events and resources dynamically
3. All bonuses should update in real-time

---

**Score now updates dynamically as you type!** 🎉
