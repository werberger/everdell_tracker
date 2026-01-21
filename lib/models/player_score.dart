import 'package:hive/hive.dart';

part 'player_score.g.dart';

@HiveType(typeId: 1)
class PlayerScore extends HiveObject {
  @HiveField(0)
  final String playerId;

  @HiveField(1)
  final String playerName;

  // Base scoring
  @HiveField(2)
  final int? pointTokens;

  @HiveField(3)
  final int? cardPoints;

  @HiveField(4)
  final int? basicEvents;

  @HiveField(5)
  final int? specialEvents;

  @HiveField(6)
  final int? prosperityPoints;

  @HiveField(7)
  final int? journeyPoints;

  // Resources
  @HiveField(8)
  final int? leftoverBerries;

  @HiveField(9)
  final int? leftoverResin;

  @HiveField(10)
  final int? leftoverPebbles;

  @HiveField(11)
  final int? leftoverWood;

  // Expansion-specific
  @HiveField(12)
  final int? pearlPoints;

  @HiveField(13)
  final int? wonderPoints;

  @HiveField(14)
  final int? weatherPoints;

  @HiveField(15)
  final int? garlandPoints;

  @HiveField(16)
  final int? ticketPoints;

  @HiveField(17)
  final int totalScore;

  @HiveField(18)
  final int tiebreakerResources;

  @HiveField(19)
  final bool isWinner;

  @HiveField(20)
  final bool isQuickEntry;

  @HiveField(21)
  final int? playerOrder;

  @HiveField(22)
  final int? startingCards;

  // Card entry by type
  @HiveField(23)
  final int? constructionPoints;

  @HiveField(24)
  final int? critterPoints;

  // Card entry by color
  @HiveField(25)
  final int? productionPoints; // Green

  @HiveField(26)
  final int? destinationPoints; // Red

  @HiveField(27)
  final int? governancePoints; // Blue

  @HiveField(28)
  final int? travellerPoints; // Tan

  @HiveField(29)
  final int? prosperityCardPoints; // Purple (base card points)

  PlayerScore({
    required this.playerId,
    required this.playerName,
    this.pointTokens,
    this.cardPoints,
    this.basicEvents,
    this.specialEvents,
    this.prosperityPoints,
    this.journeyPoints,
    this.leftoverBerries,
    this.leftoverResin,
    this.leftoverPebbles,
    this.leftoverWood,
    this.pearlPoints,
    this.wonderPoints,
    this.weatherPoints,
    this.garlandPoints,
    this.ticketPoints,
    required this.totalScore,
    required this.tiebreakerResources,
    required this.isWinner,
    required this.isQuickEntry,
    this.playerOrder,
    this.startingCards,
    this.constructionPoints,
    this.critterPoints,
    this.productionPoints,
    this.destinationPoints,
    this.governancePoints,
    this.travellerPoints,
    this.prosperityCardPoints,
  });
}
