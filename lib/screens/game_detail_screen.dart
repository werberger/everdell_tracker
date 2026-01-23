import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expansion.dart';
import '../models/game.dart';
import '../models/player_score.dart';
import '../providers/game_provider.dart';
import 'new_game_screen.dart';

class GameDetailScreen extends StatelessWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('yyyy-MM-dd HH:mm').format(game.dateTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => NewGameScreen(game: game)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteGame(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          Text('Date: $dateText'),
          const SizedBox(height: 8),
          Text('Expansions: ${_expansionText(game.expansionsUsed)}'),
          const SizedBox(height: 8),
          if (game.notes != null && game.notes!.isNotEmpty)
            Text('Notes: ${game.notes}'),
          const SizedBox(height: 16),
          const Text(
            'Players',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...game.players.map((player) => _playerCard(context, player)),
        ],
      ),
    );
  }

  String _expansionText(List<Expansion> expansions) {
    if (expansions.isEmpty) {
      return 'Base';
    }
    return expansions.map((e) => e.label).join(', ');
  }

  Widget _playerCard(BuildContext context, PlayerScore player) {
    final isWinner = game.winnerIds.contains(player.playerId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    player.playerName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isWinner)
                  Chip(
                    label: const Text('Winner'),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Total: ${player.totalScore}'),
            Text('Tiebreaker Resources: ${player.tiebreakerResources}'),
            if (!player.isQuickEntry) ...[
              const Divider(),
              _line('Point Tokens', player.pointTokens),
              _line('Card Points', player.cardPoints),
              _line('Basic Events', player.basicEvents),
              _line('Special Events', player.specialEvents),
              _line('Prosperity Bonus Points', player.prosperityPoints),
              _line('Journey Points', player.journeyPoints),
              _line('Berries', player.leftoverBerries),
              _line('Resin', player.leftoverResin),
              _line('Pebbles', player.leftoverPebbles),
              _line('Wood', player.leftoverWood),
              _line('Pearlbrook Points', player.pearlPoints),
              _line('Wonder Points', player.wonderPoints),
              _line('Weather Points', player.weatherPoints),
              _line('Garland Points', player.garlandPoints),
              _line('Ticket Points', player.ticketPoints),
            ],
          ],
        ),
      ),
    );
  }

  Widget _line(String label, int? value) {
    if (value == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$label: $value'),
    );
  }

  Future<void> _deleteGame(BuildContext context) async {
    final confirm = await showDialog<bool>(
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

    if (!confirm || !context.mounted) {
      return;
    }
    await context.read<GameProvider>().deleteGame(game.id);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
