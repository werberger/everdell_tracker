import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';
import '../models/app_settings.dart';
import '../utils/constants.dart';

/// Web-compatible storage service using SharedPreferences
/// Used when running on web platform
class WebStorageService {
  static const String _gamesKey = 'everdell_games';
  static const String _settingsKey = 'everdell_settings';
  static const String _playerNamesKey = 'everdell_player_names';

  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('WebStorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // Games
  static Future<List<Game>> getAllGames() async {
    final jsonString = prefs.getString(_gamesKey);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Game.fromJson(json)).toList();
    } catch (e) {
      print('Error loading games: $e');
      return [];
    }
  }

  static Future<Game?> getGame(String id) async {
    final games = await getAllGames();
    try {
      return games.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveGame(Game game) async {
    final games = await getAllGames();
    final index = games.indexWhere((g) => g.id == game.id);
    
    if (index >= 0) {
      games[index] = game;
    } else {
      games.add(game);
    }
    
    final jsonString = json.encode(games.map((g) => g.toJson()).toList());
    await prefs.setString(_gamesKey, jsonString);
  }

  static Future<void> updateGame(Game game) async {
    await saveGame(game);
  }

  static Future<void> deleteGame(String id) async {
    final games = await getAllGames();
    games.removeWhere((game) => game.id == id);
    
    final jsonString = json.encode(games.map((g) => g.toJson()).toList());
    await prefs.setString(_gamesKey, jsonString);
  }

  // Settings
  static Future<AppSettings> getSettings() async {
    final jsonString = prefs.getString(_settingsKey);
    
    if (jsonString != null) {
      try {
        final jsonMap = json.decode(jsonString);
        return AppSettings.fromJson(jsonMap);
      } catch (e) {
        print('Error loading settings: $e');
      }
    }
    
    final defaults = AppSettings.defaults();
    await saveSettings(defaults);
    return defaults;
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final jsonString = json.encode(settings.toJson());
    await prefs.setString(_settingsKey, jsonString);
  }

  // Player names
  static Future<void> addPlayerName(String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty) return;
    
    final names = getPlayerNames();
    final key = normalized.toLowerCase();
    
    if (!names.any((n) => n.toLowerCase() == key)) {
      names.add(normalized);
      final jsonString = json.encode(names);
      await prefs.setString(_playerNamesKey, jsonString);
    }
  }

  static List<String> getPlayerNames() {
    final jsonString = prefs.getString(_playerNamesKey);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final names = jsonList.map((e) => e.toString()).toList();
      names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return names;
    } catch (e) {
      print('Error loading player names: $e');
      return [];
    }
  }

  // Clear all data (useful for testing)
  static Future<void> clearAll() async {
    await prefs.remove(_gamesKey);
    await prefs.remove(_settingsKey);
    await prefs.remove(_playerNamesKey);
  }
}
