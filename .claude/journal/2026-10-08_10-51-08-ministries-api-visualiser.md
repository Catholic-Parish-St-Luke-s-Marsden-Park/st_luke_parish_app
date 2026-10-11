# Journal — Visualiser Phase — 08-ministries-api

- Timestamp: 2026-10-08_10-51
- Branch: `feature/08-ministries-api`
- Tester commit: `4f40d95`

## What was done
- Booted an iPhone 17 simulator. The first `simctl` call triggered Xcode's one-time first-launch setup, which took about 10s once it had started.
- Built and launched the real app with `flutter run`: a clean launch, with no exceptions.
- **Problem:** the simulator couldn't be driven by tapping (no `idb`, no `integration_test`). The app's startup notification-permission alert also stuck on screen through terminate and uninstall; a simulator reboot cleared it.
- **Workaround:** a throwaway smoke test run on the device with `flutter run test/_smoke/…`. It exercised the live API, the real `shared_preferences` cache and the bundled fallback, with a screenshot at each step. It passed.
- **Harness fixes to the throwaway file, not to the app:**
  - `flutter_test` mocks HTTP to return 400 even on-device, so the first run silently showed the bundled fallback. The cache was empty, which gave it away. The fix was `HttpOverrides.global = null`.
  - A `SemanticsHandle` assertion from the live binding.
- Deleted the smoke file. Nothing from it is committed.

## Outputs
- Visualiser plan: `.claude/plans/visualiser/2026-10-08_10-51-08-ministries-api.md`
- Screenshots: the session scratchpad only, not committed.

## Stopping point
- Condensed SDLC: continue to the verifier phase without a stop.
