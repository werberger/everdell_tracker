import 'package:flutter/material.dart';

import '../services/platform_storage_service.dart';

class PlayerProvider extends ChangeNotifier {
  List<String> _playerNames = [];

  List<String> get playerNames => List.unmodifiable(_playerNames);

  Future<void> loadPlayerNames() async {
    _playerNames = PlatformStorageService.getPlayerNames();
    notifyListeners();
  }

  Future<void> addPlayerName(String name) async {
    await PlatformStorageService.addPlayerName(name);
    _playerNames = PlatformStorageService.getPlayerNames();
    notifyListeners();
  }
}
