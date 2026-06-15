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

  /// Autocomplete labels — adds short id when names collide.
  List<String> get pickerSuggestions =>
      _roster.map((player) => player.pickerLabel(_roster)).toList();

  EverdellPlayer? get myPlayer {
    for (final player in _roster) {
      if (player.isLinkedToMe) {
        return player;
      }
    }
    return null;
  }

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

  /// Match autocomplete selection (may include · AB12 suffix).
  EverdellPlayer? findByPickerLabel(String label) {
    final query = label.trim();
    if (query.isEmpty) {
      return null;
    }
    for (final player in _roster) {
      if (player.pickerLabel(_roster) == query) {
        return player;
      }
    }
    // Fallback: strip disambiguator suffix " · XXXX"
    final base = query.replaceFirst(RegExp(r'\s·\s[A-Z0-9]{4}$'), '');
    return findByDisplayName(base);
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
    final existing = findByPickerLabel(trimmed) ?? findByDisplayName(trimmed);
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

  Future<EverdellPlayer?> updateMyNickname(
    String groupId,
    String nickname, {
    String? displayNameSource,
  }) async {
    final mine = myPlayer;
    if (mine == null) {
      return null;
    }
    final updated = await _api.patchPlayer(
      groupId,
      mine.id,
      nickname: nickname,
      displayNameSource: displayNameSource,
    );
    if (_activeGroupId == groupId) {
      _roster = _roster
          .map((p) => p.id == updated.id ? updated : p)
          .toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName));
      notifyListeners();
    }
    return updated;
  }
}
