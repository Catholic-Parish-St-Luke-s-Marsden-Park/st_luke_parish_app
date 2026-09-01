# Journal Entry

- Feature ID: 06
- Feature Slug: saint-of-the-day
- Branch: feature/06-saint-of-the-day
- Phase: ba
- Timestamp: 2026-09-01_01-34

## Files Changed
- `.claude/plans/ba/2026-09-01_01-34-06-saint-of-the-day.md` — filled in with full BA plan (Inputs, User-confirmed decisions, Feature Summary, In Scope, Out of Scope, Assumptions, Risks, Unknowns/Open Questions, Acceptance Criteria `REQ-F06-001`..`REQ-F06-018`, Handoff); subsequently updated to fold in the pill-styling decision (see below).
- `.claude/journal/2026-09-01_01-34-06-saint-of-the-day-ba.md` — this entry.

## Commands Run
- Read (this repo): `lib/app/shell/widgets/saint_of_the_day_pill.dart`, `lib/app/shell/widgets/ask_luke_pill.dart`, `lib/app/shell/app_shell.dart`, `lib/features/ask_luke/presentation/screens/ask_luke_screen.dart`, `lib/core/network/http_client_provider.dart`, `lib/shared/widgets/app_pill_button.dart`, `lib/core/theme/app_colors.dart`, `lib/core/theme/app_theme.dart`, `pubspec.yaml`, root `CLAUDE.md` (Architecture Summary, Coding Standards, State Management, Testing Standards, Security and Reliability Rules), `.claude/context/feature-index.md`, `.claude/plans/ba/2026-08-30_19-06-05-news-tab.md` (precedent/template).
- Grep: `git log --all`/`git ls-tree -r` across every branch of this repo for "saint" — confirmed only the existing "coming soon" pill exists; no prior saint-info implementation anywhere in this repo.
- Read (external reference, user-owned GitHub account, private repo `malindafernando-blip/stlukes-marsden-park-app`, granted local folder access this session): `netlify/functions/saint-of-day.mjs` (live, currently-deployed OpenRouter/Gemini call — model, prompt, caching), `stlukes_flutter/lib/services/api_service.dart`, `stlukes_flutter/lib/services/saint_parser.dart`, `stlukes_flutter/lib/widgets/saint_of_day_sheet.dart` (earlier, unfinished Flutter port).
- Checked own persistent memory (`/areas/parish-pwa.md`) for project history, confirming the live PWA/Netlify backend context and that the user (Malinda Fernando) owns the "Saint of the Day integration" workstream.

## Results
- Confirmed the exact reference implementation: OpenRouter `https://openrouter.ai/api/v1/chat/completions`, model `google/gemini-3.1-flash-lite`, a structured prompt requesting 8 labelled sections, `max_tokens: 1000`, `temperature: 0.3`, server-side daily cache (Netlify Blobs, `Australia/Sydney` date key).
- Flagged, not silently carried forward: the reference Netlify function has its OpenRouter API key hardcoded directly in committed source in that other repo — noted as a pre-existing exposure the user should independently rotate, out of scope to fix here.
- User explicitly chose to call OpenRouter directly from this Flutter app (declining the safer zero-client-key alternative of reusing the existing Netlify function), and confirmed Supabase/Firebase is not yet set up, so caching for now is on-device only (`shared_preferences`), built behind a swappable interface.
- Wrote 18 requirement IDs (`REQ-F06-001`..`REQ-F06-018`) covering: direct OpenRouter request shape/headers/prompt, `String.fromEnvironment`-based key handling (not hardcoded, with an explicit "not configured" failure state), typed network/parsing/empty failures, the ported tolerant regex-section parser, date-keyed local cache read/write/eviction behind a swappable interface, full UI state coverage, accessibility (48x48 targets, text-scale reflow), new `shared_preferences` dependency, and required ADR + README documentation.
- Explicitly flagged the client-side-key-exposure risk (a `--dart-define` value is still compiled into the release binary and recoverable from a decompiled app) as a knowingly-accepted trade-off, with recommended mitigations (spend cap on the OpenRouter key; Supabase/Firebase proxy as the real long-term fix) — presented to the user rather than silently shipped.
- **User confirmed a follow-up decision after initial plan delivery:** the "Saint of the Day" pill (already positioned beside "Ask Luke" in the AppBar — no layout change needed) should render with a solid yellow/gold fill. Resolved this using the app's existing `filledButtonTheme` gold-button precedent (`AppColors.gold` background, `AppColors.textPrimary` foreground) rather than an arbitrary new color, keeping the pill's existing icon and label unchanged. Folded into the plan as `REQ-F06-018` and a new scope item (`AppPillButton` gains optional background/foreground color parameters, defaulting to the current style so `AskLukePill` is unaffected).
- Did not write any implementation code.

## Risks / Follow-up
- Client-side OpenRouter key exposure (accepted trade-off) — Coder must implement `String.fromEnvironment` handling and produce the required ADR; not resolved by this phase.
- On-device-only cache means N installs can each trigger their own model call per day (no shared server-side dedupe) — acceptable per explicit user instruction, flagged for future Supabase migration.
- UI presentation beyond the pill (full-screen page, no icons/emoji on the content screen itself) remains this BA phase's one default-not-confirmed assumption — Coder should treat it as decided unless the user overrides at review.
- Second network-capable feature after News (05) — Coder/Tester should re-confirm Android release-build `INTERNET` permission coverage and iOS ATS defaults for the new host (`openrouter.ai`), per the plan's Risks section.

## Next Handoff
- User approved this BA plan (including the pill-styling follow-up). Phase-closed; awaiting `complete-phase` (commit) then CODER_AGENT handoff.
