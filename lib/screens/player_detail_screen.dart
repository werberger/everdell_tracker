import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/stats_service.dart';

class PlayerDetailScreen extends StatelessWidget {
  final PlayerStats stats;
  final DateTimeRange? dateRange;

  const PlayerDetailScreen({
    super.key,
    required this.stats,
    this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = dateRange == null
        ? 'All time'
        : '${DateFormat('MMM d, yyyy').format(dateRange!.start)} - '
            '${DateFormat('MMM d, yyyy').format(dateRange!.end)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(stats.playerName),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share stats
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date range indicator
          _buildDateRangeChip(dateText),
          const SizedBox(height: 16),

          // Entry method breakdown
          _buildEntryMethodCard(),
          const SizedBox(height: 16),

          // Key stats at a glance
          _buildKeyStatsCard(),
          const SizedBox(height: 16),

          // Performance breakdown
          _buildPerformanceCard(),
          const SizedBox(height: 16),

          // Scoring breakdown
          _buildScoringBreakdownCard(),
          const SizedBox(height: 16),

          // Position statistics
          if (stats.positionCounts.isNotEmpty) ...[
            _buildPositionStatsCard(),
            const SizedBox(height: 16),
          ],

          // Winning card combinations
          if (stats.winningCardCombinations.isNotEmpty) ...[
            _buildWinningCombinationsCard(),
            const SizedBox(height: 16),
          ],

          // Most used cards
          if (stats.mostUsedCards.isNotEmpty) ...[
            _buildMostUsedCardsCard(),
            const SizedBox(height: 16),
          ],

          // Expansion statistics
          if (stats.expansionCounts.isNotEmpty) ...[
            _buildExpansionsCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRangeChip(String dateText) {
    return Chip(
      avatar: const Icon(Icons.calendar_today, size: 18),
      label: Text(dateText),
      backgroundColor: Colors.blue.shade50,
    );
  }

  Widget _buildEntryMethodCard() {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.input, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Game Entry Methods',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildEntryMethodChip(
                    'Visual',
                    stats.visualEntryGames,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEntryMethodChip(
                    'Basic',
                    stats.basicEntryGames,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEntryMethodChip(
                    'Quick',
                    stats.quickEntryGames,
                    Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryMethodChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
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
          ),
        ],
      ),
    );
  }

  Widget _buildKeyStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    'Games',
                    stats.gamesPlayed.toString(),
                    Icons.sports_esports,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatBox(
                    'Wins',
                    stats.wins.toString(),
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatBox(
                    'Win Rate',
                    '${(stats.winRate * 100).toStringAsFixed(0)}%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPerformanceRow(
              'Average Score',
              stats.averageScore.toStringAsFixed(1),
              Icons.bar_chart,
            ),
            const Divider(height: 24),
            _buildPerformanceRow(
              'Highest Score',
              stats.highestScore.toString(),
              Icons.stars,
            ),
            const Divider(height: 24),
            _buildPerformanceRow(
              'Lowest Score',
              stats.lowestScore.toString(),
              Icons.arrow_downward,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScoringBreakdownCard() {
    // Filter out zero averages and sort by value
    final nonZeroBreakdown = stats.averageBreakdown.entries
        .where((entry) => entry.value > 0.1)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Average Scoring Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Based on ${stats.detailedEntryGames} games (visual + basic entry)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...nonZeroBreakdown.map((entry) {
              final percentage = (entry.value / stats.averageScore * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${entry.value.toStringAsFixed(1)} (${percentage.toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionStatsCard() {
    final positions = stats.positionCounts.keys.toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Player Position Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...positions.map((position) {
              final games = stats.positionCounts[position] ?? 0;
              final wins = stats.positionWins[position] ?? 0;
              final winRate = stats.getPositionWinRate(position);
              final percentage = (games / stats.gamesPlayed * 100);

              String positionLabel;
              IconData icon;
              Color color;

              switch (position) {
                case 1:
                  positionLabel = '1st Place';
                  icon = Icons.emoji_events;
                  color = Colors.amber;
                  break;
                case 2:
                  positionLabel = '2nd Place';
                  icon = Icons.military_tech;
                  color = Colors.grey;
                  break;
                case 3:
                  positionLabel = '3rd Place';
                  icon = Icons.emoji_events_outlined;
                  color = Colors.brown;
                  break;
                default:
                  positionLabel = '${position}th Place';
                  icon = Icons.person;
                  color = Colors.blue;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            positionLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$games games (${percentage.toStringAsFixed(0)}%) • '
                            '$wins wins (${(winRate * 100).toStringAsFixed(0)}% win rate)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWinningCombinationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Winning Card Combinations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Most common card combos in winning cities',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Based on ${stats.visualEntryGames} visual entry games',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.purple.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...stats.winningCardCombinations.take(10).map((combo) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${combo.count}x',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: combo.cardNames.map((name) {
                            return Chip(
                              label: Text(
                                name,
                                style: const TextStyle(fontSize: 11),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMostUsedCardsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Most Used Cards',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Cards you play most often',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Based on ${stats.visualEntryGames} visual entry games',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...stats.mostUsedCards.take(15).map((cardStat) {
              final percentage =
                  (cardStat.count / stats.visualEntryGames * 100).toStringAsFixed(0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '${cardStat.count}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cardStat.cardName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expansions Played',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...stats.expansionCounts.entries.map((entry) {
              final percentage =
                  (entry.value / stats.gamesPlayed * 100).toStringAsFixed(0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '${entry.value} games ($percentage%)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
