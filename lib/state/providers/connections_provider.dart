import 'package:flutter/foundation.dart';

import '../../api/api_exception.dart';
import '../../api/api_repository.dart';
import '../../data/app_services.dart';

class ConnectionsProvider extends ChangeNotifier {
  ConnectionsProvider({
    ApiRepository? repository,
    Duration ttl = const Duration(minutes: 2),
  }) : _repository = repository ?? appApiRepository,
       _ttl = ttl;

  final ApiRepository _repository;
  final Duration _ttl;

  ApiUser? _me;
  List<ApiConnection> _connections = const <ApiConnection>[];
  double _profileUsedBytes = 0;
  double _totalUsedBytes = 0;
  double _totalBytes = 0;
  DateTime? _lastLoadedAt;
  bool _isLoading = false;
  String? _error;
  Future<void>? _inflight;
  int _generation = 0;

  ApiUser? get me => _me;
  List<ApiConnection> get connections => _connections;
  double get profileUsedBytes => _profileUsedBytes;
  double get totalUsedBytes => _totalUsedBytes;
  double get totalBytes => _totalBytes;
  DateTime? get lastLoadedAt => _lastLoadedAt;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isStale {
    final loadedAt = _lastLoadedAt;
    if (loadedAt == null) return true;
    return DateTime.now().difference(loadedAt) > _ttl;
  }

  Future<void> ensureLoaded({bool forceRefresh = false}) {
    if (!forceRefresh && !isStale) {
      return Future<void>.value();
    }
    final inflight = _inflight;
    if (inflight != null) return inflight;

    final loadFuture = _load();
    _inflight = loadFuture;
    return loadFuture.whenComplete(() {
      if (identical(_inflight, loadFuture)) {
        _inflight = null;
      }
    });
  }

  void invalidate() {
    _generation += 1;
    _lastLoadedAt = null;
    _inflight = null;
    notifyListeners();
  }

  void reset() {
    _generation += 1;
    _me = null;
    _connections = const <ApiConnection>[];
    _profileUsedBytes = 0;
    _totalUsedBytes = 0;
    _totalBytes = 0;
    _lastLoadedAt = null;
    _error = null;
    _isLoading = false;
    _inflight = null;
    notifyListeners();
  }

  Future<void> _load() async {
    final int requestGeneration = _generation;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final usageReportFuture = _loadUsageReportSafe();
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _repository.me(),
        _repository.connections(),
        usageReportFuture,
      ]);

      final me = results[0] as ApiUser?;
      final baseConnections = results[1] as List<ApiConnection>;
      final usageReport = results[2] as ApiStorageUsageReport?;
      final usageConnections =
          usageReport?.connections ?? const <ApiConnection>[];
      final mergedConnections = _mergeConnectionsWithUsage(
        baseConnections,
        usageConnections,
      );
      if (!_isCurrentGeneration(requestGeneration)) {
        return;
      }
      final totalUsedBytes =
          usageReport?.usedBytes ??
          mergedConnections.fold<double>(
            0,
            (double acc, ApiConnection item) => acc + item.usedBytes,
          );
      final totalBytes =
          usageReport?.totalBytes ??
          mergedConnections.fold<double>(
            0,
            (double acc, ApiConnection item) => acc + item.totalBytes,
          );

      _me = me;
      _connections = mergedConnections;
      _profileUsedBytes = totalUsedBytes;
      _totalUsedBytes = totalUsedBytes;
      _totalBytes = totalBytes;
      _lastLoadedAt = DateTime.now();
      _error = null;
    } on ApiException catch (e) {
      if (!_isCurrentGeneration(requestGeneration)) {
        return;
      }
      _error = 'API error: ${e.statusCode ?? ''} ${e.message}'.trim();
      rethrow;
    } catch (_) {
      if (!_isCurrentGeneration(requestGeneration)) {
        return;
      }
      _error = 'Failed to load connections data';
      rethrow;
    } finally {
      if (_isCurrentGeneration(requestGeneration)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  bool _isCurrentGeneration(int generation) => _generation == generation;

  Future<ApiStorageUsageReport?> _loadUsageReportSafe() async {
    try {
      return await _repository.storageUsageReport();
    } catch (_) {
      return null;
    }
  }

  List<ApiConnection> _mergeConnectionsWithUsage(
    List<ApiConnection> connections,
    List<ApiConnection> usage,
  ) {
    String key(ApiConnection c) =>
        '${c.id}|${c.providerId}|${c.providerName}'.toLowerCase();

    final usageByKey = <String, ApiConnection>{
      for (final ApiConnection item in usage) key(item): item,
    };
    final usageById = <String, ApiConnection>{
      for (final ApiConnection item in usage)
        if (item.id.isNotEmpty) item.id.toLowerCase(): item,
    };
    final usageByProvider = <String, ApiConnection>{
      for (final ApiConnection item in usage)
        if (item.providerId.isNotEmpty) item.providerId.toLowerCase(): item,
    };

    final connectionProviderCounts = <String, int>{};
    for (final ApiConnection connection in connections) {
      if (connection.providerId.isEmpty) continue;
      final providerKey = connection.providerId.toLowerCase();
      connectionProviderCounts[providerKey] =
          (connectionProviderCounts[providerKey] ?? 0) + 1;
    }

    final usageProviderCounts = <String, int>{};
    for (final ApiConnection item in usage) {
      if (item.providerId.isEmpty) continue;
      final providerKey = item.providerId.toLowerCase();
      usageProviderCounts[providerKey] =
          (usageProviderCounts[providerKey] ?? 0) + 1;
    }

    return connections.map((ApiConnection connection) {
      final providerIdKey = connection.providerId.toLowerCase();
      final canFallbackByProvider =
          providerIdKey.isNotEmpty &&
          (connectionProviderCounts[providerIdKey] ?? 0) == 1 &&
          (usageProviderCounts[providerIdKey] ?? 0) == 1;
      final matched =
          usageByKey[key(connection)] ??
          usageById[connection.id.toLowerCase()] ??
          (canFallbackByProvider ? usageByProvider[providerIdKey] : null);

      if (matched == null) return connection;

      return ApiConnection(
        id: connection.id,
        providerId: connection.providerId,
        providerName: connection.providerName,
        usedBytes: matched.usedBytes,
        totalBytes: matched.totalBytes,
      );
    }).toList();
  }
}
