import 'package:flutter/foundation.dart';

import '../../api/api_exception.dart';
import '../../api/api_repository.dart';
import '../../data/api_mappers.dart';
import '../../data/app_services.dart';
import '../../models/storage_usage_item.dart';

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsProvider({
    ApiRepository? repository,
    Duration ttl = const Duration(minutes: 3),
  }) : _repository = repository ?? appApiRepository,
       _ttl = ttl;

  final ApiRepository _repository;
  final Duration _ttl;

  List<StorageUsageItem> _usageItems = const <StorageUsageItem>[];
  List<ApiStorageRecommendation> _recommendations =
      const <ApiStorageRecommendation>[];
  DateTime? _lastLoadedAt;
  bool _isLoading = false;
  String? _error;
  Future<void>? _inflight;
  int _generation = 0;

  List<StorageUsageItem> get usageItems => _usageItems;
  List<ApiStorageRecommendation> get recommendations => _recommendations;
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
    _isLoading = false;
    _error = null;
    _inflight = null;
    notifyListeners();
  }

  void reset() {
    _generation += 1;
    _usageItems = const <StorageUsageItem>[];
    _recommendations = const <ApiStorageRecommendation>[];
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
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _repository.storageUsage(),
        _repository.recommendations(),
      ]);
      final usage = results[0] as List<ApiConnection>;
      final recommendations = results[1] as List<ApiStorageRecommendation>;
      if (!_isCurrentGeneration(requestGeneration)) {
        return;
      }

      _usageItems = usage.map(mapConnectionToStorageUsageItem).toList();
      _recommendations = recommendations;
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
      _error = 'Failed to load analytics';
      rethrow;
    } finally {
      if (_isCurrentGeneration(requestGeneration)) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  bool _isCurrentGeneration(int generation) => _generation == generation;
}
