# Closed testing — tester feedback log

Madeira Ativa · `ai.azenha.ativa` · closed testing track

Kept for the Google Play closed-testing requirement to show what testers
reported and what was done about it. Feedback arrived by direct message; the
quotes below are translated from Russian, and the wording is the tester's own,
not tidied up.

Two testers have reported in writing so far, each in their own section below.

## Tester 1 — Kate

**Who:** resident on Madeira, former IT professional, tests on Android.
**Period:** 19–24 August 2026.
**Volume:** 17 distinct observations over five sessions.

---

## Defects reported

| # | Date | What she reported | Status |
|---|------|-------------------|--------|
| 1 | 21 Aug | "The map is missing a legend. Not everyone can read symbols and many have forgotten." | **Fixed** — collapsible legend added, covering trail status, running layers and base overlays, in English and Portuguese. |
| 2 | 21 Aug | "The red ones need a legend too." | **Fixed** — same change; closed trails are now named explicitly. |
| 3 | 21 Aug | "Why are some closed ones red and others brown?" | **Fixed, and it was a real ambiguity.** They were not all closed: amber dashed means partly open, and the roads overlay is drawn in brown. Two close hues with no key. The legend now separates them. |
| 4 | 19 Aug | "A Portuguese quote suddenly appears in the English version. Is that deliberate?" | **Fixed.** It was deliberate and nothing said so. The line stays in Portuguese — it is how Pessoa wrote it, on an island that speaks the language — with an English translation beneath. |
| 5 | 19 Aug | "The map does not load in the preview." | **Accepted, pending.** It loads, but slowly enough to read as broken. Needs a loading state and a lighter first paint. |
| 6 | 19 Aug | "The map froze." (with screenshot) | **Under investigation.** Console on the equivalent web view shows canvas errors — drawing into a zero-width element. Likely the same cause. |
| 7 | 20 Aug | "I thought this back button went one step up the tree, but no. And I could not find a way to return." | **Accepted, pending.** Navigation relies on the bottom bar; no in-page back affordance. Being reworked. |
| 8 | 20 Aug | "The letters wrap around the texture and are sometimes unreadable." (with screenshot) | **Accepted, pending.** Text over the 3D/map texture loses contrast. |
| 14 | 24 Aug | "Different status in the preview and in the card." (with screenshot) | **Fixed, and the cause was not where it looked.** The three feeds agree; the disagreement was inside the app. Every screen shows the official trail-status feed, while the watcher that raises "trail status changed" compared the status bundled in the app. A trail could close on the feed, show as closed on its page, and raise nothing. Both now read the same value. |
| 15 | 24 Aug | The 3D view's "tunnels" filter is ambiguous. "I assume it is about roads. But it looked to me like it was about walking routes." | **Fixed.** It is the road-tunnel overlay and now says "Road tunnels". Her reading was the reasonable one and a different question entirely: people choose walks by whether there are tunnels to pass through. |

## Suggestions and requests

| # | Date | What she asked for | Status |
|---|------|--------------------|--------|
| 9 | 19 Aug | Uses the "events nearby" filter; expects to see her own position when opening the map. | **Deferred, with a reason.** The app requests no location permission at all, which is why the estimate is island-wide. Adding it means a permission prompt and a store-privacy change; being weighed. |
| 10 | 20 Aug | "Why this section? I like numbers, but what is the thinking behind having it in the main menu?" (statistics) | **Accepted.** Carried over from the website without rethinking. To be reworked or demoted. |
| 11 | 20 Aug | For levadas: show which are paid and which are free, and where to pay. "Tourists are struggling with the levadas right now." | **Fixed in build 28.** The fee now opens SIMplifica, the only place a PR trail can be booked and paid, and there is a button for it under the trail details. Booking is mandatory and online-only, and the trailheads have no signal — so the link matters more than the number. |
| 12 | 21 Aug | Tick off levadas walked and sights visited — a personal history. "Many come back here or winter here. Or simply like ticking things off." Also as a group, with friends. | **Logged as a feature.** Larger than a fix; recorded for planning. |
| 16 | 24 Aug | Explain the vocabulary of the trails themselves. "Here we have levadas, veredas, there is PR marking, and ones open in one direction only, or partly open. It is a mess. We are used to it, but a newcomer will not work it out without a bottle. I found no explanation of the names in the app." | **Fixed in build 28.** "Words on the signs" on every trail page: levada, vereda, PR, partially open, open one way — each in one sentence, in English and Portuguese. |
| 17 | 24 Aug | Flag two things people choose routes by: whether the route has tunnels (claustrophobia) and whether it has an open, unfenced drop-off (fear of heights). "Some tourists pick routes with no tunnels and with closed edges. Routes you can walk with a school-age child." | **Logged as a feature.** The strongest suggestion in the set: it is a safety and comfort filter, not decoration, and no other Madeira app offers it. Needs survey data the feed does not carry. |
| 13 | 20 Aug | Live bus timetables to trailheads. "People rely on local bus schedules, the naive ones." | **Logged.** Acknowledged as genuinely hard — the data is not published in a usable form. |

