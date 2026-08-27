import 'package:flutter/material.dart';

import '../../../../core/constants/external_links.dart';
import '../../../../shared/webview/simple_webview_screen.dart';

/// Donate destination: an in-app WebView loading the parish website's
/// Donate page (`ExternalLinks.donate`). Renders as bare tab-body content
/// inside `AppShell`'s shared `AppBar`/`Scaffold` — no per-tab title, per
/// REQ-F02-016a.
class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleWebViewScreen(url: ExternalLinks.donate);
  }
}
