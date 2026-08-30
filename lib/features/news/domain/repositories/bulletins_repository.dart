import '../entities/bulletin.dart';

/// Sole access point for bulletin data (REQ-F05-011). Screens/widgets read
/// bulletins only through the presentation-layer provider that wraps this
/// contract — never by importing a datasource or parser directly.
///
/// Implementations must convert network/parsing failures into a
/// [BulletinsFailure] subtype (see `../failures/bulletins_failure.dart`)
/// rather than letting a raw exception escape.
abstract class BulletinsRepository {
  /// Fetches, parses, validates, and sorts (newest-first) up to 6 bulletins.
  Future<List<Bulletin>> getBulletins();
}
