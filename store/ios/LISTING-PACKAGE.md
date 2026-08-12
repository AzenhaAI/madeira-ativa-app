# App Store listing package — Madeira Ativa

Generated from the app's own source, then read back by an adversarial
reviewer. Fields are meant to be pasted into App Store Connect as-is;
character counts are the ones Apple enforces.

## Positioning

**One line.** A free guide to Madeira's 44 official PR levada trails — distance, climb and whether they are open today — with every race, walk and festa on the island's calendar and the history of the paths they run on.

**Audience.** People who are on the island for more than a weekend: Funchal-area residents who walk or run the levadas, trail and road runners and their families who follow the local race calendar, and repeat visitors planning walks a week ahead. It is a planning app, not a navigation app — there is no GPS in it at all, so it does not serve the walker who wants a blue dot on a trail.

**Why this over the alternative.** AllTrails, Komoot and Wikiloc are global route databases with GPS navigation but no idea that PR 9 is closed this week and no idea that there is a trail race on Sunday. The official tourism site has the closure list but no calendar and no app. Madeira Ativa is the only place where the official 44-PR open/closed status, the island's sport-and-festa calendar, and the heritage of the paths sit in one free app, in English and Portuguese, with no account and nothing to buy. It concedes navigation entirely and wins on 'what is open and what is on, here, this week'.

## Pricing

**Recommendation.** Ship 1.8.1 free with no monetisation at all. The app has no server cost beyond static hosting, no install base to convert, and its cleanest selling line — no account, no ads, nothing to buy — is currently true in code, which also keeps App Review short (no IAP screenshots, no restore flow, no Paid Applications Agreement, no banking/tax forms). Revisit the tip jar only once there is a real install base and the feed has proven it stays fresh; do not consider paid up-front or a subscription until something genuinely gated exists, and it does not today.

### Free, no monetisation (recommended for 1.8.1) — Free

*Mechanics.* ASC: Pricing and Availability set to Free, no in-app purchases. Only the free-apps side of the agreements is needed — no Paid Applications Agreement, no bank account, no tax forms. You still must resolve the EU trader/DSA declaration (marked UNRESOLVED at store/ios/APPSTORE-listing.md:171-186); per the account setup that is Individual, non-trader. No code changes: pubspec has no StoreKit or billing dependency. Description keeps the verified line 'There is no account to create, no advertising, and nothing to buy.'

*Why.* Everything the app does is already free of purchase machinery, and the audit confirms nothing is gated. Distribution is the scarce thing for an unknown developer, not revenue; a zero-friction free app is the only version of this that gets installed by the 200 people on the island who would actually use it. Hosting is static shpara.com pages plus JSON feeds you already publish for the website.

*Risk.* Zero revenue, so the data feeds are maintained purely on your own time. If you later add any purchase, you must edit the description and What's New, because 'nothing to buy' becomes false — plan for that edit rather than being surprised by it.

### Free with an optional tip jar (paid tier that gates nothing) — Free app + non-consumable 'Supporter' at EUR 2.99, or consumables at EUR 0.99 / 2.99 / 9.99

*Mechanics.* ASC: sign the Paid Applications Agreement, complete Portuguese tax forms and bank details for Azenha AI, create the IAP product(s) with localised display name, description, price tier and a review screenshot each, then submit them alongside the build. Code: add a StoreKit 2 purchase flow (no billing dependency exists in pubspec today) and, for a non-consumable, a working Restore Purchases control — App Review rejects non-consumables without one. Metadata: remove 'nothing to buy' from Description and What's New, and add the supporter note instead.

*Why.* It is the only monetisation that does not damage the product: nothing is withheld, so the app still installs frictionlessly, and users who use it every week for a season have a way to pay for it. It is also reversible — you can remove the product without breaking anyone's app.

*Risk.* Tip-jar conversion is well under 1% for an app with no install base; realistically single-digit euros a year, against a permanent increase in review surface (IAP metadata, restore flow, refund questions) and the loss of the cleanest sentence in the listing. Do not do this in the same submission as the iPad-layout fix — one rejection vector at a time.

