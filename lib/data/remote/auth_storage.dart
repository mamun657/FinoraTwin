import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authStorageProvider = Provider<AuthStorage>(
  (ref) => throw UnimplementedError('Override in main()'),
);

class AuthStorage {
  AuthStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  final FlutterSecureStorage _storage;

  static const _kAccess = 'finora.access_token';
  static const _kRefresh = 'finora.refresh_token';
  static const _kUserId = 'finora.user_id';
  static const _kUserEmail = 'finora.user_email';
  static const _kUserName = 'finora.user_name';
  static const _kUserRole = 'finora.user_role';
  static const _kUserIsActive = 'finora.user_is_active';

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
    String? fullName,
    String role = 'User',
    bool isActive = true,
  }) async {
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
    await _storage.write(key: _kUserId, value: userId);
    await _storage.write(key: _kUserEmail, value: email);
    if (fullName != null) {
      await _storage.write(key: _kUserName, value: fullName);
    }
    await _storage.write(key: _kUserRole, value: role);
    await _storage.write(key: _kUserIsActive, value: isActive ? '1' : '0');
  }

  Future<String?> readAccessToken() => _storage.read(key: _kAccess);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);
  Future<String?> readUserId() => _storage.read(key: _kUserId);
  Future<String?> readUserEmail() => _storage.read(key: _kUserEmail);
  Future<String?> readUserName() => _storage.read(key: _kUserName);
  Future<String?> readUserRole() => _storage.read(key: _kUserRole);
  Future<bool?> readUserIsActive() async {
    final v = await _storage.read(key: _kUserIsActive);
    if (v == null) return null;
    return v == '1';
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kUserEmail);
    await _storage.delete(key: _kUserName);
    await _storage.delete(key: _kUserRole);
    await _storage.delete(key: _kUserIsActive);
  }
}
