# Journal — Coder Phase — 08-ministries-api

- Timestamp: 2026-10-08_10-51
- Branch: `feature/08-ministries-api`

## What was done
- **Implemented REQ-F08-001..020** as set out in `.claude/plans/coder/2026-10-08_10-51-08-ministries-api.md`.
- **Content parity:** `assets/ministries_fallback.json` is a snapshot of the live API. Before `static_ministries_config.dart` was deleted, a temporary test confirmed the snapshot matches it field-for-field (all 16 ministries, same category order, `ctaEmail` equivalence), so switching over changes nothing on screen.
- **Shared validation:** the URL validation was extracted from `NotificationService.resolveBackendUri` into `lib/core/config/backend_uri.dart` instead of being duplicated. The existing `resolveBackendUri` tests pass unchanged.
- **Riverpod 3 details:**
  - The screens use `AsyncValue(:final value?)` pattern matching, so the previous data stays visible during a reload.
  - `refresh()` checks `ref.mounted` before writing state.
- **Fresh validation:** format clean, analyze clean, and `flutter test` 357 passed / 2 skipped.

## Decisions
- ADR-0006 covers stale-while-revalidate with a bundled fallback, the API origin resolution, and reversing REQ-F03-010.

## Outputs
- Coder plan: `.claude/plans/coder/2026-10-08_10-51-08-ministries-api.md`
- ADR: `.claude/decisions/0006-ministries-from-parish-api.md`

## Stopping point
- Condensed SDLC: continue to the tester phase without a stop.
