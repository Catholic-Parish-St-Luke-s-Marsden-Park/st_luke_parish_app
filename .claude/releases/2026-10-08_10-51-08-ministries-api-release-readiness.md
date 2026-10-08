# Release Readiness — 08-ministries-api

- Branch: `feature/08-ministries-api`, 0 behind / 5 ahead of `origin/main` (`aa91b85`) at the time of the deployer phase
- Issue: #24

## What ships
- **Data source:** the Ministries tab and detail screen read from the parish API (`GET /v1/ministries`, `GET /v1/ministries/{id}`) instead of hardcoded config.
- **Offline behaviour:** the last good response is cached on the device, and a bundled snapshot covers a first launch with no network.
- **Pull-to-refresh:** added to the Ministries tab.
- **Join CTA:** builds an encoded `mailto:` from `contactEmail` + `emailSubject`.
- **No visible change:** the snapshot equals the old config field-for-field.

## Configuration required for release
- **`assets/app.env` → `API_BASE_URL=https://parish-app-service.fly.dev`:** already set in this branch. `RELEASE_CHECK=true flutter test test/release_readiness_test.dart` verifies it, and that check passes.
- **Before each release, refresh `assets/ministries_fallback.json`:** use the command in README > Parish API, and review the diff in `ministries_fallback_asset_test.dart` (RISK-012).
- **Unchanged and pre-existing:** `BASE_URL` still holds the emulator URL, and the release check still fails on it. That's tracked under feature 07 and is not a feature 08 item.

## Validation (this session)
| Check | Result |
|---|---|
| `flutter analyze` | No issues |
| `dart format lib test -o none --set-exit-if-changed` | 0 changed |
| `flutter test` | 405 passed, 2 skipped (opt-in release checks) |
| `RELEASE_CHECK=true … release_readiness_test.dart` | `API_BASE_URL` passes; `BASE_URL` fails (pre-existing, emulator URL) |
| `flutter build ios --no-codesign` (release) | ✓ Built `Runner.app` (22.2MB) |
| `flutter run` on an iPhone 17 simulator (debug) | Built and launched cleanly; on-device smoke run of the Ministries flow passed against the live API |
| Android build | Not run: no Android SDK on this machine (same as feature 07) |

## Platform and permissions
- **Android:** no change. The `INTERNET` permission was already added (RISK-005, resolved) and isn't scoped to a host.
- **iOS:** no ATS change needed, because the API is https.
- **Store listing:** no change. No new permissions, and no new data is collected. The cache holds public ministry content only.

## Risks
- **RISK-012 (open):** the bundled snapshot drifts if it isn't refreshed at release time. Low impact, since it's only used on a first launch with no network.
- **RISK-013 (open, pre-existing):** the Ministries grid overflows at 1.5x/2x text size, and the detail hero overflows at 1.0x for "Extraordinary Ministers of Holy Communion". This was reproduced on `main`; feature 08 doesn't change those layouts. A follow-up fix is recommended.
- **Behaviour change:** content now depends on the parish API's availability. When the API is down, users see the cached or bundled copy, not an error. Changes staff publish appear after the next successful fetch, which happens on the next tab open or pull-to-refresh.

## Rollback
- Revert the merge commit. The old `static_ministries_config.dart` comes back from history, and no data migration is involved.
- The orphaned `ministries_cache_v1` `shared_preferences` key does no harm.
