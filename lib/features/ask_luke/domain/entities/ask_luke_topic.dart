/// A single quick-reply topic on the Ask Luke screen: the chip label and
/// its hardcoded placeholder response.
///
/// Typed config per root `CLAUDE.md`'s "typed config over dynamic maps"
/// rule — never inline strings scattered across widget build methods.
class AskLukeTopic {
  const AskLukeTopic({required this.label, required this.response});

  /// Quick-reply chip label, e.g. "Mass times".
  final String label;

  /// Hardcoded placeholder response shown when this topic's chip is
  /// tapped. Flagged as placeholder copy the user is expected to revise;
  /// kept isolated here so that future edit is low-risk and localized.
  final String response;
}
