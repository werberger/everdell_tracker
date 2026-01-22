import 'package:flutter/material.dart';
import '../models/player_score.dart';
import '../models/everdell_card.dart';
import '../screens/card_selection_screen_example.dart';
import '../services/card_service.dart';

class CardSelectionHelper {
  /// Navigate to card selection screen and return the result
  static Future<Map<String, dynamic>?> selectCards(BuildContext context) async {
    return await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const CardSelectionScreenExample(),
      ),
    );
  }

  /// Create a PlayerScore from card selection results
  static PlayerScore createPlayerScoreFromCards({
    required String playerId,
    required String playerName,
    required List<String> selectedCardIds,
    required int totalScore,
    required int tiebreakerResources,
    required bool isWinner,
    Map<String, int>? tokenCounts,
    Map<String, int>? resourceCounts,
    int? basicEvents,
    int? specialEvents,
    int? journeyPoints,
    int? playerOrder,
  }) {
    return PlayerScore(
      playerId: playerId,
      playerName: playerName,
      totalScore: totalScore,
      tiebreakerResources: tiebreakerResources,
      isWinner: isWinner,
      isQuickEntry: false,
      selectedCardIds: selectedCardIds,
      cardTokenCounts: tokenCounts,
      cardResourceCounts: resourceCounts,
      basicEvents: basicEvents,
      specialEvents: specialEvents,
      journeyPoints: journeyPoints,
      playerOrder: playerOrder,
      // Set cardPoints to the calculated score for compatibility
      cardPoints: totalScore - 
          ((basicEvents ?? 0) * 1) - 
          ((specialEvents ?? 0) * 3) - 
          (journeyPoints ?? 0),
    );
  }

  /// Calculate score from selected cards and additional inputs
  static Future<int> calculateScore({
    required List<String> selectedCardIds,
    Map<String, int>? tokenCounts,
    Map<String, int>? resourceCounts,
    int? basicEvents,
    int? specialEvents,
  }) async {
    final allCards = await CardService.loadCards();
    final selectedCards = allCards
        .where((card) => selectedCardIds.contains(card.id))
        .toList();

    return CardService.calculateTotalPoints(
      selectedCards,
      tokenCounts: tokenCounts,
      resourceCounts: resourceCounts,
      basicEvents: basicEvents,
      specialEvents: specialEvents,
    );
  }

  /// Get card names from IDs for display
  static Future<List<String>> getCardNames(List<String> cardIds) async {
    final cards = await Future.wait(
      cardIds.map((id) => CardService.getCardById(id)),
    );
    return cards
        .where((card) => card != null)
        .map((card) => card!.name)
        .toList();
  }

  /// Get breakdown of selected cards by type
  static Future<Map<String, int>> getCardTypeBreakdown(
    List<String> cardIds,
  ) async {
    final allCards = await CardService.loadCards();
    final selectedCards = allCards
        .where((card) => cardIds.contains(card.id))
        .toList();

    return {
      'constructions': selectedCards
          .where((c) => c.type == CardType.construction)
          .length,
      'critters': selectedCards.where((c) => c.type == CardType.critter).length,
      'production': selectedCards
          .where((c) => c.cardColor == CardColor.production)
          .length,
      'destination': selectedCards
          .where((c) => c.cardColor == CardColor.destination)
          .length,
      'governance': selectedCards
          .where((c) => c.cardColor == CardColor.governance)
          .length,
      'traveller': selectedCards
          .where((c) => c.cardColor == CardColor.traveller)
          .length,
      'prosperity': selectedCards
          .where((c) => c.cardColor == CardColor.prosperity)
          .length,
    };
  }

  /// Check if a player score uses visual card selection
  static bool isVisualCardSelection(PlayerScore score) {
    return score.selectedCardIds != null &&
        score.selectedCardIds!.isNotEmpty;
  }

  /// Get a summary string of selected cards for display
  static Future<String> getCardSelectionSummary(PlayerScore score) async {
    if (!isVisualCardSelection(score)) {
      return 'Manual scoring';
    }

    final cardCount = score.selectedCardIds!.length;
    final breakdown = await getCardTypeBreakdown(score.selectedCardIds!);

    return '$cardCount cards (${breakdown['constructions']} constructions, ${breakdown['critters']} critters)';
  }
}
