import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/expansion.dart';
import '../models/game.dart';
import '../models/player_score.dart';
import '../providers/game_provider.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
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
      _players.add(_PlayerEntry(id: _uuid.v4()));
    });
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
    if (entry.isQuickEntry && entry.quickTotal == null) {
      return null;
    }
    final score = entry.buildScore(
      autoConvertResources: autoConvertResources,
      isWinner: false,
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
      scores.add(
        entry.buildScore(
          autoConvertResources: settings.autoConvertResources,
          isWinner: false,
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
      if (entry.isQuickEntry && entry.quickTotal == null) {
        _showSnack('Enter a total score for each quick entry player.');
        return;
      }
      scores.add(
        entry.buildScore(
          autoConvertResources: settings.autoConvertResources,
          isWinner: _winnerIds.contains(entry.id),
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
        padding: const EdgeInsets.all(16),
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
              isQuickEntry: entry.isQuickEntry,
              onQuickEntryChanged: (value) {
                setState(() {
                  entry.isQuickEntry = value;
                });
              },
              totalController: entry.totalController,
              separatePointTokens: settings.separatePointTokens,
              autoConvertResources: settings.autoConvertResources,
              expansions: _selectedExpansions,
              pointTokensController: entry.pointTokensController,
              cardPointsController: entry.cardPointsController,
              basicEventsController: entry.basicEventsController,
              specialEventsController: entry.specialEventsController,
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

  bool isQuickEntry = false;

  _PlayerEntry({required this.id});

  static int calculateStartingCards(int playerOrder) {
    // Everdell starting cards: 1st=5, 2nd=6, 3rd=7, 4th+=8
    if (playerOrder == 1) return 5;
    if (playerOrder == 2) return 6;
    if (playerOrder == 3) return 7;
    return 8;
  }

  factory _PlayerEntry.fromScore(PlayerScore score) {
    final entry = _PlayerEntry(id: score.playerId)
      ..nameController.text = score.playerName
      ..isQuickEntry = score.isQuickEntry;

    if (score.isQuickEntry) {
      entry.totalController.text = score.totalScore.toString();
    } else {
      entry.pointTokensController.text = _toText(score.pointTokens);
      entry.cardPointsController.text = _toText(score.cardPoints);
      entry.basicEventsController.text = _toText(score.basicEvents);
      entry.specialEventsController.text = _toText(score.specialEvents);
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
    }

    entry.playerOrderController.text = _toText(score.playerOrder);
    entry.startingCardsController.text = _toText(score.startingCards);

    return entry;
  }

  int? get quickTotal => int.tryParse(totalController.text);

  PlayerScore buildScore({
    required bool autoConvertResources,
    required bool isWinner,
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
      isQuickEntry: isQuickEntry,
    );

    final total = isQuickEntry
        ? (quickTotal ?? 0)
        : ScoreCalculator.calculateTotal(
            score: baseScore,
            autoConvertResources: autoConvertResources,
          );

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
      isQuickEntry: isQuickEntry,
      playerOrder: _parse(playerOrderController),
      startingCards: _parse(startingCardsController),
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

  void dispose() {
    nameController.dispose();
    totalController.dispose();
    pointTokensController.dispose();
    cardPointsController.dispose();
    basicEventsController.dispose();
    specialEventsController.dispose();
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
  }

  static String _toText(int? value) => value == null ? '' : value.toString();
}