### Paid up-front — EUR 2.99 one-off (Tier 3), no free version

*Mechanics.* ASC: Paid Applications Agreement, tax and banking, set the price tier and availability. Metadata: strip every 'free' claim from Description, promo text and What's New. No code change. Consider whether to keep a free 'lite' — that would mean a second bundle ID, a second listing and a second review, which doubles the maintenance for one developer.

*Why.* Honest exchange: the work is real and the aggregation (44-PR status feed + race calendar + history) does not exist anywhere else. A price also filters for the small serious audience and would fund the feeds outright if it sold.

*Risk.* This is the option most likely to end in zero installs. An unknown developer with no reviews, no install base and no brand, charging for what is largely publicly-sourced data that visitmadeira.com gives away, has almost no way to earn the first hundred downloads — and without downloads there are no reviews, so nothing improves. It also inverts the support relationship: paying users expect the live shpara.com feeds to never go stale, and every feed outage becomes a refund and a one-star review. App Review scrutinises paid apps built on aggregated public data more closely than free ones.

### Free core + paid unlock for features that do not exist yet — Free + EUR 4.99 unlock, or EUR 1.99/month with a 7-day trial

*Mechanics.* Requires building the gated value first — none of it ships today: an offline tile cache and offline Roots images (OSM tiles and Roots photos are fetched live with no cache), GPX export, route planning, or saved trail packs. Then ASC: Paid Applications Agreement, tax and banking, an auto-renewable subscription group with introductory offer, a paywall screen, and — for subscriptions — the price, duration and renewal terms in the Description plus EULA and privacy links, or Apple rejects the metadata. Code: StoreKit 2, entitlement checks, restore, and receipt handling.

*Why.* It is the only model that could carry real recurring revenue, and 'download this trail for a day with no signal' is the one thing walkers on Madeira genuinely need that the app cannot do.

*Risk.* Not sustainable for a solo developer at this stage, and honest about why: it is weeks of work before the first euro, it puts a paywall in front of an audience that has not formed yet, subscriptions bring churn management and support load forever, and Apple rejects thin paywalls. Worse, marketing offline capability before the tile cache exists repeats the overclaim already in the repo's promo text.

## App Store Connect fields

### Name (30)  ·  13 chars

**Now:** Madeira Ativa

**Paste:**

```
Madeira Ativa
```

*Why.* Unchanged. It matches CFBundleDisplayName in ios/Runner/Info.plist and the brand as used everywhere else (Ativa, never Ative). Padding the name with keywords would split the brand from the home-screen label for 17 characters of index; the subtitle and keyword field carry the search terms instead.

### Subtitle (30)  ·  29 chars

**Now:** Levada trails, events & maps

**Paste:**

```
Levada trails, races & events
```

*Why.* 'maps' is the weakest of the three nouns — the map is a view onto the same data, while races are half the reason anyone opens the app, and 'race' is what locals actually search. Trading 'maps' for 'races' frees 'map' for the keyword field, where it costs 4 characters instead of 5. All four words are verified on screen: the Levadas tab, the event category chips, and the Events tab heading.

### Keywords (100)  ·  100 chars

**Now:** hiking,walking,trekking,vereda,funchal,race,running,offline,outdoor,island,heritage,guide,bike,swim

**Paste:**

```
hiking,walk,trek,vereda,funchal,portugal,run,map,outdoor,island,nature,heritage,festa,bike,swim,tour
```

*Why.* 16 terms, no spaces after commas, and nothing that repeats Name or Subtitle (madeira, ativa, levada, trails, races, events are all excluded — Apple indexes those already; the old list wasted 'race' and would now waste 'trail'). Dropped 'offline' deliberately: the app is not an offline map (OSM tiles and Roots images are fetched live, the four WebGL screens require a connection), so it should not be bid on. Shortened hiking/walking/trekking to their stems to buy room for 'portugal' and 'tour', which is how visitors search, and added 'map' and 'festa' back after the subtitle change.

