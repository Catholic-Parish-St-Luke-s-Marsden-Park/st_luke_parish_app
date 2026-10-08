# DEPLOYER_AGENT Plan

- Feature ID: 08
- Feature Slug: events-calendar
- Branch: feature/08-events-calendar
- Phase: deployer
- Timestamp: 2026-10-08_11-06

## Inputs Reviewed
- Approved verification report: `.claude/verification/2026-10-07_10-22-events-calendar.md` (verdict: CONDITIONAL PASS -- all 39 requirements, REQ-F08-001..039, independently re-verified with complete traceability: 34 direct code+test, 5 correctly retired, 1 correctly amended; the condition was this session's own inability to self-run Flutter commands plus RISK-014 (open) and newly-logged RISK-015)
- Verifier plan: `.claude/plans/verifier/2026-10-07_10-22-events-calendar.md`
- `.claude/risks/active-risks.md` -- RISK-014 (open, carried forward, deferred to a future Coder follow-up), RISK-015 and RISK-016 (both resolved this session, see below), RISK-003/RISK-004 (confirmed to extend to this feature's 2 new `https:` tap targets, still open project-wide), RISK-005 (confirmed already covered)
- Root `CLAUDE.md`
- `.claude/memory.md` (Active State header updated to `deployer`/`DEPLOYER_AGENT` this session, after the post-verifier review-fix round below)
- Prior deployer artifacts for reference format/precedent: `.claude/plans/deployer/2026-09-10_09-15-06-saint-of-the-day.md` and its release/PR readiness notes
- `pubspec.yaml`, `pubspec.lock`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist` (read-only inspection only -- no edits made by this agent)

## Method
1. **Post-verifier review-fix round happened first, before this deployer phase started** (commits `c21ed4c`, `3c7fa93`, `670cd4a`, all already on `feature/08-events-calendar`): the user live-tested "Add to my calendar" on the same Android emulator used throughout the visualiser phase -- the exact live-device confirmation the verifier phase's RISK-015 had flagged as missing -- and found it genuinely broken (the native calendar app failed to open at all). Root-caused to a missing AndroidManifest `<queries>` entry for `ACTION_INSERT`/`vnd.android.cursor.item/event` (Android 11+ package-visibility filtering); fixed. Re-testing after that fix surfaced a second, separate defect (new **RISK-016**): the calendar app now opened but showed the wrong date/time (an 11-hour/next-day error), because this app's internal "fake UTC" `DateTime` representation was passed unconverted into `add_2_calendar`. Fixed by adding `sydneyFakeUtcToRealUtc()` to `ics_event_parser.dart` and using it in `add_to_device_calendar.dart`, with 3 new fixed-date unit tests and tightened widget-test assertions. The user confirmed both fixes live, on-device, after rebuilding -- both risks marked resolved in `active-risks.md`. Full detail in `.claude/memory.md`'s 2026-10-08 (review-fix) log entry.
2. Independently re-read `ios/Runner/Info.plist` this session (read-only) and found it **already** declares `NSCalendarsUsageDescription`, added during the coder phase (commit `2643e9c`, 2026-10-01) -- predating the verifier phase. This mildly corrects the verifier phase's RISK-015 writeup, which stated neither manifest declared anything calendar-related; in fact only the Android side was missing the entry. Not re-opening RISK-015 over this -- it's already resolved and confirmed live -- just noting the correction for the record. No further iOS change needed or made.
3. **Same environment constraint carried through every phase this session**: no Flutter SDK and no GitHub credentials reachable from this cloud-side session, so local validation and the git/rebase check were run by the user and reported back here, mirroring every prior deployer phase in this repo.
4. User-confirmed fresh local validation, 2026-10-08, on HEAD `670cd4a`:
   - `flutter analyze` -- clean
   - `dart format . --set-exit-if-changed` -- `0 changed` (166 files)
   - `flutter test` -- `357 passed / 1 skipped (pre-existing) / 0 failed` (+3 from the new `sydneyFakeUtcToRealUtc` tests, as expected)
   - `flutter build apk --debug` -- succeeded (`build/app/outputs/flutter-apk/app-debug.apk`, Gradle `assembleDebug` in 24.5s)
   - `flutter --version` not captured this round -- flagged as a gap rather than assumed unchanged from the last feature's run.
5. Same environment constraint applies to git/GitHub remote operations: `device_bash` has no GitHub credentials (`git fetch origin main` fails locally with "could not read Username for 'https://github.com'"). User ran it directly: `origin/main` fetched successfully, and `git rev-list --left-right --count origin/main...feature/08-events-calendar` returned **0 behind, 14 ahead**. **No rebase needed.**
6. Checked `gh` CLI availability in this session's own bridge shell (`which gh` / `gh --version`) -- not found there, but that shell is this session's Linux bridge VM, not the user's actual Windows machine, so this is **not** a confirmed answer about the user's own PowerShell environment (unlike 06-saint-of-the-day's deployer phase, which checked this directly in the user's shell). Left genuinely unconfirmed here; flagged for the PR-agent phase to check properly, on the user's own machine, before assuming either way.
7. Ran `git diff --stat main...feature/08-events-calendar` scoped to `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `README.md`, `.gitignore`, `android/`, `ios/` to precisely scope this feature's shared/infra footprint: `android/app/src/main/AndroidManifest.xml` (+16, includes today's `<queries>` fix), `ios/Runner/Info.plist` (+4, `NSCalendarsUsageDescription`), `pubspec.lock` (+34/-1), `pubspec.yaml` (+8: `rrule`, `timezone`, `add_2_calendar`). No `analysis_options.yaml`/`README.md`/`.gitignore` changes -- a narrower, more self-contained footprint than 06-saint-of-the-day's toolchain-bump-carrying branch.
8. Assessed store-facing impact: this feature adds a new inline section to the existing News tab plus a "View all" pagination flow and a Details bottom sheet -- no app store listing content (description, screenshots, keywords, age rating) is affected. The new Android `<queries>` entries (both this feature's and the pre-existing `PROCESS_TEXT` one) and the new iOS `NSCalendarsUsageDescription` are standard, user-facing-permission-prompt-level disclosures, not anything requiring a store-listing change. Per role rules, **no formal store-metadata note is produced**.
9. Did **not** run `prepare-pr`, rebase, push, or open a PR -- per deployer-agent rules, this phase stops at artifact production and waits for user approval.

## Local Validation Evidence (user-run, 2026-10-08, fresh session on HEAD `670cd4a`)

| Command | Result |
|---|---|
| `flutter analyze` | Clean, no issues |
| `dart format . --set-exit-if-changed` | `0 changed` (166 files), exit 0 |
| `flutter test` | `357 passed / 1 skipped (pre-existing) / 0 failed` -- matches the tester phase's count plus the 3 new `sydneyFakeUtcToRealUtc` tests from today's review-fix round |
| `flutter build apk --debug` | Succeeded -- `build/app/outputs/flutter-apk/app-debug.apk` (`assembleDebug`, 24.5s) |
| `git fetch origin main` + `git rev-list --left-right --count origin/main...feature/08-events-calendar` | `0` behind, `14` ahead -- no rebase needed |

No release build (`flutter build apk --release`, `flutter build appbundle`, `flutter build ios --release`) was run this phase, consistent with prior features' precedent (debug-build validation is this phase's bar unless a specific risk needs a release-build check).

## Observations (not filed as a numbered risk)
- iOS's `NSCalendarsUsageDescription` was already present since the coder phase (2026-10-01) -- the verifier phase's RISK-015 writeup slightly overstated the gap by saying neither manifest declared anything calendar-related, when only Android was actually missing its entry. Noted here for the record; both risks are already resolved and confirmed live, so this is not reopened as anything.
- `gh` CLI availability on the user's actual machine is **unconfirmed** this phase (only checked, and not found, in this session's own Linux bridge shell, which is a different environment from the user's Windows PowerShell). Needs a direct check on the user's machine at PR-agent time, same open item 06-saint-of-the-day's deployer phase flagged (that one got a definitive "not installed" answer; this one does not yet).
- `flutter --version` was not captured this round. Not expected to have changed, but flagged rather than assumed.

## Risks Carried Forward
- **RISK-003 / RISK-004** -- confirmed to **extend** to this feature's 2 new `https:` external-link tap targets (website fallback link, Details sheet's optional secondary link), per the verifier phase's addendum. Remain open for the app overall.
- **RISK-005** -- confirmed **applicable and already covered**: the existing unscoped Android `INTERNET` permission already covers this feature's ICS feed fetch. No manifest change needed beyond the `<queries>` entries already made.
- **RISK-014** -- open, carried forward from the Tester phase (in-progress events narrower-than-spec filter). **User decision: defer to a future Coder follow-up**, not fixed in this feature. Disclosed in the release readiness note.
- **RISK-015 / RISK-016** -- both **resolved** this session (see Method, step 1), confirmed live by the user on the same Android emulator used throughout the visualiser phase.

## Outputs
- Deployer plan (this file)
- Release readiness note: `.claude/releases/2026-10-08_11-06-events-calendar-release-readiness.md`
- PR readiness note: `.claude/releases/2026-10-08_11-06-events-calendar-pr-readiness.md`
- (No store preparation note -- this feature does not change store-facing listing content)
- `.claude/memory.md` Latest Session Logs entry for this phase; Active State header to be updated to reflect deployer-phase completion, awaiting user approval
- `.claude/context/feature-index.md` Deployer Plan column to be updated

## Handoff
- Next phase: rebase with `main` (currently a no-op -- branch is already up to date, 0 commits behind), final checks, and PR creation -- only after explicit user approval of this deployer phase.
- Stopping here per deployer-agent rules: no publish, no submit, no push, no PR opened, no `AndroidManifest.xml`/`lib/`/`test/` code modified in this session.
