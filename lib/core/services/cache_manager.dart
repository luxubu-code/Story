import '../../models/CacheItem.dart';

class CacheManager {
  static final CacheManager _intance = CacheManager._internal();

  factory CacheManager() => _intance;

  CacheManager._internal();

  final Map<String, CacheItem> _cache = {};

  void setItem(String key, dynamic data, {Duration? duration}) {
    final expiryTime = DateTime.now().add(duration ?? const Duration(hours: 1));
    _cache[key] = CacheItem(data: data, expiryTime: expiryTime);
  }

  T? getItem<T>(String key) {
    final item = _cache[key];
    if (item == null || item.isExpired) {
      _cache.remove(key);
      return null;
    }
    return item.data as T;
  }

  // Xóa một item khỏi cache
  void removeItem(String key) {
    _cache.remove(key);
  }

  // Xóa toàn bộ cache
  void clearCache() {
    _cache.clear();
  }
}
