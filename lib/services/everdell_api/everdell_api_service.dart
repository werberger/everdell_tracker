import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../../models/everdell_group.dart';
import '../../models/everdell_profile.dart';
import 'everdell_api_config.dart';
import 'everdell_api_exception.dart';
import 'everdell_http_client.dart';
import 'everdell_token_storage.dart';

class EverdellApiService {
  EverdellApiService({http.Client? client})
      : _client = client ?? createEverdellHttpClient();

  final http.Client _client;

  String get _root => '${EverdellApiConfig.baseUrl}${EverdellApiConfig.apiPrefix}';

  Future<Map<String, String>> _headers({bool jsonBody = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (!kIsWeb) {
      final token = await EverdellTokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> _decodeResponse(http.Response response) async {
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = json.decode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    if (response.statusCode == 409 && body is Map<String, dynamic>) {
      throw EverdellConflictException(
        message: body['detail'] as String? ?? 'Conflict',
        current: body['current'] as Map<String, dynamic>?,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String message = 'Request failed';
    if (body is Map<String, dynamic>) {
      message = body['detail'] as String? ?? body['error'] as String? ?? message;
    }
    throw EverdellApiException(
      message,
      statusCode: response.statusCode,
      body: body is Map<String, dynamic> ? body : null,
    );
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_root/token/cookie/'),
      headers: await _headers(jsonBody: true),
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
    final body = await _decodeResponse(response);
    if (!kIsWeb && body is Map<String, dynamic>) {
      final access = body['access'] as String?;
      final refresh = body['refresh'] as String?;
      if (access != null) {
        await EverdellTokenStorage.saveTokens(
          access: access,
          refresh: refresh,
        );
      }
    }
  }

  Future<void> logout() async {
    try {
      await _client.post(
        Uri.parse('$_root/logout/'),
        headers: await _headers(),
      );
    } finally {
      await EverdellTokenStorage.clearTokens();
      await EverdellTokenStorage.clearActiveGroup();
    }
  }

  Future<EverdellProfile> getMe() async {
    final response = await _client.get(
      Uri.parse('$_root/me/'),
      headers: await _headers(),
    );
    final body = await _decodeResponse(response);
    return EverdellProfile.fromJson(body as Map<String, dynamic>);
  }

  Future<List<EverdellGroup>> listGroups() async {
    final response = await _client.get(
      Uri.parse('$_root/groups/'),
      headers: await _headers(),
    );
    final body = await _decodeResponse(response);
    final list = body as List<dynamic>;
    return list
        .map((item) => EverdellGroup.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<EverdellGroup> createGroup(String name) async {
    final response = await _client.post(
      Uri.parse('$_root/groups/'),
      headers: await _headers(jsonBody: true),
      body: json.encode({'name': name}),
    );
    final body = await _decodeResponse(response);
    return EverdellGroup.fromJson(body as Map<String, dynamic>);
  }

  Future<EverdellGroup> joinGroup(String inviteCode) async {
    final response = await _client.post(
      Uri.parse('$_root/groups/join/'),
      headers: await _headers(jsonBody: true),
      body: json.encode({'invite_code': inviteCode.trim()}),
    );
    final body = await _decodeResponse(response);
    return EverdellGroup.fromJson(body as Map<String, dynamic>);
  }

  void dispose() {
    _client.close();
  }
}
