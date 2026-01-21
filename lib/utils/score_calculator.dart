import '../models/player_score.dart';

class ScoreCalculator {
  static int calculateTotal({
    required PlayerScore score,
    required bool autoConvertResources,
  }) {
    // Calculate card points based on entry method
    final cardPoints = _calculateCardPoints(score);

    final basePoints = _safe(score.pointTokens) +
        cardPoints +
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

  static int _calculateCardPoints(PlayerScore score) {
    // If by-color fields are populated, use those
    if (score.productionPoints != null ||
        score.destinationPoints != null ||
        score.governancePoints != null ||
        score.travellerPoints != null ||
        score.prosperityCardPoints != null) {
      return _safe(score.productionPoints) +
          _safe(score.destinationPoints) +
          _safe(score.governancePoints) +
          _safe(score.travellerPoints) +
          _safe(score.prosperityCardPoints);
    }

    // If by-type fields are populated, use those
    if (score.constructionPoints != null || score.critterPoints != null) {
      return _safe(score.constructionPoints) + _safe(score.critterPoints);
    }

    // Otherwise use simple cardPoints field
    return _safe(score.cardPoints);
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
