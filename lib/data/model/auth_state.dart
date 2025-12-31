import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/auth_state.freezed.dart';

/// Authentication state model
@freezed
sealed class AuthState with _$AuthState {
  /// Initial state - checking authentication status
  const factory AuthState.initial() = AuthStateInitial;

  /// User is authenticated
  const factory AuthState.authenticated({
    required String token,
  }) = AuthStateAuthenticated;

  /// User is not authenticated
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  /// Error occurred during authentication check
  const factory AuthState.error({
    required String message,
  }) = AuthStateError;
}
