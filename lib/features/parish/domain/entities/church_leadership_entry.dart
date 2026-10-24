/// A single leadership/diocese entry rendered in the Parish tab's Church
/// Leadership section (e.g. Pope Leo XIV, Bishop Vincent Long, Fr Gayan
/// Thamel, Gerald "Ged" Oblea).
///
/// Typed config per root `CLAUDE.md`'s "typed config over dynamic maps"
/// rule — never a raw/dynamic map.
class ChurchLeadershipEntry {
  const ChurchLeadershipEntry({
    required this.name,
    required this.role,
    required this.assetPath,
    this.linkUrl,
    this.about,
    this.linkLabel,
  });

  /// Display name, e.g. "Fr Gayan Thamel".
  final String name;

  /// Display role/title, e.g. "Parish Priest".
  final String role;

  /// Path to the locally bundled image asset (never a network URL).
  final String assetPath;

  /// External URL to launch when this entry is tapped. `null` means the
  /// entry is not tappable/linked (e.g. the Parish Secretary row).
  final String? linkUrl;

  /// A short introduction. When set, the row pulls down to show it, with a
  /// [linkLabel] button to [linkUrl], instead of opening the link on tap.
  final String? about;

  /// The pull-down's button text, e.g. "Visit the Vatican website".
  final String? linkLabel;
}
