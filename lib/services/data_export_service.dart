import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/game.dart';
import '../models/app_settings.dart';
import 'platform_storage_service.dart';

// Conditional import for web
import 'data_export_web.dart' if (dart.library.io) 'data_export_stub.dart' as web_helper;

/// Service for exporting and importing data
/// Works on both web and mobile platforms
class DataExportService {
  /// Export all games and settings to JSON
  static Future<Map<String, dynamic>> exportAllData() async {
    final games = await PlatformStorageService.getAllGames();
    final settings = await PlatformStorageService.getSettings();
    final playerNames = PlatformStorageService.getPlayerNames();

    return {
      'version': '2.1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'games': games.map((g) => g.toJson()).toList(),
      'settings': settings.toJson(),
      'playerNames': playerNames,
    };
  }

  /// Export data as JSON string
  static Future<String> exportAsJsonString() async {
    final data = await exportAllData();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Export data and download/share depending on platform
  static Future<void> exportData() async {
    try {
      final jsonString = await exportAsJsonString();
      final fileName = 'everdell_tracker_export_${DateTime.now().millisecondsSinceEpoch}.json';

      if (kIsWeb) {
        // Web: Download file
        web_helper.downloadFile(jsonString, fileName);
      } else {
        // Mobile: Share file
        await Share.share(
          jsonString,
          subject: 'Everdell Tracker Data Export',
        );
      }
    } catch (e) {
      print('Error exporting data: $e');
      rethrow;
    }
  }


  /// Import data from JSON string
  static Future<Map<String, dynamic>> importFromJsonString(String jsonString) async {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      // Validate version (optional - could add migration logic here)
      final version = data['version'] as String?;
      print('Importing data from version: $version');

      // Parse games
      final games = (data['games'] as List?)
          ?.map((g) => Game.fromJson(g as Map<String, dynamic>))
          .toList() ?? [];

      // Parse settings
      final settings = data['settings'] != null
          ? AppSettings.fromJson(data['settings'] as Map<String, dynamic>)
          : null;

      // Parse player names
      final playerNames = (data['playerNames'] as List?)
          ?.map((n) => n.toString())
          .toList() ?? [];

      return {
        'games': games,
        'settings': settings,
        'playerNames': playerNames,
      };
    } catch (e) {
      print('Error parsing import data: $e');
      rethrow;
    }
  }

  /// Import data and save to storage
  static Future<void> importData(String jsonString) async {
    try {
      final data = await importFromJsonString(jsonString);

      final games = data['games'] as List<Game>;
      final settings = data['settings'] as AppSettings?;
      final playerNames = data['playerNames'] as List<String>;

      // Save games
      for (final game in games) {
        await PlatformStorageService.saveGame(game);
      }

      // Save settings
      if (settings != null) {
        await PlatformStorageService.saveSettings(settings);
      }

      // Save player names
      for (final name in playerNames) {
        await PlatformStorageService.addPlayerName(name);
      }
    } catch (e) {
      print('Error importing data: $e');
      rethrow;
    }
  }

  /// Pick and import file (mobile only)
  static Future<void> pickAndImportFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final jsonString = utf8.decode(bytes);
        await importData(jsonString);
      }
    } catch (e) {
      print('Error picking and importing file: $e');
      rethrow;
    }
  }
}
