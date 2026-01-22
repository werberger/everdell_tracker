# Setup & Next Steps

## ✅ What's Been Created

1. **Card Data Model** - Complete Dart classes for cards with conditional scoring
2. **JSON Database** - All 57 cards (48 with images, 9 placeholders)
3. **Card Service** - Loading, filtering, and scoring logic
4. **Card Display Widget** - Shows cards with images or attractive placeholders
5. **Example Screen** - Working card selection interface with real-time scoring

## 🚀 Next Steps to Get This Running

### Step 1: Generate Hive Adapters

The `EverdellCard` model uses Hive for storage. You need to generate the adapter files:

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

This will create:
- `lib/models/everdell_card.g.dart`

### Step 2: Register Hive Adapters

In your `main.dart`, register the new adapters before opening Hive boxes:

```dart
import 'package:everdell_tracker/models/everdell_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Register existing adapters
  Hive.registerAdapter(PlayerScoreAdapter());
  Hive.registerAdapter(GameAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(ExpansionAdapter());
  
  // Register NEW card adapters
  Hive.registerAdapter(EverdellCardAdapter());      // typeId: 10
  Hive.registerAdapter(ConditionalScoringAdapter()); // typeId: 11
  
  // ... rest of your initialization
}
```

### Step 3: Update PlayerScore Model (Optional for MVP)

To store selected cards with player scores, add to `player_score.dart`:

```dart
@HiveField(30)
final List<String>? selectedCardIds;

@HiveField(31)
final Map<String, int>? cardTokenCounts;

@HiveField(32)
final Map<String, int>? cardResourceCounts;
```

Then regenerate:
```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Add New Scoring Method to Settings

In `app_settings.dart`, add a new enum value for card entry method:

```dart
enum CardEntryMethod {
  simple,
  byType,
  byColor,
  visual,  // NEW: Card selection method
}
```

### Step 5: Integrate Card Selection Screen

Add a route to your card selection screen. For example, in your new game flow:

```dart
// In new_game_screen.dart or wherever you handle scoring
if (settings.cardEntryMethod == CardEntryMethod.visual) {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CardSelectionScreenExample(),
    ),
  );
  
  if (result != null) {
    // result contains selectedCardIds, score, etc.
    // Save to player score
  }
}
```

## 📝 Testing the Card System

### Quick Test in Your App

Add a temporary button somewhere to test the card screen:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CardSelectionScreenExample(),
      ),
    );
  },
  child: const Text('Test Card Selection'),
)
```

### Verify Cards Load

```dart
// In any screen, test loading
final cards = await CardService.loadCards();
print('Loaded ${cards.length} cards');  // Should print 57

final baseCards = await CardService.getBaseGameCards();
print('Base game has ${baseCards.length} cards');  // Should print 48
```

## 🎨 Enhancing the UI (Future)

### Add Carousel/Fan Effect

For the fan/carousel effect you wanted, you can:

1. **Install carousel package:**
   ```yaml
   dependencies:
     carousel_slider: ^4.2.1
   ```

2. **Replace ListView.builder with CarouselSlider:**
   ```dart
   CarouselSlider.builder(
     itemCount: cardsInSection.length,
     options: CarouselOptions(
       height: 200,
       viewportFraction: 0.35,
       enlargeCenterPage: true,
       enlargeStrategy: CenterPageEnlargeStrategy.scale,
     ),
     itemBuilder: (context, index, realIndex) {
       return CardDisplayWidget(...);
     },
   )
   ```

3. **Add transform for fan effect:**
   ```dart
   Transform(
     transform: Matrix4.identity()
       ..setEntry(3, 2, 0.001)
       ..rotateY(index * 0.1 - 0.5), // Creates fan effect
     child: CardDisplayWidget(...),
   )
   ```

## 🔧 Troubleshooting

### Build Runner Issues

If you get conflicts:
```powershell
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Image Loading Issues

If card images don't show:
1. Verify `pubspec.yaml` has `assets/images/cards/`
2. Run `flutter clean`
3. Run `flutter pub get`
4. Rebuild app

### Hive Type ID Conflicts

If you get "type ID already registered":
- EverdellCard uses typeId: 10
- ConditionalScoring uses typeId: 11
- Make sure these don't conflict with existing adapters

## 📊 Current Card Statistics

- **Total Cards**: 57
- **Base Game**: 48 (all with images ✓)
- **Extra! Extra!**: 6 (placeholders)
- **Rugwort**: 3 (placeholders)

### Scoring Breakdown:
- Simple scoring: 44 cards
- Conditional scoring: 13 cards
  - Resource-based: 1 (Architect)
  - Card count: 6 (Palace, Castle, etc.)
  - Pairing: 2 (Wife, Scurrble Champion)
  - Token placement: 3 (Clock Tower, Chapel, Shepherd)
  - Event count: 1 (King)

## 🎯 MVP Features Implemented

✅ Load all 48 base game cards
✅ Display cards with images
✅ Placeholder cards for non-image cards
✅ Card selection with 15-card limit
✅ Real-time score calculation
✅ Automatic conditional scoring (pairing, card counting)
✅ Manual prompts for conditional scoring (resources, tokens, events)
✅ Search functionality
✅ Grouped by card type/color

## 📅 Future Enhancements

- [ ] Animated carousel with fan effect
- [ ] Save selected cards to player scores
- [ ] Export/import card selections
- [ ] Add expansion cards (Pearlbrook, Spirecrest, etc.)
- [ ] Visual event selection
- [ ] Journey point selection
- [ ] Settings toggle for real-time vs end scoring

---

**Ready to test?** Run step 1 first (build_runner), then add a test button and try it out!
