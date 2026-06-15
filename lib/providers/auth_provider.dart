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

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.register(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
      );
      // Registration auto-logs-in on the server; load the profile.
      _profile = await _api.getMe();
      _status = AuthStatus.authenticated;
      return true;
    } on EverdellApiException catch (e) {
      _errorMessage = _formatRegistrationError(e);
      _status = AuthStatus.unauthenticated;
      return false;
    } catch (_) {
      _errorMessage = 'Could not create account. Check your connection and try again.';
      _status = AuthStatus.unauthenticated;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  String _formatRegistrationError(EverdellApiException e) {
    if (e.statusCode == 429) {
      return 'Too many sign-up attempts. Please try again later.';
    }
    final body = e.body;
    if (body != null) {
      // DRF field errors look like {"email": ["An account with this email..."]}.
      final messages = <String>[];
      for (final entry in body.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          messages.add(value.first.toString());
        } else if (value is String) {
          messages.add(value);
        }
      }
      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }
    return e.message;
  }

  Future<void> logout() async {
    await _api.logout();
    _profile = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

}
