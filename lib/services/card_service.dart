import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/everdell_card.dart';

class CardService {
  static List<EverdellCard>? _cachedCards;

  /// Load all cards from JSON file
  static Future<List<EverdellCard>> loadCards() async {
    if (_cachedCards != null) {
      return _cachedCards!;
    }

    final String jsonString =
        await rootBundle.loadString('assets/cards_data.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    _cachedCards = jsonList
        .map((json) => EverdellCard.fromJson(json as Map<String, dynamic>))
        .toList();

    return _cachedCards!;
  }

  /// Get cards filtered by module (base, extra, rugwort, etc.)
  static Future<List<EverdellCard>> getCardsByModule(String module) async {
    final cards = await loadCards();
    return cards.where((card) => card.module == module).toList();
  }

  /// Get base game cards only
  static Future<List<EverdellCard>> getBaseGameCards() async {
    return getCardsByModule('base');
  }

  /// Get cards by type (construction or critter)
  static Future<List<EverdellCard>> getCardsByType(CardType type) async {
    final cards = await loadCards();
    return cards.where((card) => card.type == type).toList();
  }

  /// Get cards by color
  static Future<List<EverdellCard>> getCardsByColor(CardColor color) async {
    final cards = await loadCards();
    return cards.where((card) => card.cardColor == color).toList();
  }

  /// Get cards grouped by color
  static Future<Map<CardColor, List<EverdellCard>>> getCardsGroupedByColor({
    String? module,
  }) async {
    List<EverdellCard> cards;
    if (module != null) {
      cards = await getCardsByModule(module);
    } else {
      cards = await loadCards();
    }

    final Map<CardColor, List<EverdellCard>> grouped = {};

    for (final color in CardColor.values) {
      grouped[color] = cards.where((card) => card.cardColor == color).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }

    return grouped;
  }

  /// Search cards by name
  static Future<List<EverdellCard>> searchCards(String query) async {
    final cards = await loadCards();
    final lowerQuery = query.toLowerCase();
    return cards
        .where((card) => card.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get a specific card by ID
  static Future<EverdellCard?> getCardById(String id) async {
    final cards = await loadCards();
    try {
      return cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Calculate total points for selected cards
  static int calculateTotalPoints(
    List<EverdellCard> selectedCards, {
    Map<String, int>? tokenCounts,
    Map<String, int>? resourceCounts,
    int? basicEvents,
    int? specialEvents,
  }) {
    int total = 0;

    // Track card types for conditional scoring
    final uniqueConstructions =
        selectedCards.where((c) => c.type == CardType.construction && c.rarity == CardRarity.unique).length;
    final commonConstructions =
        selectedCards.where((c) => c.type == CardType.construction && c.rarity == CardRarity.common).length;
    final uniqueCritters =
        selectedCards.where((c) => c.type == CardType.critter && c.rarity == CardRarity.unique).length;
    final commonCritters =
        selectedCards.where((c) => c.type == CardType.critter && c.rarity == CardRarity.common).length;
    final prosperityCards =
        selectedCards.where((c) => c.cardColor == CardColor.prosperity).length;

    // Track paired cards
    final selectedIds = selectedCards.map((c) => c.id).toSet();

    for (final card in selectedCards) {
      // Add base points
      total += card.basePoints;

      // Add conditional scoring
      if (card.conditionalScoring != null) {
        final scoring = card.conditionalScoring!;

        switch (scoring.type) {
          case ConditionalScoringType.resourceCount:
            // For Architect: pebbles + resin
            final count = resourceCounts?['pebbles_resin'] ?? 0;
            total += scoring.calculateBonus(resourceCount: count);
            break;

          case ConditionalScoringType.cardTypeCount:
            final countType = scoring.calculationData['countType'] as String;
            int cardCount = 0;

            if (countType == 'unique_constructions') {
              cardCount = uniqueConstructions;
            } else if (countType == 'common_constructions') {
              cardCount = commonConstructions;
            } else if (countType == 'unique_critters') {
              cardCount = uniqueCritters;
            } else if (countType == 'common_critters') {
              cardCount = commonCritters;
            } else if (countType == 'prosperity_cards') {
              cardCount = prosperityCards;
            }

            total += scoring.calculateBonus(cardCount: cardCount);
            break;

          case ConditionalScoringType.cardPairing:
            // Check if paired card is in city
            final pairedId = scoring.calculationData['pairedCardId'] as String;
            final isPaired = selectedIds.contains(pairedId);
            total += scoring.calculateBonus(isPaired: isPaired);
            break;

          case ConditionalScoringType.tokenPlacement:
            // Use provided token count for this card
            final tokens = tokenCounts?[card.id] ?? 0;
            total += scoring.calculateBonus(tokenCount: tokens);
            break;

          case ConditionalScoringType.eventCount:
            total += scoring.calculateBonus(
              basicEvents: basicEvents,
              specialEvents: specialEvents,
            );
            break;

          case ConditionalScoringType.simple:
            // No bonus
            break;
        }
      }
    }

    return total;
  }
}