### Promotional text (170)  ·  157 chars

**Now:** All 44 official PR levadas — distance, climb, open-or-closed status — plus every race, walk and festa on the island, on a map that works offline.

**Paste:**

```
All 44 official PR levada routes — distance, climb, open-or-closed status — plus the races, walks and festas of the island, and the history behind the paths.
```

*Why.* Removes the false 'on a map that works offline' (store.dart caches JSON bodies in SharedPreferences only; there is no tile cache) and replaces it with Roots, which is real and is the app's most distinctive screen. '44 official PR routes' and the distance/climb/status triple are verified against the Levadas list and levada_page.dart. Promotional text can be changed without a new build, so this is the field to re-tune later.

### Description (4000)  ·  2948 chars

**Now:** Same structure, but contains three unsupported claims: 'over a hundred of them' (event count comes from the live feed; the shipped iPad screenshot reads 'Events (69)'), 'a nineteen-picture album' (roots_data.dart ships 18 entries since commit 82aa92e), and 'An offline cache, so a route you have already opened still works where the signal stops' overstated alongside the promo's offline-map claim.

**Paste:**

```
Madeira's mountains are laced with levadas: narrow irrigation channels cut into the cliffs from the sixteenth century onward, carrying water from the wet north down to the terraced farmland of the south. The maintenance paths beside them became the island's footpath network, and most of the races, walks and village festas on Madeira still happen somewhere along it. Madeira Ativa shows you both at once.

LEVADAS
All 44 official PR routes. Each one carries its distance, total climb, current open or closed status and any access fee, so you know what a walk asks of you before you leave the car park. Every route then has its own page: a drawn elevation profile, an estimated walking time, difficulty, altitude range, descent, steepest section, and the races that have run along it. A separate statistics screen covers the trail network as a whole, from finishers by year to the toughest races by drop-out rate.

EVENTS
Trail running, road races, orienteering, cycling, open-water swimming, children's races, professional fixtures and village festas, filtered by category or by period: next, this week, this month, three months, six months, a year. Star the ones you care about, add any of them to your calendar, and set a reminder that arrives the evening before. A separate watchlist holds events that have been announced but not yet confirmed, so nothing quietly disappears while organisers make up their minds.

Each event is matched to the nearest heritage trail, because on Madeira sport and heritage share the same paths.

MAP
Events and trails on one OpenStreetMap view, switchable between the two, with trail geometry drawn as coloured lines and every pin opening the same details you get in the lists. Web-based 3D terrain, aerial and popularity views open inside the app when you are online.

ROOTS
The island's history told as stories rather than a textbook: levadas, transport, flora, festivals, the island kitchen, and wine, rum and poncha. A six-era timeline spans six centuries, and an album collects photographs of old Madeira. Written to be read at a trailhead or on the bus up the valley.

NEWS AND TV
Headlines from Madeiran and international outlets in English, Portuguese, German, Polish, Ukrainian and Russian. Every item credits its publisher, opens the full article at the source, and is labelled when the translation was done by machine. Plus a list of upcoming sports broadcasts with channel and time.

EVERYDAY DETAILS
Notifications for the events you follow and for trails that change status. Favourites, search, and the system share sheet. Lists and trail pages you have already opened stay readable when the signal drops. Light, dark or system theme. Interface in English or Portuguese.

Madeira Ativa is free. There is no account to create, no advertising, and nothing to buy. Your favourites and reminders stay on your device.

Made on the island, for the people who live here and the ones who came to be outside.
```

*Why.* Every sentence traces to the audit. Fixes: no event count at all (the feed decides it); the album carries no number until roots_data.dart and the 'nineteen' strings agree; 'offline cache' downgraded to the true statement that already-opened lists and trail pages stay readable; 3D/aerial/popularity described as web views that need a connection, matching what App Review was already told; no 'no tracking' sentence anywhere, because the GA4/Clarity gating lives in the website repo and could not be verified from this machine. Nothing implies an account, a profile, GPS, navigation, live results or route download, because none exist. Deliberately silent on three-state trail status: the Levadas list prints only open or closed (main.dart:2197). Note for the PT localisation: description-pt.txt needs the same four fixes; this package is English-only by instruction, so translate this text rather than patching the old PT file.

