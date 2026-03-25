import 'dart:typed_data';

import '../data/provider_identity.dart';
import '../data/provider_labels.dart';
import 'api_client.dart';
import 'api_exception.dart';

class ApiUser {
  const ApiUser({
    required this.uid,
    required this.email,
    required this.name,
    this.picture,
  });

  final String uid;
  final String email;
  final String name;
  final String? picture;
}

class ApiConnection {
  const ApiConnection({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.usedBytes,
    required this.totalBytes,
  });

  final String id;
  final String providerId;
  final String providerName;
  final double usedBytes;
  final double totalBytes;
}

class ApiFileItem {
  const ApiFileItem({
    required this.id,
    required this.connectionId,
    required this.name,
    this.path,
    required this.displayPath,
    required this.sizeBytes,
    required this.modifiedAt,
    required this.providerId,
    required this.providerName,
    required this.isFavorite,
    required this.kind,
    this.mimeType,
  });

  final String id;
  final String connectionId;
  final String name;
  final String? path;
  final String displayPath;
  final double sizeBytes;
  final DateTime modifiedAt;
  final String providerId;
  final String providerName;
  final bool isFavorite;
  final String kind;
  final String? mimeType;
}

class ApiProviderFacet {
  const ApiProviderFacet({
    required this.providerId,
    required this.providerName,
    required this.count,
  });

  final String providerId;
  final String providerName;
  final int count;
}

class ApiSearchFilesResult {
  const ApiSearchFilesResult({
    required this.items,
    required this.providerFacets,
  });

  final List<ApiFileItem> items;
  final List<ApiProviderFacet> providerFacets;
}

class ApiStorageRecommendation {
  const ApiStorageRecommendation({required this.title, required this.body});

  final String title;
  final String body;
}

class ApiStorageUsageReport {
  const ApiStorageUsageReport({
    required this.connections,
    this.usedBytes,
    this.totalBytes,
    this.usagePercent,
  });

  final List<ApiConnection> connections;
  final double? usedBytes;
  final double? totalBytes;
  final double? usagePercent;
}

class ApiPreviewUrl {
  const ApiPreviewUrl({
    required this.url,
    required this.method,
    required this.headers,
  });

  final String url;
  final String method;
  final Map<String, String> headers;
}

class ApiMegaConnectResult {
  const ApiMegaConnectResult({
    required this.connectionId,
    required this.providerId,
    required this.accountEmail,
  });

  final String connectionId;
  final String providerId;
  final String accountEmail;
}

class ApiRepository {
  ApiRepository(this._client);

  static const int _maxFilesListPageSize = 100;
  static const String storageApiRootPath = 'root';
  static const String _storageApiRootPath = storageApiRootPath;

  final ApiClient _client;

  Future<ApiUser?> me() async {
    final json = await _client.getJson('/me');
    final obj = _extractObject(json);
    if (obj == null) return null;

    return ApiUser(
      uid: _str(obj['uid']) ?? '',
      email: _str(obj['email']) ?? '',
      name: _str(obj['name']) ?? _str(obj['displayName']) ?? 'User',
      picture: _str(obj['picture']),
    );
  }

  Future<List<ApiConnection>> connections() async {
    final json = await _client.getJson('/connections');
    final list = _extractList(json);

    return list
        .map((item) {
          return ApiConnection(
            id: _str(item['id']) ?? _str(item['_id']) ?? '',
            providerId: normalizeProviderId(
              _str(item['providerId']) ?? _str(item['provider']),
            ),
            providerName:
                _str(item['providerName']) ??
                _str(item['displayName']) ??
                _str(item['provider']) ??
                'Storage',
            usedBytes:
                _num(item['usedBytes']) ??
                _num(item['usage']?['usedBytes']) ??
                _num(item['storage']?['used']) ??
                0,
            totalBytes:
                _num(item['totalBytes']) ??
                _num(item['usage']?['totalBytes']) ??
                _num(item['storage']?['total']) ??
                0,
          );
        })
        .where((c) => c.id.isNotEmpty)
        .toList();
  }

