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

  // Visual card selection data (for future player stats)
  @HiveField(30)
  final List<String>? selectedCardIds;

  @HiveField(31)
  final Map<String, int>? cardTokenCounts;

  @HiveField(32)
  final Map<String, int>? cardResourceCounts;

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
    this.selectedCardIds,
    this.cardTokenCounts,
    this.cardResourceCounts,
  });

  // JSON serialization for web compatibility
  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'pointTokens': pointTokens,
      'cardPoints': cardPoints,
      'basicEvents': basicEvents,
      'specialEvents': specialEvents,
      'prosperityPoints': prosperityPoints,
      'journeyPoints': journeyPoints,
      'leftoverBerries': leftoverBerries,
      'leftoverResin': leftoverResin,
      'leftoverPebbles': leftoverPebbles,
      'leftoverWood': leftoverWood,
      'pearlPoints': pearlPoints,
      'wonderPoints': wonderPoints,
      'weatherPoints': weatherPoints,
      'garlandPoints': garlandPoints,
      'ticketPoints': ticketPoints,
      'totalScore': totalScore,
      'tiebreakerResources': tiebreakerResources,
      'isWinner': isWinner,
      'isQuickEntry': isQuickEntry,
      'playerOrder': playerOrder,
      'startingCards': startingCards,
      'constructionPoints': constructionPoints,
      'critterPoints': critterPoints,
      'productionPoints': productionPoints,
      'destinationPoints': destinationPoints,
      'governancePoints': governancePoints,
      'travellerPoints': travellerPoints,
      'prosperityCardPoints': prosperityCardPoints,
      'selectedCardIds': selectedCardIds,
      'cardTokenCounts': cardTokenCounts,
      'cardResourceCounts': cardResourceCounts,
    };
  }

  factory PlayerScore.fromJson(Map<String, dynamic> json) {
    return PlayerScore(
      playerId: json['playerId'],
      playerName: json['playerName'],
      pointTokens: json['pointTokens'],
      cardPoints: json['cardPoints'],
      basicEvents: json['basicEvents'],
      specialEvents: json['specialEvents'],
      prosperityPoints: json['prosperityPoints'],
      journeyPoints: json['journeyPoints'],
      leftoverBerries: json['leftoverBerries'],
      leftoverResin: json['leftoverResin'],
      leftoverPebbles: json['leftoverPebbles'],
      leftoverWood: json['leftoverWood'],
      pearlPoints: json['pearlPoints'],
      wonderPoints: json['wonderPoints'],
      weatherPoints: json['weatherPoints'],
      garlandPoints: json['garlandPoints'],
      ticketPoints: json['ticketPoints'],
      totalScore: json['totalScore'],
      tiebreakerResources: json['tiebreakerResources'],
      isWinner: json['isWinner'],
      isQuickEntry: json['isQuickEntry'],
      playerOrder: json['playerOrder'],
      startingCards: json['startingCards'],
      constructionPoints: json['constructionPoints'],
      critterPoints: json['critterPoints'],
      productionPoints: json['productionPoints'],
      destinationPoints: json['destinationPoints'],
      governancePoints: json['governancePoints'],
      travellerPoints: json['travellerPoints'],
      prosperityCardPoints: json['prosperityCardPoints'],
      selectedCardIds: json['selectedCardIds'] != null
          ? List<String>.from(json['selectedCardIds'])
          : null,
      cardTokenCounts: json['cardTokenCounts'] != null
          ? Map<String, int>.from(json['cardTokenCounts'])
          : null,
      cardResourceCounts: json['cardResourceCounts'] != null
          ? Map<String, int>.from(json['cardResourceCounts'])
          : null,
    );
  }
}
