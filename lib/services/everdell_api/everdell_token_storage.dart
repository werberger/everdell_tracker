import 'package:shared_preferences/shared_preferences.dart';

/// Persists Everdell JWT tokens for native platforms (Bearer auth).
class EverdellTokenStorage {
  static const _accessKey = 'everdell_access_token';
  static const _refreshKey = 'everdell_refresh_token';
  static const _activeGroupIdKey = 'everdell_active_group_id';
  static const _activeGroupNameKey = 'everdell_active_group_name';

  static Future<void> saveTokens({
    required String access,
    String? refresh,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    if (refresh != null) {
      await prefs.setString(_refreshKey, refresh);
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }

  static Future<void> saveActiveGroup({
    required String groupId,
    required String groupName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeGroupIdKey, groupId);
    await prefs.setString(_activeGroupNameKey, groupName);
  }

  static Future<({String? id, String? name})> getActiveGroup() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      id: prefs.getString(_activeGroupIdKey),
      name: prefs.getString(_activeGroupNameKey),
    );
  }

  static Future<void> clearActiveGroup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeGroupIdKey);
    await prefs.remove(_activeGroupNameKey);
  }
}
