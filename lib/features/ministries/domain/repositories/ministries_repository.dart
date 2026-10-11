import '../entities/ministry.dart';
import '../entities/ministry_category.dart';

/// Contract for loading ministries. Implementations only ever throw
/// `MinistriesFailure` subtypes.
abstract class MinistriesRepository {
  /// Stale-while-revalidate: emits the last saved list first (if any), then
  /// the fresh list once the network responds. If the network fails, the
  /// saved list stands; with nothing saved, the copy bundled with the app is
  /// emitted instead.
  Stream<List<MinistryCategory>> watchMinistries();

  /// Fetches from the network only and saves the result. Throws on failure,
  /// leaving the saved list untouched.
  Future<List<MinistryCategory>> refreshMinistries();

  /// Fetches a single ministry. Throws `MinistryNotFoundFailure` when the id
  /// is unknown or hidden.
  Future<Ministry> getMinistryById(String id);
}
