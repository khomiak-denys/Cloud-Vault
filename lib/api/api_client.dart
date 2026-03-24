import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'auth_session.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();
  static const Set<String> _sensitiveBodyKeys = {
    'password',
    'secondfactorcode',
    'token',
    'access_token',
    'refresh_token',
    'authorization',
    'bearer',
    'appcheck',
  };

  final http.Client _httpClient;

  Future<Map<String, dynamic>> getJson(String path, {Map<String, String>? query}) {
    return _sendJson('GET', path, query: query);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) {
    return _sendJson('POST', path, body: body, query: query);
  }

  Future<Map<String, dynamic>> deleteJson(String path, {Map<String, String>? query}) {
    return _sendJson('DELETE', path, query: query);
  }

  Future<bool> refreshBearerToken() {
    return _refreshBearerToken();
  }

  Future<Map<String, dynamic>> _sendJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = ApiConfig.resolveApiUri(path, queryParameters: query);
    final requestBody = body ?? <String, dynamic>{};

    var response = await _sendRequest(method, uri, requestBody);

    if (response.statusCode == 401) {
      final refreshed = await _refreshBearerToken();
      if (refreshed) {
        _logApiError(
          phase: 'auth',
          method: method,
          uri: uri,
          statusCode: 401,
          body: 'Token expired. Retrying once with refreshed token.',
        );
        response = await _sendRequest(method, uri, requestBody);
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _logApiError(
        phase: 'http',
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
      );
      throw ApiException(
        'Request failed',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    if (response.body.isEmpty) return <String, dynamic>{};

    late dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      _logApiError(
        phase: 'decode',
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
        error: e.toString(),
      );
      rethrow;
    }
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{'data': decoded};
  }

  Future<http.Response> _sendRequest(
    String method,
    Uri uri,
    Map<String, dynamic> requestBody,
  ) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final bearer = AuthSession.instance.bearerToken;
    final appCheck = AuthSession.instance.appCheckToken;

    if (bearer != null && bearer.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearer';
    }
    if (appCheck != null && appCheck.isNotEmpty) {
      headers['X-Firebase-AppCheck'] = appCheck;
    }

    try {
      _logApiRequest(
        method: method,
        uri: uri,
        body: method == 'GET' || method == 'DELETE' ? null : requestBody,
      );

      final response = switch (method) {
        'GET' => await _httpClient.get(uri, headers: headers),
        'POST' => await _httpClient.post(
            uri,
            headers: headers,
            body: jsonEncode(requestBody),
          ),
        'DELETE' => await _httpClient.delete(uri, headers: headers),
        _ => throw ApiException('Unsupported HTTP method: $method'),
      };

      _logApiResponse(
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
      );
      return response;
    } catch (e) {
      _logApiError(
        phase: 'network',
        method: method,
        uri: uri,
        error: e.toString(),
      );
      throw ApiException('Network request failed', body: e.toString());
    }
  }

  Future<bool> _refreshBearerToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return false;
      }

      final refreshedToken = await user.getIdToken(true);
      if (refreshedToken == null || refreshedToken.isEmpty) {
        return false;
      }

      await AuthSession.instance.setTokens(bearerToken: refreshedToken);
      return true;
    } catch (e) {
      _logApiError(
        phase: 'auth-refresh',
        method: 'AUTH',
        uri: Uri.parse(ApiConfig.baseUrl),
        error: e.toString(),
      );
      return false;
    }
  }

  void _logApiRequest({
    required String method,
    required Uri uri,
    Map<String, dynamic>? body,
  }) {
    debugPrint('[API][request] $method $uri');
    if (body != null) {
      debugPrint('[API][request-body] ${jsonEncode(_redactSensitive(body))}');
    }
  }

  dynamic _redactSensitive(dynamic value, {String? key}) {
    if (_isSensitiveKey(key)) {
      return '***REDACTED***';
    }
    if (value is Map) {
      return value.map(
        (k, v) => MapEntry(
          k,
          _redactSensitive(v, key: k?.toString()),
        ),
      );
    }
    if (value is List) {
      return value.map((item) => _redactSensitive(item)).toList();
    }
    return value;
  }

  bool _isSensitiveKey(String? key) {
    if (key == null || key.isEmpty) return false;
    final normalized = key.toLowerCase().trim();
    if (_sensitiveBodyKeys.contains(normalized)) return true;
    return normalized.contains('password') ||
        normalized.contains('token') ||
        normalized.contains('secret');
  }

  void _logApiResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required String body,
  }) {
    final responseBody = body.isEmpty ? '' : '\nbody=$body';
    debugPrint('[API][response] $method $uri status=$statusCode$responseBody');
  }

  void _logApiError({
    required String phase,
    required String method,
    required Uri uri,
    int? statusCode,
    String? body,
    String? error,
  }) {
    final status = statusCode == null ? '' : ' status=$statusCode';
    final err = error == null ? '' : '\nerror=$error';
    final responseBody = body == null || body.isEmpty ? '' : '\nbody=$body';
    debugPrint('[API][$phase] $method $uri$status$err$responseBody');
  }
}
