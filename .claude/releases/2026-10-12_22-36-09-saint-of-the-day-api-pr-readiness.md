# PR Readiness — 09-saint-of-the-day-api

## Merge-to-main checklist (`.claude/git/merge-to-main-checklist.md`)
- [x] Branch created from `main`
- [x] BA phase complete. The user approved it 2026-10-12, with OQ-1..7 answered and D-1..D-8 recorded.
- [x] Coder phase complete. The user approved it, including the tightened 404 mapping.
- [x] Tester phase complete. 48 tests were added, and the `live` tag was introduced.
- [x] App-Visualiser phase complete. It was a live Android emulator render of the success state. The user accepted it on screenshot evidence; RISK-020 records the thin coverage.
- [x] Verifier phase complete: PASS, 23 of 23 requirements traced, user-approved 2026-10-12.
- [x] Deployer phase complete. Artifacts are written, and the phase is awaiting user approval.
- [x] Latest `main` fetched: `origin/main` = `6ef2edd` (2026-10-13)
- [x] Feature branch rebased with latest `main`: not needed (0 behind, 6 ahead)
- [x] Merge conflicts resolved: n/a
- [x] `dart format` completed: 201 files, 0 changed
- [x] `flutter analyze` completed: no issues
- [x] `flutter test` completed: 611 passed, 2 skipped, 0 failed. `--exclude-tags live` gives 606/2/0.
- [x] Build validation completed: `flutter build apk --debug` succeeded. iOS was not built because this is a Windows machine; CI builds it.
- [x] Generated code matches its source: the verifier's clean `build_runner` rebuild left no diff, and `.g.dart` is in the same commit as its provider (`c9e1373`).
- [x] Test summary, verification report, journal and memory updated
- [x] PR description drafted (below)
- [ ] **User approval to push the branch and open the PR.** Not yet given.
- [ ] RISK-019 decision (OpenRouter key revoke, rotate or spend cap). Recommended before merge.

## Suggested PR
- Title: `feat(09): load Saint of the Day from the parish API`
- Base: `main`; head: `feature/09-saint-of-the-day-api`
- No GitHub issue is recorded for this feature. Add `Closes #NN` if one is created.

## Draft PR body

```markdown
## Summary
Saint of the Day now loads from the parish API (`GET {API_BASE_URL}/v1/saints/{date}`, with the date computed on the device in Sydney time) instead of calling OpenRouter from the device. The server already generates each day's saint as structured JSON, so the app no longer needs an AI key, a prompt or a free-text parser.

- The OpenRouter datasource, the free-text parser, the `OPENROUTER_API_KEY` dart-define and the prompt-date helper are removed, with no fallback (ADR-0008 supersedes ADR-0005).
- The per-day on-device cache is kept, with the same storage format.
- Errors are now specific (resolves RISK-008): not ready yet (503 `saint_not_ready`), check your phone's date and time (404 `saint_not_available`), temporarily unavailable (other non-200 responses, including 401 `app_check_required`), no connection, not set up, and something went wrong.
- The screen looks the same. The error view now scrolls so it reflows at large text sizes.
- `dart_test.yaml` adds a `live` tag, and the 3 real-network test files are tagged. Run `flutter test --exclude-tags live` for offline runs.

**Probable user-facing fix (not verified on a store build):** no CI or fastlane step ever passed `OPENROUTER_API_KEY`, so store and TestFlight builds probably showed "Saint of the Day isn't set up on this build yet." The screen now needs only `API_BASE_URL`, which CI already writes.

## Requirements coverage
REQ-F09-001..023: all 23 are traced to code and tests in the verification report (`.claude/verification/2026-10-12_22-36-09-saint-of-the-day-api.md`). Highlights:
- 001-004: endpoint, headers, App Check hook, not-configured handling, OpenRouter removal
- 005-007: RFC 9457 problem parsing, status and code mapping, diagnostics logged and never shown
- 008-014: JSON validation, content guard, cache read and write semantics
- 015-016: UI unchanged, six exact messages, 48dp Try again, reflow at 1.5x and 2.0x
- 017-023: provider wiring, `.g.dart`, docs and risks, `sydney_date` trimmed, tests

## Test results
| Check | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed .` | 0 changed |
| `flutter analyze` | No issues |
| `flutter test` | 611 passed, 2 skipped (opt-in release checks), 0 failed |
| `flutter test --exclude-tags live` | 606 passed, 2 skipped, 0 failed |
| `flutter build apk --debug` | Built |
| Live render (Android emulator, no dart-defines) | Saint Wilfrid, October 12, served from production |

## Configuration
- No dart-defines are needed any more. `assets/app.env` `API_BASE_URL` is already `https://parish-app-service.fly.dev`.
- There are no changes to `.github/workflows/`, `ios/fastlane/`, `android/`, `ios/` or `pubspec.*`.
- Pre-existing and not changed here: the committed `assets/app.env` has `BASE_URL=http://localhost:8080/tokens` (from `c698c41`). The iOS TestFlight workflow overwrites it, but local and Android release builds would ship it, and push registration would fail.

## Risks
- **RISK-019:** the old OpenRouter key may still be live in older installs. Revoke or rotate it, or set a spend cap, in the OpenRouter dashboard.
- **RISK-018:** if parish_app_service moves App Check to `enforce`, Saint of the Day and Ministries break until an App Check build ships. Coordinate with the server owner.
- **RISK-017 (accepted):** the device clock picks the day. A clock more than a day off gets the "check your date and time" message.
- **RISK-007:** a plain `flutter test` still runs the live tests. Excluding them by default is an open decision before CI runs the full suite.
- **RISK-020 (low):** failure states and large font were checked by widget tests only, not on a device.
- **Rollback:** revert the merge commit. A rolled-back build needs a valid OpenRouter key passed at build time to work.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```
