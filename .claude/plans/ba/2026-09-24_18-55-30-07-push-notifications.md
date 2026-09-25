# BA_AGENT Plan

- Feature ID: 07
- Feature Slug: push-notifications
- Branch: feature/07-push-notifications
- Phase: ba (retrospective)
- Timestamp: 2026-09-24_18-55

> **Retrospective artifact.** Feature 07 was built outside the SDLC flow: there was no BA, coder, tester, visualiser or verifier phase, and PR #22 was opened directly. The PR #22 re-review (2026-09-23, finding N6) flagged the missing artifacts. This plan records the scope that was actually built and then agreed with the user during the 2026-09-24 review-fix session, so that the verifier phase has requirements to trace against. It does not approve anything retroactively. The user approved the scope decisions listed below in-session.

## Inputs
- Root `CLAUDE.md`, including the Phase 2 note that a backend may be introduced for notification features.
- `.claude/memory.md`.
- PR #22 and both of its reviews: CHANGES_REQUESTED on 2026-09-21 and 2026-09-23.
- The branch as pushed by the author (`089082e`) and the review-fix commits `35f9dbd..59edd6a`.

## User-confirmed decisions this session (not open questions)
- **Crashlytics is removed** from this feature. It was out of scope and brings privacy-label and Data Safety work. It may return in its own PR.
- **Tap routing is removed** for now. A notification tap only opens the app. The payload is still written so routing can be added later.
- **Package upgrades are in scope.** Firebase, flutter_local_notifications, flutter_dotenv and firebase-admin move to their latest stable versions, per CLAUDE.md.
- **The fixes go directly on the author's branch**, so PR #22 updates in place.

## Feature Summary
Parishioners receive push notifications from the parish on Android and iOS. The app registers its FCM token with a small Node.js backend (`server/`), which stores tokens in Firestore. A parish admin sends pushes to one device (`/send`) or to all devices (`/broadcast`) using a shared API key.

## In Scope
- Firebase initialisation and FCM on Android and iOS: permission request, the foreground display path, a background/terminated handler, and APNs entitlements per build configuration.
- Token registration with retry/backoff, a cache keyed on `token@origin`, and re-registration on token refresh.
- `BASE_URL` configuration in `assets/app.env`, with release-mode https enforcement and an opt-in release check.
- The Node.js backend: `/tokens` (unauthenticated, rate limited), `/send` and `/broadcast` (API key), `/health`, and pruning of stale tokens.
- README documentation for setup, testing and troubleshooting.

## Out of Scope
- Deep-link or tap routing to specific screens.
- Crashlytics or any other crash reporting.
- Topic subscriptions UI, notification preferences screen and an in-app inbox.
- An admin UI for sending pushes (the admin uses Postman or curl).
- Supabase. CLAUDE.md anticipated Supabase for Phase 2 notifications. This feature uses Firebase and Firestore instead, and that is recorded as a risk (RISK-011) rather than being re-litigated here.

## Assumptions
- Firebase client config files (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) contain only public client identifiers and are safe to commit.
- iOS delivery cannot be verified on a device until an Apple developer account and APNs key are in place.

## Risks
- See `.claude/risks/active-risks.md`: RISK-009 (iOS on-device delivery unverified), RISK-010 (unauthenticated `/tokens` endpoint) and RISK-011 (backend choice and singleton outside Riverpod).

## Unknowns / Open Questions
- The production backend host and URL (the README suggests Render). `assets/app.env` still holds the emulator URL, and the release check gates it.

## Acceptance Criteria

### Delivery
- `REQ-F07-001`: An Android push appears exactly once in the foreground, background and terminated states. The server sends data-only messages at high priority, and the app posts the notification.
- `REQ-F07-002`: An iOS push is visible in every app state. The server includes an APNs `alert`, and foreground presentation options are set.
- `REQ-F07-003`: Notifications use the `app_channel` Android channel, created at startup, with the default sound and no missing custom-sound resource.
- `REQ-F07-004`: Notification IDs are always within the signed 32-bit range.

### Startup safety
- `REQ-F07-005`: No failure in dotenv, Firebase or notification initialisation prevents `runApp`. Permission and registration never delay the first frame.

### Registration
- `REQ-F07-006`: `BASE_URL` that is missing, malformed, unloaded, or non-https in release sends no request, and the reason is logged.
- `REQ-F07-007`: Token registration retries with backoff and gives up after a bounded number of attempts. A failure is logged and is not cached.
- `REQ-F07-008`: An unchanged `token@origin` pair is not re-sent. A new token or a new backend origin re-registers.
- `REQ-F07-009`: Token refresh re-registers, and errors in the refresh handler are caught.

### Platform configuration
- `REQ-F07-010`: iOS uses `aps-environment` development for Debug and production for Release/Profile.
- `REQ-F07-011`: The Android manifest declares `POST_NOTIFICATIONS` and has the FCM default channel/icon meta-data under `<application>`.
- `REQ-F07-012`: The iOS plugins resolve through SwiftPM, and `Package.resolved` pins are committed.

### Server
- `REQ-F07-013`: `/tokens` validates the token format, upserts it idempotently and is rate limited.
- `REQ-F07-014`: `/send` and `/broadcast` require the API key (timing-safe compare) and validate `title`, `body` and `data`.
- `REQ-F07-015`: `/broadcast` batches in groups of 500. `/send` and `/broadcast` prune stale tokens.
- `REQ-F07-016`: Server route tests run with `npm test` without Firebase credentials.

### Quality gates
- `REQ-F07-017`: `dart format`, `flutter analyze` and `flutter test` are clean, and the packages are at their latest stable versions.
- `REQ-F07-018`: A release-readiness check fails if `BASE_URL` is the emulator loopback address or is not https.

## Handoff
Next phase: VERIFIER_AGENT. The retrospective traceability pass is at `.claude/verification/2026-09-24_18-55-30-07-push-notifications.md`.
