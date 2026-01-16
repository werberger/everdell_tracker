import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/game.dart';
import '../models/player_score.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('yyyy-MM-dd').format(game.dateTime);
    final winners = _winnerNames();
    final topScores = _topScores();

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(dateText),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (winners.isNotEmpty)
              Wrap(
                spacing: 6,
                children: winners
                    .map(
                      (name) => Chip(
                        label: Text(name),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                    )
                    .toList(),
              ),
            if (topScores.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  topScores,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  List<String> _winnerNames() {
    if (game.winnerIds.isEmpty) {
      return [];
    }
    final winners = game.players
        .where((player) => game.winnerIds.contains(player.playerId))
        .map((player) => player.playerName)
        .toList();
    return winners;
  }

  String _topScores() {
    if (game.players.isEmpty) {
      return '';
    }
    final sorted = List<PlayerScore>.from(game.players)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    final top = sorted.take(3).map((player) {
      return '${player.playerName}: ${player.totalScore}';
    }).join(' • ');
    return top;
  }
}
