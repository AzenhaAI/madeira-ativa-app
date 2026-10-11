# Madeira Ativa 1.9.3 (43): release day

Both stores go live together: Apple is set to "Manually release this version",
Play should use Managed publishing.

## Today (submit)
0. App Store Connect → Distribution → In-App Events → "1.9.3 island buses" → **Add for Review**
   (deep link madeiraativa://open/bus is set; event runs 14–28 Oct, shown from 13 Oct).
1. App Store Connect → Madeira Ativa → iOS 1.9.3 → check the page → **Add for Review** → **Submit to App Review**.
   Build 43, texts EN/PT/DE, screenshots iPhone 6.9" + iPad 13" and review notes are already in place.
2. Play Console → Publishing overview → turn on **Managed publishing**.
3. Play Console → Test and release → Production → Create new release → upload `madeira-ativa-v1.9.3+43.aab`
   → paste the release notes block from PASTE.md → Next → Save → Send for review.
4. Play Console → Grow users → Store presence → Main store listing: short and full description EN, PT;
   Manage translations → Add language → German (de-DE) → texts from PASTE.md;
   Phone screenshots per language from phone-en / phone-pt / phone-de.

## When both are approved (release)
1. App Store Connect → 1.9.3 → **Release This Version**.
2. Play Console → Publishing overview → **Publish changes**.
3. Site APK: `~/Projects/ativa/store/PLAY-1.9.3/release_site_apk.sh`.
4. Check: App Store page shows 1.9.3, Play shows 1.9.3, azenha.ai/ativa/madeira-events.apk is 1.9.3.
