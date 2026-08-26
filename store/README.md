# Madeira Ativa — store submission kit

Everything needed to publish to Google Play and the App Store. This folder is
gitignored (holds large binaries); the signing secrets live outside the repo.

## Where everything is

| Item | Location |
|---|---|
| Android App Bundle (upload to Play) | `store/android/madeira-ativa-v1.6.1.aab` |
| Android APK (sideload / site) | `store/android/madeira-ativa-v1.6.1.apk` |
| **Upload keystore** (Android, KEEP FOREVER) | `~/keystores/ativa-upload.jks` |
| Keystore password | `~/keystores/ativa-upload.password.txt` |
| Signing config (gitignored) | `android/key.properties` |
| Privacy policy (live) | https://shpara.com/ativa/privacy |
| Listing copy (EN/PT) | `store/listing.md` |
| Screenshots | `store/screenshots/` (add here) |
| Source repo | https://github.com/Azenhaai/ativa |
| App icon source | `assets/icon.png` |

## App identity (same on both stores)
- App name: **Madeira Ativa**
- Package / bundle id: **com.shpara.ativa**
- Version: **1.6.0** (build 11)
- Category: Travel / Sports
- Content rating: Everyone
- Data safety: no data collected (see privacy policy)

## Android — Google Play
Prepared ✅: signed AAB, upload keystore, icon, splash, privacy URL.
You do:
1. Register Play Console ($25 one-time) + identity verification.
2. Create app → upload `madeira-ativa-v1.6.0.aab`.
3. Personal accounts: run **closed testing with 12 testers for 14 days** before production.
4. Fill listing from `listing.md`, add screenshots, set data-safety = "no data collected".

## iOS — App Store
Prepared ✅: bundle id, app icons (21), launch screen/splash, version, privacy URL.
Gated on a **paid Apple Developer account ($99/year)** — the current free
"personal team" cannot distribute to the App Store (7-day signing only).
You do:
1. Enrol in the Apple Developer Program ($99/yr).
2. In Xcode: select the paid team on the Runner target → Product ▸ Archive →
   Distribute App ▸ App Store Connect.
3. Create the app in App Store Connect, fill listing from `listing.md`,
   add screenshots (6.7" + 6.5" iPhone), set privacy = "no data collected".
   No 12-tester rule; TestFlight is optional.

## Rebuild commands
```sh
flutter build appbundle --release          # Android AAB (signed with upload key)
flutter build ipa --release                # iOS (needs paid team selected)
```
