# Journal Entry

- Feature ID: 09
- Feature Slug: saint-of-the-day-api
- Branch: feature/09-saint-of-the-day-api
- Phase: ba
- Timestamp: 2026-10-12_22-36

## Files Changed
- `.claude/plans/ba/2026-10-12_22-36-09-saint-of-the-day-api.md`: BA plan written, then finalised with the user's answers. Now REQ-F09-001..023, D-1..D-8 and RISK-F09-001..008. Marked user-approved on 2026-10-12.
- `.claude/journal/2026-10-12_22-36-09-saint-of-the-day-api-ba.md`: this entry.

## Commands Run
- No shell commands. I only read files and ran Grep/Glob over the repo:
  - read `CLAUDE.md`, `.claude/memory.md`, `.claude/agents/ba-agent.md` and the feature 08 ministries-api BA plan;
  - read `lib/features/saint_of_the_day/**` (entity, failures, repository, cache, sydney_date, provider, screen) and `MinistriesRemoteDatasource`/`ministries_failure.dart`;
  - grepped for `OPENROUTER` across the repo and `.github/`;
  - grepped RISK-008 in `active-risks.md` and listed `.claude/decisions/`.
- The API contract and live response facts came from the caller, who checked them on 2026-10-12. I did not re-fetch them in this phase.

## Results
- Draft 1 raised 7 open questions. The user answered (verbatim): "1/ remove it completely 2/ keep it 3/ date 4/ recomended 5/ agree 6/ agree 7/ agree".
- OQ-3 went against my recommendation: the app uses `GET /v1/saints/{date}` with `sydneyDateKey(sydneyNow())`, not `/today`. The plan was updated to match:
  - the datasource takes the date key, and the cache lookup and the request use the same key;
  - 404 `saint_not_available` gets a new DateUnavailable failure with a "check your phone's date and time" message (D-8, a BA choice);
  - 400 `invalid_date` maps to the generic Unavailable failure;
  - the device-clock risk is recorded (RISK-F09-002), along with an analysis of the DST rule (RISK-F09-004). That rule's 1-hour error window falls on Sunday morning, about 02:00 to 11:00 Sydney time, so it never changes the requested calendar date. Fixed-time tests are required (REQ-F09-019);
  - the live test calls `/v1/saints/{today's Sydney key}` and skips on 503 `saint_not_ready`.
- `sydneyDisplayDate` and `sydneyFullDateForPrompt` are dropped. `sydneyNow` and `sydneyDateKey` remain.
- Finding: `OPENROUTER_API_KEY` isn't referenced anywhere in `.github/` or fastlane, so CI-built store binaries probably ship without the key and show "isn't set up". Not verified on a store build.
- The next free ADR number is 0008.

## Risks / Follow-up
- Whether to revoke or rotate the existing OpenRouter key is the user's call, outside this feature.
- App Check enforce mode (RISK-F09-003) is shared with feature 08.
- D-8's 404 and 400 mapping is a BA choice the user can still change at Coder handoff.

## Next Handoff
- Approved on 2026-10-12. Next: CODER_AGENT. Not committed in this phase by request.
