import 'package:app/data/model/auth_state.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/route/app_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Guard to protect routes that require authentication
class AuthGuard extends AutoRouteGuard {
  AuthGuard(this._ref);

  final Ref _ref;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final authState = _ref.read(authStateProvider);

    authState.when(
      initial: () {
        // Wait for auth state to be determined
        resolver.next(false);
      },
      authenticated: (_) {
        // User is authenticated, allow navigation
        resolver.next(true);
      },
      unauthenticated: () {
        // User is not authenticated, redirect to login
        router.push(const LoginRoute());
        resolver.next(false);
      },
      error: (_) {
        // Error occurred, redirect to login
        router.push(const LoginRoute());
        resolver.next(false);
      },
    );
  }
}
