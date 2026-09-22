## Feature
- Feature ID: 06
- Feature Name: saint-of-the-day
- Branch: feature/06-saint-of-the-day

## Summary
- Scope: Adds a "Saint of the Day" screen (`lib/features/saint_of_the_day/`) reachable from a new gold-styled pill on the home shell (REQ-F06-018):
  - Calls OpenRouter directly (`google/gemini-3.1-flash-lite`) with a prompt ported verbatim from the parish's existing Netlify function, using a tolerant regex-section parser (name/feast/bornDied/about/saying/didYouKnow/patronOf/prayer) to turn the model's free-text response into structured content.
  - API key supplied only via `--dart-define=OPENROUTER_API_KEY=...` (never hardcoded); explicit "not configured" failure state when absent.
  - On-device `shared_preferences` cache keyed to `Australia/Sydney` calendar date, behind a swappable interface (Supabase/Firebase deferred — see ADR-0005).
  - Full typed network/parsing/empty/not-configured failure states, no icons/emoji, text-scale-robust layout (3 sizes × 3 text scales swept, no prior coverage existed for this screen before this feature's tester phase added it).
  - Also carries a project-wide Flutter/Gradle/Riverpod toolchain bump (Flutter 3.47.2, Gradle wrapper 9.5.1, Riverpod 2.x -> 3.x, `analyzer` 14.3.0), required during this feature's own coder phase because the original coder-agent environment had no reachable Flutter SDK. See the deployer plan's rollback notes — this feature's merge is not as fully isolated as prior features' were, because of this toolchain change.
- User value: A parish-relevant daily content feature, positioned beside the existing "Ask Luke" pill.

## RISKS — RISK-008 open, shipped as-is by explicit user decision (please read first)

**RISK-008 (new, logged during this feature's verifier phase):** every non-200 OpenRouter response — a bad/expired API key (401), rate limiting (429), a server error (5xx), or a genuine network outage — currently surfaces identically as "Unable to fetch today's saint. Please check your connection and try again." (`openrouter_saint_datasource.dart:76-79`, `saint_of_the_day_screen.dart:37-46`).

This was found via a real incident, not testing: during this feature's own visualiser phase, the first live run appeared to fail with exactly this message; the real cause (a literal placeholder API key string used verbatim, rejected by OpenRouter with a 401) was indistinguishable from a genuine network problem until the underlying `flutter run` command was inspected directly.

**Impact if it recurs in production:** if the real OpenRouter key is ever revoked, expires, or the account runs out of credit, every user sees "check your connection" — a connectivity-sounding message for what is actually a configuration/billing problem needing the parish team's attention, with no in-app signal that anything is misconfigured on the backend side. Medium impact, low day-to-day likelihood, but a plausible and foreseeable event given the already-accepted client-side key exposure trade-off (ADR-0005).

**Explicitly asked, not assumed:** during the deployer phase, the user was asked directly whether to fix this now or ship as-is. **User chose: carry forward / ship as-is.** No code was changed for this risk in this feature. Recommended fix (distinguish 401/403 from other non-2xx responses, surface a distinct configuration-pointing message) is a small, scoped follow-up confined to the datasource and the screen's `_messageFor` branch — suitable as a fast-follow.

**RISK-003 / RISK-004 (pre-existing, from 02-parish-tab/03-multi-pages — confirmed NOT applicable to this feature):**
- Both re-confirmed via `grep` across `lib/features/saint_of_the_day/` this feature's verifier and deployer phases — the only `InkWell`/`onTap` in this feature is the in-app "Try again" retry button, not an external link. Not touched or worsened by this feature. Still open, unrelated, for the app overall (GitHub issue #12).

**RISK-005 (pre-existing, from 03-multi-pages, resolved during 05-news-tab's deployer phase — confirmed to already cover this feature):**
- This feature is the app's third network-calling surface (a raw `POST` to `openrouter.ai`). The release-build Android `INTERNET` permission fixed for News' RSS fetch is unscoped by host, so it already covers this feature's OpenRouter calls too. Independently re-read `android/app/src/main/AndroidManifest.xml` during both the verifier and deployer phases — no manifest change needed or made.

Reviewers: the practical highlight for this PR is RISK-008 — a real, user-confirmed, non-blocking messaging-clarity gap, shipped as a known/accepted risk by explicit user decision. RISK-003/004/005 are informational continuity items, no new decision required.

## Artifacts
- BA Plan: `.claude/plans/ba/2026-09-01_01-34-06-saint-of-the-day.md`
- Coder Plan: `.claude/plans/coder/2026-09-01_02-04-06-saint-of-the-day.md`
- Tester Plan: `.claude/plans/tester/2026-09-10_07-42-06-saint-of-the-day.md`
- App-Visualiser Plan: `.claude/plans/visualiser/2026-09-10_08-39-06-saint-of-the-day.md`
- Verifier Plan: `.claude/plans/verifier/2026-09-10_08-52-06-saint-of-the-day.md`
- Deployer Plan: `.claude/plans/deployer/2026-09-10_09-15-06-saint-of-the-day.md`
- Verification Report: `.claude/verification/2026-09-10_08-52-06-saint-of-the-day.md`
- Release Readiness Note: `.claude/releases/2026-09-10_09-15-06-saint-of-the-day-release-readiness.md` (RISK-008 given standalone, first-read disclosure)
- PR Readiness Note: `.claude/releases/2026-09-10_09-15-06-saint-of-the-day-pr-readiness.md`
- ADR: `.claude/decisions/0005-saint-of-the-day-direct-openrouter-call.md`
- Active Risks: `.claude/risks/active-risks.md` (RISK-003, RISK-004, RISK-005 [resolved/covered], RISK-008 [open, shipped as-is])
- Latest Journal: `.claude/journal/2026-09-10_09-15-06-saint-of-the-day-deployer.md`
- Memory: `.claude/memory.md`

## Validation (user-run this session, fresh, on HEAD `a6b2eb2`)
- Rebased with main: not needed — `git rev-list --left-right --count remotes/origin/main...feature/06-saint-of-the-day` = 0 behind, 7 ahead; `origin/main` confirmed unchanged at `3e1b8da` since 2026-08-30 (News-tab's merge)
- Merge conflicts resolved: n/a (no rebase necessary)
- dart format: pass (`Formatted 133 files (0 changed)`)
- flutter analyze: pass (`No issues found!`)
- flutter test: pass (232/232)
- build validation: pass (`flutter build apk --debug` succeeded; two non-fatal AGP/Kotlin deprecation warnings noted, pre-existing, not blocking)
- All six phase artifacts (BA, coder, tester, visualiser, verifier, deployer) plus the verification report confirmed present on disk this session; all phase approvals confirmed logged in `.claude/memory.md`
- **Note:** this session's cloud-side `device_bash` shell has no GitHub credentials and no `gh` CLI at all — unlike prior features' PR phases, `git fetch`/`gh auth status` could not be independently re-run from here. The user ran `git fetch origin main` directly (interactive browser sign-in) and confirmed the state above. `gh` CLI is also not installed in the user's local environment — the PR itself will need to be opened via the GitHub web UI unless `gh` is installed first.

## Approval
- User approval recorded: pending — this filled template is presented for review before any push or PR-open action is taken.