### What's New  ·  532 chars

**Now:** Written for 1.8.0; says 'Built for iPhone' and 'Version 1.8.0 is the first release', both stale since iPad support landed (commit 03c00f0) and pubspec moved to 1.8.1+16.

**Paste:**

```
iPad. Madeira Ativa now runs on iPad as well as iPhone. Lists, event sheets and levada pages sit in a readable centred column instead of stretching across the screen, and the facts on a levada page lay out across the width of a wide window.

Everything else is where you left it: all 44 official PR routes with distance, climb and open-or-closed status, the island's races, walks and festas with calendar entries and evening-before reminders, the map, the six-language news feed and Roots.

Free, with no account and nothing to buy.
```

*Why.* The 'Built for iPhone' line is exactly the claim that 1.8.0 was rejected over, so it must not survive into 1.8.1. If 1.8.0 was never actually released, this field is not shown to users for a first release — fill it in anyway so nothing stale ships, and re-check that no sentence calls any version 'the first release'.

### Support URL  ·  32 chars

**Now:** https://shpara.com/ativa/support (privacy https://shpara.com/ativa/privacy, marketing https://shpara.com/ativa)

**Paste:**

```
https://shpara.com/ativa/support
```

*Why.* Load all three URLs in a browser before submitting. The site repo is not on this machine (/Users/kirillshpara/shpara1 holds only alfacat and papagaio) and the canonical Madeira folder has a known /ative-versus-/ativa split, so these paths are unverified; a support URL that 404s is an automatic rejection. The support page must show azenha.agent@gmail.com, which matches the in-app drawer's 'Contact developer'. While you are on the site, re-check that /ativa/map, /ativa/map3d, /ativa/mapfly and /ativa/mapbay really do skip GA4 and Clarity under ?app=1, and that privacy.html says so — until someone confirms that, no 'no tracking' sentence goes back into any listing (store/listing.md still carries one).

### Category  ·  32 chars

**Now:** Primary Travel, Secondary Sports

**Paste:**

```
Primary Travel, Secondary Sports
```

*Why.* Keep. Travel is where a visitor looks for an island guide and where the levada, heritage and map content belongs; Sports catches the race calendar without competing head-on with the fitness trackers in Health & Fitness, which the app would lose to since it records nothing. Age rating stays 12+ for the alcohol references in the Roots drinks chapter. Resolve the EU trader declaration (Individual, non-trader) in the same pass — it is still marked UNRESOLVED in store/ios/APPSTORE-listing.md.

## Screenshots

### ipad-13

1. **Levadas tab, portrait (2048x2732, the ios-ipad13p set), stat band full column width, seven or eight rows visible below it.** — "All 44 official PR routes"
   Same reasoning as the iPhone lead frame, and the same screen so the two sets tell one story. Shoot the iPad set in portrait rather than landscape: every tab except Map is clamped to a 760pt centred column (ReadableWidth, main.dart:562, 1278-1290), which leaves roughly a quarter of a portrait canvas as margin but nearly half of a landscape one. Keep the whole set in one orientation.

2. **Levada detail page on iPad, scrolled so the six fact tiles and the elevation profile are both in frame.** — "Climb, time and profile"
   Not in any captured set and the best iPad-specific frame available: _DetailGrid is a Wrap written so a wide window fills across instead of leaving an empty column (levada_page.dart:202-204), so the tiles form full rows here instead of the iPhone's stack. This is the frame that shows a reviewer the iPad layout was actually thought about — which matters, since 1.8.0 was rejected on exactly that.

3. **Home tab, portrait, everything from the alert strip through the mini-map, Pessoa card, 'Next up' hero and the first Coming up tiles in one shot.** — "What's open, what's next"
   The tall iPad viewport is the only place the whole home stack lands above the fold at once — that is the argument for the iPad build in a single image.

