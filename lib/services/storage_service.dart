import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings.dart';
import '../models/game.dart';
import '../models/player_score.dart';
import '../models/expansion.dart';
import '../utils/constants.dart';

class StorageService {
  static Future<void> initialize() async {
    await Hive.initFlutter();
  }

  static Future<void> registerAdapters() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GameAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PlayerScoreAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ExpansionAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
  }

  static Future<void> openBoxes() async {
    await Hive.openBox<Game>(gamesBoxName);
    await Hive.openBox<AppSettings>(settingsBoxName);
    await Hive.openBox<String>(playerNamesBoxName);
  }

  static Box<Game> gamesBox() => Hive.box<Game>(gamesBoxName);

  static Box<AppSettings> settingsBox() =>
      Hive.box<AppSettings>(settingsBoxName);

  static Box<String> playerNamesBox() =>
      Hive.box<String>(playerNamesBoxName);

  static Future<List<Game>> getAllGames() async {
    return gamesBox().values.toList();
  }

  static Future<Game?> getGame(String id) async {
    return gamesBox().get(id);
  }

  static Future<void> saveGame(Game game) async {
    await gamesBox().put(game.id, game);
  }

  static Future<void> updateGame(Game game) async {
    await gamesBox().put(game.id, game);
  }

  static Future<void> deleteGame(String id) async {
    await gamesBox().delete(id);
  }

  static Future<AppSettings> getSettings() async {
    final box = settingsBox();
    final existing = box.get(settingsKey);
    if (existing != null) {
      return existing;
    }
    final defaults = AppSettings.defaults();
    await box.put(settingsKey, defaults);
    return defaults;
  }

  static Future<void> saveSettings(AppSettings settings) async {
    await settingsBox().put(settingsKey, settings);
  }

  static Future<void> addPlayerName(String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      return;
    }
    await playerNamesBox().put(normalized.toLowerCase(), normalized);
  }

  static List<String> getPlayerNames() {
    final names = playerNamesBox().values.toList();
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }
}
