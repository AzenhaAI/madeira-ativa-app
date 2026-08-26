# Madeira Ativa — App Store Connect copy (v1.8.0+13)

English and Portuguese metadata for the first App Store release.
Character counts verified against Apple limits.

# Final App Store Connect metadata (EN + PT)

All limits verified with `python3 len()` on the exact strings below.

| Field | Limit | EN count | PT count |
|---|---|---|---|
| Subtitle | 30 | **28** | **24** |
| Keywords | 100 | **99** | **96** |
| Promotional text | 170 | **145** | **144** |
| Description | 4000 | **2808** | **2488** |
| What's New | 4000 | **1181** | **1113** |

Grafting decisions: subtitle leads with **levada** (the highest-value unique search term,
taken from draft 2) but keeps *events* and *maps* from draft 1, so the three strongest
terms are all in the indexed subtitle. Keywords deliberately repeat **nothing** from the app
name or the subtitle — Apple indexes name + subtitle + keywords as one pool, so `madeira`
and `levada` in the keyword field would be dead weight. Promotional text takes draft 2's
concrete levada hook and grafts draft 1's events breadth onto it. Description uses draft 2's
opening (the strongest of the three), draft 3's watchlist/TV specifics, and draft 1's
closing line.

**One deliberate omission.** None of the copy below claims "no tracking", "no analytics" or
"nothing leaves your device" — those sentences are false while GA4 and Clarity run on the
four embedded map screens, and a false privacy claim in the description is a metadata
inaccuracy on top of the App Privacy problem. The optional add-on sentence is at the end of
this document; add it **only after** the trackers are gated.

## Subtitle

**EN (28/30)**

```
Levada trails, events & maps
```

**PT (24/30)**

```
Levadas, eventos e mapas
```

## Keywords

**EN (99/100, 14 terms, no spaces after commas, no app-name words, no subtitle repeats)**

```
hiking,walking,trekking,vereda,funchal,race,running,offline,outdoor,island,heritage,guide,bike,swim
```

**PT (96/100, 12 terms)**

```
trilho,caminhada,percurso,vereda,funchal,corrida,trail,montanha,natureza,passeio,turismo,offline
```

## Promotional text

**EN (145/170)**

```
All 44 official PR levadas — distance, climb, open-or-closed status — plus every race, walk and festa on the island, on a map that works offline.
```

**PT (144/170)**

```
Os 44 percursos PR das levadas — distância, desnível e estado — e ainda as corridas, caminhadas e festas da ilha, num mapa que funciona offline.
```

## Description — EN (2808/4000)

```
Madeira's mountains are laced with levadas: narrow irrigation channels cut into the cliffs from the sixteenth century onward to carry water from the wet north down to the terraced farmland of the south. The maintenance paths beside them became the island's footpath network — and almost every race, walk and village festival on Madeira still happens somewhere along it. Madeira Ativa shows you both at once.

LEVADAS
All 44 official PR routes, each with distance, total climb, current open or closed status and any access fee, so you know what a walk asks of you before you leave the car park. Every route has its own page with a drawn elevation profile, and aggregate statistics cover the network as a whole.

EVENTS
Trail running, road races, orienteering, cycling, open-water swimming, triathlon, children's races, motorsport and village festas — over a hundred of them, filterable by category and by period. Set a reminder for the ones you intend to enter, keep the undecided ones in favourites, and add any of them to your calendar. A separate watchlist holds events whose dates are announced but not yet confirmed, so nothing quietly disappears while organisers make up their minds.

Every event is tied to the nearest centuries-old levada, because on Madeira sport and heritage share the same paths.

MAP
Events and trails on one OpenStreetMap view, with switchable layers, trail geometry drawn as polylines, and pins placed from a gazetteer built into the app. A 3D terrain view, an aerial flyover and a popularity layer are there when you want to read the shape of a climb before you commit to it, or find the quieter alternative to a famous walk.

ROOTS
The island's history as themed stories rather than a textbook: a six-era timeline running from the uninhabited laurel forest through sugar, wine, embroidery and the arrival of tourism, with a nineteen-picture album. Written to be read at a trailhead or on the bus up the valley.

NEWS AND TV
Headlines from independent Madeiran and international outlets in English, Portuguese, German, Polish, Ukrainian and Russian, each crediting its publisher and linking to the full article at the source. Plus a list of upcoming sports broadcasts, for the days you would rather watch than run.

EVERYDAY DETAILS
Notifications for events you follow and for trails that open or close. Favourites and the system share sheet. An offline cache, so a route you have already opened still works where the signal stops. Light, dark or system theme. Interface in English or Portuguese.

Madeira Ativa is free. There is no account to create, no advertising, and nothing to buy. Event, trail, history and news content comes from the same public data feed that supplies the website.

Made on the island, for the people who live here and the ones who came to be outside.
```