## Found while acting on her reports

Not reported by her, but found because she asked and someone went looking. Kept
here because they are the same defect in kind: the product telling a person two
different things.

- The same amber, `#e0902a`, read "Restricted" in the 3D map legend and
  "Partially open" everywhere else — including in that map's own popups, so the
  legend disagreed with the map it belonged to. Those are not synonyms.
- The trail-status feed was fetched inside a `catch` that swallowed the error
  whole. Falling back to the bundled statuses is correct, but it was silent:
  everything on screen would be as old as the last release with nothing saying
  so.

## Tester 2 — Alexander

**Who:** Android, tests with screenshots annotated in red, writes in English
and Russian. Numbered his findings himself.
**Period:** 12–15 September 2026, on build 29.
**Volume:** 7 distinct observations in one sitting, all with screenshots.

Where Kate walked the trails, Alexander walked the map. Five of his seven are
about the Map tab, and he went looking for the seams between screens — the
same trail shown two ways, the same count given two answers.

| # | What he reported | Status |
|---|------------------|--------|
| A1 | Map → pick an event → tap "Nearby heritage trail". "Result: nothing happens. Expect: opens link of the proper levada." Same on a second event. | **Fixed.** The tile opened the trail's visitmadeira page, and seven of the 44 trails have none, so the tap did nothing. It now opens the app's own trail page, which exists for all 44 — what the chevron promised. |
| A2 | Home banner says "14 closed now · 6 partly open"; he counted the Levadas list: "9 closed, not 14. 5 partly open, not 6." | **Fixed, and it was three answers, not two.** The banner counted the alerts list, which holds closed *and* partial together (8 + 6 = 14). His list was built from the bundled file before the official feed arrived (9 / 5). The banner now reads the same tally the list is built from. |
| A3 | Map → Heat and 3D: "both are not working. Looping downloads for both." | **Fixed.** Both pages loaded their one essential library from unpkg.com. When that host does not answer on a mobile network, the page renders nothing and the spinner never stops. The libraries are served from our own domain now. |
| A4 | Home: "Some map should be in the background?" — the trail sketch on a plain grey card. Next morning: "map was updated. Very strange because theoretically it's the same source." | **Explained; not a code defect.** The card is a real map; the base tiles come from tile.openstreetmap.org and did not arrive that evening. Logged as a risk — same shape as A3, a third-party host — and kept for a decision on hosting tiles. |
| A5 | Map → PR 23 Levada da Azenha → "visitmadeira.com" button: "broken link". | **Fixed.** No page exists there for that trail, and six others. The button is shown only when there is a page to open. |
| A6 | "Grey doesn't recognize like closed. Green and yellow are great but grey probably should be red. Red equals prohibited or closed, warning colour." | **Fixed, and he was right on the principle.** Closed trails were grey on the in-app map and red on the web map and in its legend. One state, one colour now: the web map's red, everywhere. |
| A7 | In English, several strings stay Portuguese: the Pessoa quote, "Next up" event names, "Campeonato da Madeira de Enduro". "P.S. Madeira Ativa should probably remain as a brand without translation." | **Accepted with a distinction.** The quote and the brand are deliberate and now say so (see Kate's #4). Event *names* are the organiser's own title and are not translated by design — a race called Campeonato da Madeira is called that. Logged: an English gloss for festival names is worth considering. |

Five fixed in build 30, one explained, one accepted. None dismissed.

## What she said about the product

Kept because the closed-testing summary is also meant to show whether the
build is usable, not only where it breaks.

- "Very very cool app!"
- "A mature product on the first try."
- "Very good, convenient, mature product. A pleasure to use."
- "Really classy that there is weather on the levada page."
- "Found where it says open or closed." — after looking for it, which is itself
  a finding: it was there, but not where she looked first.
- "Again I want to say I really like the app. Clear, convenient, very pleasant
  to come back to." (24 Aug, unprompted)
- "Very cool filter!!!" — on the events filters.
- She posted the app to a local Madeira Telegram channel of her own accord.

## Where it stands

Nine of seventeen are fixed and shipped, in builds 26, 27 and 28. Eight are
accepted and queued, three of them (location, personal history, the
tunnel/exposure survey) large enough to need a decision rather than a patch.
None were dismissed.

Two of her reports changed the product beyond the fix itself. The colour
question exposed a legend that disagreed with its own map. The status question
led to a watcher reading a different value from every screen in the app — a
defect no one had noticed and which no amount of looking at the data would have
revealed, because the data was never wrong.

The tester continues through the 14-day window and has said she will report
anything further.
