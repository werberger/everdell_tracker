import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/everdell_card.dart';
import '../providers/settings_provider.dart';
import '../services/card_service.dart';
import '../widgets/card_display_widget.dart';
import '../widgets/card_carousel_widget.dart';

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
  bool _useCarouselView = true; // Toggle between carousel and list view
  CardColor? _selectedColorFilter; // For carousel color filtering

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
    
    // Read setting for initial view (after first frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      setState(() {
        _useCarouselView = settings.settings.useFanLayout;
      });
    });
    
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
    int husbandCount = 0;
    int wifeCount = 0;
    int scurrbleChampionCount = 0;

    for (final entry in _selectedCardCounts.entries) {
      final card = _allCards.firstWhere((c) => c.id == entry.key);
      final count = entry.value;

      // Track husband/wife counts for pairing
      if (card.id == 'husband') husbandCount = count;
      if (card.id == 'wife') wifeCount = count;
      
      // Track Scurrble Champions (all can share one space)
      if (card.id == 'scurrble_champion') {
        scurrbleChampionCount = count;
      }

      // Only count cards that count toward city size
      if (card.countsTowardCitySize) {
        size += count;
      }
    }

    // Husband/Wife pairing: pairs share spaces
    // e.g., 1 husband + 1 wife = 1 space, 2 husband + 2 wife = 2 spaces
    if (husbandCount > 0 && wifeCount > 0) {
      final pairs = husbandCount < wifeCount ? husbandCount : wifeCount;
      size -= pairs; // Each pair shares a space
    }
    
    // Scurrble Champions: all share one space (max reduction is count - 1)
    if (scurrbleChampionCount > 1) {
      size -= (scurrbleChampionCount - 1); // All champions share 1 space
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
          // Your City section - selected cards
          if (_selectedCardCounts.isNotEmpty)
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedCardCounts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0, top: 30),
                              child: Text(
                                'Your City',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            );
                          }

                          final cardId = _selectedCardCounts.keys.elementAt(index - 1);
                          final count = _selectedCardCounts[cardId]!;
                          final card = _allCards.firstWhere((c) => c.id == cardId);
                          
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 70,
                            child: Stack(
                              children: [
                                CardDisplayWidget(
                                  card: card,
                                  isSelected: true,
                                  onTap: () => _removeCard(card),
                                ),
                                if (count > 1)
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.amber,
                                      child: Text(
                                        '$count',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Text(
                    '$totalCards card${totalCards != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          
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
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _useCarouselView ? Icons.view_carousel : Icons.grid_view,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _useCarouselView = !_useCarouselView;
                        });
                      },
                      tooltip: _useCarouselView ? 'Switch to Grid' : 'Switch to Carousel',
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
              ],
            ),
          ),

          const Divider(),

          // Card display (carousel or grid)
          if (_useCarouselView)
            _buildCarouselView(filteredCards)
          else
            _buildGridView(),
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

  Widget _buildGridView() {
    final filteredCards = _getFilteredCards();
    
    return Expanded(
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
                                // Top button row - matching carousel layout
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.5),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Remove button (left)
                                        if (isSelected)
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle),
                                            color: Colors.red,
                                            iconSize: 28,
                                            onPressed: () => _removeCard(card),
                                          )
                                        else
                                          const SizedBox(width: 48),
                                        
                                        // Count badge (center)
                                        if (cardCount > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.amber,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '$cardCount',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                          )
                                        else
                                          const SizedBox(width: 48),
                                        
                                        // Add button (right)
                                        if (card.rarity == CardRarity.common)
                                          IconButton(
                                            icon: const Icon(Icons.add_circle),
                                            color: Colors.green,
                                            iconSize: 28,
                                            onPressed: () => _addCard(card),
                                          )
                                        else
                                          const SizedBox(width: 48),
                                      ],
                                    ),
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
    );
  }

  Widget _buildCarouselView(List<EverdellCard> filteredCards) {
    // Color filter chips
    final colorFilterChips = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: _selectedColorFilter == null,
              onSelected: (selected) {
                setState(() {
                  _selectedColorFilter = null;
                });
              },
            ),
            const SizedBox(width: 8),
            ...CardColor.values.map((color) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(_getColorName(color)),
                  selected: _selectedColorFilter == color,
                  onSelected: (selected) {
                    setState(() {
                      _selectedColorFilter = selected ? color : null;
                    });
                  },
                  backgroundColor: _getColorForType(color).withOpacity(0.2),
                  selectedColor: _getColorForType(color),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );

    // Filter cards by selected color
    final cardsToDisplay = _selectedColorFilter == null
        ? filteredCards
        : filteredCards.where((card) => card.cardColor == _selectedColorFilter).toList();

    if (cardsToDisplay.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              colorFilterChips,
              const SizedBox(height: 20),
              const Text('No cards found'),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          colorFilterChips,
          const SizedBox(height: 4),
          Text(
            'Swipe to browse • Tap center card to select',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CardCarouselWidget(
              cards: cardsToDisplay,
              selectedCardIds: _selectedCardCounts.keys.toSet(),
              selectedCardCounts: _selectedCardCounts,
              onCardTap: (card) {
                if (card.rarity == CardRarity.unique) {
                  // Toggle selection for unique cards
                  if (_selectedCardCounts.containsKey(card.id)) {
                    _removeCard(card);
                  } else {
                    _addCard(card);
                  }
                } else {
                  // For common cards, just add one
                  _addCard(card);
                }
              },
              onCardAdd: (card) => _addCard(card),
              onCardRemove: (card) => _removeCard(card),
            ),
          ),
        ],
      ),
    );
  }


  String _getColorName(CardColor color) {
    switch (color) {
      case CardColor.production:
        return 'Production';
      case CardColor.governance:
        return 'Governance';
      case CardColor.destination:
        return 'Destination';
      case CardColor.traveller:
        return 'Traveller';
      case CardColor.prosperity:
        return 'Prosperity';
    }
  }

  Color _getColorForType(CardColor color) {
    switch (color) {
      case CardColor.production:
        return Colors.green;
      case CardColor.governance:
        return Colors.blue;
      case CardColor.destination:
        return Colors.red;
      case CardColor.traveller:
        return Colors.amber; // Tan/Yellow
      case CardColor.prosperity:
        return Colors.purple;
    }
  }
}
