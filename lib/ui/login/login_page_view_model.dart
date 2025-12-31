import 'package:app/data/model/auth_state.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/route/app_router.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

final StateNotifierProvider<LoginViewModel, LoginUiState> loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginUiState>(
      (ref) => LoginViewModel(ref),
    );

class LoginViewModel extends StateNotifier<LoginUiState> {
  LoginViewModel(this._ref) : super(const LoginUiStateInitial());

  final Ref _ref;

  InAppWebViewController? _webViewController;

  void setWebViewController(InAppWebViewController controller) {
    _webViewController = controller;
    final currentState = state;
    if (currentState is LoginUiStateLoading) {
      state = currentState.copyWith(webViewController: controller);
    }
  }

  void onLoadStart(WebUri? url) {
    state = LoginUiStateLoading(
      currentUrl: url?.toString() ?? '',
      progress: 0.0,
      webViewController: _webViewController,
    );
  }

  Future<void> onLoadStop(WebUri? url) async {
    // Check for authentication cookie
    if (_webViewController != null && url != null) {
      final cookieManager = CookieManager.instance();
      final cookies = await cookieManager.getCookies(url: url);

      // Look for the auth cookie
      final authCookie = cookies.firstWhere(
        (cookie) => cookie.name == '__Secure-HQ-AUTH',
        orElse: () => Cookie(name: '', value: ''),
      );

      // Check if user is currently authenticated
      final currentAuthState = _ref.read(authStateProvider);
      final isCurrentlyAuthenticated = currentAuthState is AuthStateAuthenticated;

      if (authCookie.value != null && authCookie.value.toString().isNotEmpty) {
        // Authentication successful
        await onLoginSuccess(authCookie.value.toString());
        return;
      } else if (isCurrentlyAuthenticated) {
        // Auth cookie was cleared (logout detected) and user was authenticated
        await onLogoutSuccess();
        return;
      }
    }

    state = LoginUiStateLoaded(
      currentUrl: url?.toString() ?? '',
      webViewController: _webViewController,
    );
  }

  void onProgressChanged(int progress) {
    final currentState = state;
    if (currentState is LoginUiStateLoading) {
      state = currentState.copyWith(
        progress: progress / 100.0,
      );
    }
  }

  void onLoadError(String error) {
    state = LoginUiStateError(
      message: error,
      currentUrl: state is LoginUiStateLoading ? (state as LoginUiStateLoading).currentUrl : '',
    );
  }

  Future<void> onLoginSuccess(String authToken) async {
    // Save the auth token and update authentication state
    // This will notify all listeners (widgets) about the auth state change
    await _ref.read(authStateProvider.notifier).setAuthenticated(authToken);

    // Navigate to home page after successful authentication
    // _ref.read(appRouterProvider).replaceAll([const HomeRoute()]);
  }
  Future<void> onLogoutSuccess() async {
    // Clear the auth token and update authentication state
    await _ref.read(authStateProvider.notifier).logout();

    // Navigation will be handled by AuthGuard redirecting to login
  }
  Future<void> reload() async {
    if (_webViewController != null) {
      await _webViewController!.reload();
    }
  }

  Future<void> goBack() async {
    if (_webViewController != null) {
      final canGoBack = await _webViewController!.canGoBack();
      if (canGoBack) {
        await _webViewController!.goBack();
      }
    }
  }

  Future<void> goForward() async {
    if (_webViewController != null) {
      final canGoForward = await _webViewController!.canGoForward();
      if (canGoForward) {
        await _webViewController!.goForward();
      }
    }
  }
}

/// Sealed class for Login UI states
sealed class LoginUiState {
  const LoginUiState();
}

/// Initial state - before loading
class LoginUiStateInitial extends LoginUiState {
  const LoginUiStateInitial();
}

/// Loading state - web page is loading
class LoginUiStateLoading extends LoginUiState {
  const LoginUiStateLoading({
    required this.currentUrl,
    this.progress = 0.0,
    this.webViewController,
  });

  final String currentUrl;
  final double progress;
  final InAppWebViewController? webViewController;

  LoginUiStateLoading copyWith({
    String? currentUrl,
    double? progress,
    InAppWebViewController? webViewController,
  }) {
    return LoginUiStateLoading(
      currentUrl: currentUrl ?? this.currentUrl,
      progress: progress ?? this.progress,
      webViewController: webViewController ?? this.webViewController,
    );
  }
}

/// Loaded state - web page loaded successfully
class LoginUiStateLoaded extends LoginUiState {
  const LoginUiStateLoaded({
    required this.currentUrl,
    this.webViewController,
  });

  final String currentUrl;
  final InAppWebViewController? webViewController;
}

/// Error state - loading failed
class LoginUiStateError extends LoginUiState {
  const LoginUiStateError({
    required this.message,
    this.currentUrl = '',
  });

  final String message;
  final String currentUrl;
}
