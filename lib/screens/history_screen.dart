import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expansion.dart';
import '../models/game.dart';
import '../providers/game_provider.dart';
import '../providers/player_provider.dart';
import '../services/export_service.dart';
import '../widgets/expansion_selector.dart';
import '../widgets/game_card.dart';
import 'game_detail_screen.dart';
import 'new_game_screen.dart';

enum HistorySortOption { dateDesc, dateAsc, highestScore, winnerName }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistorySortOption _sortOption = HistorySortOption.dateDesc;
  String _playerFilter = '';
  String _winnerFilter = '';
  DateTimeRange? _dateRange;
  final List<Expansion> _expansionFilter = [];

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final games = _applyFilters(gameProvider.games);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportDialog(games);
              }
              if (value == 'import') {
                _importGames();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'export',
                child: Text('Export'),
              ),
              PopupMenuItem(
                value: 'import',
                child: Text('Import'),
              ),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<HistorySortOption>(
              value: _sortOption,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortOption = value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: HistorySortOption.dateDesc,
                  child: Text('Newest'),
                ),
                DropdownMenuItem(
                  value: HistorySortOption.dateAsc,
                  child: Text('Oldest'),
                ),
                DropdownMenuItem(
                  value: HistorySortOption.highestScore,
                  child: Text('Highest Score'),
                ),
                DropdownMenuItem(
                  value: HistorySortOption.winnerName,
                  child: Text('Winner Name'),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      body: games.isEmpty
          ? const Center(child: Text('No games yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return Dismissible(
                  key: ValueKey(game.id),
                  background: _buildSwipeBackground(
                    context,
                    Icons.edit,
                    'Edit',
                    Alignment.centerLeft,
                  ),
                  secondaryBackground: _buildSwipeBackground(
                    context,
                    Icons.delete,
                    'Delete',
                    Alignment.centerRight,
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NewGameScreen(game: game),
                        ),
                      );
                      return false;
                    }
                    return await _confirmDelete(game);
                  },
                  onDismissed: (_) async {
                    await context.read<GameProvider>().deleteGame(game.id);
                  },
                  child: GameCard(
                    game: game,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GameDetailScreen(game: game),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Future<void> _openFilterDialog() async {
    final playerController = TextEditingController(text: _playerFilter);
    final winnerController = TextEditingController(text: _winnerFilter);
    DateTimeRange? tempRange = _dateRange;
    final tempExpansions = List<Expansion>.from(_expansionFilter);

    final dateFormat = DateFormat('yyyy-MM-dd');
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Games'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: playerController,
                      decoration: const InputDecoration(
                        labelText: 'Player Name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: winnerController,
                      decoration: const InputDecoration(
                        labelText: 'Winner Name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExpansionSelector(
                      selected: tempExpansions,
                      onChanged: (value) {
                        setDialogState(() {
                          tempExpansions
                            ..clear()
                            ..addAll(value);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tempRange == null
                                ? 'Any date'
                                : '${dateFormat.format(tempRange!.start)}'
                                    ' - ${dateFormat.format(tempRange!.end)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final range = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            setDialogState(() {
                              tempRange = range;
                            });
                          },
                          child: const Text('Pick Range'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _playerFilter = '';
                      _winnerFilter = '';
                      _dateRange = null;
                      _expansionFilter.clear();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _playerFilter = playerController.text.trim();
                      _winnerFilter = winnerController.text.trim();
                      _dateRange = tempRange;
                      _expansionFilter
                        ..clear()
                        ..addAll(tempExpansions);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _exportDialog(List<Game> filteredGames) async {
    final allGames = context.read<GameProvider>().games;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Games'),
          content: const Text('Choose what to export.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('filtered'),
              child: const Text('Filtered'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('all'),
              child: const Text('All'),
            ),
          ],
        );
      },
    );

    if (choice == null) {
      return;
    }

    final gamesToExport = choice == 'all' ? allGames : filteredGames;
    final json = ExportService.exportGames(gamesToExport);
    await ExportService.shareExport(json);
  }

  Future<void> _importGames() async {
    final json = await ExportService.pickImportFile();
    if (json == null) {
      return;
    }

    final gameProvider = context.read<GameProvider>();
    final existing = gameProvider.games;
    final result = ExportService.parseImport(json, existing);
    final toAdd = <Game>[...result.newGames];

    if (result.duplicates.isNotEmpty) {
      final strategy = await _askMergeStrategy();
      if (strategy == null) {
        return;
      }
      toAdd.addAll(ExportService.mergeDuplicates(result.duplicates, strategy));
    }

    if (toAdd.isEmpty) {
      _showSnack('No new games to import.');
      return;
    }

    await gameProvider.addGames(toAdd);

    final playerProvider = context.read<PlayerProvider>();
    for (final game in toAdd) {
      for (final player in game.players) {
        await playerProvider.addPlayerName(player.playerName);
      }
    }

    _showSnack('Imported ${toAdd.length} games.');
  }

  Future<MergeStrategy?> _askMergeStrategy() async {
    return showDialog<MergeStrategy>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Duplicate Games'),
          content: const Text('How should duplicates be handled?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(MergeStrategy.skip),
              child: const Text('Skip'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(MergeStrategy.keepBoth),
              child: const Text('Keep Both'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(MergeStrategy.overwrite),
              child: const Text('Overwrite'),
            ),
          ],
        );
      },
    );
  }

  List<Game> _applyFilters(List<Game> games) {
    final filtered = games.where((game) {
      if (_playerFilter.isNotEmpty) {
        final match = game.players.any(
          (player) =>
              player.playerName.toLowerCase().contains(_playerFilter.toLowerCase()),
        );
        if (!match) {
          return false;
        }
      }
      if (_winnerFilter.isNotEmpty) {
        final winnerNames = game.players
            .where((player) => game.winnerIds.contains(player.playerId))
            .map((player) => player.playerName.toLowerCase())
            .toList();
        if (!winnerNames.any((name) => name.contains(_winnerFilter.toLowerCase()))) {
          return false;
        }
      }
      if (_expansionFilter.isNotEmpty) {
        final match = game.expansionsUsed
            .any((expansion) => _expansionFilter.contains(expansion));
        if (!match) {
          return false;
        }
      }
      if (_dateRange != null) {
        if (game.dateTime.isBefore(_dateRange!.start) ||
            game.dateTime.isAfter(_dateRange!.end)) {
          return false;
        }
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortOption) {
        case HistorySortOption.dateAsc:
          return a.dateTime.compareTo(b.dateTime);
        case HistorySortOption.dateDesc:
          return b.dateTime.compareTo(a.dateTime);
        case HistorySortOption.highestScore:
          return _highestScore(b).compareTo(_highestScore(a));
        case HistorySortOption.winnerName:
          return _winnerName(a).compareTo(_winnerName(b));
      }
    });

    return filtered;
  }

  int _highestScore(Game game) {
    if (game.players.isEmpty) {
      return 0;
    }
    return game.players
        .map((player) => player.totalScore)
        .reduce((a, b) => a > b ? a : b);
  }

  String _winnerName(Game game) {
    if (game.players.isEmpty) {
      return '';
    }
    final winner = game.players.firstWhere(
      (player) => game.winnerIds.contains(player.playerId),
      orElse: () => game.players.first,
    );
    return winner.playerName;
  }

  Widget _buildSwipeBackground(
    BuildContext context,
    IconData icon,
    String label,
    Alignment alignment,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: alignment,
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(Game game) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Game'),
              content: const Text('Are you sure you want to delete this game?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
