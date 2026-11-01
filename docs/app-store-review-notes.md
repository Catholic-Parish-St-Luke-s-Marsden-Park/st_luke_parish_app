# App Store Review Notes

These are the answers we give App Review about what the app is and how to use it.
Apple asked for them after the first submission was paused under **Guideline 2.1, Information Needed**.
Apple wants the same text in two places:

- the reply to App Review, and
- **App Review Information → Notes** on the version page, so later submissions carry it automatically.

Keep this file and the Notes field in step. The Notes field holds at most 4,000 characters.

| Field | Value |
|---|---|
| Submission | Version 1.0, first sent with build `1.0.0 (1002)`, switched to `1.0.0 (1003)` for the reply |
| Source of 1003 | Commit `db158fc` on `release`. Same `lib/` as `main` at `4974baf`; iPhone only |
| First paused | Guideline 2.1, Information Needed |

The reply describes **build 1003**. Its side menu has four items: Resources, Faith Formation, The Rosary and Divine Mercy Chaplet.
Build 1002 had no Rosary or Divine Mercy screens. Its menu had Prayer Request in their place.
When a newer build goes up, see [Updating for the next build](#updating-for-the-next-build).

## Switching the submission from 1002 to 1003

The video, the reply and the build Apple reviews must all be the same build.

1. App Store Connect → the app → **iOS App 1.0** → **Build**: remove 1002 and select 1003.
   If the Build section is locked, first cancel the open submission from the **App Review** page.
2. Paste the reply text below into **App Review Information → Notes**, then **Add for Review** and resubmit.
3. In the App Review message thread, reply with the same text and attach the video.
   Say that the submission now uses build 1003.

## Before recording: device smoke test

App Review runs the build on physical devices, and a crash brings a "2.1 Bugs" rejection.
Run the exact TestFlight build on an iPhone updated to the latest iOS, and check:

- [ ] Delete the app and reinstall it, so the first-launch notification prompt appears.
- [ ] Every bottom tab loads: Parish, Masses, News, Ministries, Contact and Donate.
- [ ] **Saint of the Day** loads a saint, not an error.
- [ ] News → an event → **Add to my calendar** opens the native sheet.
- [ ] In that sheet, **tap the Location field and type a few letters**. It must not crash.
  The `add_2_calendar` README warns that a missing `NSContactsUsageDescription` can crash here, and `ios/Runner/Info.plist` doesn't have that key.
- [ ] A bulletin PDF opens.
- [ ] Donate by Card opens Safari.
- [ ] Side menu: Resources, Faith Formation ("On Our Knees"), The Rosary (step through a few prayers) and Divine Mercy Chaplet all open.

If anything fails, fix it on its own branch and upload a new build before replying.
The new build number must be higher than the last one uploaded.
The CI lane (`ios/fastlane/Fastfile`) numbers builds by `GITHUB_RUN_NUMBER`, which can be lower than 1003, so pass an explicit build number.

## Screen recording

Apple's requirements for the recording:

- It is made on a physical device running the latest iOS.
- It **starts at launch** and shows the typical user flow.

Setup:

1. Turn on Do Not Disturb.
2. Add Screen Recording to Control Center.
3. Start recording from the Home Screen, then tap the app icon.

Shot list (about 3–4 minutes):

1. Launch → **Allow** notifications.
2. Parish: scroll, expand About, open the Pastoral Plan PDF, go back.
3. Masses: scroll the Mass times.
4. News: open an event's Details, tap Add to my calendar (show the sheet, then cancel), open a bulletin.
5. Ministries: open one ministry.
6. Contact: show the map, tap Call, cancel.
7. Donate: tap Donate by Card to show it opens Safari. This shows nothing is paid for inside the app.
8. Top bar: Saint of the Day, then Ask Luke.
9. Side menu: Resources → Faith Formation (tap "On Our Knees") → The Rosary (Pray the Rosary, a few Next taps) → Divine Mercy Chaplet.

Trim the recording in Photos and AirDrop it to a Mac.
Attach it to the reply in App Store Connect.
The Notes field is text only, so also put an unlisted link to the video there (Google Drive or unlisted YouTube).

## Reply text

Fill in the bracketed values. Paste the text into the reply to App Review and into **App Review Information → Notes**.

```text
1. Screen recording
Attached / link: [LINK]. Recorded on [iPhone model], iOS [version], build 1.0.0 (1003) installed from TestFlight. It starts at launch from the Home Screen and covers every tab, the side menu, Saint of the Day and Ask Luke. The app has no account registration or login, no user-generated content, and no paid content or in-app purchases.

2. Purpose and audience
St Luke's Parish is the official app of the Catholic Parish of St Luke's, Marsden Park (Diocese of Parramatta, NSW, Australia). The parish publishes it under its own developer account. It is for parishioners, families new to the area and visitors. It puts Mass times, upcoming events, weekly bulletins, ministries, contact details and prayer resources in one place that works well on a phone. It also lets the parish send announcements as push notifications. Many parishioners are older, so the app uses large text and simple navigation.

3. How to use it
No login, setup or sample files are needed. Open the app; it starts on the Parish tab.
- Bottom tabs: Parish (about the parish, leadership, parish prayer), Masses (Mass times and parish activities), News (upcoming events with "Add to my calendar", latest bulletin PDFs, prayer request link), Ministries (tap one for details and how to join), Contact (map, phone, email), Donate.
- Top bar: Saint of the Day; Ask Luke (fixed answers to common questions; no free-text input and no AI).
- Menu (top left): Resources and Faith Formation (curated Catholic links, including this month's "On Our Knees" daily readings and reflections), The Rosary (step-by-step guide) and Divine Mercy Chaplet.
Notifications: the app asks once at first launch. Parish staff send notifications from the parish's own server, so a reviewer cannot trigger one, and the app works fully if notifications are declined.
Donations: "Donate by Card" opens the parish's Commonwealth Bank BPOINT payment page in Safari. The app itself collects no money and sells nothing.

4. External services
- stlukesmarsdenpark.org.au: the parish's own website (bulletins RSS feed, events calendar feed, announcements).
- Parish App Service: the parish's own API, hosted on Fly.io (ministries, Saint of the Day, push-token registration). No personal data is sent.
- Firebase Cloud Messaging / Apple Push Notification service: push notifications only. No analytics, advertising or tracking.
- AI: the Saint of the Day text is generated once a day on the parish's server using Google Gemini via OpenRouter. No user data is sent to it, and the app makes no AI calls itself.
- Commonwealth Bank BPOINT: donation page, opened in Safari.
- Google Maps: map preview and directions link. Google Fonts: app typefaces.
- Risen Lord Community (risenlordcommunity.com): the app finds the link to this month's public "Daily Readings & Reflections" PDF, which opens in Safari.
- Links opened in Safari: Vatican News, Catholic Church Australia, Diocese of Parramatta, Bible Gateway, USCCB, FORMED, Word on Fire, CHARIS, The Divine Mercy (thedivinemercy.org) and Mary's Rosary Chain (Rosary prayer card PDF).

5. Regional differences
None. The app works the same in every region. Its content is about one parish in Marsden Park, NSW, Australia, and times are shown in Sydney time.

6. Regulated industry / third-party material
The app is not in a regulated industry. It is published by the Catholic Parish of St Luke's Marsden Park under its own Apple Developer account, and it presents the parish's own content (website, bulletins, events, ministries). Links to other Catholic resources open in Safari. A letter of authorisation from the Parish Priest is available on request.
```

## Other App Store Connect settings to check

On the version page:

- **App Review Information → Sign-in required** is unticked. The app has no accounts.

In the app's settings:

- **App Privacy** declares **Identifiers → Device ID** for the push token. Purpose: App Functionality. Not linked to the user. Not used for tracking.
  The app sends only the token, platform and locale to `POST /v1/devices`.
- The **privacy policy URL** loads.
- The **Content Rights** answer agrees with item 6 above.

Optional: a short letter from the Parish Priest on parish letterhead confirming that the parish publishes the app.
Attaching it strengthens item 6. Without it, item 6 says the letter is available on request.

## Where each claim comes from

When the code changes, re-check these before resubmitting:

| Claim | Source |
|---|---|
| No login, no text input, no in-app purchase | No auth or StoreKit packages in `pubspec.yaml`; no text fields under `lib/` |
| Push is the only Firebase use; no analytics | `lib/core/notifications/notification_service.dart`, `ios/Runner/GoogleService-Info.plist` |
| Donations open in Safari | `lib/features/donate/data/config/donate_config.dart` (`bpointUrl`), `launchExternal` in `donate_screen.dart` |
| Ask Luke has fixed answers, no AI | `lib/features/ask_luke/data/config/ask_luke_topics.dart` |
| Saint of the Day comes from the parish API | `lib/features/saint_of_the_day/data/datasources/saint_of_the_day_remote_datasource.dart`, ADR-0008 |
| The AI model is Google Gemini via OpenRouter | `parish_app_service`: `internal/platform/config/config.go` (`google/gemini-3.1-flash-lite`) |
| "On Our Knees" reads the Risen Lord page | `lib/features/resources/data/datasources/reflections_page_datasource.dart`, ADR-0009 |

## Updating for the next build

When a newer build replaces 1003, check the reply text before submitting.

1. **Item 1:** set the new build number.
2. **Item 3:** if tabs or menu items changed, update the Bottom tabs and Menu lines, and the shot list above.
3. **Item 4:** if the app now talks to a new service or links to a new site, add it.
4. Re-record the video if the user flow changed.
5. Check the reply text is still under 4,000 characters.
