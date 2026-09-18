# App Store listing

Everything below is written to the same belief sequence as onboarding. The listing is the
first onboarding screen.

## Title (30 chars max)

`Damp: Drink Less Tracker`

"Drink less" is the highest-intent phrase in the category; "tracker" is what people type.

## Subtitle (30 chars max)

`Dry nights, not a dry life`

## Promotional text (170 chars, editable without review)

`Sober October starts now. One tap a night, a streak you'll want to keep, and a running count of the money you didn't spend. No account. No coach. No judgment.`

## Keywords (100 chars, comma-separated, no spaces, don't repeat title words)

`alcohol,sober,sobriety,hangover,mindful drinking,dry january,sober october,habit,streak,quit`

## Description

The first three lines show before "more". They have to carry everything.

```
Drink less. Not never.

Damp counts your dry nights, the money you kept and the mornings you woke up clear. One tap a
night. That's the whole habit.

WHY DAMP
• One tap. A 9pm check-in asks "Dry tonight?" Tap Dry, or tap Drank and say how many. Done.
• Your number, your money. Tell Damp what you drink and what it costs. Every dry night adds up
  on the home screen.
• A drinking night is a number, not a failure. Your streak resets. Your savings and your
  history don't.
• Cards worth posting. 1, 3, 7, 14, 30, 60, 100 and 365 dry nights each get one.
• Nothing leaves your phone. No account. No cloud. No data collection.

HOW IT WORKS
1. Say how many drinks a week and what they cost you.
2. Pick your goal: 3, 4, 5 or 7 dry nights a week.
3. Tap once a night. Watch the streak and the money.

WHAT YOU GET BACK
At 10 drinks a week and $8 a drink, you spend $4,160 a year. Four dry nights a week gives
you $2,377 of that back. Damp shows your real numbers, not ours.

Say "Log a dry night in Damp" to Siri, tap the Home Screen widget, or put it on your Action
Button.

Damp is a habit tracker, not medical advice. If drinking feels out of control, talk to a
doctor or call SAMHSA's helpline at 1-800-662-4357.

PRICING
Damp is free to try for 7 days, then $29.99/year, $5.99/month, or $49.99 once for life.
Subscriptions renew automatically unless cancelled at least 24 hours before the end of the
current period. Manage or cancel in Settings > Apple ID > Subscriptions.

Privacy policy: https://getdamp.app/privacy.html
Terms of use: https://getdamp.app/terms.html
```

## Screenshots (6.9-inch, in this order)

| # | Screen | Caption (top of image, 5 words max) |
|---|---|---|
| 1 | Lock screen notification "Dry tonight?" with the Dry ✓ button | One tap. That's it. |
| 2 | Home: 12 dry nights, week dots, $120 kept | Streaks you'll want to keep. |
| 3 | Reveal: "$4,160" → "$2,377 back" | See your real number. |
| 4 | Milestone card: "30 dry nights · $343 kept" | A card every milestone. |
| 5 | First night: the one button | Drink less. Not never. |
| 6 | Widget on a Home Screen | Log it from anywhere. |

Real captures for 2–5 are in `docs/screenshots/`. Screenshot 1 needs a device recording of
the notification; screenshot 6 is the widget on a real Home Screen.

## App preview video (15–30s)

Screen recording of the demo in `docs/07-launch-videos.md` video #1, no voiceover, captions on.

## App Review notes

```
Damp is a personal habit tracker for people who want to drink less alcohol. It is not a
medical app: it does not diagnose, treat, dose or make health claims. Users log whether each
night was dry or how many drinks they had; the app shows a streak, money not spent (based on
the user's own price input) and calories not consumed (a standard 150 kcal per drink).

No account, no server, no data leaves the device. Local notifications only, scheduled at a
time the user picks, with two actions (log dry / log drinks).

To test: enter any numbers in onboarding, tap "Tonight's dry" on step 7, see the result card.
Purchases can be tested with the yearly plan; the 7-day trial is configured in App Store
Connect. The widget extension (app.getdamp.damp.widgets) shows the streak and a button that
opens the app and logs tonight.
```

## Category

Primary: Health & Fitness. Secondary: Lifestyle. (Sunnyside and Reframe are both in
Health & Fitness.)

## Age rating

Alcohol references: "Infrequent/Mild". Everything else none. Expect 12+.
