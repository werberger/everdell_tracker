import 'package:flutter/material.dart';
import '../models/everdell_card.dart';
import '../services/card_service.dart';
import '../widgets/card_display_widget.dart';

/// Card selection screen with multiple common cards, pairing, and proper city size
class CardSelectionScreenExample extends StatefulWidget {
  final Map<String, int>? initialCardCounts;
  final Map<String, int>? initialTokenCounts;
  final Map<String, int>? initialResourceCounts;
  final int? initialBasicEvents;
  final int? initialSpecialEventsCount;
  final int? initialSpecialEvents;
  final int? initialJourneyPoints;
  final int? leftoverPebbles;
  final int? leftoverResin;
  final int? leftoverBerries;
  final int? leftoverWood;
  
  const CardSelectionScreenExample({
    super.key,
    this.initialCardCounts,
    this.initialTokenCounts,
    this.initialResourceCounts,
    this.initialBasicEvents,
    this.initialSpecialEventsCount,
    this.initialSpecialEvents,
    this.initialJourneyPoints,
    this.leftoverPebbles,
    this.leftoverResin,
    this.leftoverBerries,
    this.leftoverWood,
  });

  @override
  State<CardSelectionScreenExample> createState() =>
      _CardSelectionScreenExampleState();
}

class _CardSelectionScreenExampleState
    extends State<CardSelectionScreenExample> {
  List<EverdellCard> _allCards = [];
  Map<CardColor, List<EverdellCard>> _cardsByColor = {};
  Map<String, int> _selectedCardCounts = {}; // CardId -> Count
  String _searchQuery = '';
  bool _isLoading = true;
  int _currentScore = 0;

  // For conditional scoring inputs
  final Map<String, int> _tokenCounts = {};
  final Map<String, int> _resourceCounts = {};
  int _basicEvents = 0;
  int _specialEventsCount = 0;
  int _specialEvents = 0;
  int _journeyPoints = 0;

  // For leftover resources
  int _leftoverBerries = 0;
  int _leftoverResin = 0;
  int _leftoverPebbles = 0;
  int _leftoverWood = 0;

  @override
  void initState() {
    super.initState();
    // Pre-populate with initial data
    if (widget.initialCardCounts != null) {
      _selectedCardCounts = Map<String, int>.from(widget.initialCardCounts!);
    }
    if (widget.initialTokenCounts != null) {
      _tokenCounts.addAll(widget.initialTokenCounts!);
    }
    if (widget.initialResourceCounts != null) {
      _resourceCounts.addAll(widget.initialResourceCounts!);
    }
    _basicEvents = widget.initialBasicEvents ?? 0;
    _specialEventsCount = widget.initialSpecialEventsCount ?? 0;
    _specialEvents = widget.initialSpecialEvents ?? 0;
    _journeyPoints = widget.initialJourneyPoints ?? 0;
    
    // Pre-populate leftover resources for Architect calculation
    _leftoverPebbles = widget.leftoverPebbles ?? 0;
    _leftoverResin = widget.leftoverResin ?? 0;
    _leftoverBerries = widget.leftoverBerries ?? 0;
    _leftoverWood = widget.leftoverWood ?? 0;
    
    // Add pebbles + resin to resourceCounts for Architect
    if (_leftoverPebbles > 0 || _leftoverResin > 0) {
      _resourceCounts['pebbles_resin'] = _leftoverPebbles + _leftoverResin;
    }
    
    _loadCards();
  }

  Future<void> _loadCards() async {
    // Load ALL cards including expansions (for placeholders)
    final cardsByColor = await CardService.getCardsGroupedByColor();
    final allCards = await CardService.loadCards();

    setState(() {
      _cardsByColor = cardsByColor;
      _allCards = allCards;
      _isLoading = false;
    });
    
    // Calculate initial score if cards are pre-selected
    if (_selectedCardCounts.isNotEmpty) {
      _calculateScore();
    }
  }

  int _getCurrentCitySize() {
    int size = 0;
    bool hasHusband = false;
    bool hasWife = false;

    for (final entry in _selectedCardCounts.entries) {
      final card = _allCards.firstWhere((c) => c.id == entry.key);
      final count = entry.value;

      // Check for Husband/Wife pairing
      if (card.id == 'husband') hasHusband = true;
      if (card.id == 'wife') hasWife = true;

      // Only count cards that count toward city size
      if (card.countsTowardCitySize) {
        size += count;
      }
    }

    // If both Husband and Wife are selected, they share 1 space
    if (hasHusband && hasWife) {
      size -= 1; // Reduce by 1 since they share a space
    }

    return size;
  }

  void _addCard(EverdellCard card) {
    setState(() {
      final currentCount = _selectedCardCounts[card.id] ?? 0;

      // Check if we can add more
      if (card.rarity == CardRarity.unique && currentCount >= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${card.name} is unique - only 1 allowed'),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Check city size limit (only for cards that count toward it)
      final newSize = card.countsTowardCitySize
          ? _getCurrentCitySize() + 1
          : _getCurrentCitySize();

      if (newSize > 15) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('City limit: Maximum 15 spaces'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      _selectedCardCounts[card.id] = currentCount + 1;
      _calculateScore();

      // Show conditional scoring dialog for first selection
      if (currentCount == 0) {
        _showConditionalScoringDialog(card);
      }
    });
  }

  void _removeCard(EverdellCard card) {
    setState(() {
      final currentCount = _selectedCardCounts[card.id] ?? 0;
      if (currentCount > 0) {
        if (currentCount == 1) {
          _selectedCardCounts.remove(card.id);
        } else {
          _selectedCardCounts[card.id] = currentCount - 1;
        }
        _calculateScore();
      }
    });
  }

  void _calculateScore() {
    final selectedCards = <EverdellCard>[];

    // Build list of all selected cards (including duplicates)
    for (final entry in _selectedCardCounts.entries) {
      final card = _allCards.firstWhere((c) => c.id == entry.key);
      final count = entry.value;
      for (int i = 0; i < count; i++) {
        selectedCards.add(card);
      }
    }

    // Update resource counts for Architect using current leftover resources
    final Map<String, int> currentResourceCounts = {};
    currentResourceCounts['pebbles_resin'] = _leftoverPebbles + _leftoverResin;

    final score = CardService.calculateTotalPoints(
      selectedCards,
      tokenCounts: _tokenCounts,
      resourceCounts: currentResourceCounts,
      basicEvents: _basicEvents,
      specialEvents: _specialEventsCount,
    );

    setState(() {
      _currentScore = score + _journeyPoints;
    });
  }

  List<EverdellCard> _getFilteredCards() {
    if (_searchQuery.isEmpty) {
      return _allCards;
    }
    return _allCards
        .where((card) =>
            card.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _showConditionalScoringDialog(EverdellCard card) {
    if (card.conditionalScoring == null ||
        card.conditionalScoring!.type == ConditionalScoringType.simple) {
      return;
    }

    final scoring = card.conditionalScoring!;

    switch (scoring.type) {
      case ConditionalScoringType.resourceCount:
        // Architect - uses leftover resources from new game screen
        // No dialog needed
        break;
      case ConditionalScoringType.tokenPlacement:
        _showTokenCountDialog(card);
        break;
      case ConditionalScoringType.eventCount:
        // King - uses event counts from new game screen
        // No dialog needed
        break;
      default:
        // Auto-calculated types don't need dialogs
        break;
    }
  }

  void _showResourceCountDialog(EverdellCard card) {
    int count = _resourceCounts['pebbles_resin'] ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        int tempCount = count;
        return AlertDialog(
          title: const Text('Architect Resources'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(card.conditionalScoring!.userPrompt ?? ''),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pebbles + Resin',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: count.toString()),
                onChanged: (value) {
                  tempCount = int.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _resourceCounts['pebbles_resin'] = tempCount;
                  _calculateScore();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showTokenCountDialog(EverdellCard card) {
    int count = _tokenCounts[card.id] ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        int tempCount = count;
        return AlertDialog(
          title: Text('${card.name} Tokens'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(card.conditionalScoring!.userPrompt ?? ''),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Token Count',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: count.toString()),
                onChanged: (value) {
                  tempCount = int.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tokenCounts[card.id] = tempCount;
                  _calculateScore();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEventCountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempBasic = _basicEvents;
        int tempSpecial = _specialEvents;
        return AlertDialog(
          title: const Text('Events Achieved'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Basic Events',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _basicEvents.toString()),
                onChanged: (value) {
                  tempBasic = int.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Special Events',
                  border: OutlineInputBorder(),
                ),
                controller:
                    TextEditingController(text: _specialEvents.toString()),
                onChanged: (value) {
                  tempSpecial = int.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _basicEvents = tempBasic;
                  _specialEvents = tempSpecial;
                  _calculateScore();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAdditionalInputsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempJourney = _journeyPoints;
        int tempBerries = _leftoverBerries;
        int tempResin = _leftoverResin;
        int tempPebbles = _leftoverPebbles;
        int tempWood = _leftoverWood;

        return AlertDialog(
          title: const Text('Additional Points & Resources'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Journey Points',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Journey Points',
                    border: OutlineInputBorder(),
                  ),
                  controller:
                      TextEditingController(text: _journeyPoints.toString()),
                  onChanged: (value) {
                    tempJourney = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Leftover Resources',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Berries',
                    border: OutlineInputBorder(),
                  ),
                  controller:
                      TextEditingController(text: _leftoverBerries.toString()),
                  onChanged: (value) {
                    tempBerries = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Resin',
                    border: OutlineInputBorder(),
                  ),
                  controller:
                      TextEditingController(text: _leftoverResin.toString()),
                  onChanged: (value) {
                    tempResin = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Pebbles',
                    border: OutlineInputBorder(),
                  ),
                  controller:
                      TextEditingController(text: _leftoverPebbles.toString()),
                  onChanged: (value) {
                    tempPebbles = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Wood/Twigs',
                    border: OutlineInputBorder(),
                  ),
                  controller:
                      TextEditingController(text: _leftoverWood.toString()),
                  onChanged: (value) {
                    tempWood = int.tryParse(value) ?? 0;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _journeyPoints = tempJourney;
                  _leftoverBerries = tempBerries;
                  _leftoverResin = tempResin;
                  _leftoverPebbles = tempPebbles;
                  _leftoverWood = tempWood;
                  _calculateScore();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredCards = _getFilteredCards();
    final currentCitySize = _getCurrentCitySize();
    final totalCards = _selectedCardCounts.values.fold(0, (sum, count) => sum + count);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Cards'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(
                'Score: $_currentScore',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.amber,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search cards...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Selected card count and city size
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'City: $currentCitySize/15 spaces',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Cards: $totalCards',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (_selectedCardCounts.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCardCounts.clear();
                        _calculateScore();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),

          const Divider(),

          // Card grid (sectioned by color)
          Expanded(
            child: ListView.builder(
              itemCount: CardColor.values.length,
              itemBuilder: (context, sectionIndex) {
                final color = CardColor.values[sectionIndex];
                final cardsInSection = _searchQuery.isEmpty
                    ? _cardsByColor[color] ?? []
                    : filteredCards.where((c) => c.cardColor == color).toList();

                if (cardsInSection.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _getColorName(color),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: cardsInSection.length,
                        itemBuilder: (context, index) {
                          final card = cardsInSection[index];
                          final cardCount = _selectedCardCounts[card.id] ?? 0;
                          final isSelected = cardCount > 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Stack(
                              children: [
                                CardDisplayWidget(
                                  card: card,
                                  isSelected: isSelected,
                                  onTap: () => _addCard(card),
                                ),
                                // Show count badge for selected cards
                                if (isSelected)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.amber,
                                      child: Text(
                                        '$cardCount',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                // Remove button (minus)
                                if (isSelected)
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    child: IconButton(
                                      icon: const Icon(Icons.remove_circle),
                                      color: Colors.red,
                                      onPressed: () => _removeCard(card),
                                      iconSize: 28,
                                    ),
                                  ),
                                // Add button (plus) for common cards
                                if (card.rarity == CardRarity.common)
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: IconButton(
                                      icon: const Icon(Icons.add_circle),
                                      color: Colors.green,
                                      onPressed: () => _addCard(card),
                                      iconSize: 28,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
      Navigator.pop(context, {
        'selectedCardCounts': _selectedCardCounts,
        'score': _currentScore,
        'tokenCounts': _tokenCounts,
        'resourceCounts': _resourceCounts,
        'basicEvents': _basicEvents,
        'specialEventsCount': _specialEventsCount,
        'specialEvents': _specialEvents,
        'journeyPoints': _journeyPoints,
            'leftoverBerries': _leftoverBerries,
            'leftoverResin': _leftoverResin,
            'leftoverPebbles': _leftoverPebbles,
            'leftoverWood': _leftoverWood,
          });
        },
        label: const Text('Save Selection'),
        icon: const Icon(Icons.check),
      ),
    );
  }

  String _getColorName(CardColor cardColor) {
    switch (cardColor) {
      case CardColor.production:
        return 'Production (Green)';
      case CardColor.destination:
        return 'Destination (Red)';
      case CardColor.governance:
        return 'Governance (Blue)';
      case CardColor.traveller:
        return 'Traveller (Tan)';
      case CardColor.prosperity:
        return 'Prosperity (Purple)';
    }
  }
}
