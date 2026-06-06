import 'package:flutter/material.dart';

import '../models/everdell_game_record.dart';
import '../models/game.dart';
import '../services/everdell_api/everdell_api_exception.dart';
import '../services/everdell_api/everdell_api_service.dart';

class GameProvider extends ChangeNotifier {
  GameProvider({EverdellApiService? api}) : _api = api ?? EverdellApiService();

  final EverdellApiService _api;

  List<Game> _games = [];
  final Map<String, DateTime> _serverUpdatedAt = {};
  bool _loading = false;
  String? _errorMessage;
  String? _activeGroupId;

  List<Game> get games => List.unmodifiable(_games);
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  String? get activeGroupId => _activeGroupId;

  DateTime? updatedAtFor(String gameId) => _serverUpdatedAt[gameId];

  Future<void> loadGames(String groupId) async {
    _activeGroupId = groupId;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final records = await _api.listGames(groupId);
      _applyRecords(records);
    } on EverdellApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load games.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearGames() {
    _games = [];
    _serverUpdatedAt.clear();
    _activeGroupId = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> addGame(String groupId, Game game) async {
    final record = await _api.createGame(groupId, game);
    _upsertRecord(record);
    notifyListeners();
  }

  Future<void> updateGame(String groupId, Game game) async {
    final updatedAt = _serverUpdatedAt[game.id];
    if (updatedAt == null) {
      throw EverdellApiException(
        'Missing server version for this game. Refresh and try again.',
      );
    }
    final record = await _api.updateGame(groupId, game.id, updatedAt, game);
    _upsertRecord(record);
    notifyListeners();
  }

  Future<void> deleteGame(String groupId, String id) async {
    await _api.deleteGame(groupId, id);
    _games.removeWhere((game) => game.id == id);
    _serverUpdatedAt.remove(id);
    notifyListeners();
  }

  Future<void> addGames(String groupId, List<Game> games) async {
    for (final game in games) {
      final record = await _api.createGame(groupId, game);
      _upsertRecord(record);
    }
    notifyListeners();
  }

  void applyRemoteGame(Map<String, dynamic> current) {
    final record = EverdellGameRecord.fromDetailJson(current);
    _upsertRecord(record);
    notifyListeners();
  }

  void _applyRecords(List<EverdellGameRecord> records) {
    _games = records.map((record) => record.game).toList();
    _serverUpdatedAt
      ..clear()
      ..addEntries(
        records.map((record) => MapEntry(record.id, record.updatedAt)),
      );
  }

  void _upsertRecord(EverdellGameRecord record) {
    final index = _games.indexWhere((game) => game.id == record.id);
    if (index >= 0) {
      _games[index] = record.game;
    } else {
      _games.add(record.game);
    }
    _serverUpdatedAt[record.id] = record.updatedAt;
    _games.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }
}