4. **Roots tab, portrait, two story cards visible with their archive photographs at full column width.** — "The island's memory"
   Largest imagery in the app, and it holds up on a big display better than any list does.

5. **Events tab, portrait, Month period active, date strip with dots, a grouped list running well down the column.** — "Races, walks and festas"
   Plain at 760pt but necessary — it is half the product. The extra vertical space at least makes the list look full rather than sparse; do not shoot it in landscape, where the wide cream margins dominate.

6. **Map tab, Events layer, camera manually fitted so Madeira fills the canvas before capture. If the camera cannot be fitted, omit this frame entirely rather than shipping it.** — "Everything on one map"
   Map is the only tab that opts out of the width cap, and at the fixed initialCenter/initialZoom (main.dart:2329-2332) the island occupies about a quarter of a 2732pt-wide canvas with empty sea around it — do not ship store/screenshots/ios-ipad13l/3-map.png as captured. Also check before shooting any iPad set: StatsPage (stats_page.dart:156), AlbumPage (roots_page.dart:209) and BroadcastsPage (main.dart:2742) never opt into ReadableWidth and will stretch edge-to-edge on a wide iPad, so keep all three out of the iPad screenshots until they are fixed.

### iphone-6.9

1. **Levadas tab, top of the list, unfiltered, sorted By name — green stat band visible in full (44 routes / 230 km trails / 18k m climb / 1848 m peak) with at least five rows below it, each showing its PR code tile, name, and the '6.1 km · ↑499 m · open · Fee 10.50 EUR' line. Light theme.** — "All 44 official PR routes"
   This is the only frame that answers 'what is this app' without a caption, and it is the frame the audit rates strongest. The stat band reads as a designed header, the PR tiles make an instantly legible left rail, and each row proves the app's core claim (distance, climb, status, fee) in one line. Most people see only this image — it must show the list, not the map, not the home screen.

2. **A levada detail page (pick a well-known route with a real fee and a strong profile, e.g. PR 1 Vereda do Areeiro), scrolled so the fact tiles (On foot ~2h 15m, Difficulty, Descent, Altitude, Steepest climb, Route) and the drawn elevation profile are both in frame.** — "Climb, time and profile"
   The depth argument. Not in any captured set today and it must be shot. It is what separates this from a list of trail names and it is the screen a walker actually uses the night before.

3. **Home tab, top of the scroll: the alert strip ('14 closed now · 6 partly open'), the 190pt polyline map preview with the 'Levadas & trails · 44 PR' pill, and the green 'Next up' hero card. Pull the scroll so the Pessoa quote card is partly visible but the hero is not cut.** — "What's open, what's next"
   The densest frame in the app and the one that shows the two feeds working together. The closed-count strip is the single most useful piece of information the app carries and it appears nowhere else in the set.

4. **Events tab with the 'Month' period chip active and a category chip selected (Trail), date strip visible with event dots, count line reading 'N upcoming', and three or four grouped rows below with stars.** — "Races, walks and festas"
   Shows the filtering model — period chips, category chips, date strip — which is the second half of the product. Do not shoot an empty state; pick a month with a full list. Let the count line show whatever the feed says; never caption a number.

5. **Map tab, Events layer selected in the segmented control, camera panned and zoomed so Madeira fills the frame (the default centre 32.75/-16.97 at zoom 10 leaves too much sea — zoom in before capturing), terracotta pins spread across the island, '© OpenStreetMap' credit visible.** — "Everything on one map"
   The map sells the density of the data, but only when the island fills the frame. Capture with the Events layer, not Levadas, so the pins are numerous and coloured; leave the Heat and 3D FABs in shot, they are genuine features, but do not caption them as 3D maps since they are embedded web views.

6. **Roots tab, scrolled to a story card expanded over one of the full-width archive photographs (the levadas or transport chapter), with the terracotta headline visible above.** — "The island's memory"
   The most visually distinct frame the app has, and the only one no competing hiking app can show. It also carries the largest imagery in the product. Verify the photo in frame has its licence line legible in the caption.

