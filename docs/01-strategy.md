# Damp — Strategy

> One sentence: **Drink less. Not never. One tap a night.**

## 1. Why this idea

Same filter as Clam: a problem people already feel every day, already Google, already pay to
fix, where several competitors are already making real money. "Drink less" passes every check,
and it has two free distribution windows a year that the screen-time category doesn't:
Sober October and Dry January.

| Check | Evidence |
|---|---|
| Daily felt pain | The 9pm "should I?" and the 7am "why did I?". Hangxiety is a mainstream word. |
| Proven spend | Sunnyside: $99/yr (or $12/mo), plus a $298/yr coaching tier and a $99/mo naltrexone tier. Reframe: $99.99/yr plus $10–250/mo coaching. I Am Sober, Drinkaware, Try Dry, Less, Drylendar all in the same search results. |
| Loud complaints | Reframe's Trustpilot and App Store reviews repeat the same three things: charged after cancelling, hidden costs, can't reach support. Sunnyside reviews: text-coach is a chatbot, too many screens, expensive for what is a tracker. |
| 7-second demo | 9pm notification → tap "Dry tonight ✓" → streak goes 11 → 12, "$137 kept". Nothing to explain. |
| Shareable result | "30 dry nights · $343 kept" card. Streak milestones at 1, 3, 7, 14, 30, 60, 100, 365. |
| No backend needed for v1 | Local notifications + StoreKit 2 + a widget. Zero server cost, no account, and no special entitlement to wait for. |

**Why this beats Clam on risk:** Clam's critical path was Apple's Family Controls entitlement
(days to weeks). Damp needs nothing from Apple but App Review. Build to submission is under
two weeks.

## 2. The "damp" angle

Sobriety apps sell quitting. Most people don't want to quit; they want to drink *less* and
stop feeling bad about it. Sunnyside's own survey: 73% of members wanted an option other than
complete sobriety. The word for that on TikTok is "damp" (coined by creator Hana Elson;
"damp January", "damp lifestyle"). Nobody owns it as a product name.

- **The promise is the name.** Damp = drink less, not never. No AA framing, no "day 1 of
  sobriety" guilt, no counting since your last drink.
- **The unit is the night, not the drink.** A dry night is a win you can tap. Counting every
  unit (Sunnyside, Drinkaware) makes the app a chore; counting nights makes it a streak.
- **Money is the number.** "$2,377 a year back" converts better than health copy because it's
  personal, big and checkable. Calories and clear mornings are the supporting cast.

## 3. Launch windows

| Window | Date | What happens |
|---|---|---|
| **Sober October** | 1–31 Oct 2026 (starts in 14 days) | "Sober October tracker" searches spike. Participation grew ~150% year over year. Our v1 ships a "Sober October" reason chip and a 31-day framing in the content. |
| **Dry January** | 1 Jan 2027 | The biggest month in the category by a mile. Every competitor's install chart is a January spike. Damp needs to be live, reviewed and ranking by mid-December. |
| Year-round | | "Sunday scaries", "hangxiety", "damp lifestyle" content runs all year. |

Ship for October to learn. Optimise for January to earn.

## 4. Positioning against the category

| Competitor | What they do well | What users hate | Damp's answer |
|---|---|---|---|
| Sunnyside ($99/yr) | Brand, moderation framing, weekly plan | Text "coach" is a bot, drink-by-drink logging, price | One tap a night. A third of the price. |
| Reframe ($99.99/yr) | Neuroscience course content, community | Billing complaints, upsells, heavy | No courses, no upsells, no account. Cancel in Settings like any app. |
| I Am Sober (free + $10/mo) | Sobriety streak, community | Abstinence-only; drinking once is "relapse" | A drinking night is a number, not a failure. Streak resets, savings don't. |
| Try Dry / Drinkaware (free) | Free, charity-backed | UK-focused, dated, no habit loop | Notification with tap-to-log, milestone cards, widget. |
| Drylendar, Less, Tipple (small) | Simple | Small, no distribution | We out-distribute on short-form; same simplicity. |

**One-line differentiation:** Damp is the simplest way to drink less on iOS. Tell it your
number once, then every night is one tap, and every milestone is a card you'll want to post.

## 5. Product (v1 = onboarding + paywall + core loop, nothing else)

**Core loop**
1. 9pm (or whenever you chose) notification: "Dry tonight?" with **Dry ✓** and **I had a drink**
   buttons. Dry logs without opening the app.
2. Home: streak, this week's dots against your goal, money kept, calories skipped.
3. Dry night → confetti. Streak hits a milestone → card → share.
4. Drinking night → "How many?" → logged. Streak resets, savings and history stay.
5. Forgot last night → one banner on home, two buttons. Unlogged nights never count either way.

