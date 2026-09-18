# App Store Connect setup, step by step

Do these in order. Steps 1–2 are on developer.apple.com, the rest on appstoreconnect.apple.com.
Total time about 60 minutes if the Developer Program is already active.

## 1. Developer Program

- Enroll at developer.apple.com/programs ($99/yr). Individual is fine to start; you can
  transfer to a company later. Approval is usually same-day, sometimes 48 hours.

## 2. Identifiers (developer.apple.com → Certificates, Identifiers & Profiles → Identifiers)

Create two App IDs, explicit (not wildcard):

| Bundle ID | Description | Capabilities to tick |
|---|---|---|
| `app.usedamp.damp` | Damp | App Groups |
| `app.usedamp.damp.widgets` | Damp Widgets | App Groups |

Then Identifiers → App Groups → register `group.app.usedamp.damp`, and assign it to both
App IDs (edit each App ID → App Groups → Configure). No special entitlements are needed.

## 3. Create the app record (App Store Connect → My Apps → +)

- Platform: iOS. Name: **Damp** (this is the reserved App Store name; if it's taken, use
  "Damp: Drink Less"). Primary language: English (U.S.).
- Bundle ID: `app.usedamp.damp`. SKU: `damp-ios`. User access: Full.

## 4. Agreements, tax and banking (App Store Connect → Business)

- Accept the **Paid Apps Agreement**. Without it, in-app purchases won't load in TestFlight or
  production, and purchases fail with an unhelpful error.
- Add a bank account and complete the US tax form (W-9 if US-based). Payouts start 45 days
  after the end of the month a sale happens.
- Under Business → Small Business Program, apply. Apple's cut drops from 30% to 15% while
  revenue is under $1M/yr. Takes a few days, worth doing now.

## 5. In-app purchases (My Apps → Damp → Monetization → Subscriptions / In-App Purchases)

**Subscription group** "Damp Pro". Both subscriptions go in it.

| Reference name | Product ID | Type | Price (US) | Intro offer |
|---|---|---|---|---|
| Yearly | `damp.yearly` | Auto-renewable, 1 year | $29.99 | Free trial, 7 days, all territories, new subscribers |
| Monthly | `damp.monthly` | Auto-renewable, 1 month | $5.99 | none |
| Lifetime | `damp.lifetime` | Non-consumable | $49.99 | n/a |

Product IDs must match `Damp/Services/StoreManager.swift` exactly.

For each product:
- Subscription level: Yearly = 1, Monthly = 2 (same group, yearly ranks higher so upgrades
  from monthly are treated as upgrades).
- Localization (en-US): display name "Damp Yearly" / "Damp Monthly" / "Damp Lifetime",
  description one line ("Full access, billed yearly." etc.).
- Review screenshot: any screenshot of the paywall from the simulator
  (`docs/screenshots/paywall.png`). Required before submission, ignored by users.
- Subscription group localization: name "Damp Pro", app name "Damp".

Price: choose the US price and let Apple's pricing equalize other territories.

## 6. App Privacy (App Store Connect → Damp → App Privacy)

Answer honestly for the analytics setup in `Config.swift`:
- Data collected: **Product Interaction** and **Crash Data** (PostHog lifecycle + funnel events)
  → "Analytics" purpose, **not** linked to identity, **not** used for tracking.
- Health data: **not collected.** The drinks count never leaves the device and is not written
  to HealthKit. Say so in the review notes if asked.
- Privacy policy URL: https://usedamp.app/privacy.html

## 7. App information

- Category: Health & Fitness (primary), Lifestyle (secondary).
- Age rating: questionnaire → Alcohol, Tobacco, or Drug Use or References: "Infrequent/Mild".
  Everything else "None". Expect 12+.
- Support URL: https://usedamp.app/ Marketing URL: same.
- Copyright: 2026 <your name>.

## 8. Version 1.0 page

Paste from `docs/06-app-store-listing.md`: subtitle, promotional text, description, keywords.
Upload the six screenshots (6.9-inch required; Apple scales down for smaller phones).
App Review Information: contact details, and the review notes from the listing doc. No
sign-in required.

## 9. TestFlight

- Xcode → Product → Archive → Distribute → App Store Connect → Upload. Xcode handles
  signing when "Automatically manage signing" is on for both targets.
- Add yourself and ten friends as internal testers (no review needed). External testers
  need a one-time beta review, usually under 24 hours.
- Sandbox purchases: Users and Access → Sandbox → Testers → create a sandbox Apple ID. On the
  test phone, Settings → App Store → Sandbox Account → sign in with it. Trials and renewals
  run on an accelerated clock (a 1-year sub renews every hour) so you can test the flow.

## 10. Offer codes for creators (after launch)

Monetization → Subscriptions → Damp Yearly → Offer Codes → create a one-time-use batch per
creator (e.g. 100 codes, 1 month free). Codes redeem at apps.apple.com/redeem and are the
cleanest way to attribute trials to a creator.

## 11. Submit

- Build attached, all metadata complete, IAPs in "Ready to Submit" state and attached to the
  version (they review with the first build).
- Export compliance: "No" to encryption beyond HTTPS (already set via
  `ITSAppUsesNonExemptEncryption` in `project.yml`).
- Release: manual, so launch day is your choice, not Apple's. Target: live by Sep 30 for
  Sober October.
