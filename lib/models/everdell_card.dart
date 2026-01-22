import 'package:hive/hive.dart';

part 'everdell_card.g.dart';

enum CardType { critter, construction }

enum CardColor {
  production, // Green
  destination, // Red
  governance, // Blue
  traveller, // Tan
  prosperity // Purple
}

enum CardRarity { common, unique, legendary }

enum ConditionalScoringType {
  resourceCount, // Architect: pebbles + resin
  cardTypeCount, // Palace: unique constructions, School: common critters, etc.
  cardPairing, // Wife/Husband
  tokenPlacement, // Clock Tower, Chapel
  eventCount, // King: basic and special events
  simple // No conditional scoring
}

@HiveType(typeId: 10)
class EverdellCard extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final CardType type;

  @HiveField(3)
  final CardColor cardColor;

  @HiveField(4)
  final CardRarity rarity;

  @HiveField(5)
  final int basePoints;

  @HiveField(6)
  final String imagePath;

  @HiveField(7)
  final String? pairedWith;

  @HiveField(8)
  final ConditionalScoring? conditionalScoring;

  @HiveField(9)
  final String module; // "base", "extra", "rugwort", etc.

  @HiveField(10)
  final bool hasImage;

  @HiveField(11)
  final bool countsTowardCitySize; // False for Wanderer, Ruins

  @HiveField(12)
  final bool canShareSpace; // True for Husband/Wife when paired

  EverdellCard({
    required this.id,
    required this.name,
    required this.type,
    required this.cardColor,
    required this.rarity,
    required this.basePoints,
    required this.imagePath,
    this.pairedWith,
    this.conditionalScoring,
    this.module = 'base',
    this.hasImage = true,
    this.countsTowardCitySize = true,
    this.canShareSpace = false,
  });

  factory EverdellCard.fromJson(Map<String, dynamic> json) {
    return EverdellCard(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CardType.values.firstWhere(
        (e) => e.toString() == 'CardType.${json['type']}',
      ),
      cardColor: CardColor.values.firstWhere(
        (e) => e.toString() == 'CardColor.${json['cardColor']}',
      ),
      rarity: CardRarity.values.firstWhere(
        (e) => e.toString() == 'CardRarity.${json['rarity']}',
      ),
      basePoints: json['basePoints'] as int,
      imagePath: json['imagePath'] as String,
      pairedWith: json['pairedWith'] as String?,
      conditionalScoring: json['conditionalScoring'] != null
          ? ConditionalScoring.fromJson(
              json['conditionalScoring'] as Map<String, dynamic>)
          : null,
      module: json['module'] as String? ?? 'base',
      hasImage: json['hasImage'] as bool? ?? true,
      countsTowardCitySize: json['countsTowardCitySize'] as bool? ?? true,
      canShareSpace: json['canShareSpace'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'cardColor': cardColor.toString().split('.').last,
      'rarity': rarity.toString().split('.').last,
      'basePoints': basePoints,
      'imagePath': imagePath,
      'pairedWith': pairedWith,
      'conditionalScoring': conditionalScoring?.toJson(),
      'module': module,
      'hasImage': hasImage,
      'countsTowardCitySize': countsTowardCitySize,
      'canShareSpace': canShareSpace,
    };
  }
}

@HiveType(typeId: 11)
class ConditionalScoring extends HiveObject {
  @HiveField(0)
  final ConditionalScoringType type;

  @HiveField(1)
  final String? userPrompt;

  @HiveField(2)
  final Map<String, dynamic> calculationData;

  ConditionalScoring({
    required this.type,
    this.userPrompt,
    required this.calculationData,
  });

  factory ConditionalScoring.fromJson(Map<String, dynamic> json) {
    return ConditionalScoring(
      type: ConditionalScoringType.values.firstWhere(
        (e) => e.toString() == 'ConditionalScoringType.${json['type']}',
      ),
      userPrompt: json['userPrompt'] as String?,
      calculationData: json['calculation'] != null
          ? Map<String, dynamic>.from(json['calculation'] as Map)
          : <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'userPrompt': userPrompt,
      'calculation': calculationData,
    };
  }

  /// Calculate bonus points based on the scoring type
  int calculateBonus({
    int? resourceCount,
    int? cardCount,
    bool? isPaired,
    int? tokenCount,
    int? basicEvents,
    int? specialEvents,
  }) {
    switch (type) {
      case ConditionalScoringType.resourceCount:
        final pointsPerResource = calculationData['pointsPerResource'] as int;
        final maxBonus = calculationData['maxBonus'] as int;
        final bonus = (resourceCount ?? 0) * pointsPerResource;
        return bonus > maxBonus ? maxBonus : bonus;

      case ConditionalScoringType.cardTypeCount:
        final pointsPerCard = calculationData['pointsPerCard'] as int;
        return (cardCount ?? 0) * pointsPerCard;

      case ConditionalScoringType.cardPairing:
        if (isPaired == true) {
          return calculationData['bonusPoints'] as int;
        }
        return 0;

      case ConditionalScoringType.tokenPlacement:
        return tokenCount ?? 0;

      case ConditionalScoringType.eventCount:
        final basicEventPoints = calculationData['pointsPerBasicEvent'] as int;
        final specialEventPoints =
            calculationData['pointsPerSpecialEvent'] as int;
        return ((basicEvents ?? 0) * basicEventPoints) +
            ((specialEvents ?? 0) * specialEventPoints);

      case ConditionalScoringType.simple:
        return 0;
    }
  }
}
