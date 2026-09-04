import 'dart:async';

/// One cached value plus its expiry.
class CacheEntry<T> {
  final T value;
  final DateTime expiresAt;
  CacheEntry(this.value, this.expiresAt);
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Simple in-memory TTL cache with get-or-fetch semantics, used for GET
/// responses that don't change often (home, categories, reference data,
/// product listings) so repeat navigation is instant.
///
/// Deliberately not persisted to disk — it only needs to survive the app
/// session — and deliberately not generic-key-typed beyond String, to keep
/// this small.
class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  final Map<String, CacheEntry<dynamic>> _store = {};

  static const Duration defaultTtl = Duration(minutes: 5);

  /// Returns the cached value if fresh, otherwise calls [fetch], caches and
  /// returns its result. Pass [ttl] to override the default freshness window.
  Future<T> getOrFetch<T>(String key, Future<T> Function() fetch, {Duration ttl = defaultTtl}) async {
    final cached = _store[key];
    if (cached != null && !cached.isExpired) {
      return cached.value as T;
    }
    final value = await fetch();
    _store[key] = CacheEntry<T>(value, DateTime.now().add(ttl));
    return value;
  }

  void invalidate(String key) => _store.remove(key);

  /// Invalidates every cached key starting with [prefix] — e.g. all
  /// `products:` listing pages after a mutation that could change them.
  void invalidatePrefix(String prefix) {
    _store.removeWhere((k, _) => k.startsWith(prefix));
  }

  void clear() => _store.clear();
}
