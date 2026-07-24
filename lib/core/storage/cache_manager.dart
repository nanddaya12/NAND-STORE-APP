class CacheItem<T> {
  final T data;
  final DateTime expiresAt;

  CacheItem({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class CacheManager {
  final Map<String, CacheItem> _memoryCache = {};
  final int maxCacheSize = 100;

  static final CacheManager instance = CacheManager._internal();
  CacheManager._internal();

  // Write item with expiration duration
  void write<T>(String key, T data, Duration duration) {
    // Implement cache size limit enforcement (FIFO eviction)
    if (_memoryCache.length >= maxCacheSize) {
      final firstKey = _memoryCache.keys.first;
      _memoryCache.remove(firstKey);
    }

    _memoryCache[key] = CacheItem<T>(
      data: data,
      expiresAt: DateTime.now().add(duration),
    );
  }

  // Read item (returns null if expired or missing)
  T? read<T>(String key) {
    final item = _memoryCache[key];
    if (item == null) return null;

    if (item.isExpired) {
      _memoryCache.remove(key);
      return null;
    }
    return item.data as T;
  }

  // Clear a cache key
  void invalidate(String key) {
    _memoryCache.remove(key);
  }

  // Clear all memory caches
  void clear() {
    _memoryCache.clear();
  }
}
