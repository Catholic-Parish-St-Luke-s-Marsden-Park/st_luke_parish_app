import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Reusable in-app WebView content: a full-page [WebViewWidget] loading
/// [url], a loading overlay while the page is loading, and a user-visible
/// error state if the main-frame load fails (e.g. no network). Genuinely
/// reusable across features (not tied to Donate) per root `CLAUDE.md`'s
/// `lib/shared/` guidance.
///
/// Deliberately renders bare content only, with no own `Scaffold`/`AppBar`:
/// this app's bottom-nav tabs (including Donate) render inside a single
/// shared `AppBar`/`Scaffold` owned by `AppShell` (established in
/// 02-parish-tab, REQ-F02-016a) — a second, nested `AppBar` here would
/// duplicate that chrome. [title] is accepted for callers that push this
/// widget as its own route (outside the bottom-nav shell) and want an
/// `AppBar` of their own; it is not rendered by this widget itself.
class SimpleWebViewScreen extends StatefulWidget {
  const SimpleWebViewScreen({super.key, required this.url, this.title});

  /// Optional title for callers that wrap this widget in their own
  /// `Scaffold`/`AppBar` when pushing it as a standalone route.
  final String? title;
  final String url;

  @override
  State<SimpleWebViewScreen> createState() => _SimpleWebViewScreenState();
}

class _SimpleWebViewScreenState extends State<SimpleWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.cream)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            // Ignore subresource errors (e.g. a blocked third-party
            // script); only treat a main-frame load failure as a
            // user-visible error state.
            if (error.isForMainFrame == false) return;
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_hasError) WebViewWidget(controller: _controller),
        if (_hasError) _WebViewErrorState(onRetry: _retry),
        if (_isLoading && !_hasError)
          const ColoredBox(
            color: AppColors.cream,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryNavy),
            ),
          ),
      ],
    );
  }
}

class _WebViewErrorState extends StatelessWidget {
  const _WebViewErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.cream,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load this page',
                textAlign: TextAlign.center,
                style: AppTypography.display(fontSize: 18),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Try Again')),
            ],
          ),
        ),
      ),
    );
  }
}
