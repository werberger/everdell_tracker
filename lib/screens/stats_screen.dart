import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/game.dart';
import '../providers/game_provider.dart';
import '../services/stats_service.dart';
import 'player_detail_screen.dart';

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
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Overall stats card
                _buildOverallStatsCard(filteredGames, playerNames),
                const SizedBox(height: 16),
                const Text(
                  'Players',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Player list
                ...playerNames.map((name) {
                  final stats = StatsService.calculatePlayerStats(
                    playerName: name,
                    games: filteredGames,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.emoji_events,
                                    size: 14, color: Colors.amber.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  '${(stats.winRate * 100).toStringAsFixed(0)}% win rate',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.bar_chart, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${stats.averageScore.toStringAsFixed(1)} avg',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${stats.wins} wins in ${stats.gamesPlayed} games',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _navigateToPlayerDetail(stats),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildOverallStatsCard(List<Game> games, List<String> playerNames) {
    final totalGames = games.length;
    final totalPlayers = playerNames.length;
    
    // Calculate average score across all games
    double avgScore = 0;
    int scoreCount = 0;
    for (final game in games) {
      for (final player in game.players) {
        avgScore += player.totalScore;
        scoreCount++;
      }
    }
    if (scoreCount > 0) avgScore /= scoreCount;

    // Find highest scoring game
    int highestScore = 0;
    String highestScorer = '';
    for (final game in games) {
      for (final player in game.players) {
        if (player.totalScore > highestScore) {
          highestScore = player.totalScore;
          highestScorer = player.playerName;
        }
      }
    }

    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.public, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Overall Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverallStatItem(
                    'Total Games',
                    totalGames.toString(),
                    Icons.games,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOverallStatItem(
                    'Players',
                    totalPlayers.toString(),
                    Icons.people,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildOverallStatItem(
                    'Avg Score',
                    avgScore.toStringAsFixed(1),
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOverallStatItem(
                    'High Score',
                    highestScore.toString(),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            if (highestScorer.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Highest scoring player: $highestScorer ($highestScore pts)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  void _navigateToPlayerDetail(PlayerStats stats) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlayerDetailScreen(
          stats: stats,
          dateRange: _dateRange,
        ),
      ),
    );
  }
}
