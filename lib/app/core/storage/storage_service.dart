import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

/// Wraps token persistence (secure storage) and lightweight local
/// key/value cache (GetStorage) behind one service.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final _secure = const FlutterSecureStorage();
  final _box = GetStorage();

  static const _kToken = 'auth_token';
  static const _kCartToken = 'cart_token';
  static const _kDeviceName = 'device_name';

  static Future<void> init() async {
    await GetStorage.init();
  }

  Future<void> saveToken(String token) => _secure.write(key: _kToken, value: token);
  Future<String?> readToken() => _secure.read(key: _kToken);
  Future<void> clearToken() => _secure.delete(key: _kToken);

  Future<void> saveCartToken(String token) => _secure.write(key: _kCartToken, value: token);
  Future<String?> readCartToken() => _secure.read(key: _kCartToken);
  Future<void> clearCartToken() => _secure.delete(key: _kCartToken);

  String get deviceName => _box.read(_kDeviceName) ?? 'Flutter App';
  set deviceName(String v) => _box.write(_kDeviceName, v);

  // Generic key/value cache (non-sensitive), used by CacheService.
  T? read<T>(String key) => _box.read<T>(key);
  Future<void> write(String key, dynamic value) => _box.write(key, value);
  Future<void> remove(String key) => _box.remove(key);
}
