import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/game.dart';
import '../models/app_settings.dart';
import 'storage_service.dart';
import 'web_storage_service.dart';

/// Platform-agnostic storage service
/// Automatically uses WebStorageService for web, StorageService for mobile
class PlatformStorageService {
  static Future<void> initialize() async {
    if (kIsWeb) {
      await WebStorageService.initialize();
    } else {
      await StorageService.initialize();
      await StorageService.registerAdapters();
      await StorageService.openBoxes();
    }
  }

  static Future<List<Game>> getAllGames() async {
    if (kIsWeb) {
      return await WebStorageService.getAllGames();
    } else {
      return await StorageService.getAllGames();
    }
  }

  static Future<Game?> getGame(String id) async {
    if (kIsWeb) {
      return await WebStorageService.getGame(id);
    } else {
      return await StorageService.getGame(id);
    }
  }

  static Future<void> saveGame(Game game) async {
    if (kIsWeb) {
      await WebStorageService.saveGame(game);
    } else {
      await StorageService.saveGame(game);
    }
  }

  static Future<void> updateGame(Game game) async {
    if (kIsWeb) {
      await WebStorageService.updateGame(game);
    } else {
      await StorageService.updateGame(game);
    }
  }

  static Future<void> deleteGame(String id) async {
    if (kIsWeb) {
      await WebStorageService.deleteGame(id);
    } else {
      await StorageService.deleteGame(id);
    }
  }

  static Future<AppSettings> getSettings() async {
    if (kIsWeb) {
      return await WebStorageService.getSettings();
    } else {
      return await StorageService.getSettings();
    }
  }

  static Future<void> saveSettings(AppSettings settings) async {
    if (kIsWeb) {
      await WebStorageService.saveSettings(settings);
    } else {
      await StorageService.saveSettings(settings);
    }
  }

  static Future<void> addPlayerName(String name) async {
    if (kIsWeb) {
      await WebStorageService.addPlayerName(name);
    } else {
      await StorageService.addPlayerName(name);
    }
  }

  static List<String> getPlayerNames() {
    if (kIsWeb) {
      return WebStorageService.getPlayerNames();
    } else {
      return StorageService.getPlayerNames();
    }
  }
}
