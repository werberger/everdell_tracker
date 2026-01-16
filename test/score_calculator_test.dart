import 'package:flutter_test/flutter_test.dart';

import 'package:everdell_tracker/models/player_score.dart';
import 'package:everdell_tracker/utils/score_calculator.dart';

void main() {
  test('calculates total with resource conversion', () {
    final score = PlayerScore(
      playerId: 'p1',
      playerName: 'Ada',
      pointTokens: 5,
      cardPoints: 20,
      basicEvents: 2,
      specialEvents: 4,
      prosperityPoints: 6,
      journeyPoints: 3,
      leftoverBerries: 2,
      leftoverResin: 2,
      leftoverPebbles: 1,
      leftoverWood: 1,
      pearlPoints: 3,
      wonderPoints: 2,
      weatherPoints: 1,
      garlandPoints: 2,
      ticketPoints: 3,
      totalScore: 0,
      tiebreakerResources: 0,
      isWinner: false,
      isQuickEntry: false,
    );

    final total = ScoreCalculator.calculateTotal(
      score: score,
      autoConvertResources: true,
    );

    // Resources: 2+2+1+1 = 6 -> 2 points
    // Basic events: 2 * 3 = 6
    expect(total, 5 + 20 + 6 + 4 + 6 + 3 + 3 + 2 + 1 + 2 + 3 + 2);
  });

  test('resource points use floor division', () {
    final score = PlayerScore(
      playerId: 'p1',
      playerName: 'Ada',
      leftoverBerries: 2,
      leftoverResin: 1,
      leftoverPebbles: 0,
      leftoverWood: 0,
      totalScore: 0,
      tiebreakerResources: 0,
      isWinner: false,
      isQuickEntry: false,
    );

    expect(ScoreCalculator.calculateResourcePoints(score), 1);
    expect(ScoreCalculator.calculateTiebreakerResources(score), 3);
  });

  test('determineTopPlayers resolves tiebreaker', () {
    final a = PlayerScore(
      playerId: 'a',
      playerName: 'A',
      totalScore: 10,
      tiebreakerResources: 4,
      isWinner: false,
      isQuickEntry: true,
    );
    final b = PlayerScore(
      playerId: 'b',
      playerName: 'B',
      totalScore: 10,
      tiebreakerResources: 2,
      isWinner: false,
      isQuickEntry: true,
    );

    final top = ScoreCalculator.determineTopPlayers([a, b]);
    expect(top.length, 1);
    expect(top.first.playerId, 'a');
  });
}