  Future<String?> startProviderConnect(
    String providerId, {
    String? redirectUri,
  }) async {
    final body = <String, dynamic>{
      if (providerId == 'google-drive' || providerId == 'onedrive')
        'prompt': 'consent',
    };
    if (redirectUri != null) {
      body['redirectUri'] = redirectUri;
    }

    final json = await _client.postJson(
      '/providers/$providerId/connect/start',
      body: body,
    );

    final obj = _extractObject(json) ?? json;
    return _str(obj['authorizeUrl']) ?? _str(obj['url']);
  }

  Future<ApiMegaConnectResult> startMegaConnect({
    required String email,
    required String password,
    String? secondFactorCode,
  }) async {
    final json = await _client.postJson(
      '/providers/mega/connect/start',
      body: <String, dynamic>{
        'email': email,
        'password': password,
        if (secondFactorCode != null && secondFactorCode.isNotEmpty)
          'secondFactorCode': secondFactorCode,
      },
    );

    final obj = _extractObject(json) ?? json;
    final connectionId = _str(obj['connectionId'])?.trim() ?? '';
    final providerId = normalizeProviderId(_str(obj['providerId']) ?? 'mega');
    final accountEmail = _str(obj['accountEmail'])?.trim() ?? email;
    if (connectionId.isEmpty) {
      throw ApiException('Invalid MEGA connect response: missing connectionId');
    }

    return ApiMegaConnectResult(
      connectionId: connectionId,
      providerId: providerId,
      accountEmail: accountEmail,
    );
  }

  Future<void> disconnectConnection(String id) async {
    await _client.deleteJson('/connections/$id');
  }

  Future<List<ApiFileItem>> recentFiles({int pageSize = 20}) async {
    final query = <String, String>{'pageSize': '$pageSize'};
    final json = await _client.getJson('/files/recent', query: query);
    return _parseFileItems(json);
  }

  Future<List<ApiFileItem>> favoriteFiles({
    int? pageSize,
    String? cursor,
    String? connectionId,
    String? providerId,
  }) async {
    final query = <String, String>{
      if (pageSize != null) 'pageSize': '${pageSize.clamp(1, 100).toInt()}',
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      if (connectionId != null && connectionId.isNotEmpty)
        'connectionId': connectionId,
      if (providerId != null && providerId.isNotEmpty)
        'providerId': normalizeProviderId(providerId),
    };
    final json = await _client.getJson('/files/favorites', query: query);
    return _parseFileItems(json);
  }

  Future<List<ApiFileItem>> dashboardSummaryRecentFiles({int pageSize = 20}) async {
    final json = await _client.getJson('/dashboard/summary');
    final root = _extractObject(json) ?? json;
    final recentRaw = root['recentFiles'];
    if (recentRaw is! List) return const [];
    final bounded = recentRaw.take(pageSize.clamp(1, 100).toInt()).toList();
    final merged = <String, dynamic>{...root, 'items': bounded};
    return _parseFileItems(merged);
  }

  Future<List<ApiFileItem>> listFiles({
    required String connectionId,
    String? providerId,
    String path = '/',
    int pageSize = _maxFilesListPageSize,
  }) async {
    final normalizedPageSize = pageSize.clamp(1, _maxFilesListPageSize).toInt();
    final normalizedPath = _normalizeListPath(path, providerId: providerId);
    final payload = <String, dynamic>{
      'connectionId': connectionId,
      'path': normalizedPath,
      'pageSize': normalizedPageSize,
    };
    final json = await _client.postJson('/files/list', body: payload);
    return _parseFileItems(json);
  }

  String _normalizeListPath(String path, {String? providerId}) {
    if (isIdBasedProviderId(providerId)) {
      return _normalizeIdBasedListPath(path);
    }
    return _normalizeStoragePath(path);
  }