## Description — PT (2488/4000)

```
As montanhas da Madeira estão atravessadas por levadas: canais estreitos abertos nas encostas a partir do século XVI para levar a água do norte húmido até aos terrenos agrícolas do sul. Os caminhos de manutenção ao lado delas tornaram-se a rede pedestre da ilha — e quase todas as corridas, caminhadas e festas da Madeira acontecem ainda hoje ao longo dela. A Madeira Ativa mostra as duas coisas ao mesmo tempo.

LEVADAS
Os 44 percursos PR oficiais, cada um com distância, desnível acumulado, estado atual (aberto ou fechado) e eventuais taxas de acesso, para saber o que a caminhada exige antes de sair do carro. Cada percurso tem a sua própria página com perfil de altimetria, e há estatísticas de conjunto para toda a rede.

EVENTOS
Trail, corridas de estrada, orientação, ciclismo, natação em águas abertas, triatlo, provas para crianças, automobilismo e festas de freguesia — mais de cem, com filtros por categoria e por período. Defina um lembrete para as provas em que pensa participar, guarde as restantes nos favoritos e adicione qualquer uma ao calendário. Uma lista de acompanhamento separada reúne os eventos com data anunciada mas ainda não confirmada.

Cada evento está ligado à levada centenária mais próxima — na Madeira, desporto e património partilham os mesmos caminhos.

MAPA
Eventos e percursos numa única vista OpenStreetMap, com camadas comutáveis, geometria dos percursos desenhada e marcadores colocados a partir de um gazetteer incluído na aplicação. Uma vista 3D do terreno, um sobrevoo aéreo e uma camada de popularidade ajudam a perceber a inclinação de uma subida ou a encontrar a alternativa mais tranquila a um percurso muito procurado.

RAÍZES
A história da ilha em histórias temáticas: uma cronologia de seis épocas, da floresta laurissilva desabitada ao açúcar, ao vinho, ao bordado e à chegada do turismo, com um álbum de dezanove imagens.

NOTÍCIAS E TV
Notícias de órgãos madeirenses e internacionais independentes em português, inglês, alemão, polaco, ucraniano e russo, sempre com o nome do editor e ligação ao artigo original na fonte. E ainda a lista das próximas transmissões desportivas.

DIA A DIA
Notificações para os eventos que segue e para percursos que abrem ou fecham. Favoritos e partilha pelo sistema. Cache offline, para que um percurso já aberto continue a funcionar onde não há rede. Tema claro, escuro ou do sistema. Interface em português ou inglês.

A Madeira Ativa é gratuita. Sem conta, sem publicidade e sem nada para comprar.
```

## What's New — EN (1181/4000)

