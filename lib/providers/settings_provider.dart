import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings.defaults();

  AppSettings get settings => _settings;

  bool get separatePointTokens => _settings.separatePointTokens;

  bool get autoConvertResources => _settings.autoConvertResources;

  bool get darkMode => _settings.darkMode;

  CardEntryMethod get cardEntryMethod => _settings.cardEntryMethod;

  Future<void> loadSettings() async {
    _settings = await StorageService.getSettings();
    notifyListeners();
  }

  Future<void> setSeparatePointTokens(bool value) async {
    _settings = _settings.copyWith(separatePointTokens: value);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setAutoConvertResources(bool value) async {
    _settings = _settings.copyWith(autoConvertResources: value);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _settings = _settings.copyWith(darkMode: value);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setCardEntryMethod(CardEntryMethod value) async {
    _settings = _settings.copyWith(cardEntryMethodIndex: value.index);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setUseFanLayout(bool value) async {
    _settings = _settings.copyWith(useFanLayout: value);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }
}
