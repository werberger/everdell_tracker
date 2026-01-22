import 'package:flutter/material.dart';

import '../models/game.dart';
import '../services/platform_storage_service.dart';

class GameProvider extends ChangeNotifier {
  List<Game> _games = [];

  List<Game> get games => List.unmodifiable(_games);

  Future<void> loadGames() async {
    _games = await PlatformStorageService.getAllGames();
    notifyListeners();
  }

  Future<void> addGame(Game game) async {
    await PlatformStorageService.saveGame(game);
    _games = await PlatformStorageService.getAllGames();
    notifyListeners();
  }

  Future<void> updateGame(Game game) async {
    await PlatformStorageService.updateGame(game);
    _games = await PlatformStorageService.getAllGames();
    notifyListeners();
  }

  Future<void> deleteGame(String id) async {
    await PlatformStorageService.deleteGame(id);
    _games = await PlatformStorageService.getAllGames();
    notifyListeners();
  }

  Future<void> addGames(List<Game> games) async {
    for (final game in games) {
      await PlatformStorageService.saveGame(game);
    }
    _games = await PlatformStorageService.getAllGames();
    notifyListeners();
  }
}
