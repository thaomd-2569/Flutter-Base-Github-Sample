import 'package:app/data/model/auth_state.dart';
import 'package:app/data/repository/auth_repository.dart';
import 'package:app/data/repository/auth_repository_impl.dart';
import 'package:app/provider/secure_storage_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(secureStorageProvider));
});

/// Auth State Provider using StateNotifier
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(ref),
);

/// Auth State Notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(this._ref) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  final Ref _ref;

  late final AuthRepository _authRepository = _ref.read(authRepositoryProvider);

  /// Check authentication status on initialization
  Future<void> _checkAuthStatus() async {
    try {
      final token = await _authRepository.getAuthToken();
      if (token != null && token.isNotEmpty) {
        state = AuthState.authenticated(token: token);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(message: e.toString());
    }
  }

  /// Set authenticated state and save token
  Future<void> setAuthenticated(String token) async {
    try {
      await _authRepository.saveAuthToken(token);
      state = AuthState.authenticated(token: token);
    } catch (e) {
      state = AuthState.error(message: e.toString());
    }
  }

  /// Logout - clear authentication
  Future<void> logout() async {
    try {
      await _authRepository.clearAuthData();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(message: e.toString());
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state is AuthStateAuthenticated;

  /// Get current token
  String? get token {
    final currentState = state;
    if (currentState is AuthStateAuthenticated) {
      return currentState.token;
    }
    return null;
  }
}
