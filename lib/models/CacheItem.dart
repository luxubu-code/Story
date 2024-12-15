class CacheItem {
  final dynamic data;
  final DateTime expiryTime;

  CacheItem({required this.data, required this.expiryTime});

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}
