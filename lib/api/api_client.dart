import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
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

  Future<Uint8List> postBytes(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) {
    return _sendBytes('POST', path, body: body, query: query);
  }

  Future<Uint8List> postBytesCapped(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    required int maxBytes,
    Duration timeout = const Duration(seconds: 20),
  }) {
    return _sendBytesStreamedCapped(
      'POST',
      path,
      body: body,
      query: query,
      maxBytes: maxBytes,
      timeout: timeout,
    );
  }

  Future<Map<String, dynamic>> _sendJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = ApiConfig.resolveApiUri(path, queryParameters: query);
    final requestBody = body ?? <String, dynamic>{};

    var response = await _sendRequest(
      method,
      uri,
      requestBody,
      logResponseBody: false,
    );

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
        response = await _sendRequest(
          method,
          uri,
          requestBody,
          logResponseBody: false,
        );
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

  Future<Uint8List> _sendBytes(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = ApiConfig.resolveApiUri(path, queryParameters: query);
    final requestBody = body ?? <String, dynamic>{};

    var response = await _sendRequest(
      method,
      uri,
      requestBody,
      logResponseBody: false,
    );
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
        response = await _sendRequest(
          method,
          uri,
          requestBody,
          logResponseBody: false,
        );
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final responseBody = utf8.decode(response.bodyBytes, allowMalformed: true);
      _logApiError(
        phase: 'http',
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        body: responseBody,
      );
      throw ApiException(
        'Request failed',
        statusCode: response.statusCode,
        body: responseBody,
      );
    }

    return response.bodyBytes;
  }

  Future<Uint8List> _sendBytesStreamedCapped(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    required int maxBytes,
    required Duration timeout,
  }) async {
    final uri = ApiConfig.resolveApiUri(path, queryParameters: query);
    final requestBody = body ?? <String, dynamic>{};
    final requestJson = jsonEncode(requestBody);

    Future<http.StreamedResponse> sendOnce() async {
      final request = http.Request(method, uri);
      request.headers.addAll(_buildHeaders());
      request.body = requestJson;
      _logApiRequest(method: method, uri: uri, body: requestBody);
      return _httpClient.send(request).timeout(timeout);
    }

    http.StreamedResponse response = await sendOnce();
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
        response = await sendOnce();
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorText = await _readErrorText(response, timeout: timeout);
      _logApiError(
        phase: 'http',
        method: method,
        uri: uri,
        statusCode: response.statusCode,
        body: errorText,
      );
      throw ApiException(
        'Request failed',
        statusCode: response.statusCode,
        body: errorText,
      );
    }

    _logApiResponseMeta(
      method: method,
      uri: uri,
      statusCode: response.statusCode,
      contentLength: response.contentLength,
    );

    final bytes = BytesBuilder(copy: false);
    var total = 0;
    await for (final chunk in response.stream.timeout(timeout)) {
      total += chunk.length;
      if (total > maxBytes) {
        throw ApiException('Response exceeded max preview size');
      }
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  }

  Future<http.Response> _sendRequest(
    String method,
    Uri uri,
    Map<String, dynamic> requestBody,
    {required bool logResponseBody}
  ) async {
    final headers = _buildHeaders();

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

      if (logResponseBody) {
        _logApiResponse(
          method: method,
          uri: uri,
          statusCode: response.statusCode,
          body: response.body,
        );
      } else {
        _logApiResponseMeta(
          method: method,
          uri: uri,
          statusCode: response.statusCode,
          contentLength: response.contentLength,
        );
      }
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

  void _logApiResponseMeta({
    required String method,
    required Uri uri,
    required int statusCode,
    int? contentLength,
  }) {
    final size = contentLength == null ? '' : ' bytes=$contentLength';
    debugPrint('[API][response] $method $uri status=$statusCode$size');
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

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final bearer = AuthSession.instance.bearerToken;
    final appCheck = AuthSession.instance.appCheckToken;

    if (bearer != null && bearer.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearer';
    }
    if (appCheck != null && appCheck.isNotEmpty) {
      headers['X-Firebase-AppCheck'] = appCheck;
    }
    return headers;
  }

  Future<String> _readErrorText(
    http.StreamedResponse response, {
    required Duration timeout,
  }) async {
    const maxErrorBytes = 8192;
    final bytes = BytesBuilder(copy: false);
    try {
      await for (final chunk in response.stream.timeout(timeout)) {
        final remaining = maxErrorBytes - bytes.length;
        if (remaining <= 0) break;
        if (chunk.length <= remaining) {
          bytes.add(chunk);
        } else {
          bytes.add(chunk.sublist(0, remaining));
          break;
        }
      }
    } catch (_) {
      // Best effort only for diagnostics.
    }
    return utf8.decode(bytes.takeBytes(), allowMalformed: true);
  }
}
