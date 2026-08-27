/// A single parish ministry/group shown on the Ministries tab.
///
/// Typed config per root `CLAUDE.md`'s "typed config over dynamic maps"
/// rule — never a raw/dynamic map.
///
/// [emoji] is retained on the entity for potential future use, but is not
/// rendered by any widget under `lib/features/ministries/presentation/` —
/// an explicit, user-confirmed decision (see the approved BA plan).
class Ministry {
  const Ministry({
    required this.id,
    required this.category,
    required this.emoji,
    required this.name,
    required this.membersLine,
    required this.dayLine,
    required this.tagline,
    required this.time,
    required this.location,
    required this.open,
    required this.about,
    required this.leaderName,
    required this.leaderRole,
    required this.leaderInitials,
    required this.joinInfo,
    required this.ctaLabel,
    required this.ctaEmail,
  });

  /// Stable internal id, e.g. `music`, `sacramental`.
  final String id;

  /// One of the 4 ministry categories (see `ministryCategories`).
  final String category;

  /// Not rendered anywhere in the UI — retained for potential future use.
  final String emoji;

  final String name;

  /// Short line shown on the grid card, e.g. "9 choirs".
  final String membersLine;

  /// Short line shown on the grid card, e.g. "Weekend Masses".
  final String dayLine;

  final String tagline;
  final String time;
  final String location;
  final String open;
  final String about;
  final String leaderName;
  final String leaderRole;
  final String leaderInitials;
  final String joinInfo;
  final String ctaLabel;

  /// Target for the detail screen's `mailto:` "Join Us" CTA, e.g.
  /// `marsdenpark@parracatholic.org?subject=Music Ministry Interest`.
  final String ctaEmail;
}
