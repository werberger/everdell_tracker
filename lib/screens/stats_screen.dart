import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/game.dart';
import '../providers/game_provider.dart';
import '../services/stats_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final games = context.watch<GameProvider>().games;
    final filteredGames = _filterGames(games);
    final playerNames = StatsService.getAllPlayers(filteredGames);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Stats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: playerNames.isEmpty
          ? const Center(child: Text('No players yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: playerNames.length,
              itemBuilder: (context, index) {
                final name = playerNames[index];
                final stats = StatsService.calculatePlayerStats(
                  playerName: name,
                  games: filteredGames,
                );
                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(
                      'Win rate: ${(stats.winRate * 100).toStringAsFixed(1)}% '
                      '• Avg: ${stats.averageScore.toStringAsFixed(1)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showDetails(stats),
                  ),
                );
              },
            ),
    );
  }

  List<Game> _filterGames(List<Game> games) {
    if (_dateRange == null) {
      return games;
    }
    return games.where((game) {
      return !game.dateTime.isBefore(_dateRange!.start) &&
          !game.dateTime.isAfter(_dateRange!.end);
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    setState(() => _dateRange = range);
  }

  Future<void> _showDetails(PlayerStats stats) async {
    final dateText = _dateRange == null
        ? 'All time'
        : '${DateFormat('yyyy-MM-dd').format(_dateRange!.start)}'
            ' - ${DateFormat('yyyy-MM-dd').format(_dateRange!.end)}';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(stats.playerName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Range: $dateText'),
                const SizedBox(height: 8),
                Text('Games Played: ${stats.gamesPlayed}'),
                Text('Wins: ${stats.wins}'),
                Text(
                  'Win Rate: ${(stats.winRate * 100).toStringAsFixed(1)}%',
                ),
                Text(
                  'Average Score: ${stats.averageScore.toStringAsFixed(1)}',
                ),
                Text('Highest Score: ${stats.highestScore}'),
                const SizedBox(height: 12),
                const Text(
                  'Average Breakdown',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...stats.averageBreakdown.entries.map(
                  (entry) => Text(
                    '${entry.key}: ${entry.value.toStringAsFixed(1)}',
                  ),
                ),
                if (stats.expansionCounts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Expansions Played',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...stats.expansionCounts.entries.map(
                    (entry) => Text('${entry.key}: ${entry.value}'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
