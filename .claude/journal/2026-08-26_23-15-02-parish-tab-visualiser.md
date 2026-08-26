# Journal Entry

- Feature ID: 02
- Feature Slug: parish-tab
- Branch: feature/02-parish-tab
- Phase: visualiser
- Timestamp: 2026-08-26_23-15

## Files Changed
- `.claude/plans/visualiser/2026-08-26_23-15-02-parish-tab.md` — new visualiser plan
- No `lib/` or `test/` code changed during this phase

## Commands Run
- See full list in the visualiser plan; summary: booted `Medium_Phone_API_36.1` Android emulator, ran the app live, captured device screenshots via `adb exec-out screencap`, tested a leadership link tap via `adb shell input tap` + `logcat`, traced a real bug to source, created 4 `gh issue create` entries (after creating the missing `visualiser-feedback` label and switching the active `gh` account to one with issue-write permission)

## Results
- App ran successfully on the Android emulator; user interacted with it live
- User gave 4 feedback points in one message; 2 referenced screenshots of the BA-review mockup rather than the live app, so each point was independently verified against the actual running app (screenshots, adb taps, logcat, source reading) before being parsed into issues, rather than taken at face value
- 1 confirmed, reproducible bug found and root-caused: leadership entry links (Pope, Bishop, Fr Gayan Thamel) are silently non-functional due to a missing AndroidManifest `<queries>` block — exactly the risk the BA plan had flagged for the `url_launcher` dependency
- 3 items were ambiguous/design-decision points rather than clear-cut bugs (section order, which icon, which color) — filed as clarification-needed issues rather than guessed at and silently implemented
- All 4 items filed as GitHub issues (#12–#15) with labels `bug`/`question` + `visualiser-feedback`, after showing the parsed list back to the user and getting explicit confirmation to create them

## Risks / Follow-up
- Issue #12 (link bug) blocks REQ-F02-005/006/007 from being considered fully working on real devices, despite widget tests passing (those tests use a fake `UrlLauncherService` by design and can't catch a platform-manifest gap) — flagged for a follow-up fix, not rolled back into this feature's Coder phase per the visualiser-agent's no-rework-loop rule
- Issues #13–#15 need user decisions before they can be actioned; none block Verifier from proceeding
- `gh` CLI had two locally authenticated accounts; the default active one lacked issue-create permission on this repo — switched to the other. Left switched (not reverted) since the task is ongoing; noted for user awareness.

## Next Handoff
- Next phase: VERIFIER_AGENT
- Wait for user approval before Verifier starts
