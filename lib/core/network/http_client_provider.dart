import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Shared [http.Client] provider for feature datasources that make network
/// requests. Kept in `core/` (cross-cutting networking primitive per root
/// `CLAUDE.md`) so future features fetching remote content can reuse it
/// rather than each constructing/disposing their own client. This is the
/// app's first real network-capable feature (News/bulletins); no other
/// feature depends on this yet.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});
