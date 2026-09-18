# Launch checklist

## Day 1 (do these before writing another line of code)

- [ ] Buy `getdamp.app` at Cloudflare Registrar. Then run the runbook in
      `docs/10-site-and-email-runbook.md` (or `CF_TOKEN=… bash scripts/cloudflare-setup.sh`).
- [ ] Create the App ID `app.getdamp.damp` and `app.getdamp.damp.widgets` in the Apple
      Developer portal (matches `project.yml`). Enable **App Groups** (`group.app.getdamp.damp`)
      on both.
- [ ] App Store Connect (full walkthrough in `docs/09-app-store-connect.md`): create the app,
      three in-app purchases matching `Damp/Resources/Products.storekit`
      (`damp.yearly`, `damp.monthly`, `damp.lifetime`), one subscription group, 7-day free trial
      intro offer on yearly.
- [ ] GitHub: push this repo, turn on Pages (Settings → Pages → Deploy from a branch →
      folder `/docs`), custom domain `getdamp.app` (the `docs/CNAME` file already says so),
      tick "Enforce HTTPS" once the certificate appears.
- [ ] Cloudflare Email Routing: `support@getdamp.app` and `hello@getdamp.app` → your inbox.
      Gmail "Send mail as" for replies. Gmail filter → label "Damp support", skip inbox.

No entitlement request. Damp uses no restricted frameworks. That's the whole reason the
timeline is two weeks instead of six.

## Build

```bash
brew install xcodegen
cd damp
xcodegen generate
open Damp.xcodeproj
```

- Select your team in Signing & Capabilities for the app and the widget extension.
- The simulator runs everything: onboarding, paywall (StoreKit config), logging, milestones,
  the widget. Notification *actions* need a physical device to feel right (the simulator shows
  them but the timing is unreliable).
- Use the `Damp` scheme; StoreKit testing is wired to `Products.storekit` so purchases work
  locally without App Store Connect.

## Before submission

- [ ] Replace the hook number ("$2,900": one $8 drink × 365) and the two assumptions in
      `OnboardingAnswers` (150 kcal per drink, 2,000 kcal per day of food) with cited sources
      in the App Store description. Both are standard figures; cite NIAAA for the drink.
- [ ] App Store screenshots: 1) 9pm notification with Dry ✓, 2) home with 12-night streak,
      3) reveal "$4,160 → $2,377 back", 4) milestone card, 5) the one-button first night,
      6) widget. Same order as the onboarding beliefs. `docs/screenshots/` has the raw captures.
- [ ] App Review notes: it's a habit tracker, not a medical app; how to test (any drinks
      number, tap "Tonight's dry", paywall via yearly).
- [ ] Age rating questionnaire: answer "Infrequent/Mild Alcohol, Tobacco, or Drug Use or
      References" honestly. Expect 12+. Do not answer "None"; reviewers check.
- [ ] Analytics: create a free PostHog project, paste the `phc_…` key into `Damp/App/Config.swift`.
      Build the funnel `onboarding_started → first_night_logged → paywall_shown → trial_started → paid`
      and the retention chart on `night_logged`. That funnel is the business.
- [ ] Run onboarding on a real iPhone at 9pm. Wait for the notification. Tap Dry ✓ without
      opening the app. Confirm the streak moved. This is the demo video; it has to work.

## Day of launch

- [ ] Landing page: paste the App Store URL into `APP_STORE_URL` at the bottom of `docs/index.html`.
      The button switches to "Download on the App Store" by itself.
- [ ] Promo codes for creators generated in App Store Connect (Offer Codes).
- [ ] Post the first 10 videos already recorded.
- [ ] Read every review daily. One fix per day for the first two weeks.
