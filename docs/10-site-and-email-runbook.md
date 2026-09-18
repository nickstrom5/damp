# Runbook: static site + custom domain + free support email for an iOS app

Reusable for any app. Replace: `APP` (app name), `DOMAIN` (e.g. usedamp.app), `GH_USER`
(GitHub username), `REPO` (repo name), `GMAIL` (the Gmail inbox that receives support mail).
Cost: the domain only (~$15/yr for .app at Cloudflare). Everything else is free.
For Damp: APP=Damp, DOMAIN=usedamp.app, GH_USER=nickstrom5.

## 1. Domain
- Buy DOMAIN at Cloudflare Registrar (dash.cloudflare.com → Domain Registration). At-cost
  pricing, 1 year is enough. Avoid Squarespace/GoDaddy (3-year defaults, markups).

## 2. Site files (in the repo, folder `/docs`)
- `docs/index.html` landing page (hero, how it works, pricing, FAQ, footer links)
- `docs/privacy.html` privacy policy
- `docs/terms.html` terms (must cover auto-renewing subscriptions and the cancel-24h rule)
- `docs/CNAME` one line containing DOMAIN
- Landing page has one App Store button driven by a JS constant `APP_STORE_URL = ""`:
  empty shows "Get early access" (mailto), set shows "Download on the App Store".
- All mailto links use `support@DOMAIN` or `hello@DOMAIN`.
- SEO files at the site root: `robots.txt`, `sitemap.xml`, `404.html`, `site.webmanifest`, `.nojekyll`, `og.png`,
  `favicon-32.png`, `apple-touch-icon.png`, `icon-192.png`, `icon-512.png` (images come from `swift scripts/make-brand.swift`).
  Every page carries its own title, description, canonical, Open Graph/Twitter tags and JSON-LD; all absolute URLs use DOMAIN.
- Content pages (Damp): `damp-lifestyle.html`, `drinking-cost-calculator.html`, `dry-january-tracker.html`. When you add
  or edit a page, add it to `sitemap.xml`, bump its `lastmod`, and link it from the index "Guides" list and the footer nav.

## 3. GitHub Pages
- Repo → Settings → Pages: Source "Deploy from a branch", branch = main (or yours), folder
  `/docs`. Save.
- Custom domain = DOMAIN. Save. Shows "DNS check in progress" until step 4.
- Account level: github.com/settings/pages_verified_domains → Add DOMAIN. It shows a TXT record
  name (`_github-pages-challenge-GH_USER`) and value. Keep for step 4; click Verify after.

## 4. Cloudflare DNS (DOMAIN → DNS → Records), all **DNS only** (grey cloud, not proxied)

| Type | Name | Content |
|---|---|---|
| A | `@` | 185.199.108.153 |
| A | `@` | 185.199.109.153 |
| A | `@` | 185.199.110.153 |
| A | `@` | 185.199.111.153 |
| CNAME | `www` | `GH_USER.github.io` |
| TXT | `_github-pages-challenge-GH_USER` | value from step 3 |

- Delete any registrar parking A/AAAA/CNAME records on the apex.
- Back in GitHub Pages settings, click Save next to the domain. Green within minutes.
- Tick "Enforce HTTPS" when it appears (up to an hour for the certificate).
- `scripts/cloudflare-setup.sh` in this repo does this section and the next via the API.

## 5. Inbound email (Cloudflare → DOMAIN → Email → Email Routing)
- Enable Email Routing; accept the MX/SPF/DKIM records it adds.
- Destination addresses → add GMAIL → click the verification link Cloudflare emails you.
- Routing rules → `support@DOMAIN` → GMAIL; same for `hello@DOMAIN`. Enable catch-all → GMAIL.

## 6. Outbound email (reply as support@DOMAIN from Gmail)
- Google Account → Security → 2-Step Verification on → App passwords → create one.
- Gmail → Settings → Accounts and Import → "Send mail as" → Add another email address:
  name "APP Support", email `support@DOMAIN`, untick "Treat as alias".
  SMTP `smtp.gmail.com`, port 587, TLS, username = full GMAIL address,
  password = the app password (not the account password).
- Gmail emails a confirmation code to support@DOMAIN, which forwards to GMAIL. Enter it.
- Gmail filter: `to:(support@DOMAIN OR hello@DOMAIN)` → label "APP support", skip inbox.
- Never paste or screenshot the app password; revoke and recreate it if you do.

## 7. Verify
- `https://DOMAIN/privacy.html` loads with a padlock.
- Mail from another address to support@DOMAIN arrives in GMAIL; a reply shows From: support@DOMAIN.

## 8. Use the URLs
- App Store Connect: support URL `https://DOMAIN/`, privacy policy `https://DOMAIN/privacy.html`.
- In-app: paywall footer and settings link to privacy.html and terms.html; feedback → support@DOMAIN.
- Bundle ID convention: reverse of DOMAIN, e.g. `app.usedamp.APP` (extensions `.widgets`).

## 9. SEO after launch
Do these once the site is live on DOMAIN with HTTPS.
- Google Search Console (search.google.com/search-console): add a **Domain** property for DOMAIN and verify it with the
  TXT record it gives you (Cloudflare → DNS → add TXT on `@`, DNS only). Then Sitemaps → submit `https://DOMAIN/sitemap.xml`.
- Bing Webmaster Tools (bing.com/webmasters): "Import from Google Search Console", or add DOMAIN and verify by DNS.
  Submit the same sitemap.
- Request indexing: in Search Console, URL Inspection → paste `https://DOMAIN/` → Request indexing. Repeat for each
  content page. Bing: URL Submission.
- When the App Store Connect record exists, take the numeric Apple ID (App Information → Apple ID) and:
  1. in `docs/index.html` uncomment `<meta name="apple-itunes-app" content="app-id=APP_ID">` and replace `APP_ID`
     (Safari on iPhone then shows the Smart App Banner);
  2. once the app is live, set `APP_STORE_URL` at the bottom of `docs/index.html` to `https://apps.apple.com/app/idAPP_ID`.
     Optionally add `"downloadUrl"` / `"installUrl"` with the same URL to the `MobileApplication` JSON-LD block.
- Validate: search.google.com/test/rich-results on `/` (FAQ, software app) and a content page (Article, Breadcrumb);
  paste `https://DOMAIN/` into a link-preview debugger (e.g. opengraph.xyz) and check `og.png` shows.
- Prices on the site (index pricing cards, the "How much does Damp cost?" FAQ, the JSON-LD `offers`, and
  `terms.html`) must match `Damp/Resources/Products.storekit`. Change them together. The visible FAQ and the `FAQPage`
  JSON-LD must stay word-for-word identical.
- Do not add `aggregateRating` or review markup until there are real App Store ratings to cite.
- Seasonal: before Dry January (mid-December) and Sober October (mid-September), bump `lastmod` on
  `dry-january-tracker.html` in the sitemap after any refresh and re-request indexing.

## Gotchas
- Orange (proxied) cloud on the A records means GitHub can never issue HTTPS. Must be grey.
- Gmail auto-fills the SMTP server as `smtp.DOMAIN`; it must be `smtp.gmail.com`.
- Too many failed Send-as attempts locks that dialog for about an hour.
- Cloudflare forwarding is inactive until the destination address is verified by email.
- A bounce saying "DNS type mx lookup had no relevant answers" means Email Routing isn't enabled.
