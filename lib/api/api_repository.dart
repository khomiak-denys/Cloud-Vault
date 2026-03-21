import 'api_client.dart';

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
    required this.path,
    required this.sizeBytes,
    required this.modifiedAt,
    required this.providerName,
    required this.isFavorite,
    required this.kind,
    this.mimeType,
  });

  final String id;
  final String connectionId;
  final String name;
  final String path;
  final double sizeBytes;
  final DateTime modifiedAt;
  final String providerName;
  final bool isFavorite;
  final String kind;
  final String? mimeType;
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

class ApiRepository {
  ApiRepository(this._client);

  static const int _maxFilesListPageSize = 100;
  static const String _storageApiRootPath = 'root';

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
            providerId:
                _str(item['providerId']) ?? _str(item['provider']) ?? '',
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

  Future<void> disconnectConnection(String id) async {
    await _client.deleteJson('/connections/$id');
  }

  Future<List<ApiFileItem>> recentFiles({int pageSize = 20}) async {
    final query = <String, String>{'pageSize': '$pageSize'};
    final json = await _client.getJson('/files/recent', query: query);
    return _parseFileItems(json);
  }

  Future<List<ApiFileItem>> listFiles({
    required String connectionId,
    String path = '/',
    int pageSize = 100,
  }) async {
    final normalizedPageSize = pageSize.clamp(1, _maxFilesListPageSize).toInt();
    final normalizedPath = _normalizeStoragePath(path);
    final payload = <String, dynamic>{
      'connectionId': connectionId,
      'path': normalizedPath,
      'pageSize': normalizedPageSize,
    };
    final json = await _client.postJson('/files/list', body: payload);
    return _parseFileItems(json);
  }

  Future<List<ApiFileItem>> searchFiles(
    String query, {
    int pageSize = 20,
    String? cursor,
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

    final json = await _client.postJson('/files/search', body: payload);
    return _parseFileItems(json);
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
    required String parentPath,
    required String name,
  }) async {
    final normalizedParentPath = _normalizeStoragePath(parentPath);
    await _client.postJson(
      '/files/folders/create',
      body: <String, dynamic>{
        'connectionId': connectionId,
        'parentPath': normalizedParentPath,
        'name': name,
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
            providerId: _str(item['providerId']) ?? '',
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
    final rootProviderId = _str(json['providerId']);

    return list.map((item) {
      final modifiedRaw =
          _str(item['modifiedTime']) ??
          _str(item['updatedAt']) ??
          _str(item['modifiedAt']) ??
          _str(item['createdAt']);
      final fileName =
          _str(item['fileName']) ?? _str(item['name']) ?? 'Unknown';
      final filePath = _str(item['path']) ?? _str(item['parentPath']) ?? '/';
      final itemConnectionId = _str(item['connectionId']);
      final safeRootConnectionId = rootConnectionId == 'all'
          ? null
          : rootConnectionId;

      return ApiFileItem(
        // Prefer provider-native file identifier (fileId/path) for file actions.
        id: _str(item['fileId']) ?? filePath,
        connectionId:
            itemConnectionId ?? safeRootConnectionId ?? rootProviderId ?? '',
        name: fileName,
        path: filePath,
        sizeBytes: _num(item['sizeBytes']) ?? _num(item['size']) ?? 0,
        modifiedAt: DateTime.tryParse(modifiedRaw ?? '') ?? DateTime.now(),
        providerName:
            _str(item['providerName']) ?? _str(item['provider']) ?? 'Storage',
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

  String _normalizeStoragePath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty || trimmed == '/') {
      return _storageApiRootPath;
    }
    return trimmed;
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
