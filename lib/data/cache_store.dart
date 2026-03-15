class CacheEntry<T> {
  CacheEntry(this.value, this.expiresAt);

  final T value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class CacheStore {
  final Map<String, CacheEntry<dynamic>> _entries = <String, CacheEntry<dynamic>>{};

  T? get<T>(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _entries.remove(key);
      return null;
    }
    return entry.value as T;
  }

  void set<T>(String key, T value, {required Duration ttl}) {
    _entries[key] = CacheEntry<T>(
      value,
      DateTime.now().add(ttl),
    );
  }

  void remove(String key) {
    _entries.remove(key);
  }

  void clear() {
    _entries.clear();
  }
}