```
Version 1.8.0 is the first release of Madeira Ativa on the App Store, and it brings the whole app rather than a preview of it.

All 44 official PR levada trails, each with distance, total climb, open or closed status and access fees, plus an elevation profile per route and statistics for the network as a whole.

The island events calendar: trail running, road races, orienteering, cycling, open-water swimming, triathlon, children's races, motorsport and village festas, filterable by category and period, with reminders, favourites and a watchlist for dates that are announced but not yet confirmed. Every event points to the nearest historic levada.

One map carrying events and trails together on an OpenStreetMap base, alongside a 3D terrain view, an aerial flyover and a popularity layer.

Roots, with the island's history in a six-era timeline and a nineteen-picture album, and a news feed in six languages that credits every publisher.

Built for iPhone: reminders through iOS notifications, calendar integration, the system share sheet, a light, dark or system theme, an offline cache, and an interface in English or Portuguese.

Free, with no account and nothing to buy.
```

## What's New — PT (1113/4000)

```
A versão 1.8.0 é o primeiro lançamento da Madeira Ativa na App Store, e traz a aplicação completa.

Os 44 percursos PR oficiais das levadas, com distância, desnível, estado (aberto ou fechado) e taxas, perfil de altimetria por percurso e estatísticas de toda a rede.

O calendário de eventos da ilha: trail, estrada, orientação, ciclismo, natação, triatlo, provas para crianças, automobilismo e festas, com filtros por categoria e período, lembretes, favoritos e uma lista de acompanhamento para datas ainda não confirmadas. Cada evento indica a levada histórica mais próxima.

Um mapa com eventos e percursos em conjunto sobre base OpenStreetMap, mais vista 3D do terreno, sobrevoo aéreo e camada de popularidade.

Raízes, com a história da ilha numa cronologia de seis épocas e um álbum de dezanove imagens, e um feed de notícias em seis línguas que identifica sempre o editor.

Feito para iPhone: lembretes por notificações iOS, integração com o calendário, partilha pelo sistema, tema claro, escuro ou do sistema, cache offline e interface em português ou inglês.

Gratuita, sem conta e sem nada para comprar.
```

## App Information — the fields that currently block Submit

| Field | Value |
|---|---|
| Bundle ID | `com.shpara.ativa` |
| Version / build | **1.8.0 (13)** — read from `pubspec.yaml`, do not hardcode elsewhere |
| Primary category | Travel |
| Secondary category | Sports |
| **Copyright** | `2026 Azenha AI` |
| Age rating | **12+** — answer "Alcohol, Tobacco, or Drug Use or References" = *Infrequent/Mild* (the Roots screenshot shows a wine/rum/poncha section) |
| Privacy policy URL | https://shpara.com/ativa/privacy |
| Support URL | https://shpara.com/ativa/support |
| Marketing URL | https://shpara.com/ativa |
| App Review contact | Azenha AI · agent@azenha.ai · phone: **fill in a reachable number** |
| Demo account | Not required — nothing in the app is gated |
| Sign-in required | No |
| App Privacy | **Data Not Collected** — valid *only* after the GA4/Clarity blocks on `map`, `map3d`, `mapfly`, `mapbay` are gated. Otherwise declare Identifiers (Device ID) + Usage Data (Product Interaction), not linked to identity |
| EU trader status | **UNRESOLVED — decide before opening the submission form** |

---

# Notes for Reviewer

Paste into App Review Information → Notes. 2360 characters (limit ~4000).

**Gate:** two sentences below are statements about the shipped build — the in-app privacy
link and the publisher credit on news items. Do not submit these notes until MUST-FIX #1
and the news byline have actually landed, or the notes themselves become a second
inaccuracy.

