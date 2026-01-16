import '../models/player_score.dart';

class ScoreCalculator {
  static int calculateTotal({
    required PlayerScore score,
    required bool autoConvertResources,
  }) {
    final basePoints = _safe(score.pointTokens) +
        _safe(score.cardPoints) +
        _safe(score.basicEvents) * 3 +
        _safe(score.specialEvents) +
        _safe(score.prosperityPoints) +
        _safe(score.journeyPoints) +
        _safe(score.pearlPoints) +
        _safe(score.wonderPoints) +
        _safe(score.weatherPoints) +
        _safe(score.garlandPoints) +
        _safe(score.ticketPoints);

    final resourcePoints =
        autoConvertResources ? calculateResourcePoints(score) : 0;

    return basePoints + resourcePoints;
  }

  static int calculateResourcePoints(PlayerScore score) {
    final totalResources = calculateTiebreakerResources(score);
    return totalResources ~/ 3;
  }

  static int calculateTiebreakerResources(PlayerScore score) {
    return _safe(score.leftoverBerries) +
        _safe(score.leftoverResin) +
        _safe(score.leftoverPebbles) +
        _safe(score.leftoverWood);
  }

  static List<PlayerScore> determineTopPlayers(List<PlayerScore> players) {
    if (players.isEmpty) {
      return [];
    }

    final highestScore =
        players.map((p) => p.totalScore).reduce((a, b) => a > b ? a : b);
    final topByScore =
        players.where((p) => p.totalScore == highestScore).toList();

    if (topByScore.length <= 1) {
      return topByScore;
    }

    final highestTiebreaker = topByScore
        .map((p) => p.tiebreakerResources)
        .reduce((a, b) => a > b ? a : b);

    return topByScore
        .where((p) => p.tiebreakerResources == highestTiebreaker)
        .toList();
  }

  static int _safe(int? value) => value ?? 0;
}
