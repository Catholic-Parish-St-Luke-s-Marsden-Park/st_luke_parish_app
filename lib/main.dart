import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/provider_retry.dart';

void main() {
  runApp(
    // `retry` is not optional-by-omission here: leaving it unset opts the
    // whole app into Riverpod 3.x's automatic retry. See
    // `app/provider_retry.dart` for why this app opts out.
    const ProviderScope(retry: noAutomaticRetry, child: StLukeApp()),
  );
}