7. **Trail stats page (bar-chart icon from Levadas), scrolled to 'Finishers by year' with a second section starting below.** — "Race statistics"
   Optional seventh frame. Adds credibility for the running audience and shows there is real data underneath. Drop it if the set feels long — the first six carry the app on their own.

## Adversarial pass

Verdict: **revise**

### Pricing

- AGREE with option 1, and it is the only option whose machinery exists: pubspec.yaml has no in_app_purchase, no StoreKit, no billing dependency of any kind (verified). Options 2 and 4 are correctly labelled as needing code that is not there. No objection to the free recommendation itself.
- The 'Individual, non-trader' EU declaration is only compatible with option 1, and the package treats it as a one-time decision to reuse later. The moment you take money in the EU you are a trader under the DSA: App Store Connect then requires verified trader details (legal name, address, phone) published on the product page and re-verified. So 'resolve trader status now, revisit the tip jar later' is not one decision — the tip jar re-opens it and changes what is publicly displayed on your listing.
- Entity mismatch inside option 2: it says 'Portuguese tax forms and bank details for Azenha AI' while the account is set up as an Individual (and memory records Azenha AI as the Google Play entity, not the Apple one). Apple's tax and banking records must match the account holder; a company name on an individual account stalls payouts and triggers a verification loop that has nothing to do with App Review.
- 'EUR 2.99 one-off (Tier 3)' — Apple retired price tiers in 2023. ASC now has ~900 price points with a base storefront and per-territory rounding. Cosmetic, but it means the pricing mechanics were written from memory rather than checked against the current ASC.
- Option 4 is not merely unbuilt, part of it is not permitted. An 'offline tile cache' of tile.openstreetmap.org violates the OSMF Tile Usage Policy (no bulk downloading, no pre-fetching for offline use). Offline maps therefore require a commercial tile provider (MapTiler/Thunderforest/Mapbox), which gives the EUR 1.99/month subscription a real per-user COGS the plan books at zero. The one feature that could carry recurring revenue is also the one that ends the app's zero-cost hosting story.
- Related live risk the free plan ignores: lib/main.dart already points TileLayer straight at https://tile.openstreetmap.org/{z}/{x}/{y}.png in production. The same OSMF policy discourages distributed apps hitting the public tile server. If it is throttled or blocked, the Map tab breaks for every installed copy and there is no fallback layer — a zero-revenue plan still has a single-supplier dependency.
- The stronger argument against ever charging is not in the package: the app is a thin client over eight shpara.com JSON endpoints (events, news_feed, levadas, trails_geo, trails_status, tv_broadcasts, watchlist, trail_races) with no bundled fallback dataset. A cold-install user whose first launch hits a dead feed sees skeleton states on four tabs. Paying users would treat that as a refund; that is the real reason to stay free, and it is a code fact, not a marketing one.

### Guideline risk

