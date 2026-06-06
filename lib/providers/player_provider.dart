import 'package:flutter/material.dart';

import '../models/everdell_player.dart';
import '../services/everdell_api/everdell_api_exception.dart';
import '../services/everdell_api/everdell_api_service.dart';

class PlayerProvider extends ChangeNotifier {
  PlayerProvider({EverdellApiService? api}) : _api = api ?? EverdellApiService();

  final EverdellApiService _api;

  List<EverdellPlayer> _roster = [];
  bool _loading = false;
  String? _errorMessage;
  String? _activeGroupId;

  List<EverdellPlayer> get roster => List.unmodifiable(_roster);
  List<String> get playerNames =>
      _roster.map((player) => player.displayName).toList();
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRoster(String groupId) async {
    _activeGroupId = groupId;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _roster = await _api.listPlayers(groupId);
    } on EverdellApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load players.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearRoster() {
    _roster = [];
    _activeGroupId = null;
    _errorMessage = null;
    notifyListeners();
  }

  EverdellPlayer? findByDisplayName(String name) {
    final query = name.trim().toLowerCase();
    if (query.isEmpty) {
      return null;
    }
    for (final player in _roster) {
      if (player.displayName.toLowerCase() == query ||
          player.name.toLowerCase() == query) {
        return player;
      }
    }
    return null;
  }

  EverdellPlayer? findById(String id) {
    for (final player in _roster) {
      if (player.id == id) {
        return player;
      }
    }
    return null;
  }

  Future<EverdellPlayer> ensurePlayer(String groupId, String name) async {
    final trimmed = name.trim();
    final existing = findByDisplayName(trimmed);
    if (existing != null) {
      return existing;
    }

    final created = await _api.createPlayer(groupId, name: trimmed);
    if (_activeGroupId == groupId) {
      _roster = [..._roster, created]
        ..sort((a, b) => a.displayName.compareTo(b.displayName));
      notifyListeners();
    }
    return created;
  }

  Future<void> ensurePlayersFromGame(
    String groupId,
    Iterable<String> names,
  ) async {
    for (final name in names) {
      if (name.trim().isEmpty) {
        continue;
      }
      await ensurePlayer(groupId, name);
    }
  }
}
