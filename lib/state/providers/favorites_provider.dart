import 'package:flutter/foundation.dart';

import '../../api/api_exception.dart';
import '../../api/api_repository.dart';
import '../../data/api_mappers.dart';
import '../../data/app_services.dart';
import '../../models/recent_file_item.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({
    ApiRepository? repository,
    Duration ttl = const Duration(minutes: 2),
  }) : _repository = repository ?? appApiRepository,
       _ttl = ttl;

  final ApiRepository _repository;
  final Duration _ttl;

  List<RecentFileItem> _favoriteFiles = const <RecentFileItem>[];
  DateTime? _lastLoadedAt;
  bool _isLoading = false;
  String? _error;
  Future<void>? _inflight;

  List<RecentFileItem> get favoriteFiles => _favoriteFiles;
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
    _lastLoadedAt = null;
    notifyListeners();
  }

  void reset() {
    _favoriteFiles = const <RecentFileItem>[];
    _lastLoadedAt = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final files = await _repository.favoriteFiles();
      _favoriteFiles = files.map(mapApiFileToRecentFileItem).toList();
      _lastLoadedAt = DateTime.now();
      _error = null;
    } on ApiException catch (e) {
      _error = 'API error: ${e.statusCode ?? ''} ${e.message}'.trim();
      rethrow;
    } catch (_) {
      _error = 'Failed to load favorites';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