- 5.1.1(i) / 5.1.2 and App Privacy accuracy — BLOCKING, verified today, not a 're-check' item. https://shpara.com/ativa/map?app=1 still serves GA4 (G-QM1PRCY7M1) and Microsoft Clarity; the ?app=1 gating never landed. Meanwhile https://shpara.com/ativa/privacy states 'We do not use analytics, advertising, or third-party trackers' and 'Dados recolhidos: nenhum'. The app opens those pages in its own WebView (main.dart:2413, 2426, 472, 480), so a session-replay tool runs inside the app while the linked policy denies it exists. Answering App Privacy as 'Data Not Collected' would be a false declaration. The package files this under the Support URL note as something to verify; it is a hard blocker and it is currently false.
- Age rating / 2.3.6 — unrestricted web access. WebPage sets JavaScriptMode.unrestricted with a NavigationDelegate that handles only onPageFinished / onWebResourceError / onHttpError (main.dart:2488-2506). There is no onNavigationRequest. The embedded map page links out to https://openstreetmap.org (and pulls fonts.googleapis.com and unpkg.com), so a tap inside the WebView starts an unbounded in-app browsing session. The rating questionnaire's 'Unrestricted Web Access' must then be answered yes (17+), or navigation must be gated to shpara.com with off-site links pushed to Safari. The package plans a 12+ rating and never mentions this. It was already on the repo's own blocking checklist and is still unmet.
- 5.2.2 / 5.2.3 third-party content — absent from the entire package. trails_status.json carries 'source: https://visitmadeira.com/.../notice-to-walkers-and-list-of-walks/', i.e. the core dataset is scraped from the tourism board's page; and the News tab republishes headlines plus snippets from named Madeiran and international outlets with machine translation. The proposed description advertises both. Apple routinely asks aggregators to document permission to use and display third-party content. Have an answer ready in App Review Information, not just the attribution line that is already there.
- 5.2.1 / 2.3.1 affiliation — the proposed public Description says 'official' repeatedly ('All 44 official PR routes', promo text, What's New, screenshot caption 1) and contains no disclaimer. The non-affiliation sentence exists only in the reviewer notes, which users never see. Add one line to the Description: independent app, not affiliated with or endorsed by the Regional Government of Madeira or visitmadeira.com. Cheap, and it is the sentence a reviewer looks for when an app leans on the word 'official'.
- 2.3.3 screenshots — the specced iPhone frame 3 and iPad frame 3 show the Home alert strip reading '14 closed now · 6 partly open'. That number is wrong: trails_status.json today returns counts {open 28, partial 6, closed 8} and an alerts array of 14 that contains both the 8 closed and the 6 partial. main.dart:804 prints alerts.length under the label 'closed now' and then prints the partial count again beside it. The screenshot would publish a double-counted, overstated closure figure about trail safety. Fix the code, then shoot the frame.
- Not a guideline risk, checked and clear: I found no evidence of a Regional Government programme called 'Madeira Ativa' that the name would collide with (searched JORAM and regional sports coverage). Name 'Madeira Ativa' matches CFBundleDisplayName in ios/Runner/Info.plist. TARGETED_DEVICE_FAMILY = 1,2 and IPHONEOS_DEPLOYMENT_TARGET = 15.0 both match the stated 'iOS 15.0+, iPhone + iPad'.
- 4.0 / 2.4.1 repeat-rejection risk the package designs around instead of fixing: 1.8.0 was rejected on iPad layout, and the plan's answer is to keep StatsPage (stats_page.dart:156), AlbumPage (roots_page.dart:209) and BroadcastsPage (main.dart:2742) out of the iPad screenshots because they stretch edge-to-edge. Confirmed — ReadableWidth appears only at main.dart:562 and levada_page.dart:16. Hiding those screens from the screenshots does not hide them from the reviewer, who opens the app on an iPad and taps the bar-chart icon. Wrapping three screens in ReadableWidth is a three-line change and is the highest-value item in this package.

### Copy

- 'Each event is matched to the nearest heritage trail' — false for a third of the catalogue. nearestHeritage() (main.dart:1105) needs geocode() to hit one of 23 hardcoded place names in lib/gazetteer.dart AND a levada within 12 km. Against the live events.json today: 103 events, 69 geocode, 34 do not (33 of them have location 'Madeira', one 'Poiso'). Those 34 get no heritage link and no map pin. Rewrite as 'where the location is known, each event shows the nearest heritage trail' — this is exactly the class of overclaim the package removed for the event count and then reintroduced here.
- 'Notifications for the events you follow and for trails that change status' — the second half implies background alerts. There is no BGTaskScheduler, no workmanager, no UIBackgroundModes anywhere in lib/ or Info.plist. _checkStatusChanges (main.dart:1987-2004) compares against the last-seen snapshot and calls notifyNow only while the app is running, i.e. you learn a trail closed at the moment you open the app and can already see it in the list. Worse, notifyNow never requests permission — _ensurePermission runs only inside setReminder — so a user who never set an event reminder gets zero status notifications on iOS. Say 'when you open the app it tells you which trails changed since last time'.
- 'current open or closed status' plus a UI that mislabels partial trails. Both feeds are three-state: levadas.json today is 30 open / 9 closed / 5 partial, trails_status.json is 28 / 8 / 6. main.dart:2197 prints t(open ? 'open' : 'closed'), so five or six partly-open trails read as 'closed' in text (only the colour differs), while the Home strip on the same launch calls them 'partly open'. The two screens contradict each other and both would appear in the screenshot set. Being 'deliberately silent' does not fix it — either add the partial string (it already exists: main.dart:70 'partly open') or the copy should not promise status at all.
- 'All 44 official PR routes' is feed-driven, not fixed. The stat band renders _levadas!.length (main.dart:2150), and 44 is only today's count from levadas.json. It is also baked into promo text, Description, What's New and a screenshot caption — a screenshot caption can only change via a metadata update. Separately, trails_status.json has total 42, so two of the 44 have no official status at all. Verified live: count 44, 230 km, 18326 m climb — the '230 km / 18k m' figures in the screenshot spec are correct.
- '1848 m peak' in the lead screenshot's stat band is a hardcoded string (main.dart:2154) that matches neither the data nor the mountain: the highest point across all 44 elevation profiles is 1830 m, and Pico Ruivo is 1862 m. It is the first number a stranger reads in your first frame, and it is wrong under either reading.
- 'A separate statistics screen covers the trail network as a whole, from finishers by year to the toughest races by drop-out rate.' The sections are finishers_year, top_clubs, top_localities, toughest (DNF %), finish_hours, loyalty, countries, intl_trend, time_dist (stats_page.dart:54-144) — these are race statistics, not trail-network statistics. The screenshot caption gets it right ('Race statistics'); the Description does not.
- 'A six-era timeline spans six centuries' — eras_data.dart runs 1419 to the 1970s, six eras covering about five and a half centuries with nothing after the airport. Minor, but it is the same kind of unforced number the package spent effort removing elsewhere.
- English-only is the wrong half to fix first. The PT Description in store/ios/APPSTORE-listing.md still carries 'mais de cem', 'álbum de dezanove imagens', 'num mapa que funciona offline' and 'Cache offline' — every claim the EN rewrite removes. Portuguese is the locale most of the stated audience (Funchal-area residents) actually reads. Shipping a corrected EN listing beside an uncorrected PT one leaves the 2.3 exposure fully intact.
- Character limits and 2.3.7 all check out — I counted them: Name 13/30, Subtitle 29/30, Keywords exactly 100/100 (16 terms, no spaces, no repeats of Name or Subtitle), Promotional text 157/170, Description 2948/4000, What's New 532. No competitor names, no price mentions, no non-English text in Name/Subtitle/Keywords, no 'free'/'sale' language in the indexed fields. Note the keyword field is at the ceiling: a single trailing space pasted into ASC fails the field, so paste it last and re-count in the form.
- Verified clean and worth keeping: all three URLs return 200 (shpara.com/ativa, /ativa/support, /ativa/privacy — the /ative alias resolves too), so the package's caution there was unnecessary. Album correctly de-numbered — roots_data.dart holds 18 items, not 19, and the missing 2019-festa-da-flor entry is gone. The eight event categories in the Description match _modeCats exactly (trail, road, orienteering, cycling, kids, pro, swim, festivals) and correctly drop the old triathlon/motorsport. Reminder timing is right (notify.dart schedules 18:00 the day before). News byline landed (main.dart:2688) and the machine-translation badge exists, though it reads only 'EN · auto' — thin support for 'labelled when the translation was done by machine'. Broadcasts do carry channel and time.
- Standing-rule check, your call not Apple's: the Description advertises news in Russian and Ukrainian. Your own rule is no Russian on public surfaces — this is an English sentence naming a language, not Cyrillic text, so it does not breach it, but it does put 'Russian' on your most public page. Decide deliberately rather than by inheritance from the old draft.
