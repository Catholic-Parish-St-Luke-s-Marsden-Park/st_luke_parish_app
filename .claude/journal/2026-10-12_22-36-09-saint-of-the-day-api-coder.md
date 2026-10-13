# Journal — Coder Phase — 09-saint-of-the-day-api

- Timestamp: 2026-10-12_22-36
- Branch: `feature/09-saint-of-the-day-api` (started from clean HEAD `ce86670`)

## What was done
- Implemented REQ-F09-001..023 per `.claude/plans/coder/2026-10-12_22-36-09-saint-of-the-day-api.md`: Saint of the Day now reads `GET {API_BASE_URL}/v1/saints/{sydneyDateKey}` from the parish API; OpenRouter code, parser, dart-define, tests and README section removed.
- Failure model split into six types, one message each; RISK-008 resolved.
- Found and fixed one real layout issue while extending the text-scale sweep: the new "check your date and time" message overflowed the non-scrolling error view by 82px at 2.0x on a 360x690 phone. The error view is now a `SingleChildScrollView`.
- Live test against production passed on 2026-10-12.

## Validation
- `dart format .` 0 changed; `flutter analyze` no issues; `flutter test` 562 passed / 2 skipped / 0 failed.

## Decisions
- ADR-0008 (supersedes ADR-0005).

## Risks
- RISK-008 resolved. Added RISK-017 (device clock picks the day, accepted) and RISK-018 (App Check enforce mode, open).

## Stopping point
- Not committed (main session handles commits). Awaiting user approval before TESTER_AGENT.

## Follow-up at coder handoff (2026-10-12, main session)
- User asked to tighten the 404 mapping ("tighten point 2"): only 404 with problem `code` `saint_not_available` maps to `SaintOfTheDayDateUnavailableFailure`; any other 404 (other code, or no problem body) now maps to `SaintOfTheDayUnavailableFailure`. Changed `saint_of_the_day_remote_datasource.dart` (`_notAvailableCode`), replaced the "404 without a problem body is still DateUnavailable" test with two Unavailable tests (no body; `not_found` code). ADR-0008 and the BA plan REQ-F09-006 table updated to match.
