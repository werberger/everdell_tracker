import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/expansion.dart';
import '../models/game.dart';
import '../models/player_score.dart';

enum MergeStrategy { skip, overwrite, keepBoth }

class ImportResult {
  final List<Game> newGames;
  final List<Game> duplicates;

  const ImportResult({
    required this.newGames,
    required this.duplicates,
  });
}

class ExportService {
  static const int _schemaVersion = 1;

  static String exportGames(List<Game> games) {
    final payload = {
      'version': _schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'games': games.map(_gameToJson).toList(),
    };
    return jsonEncode(payload);
  }

  static Future<void> shareExport(String json) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/everdell_export.json');
    await file.writeAsString(json);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Everdell Tracker export',
    );
  }

  static Future<String?> pickImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    final filePath = result.files.single.path;
    if (filePath == null) {
      return null;
    }
    return File(filePath).readAsString();
  }

  static ImportResult parseImport(String json, List<Game> existingGames) {
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    final gamesData = decoded['games'] as List<dynamic>? ?? [];
    final incoming = gamesData.map((game) {
      return _gameFromJson(game as Map<String, dynamic>);
    }).toList();

    final existingIds = existingGames.map((game) => game.id).toSet();
    final newGames = <Game>[];
    final duplicates = <Game>[];

    for (final game in incoming) {
      if (existingIds.contains(game.id)) {
        duplicates.add(game);
      } else {
        newGames.add(game);
      }
    }

    return ImportResult(newGames: newGames, duplicates: duplicates);
  }

  static List<Game> mergeDuplicates(
    List<Game> duplicates,
    MergeStrategy strategy,
  ) {
    if (strategy == MergeStrategy.skip) {
      return [];
    }
    if (strategy == MergeStrategy.overwrite) {
      return duplicates;
    }
    return duplicates.map((game) {
      return Game(
        id: '${game.id}_${DateTime.now().millisecondsSinceEpoch}',
        dateTime: game.dateTime,
        expansionsUsed: game.expansionsUsed,
        players: game.players,
        notes: game.notes,
        winnerIds: game.winnerIds,
      );
    }).toList();
  }

  static Map<String, dynamic> _gameToJson(Game game) {
    return {
      'id': game.id,
      'dateTime': game.dateTime.toIso8601String(),
      'expansionsUsed': game.expansionsUsed.map((e) => e.name).toList(),
      'players': game.players.map(_playerToJson).toList(),
      'notes': game.notes,
      'winnerIds': game.winnerIds,
    };
  }

  static Map<String, dynamic> _playerToJson(PlayerScore score) {
    return {
      'playerId': score.playerId,
      'playerName': score.playerName,
      'pointTokens': score.pointTokens,
      'cardPoints': score.cardPoints,
      'basicEvents': score.basicEvents,
      'specialEvents': score.specialEvents,
      'prosperityPoints': score.prosperityPoints,
      'journeyPoints': score.journeyPoints,
      'leftoverBerries': score.leftoverBerries,
      'leftoverResin': score.leftoverResin,
      'leftoverPebbles': score.leftoverPebbles,
      'leftoverWood': score.leftoverWood,
      'pearlPoints': score.pearlPoints,
      'wonderPoints': score.wonderPoints,
      'weatherPoints': score.weatherPoints,
      'garlandPoints': score.garlandPoints,
      'ticketPoints': score.ticketPoints,
      'totalScore': score.totalScore,
      'tiebreakerResources': score.tiebreakerResources,
      'isWinner': score.isWinner,
      'isQuickEntry': score.isQuickEntry,
      'playerOrder': score.playerOrder,
      'startingCards': score.startingCards,
      'constructionPoints': score.constructionPoints,
      'critterPoints': score.critterPoints,
      'productionPoints': score.productionPoints,
      'destinationPoints': score.destinationPoints,
      'governancePoints': score.governancePoints,
      'travellerPoints': score.travellerPoints,
      'prosperityCardPoints': score.prosperityCardPoints,
      'selectedCardIds': score.selectedCardIds,
      'cardTokenCounts': score.cardTokenCounts,
      'cardResourceCounts': score.cardResourceCounts,
    };
  }

  static Game _gameFromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      expansionsUsed: (json['expansionsUsed'] as List<dynamic>? ?? [])
          .map((e) => Expansion.values.byName(e as String))
          .toList(),
      players: (json['players'] as List<dynamic>)
          .map((p) => _playerFromJson(p as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      winnerIds: (json['winnerIds'] as List<dynamic>? ?? [])
          .map((id) => id as String)
          .toList(),
    );
  }

  static PlayerScore _playerFromJson(Map<String, dynamic> json) {
    return PlayerScore(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      pointTokens: json['pointTokens'] as int?,
      cardPoints: json['cardPoints'] as int?,
      basicEvents: json['basicEvents'] as int?,
      specialEvents: json['specialEvents'] as int?,
      prosperityPoints: json['prosperityPoints'] as int?,
      journeyPoints: json['journeyPoints'] as int?,
      leftoverBerries: json['leftoverBerries'] as int?,
      leftoverResin: json['leftoverResin'] as int?,
      leftoverPebbles: json['leftoverPebbles'] as int?,
      leftoverWood: json['leftoverWood'] as int?,
      pearlPoints: json['pearlPoints'] as int?,
      wonderPoints: json['wonderPoints'] as int?,
      weatherPoints: json['weatherPoints'] as int?,
      garlandPoints: json['garlandPoints'] as int?,
      ticketPoints: json['ticketPoints'] as int?,
      totalScore: json['totalScore'] as int,
      tiebreakerResources: json['tiebreakerResources'] as int,
      isWinner: json['isWinner'] as bool? ?? false,
      isQuickEntry: json['isQuickEntry'] as bool? ?? false,
      playerOrder: json['playerOrder'] as int?,
      startingCards: json['startingCards'] as int?,
      constructionPoints: json['constructionPoints'] as int?,
      critterPoints: json['critterPoints'] as int?,
      productionPoints: json['productionPoints'] as int?,
      destinationPoints: json['destinationPoints'] as int?,
      governancePoints: json['governancePoints'] as int?,
      travellerPoints: json['travellerPoints'] as int?,
      prosperityCardPoints: json['prosperityCardPoints'] as int?,
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
