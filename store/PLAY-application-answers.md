# Production access — answers for the application form

Madeira Ativa · `ai.azenha.ativa` · second application, after the 3 September
refusal ("requires more testing")

Every number below can be checked against `PLAY-tester-feedback-log.md` in
this folder, the git history of the app, and the closed-testing track. Nothing
is rounded up.

Character counts are given because the form truncates at 300.

---

## How did you recruit users for your closed test?

*(291 characters)*

```
Not easy. Friends and acquaintances on Madeira, asked one by one over
WhatsApp and Telegram; no paid provider. I collected each person's
Google account address, added them to the Play Console email list and
sent the opt-in link with step-by-step instructions. Twelve agreed;
four wrote back.
```

**How easy was it to recruit testers?** — Difficult. Twelve people took
about a week of individual messages, and each needed the address of the
Google account on their phone, which most had to look up.

---

## Describe the engagement you received from testers

*(299 characters)*

```
Four of twelve wrote back: 32 findings, 22 with screenshots. One used
the app six days running. One counted closed trails in the list against
the home banner, got 9 vs 14 — we found both wrong. One held a concert
poster next to our calendar export: 09:00 for a 21:00 show. All fixed in
builds 26–31.
```

**What backs this up.** Aileen: first to install, 18 August; 3 findings including the empty Play page every new tester meets. Kate: 17 findings across five sessions, 19–24
August. Alexander: 7 findings on 12–15 September, each with a red-annotated
screenshot, numbered by him. Alexey: 5 findings on 18 September, all on an
iPhone-class 375-point screen, one of them cross-checked against the
organiser's poster and the phone's own Calendar app.

Screens they exercised, by their own reports: Home, Events (period chips,
categories, the event sheet, Open site, Add to calendar, Remind me), Map
(trail markers, event pins, Heat, 3D), Levadas (list, trail page, status,
fees, glossary), Statistics. Not mentioned by anyone: News, Roots.

---

## Provide a summary of the feedback you received from testers, and how you collected it

*(301 characters)*

```
Direct messages on Telegram, in their own words, screenshots annotated
by them. 32 findings: no map legend; two colours alike; grey read as
inactive, not closed; home count disagreed with the list; links led to
a season PDF or a rival app; 09:00 in the calendar for a 21:00 show;
small font. 18 fixed.
```

**What backs this up.** Full list with dates, quotes and status in
`PLAY-tester-feedback-log.md`. Status of the 32: 18 fixed and shipped, 8
accepted and queued, 4 needing a product decision (location permission,
personal history, a tunnel/exposure survey, bus links), 0 dismissed.

---

## What changed as a result of testing

*(302 characters)*

```
Six builds, 26 to 31, during the test. Map legend added; closed trails
red everywhere; home banner reads the list's own count; calendar export
uses the real start time; 91 links to a rival app removed; links go to
the organiser's page; new "Other" sports tab; trail fee opens the
official booking site.
```

**The full list, by tester, with the build it shipped in.**

*Kate (builds 26–28)*
- Map legend added, collapsible, English and Portuguese — she reported the
  map had none and "not everyone can read symbols".
- Amber "partly open" and brown "roads" told apart in the legend — she asked
  why some closed trails were red and others brown; they were not all
  closed.
- Pessoa's epigraph kept in Portuguese with an English line beneath — she
  asked whether the Portuguese in the English build was a mistake.
- The 3D map's "Tunnels" layer renamed "Road tunnels" — she read it as
  tunnels on the walking routes, which people with claustrophobia choose
  by.
- Trail fee opens SIMplifica, the only place a regulated trail can be booked
  — she said tourists "are struggling with the levadas right now".
- "Words on the signs" glossary on every trail page: levada, vereda, PR,
  partially open, open one way — she said a newcomer "will not work it out
  without a bottle".
- The status watcher now reads the same live feed every screen shows — her
  report of a trail showing one status in the list and another on its page
  led to a watcher comparing a different, stale value.

*Alexander (build 30)*
- "Nearby heritage trail" opens the app's own trail page — it opened an
  external page that 7 of 44 trails do not have, so the tap did nothing.
- Home banner counts what the list counts — it read "14 closed" when 8
  were; he counted 9 in the list and asked which was true. It was neither:
  the banner summed closed and partial, the list was pre-refresh.
- Heat and 3D maps load — both fetched their one essential library from a
  third-party CDN; when it did not answer, the spinner never stopped. The
  libraries are now served from our domain.
- Home trail preview painted sea-blue beneath the tiles — the trail lines
  arrive before the base map does, and for an evening on slow wifi he saw
  lines on grey.
- visitmadeira button shown only for trails that have a page there.
- Closed trails red on the in-app map — they were grey; he wrote that grey
  "doesn't recognize like closed", and the web map already used red.

*Alexey (build 31)*
- Calendar export uses the event's real start time; all-day when none is
  known — a concert the poster put at 21:00 went into his phone as 09:00.
- Event links go to the event's own page; a season PDF is labelled "Open
  the organiser's calendar" rather than "Open site" — he opened a race and
  landed on a table of forty.
- No links to the competing aggregator whose events we list — he called it
  "free advertising for the competitor". 91 links removed; the facts stay.
- "Other" tab before Fest — he asked why football and volleyball sat under
  Trail.
- Period chips no longer paint over the day row when the list scrolls —
  visible on his screenshot, not reported; a 375-point-screen defect.

**Found because a tester asked, not reported by one.** Six: the 3D legend
said "Restricted" where every other surface said "Partially open"; the
status fetch swallowed its error silently; the heat map's basemap provider
had begun stamping "API KEY REQUIRED" across every tile; two events in the
same town merged on the town's name alone; the calendar's merge step let a
federation PDF outrank the race's own page; the iOS wrapper's hint referred
to a mouse.

---

## About the app

**Target audience** *(under 300)*

```
People who walk, run and ride on Madeira: residents planning the
weekend, and visitors planning a week. Every tester so far is a
resident. The app answers "what is on, is the trail open, when do I
leave" from official and organiser sources, in English and Portuguese.
```

**Expected installs** — say what is true: a small, local audience. The
Telegram channel has under a hundred subscribers; the website's monthly
visitors are in the low thousands. Something like *"hundreds in the first
months, mostly on the island; growth through the website and the Telegram
channel that already exist"*.

---

## Production readiness

*(291 characters)*

```
Ready. The closed test ran 32 days with 12 testers opted in throughout.
Six builds shipped during it, each closing reported findings within
days. The last two testers' findings were all fixed in the build now in
the track. Seven accepted items and four product decisions remain,
none blocking.
```

---

## Numbers, in one place

| | |
|---|---|
| Testers opted in | 12, continuously since 18 August |
| Testers who reported in writing | 4 |
| Findings | 32 (22 with screenshots) |
| Fixed and shipped | 18 |
| Accepted, queued | 8 |
| Needs a product decision | 4 |
| Dismissed | 0 |
| Found beyond what was reported | 6 |
| Builds during the test | 6 (26 → 31) |
| App code changed during the test | 215 lines added, 26 removed, in the two main source files |
| Commits during the test | 23 |
| Sections exercised | Home, Events, Map, Levadas, Statistics |
| Sections not mentioned | News, Roots |
