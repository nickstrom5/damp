# Onboarding + Paywall — screen by screen, with the reason each screen exists

Onboarding moves the user through a belief sequence:

> I have this problem → this app understands my problem → this might actually help me → I want the result → (pay)

Every screen below maps to one of those beliefs. If a screen doesn't move a belief, it gets cut.
This is hypothesis #1, not the final flow. The step enum lives in
`Damp/Views/Onboarding/OnboardingFlow.swift` so reordering is a one-line change.

| # | Screen | Belief it moves | What it does | Why |
|---|---|---|---|---|
| 1 | **Hook** | "I have this problem" | Full-bleed: "Skipping one drink a night gives you back **$2,900** a year. And every morning after." One button: "Show me my number." | Money is the hook because it's personal, big and checkable. No welcome, no feature list. |
| 2 | **Drinks a week** | "I have this problem" | Slider 0–40, defaults to 10. A one-line reaction under it changes with the number. | Making them *state* the number is a small commitment and the input for the reveal. |
| 3 | **Price per drink** | "This app understands me" | Chips: $3 at home / $8 mix / $14 bars, plus a slider. Live "that's $X a year" line. | Turns their number into their money before the reveal, so the reveal feels earned, not asserted. |
| 4 | **Reasons** | "This app understands me" | Multi-select: sleep, money, hangxiety, weight, health, a dry month (Sober October, Dry January). | Personalizes copy later and signals we know why people do this, not just that they drink. |
| 5 | **Reveal** | "This might help" | Animated count-ups: "$4,160 a year on alcohol." → "39 full days of food." → "4 dry nights a week gives you $2,377 of it back." | The aha. Three numbers, red → yellow → green, screenshot-able. |
| 6 | **Goal + check-in** | "This might help" | Pick 3/4/5/7 dry nights a week (savings line updates live). Set the 9pm check-in time. CTA requests notification permission. | The commitment and the mechanism on one screen. Permission is asked with the reason on screen. |
| 7 | **First night** | "I want the result" | "Make tonight dry night #1?" One big button. Tap → confetti → logged. Escape hatch: "I'm drinking tonight. Start tomorrow." | The product is used *before* the paywall. This is the screen that sells. |
| 8 | **Result** | "I want the result" | "Dry night 1. $11 kept by morning." First share card. | Immediate win + the first shareable artifact. |
| 9 | **Paywall** | (pay) | Hard paywall. Yearly w/ 7-day trial preselected, monthly + lifetime as alternates. | See below. |

## Paywall design decisions

- **Hard paywall, not soft.** The user has already logged a real night and seen a real card.
  Soft paywalls in this category train people that free is enough (see: every free tracker's
  retention).
- **Trial-first framing.** Headline is "Try Damp free for 7 days", not "Subscribe". Timeline
  graphic: Today (full access) → Day 5 (reminder) → Day 7 (charged). The reminder toggle is on by
  default and actually schedules a local notification. Reframe's worst reviews are all about
  surprise charges; the toggle is the answer to that fear.
- **Yearly preselected**, shown as "$1.67/mo, billed $19.99/yr". Monthly at $3.99 exists to make
  yearly obvious. Lifetime at $29.99 catches subscription-haters.
- **Personal number above the plans:** "About $2,377 a year back at 4 dry nights a week."
  The price is smaller than two dry nights. Say so once real conversion data exists.
- **Close button** appears after 2 seconds, top-left, low contrast. Apple requires dismissal;
  the delay is standard.
- **Restore + Terms + Privacy** in the footer (App Review requires all three).

## What to A/B test first (in order)

1. Hook copy ("$2,900 a year" vs. "Hangxiety isn't a personality trait" vs. "You've said 'not this week' before").
2. Reveal number order (money first vs. clear mornings first).
3. First-night screen: default to logging vs. asking.
4. Paywall: trial toggle on vs. off by default.
5. Price: $19.99 vs. $24.99 yearly.

Everything else waits until these five have a read.