Entry points besides the app: the notification actions, a Home Screen widget with a "Tonight's
dry" button, Siri ("Log a dry night in Damp"), Shortcuts, the Action Button.

**What is deliberately not in v1:** drink-by-drink logging with types, mood journaling, an AI
coach, community, courses, HealthKit, Apple Watch, Android. Each is a v1.x candidate only if
reviews ask for it.

## 6. Monetization

Subscription, hard paywall at the end of onboarding (after the user has logged their first
dry night and seen the first card).

| Plan | Price | Notes |
|---|---|---|
| Yearly | **$29.99** with 7-day free trial | Default. "$2.50/mo" framing. Pays for itself on the first three dry nights. |
| Monthly | $5.99 | Anchor to make yearly obvious. |
| Lifetime | $49.99 | For the subscription-haters (a loud group in this category's reviews). |

Why these numbers: Sunnyside and Reframe are both ~$100/yr, so $29.99 reads as "the honest one"
and still supports a business. The paywall says what one dry night is worth in the user's own
money; the yearly price is less than three of them.

**Unit-economics targets (month 3):**

| Metric | Target |
|---|---|
| Install → onboarding complete | 65% (no permission gate beyond notifications) |
| Onboarding complete → trial start | 25% |
| Trial → paid | 40% |
| Blended install → paid | ~6.5% |
| Yearly ARPU after Apple's cut (small-business 15%) | ~$25 |
| Break-even CPI at 6.5% install→paid | ~$1.60 |

At 10,000 installs/mo from organic short-form plus a Dry January spike, that is ~650 paying
users/mo, ~$16k/mo run-rate by month 3, before January.

## 7. Distribution plan (starts before the app is approved)

See `docs/03-distribution.md`. Short version:

1. **Week 0–1:** study 20 winning videos from Sunnyside, Reframe, sober-curious creators and
   "damp January" content. Save hook, first frame, time-to-product, CTA.
2. **Week 1–2:** post 3 videos/day across 2 accounts. Sober October countdown content from
   Sep 24. Track by the tier ladder.
3. **Oct 1–31:** "Day N of Sober October" daily series from the founder account. Seed 10 small
   creators doing the challenge with the app.
4. **Nov–Dec:** put paid spend behind the 3–5 organic concepts that produced trials. Build
   the Dry January content bank. Ask every October user for a review before Dec 15.

## 8. Metrics that matter (instrument from day 1)

Events are defined in `Damp/Services/Analytics.swift`. Funnel to watch weekly:

`app_open → onboarding_step(n) → reminders_authorized → first_night_logged → paywall_shown → trial_started → paid → night_logged (D1, D7, D30) → milestone_reached → share_tapped`

The ratio that decides everything: **first_night_logged / onboarding_started.** People who log
one dry night in onboarding convert. People who drop before it need a shorter onboarding.

Second ratio: **night_logged D7 / trial_started.** If people stop logging in the trial they
cancel. The 9pm notification with tap-to-log exists to protect this number.

## 9. Risks and how we handle them

| Risk | Mitigation |
|---|---|
| App Review treats it as a medical app | It's a habit tracker. Settings footer says so and links SAMHSA's helpline. No diagnosis, no dosing, no claims of treatment. Age rating answered honestly (alcohol references). |
| Ad platforms restrict alcohol content | Content is about drinking *less*; TikTok and Meta allow responsible-drinking / wellness framing. Avoid showing drinks being consumed in ads. |
| Users stop logging | Notification actions log without opening the app; widget logs in one tap; "forgot last night" banner backfills. Unlogged nights don't punish. |
| Category seasonality (January spike, summer dip) | Sober October and the founder daily series carry the first two months; the January spike funds the year. |
| "It's just a counter" | So is every winning app in the category. Ours has the tightest loop and the best card. Price says the rest. |

## 10. 30-day plan

| Days | Deliverable |
|---|---|
| 1 | App Store Connect record, products, small-business program. Domain, Pages, email (runbook in `docs/10-site-and-email-runbook.md`). |
| 1–4 | Run onboarding on a real phone. Fix the screen you stop wanting to continue on. TestFlight to 10 friends. |
| 4–7 | Record the first 10 videos (`docs/07-launch-videos.md`). Start posting the Sober October countdown. |
| 7 | Submit for review. |
| 10–14 | Live before Oct 1. Daily posts. |
| Oct 1–31 | "Day N of Sober October" series. Seed creators. Read every review, one fix a day. |
