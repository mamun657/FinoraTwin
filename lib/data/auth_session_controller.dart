import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositories/auth_repository.dart';

class AuthSessionState {
  const AuthSessionState({this.session, this.loading = false, this.error});

  final AuthSession? session;
  final bool loading;
  final String? error;

  AuthSessionState copyWith({
    AuthSession? session,
    bool? loading,
    String? error,
    bool clearError = false,
    bool clearSession = false,
  }) {
    return AuthSessionState(
      session: clearSession ? null : session ?? this.session,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
    );
  }

  bool get isAuthenticated => session != null;
}

class AuthSessionController extends StateNotifier<AuthSessionState> {
  AuthSessionController(this._repo)
    : super(const AuthSessionState(loading: true)) {
    _bootstrap();
  }

  final AuthRepository _repo;

  Future<void> _bootstrap() async {
    try {
      final session = await _repo.restoreSession();
      state = AuthSessionState(session: session, loading: false);
    } catch (e) {
      state = AuthSessionState(loading: false, error: e.toString());
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final session = await _repo.login(email: email, password: password);
      state = AuthSessionState(session: session);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String businessName,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final session = await _repo.register(
        email: email,
        password: password,
        fullName: fullName,
        businessName: businessName,
      );
      state = AuthSessionState(session: session);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    final refreshToken = state.session?.refreshToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _repo.logout(refreshToken: refreshToken);
      } catch (_) {}
    }
    state = const AuthSessionState();
  }

  Future<void> requestPasswordReset({required String email}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repo.requestPasswordReset(email: email);
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> refresh() async {
    final refreshToken = state.session?.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return;
    try {
      final session = await _repo.refresh(refreshToken: refreshToken);
      state = AuthSessionState(session: session);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

final authSessionControllerProvider =
    StateNotifierProvider<AuthSessionController, AuthSessionState>(
      (ref) => AuthSessionController(ref.watch(authRepositoryProvider)),
    );
