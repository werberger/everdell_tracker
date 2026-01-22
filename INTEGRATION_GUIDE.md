# Card Selection Integration Guide

## ✅ Completed Setup Steps

All setup steps from `SETUP_NEXT_STEPS.md` have been completed:

1. ✅ **Hive Adapters Generated** - `everdell_card.g.dart` created
2. ✅ **Adapters Registered** - `storage_service.dart` now registers `EverdellCardAdapter` and `ConditionalScoringAdapter`
3. ✅ **PlayerScore Updated** - Added fields for card selection data:
   - `selectedCardIds` (List<String>) - IDs of selected cards
   - `cardTokenCounts` (Map<String, int>) - Token counts for Clock Tower, Chapel, etc.
   - `cardResourceCounts` (Map<String, int>) - Resource counts for Architect
4. ✅ **CardEntryMethod Updated** - Added `visual` option to the enum
5. ✅ **Helper Utilities Created** - `card_selection_helper.dart` for easy integration

## How to Integrate Card Selection

### Option 1: Quick Test (Recommended First Step)

Add a test button anywhere in your app to try the card selection screen:

```dart
// In any screen (e.g., home_screen.dart or settings_screen.dart)
import 'package:everdell_tracker/screens/card_selection_screen_example.dart';

// Add this button somewhere
ElevatedButton(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CardSelectionScreenExample(),
      ),
    );
    
    if (result != null) {
      print('Selected ${result['selectedCardIds'].length} cards');
      print('Total score: ${result['score']}');
    }
  },
  child: const Text('Test Card Selection'),
)
```

### Option 2: Integrate with New Game Flow

#### Step 1: Update your score entry screen

Find where you currently handle score entry (likely in a screen like `score_entry_screen.dart` or similar). Add a check for the visual card entry method:

```dart
import 'package:provider/provider.dart';
import 'package:everdell_tracker/models/app_settings.dart';
import 'package:everdell_tracker/utils/card_selection_helper.dart';

// Inside your build method or score entry logic
final settings = Provider.of<SettingsProvider>(context).settings;

if (settings.cardEntryMethod == CardEntryMethod.visual) {
  // Use visual card selection
  final result = await CardSelectionHelper.selectCards(context);
  
  if (result != null) {
    // Create player score from selected cards
    final playerScore = CardSelectionHelper.createPlayerScoreFromCards(
      playerId: playerId,
      playerName: playerName,
      selectedCardIds: result['selectedCardIds'],
      totalScore: result['score'],
      tiebreakerResources: 0, // Calculate from leftover resources if needed
      isWinner: false, // Determine later
      tokenCounts: result['tokenCounts'],
      resourceCounts: result['resourceCounts'],
      basicEvents: result['basicEvents'],
      specialEvents: result['specialEvents'],
      journeyPoints: journeyPoints, // Get from separate input if needed
    );
    
    // Save the player score
    // ... your existing save logic
  }
} else {
  // Use existing manual entry form
  // ... your existing logic
}
```

#### Step 2: Add a setting toggle for card entry method

In your settings screen, add an option to choose the card entry method:

```dart
// In settings_screen.dart or similar
import 'package:everdell_tracker/models/app_settings.dart';

// Add this to your settings UI
ListTile(
  title: const Text('Card Entry Method'),
  subtitle: Text(_getCardEntryMethodName(settings.cardEntryMethod)),
  trailing: const Icon(Icons.arrow_forward_ios),
  onTap: () async {
    final selected = await showDialog<CardEntryMethod>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Card Entry Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CardEntryMethod.values.map((method) {
            return RadioListTile<CardEntryMethod>(
              title: Text(_getCardEntryMethodName(method)),
              subtitle: Text(_getCardEntryMethodDescription(method)),
              value: method,
              groupValue: settings.cardEntryMethod,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
      ),
    );
    
    if (selected != null) {
      // Update settings
      final newSettings = settings.copyWith(
        cardEntryMethodIndex: selected.index,
      );
      await Provider.of<SettingsProvider>(context, listen: false)
          .updateSettings(newSettings);
    }
  },
)

// Helper methods
String _getCardEntryMethodName(CardEntryMethod method) {
  switch (method) {
    case CardEntryMethod.simple:
      return 'Simple';
    case CardEntryMethod.byType:
      return 'By Type';
    case CardEntryMethod.byColor:
      return 'By Color';
    case CardEntryMethod.visual:
      return 'Visual Selection';
  }
}

String _getCardEntryMethodDescription(CardEntryMethod method) {
  switch (method) {
    case CardEntryMethod.simple:
      return 'Enter total card points';
    case CardEntryMethod.byType:
      return 'Enter by construction/critter';
    case CardEntryMethod.byColor:
      return 'Enter by card color';
    case CardEntryMethod.visual:
      return 'Select cards visually';
  }
}
```

### Option 3: Display Card Selection in Game Details

When viewing a saved game, show which cards were selected:

