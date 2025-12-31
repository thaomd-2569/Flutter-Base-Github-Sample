import 'package:app/foundation/constants.dart';
import 'package:app/ui/login/login_page_view_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(loginViewModelProvider.notifier);
    final state = ref.watch(loginViewModelProvider);

    final pullToRefreshController = useMemoized(
      () => PullToRefreshController(
        settings: PullToRefreshSettings(
          color: Colors.blue,
        ),
        onRefresh: () async {
          await viewModel.reload();
        },
      ),
    );

    final isLoading = state is LoginUiStateLoading;
    final progress = state is LoginUiStateLoading ? state.progress : 1.0;

    return Scaffold(
      body: SafeArea(
      child: Column(
        children: [
        if (progress < 1.0)
          LinearProgressIndicator(
          value: progress,
          ),
        Expanded(
          child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(Constants.of().loginUrl),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            supportZoom: true,
            useHybridComposition: true,
          ),
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) {
            viewModel.setWebViewController(controller);
          },
          onLoadStart: (controller, url) {
            viewModel.onLoadStart(url);
          },
          onLoadStop: (controller, url) async {
            pullToRefreshController.endRefreshing();
            await viewModel.onLoadStop(url);
          },
          onProgressChanged: (controller, progress) {
            if (progress == 100) {
            pullToRefreshController.endRefreshing();
            }
            viewModel.onProgressChanged(progress);
          },
          onReceivedError: (controller, request, error) {
            pullToRefreshController.endRefreshing();
            viewModel.onLoadError(error.description);
          },
          // shouldOverrideUrlLoading: (controller, navigationAction) async {
          //   final uri = navigationAction.request.url;
          //   if (uri != null) {
          //   if (uri.toString().contains('success') ||
          //     uri.toString().contains('callback')) {
          //     viewModel.onLoginSuccess(uri.toString());
          //     return NavigationActionPolicy.CANCEL;
          //   }
          //   }
          //   return NavigationActionPolicy.ALLOW;
          // },
          ),
        ),
        ],
      ),
      ),
    );
  }
}