  String _normalizeIdBasedListPath(String path) {
    final normalized = _normalizeStoragePath(path);
    if (normalized == _storageApiRootPath) {
      return _storageApiRootPath;
    }

    final segments = normalized
        .replaceAll('\\', '/')
        .replaceAll(RegExp('/+'), '/')
        .split('/')
        .where((segment) => segment.trim().isNotEmpty)
        .toList();

    if (segments.isEmpty) {
      return _storageApiRootPath;
    }

    if (segments.first == _storageApiRootPath && segments.length == 1) {
      return _storageApiRootPath;
    }

    return segments.last;
  }

  Future<ApiSearchFilesResult> searchFiles(
    String query, {
    int pageSize = 20,
    String? cursor,
    List<String>? providerIds,
  }) async {
    final payload = <String, dynamic>{
      'query': query,
      'pageSize': pageSize,
      'sortBy': 'updatedAt',
      'order': 'desc',
    };
    if (cursor != null && cursor.isNotEmpty) {
      payload['cursor'] = cursor;
    }
    if (providerIds != null && providerIds.isNotEmpty) {
      payload['providerIds'] = providerIds;
    }

    final json = await _client.postJson('/files/search', body: payload);
    return ApiSearchFilesResult(
      items: _parseFileItems(json),
      providerFacets: _extractProviderFacets(json),
    );
  }

  Future<void> setFavorite({
    required String connectionId,
    required String fileId,
    required String fileName,
    required String kind,
  }) async {
    final normalizedKind = kind == 'folder' ? 'folder' : 'file';
    await _client.postJson(
      '/files/favorites/set',
      body: <String, dynamic>{
        'connectionId': connectionId,
        'fileId': fileId,
        'fileName': fileName,
        'kind': normalizedKind,
      },
    );
  }

  Future<void> unsetFavorite({
    required String connectionId,
    required String fileId,
    required String fileName,
    required String kind,
  }) async {
    final normalizedKind = kind == 'folder' ? 'folder' : 'file';
    await _client.postJson(
      '/files/favorites/unset',
      body: <String, dynamic>{
        'connectionId': connectionId,
        'fileId': fileId,
        'fileName': fileName,
        'kind': normalizedKind,
      },
    );
  }

  Future<String?> downloadUrl({
    required String connectionId,
    required String fileId,
  }) async {
    final json = await _client.postJson(
      '/files/download-url',
      body: <String, dynamic>{'connectionId': connectionId, 'fileId': fileId},
    );
    final obj = _extractObject(json) ?? json;
    return _str(obj['url']);
  }

  Future<ApiPreviewUrl?> previewUrl({
    required String connectionId,
    required String fileId,
  }) async {
    final json = await _client.postJson(
      '/files/preview-url',
      body: <String, dynamic>{'connectionId': connectionId, 'fileId': fileId},
    );
    final obj = _extractObject(json) ?? json;
    final url = _str(obj['url']);
    if (url == null || url.isEmpty) return null;
    final method = (_str(obj['method']) ?? 'GET').trim().toUpperCase();
    final headers = _stringMap(obj['headers']);
    return ApiPreviewUrl(url: url, method: method, headers: headers);
  }

  Future<Uint8List> previewStreamBytes({
    required String connectionId,
    required String fileId,
    String? fileName,
    String? mimeType,
    required int maxBytes,
    Duration timeout = const Duration(seconds: 20),
  }) {
    final payload = <String, dynamic>{
      'connectionId': connectionId,
      'fileId': fileId,
      if (fileName != null && fileName.isNotEmpty) 'fileName': fileName,
      if (mimeType != null && mimeType.isNotEmpty) 'mimeType': mimeType,
    };
    return _client.postBytesCapped(
      '/files/preview-stream',
      body: payload,
      maxBytes: maxBytes,
      timeout: timeout,
    );
  }

  Future<String?> shareLink({
    required String connectionId,
    required String fileId,
  }) async {
    final json = await _client.postJson(
      '/files/share-link',
      body: <String, dynamic>{'connectionId': connectionId, 'fileId': fileId},
    );
    final obj = _extractObject(json) ?? json;
    return _str(obj['url']) ?? _str(obj['shareUrl']) ?? _str(obj['link']);
  }

