import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/expansion.dart';
import '../models/everdell_card.dart';
import '../models/game.dart';
import '../models/player_score.dart';
import '../providers/game_provider.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/card_selection_screen_example.dart';
import '../services/card_service.dart';
import '../utils/score_calculator.dart';
import '../widgets/expansion_selector.dart';
import '../widgets/player_input_card.dart';

class NewGameScreen extends StatefulWidget {
  final Game? game;

  const NewGameScreen({super.key, this.game});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final _uuid = const Uuid();
  final List<Expansion> _selectedExpansions = [];
  final List<_PlayerEntry> _players = [];
  final TextEditingController _notesController = TextEditingController();
  List<String> _winnerIds = [];
  String? _editingGameId;
  DateTime _gameDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.game != null) {
      _loadExistingGame(widget.game!);
    } else {
      _addPlayer();
    }
  }
  void _loadExistingGame(Game game) {
    _editingGameId = game.id;
    _gameDateTime = game.dateTime;
    _selectedExpansions
      ..clear()
      ..addAll(game.expansionsUsed);
    _notesController.text = game.notes ?? '';
    _winnerIds = List<String>.from(game.winnerIds);
    _players.clear();
    for (final score in game.players) {
      _players.add(_PlayerEntry.fromScore(score));
    }
  }


  @override
  void dispose() {
    for (final entry in _players) {
      entry.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    setState(() {
      _players.add(_PlayerEntry(id: _uuid.v4())..entryMethod = 'visual'); // Default to visual
    });
  }

  Future<void> _selectCardsForPlayer(_PlayerEntry entry) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CardSelectionScreenExample(
          initialCardCounts: entry.selectedCardCounts,
          initialTokenCounts: entry.cardTokenCounts,
          initialResourceCounts: entry.cardResourceCounts,
          initialBasicEvents: int.tryParse(entry.basicEventsController.text),
          initialSpecialEventsCount: int.tryParse(entry.specialEventsCountController.text),
          initialSpecialEvents: int.tryParse(entry.specialEventsController.text),
          initialJourneyPoints: int.tryParse(entry.journeyPointsController.text),
          leftoverPebbles: int.tryParse(entry.pebblesController.text),
          leftoverResin: int.tryParse(entry.resinController.text),
          leftoverBerries: int.tryParse(entry.berriesController.text),
          leftoverWood: int.tryParse(entry.woodController.text),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        entry.selectedCardCounts = Map<String, int>.from(result['selectedCardCounts'] ?? {});
        entry.cardTokenCounts = Map<String, int>.from(result['tokenCounts'] ?? {});
        entry.cardResourceCounts = Map<String, int>.from(result['resourceCounts'] ?? {});
        entry.visualScore = result['score'] as int?;
        
        // Calculate base card score (without events/journey/dynamic bonuses for dynamic recalculation)
        final basicEvents = (result['basicEvents'] as int?) ?? 0;
        final specialEventsCount = (result['specialEventsCount'] as int?) ?? 0;
        final specialEventsPoints = (result['specialEvents'] as int?) ?? 0;
        final journey = (result['journeyPoints'] as int?) ?? 0;
        
        // Remove events and journey from the stored score
        int baseScore = (entry.visualScore ?? 0) - (basicEvents * 3) - specialEventsPoints - journey;
        
        // Also remove King and Architect bonuses if they were included
        if (entry.selectedCardCounts?.containsKey('king') == true) {
          baseScore -= (basicEvents * 1) + (specialEventsCount * 2);
        }
        
        if (entry.selectedCardCounts?.containsKey('architect') == true) {
          final pebbles = int.tryParse(entry.pebblesController.text) ?? 0;
          final resin = int.tryParse(entry.resinController.text) ?? 0;
          final architectBonus = (pebbles + resin).clamp(0, 6);
          baseScore -= architectBonus;
        }
        
        entry.visualCardScore = baseScore;
        
        // Update text controllers with data from card selection
        entry.pointTokensController.text = '0'; // Reset point tokens for visual mode
        entry.basicEventsController.text = basicEvents.toString();
        entry.specialEventsCountController.text = specialEventsCount.toString();
        entry.specialEventsController.text = specialEventsPoints.toString();
        entry.journeyPointsController.text = journey.toString();
      });
    }
  }

  void _removePlayer(_PlayerEntry entry) {
    setState(() {
      _players.remove(entry);
      entry.dispose();
      _winnerIds.remove(entry.id);
    });
  }

  int? _calculateTotal(
    _PlayerEntry entry,
    bool autoConvertResources,
  ) {
    if (entry.entryMethod == 'quick' && entry.quickTotal == null) {
      return null;
    }
    
    // Calculate other players' event counts for Rugwort
    int otherPlayersEventCount = 0;
    for (final otherEntry in _players) {
      if (otherEntry.id != entry.id) {
        final basicEvents = int.tryParse(otherEntry.basicEventsController.text) ?? 0;
        final specialEventsCount = int.tryParse(otherEntry.specialEventsCountController.text) ?? 0;
        otherPlayersEventCount += basicEvents + specialEventsCount;
      }
    }
    
    final score = entry.buildScore(
      autoConvertResources: autoConvertResources,
      isWinner: false,
      otherPlayersEventCount: otherPlayersEventCount,
    );
    return score.totalScore;
  }

  Future<void> _calculateWinners() async {
    if (_players.isEmpty) {
      return;
    }

    final settings = context.read<SettingsProvider>();
    final scores = <PlayerScore>[];
    for (final entry in _players) {
      if (entry.nameController.text.trim().isEmpty) {
        _showSnack('Each player needs a name.');
        return;
      }
      if (entry.isQuickEntry && entry.quickTotal == null) {
        _showSnack('Enter a total score for each quick entry player.');
        return;
      }
      
      // Calculate other players' event counts for Rugwort
      int otherPlayersEventCount = 0;
      for (final otherEntry in _players) {
        if (otherEntry.id != entry.id) {
          final basicEvents = int.tryParse(otherEntry.basicEventsController.text) ?? 0;
          final specialEventsCount = int.tryParse(otherEntry.specialEventsCountController.text) ?? 0;
          otherPlayersEventCount += basicEvents + specialEventsCount;
        }
      }
      
      scores.add(
        entry.buildScore(
          autoConvertResources: settings.autoConvertResources,
          isWinner: false,
          otherPlayersEventCount: otherPlayersEventCount,
        ),
      );
    }

    final top = ScoreCalculator.determineTopPlayers(scores);
    final preselected = top.map((p) => p.playerId).toSet();
    final selected = await _showWinnerDialog(scores, preselected);
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _winnerIds = selected;
    });
  }

  Future<List<String>?> _showWinnerDialog(
    List<PlayerScore> scores,
    Set<String> preselected,
  ) {
    return showDialog<List<String>>(
      context: context,
      builder: (context) {
        final selected = <String>{...preselected};
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Winner(s)'),
              content: SingleChildScrollView(
                child: Column(
                  children: scores.map((score) {
                    final isChecked = selected.contains(score.playerId);
                    return CheckboxListTile(
                      value: isChecked,
                      title: Text(score.playerName),
                      subtitle: Text('Score: ${score.totalScore}'),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            selected.add(score.playerId);
                          } else {
                            selected.remove(score.playerId);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      selected
                        ..clear()
                        ..addAll(scores.map((s) => s.playerId));
                    });
                  },
                  child: const Text('Mark Tie'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(selected.toList()),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveGame() async {
    if (_players.isEmpty) {
      _showSnack('Add at least one player.');
      return;
    }

    final settings = context.read<SettingsProvider>();
    final gameProvider = context.read<GameProvider>();
    final playerProvider = context.read<PlayerProvider>();

    if (_winnerIds.isEmpty) {
      final proceed = await _confirmNoWinners();
      if (!proceed) {
        return;
      }
    }

    final scores = <PlayerScore>[];
    for (final entry in _players) {
      final name = entry.nameController.text.trim();
      if (name.isEmpty) {
        _showSnack('Each player needs a name.');
        return;
      }
      if (entry.entryMethod == 'quick' && entry.quickTotal == null) {
        _showSnack('Enter a total score for each quick entry player.');
        return;
      }
      
      // Calculate other players' event counts for Rugwort
      int otherPlayersEventCount = 0;
      for (final otherEntry in _players) {
        if (otherEntry.id != entry.id && otherEntry.nameController.text.trim().isNotEmpty) {
          final basicEvents = int.tryParse(otherEntry.basicEventsController.text) ?? 0;
          final specialEventsCount = int.tryParse(otherEntry.specialEventsCountController.text) ?? 0;
          otherPlayersEventCount += basicEvents + specialEventsCount;
        }
      }
      
      scores.add(
        entry.buildScore(
          autoConvertResources: settings.autoConvertResources,
          isWinner: _winnerIds.contains(entry.id),
          otherPlayersEventCount: otherPlayersEventCount,
        ),
      );
    }

    final game = Game(
      id: _editingGameId ?? _uuid.v4(),
      dateTime: _gameDateTime,
      expansionsUsed: List<Expansion>.from(_selectedExpansions),
      players: scores,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      winnerIds: List<String>.from(_winnerIds),
    );

    if (_editingGameId == null) {
      await gameProvider.addGame(game);
    } else {
      await gameProvider.updateGame(game);
    }
    for (final entry in _players) {
      await playerProvider.addPlayerName(entry.nameController.text);
    }

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _confirmNoWinners() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('No Winner Selected'),
              content: const Text(
                'You have not selected a winner. Do you want to save anyway?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _gameDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _gameDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _gameDateTime.hour,
          _gameDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_gameDateTime),
    );
    if (picked != null) {
      setState(() {
        _gameDateTime = DateTime(
          _gameDateTime.year,
          _gameDateTime.month,
          _gameDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  List<String> _winnerNames() {
    return _players
        .where((entry) => _winnerIds.contains(entry.id))
        .map((entry) => entry.nameController.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final playerNames = context.watch<PlayerProvider>().playerNames;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingGameId == null ? 'New Game' : 'Edit Game'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          const Text(
            'Game Date & Time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('MMM d, yyyy').format(_gameDateTime)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(DateFormat('h:mm a').format(_gameDateTime)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Expansions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ExpansionSelector(
            selected: _selectedExpansions,
            onChanged: (value) {
              setState(() {
                _selectedExpansions
                  ..clear()
                  ..addAll(value);
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Players',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final entry in _players)
            PlayerInputCard(
              index: _players.indexOf(entry),
              nameController: entry.nameController,
              playerSuggestions: playerNames,
              isQuickEntry: entry.entryMethod == 'quick',
              onQuickEntryChanged: (value) {
                setState(() {
                  entry.entryMethod = value ? 'quick' : 'visual';
                });
              },
              totalController: entry.totalController,
              entryMethod: entry.entryMethod,
              onEntryMethodChanged: (value) {
                setState(() {
                  entry.entryMethod = value;
                });
              },
              selectedCardCounts: entry.selectedCardCounts,
              onSelectCards: () => _selectCardsForPlayer(entry),
              separatePointTokens: settings.separatePointTokens,
              autoConvertResources: settings.autoConvertResources,
              cardEntryMethod: settings.cardEntryMethod,
              expansions: _selectedExpansions,
              pointTokensController: entry.pointTokensController,
              cardPointsController: entry.cardPointsController,
              constructionPointsController: entry.constructionPointsController,
              critterPointsController: entry.critterPointsController,
              productionPointsController: entry.productionPointsController,
              destinationPointsController: entry.destinationPointsController,
              governancePointsController: entry.governancePointsController,
              travellerPointsController: entry.travellerPointsController,
              prosperityCardPointsController:
                  entry.prosperityCardPointsController,
              basicEventsController: entry.basicEventsController,
              specialEventsController: entry.specialEventsController,
              specialEventsCountController: entry.specialEventsCountController,
              prosperityPointsController: entry.prosperityPointsController,
              journeyPointsController: entry.journeyPointsController,
              berriesController: entry.berriesController,
              resinController: entry.resinController,
              pebblesController: entry.pebblesController,
              woodController: entry.woodController,
              pearlPointsController: entry.pearlPointsController,
              wonderPointsController: entry.wonderPointsController,
              weatherPointsController: entry.weatherPointsController,
              garlandPointsController: entry.garlandPointsController,
              ticketPointsController: entry.ticketPointsController,
              playerOrderController: entry.playerOrderController,
              startingCardsController: entry.startingCardsController,
              onRemove: () => _removePlayer(entry),
              onChanged: () => setState(() {}),
              calculatedTotal:
                  _calculateTotal(entry, settings.autoConvertResources),
            ),
          TextButton.icon(
            onPressed: _addPlayer,
            icon: const Icon(Icons.add),
            label: const Text('Add Player'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _calculateWinners,
            child: const Text('Select Winner(s)'),
          ),
          if (_winnerIds.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: _winnerNames()
                  .map((name) => Chip(label: Text(name)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saveGame,
            child: const Text('Save Game'),
          ),
        ],
      ),
    );
  }
}

class _PlayerEntry {
  final String id;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController pointTokensController = TextEditingController();
  final TextEditingController cardPointsController = TextEditingController();
  final TextEditingController basicEventsController = TextEditingController();
  final TextEditingController specialEventsController = TextEditingController();
  final TextEditingController specialEventsCountController = TextEditingController();
  final TextEditingController prosperityPointsController =
      TextEditingController();
  final TextEditingController journeyPointsController = TextEditingController();
  final TextEditingController berriesController = TextEditingController();
  final TextEditingController resinController = TextEditingController();
  final TextEditingController pebblesController = TextEditingController();
  final TextEditingController woodController = TextEditingController();
  final TextEditingController pearlPointsController = TextEditingController();
  final TextEditingController wonderPointsController = TextEditingController();
  final TextEditingController weatherPointsController = TextEditingController();
  final TextEditingController garlandPointsController = TextEditingController();
  final TextEditingController ticketPointsController = TextEditingController();
  final TextEditingController playerOrderController = TextEditingController();
  final TextEditingController startingCardsController = TextEditingController();
  final TextEditingController constructionPointsController =
      TextEditingController();
  final TextEditingController critterPointsController = TextEditingController();
  final TextEditingController productionPointsController =
      TextEditingController();
  final TextEditingController destinationPointsController =
      TextEditingController();
  final TextEditingController governancePointsController =
      TextEditingController();
  final TextEditingController travellerPointsController =
      TextEditingController();
  final TextEditingController prosperityCardPointsController =
      TextEditingController();

  bool isQuickEntry = false;
  String entryMethod = 'visual'; // 'visual', 'basic', or 'quick'
  
  // Card selection data
  Map<String, int>? selectedCardCounts;
  Map<String, int>? cardTokenCounts;
  Map<String, int>? cardResourceCounts;
  int? visualCardScore; // Store the base card score (without events/journey)
  int? visualScore; // Store the total calculated score from card selection

  _PlayerEntry({required this.id});

  factory _PlayerEntry.fromScore(PlayerScore score) {
    final entry = _PlayerEntry(id: score.playerId)
      ..nameController.text = score.playerName
      ..isQuickEntry = score.isQuickEntry
      ..selectedCardCounts = score.selectedCardIds != null 
          ? {for (var id in score.selectedCardIds!) id: 1} // Simplified for now
          : null
      ..cardTokenCounts = score.cardTokenCounts
      ..cardResourceCounts = score.cardResourceCounts;

    // Determine entry method
    if (score.isQuickEntry) {
      entry.entryMethod = 'quick';
      entry.totalController.text = score.totalScore.toString();
    } else if (score.selectedCardIds != null && score.selectedCardIds!.isNotEmpty) {
      entry.entryMethod = 'visual';
      // Populate fields from card selection data
      entry.basicEventsController.text = _toText(score.basicEvents);
      entry.specialEventsController.text = _toText(score.specialEvents);
      entry.journeyPointsController.text = _toText(score.journeyPoints);
    } else {
      entry.entryMethod = 'basic';
    }

    if (!score.isQuickEntry && score.selectedCardIds == null) {
      entry.pointTokensController.text = _toText(score.pointTokens);
      entry.cardPointsController.text = _toText(score.cardPoints);
      entry.basicEventsController.text = _toText(score.basicEvents);
      entry.specialEventsController.text = _toText(score.specialEvents);
      entry.specialEventsCountController.text = '0'; // Default for old data
      entry.prosperityPointsController.text = _toText(score.prosperityPoints);
      entry.journeyPointsController.text = _toText(score.journeyPoints);
      entry.berriesController.text = _toText(score.leftoverBerries);
      entry.resinController.text = _toText(score.leftoverResin);
      entry.pebblesController.text = _toText(score.leftoverPebbles);
      entry.woodController.text = _toText(score.leftoverWood);
      entry.pearlPointsController.text = _toText(score.pearlPoints);
      entry.wonderPointsController.text = _toText(score.wonderPoints);
      entry.weatherPointsController.text = _toText(score.weatherPoints);
      entry.garlandPointsController.text = _toText(score.garlandPoints);
      entry.ticketPointsController.text = _toText(score.ticketPoints);
      entry.constructionPointsController.text =
          _toText(score.constructionPoints);
      entry.critterPointsController.text = _toText(score.critterPoints);
      entry.productionPointsController.text = _toText(score.productionPoints);
      entry.destinationPointsController.text =
          _toText(score.destinationPoints);
      entry.governancePointsController.text = _toText(score.governancePoints);
      entry.travellerPointsController.text = _toText(score.travellerPoints);
      entry.prosperityCardPointsController.text =
          _toText(score.prosperityCardPoints);
    }

    entry.playerOrderController.text = _toText(score.playerOrder);
    entry.startingCardsController.text = _toText(score.startingCards);

    return entry;
  }

  int? get quickTotal => int.tryParse(totalController.text);

  PlayerScore buildScore({
    required bool autoConvertResources,
    required bool isWinner,
    int otherPlayersEventCount = 0,
  }) {
    final tiebreakerResources = _resourceTotal();
    final baseScore = PlayerScore(
      playerId: id,
      playerName: nameController.text.trim(),
      pointTokens: _parse(pointTokensController),
      cardPoints: _parse(cardPointsController),
      basicEvents: _parse(basicEventsController),
      specialEvents: _parse(specialEventsController),
      prosperityPoints: _parse(prosperityPointsController),
      journeyPoints: _parse(journeyPointsController),
      leftoverBerries: _parse(berriesController),
      leftoverResin: _parse(resinController),
      leftoverPebbles: _parse(pebblesController),
      leftoverWood: _parse(woodController),
      pearlPoints: _parse(pearlPointsController),
      wonderPoints: _parse(wonderPointsController),
      weatherPoints: _parse(weatherPointsController),
      garlandPoints: _parse(garlandPointsController),
      ticketPoints: _parse(ticketPointsController),
      totalScore: 0,
      tiebreakerResources: tiebreakerResources,
      isWinner: false,
      isQuickEntry: entryMethod == 'quick',
      constructionPoints: _parse(constructionPointsController),
      critterPoints: _parse(critterPointsController),
      productionPoints: _parse(productionPointsController),
      destinationPoints: _parse(destinationPointsController),
      governancePoints: _parse(governancePointsController),
      travellerPoints: _parse(travellerPointsController),
      prosperityCardPoints: _parse(prosperityCardPointsController),
      // Card selection data
      selectedCardIds: selectedCardCounts != null 
          ? selectedCardCounts!.keys.toList()
          : null,
      cardTokenCounts: cardTokenCounts,
      cardResourceCounts: cardResourceCounts,
    );

    int total;
    if (entryMethod == 'quick') {
      total = quickTotal ?? 0;
    } else if (entryMethod == 'visual' && selectedCardCounts != null) {
      // Dynamically recalculate from selected cards with current inputs
      total = _calculateVisualScoreSync(otherPlayersEventCount: otherPlayersEventCount);
    } else {
      total = ScoreCalculator.calculateTotal(
        score: baseScore,
        autoConvertResources: autoConvertResources,
      );
    }

    return PlayerScore(
      playerId: baseScore.playerId,
      playerName: baseScore.playerName,
      pointTokens: baseScore.pointTokens,
      cardPoints: baseScore.cardPoints,
      basicEvents: baseScore.basicEvents,
      specialEvents: baseScore.specialEvents,
      prosperityPoints: baseScore.prosperityPoints,
      journeyPoints: baseScore.journeyPoints,
      leftoverBerries: baseScore.leftoverBerries,
      leftoverResin: baseScore.leftoverResin,
      leftoverPebbles: baseScore.leftoverPebbles,
      leftoverWood: baseScore.leftoverWood,
      pearlPoints: baseScore.pearlPoints,
      wonderPoints: baseScore.wonderPoints,
      weatherPoints: baseScore.weatherPoints,
      garlandPoints: baseScore.garlandPoints,
      ticketPoints: baseScore.ticketPoints,
      totalScore: total,
      tiebreakerResources: baseScore.tiebreakerResources,
      isWinner: isWinner,
      isQuickEntry: entryMethod == 'quick',
      playerOrder: _parse(playerOrderController),
      startingCards: _parse(startingCardsController),
      constructionPoints: baseScore.constructionPoints,
      critterPoints: baseScore.critterPoints,
      productionPoints: baseScore.productionPoints,
      destinationPoints: baseScore.destinationPoints,
      governancePoints: baseScore.governancePoints,
      travellerPoints: baseScore.travellerPoints,
      prosperityCardPoints: baseScore.prosperityCardPoints,
    );
  }

  int? _parse(TextEditingController controller) {
    final value = int.tryParse(controller.text);
    return value;
  }

  int _resourceTotal() {
    return (_parse(berriesController) ?? 0) +
        (_parse(resinController) ?? 0) +
        (_parse(pebblesController) ?? 0) +
        (_parse(woodController) ?? 0);
  }

  int _calculateVisualScoreSync({int otherPlayersEventCount = 0}) {
    if (selectedCardCounts == null || selectedCardCounts!.isEmpty) {
      // No cards selected, just return events + journey
      final pointTokens = _parse(pointTokensController) ?? 0;
      final basicEvents = _parse(basicEventsController) ?? 0;
      final specialEventsPoints = _parse(specialEventsController) ?? 0;
      final journey = _parse(journeyPointsController) ?? 0;
      return pointTokens + (basicEvents * 3) + specialEventsPoints + journey;
    }

    // We need to load cards synchronously - this is a workaround
    // In a real scenario, we'd need to cache the loaded cards
    // For now, use the stored visualCardScore as base and recalculate bonuses
    
    int total = 0;
    
    // Calculate base card points (without conditional bonuses)
    // This is imperfect but works for the MVP
    // TODO: Cache loaded EverdellCard objects for proper calculation
    
    // For now, use a simplified calculation
    final pointTokens = _parse(pointTokensController) ?? 0;
    final basicEvents = _parse(basicEventsController) ?? 0;
    final specialEventsCount = _parse(specialEventsCountController) ?? 0;
    final specialEventsPoints = _parse(specialEventsController) ?? 0;
    final journey = _parse(journeyPointsController) ?? 0;
    
    // Add events and journey
    total += pointTokens + (basicEvents * 3) + specialEventsPoints + journey;
    
    // Add base card points from visualCardScore
    if (visualCardScore != null) {
      total += visualCardScore!;
    }
    
    // Add dynamic conditional bonuses that depend on current inputs
    if (selectedCardCounts!.containsKey('king')) {
      // King: 1 per basic event, 2 per special event count
      total += basicEvents * 1;
      total += specialEventsCount * 2;
    }
    
    if (selectedCardCounts!.containsKey('architect')) {
      // Architect: 1 per pebble/resin (max 6)
      final pebbles = _parse(pebblesController) ?? 0;
      final resin = _parse(resinController) ?? 0;
      final architectBonus = (pebbles + resin).clamp(0, 6);
      total += architectBonus;
    }
    
    if (selectedCardCounts!.containsKey('rugwort_ruler')) {
      // Rugwort the Ruler: 1 per event (basic + special count) OTHER players achieved
      total += otherPlayersEventCount;
    }
    
    return total;
  }


  void dispose() {
    nameController.dispose();
    totalController.dispose();
    pointTokensController.dispose();
    cardPointsController.dispose();
    basicEventsController.dispose();
    specialEventsController.dispose();
    specialEventsCountController.dispose();
    prosperityPointsController.dispose();
    journeyPointsController.dispose();
    berriesController.dispose();
    resinController.dispose();
    pebblesController.dispose();
    woodController.dispose();
    pearlPointsController.dispose();
    wonderPointsController.dispose();
    weatherPointsController.dispose();
    garlandPointsController.dispose();
    ticketPointsController.dispose();
    playerOrderController.dispose();
    startingCardsController.dispose();
    constructionPointsController.dispose();
    critterPointsController.dispose();
    productionPointsController.dispose();
    destinationPointsController.dispose();
    governancePointsController.dispose();
    travellerPointsController.dispose();
    prosperityCardPointsController.dispose();
  }

  static String _toText(int? value) => value == null ? '' : value.toString();
}