```
Madeira Ativa is a guide to sport events, hiking trails and local history on Madeira, Portugal. There is no account, no login, no in-app purchase, no advertising and no user-generated content. Nothing is gated, so no demo credentials are needed — every screen is reachable from a cold launch.

GUIDELINE 4.2 — WHAT IS NATIVE
All six tabs are native: Home, Events, Map, Levadas, News and Roots. Four further native screens sit behind them — trail detail with a drawn elevation profile, race statistics with nine chart sections, the photo album, and TV broadcasts. The Map tab is a native map view with OpenStreetMap raster tiles, switchable event and trail layers, 100+ event pins placed from a gazetteer bundled in the binary, and trail geometry drawn as polylines. Native OS integrations: EventKit for "Add to calendar", local notifications (a reminder the evening before an event you follow, and an alert when a trail opens or closes), the system share sheet, haptics, on-device favourites, and an offline cache so the app still works in the mountains. The history section — six themed stories, a six-era timeline and a nineteen-picture album — is compiled into the app in English and Portuguese.

Four secondary screens do embed web content we publish at shpara.com: "Heat", "3D", "3D flyover" and "Aerial". They are WebGL terrain views, the one component we did not reimplement natively. They are optional extras reached from a button on the Map tab and from the side menu — no launch or first-run path goes through them.

INDEPENDENCE AND SOURCES
Madeira Ativa is independent and is not affiliated with or endorsed by the Regional Government of Madeira or the Madeira tourism board. Trail names, PR codes and open/closed status come from the public notice-to-walkers list published by visitmadeira.com. Map data is © OpenStreetMap contributors (ODbL). News items credit the publisher and link to the original article. Historical images are public domain or Creative Commons, with author and licence in every caption.

Privacy policy: https://shpara.com/ativa/privacy — also linked from the app's side menu.
Support: https://shpara.com/ativa/support

TESTING NOTE
The app needs a connection on first launch to populate Events, News and Levadas from our public feed, then serves the cached copy offline. If a feed is unreachable the tab shows a retry state.
```

---

# Optional add-on — use only after the trackers are gated

Once the gtag and Clarity blocks on `map.html`, `map3d.html`, `mapfly.html`, `mapbay.html`
**and** `privacy.html` are gated on a flag the app never sends, this sentence becomes true
and can be appended to the description's closing paragraph:

```
No tracking, no analytics, and nothing about you is collected — favourites and reminders stay on your device.
```

PT equivalent:

```
Sem rastreio e sem analítica — favoritos e lembretes ficam no seu dispositivo.
```

Until then, `store/listing.md` ("No account, no ads, no tracking") and
`store/PLAY-STEPS.md:26` ("No data collected") carry the same false claim and need the
same correction.

---

# Pre-submit checklist

Blocking:

- [ ] Privacy policy + Support links added to the app's side menu; duplicate GitHub tile removed
- [ ] EU trader status decided and declared
- [ ] Copyright string + App Review contact name/phone/e-mail entered
- [ ] GA4 + Clarity gated on the four embedded pages and on privacy.html — or App Privacy answered honestly instead
- [ ] privacy.html text reconciled with reality (EN and PT halves)
- [ ] `countries`, `intl_trend`, `time_dist` added to both locale maps
- [ ] Webview `onWebResourceError` + retry state + timeout; `onNavigationRequest` sending off-site links to Safari
- [ ] Age rating questionnaire answered as 12+
- [ ] `git commit ios/Runner/Info.plist` before archiving

Should:

- [ ] `source` rendered as a byline on every news card; snippets capped and RSS boilerplate stripped
- [ ] `2019-festa-da-flor.jpg` added or the RootsItem removed
- [ ] `cachedJson` decodes before caching; poisoned key deleted on failure
- [ ] `mounted` guards on the Events loader; raw exception text behind `kDebugMode`
- [ ] `DateTime.tryParse` in the calendar path
- [ ] Duplicate Camacha Trail folded in the feed; Home news card pointed at the translated field
- [ ] `APPSTORE-STEPS.md` version row → 1.8.0+13, team-switch step dropped, paid/screenshot boxes ticked; `ios/RELEASE.md` → `../listing.md` and 6.9″
- [ ] Screenshots re-captured after the above (they can only change via a metadata update)

Cosmetic, if there is time:

- [ ] pbxproj :444 and :501 → `= YES`
- [ ] Secondary text `#9E9E9E` → `~#5F6368`; on-green captions → `~#C8EBDC`
- [ ] Map camera fitted to island bounds; marker anchors offset off the labels
- [ ] Event type vocabulary normalised; every type mapped to a real icon
- [ ] News dates via `fmtDate()`; fees via `NumberFormat.currency`
