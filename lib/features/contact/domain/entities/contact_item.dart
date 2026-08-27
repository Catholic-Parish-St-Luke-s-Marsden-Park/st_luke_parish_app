/// External-link action a [ContactItem] triggers when tapped.
enum ContactAction {
  /// Launch a `tel:` URI.
  call,

  /// Launch a `mailto:` URI.
  email,

  /// Launch an `https:` URI externally.
  url,

  /// Not tappable — no action.
  none,
}

/// A single row on the Contact tab (e.g. Phone, Email, Church Address).
///
/// Typed config per root `CLAUDE.md`'s "typed config over dynamic maps"
/// rule — never a raw/dynamic map.
class ContactItem {
  const ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.action,
    this.actionTarget,
    this.subtitle,
  });

  /// Emoji glyph rendered as the tile's leading icon, matching the
  /// reference app's icon-as-string approach.
  final String icon;

  final String label;
  final String value;
  final ContactAction action;

  /// `tel:`/`mailto:`/`https:` target used when [action] is not
  /// [ContactAction.none].
  final String? actionTarget;

  final String? subtitle;
}
