import 'package:flutter/material.dart';

import '../models/everdell_group.dart';
import '../services/everdell_api/everdell_api_exception.dart';
import '../services/everdell_api/everdell_api_service.dart';
import '../services/everdell_api/everdell_token_storage.dart';

class OnlineSessionProvider extends ChangeNotifier {
  OnlineSessionProvider({EverdellApiService? api}) : _api = api ?? EverdellApiService();

  final EverdellApiService _api;

  List<EverdellGroup> _groups = [];
  EverdellGroup? _activeGroup;
  bool _loading = false;
  String? _errorMessage;

  List<EverdellGroup> get groups => List.unmodifiable(_groups);
  EverdellGroup? get activeGroup => _activeGroup;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveGroup => _activeGroup != null;

  Future<void> restoreActiveGroup() async {
    final saved = await EverdellTokenStorage.getActiveGroup();
    if (saved.id == null) {
      _activeGroup = null;
      notifyListeners();
      return;
    }

    try {
      // Fetch detail so invite_code and member_count are always current.
      _activeGroup = await _api.getGroup(saved.id!);
      await EverdellTokenStorage.saveActiveGroup(
        groupId: _activeGroup!.id,
        groupName: _activeGroup!.name,
      );
    } on EverdellApiException {
      await loadGroups();
      for (final group in _groups) {
        if (group.id == saved.id) {
          _activeGroup = group;
          break;
        }
      }
      if (_activeGroup == null && saved.id != null && saved.name != null) {
        _activeGroup = EverdellGroup(
          id: saved.id!,
          name: saved.name!,
          inviteCode: '',
          memberCount: 0,
        );
      }
    } catch (_) {
      _activeGroup = null;
    }
    notifyListeners();
  }

  /// Re-fetch the active group from the API (e.g. to populate invite_code).
  Future<void> refreshActiveGroup() async {
    if (_activeGroup == null) return;
    try {
      final fresh = await _api.getGroup(_activeGroup!.id);
      _activeGroup = fresh;
      final index = _groups.indexWhere((g) => g.id == fresh.id);
      if (index >= 0) {
        _groups[index] = fresh;
      }
      notifyListeners();
    } on EverdellApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> loadGroups() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _groups = await _api.listGroups();
    } on EverdellApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load groups.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> selectGroup(EverdellGroup group) async {
    _activeGroup = group;
    await EverdellTokenStorage.saveActiveGroup(
      groupId: group.id,
      groupName: group.name,
    );
    notifyListeners();
    return true;
  }

  Future<bool> createGroup(String name) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final group = await _api.createGroup(name.trim());
      await loadGroups();
      await selectGroup(group);
      return true;
    } on EverdellApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Could not create group.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> joinGroup(String inviteCode) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final group = await _api.joinGroup(inviteCode);
      await loadGroups();
      await selectGroup(group);
      return true;
    } on EverdellApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Could not join group.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> clearActiveGroup() async {
    _activeGroup = null;
    await EverdellTokenStorage.clearActiveGroup();
    notifyListeners();
  }

}
