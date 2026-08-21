# Closed testing — tester feedback log

Madeira Ativa · `ai.azenha.ativa` · closed testing track

Kept for the Google Play closed-testing requirement to show what testers
reported and what was done about it. Feedback arrived by direct message; the
quotes below are translated from Russian, and the wording is the tester's own,
not tidied up.

**Tester:** Kate — resident on Madeira, former IT professional, tests on Android.
**Period:** 19–21 August 2026 (ongoing; she committed to the full 14 days).
**Volume:** 13 distinct observations over three sessions.

---

## Defects reported

| # | Date | What she reported | Status |
|---|------|-------------------|--------|
| 1 | 21 Aug | "The map is missing a legend. Not everyone can read symbols and many have forgotten." | **Fixed** — collapsible legend added, covering trail status, running layers and base overlays, in English and Portuguese. |
| 2 | 21 Aug | "The red ones need a legend too." | **Fixed** — same change; closed trails are now named explicitly. |
| 3 | 21 Aug | "Why are some closed ones red and others brown?" | **Fixed, and it was a real ambiguity.** They were not all closed: amber dashed means partly open, and the roads overlay is drawn in brown. Two close hues with no key. The legend now separates them. |
| 4 | 19 Aug | "A Portuguese quote suddenly appears in the English version. Is that deliberate?" | **Accepted, pending.** The Pessoa epigraph is deliberate but unexplained. Planned: keep the Portuguese original and add an English translation beneath it. |
| 5 | 19 Aug | "The map does not load in the preview." | **Accepted, pending.** It loads, but slowly enough to read as broken. Needs a loading state and a lighter first paint. |
| 6 | 19 Aug | "The map froze." (with screenshot) | **Under investigation.** Console on the equivalent web view shows canvas errors — drawing into a zero-width element. Likely the same cause. |
| 7 | 20 Aug | "I thought this back button went one step up the tree, but no. And I could not find a way to return." | **Accepted, pending.** Navigation relies on the bottom bar; no in-page back affordance. Being reworked. |
| 8 | 20 Aug | "The letters wrap around the texture and are sometimes unreadable." (with screenshot) | **Accepted, pending.** Text over the 3D/map texture loses contrast. |

## Suggestions and requests

| # | Date | What she asked for | Status |
|---|------|--------------------|--------|
| 9 | 19 Aug | Uses the "events nearby" filter; expects to see her own position when opening the map. | **Deferred, with a reason.** The app requests no location permission at all, which is why the estimate is island-wide. Adding it means a permission prompt and a store-privacy change; being weighed. |
| 10 | 20 Aug | "Why this section? I like numbers, but what is the thinking behind having it in the main menu?" (statistics) | **Accepted.** Carried over from the website without rethinking. To be reworked or demoted. |
| 11 | 20 Aug | For levadas: show which are paid and which are free, and where to pay. "Tourists are struggling with the levadas right now." | **Accepted, pending.** Fee data is already in the feed and shown on the trail page; the payment link is not. |
| 12 | 21 Aug | Tick off levadas walked and sights visited — a personal history. "Many come back here or winter here. Or simply like ticking things off." Also as a group, with friends. | **Logged as a feature.** Larger than a fix; recorded for planning. |
| 13 | 20 Aug | Live bus timetables to trailheads. "People rely on local bus schedules, the naive ones." | **Logged.** Acknowledged as genuinely hard — the data is not published in a usable form. |

## What she said about the product

Kept because the closed-testing summary is also meant to show whether the
build is usable, not only where it breaks.

- "Very very cool app!"
- "A mature product on the first try."
- "Very good, convenient, mature product. A pleasure to use."
- "Really classy that there is weather on the levada page."
- "Found where it says open or closed." — after looking for it, which is itself
  a finding: it was there, but not where she looked first.

## Where it stands

Three of thirteen are fixed and shipped. Eight are accepted and queued, two of
them (location, personal history) large enough to need a decision rather than a
patch. None were dismissed.

The tester continues through the 14-day window and has said she will report
anything further.
