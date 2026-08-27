# Journal — Coder phase, 03-multi-pages

2026-08-27_21-41

Implemented all 29 approved requirements (REQ-F03-001..029) for the Ministries, Contact, and Donate tabs, following the `lib/features/parish/` layering pattern from 02-parish-tab (`domain/entities` + `data/config` + `presentation/screens+widgets`, no repositories/providers/datasources for the two static-content tabs).

Key points:
- Ministries: 16 ministries / 4 categories ported verbatim from the sibling reference app into `static_ministries_config.dart`; grid + detail screens built with the `emoji` field intentionally unrendered anywhere (per the twice-corrected user requirement), while remaining on the `Ministry` entity itself.
- Contact: 8 static contact items ported verbatim, in the exact required order/values; static tappable map-preview card + "Open in Google Maps" pill both hand off to an external Google Maps URL (no embedded map SDK).
- Donate: added `webview_flutter: ^4.14.1`, built a reusable `SimpleWebViewScreen` under `lib/shared/webview/` with a loading overlay and a user-visible retry-able error state on main-frame load failure.

Two implementation issues surfaced and were fixed/documented rather than silently worked around:
1. The existing `UrlLauncherServiceImpl` (from 02-parish-tab) validated every URL by requiring a non-empty `Uri.host`. That's correct for `https:` but wrong for `tel:`/`mailto:` (which have no authority component) — reusing it unmodified would have made every new Ministries/Contact tap silently fail. Fixed by scoping the host-required check to `http`/`https` only. Documented as ADR-0002.
2. Donate is a bottom-nav tab body inside `AppShell`'s single shared `Scaffold`/`AppBar` (no per-tab title, established in 02-parish-tab). The BA plan's reference-app-derived description of `SimpleWebViewScreen` implied its own `Scaffold`+`AppBar`, which would have produced a duplicate/nested AppBar when embedded as a tab body. Built `SimpleWebViewScreen` as bare content instead (keeping an unused `title` field for future pushed-route reuse). Documented as ADR-0003.

Also added `CtaPillButton` (`lib/shared/widgets/cta_pill_button.dart`) as a new reusable content-area pill CTA, distinct from the existing `AppPillButton` (which is a translucent-white pill meant for the navy AppBar chrome and would be low-contrast on the light page backgrounds used here).

`flutter analyze` clean; `dart format . --set-exit-if-changed` clean (0 changed) after formatting. `flutter test`: 54 passed, 4 failed — all 4 are pre-existing tests directly affected by this feature's intentional changes (3 placeholder-screen assertions now correctly fail because the placeholders were replaced; 1 AppBar-chrome test crashes when it cycles to the Donate tab because `webview_flutter` requires a registered `WebViewPlatform.instance`, a known Flutter test-harness requirement, not a production bug). Flagged all 4 explicitly for Tester in the coder plan rather than silently leaving them unexplained, consistent with the precedent set in 02-parish-tab's Coder phase.

Did not touch Masses or News tabs, app-level routing, or the shared AppBar chrome — verified via review of the diff.

Coder plan: `.claude/plans/coder/2026-08-27_21-41-03-multi-pages.md`. ADRs: `.claude/decisions/0002-url-launcher-tel-mailto-host-validation.md`, `.claude/decisions/0003-simple-webview-screen-bare-content.md`. No scraping selectors added/changed (static content only) — selector registry left unchanged.

Stopping here per coder-agent rules; did not invoke tester-agent or run phase-close/complete-phase; awaiting user review and approval.
