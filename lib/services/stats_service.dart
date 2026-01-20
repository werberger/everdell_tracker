import '../models/game.dart';
import '../models/player_score.dart';
import '../models/expansion.dart';

class PlayerStats {
  final String playerName;
  final int gamesPlayed;
  final int wins;
  final double winRate;
  final double averageScore;
  final int highestScore;
  final Map<String, double> averageBreakdown;
  final Map<String, int> expansionCounts;
  final Map<int, int> positionCounts;
  final Map<int, int> positionWins;

  const PlayerStats({
    required this.playerName,
    required this.gamesPlayed,
    required this.wins,
    required this.winRate,
    required this.averageScore,
    required this.highestScore,
    required this.averageBreakdown,
    required this.expansionCounts,
    required this.positionCounts,
    required this.positionWins,
  });

  double getPositionWinRate(int position) {
    final games = positionCounts[position] ?? 0;
    if (games == 0) return 0.0;
    final wins = positionWins[position] ?? 0;
    return wins / games;
  }
}

class StatsService {
  static List<String> getAllPlayers(List<Game> games) {
    final names = <String>{};
    for (final game in games) {
      for (final player in game.players) {
        names.add(player.playerName);
      }
    }
    final result = names.toList();
    result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }

  static PlayerStats calculatePlayerStats({
    required String playerName,
    required List<Game> games,
  }) {
    final playerGames = <Game>[];
    final playerScores = <PlayerScore>[];
    for (final game in games) {
      final score = game.players
          .where((player) => player.playerName == playerName)
          .toList();
      if (score.isNotEmpty) {
        playerGames.add(game);
        playerScores.add(score.first);
      }
    }

    final gamesPlayed = playerScores.length;
    final wins = playerGames.where((game) {
      return game.winnerIds.any((id) {
        return game.players.any(
          (player) => player.playerId == id && player.playerName == playerName,
        );
      });
    }).length;

    final totalScore = playerScores.fold<int>(
      0,
      (sum, score) => sum + score.totalScore,
    );
    final highestScore = playerScores.isEmpty
        ? 0
        : playerScores
            .map((score) => score.totalScore)
            .reduce((a, b) => a > b ? a : b);

    final averages = _averageBreakdown(playerScores);

    final expansionCounts = <String, int>{};
    for (final game in playerGames) {
      for (final expansion in game.expansionsUsed) {
        expansionCounts.update(
          expansion.label,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    // Calculate position statistics
    final positionCounts = <int, int>{};
    final positionWins = <int, int>{};
    
    for (int i = 0; i < playerScores.length; i++) {
      final score = playerScores[i];
      final game = playerGames[i];
      final position = score.playerOrder;
      
      if (position != null) {
        positionCounts.update(position, (value) => value + 1, ifAbsent: () => 1);
        
        final isWinner = game.winnerIds.any((id) {
          return game.players.any(
            (player) => player.playerId == id && player.playerName == playerName,
          );
        });
        
        if (isWinner) {
          positionWins.update(position, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }

    return PlayerStats(
      playerName: playerName,
      gamesPlayed: gamesPlayed,
      wins: wins,
      winRate: gamesPlayed == 0 ? 0 : wins / gamesPlayed,
      averageScore: gamesPlayed == 0 ? 0 : totalScore / gamesPlayed,
      highestScore: highestScore,
      averageBreakdown: averages,
      expansionCounts: expansionCounts,
      positionCounts: positionCounts,
      positionWins: positionWins,
    );
  }

  static Map<String, double> _averageBreakdown(List<PlayerScore> scores) {
    if (scores.isEmpty) {
      return {};
    }

    final totals = <String, int>{
      'Point Tokens': 0,
      'Card Points': 0,
      'Basic Events': 0,
      'Special Events': 0,
      'Prosperity Points': 0,
      'Journey Points': 0,
      'Berries': 0,
      'Resin': 0,
      'Pebbles': 0,
      'Wood': 0,
      'Pearlbrook Points': 0,
      'Wonder Points': 0,
      'Weather Points': 0,
      'Garland Points': 0,
      'Ticket Points': 0,
    };

    for (final score in scores) {
      totals['Point Tokens'] = totals['Point Tokens']! + _safe(score.pointTokens);
      totals['Card Points'] = totals['Card Points']! + _safe(score.cardPoints);
      totals['Basic Events'] = totals['Basic Events']! + _safe(score.basicEvents);
      totals['Special Events'] =
          totals['Special Events']! + _safe(score.specialEvents);
      totals['Prosperity Points'] =
          totals['Prosperity Points']! + _safe(score.prosperityPoints);
      totals['Journey Points'] =
          totals['Journey Points']! + _safe(score.journeyPoints);
      totals['Berries'] = totals['Berries']! + _safe(score.leftoverBerries);
      totals['Resin'] = totals['Resin']! + _safe(score.leftoverResin);
      totals['Pebbles'] = totals['Pebbles']! + _safe(score.leftoverPebbles);
      totals['Wood'] = totals['Wood']! + _safe(score.leftoverWood);
      totals['Pearlbrook Points'] =
          totals['Pearlbrook Points']! + _safe(score.pearlPoints);
      totals['Wonder Points'] =
          totals['Wonder Points']! + _safe(score.wonderPoints);
      totals['Weather Points'] =
          totals['Weather Points']! + _safe(score.weatherPoints);
      totals['Garland Points'] =
          totals['Garland Points']! + _safe(score.garlandPoints);
      totals['Ticket Points'] =
          totals['Ticket Points']! + _safe(score.ticketPoints);
    }

    final result = <String, double>{};
    totals.forEach((key, value) {
      result[key] = value / scores.length;
    });
    return result;
  }

  static int _safe(int? value) => value ?? 0;
}
