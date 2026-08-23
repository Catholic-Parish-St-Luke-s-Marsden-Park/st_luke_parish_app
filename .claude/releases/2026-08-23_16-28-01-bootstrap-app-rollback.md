# Rollback Notes — 01-bootstrap-app

- Feature ID: 01
- Feature Slug: bootstrap-app
- Branch: feature/01-bootstrap-app
- Timestamp: 2026-08-23_16-28
- Prepared by: DEPLOYER_AGENT

## Blast Radius
This feature is additive and UI-shell-only. It introduces:
- `lib/app/` — bootstrap, shell, navigation, theme wiring
- `lib/core/theme/`, `lib/core/layout/` — theme tokens and responsive helpers
- `lib/features/*/presentation/screens/` — 8 placeholder screens (Parish, Masses, News, Ministries, Contact, Donate, Resources, Prayer Request)
- `lib/shared/widgets/placeholder_screen.dart` — shared placeholder widget
- `test/` — corresponding unit/widget tests
- Standard Flutter scaffolding (`android/`, `ios/`, `pubspec.yaml`, `.metadata`, `.gitignore`, `analysis_options.yaml`)

No backend calls, no persistence, no scraping logic, and no third-party service integrations are introduced by this feature. There is no data migration, no schema, and no server-side component to roll back — the entire risk surface is a mobile client UI shell.

## Rollback Triggers
Roll back if, after merge:
- `main` fails to build (`flutter build apk` / `flutter build ios`) due to this merge.
- `flutter analyze` or `flutter test` regress on `main` as a direct result of this merge.
- A subsequent feature branch cannot cleanly build against the new shell (e.g. navigation/theme APIs this feature introduces are unstable or contradict the intended architecture).

## Rollback Procedure
Because this is a single, self-contained merge commit (or squash-merge) into `main` with no data/backend side effects:

1. **Preferred:** `git revert <merge-commit-sha>` on `main` — creates a new commit undoing the merge, preserves history, does not rewrite `main`. Safe to do even after other work has landed on top, as long as no other feature has yet built directly on top of the shell APIs this feature introduces.
2. **If revert conflicts** because later features already depend on the new shell (`lib/app/`, theme tokens, `selectedNavIndexProvider`, etc.): do not force-revert. Instead, fix forward — since there is no functional defect in this feature per the verifier's traceability review, a full rollback is unlikely to be the right response to anything short of a build-breaking regression. Prefer a targeted fix commit over reverting a foundational shell that other work already depends on.
3. No database, backend config, feature flags, or store listings are affected by this feature, so there is nothing to roll back outside of the git history/app binary itself. No release has been submitted to any app store for this feature (see store preparation note — submission readiness is explicitly not yet reached), so there is no store rollback (e.g. staged rollout halt, phased release pause) to consider at this stage.

## Residual Risk if Not Rolled Back
Carrying RISK-002 (Android live-run/visual verification, golden tests) forward unresolved is not itself a rollback trigger — it is a coverage gap, not a known defect. If a real visual/rendering defect is later discovered on Android that was masked by this gap, the fix should land as a forward patch to the shell (theme/layout files), not a rollback of the whole feature, since the navigation/state-management scaffolding this feature provides is expected to be a stable foundation other features build on.
