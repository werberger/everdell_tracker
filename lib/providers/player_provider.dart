import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class PlayerProvider extends ChangeNotifier {
  List<String> _playerNames = [];

  List<String> get playerNames => List.unmodifiable(_playerNames);

  Future<void> loadPlayerNames() async {
    _playerNames = StorageService.getPlayerNames();
    notifyListeners();
  }

  Future<void> addPlayerName(String name) async {
    await StorageService.addPlayerName(name);
    _playerNames = StorageService.getPlayerNames();
    notifyListeners();
  }
}
