import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'history_screen.dart';
import 'new_game_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import '../providers/game_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = context.watch<GameProvider>().games;
    final latestGame = games.isEmpty
        ? null
        : (List.of(games)
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime)))
            .first;
    final latestWinner = latestGame == null
        ? '—'
        : latestGame.players
            .where((player) => latestGame.winnerIds.contains(player.playerId))
            .map((player) => player.playerName)
            .join(', ');
    final latestDate = latestGame == null
        ? '—'
        : DateFormat('yyyy-MM-dd').format(latestGame.dateTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Everdell Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/images/Everdell-Header.webp',
            fit: BoxFit.cover,
            height: 200,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NewGameScreen()),
                );
              },
              child: const Text('New Game'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
              child: const Text('Game History'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                );
              },
              child: const Text('Player Stats'),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Stats',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Total games played: ${games.length}'),
                    Text(
                      'Most recent winner: '
                      '${latestWinner.isEmpty ? '—' : latestWinner}',
                    ),
                    Text('Last game date: $latestDate'),
                  ],
                ),
              ),
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
