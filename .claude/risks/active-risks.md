# Active Risks

Log active technical, scraping, or delivery risks here. Add one entry per risk; move resolved risks to a "Resolved" section instead of deleting them.

## Template

- **Risk ID:** RISK-XXX
- **Title:**
- **Feature:** (feature ID/slug this risk relates to, if any)
- **Impact:**
- **Likelihood:**
- **Mitigation:**
- **Owner:**
- **Status:** open / mitigated / accepted / closed

## Open Risks

_None currently open._

## Resolved Risks

- **Risk ID:** RISK-002
- **Title:** REQ-F01-001 (themed shell) and REQ-F01-006 (no overflow/clipping) are not fully end-to-end verified
- **Feature:** 01-bootstrap-app
- **Impact:** Low-medium for this bootstrap slice; would grow if left unaddressed as real feature content lands. Android build succeeded (confirmed by verifier) but had not been run/visually confirmed on an Android emulator or device by any phase. Separately, the REQ-F01-006 overflow/clipping test suite only catches Flutter's exception-raising layout failures (`RenderFlex overflowed`, etc.) — silent visual clipping that fits within bounds without throwing an exception would not be caught, since no golden-image tests exist yet.
- **Likelihood:** Was medium — shell-only slice has low visual complexity today, but risk would grow as real feature screens replace placeholders.
- **Mitigation:** 2026-08-23: Booted Android emulator `Medium_Phone_API_36.1` (API 36), installed debug APK, launched the app live via `adb`/`monkey`. Confirmed: Parish home screen renders with themed shell (navy/gold, church icon, serif title); tapping the "Masses" bottom-nav tab correctly switches app bar title/icon/content to "Masses & Events" and highlights the active tab; the navigation drawer opens showing "St Luke's Parish" header plus Resources/Prayer Request entries. `adb logcat -d "*:E"` showed no Flutter/app errors or crashes during the session — only unrelated Play Store (Finsky) noise. This closes the Android live-run visual-verification gap. Golden-image tests remain intentionally deferred until placeholder screens are replaced by stabilized real feature UI (per root `CLAUDE.md`'s "stable, important UI states" guidance and the BA/coder plans' own note that placeholders will be reworked) — tracked as follow-up work for the next feature slice, not a residual risk on this one.
- **Owner:** Deployer (verified 2026-08-23); Tester/Coder for the next feature slice owns golden-test follow-up
- **Status:** resolved (Android live-run verified 2026-08-23; golden-test follow-up deferred by design, not a blocking risk)

- **Risk ID:** RISK-001
- **Title:** Orchestrator `complete-phase` step is not committing implementation/test code across phase transitions
- **Feature:** 01-bootstrap-app
- **Impact:** High for auditability/traceability. Across the ba -> coder -> tester -> verifier phase transitions on `feature/01-bootstrap-app`, only `.claude/plans .claude/journal .claude/verification .claude/memory.md` had been committed at each phase-close (commits `92b5c27`, `09bf292`, `d18bcb0` were docs/feat/test commits containing plan+journal artifacts only, despite messages implying code landed). The actual application source (`lib/`, `test/`, `pubspec.yaml`, `pubspec.lock`, `android/`, `ios/`, `.metadata`, `.gitignore`, `analysis_options.yaml`) had never been committed and remained untracked in the working tree, confirmed via `git status` as of the verifier phase (2026-08-23_16-10).
- **Likelihood:** Was certain (already occurred); would have recurred on every future feature without the fix.
- **Mitigation:** Fixed 2026-08-23: backfilled the missing implementation/test code in commit `ac86f4c`, and patched `agent_orchestrator.sh`'s `complete_phase()` to `git add -A` (staging the full working tree, not just `.claude/` bookkeeping) plus added a dirty-working-tree guard to `prepare_pr()` so it refuses to rebase over uncommitted work.
- **Owner:** Orchestrator/process owner
- **Status:** resolved (user-directed fix, 2026-08-23)