```dart
import 'package:everdell_tracker/utils/card_selection_helper.dart';

// In your game detail view
FutureBuilder<String>(
  future: CardSelectionHelper.getCardSelectionSummary(playerScore),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text(snapshot.data!);
    }
    return const Text('Loading...');
  },
)

// Or show detailed card breakdown
if (CardSelectionHelper.isVisualCardSelection(playerScore)) {
  FutureBuilder<List<String>>(
    future: CardSelectionHelper.getCardNames(
      playerScore.selectedCardIds!,
    ),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return Wrap(
          spacing: 4,
          children: snapshot.data!.map((name) => Chip(
            label: Text(name),
          )).toList(),
        );
      }
      return const CircularProgressIndicator();
    },
  )
}
```

## Player Stats Use Cases (Future)

With the card selection data now stored in PlayerScore, you can build powerful analytics:

### 1. Most Played Cards

```dart
Future<Map<String, int>> getMostPlayedCards() async {
  final games = await StorageService.getAllGames();
  final cardCounts = <String, int>{};
  
  for (final game in games) {
    for (final score in game.playerScores) {
      if (score.selectedCardIds != null) {
        for (final cardId in score.selectedCardIds!) {
          cardCounts[cardId] = (cardCounts[cardId] ?? 0) + 1;
        }
      }
    }
  }
  
  return cardCounts;
}
```

### 2. Winning Card Combinations

```dart
Future<List<List<String>>> getWinningCardCombinations() async {
  final games = await StorageService.getAllGames();
  final winningCombos = <List<String>>[];
  
  for (final game in games) {
    final winners = game.playerScores.where((s) => s.isWinner);
    for (final winner in winners) {
      if (winner.selectedCardIds != null) {
        winningCombos.add(winner.selectedCardIds!);
      }
    }
  }
  
  return winningCombos;
}
```

### 3. Player Card Preferences

```dart
Future<Map<String, int>> getPlayerCardPreferences(String playerId) async {
  final games = await StorageService.getAllGames();
  final cardCounts = <String, int>{};
  
  for (final game in games) {
    final playerScores = game.playerScores
        .where((s) => s.playerId == playerId);
    
    for (final score in playerScores) {
      if (score.selectedCardIds != null) {
        for (final cardId in score.selectedCardIds!) {
          cardCounts[cardId] = (cardCounts[cardId] ?? 0) + 1;
        }
      }
    }
  }
  
  return cardCounts;
}
```

### 4. Average Score by Card

```dart
Future<Map<String, double>> getAverageScoreByCard() async {
  final games = await StorageService.getAllGames();
  final cardScores = <String, List<int>>{};
  
  for (final game in games) {
    for (final score in game.playerScores) {
      if (score.selectedCardIds != null) {
        for (final cardId in score.selectedCardIds!) {
          cardScores.putIfAbsent(cardId, () => []).add(score.totalScore);
        }
      }
    }
  }
  
  return cardScores.map((cardId, scores) {
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    return MapEntry(cardId, avg);
  });
}
```

## Testing the Integration

### 1. Test Card Loading

```dart
void testCardLoading() async {
  final cards = await CardService.loadCards();
  print('Total cards: ${cards.length}'); // Should be 57
  
  final baseCards = await CardService.getBaseGameCards();
  print('Base cards: ${baseCards.length}'); // Should be 48
}
```

### 2. Test Card Selection Flow

1. Add a test button to your app
2. Navigate to card selection screen
3. Select 15 cards
4. Add conditional scoring inputs (Architect, Clock Tower, etc.)
5. Verify score calculation
6. Save and verify data persists

### 3. Test Score Calculation

```dart
void testScoreCalculation() async {
  final result = await CardSelectionHelper.calculateScore(
    selectedCardIds: ['king', 'queen', 'doctor', 'architect'],
    basicEvents: 2,
    specialEvents: 1,
    resourceCounts: {'pebbles_resin': 4},
  );
  print('Calculated score: $result');
}
```

## Tips for Best UX

1. **First Time User**: Show a tutorial or help text explaining card selection
2. **Quick Entry**: Still offer the simple manual entry for quick games
3. **Card Images**: The placeholder cards look good, but add images when available
4. **Search**: The search box is helpful when selecting 15 cards quickly
5. **Undo**: Consider adding an undo button for accidental selections
6. **Validation**: Show warnings if users select impossible combinations

## Migration Strategy

If you have existing games in the database:

1. Old games without `selectedCardIds` will still work fine
2. `CardSelectionHelper.isVisualCardSelection()` checks if cards were selected
3. Display fallback text for old games: "Manual scoring"
4. New games can use visual selection going forward

## Performance Notes

- Cards are cached after first load (`CardService._cachedCards`)
- JSON parsing happens once per app session
- Image assets are loaded lazily by Flutter
- Consider adding pagination if you add many expansion cards (100+)

---

**You're all set!** The card selection system is fully integrated and ready to use. Start with Option 1 (Quick Test) to see it in action, then integrate into your main flow.
