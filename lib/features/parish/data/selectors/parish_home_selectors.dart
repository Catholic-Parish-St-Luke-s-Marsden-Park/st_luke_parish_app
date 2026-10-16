/// How to find one labelled link on a page: the first element matching the
/// CSS [selector] whose visible text contains every phrase in
/// [labelContains] (case-insensitive), reading its [attribute].
///
/// Matching on the label, not the button's styling classes, keeps the
/// lookup working if the parish restyles its home page.
class LabelledLinkSelector {
  const LabelledLinkSelector({
    required this.key,
    required this.selector,
    required this.labelContains,
    this.attribute = 'href',
  });

  /// Stable app-level name, e.g. `pastoral_council_minutes_url`.
  final String key;

  /// CSS selector for the candidate links.
  final String selector;

  /// Phrases the link's text must all contain, in lower case.
  final List<String> labelContains;

  final String attribute;
}

/// Selectors for the parish home page (`https://stlukesmarsdenpark.org.au/`).
/// See `.claude/context/selector-registry.md`.
abstract final class ParishHomeSelectors {
  /// The image in the home page's pop-up (a Beaver Builder / UABB "modal
  /// popup" module), e.g. the "Save the Date" events poster. Lazy-loaded,
  /// so the real address is in `data-src`, with a `<noscript>` copy.
  static const popupImageKey = 'parish_notice_image_url';
  static const popupImage = '.fl-module-modal-popup img';
  static const popupImageAttributes = ['data-src', 'src'];

  /// The home page's "Parish Pastoral Plan 2026-2028" button.
  static const pastoralPlanUrl = LabelledLinkSelector(
    key: 'pastoral_plan_url',
    selector: 'a[href]',
    labelContains: ['pastoral plan'],
  );

  /// The home page's "Parish Pastoral Council Meeting Minutes" button,
  /// which the parish points at the latest minutes after each meeting.
  static const pastoralCouncilMinutesUrl = LabelledLinkSelector(
    key: 'pastoral_council_minutes_url',
    selector: 'a[href]',
    labelContains: ['pastoral council', 'minutes'],
  );
}
