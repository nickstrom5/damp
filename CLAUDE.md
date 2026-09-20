# Damp — notes for Claude Code sessions

iOS app (SwiftUI, iOS 17+). Read `README.md` and `playbook/01-strategy.md` first.

## Build
- The Xcode project is **generated**: `xcodegen generate` (brew install xcodegen). Never commit `Damp.xcodeproj`.
- Any change to targets, files outside existing folders, entitlements or Info.plist keys goes in `project.yml`, then regenerate.
- Build: `xcodebuild build -project Damp.xcodeproj -scheme Damp -destination 'platform=iOS Simulator,name=<an iPhone>' CODE_SIGNING_ALLOWED=NO`
- Tests: same with `test -only-testing:DampTests`.
- CI (`.github/workflows/build.yml`) does exactly this on `macos-26`. Keep it green.
- Screens: launch with `-screenshot <hook|drinks|price|reasons|reveal|goal|first|result|paywall|home|log|milestone|settings|share>`
  to open one screen with seeded data (`Damp/App/ScreenshotMode.swift`). `scripts/capture-screenshots.sh` and the
  `Screenshots` workflow capture all of them and write PNGs to `docs/screenshots/`. Look there before and after UI changes.
- Brand images: `swift scripts/make-brand.swift` regenerates the app icon, `docs/brand/`, and the site's `docs/og.png`, favicons and manifest icons.

## Runtime notes
- No restricted entitlements. Only App Groups (`group.app.usedamp.damp`) for the widget.
- The nightly check-in is a repeating `UNCalendarNotificationTrigger` with two actions (`ReminderManager`).
  The "Dry" action logs without opening the app via the delegate → `AppState.log`.
- StoreKit uses `Damp/Resources/Products.storekit`; product IDs `damp.yearly`, `damp.monthly`, `damp.lifetime`.
  `SIMCTL_CHILD_DAMP_FORCE_PRO=1` unlocks Pro in debug builds.
- All stats are derived (`Stats.compute`) from the log + answers. Never store a streak; recompute it.

- iPhone Duo: `scripts/duo-screenshots.sh` builds, tests and captures every screen on the iPhone Duo simulator
  (Xcode 27.1+, iOS 27.1 runtime). Xcode 27 replaced Simulator.app with **Device Hub**, which also owns the fold
  (pose) control; there is no simctl API for posture, so `--pose closed` waits for you to fold it by hand. With
  Device Hub closed the device reports the outer display; a screenshot that comes back near-black means the app
  had not drawn yet, which is why the script retries.

## Conventions
- One core loop, no feature creep: onboarding → paywall → nightly log → milestone card. New features need a line in
  `playbook/01-strategy.md` explaining which funnel metric they move.
- Every funnel step logs an `AnalyticsEvent`. Add events there, never ad-hoc strings. PostHog is the sink
  when `Config.postHogKey` is set; keep it anonymous (no `identify`, no replay).
- Copy lives in the views. Short, direct, never judgmental. A drinking night is a number, not a failure.
  No "relapse", no "sober" in UI copy. Health-adjacent copy stays factual; no medical claims.
- Dark theme only, tokens in `Damp/Design/Theme.swift`.

## Public vs private
- `docs/` is the published website (GitHub Pages serves every file in it). Only site files go there.
- Strategy and launch notes live in `playbook/`, never in `docs/`: anything in `docs/` is readable by anyone who guesses the URL.