  Future<void> renameFile({
    required String connectionId,
    required String fileId,
    required String newName,
  }) async {
    await _client.postJson(
      '/files/rename',
      body: <String, dynamic>{
        'connectionId': connectionId,
        'fileId': fileId,
        'newName': newName,
      },
    );
  }

  Future<void> deleteFile({
    required String connectionId,
    required String fileId,
  }) async {
    await _client.postJson(
      '/files/delete',
      body: <String, dynamic>{'connectionId': connectionId, 'fileId': fileId},
    );
  }

  Future<void> createFolder({
    required String connectionId,
    String? providerId,
    required String parentId,
    required String folderName,
  }) async {
    final normalizedParentId = _normalizeListPath(
      parentId,
      providerId: providerId,
    );
    await _client.postJson(
      '/files/create-folder',
      body: <String, dynamic>{
        'connectionId': connectionId,
        'parentId': normalizedParentId,
        'folderName': folderName,
      },
    );
  }

  Future<Map<String, dynamic>> fileProperties({
    required String connectionId,
    required String fileId,
  }) {
    return _client.postJson(
      '/files/properties',
      body: <String, dynamic>{'connectionId': connectionId, 'fileId': fileId},
    );
  }

  Future<ApiStorageUsageReport> storageUsageReport() async {
    final json = await _client.getJson('/analytics/storage-usage');
    final totals = json['totals'] is Map
        ? Map<String, dynamic>.from(json['totals'] as Map)
        : null;
    final list = _extractList(json);

    final connections = list
        .map((item) {
          return ApiConnection(
            id: _str(item['connectionId']) ?? _str(item['id']) ?? '',
            providerId: normalizeProviderId(_str(item['providerId'])),
            providerName:
                _str(item['providerName']) ?? _str(item['name']) ?? 'Storage',
            usedBytes: _num(item['usedBytes']) ?? 0,
            totalBytes: _num(item['totalBytes']) ?? 0,
          );
        })
        .where((c) => c.id.isNotEmpty)
        .toList();

    return ApiStorageUsageReport(
      connections: connections,
      usedBytes: _num(totals?['usedBytes']),
      totalBytes: _num(totals?['totalBytes']),
      usagePercent: _num(totals?['usagePercent']),
    );
  }

  Future<List<ApiConnection>> storageUsage() async {
    final report = await storageUsageReport();
    return report.connections;
  }

  Future<List<ApiStorageRecommendation>> recommendations() async {
    final json = await _client.getJson(
      '/analytics/storage-optimization-recommendations',
    );
    final list = _extractList(json);

    return list
        .map((item) {
          return ApiStorageRecommendation(
            title: _str(item['title']) ?? 'Recommendation',
            body: _str(item['description']) ?? _str(item['body']) ?? '',
          );
        })
        .where((r) => r.body.isNotEmpty)
        .toList();
  }

  List<ApiFileItem> _parseFileItems(Map<String, dynamic> json) {
    final list = _extractList(json);
    final rootConnectionId = _str(json['connectionId']);

    return list.map((item) {
      final modifiedRaw =
          _str(item['modifiedTime']) ??
          _str(item['updatedAt']) ??
          _str(item['modifiedAt']) ??
          _str(item['createdAt']);
      final openedRaw =
          _str(item['openedAt']) ??
          _str(item['lastOpenedAt']) ??
          _str(item['accessedAt']);
      final fileName =
          _str(item['fileName']) ?? _str(item['name']) ?? 'Unknown';
      final rawPath = _str(item['path']);
      final parentPath = _str(item['parentPath']);
      final fallbackPath = rawPath ?? parentPath ?? '/';
      final displayPath = _str(item['displayPath']) ?? fallbackPath;
      final itemConnectionId = _str(item['connectionId']);
      final safeRootConnectionId = rootConnectionId == 'all'
          ? null
          : rootConnectionId;
      final normalizedProviderId = normalizeProviderId(
        _str(item['providerId']) ?? _str(item['provider']),
      );

      return ApiFileItem(
        // Prefer provider-native file identifier (fileId/path) for file actions.
        id: _str(item['fileId']) ?? rawPath ?? parentPath ?? displayPath,
        connectionId: itemConnectionId ?? safeRootConnectionId ?? '',
        name: fileName,
        path: rawPath,
        displayPath: displayPath,
        sizeBytes: _num(item['sizeBytes']) ?? _num(item['size']) ?? 0,
        modifiedAt:
            DateTime.tryParse(modifiedRaw ?? '') ??
            DateTime.tryParse(openedRaw ?? '') ??
            DateTime.now(),
        providerId: normalizedProviderId,
        providerName:
            _str(item['providerName']) ??
            _str(item['provider']) ??
            providerDisplayName(normalizedProviderId),
        isFavorite: item['isFavorite'] == true || item['favorite'] == true,
        kind:
            _str(item['kind']) ??
            (_str(item['mimeType'])?.contains('folder') == true
                ? 'folder'
                : 'file'),
        mimeType: _str(item['mimeType']),
      );
    }).toList();
  }

