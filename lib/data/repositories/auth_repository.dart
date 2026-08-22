import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../remote/api_client.dart';
import '../remote/auth_storage.dart';

class AuthSession {
  AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    this.fullName,
    this.expiresAt,
    this.role = 'User',
    this.isActive = true,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final String? fullName;
  final DateTime? expiresAt;
  final String role;
  final bool isActive;

  bool get isAdmin => role.toLowerCase() == 'admin';
}

class AuthRepository {
  AuthRepository(this._api, this._storage);
  final ApiClient _api;
  final AuthStorage _storage;

  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    required String businessName,
  }) async {
    final response = await _api.post(
      '/api/v1/auth/register',
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'businessName': businessName,
      },
    );
    return _persist(response as Map<String, dynamic>);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      '/api/v1/auth/login',
      body: {'email': email, 'password': password},
    );
    return _persist(response as Map<String, dynamic>);
  }

  Future<AuthSession> refresh({required String refreshToken}) async {
    final response = await _api.post(
      '/api/v1/auth/refresh',
      body: {'refreshToken': refreshToken},
    );
    return _persist(response as Map<String, dynamic>);
  }

  Future<void> logout({required String refreshToken}) async {
    try {
      await _api.post(
        '/api/v1/auth/logout',
        body: {'refreshToken': refreshToken},
      );
    } catch (_) {
    } finally {
      await _storage.clear();
    }
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _api.get('/api/v1/auth/me');
    return response as Map<String, dynamic>;
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _api.post('/api/v1/auth/forgot-password', body: {'email': email});
  }

  Future<AuthSession?> restoreSession() async {
    final access = await _storage.readAccessToken();
    final refresh = await _storage.readRefreshToken();
    final id = await _storage.readUserId();
    final email = await _storage.readUserEmail();
    final name = await _storage.readUserName();
    final role = await _storage.readUserRole();
    final active = await _storage.readUserIsActive();
    if (access == null || refresh == null || id == null || email == null) {
      return null;
    }
    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      userId: id,
      email: email,
      fullName: name,
      role: (role == null || role.isEmpty) ? 'User' : role,
      isActive: active ?? true,
    );
  }

  Future<AuthSession> _persist(Map<String, dynamic> response) async {
    final user = (response['user'] as Map<String, dynamic>?) ?? const {};
    final roleRaw = (user['role'] as String?) ?? 'User';
    final isActiveRaw = user['isActive'];
    final isActive = isActiveRaw is bool
        ? isActiveRaw
        : (isActiveRaw is String
            ? isActiveRaw.toLowerCase() == 'true'
            : true);
    final session = AuthSession(
      accessToken: response['accessToken'] as String,
      refreshToken: response['refreshToken'] as String,
      userId: (user['id'] ?? response['userId'] ?? '').toString(),
      email: (user['email'] as String?) ?? '',
      fullName: user['fullName'] as String?,
      expiresAt: response['accessTokenExpiresAt'] is String
          ? DateTime.tryParse(response['accessTokenExpiresAt'] as String)
          : null,
      role: roleRaw,
      isActive: isActive,
    );
    await _storage.saveSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userId: session.userId,
      email: session.email,
      fullName: session.fullName,
      role: session.role,
      isActive: session.isActive,
    );
    return session;
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(authStorageProvider),
  ),
);
