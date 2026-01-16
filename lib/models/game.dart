import 'package:hive/hive.dart';

import 'expansion.dart';
import 'player_score.dart';

part 'game.g.dart';

@HiveType(typeId: 0)
class Game extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime dateTime;

  @HiveField(2)
  final List<Expansion> expansionsUsed;

  @HiveField(3)
  final List<PlayerScore> players;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final List<String> winnerIds;

  Game({
    required this.id,
    required this.dateTime,
    required this.expansionsUsed,
    required this.players,
    this.notes,
    required this.winnerIds,
  });
}