  List<ApiProviderFacet> _extractProviderFacets(Map<String, dynamic> json) {
    final root = _extractObject(json) ?? json;
    final facets =
        root['facets'] is Map
            ? Map<String, dynamic>.from(root['facets'] as Map)
            : (json['facets'] is Map
                ? Map<String, dynamic>.from(json['facets'] as Map)
                : null);
    if (facets == null) return const [];
    final providers = facets['providers'];
    if (providers is! List) return const [];
    return providers
        .whereType<Map>()
        .map((raw) => Map<String, dynamic>.from(raw))
        .map((item) {
          final providerId = normalizeProviderId(_str(item['providerId']));
          final providerName =
              _str(item['providerName']) ?? _str(item['provider']) ?? providerId;
          return ApiProviderFacet(
            providerId: providerId,
            providerName: providerName,
            count: (_num(item['count']) ?? 0).toInt(),
          );
        })
        .where((facet) => facet.providerId.isNotEmpty)
        .toList();
  }

  String _normalizeStoragePath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty || trimmed == '/') {
      return _storageApiRootPath;
    }

    var normalized = trimmed
        .replaceAll('\\', '/')
        .replaceAll(RegExp('/+'), '/');
    if (normalized.isEmpty || normalized == '/') {
      return _storageApiRootPath;
    }
    if (normalized.endsWith('/') && normalized.length > 1) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    if (normalized == _storageApiRootPath ||
        normalized == '/$_storageApiRootPath') {
      return _storageApiRootPath;
    }

    if (normalized.startsWith('/')) {
      normalized = normalized.substring(1);
    }
    if (normalized.isEmpty || normalized == '/') {
      return _storageApiRootPath;
    }

    if (normalized == _storageApiRootPath) {
      return _storageApiRootPath;
    }
    if (normalized.startsWith('$_storageApiRootPath/')) {
      return normalized;
    }

    return '$_storageApiRootPath/$normalized';
  }
}

String? _str(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

double? _num(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

Map<String, String> _stringMap(dynamic value) {
  if (value is! Map) return const <String, String>{};
  final result = <String, String>{};
  for (final entry in value.entries) {
    final key = _str(entry.key);
    final mapValue = _str(entry.value);
    if (key == null || key.isEmpty || mapValue == null) continue;
    result[key] = mapValue;
  }
  return result;
}

Map<String, dynamic>? _extractObject(Map<String, dynamic> json) {
  const keys = ['data', 'result', 'item', 'me'];
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
  }
  if (json.isNotEmpty && json.values.every((v) => v is! List)) return json;
  return null;
}

List<Map<String, dynamic>> _extractList(Map<String, dynamic> json) {
  const keys = [
    'items',
    'data',
    'results',
    'connections',
    'files',
    'recommendations',
  ];

  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (value is Map<String, dynamic>) {
      for (final nested in keys) {
        final nestedValue = value[nested];
        if (nestedValue is List) {
          return nestedValue
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }
  }

  if (json['data'] is List) {
    return (json['data'] as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  return const [];
}
