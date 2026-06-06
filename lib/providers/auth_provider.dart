import 'package:flutter/material.dart';

import '../models/everdell_profile.dart';
import '../services/everdell_api/everdell_api_exception.dart';
import '../services/everdell_api/everdell_api_service.dart';
import '../services/everdell_api/everdell_token_storage.dart';

enum AuthStatus { unknown, checking, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({EverdellApiService? api}) : _api = api ?? EverdellApiService();

  final EverdellApiService _api;

  AuthStatus _status = AuthStatus.unknown;
  EverdellProfile? _profile;
  String? _errorMessage;
  bool _busy = false;

  AuthStatus get status => _status;
  EverdellProfile? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get busy => _busy;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> restoreSession() async {
    _status = AuthStatus.checking;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _api.getMe();
      _status = AuthStatus.authenticated;
    } on EverdellApiException {
      await EverdellTokenStorage.clearTokens();
      _profile = null;
      _status = AuthStatus.unauthenticated;
    } catch (_) {
      _profile = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.login(username: username, password: password);
      _profile = await _api.getMe();
      _status = AuthStatus.authenticated;
      return true;
    } on EverdellApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      return false;
    } catch (_) {
      _errorMessage = 'Could not sign in. Check your connection and try again.';
      _status = AuthStatus.unauthenticated;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _profile = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

}
