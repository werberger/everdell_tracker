# Everdell Card System - Implementation Summary

## Files Created

### 1. **Card Model** (`lib/models/everdell_card.dart`)
Defines the complete card data structure including:
- `EverdellCard` - Main card class with all properties
- `ConditionalScoring` - Handles special scoring rules
- Enums for `CardType`, `CardColor`, `CardRarity`, `ConditionalScoringType`

**Key Features:**
- Hive serialization support (typeId: 10, 11)
- JSON import/export
- Automatic bonus point calculation based on scoring type

### 2. **Card Data** (`assets/cards_data.json`)
Complete JSON database containing all **57 cards**:
- **48 base game cards** (all with webp images)
- **6 Extra! Extra! cards** (placeholders - no images yet)
- **3 Rugwort cards** (placeholders - no images yet)

### 3. **Card Service** (`lib/services/card_service.dart`)
Utility service for card operations:
- Load cards from JSON
- Filter by module, type, color
- Group cards by color
- Search functionality
- **Calculate total points** including conditional scoring

### 4. **Card Display Widget** (`lib/widgets/card_display_widget.dart`)
Reusable widget for displaying cards:
- Shows actual card image if available
- Shows attractive placeholder for cards without images
- Supports selection state
- Configurable size

## Card Categories by Conditional Scoring

### Simple Scoring (No Conditions)
Most cards fall into this category - just their base point value.

### Conditional Scoring Types

#### 1. **Resource Count** (1 card)
- **Architect**: 2 base + 1 VP per pebble/resin (max 6 bonus)

#### 2. **Card Type Count** (6 cards)
- **Castle**: 4 base + 1 VP per common construction
- **Ever Tree**: 5 base + 1 VP per prosperity card
- **Palace**: 4 base + 1 VP per unique construction
- **School**: 2 base + 1 VP per common critter
- **Theatre**: 3 base + 1 VP per unique critter
- **Scurrbble Champion**: 2 base + 2 VP per other Scurrbble Champion

#### 3. **Card Pairing** (2 cards)
- **Wife**: 2 base + 3 VP if Husband in city
- **Scurrbble Champion**: Pairs with itself

#### 4. **Token Placement** (3 cards)
- **Chapel**: 2 base + tokens placed during game
- **Clock Tower**: 0 base + starts with 3 tokens
- **Shepherd**: 1 base + 1 VP per token on Chapel

#### 5. **Event Count** (1 card)
- **King**: 4 base + 1 VP per basic event + 2 VP per special event

## Cards With Images (48)

All base game cards have webp images located in `assets/images/cards/`:

**Constructions (24):**
castle, cemetery, chapel, clock_tower, courthouse, crane, dungeon, ever_tree, fairgrounds, farm, general_store, inn, lookout, mine, monastery, palace, post_office, resin_refinery, ruins, school, storehouse, theatre, twig_barge, university

**Critters (24):**
architect, bard, barge_toad, chip_sweep, doctor, fool, historian, husband, innkeeper, judge, king, miner_mole, monk, peddler, postal_pigeon, queen, ranger, shepherd, shopkeeper, teacher, undertaker, wanderer, wife, woodcarver

## Cards Without Images (9 - Placeholders)

**Extra! Extra! Module (6):**
- carnival, gazette, scurrbble_stadium, juggler, scurrbble_champion, town_crier

**Rugwort Module (3):**
- rugwort_robber, rugwort_rowdy, rugwort_ruler

## How to Use

### Loading Cards

```dart
import 'package:everdell_tracker/services/card_service.dart';

// Load all cards
final allCards = await CardService.loadCards();

// Load base game only
final baseCards = await CardService.getBaseGameCards();

// Get cards grouped by color
final cardsByColor = await CardService.getCardsGroupedByColor(module: 'base');

// Search cards
final results = await CardService.searchCards('king');
```

### Displaying Cards

```dart
import 'package:everdell_tracker/widgets/card_display_widget.dart';

CardDisplayWidget(
  card: myCard,
  isSelected: selectedCardIds.contains(myCard.id),
  onTap: () => toggleCardSelection(myCard),
  width: 120,
  height: 180,
)
```

### Calculating Points

```dart
// Basic calculation with automatic conditional scoring
final totalPoints = CardService.calculateTotalPoints(
  selectedCards,
  tokenCounts: {
    'clock_tower': 2,  // 2 tokens remaining
    'chapel': 1,        // 1 token placed
  },
  resourceCounts: {
    'pebbles_resin': 4, // For Architect
  },
  basicEvents: 2,
  specialEvents: 1,
);
```

## Next Steps for Implementation

### 1. Generate Hive Adapters
Run the build_runner to generate the `.g.dart` files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Create Card Selection Screen
Build a screen with:
- Sectioned carousel/grid by card type
- Search functionality
- Real-time score calculation
- Conditional scoring prompts when needed

### 3. Update Player Score Model
Add field to store selected card IDs:

```dart
@HiveField(30)
final List<String>? selectedCardIds;
```

### 4. Integrate with Existing Scoring
Modify `score_calculator.dart` to use card-based scoring when available.

## Data Accuracy

All base game card data has been verified against `assets/card_details.txt`:
- ✅ Card names
- ✅ Base points
- ✅ Card types (construction/critter)
- ✅ Card colors
- ✅ Rarities
- ✅ Conditional scoring rules
- ✅ Paired cards

## Image Placeholder Design

Cards without images show:
- Color-coded background based on card color
- Icon (house for constructions, paw for critters)
- Card name (centered, max 3 lines)
- Base point value
- Card color name

This ensures a consistent experience whether images exist or not.

## Modules Supported

- **base**: Everdell base game (48 cards with images)
- **extra**: Extra! Extra! expansion (6 cards, placeholders)
- **rugwort**: Rugwort promo cards (3 cards, placeholders)

You can easily add more modules (Pearlbrook, Spirecrest, etc.) by adding them to the JSON and updating the module filter.
