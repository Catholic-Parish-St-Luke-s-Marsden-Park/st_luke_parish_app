import 'package:flutter/services.dart';

/// The `GET /v1/ministries` snapshot bundled with the app, used on a first
/// launch with no network and nothing saved yet. Refresh it at release time
/// (see README.md > Parish API).
class BundledMinistriesSource {
  BundledMinistriesSource(this._bundle);

  final AssetBundle _bundle;

  static const assetPath = 'assets/ministries_fallback.json';

  Future<String> loadJson() => _bundle.loadString(assetPath);
}
