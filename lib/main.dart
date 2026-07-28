import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'gazetteer.dart';
import 'levada_page.dart';
import 'stats_page.dart';
import 'notify.dart';
import 'roots_page.dart';
import 'store.dart';
import 'stories_data.dart';

const kGreen = Color(0xFF0F6E56);
const kGreenDark = Color(0xFF085041);
const kGreenLight = Color(0xFFE1F5EE);
const kTerracotta = Color(0xFF993C1D);
const kTerracottaLight = Color(0xFFFAECE7);
const kCream = Color(0xFFFAF8F2);

// Dark-mode surfaces.
const kDarkBg = Color(0xFF15140F);
const kDarkCard = Color(0xFF23221C);
const kGreenTintDark = Color(0xFF163A2E);
const kTerraTintDark = Color(0xFF3A1E12);
const kTerraBright = Color(0xFFE0885F);

/// Theme-aware semantic colors so the app reads correctly in light and dark.
extension AtivaColors on BuildContext {
  bool get dark => Theme.of(this).brightness == Brightness.dark;
  Color get cSurface => dark ? kDarkCard : Colors.white;
  Color get cTitle => dark ? kGreenLight : kGreenDark;
  Color get cBody => dark ? const Color(0xFFE8E6DE) : const Color(0xFF1C1B17);
  Color get cSubtle => dark ? const Color(0xFF9A988E) : Colors.grey.shade600;
  Color get cHairline => dark ? const Color(0xFF3A3931) : Colors.grey.shade300;
  Color get cGreenTint => dark ? kGreenTintDark : kGreenLight;
  Color get cTerraTint => dark ? kTerraTintDark : kTerracottaLight;
  Color get cTerraText => dark ? kTerraBright : kTerracotta;
}

final locale = ValueNotifier<String>('en');
final themeModeN = ValueNotifier<ThemeMode>(ThemeMode.light);

const _tr = {
  'en': {
    'home': 'Home',
    'events': 'Events',
    'map': 'Map',
    'levadas': 'Levadas',
    'roots': 'Roots',
    'next_up': 'Next up',
    'coming_up': 'Coming up',
    'news': 'News',
    'all_news': 'All news',
    'roots_teaser': 'Roots · the island\'s memory',
    'roots_hook': 'Old Madeira in 19 pictures — levadas, sugar, wine sledges',
    'levadas_teaser': 'Levadas & trails',
    'levadas_hook': '44 official PR routes with status and elevation',
    'upcoming': 'upcoming',
    'on': 'on',
    'all_dates': 'All dates',
    'loading': 'Loading…',
    'open': 'open',
    'closed': 'closed',
    'fee': 'Fee',
    'website': 'Website',
    'telegram': 'Telegram bot',
    'language': 'Português',
    'roots_sub': "The island's memory, one place at a time",
    'view_all': 'View all',
    'roots_h1': 'How Madeira learned to move',
    'timeline': 'The timeline',
    'timeline_sub': 'Six hundred years in six chapters — worth a slow scroll.',
    'album': 'The Album',
    'album_sub': 'Nineteen pictures of old Madeira.',
    'pessoa': 'Tudo vale a pena se a alma não é pequena.',
    'pessoa_by': '— Fernando Pessoa',
    'stat_routes': 'routes',
    'stat_km': 'km trails',
    'stat_climb': 'm climb',
    'stat_peak': 'm peak',
    'watchlist': 'Watchlist',
    'watchlist_sub': 'Worth tracking — dates not yet confirmed.',
    'on_tv': 'On TV',
    'broadcasts': 'Broadcasts',
    'view_all_tv': 'All broadcasts',
    'p_week': 'Week',
    'p_month': 'Month',
    'p_3mo': '3 mo',
    'p_6mo': '6 mo',
    'p_year': 'Year',
    'add_calendar': 'Add to calendar',
    'share': 'Share',
    'open_site': 'Open site',
    'remind': 'Remind me',
    'remind_set': 'Reminder set — the day before at 18:00',
    'remind_off': 'Reminder removed',
    'theme': 'Theme',
    'theme_system': 'System',
    'theme_light': 'Light',
    'theme_dark': 'Dark',
    'contact': 'Contact developer',
    'nearby_heritage': 'Nearby heritage trail',
    'stories': 'Island stories',
    'stories_sub': 'Six themes, six centuries — tap a card to read.',
    'album_open': 'Open the album',
    'nothing_found': 'Nothing here — try another period or filter.',
    'sort': 'Sort',
    'sort_name': 'By name',
    'sort_km': 'By distance',
    'sort_climb': 'By climb',
    'stats': 'Trail stats','finishers_year':'Finishers by year','top_clubs':'Top clubs','top_localities':'Top localities','toughest':'Toughest races (DNF %)','finish_hours':'Finish times (hour of day)','loyalty':'Returning runners (years raced)','elev_profile':'Elevation profile','status_changed':'Trail status changed','p_next':'Next',
  },
  'pt': {
    'home': 'Início',
    'events': 'Eventos',
    'map': 'Mapa',
    'levadas': 'Levadas',
    'roots': 'Raízes',
    'next_up': 'A seguir',
    'coming_up': 'Próximos',
    'news': 'Notícias',
    'all_news': 'Todas as notícias',
    'roots_teaser': 'Raízes · a memória da ilha',
    'roots_hook': 'A Madeira antiga em 19 imagens — levadas, açúcar, corsas',
    'levadas_teaser': 'Levadas e veredas',
    'levadas_hook': '44 percursos PR oficiais com estado e desnível',
    'upcoming': 'a seguir',
    'on': 'em',
    'all_dates': 'Todas as datas',
    'loading': 'A carregar…',
    'open': 'aberto',
    'closed': 'fechado',
    'fee': 'Taxa',
    'website': 'Site',
    'telegram': 'Bot do Telegram',
    'language': 'English',
    'roots_sub': 'A memória da ilha, um lugar de cada vez',
    'view_all': 'Ver tudo',
    'roots_h1': 'Como a Madeira aprendeu a mover-se',
    'timeline': 'A linha do tempo',
    'timeline_sub': 'Seiscentos anos em seis capítulos — vale a pena descer devagar.',
    'album': 'O Álbum',
    'album_sub': 'Dezanove imagens da Madeira antiga.',
    'pessoa': 'Tudo vale a pena se a alma não é pequena.',
    'pessoa_by': '— Fernando Pessoa',
    'stat_routes': 'percursos',
    'stat_km': 'km de trilhos',
    'stat_climb': 'm de subida',
    'stat_peak': 'm de pico',
    'watchlist': 'A acompanhar',
    'watchlist_sub': 'Vale a pena seguir — datas por confirmar.',
    'on_tv': 'Na TV',
    'broadcasts': 'Transmissões',
    'view_all_tv': 'Todas as transmissões',
    'p_week': 'Semana',
    'p_month': 'Mês',
    'p_3mo': '3 meses',
    'p_6mo': '6 meses',
    'p_year': 'Ano',
    'add_calendar': 'Adicionar ao calendário',
    'share': 'Partilhar',
    'open_site': 'Abrir site',
    'remind': 'Lembrar-me',
    'remind_set': 'Lembrete definido — véspera às 18:00',
    'remind_off': 'Lembrete removido',
    'theme': 'Tema',
    'theme_system': 'Sistema',
    'theme_light': 'Claro',
    'theme_dark': 'Escuro',
    'contact': 'Contactar o programador',
    'nearby_heritage': 'Vereda histórica próxima',
    'stories': 'Histórias da ilha',
    'stories_sub': 'Seis temas, seis séculos — toque num cartão para ler.',
    'album_open': 'Abrir o álbum',
    'nothing_found': 'Nada aqui — tente outro período ou filtro.',
    'sort': 'Ordenar',
    'sort_name': 'Por nome',
    'sort_km': 'Por distância',
    'sort_climb': 'Por desnível',
    'stats': 'Estatísticas','finishers_year':'Finalistas por ano','top_clubs':'Melhores clubes','top_localities':'Localidades','toughest':'Provas mais duras (DNF %)','finish_hours':'Horas de chegada','loyalty':'Corredores fiéis (anos)','elev_profile':'Perfil de altitude','status_changed':'Estado do trilho mudou','p_next':'Próximo',
  },
};

String t(String k) => _tr[locale.value]![k] ?? k;

const _wdName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _moName = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// '2026-07-11' -> 'Sat, 11 Jul'
String fmtDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${_wdName[d.weekday - 1]}, ${d.day} ${_moName[d.month - 1]}';
}

Future<void> openUrl(String url) async {
  if (url.isEmpty) return;
  final uri = Uri.tryParse(url);
  if (uri != null) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}


/// Grey placeholder cards shown while a list loads.
Widget skeletonList(BuildContext context, {int count = 6}) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: count,
    itemBuilder: (_, __) => Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cHairline, width: 0.5),
      ),
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: CircleAvatar(
              radius: 16, backgroundColor: context.cGreenTint),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 12,
                  width: 180,
                  decoration: BoxDecoration(
                      color: context.cGreenTint,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 8),
              Container(
                  height: 10,
                  width: 120,
                  decoration: BoxDecoration(
                      color: context.cHairline,
                      borderRadius: BorderRadius.circular(4))),
            ],
          ),
        ),
      ]),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initStore();
  await initNotify();
  final saved = prefs.getString('themeMode');
  themeModeN.value = ThemeMode.values.firstWhere((m) => m.name == saved,
      orElse: () => ThemeMode.light);
  runApp(const AtivaApp());
}

void setThemeMode(ThemeMode m) {
  themeModeN.value = m;
  prefs.setString('themeMode', m.name);
}

class AtivaApp extends StatelessWidget {
  const AtivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([locale, themeModeN]),
      builder: (_, __) => MaterialApp(
        title: 'Madeira Ativa',
        debugShowCheckedModeBanner: false,
        themeMode: themeModeN.value,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: kCream,
          colorScheme: ColorScheme.fromSeed(seedColor: kGreen),
          appBarTheme: const AppBarTheme(
            backgroundColor: kCream,
            foregroundColor: kGreenDark,
            elevation: 0,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: kGreenLight,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: kDarkBg,
          colorScheme: ColorScheme.fromSeed(
              seedColor: kGreen, brightness: Brightness.dark),
          appBarTheme: const AppBarTheme(
            backgroundColor: kDarkBg,
            foregroundColor: kGreenLight,
            elevation: 0,
          ),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: kDarkCard,
            indicatorColor: kGreenTintDark,
          ),
          bottomSheetTheme:
              const BottomSheetThemeData(backgroundColor: kDarkCard),
        ),
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  void _goTo(int i) => setState(() => _tab = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNavigate: _goTo),
      const EventsPage(),
      const MapPage(),
      const LevadasPage(),
      const NewsPage(),
      const RootsPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset('assets/icon_mark.png', width: 32, height: 32),
        ),
        title: const Text('Madeira Ativa',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () =>
                locale.value = locale.value == 'en' ? 'pt' : 'en',
            child: Text(locale.value.toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: kGreen)),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: kGreen),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Madeira Ativa',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: kGreenLight)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.public, color: kGreen),
              title: Text(t('website')),
              onTap: () => openUrl('https://shpara.com/madeira/'),
            ),
            ListTile(
              leading: const Icon(Icons.send, color: kGreen),
              title: Text(t('telegram')),
              onTap: () => openUrl('https://t.me/madeira_ebot'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: kGreen),
              title: Text(t('stats')),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const StatsPage())),
            ),
            ListTile(
              leading: const Icon(Icons.flight, color: kGreen),
              title: const Text('3D flyover'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const WebPage(
                      title: '3D flyover',
                      url: 'https://shpara.com/madeira/mapfly'))),
            ),
            ListTile(
              leading: const Icon(Icons.terrain, color: kGreen),
              title: const Text('Aerial view'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const WebPage(
                      title: 'Aerial',
                      url: 'https://shpara.com/madeira/mapbay'))),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.code, color: kGreen),
              title: const Text('GitHub · app'),
              subtitle: const Text('kirshp/ativa'),
              onTap: () => openUrl('https://github.com/kirshp/ativa'),
            ),
            ListTile(
              leading: const Icon(Icons.public, color: kGreen),
              title: const Text('GitHub · web'),
              subtitle: const Text('kirshp/madeira-ative'),
              onTap: () => openUrl('https://github.com/kirshp/madeira-ative'),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined, color: kGreen),
              title: const Text('GitHub · BullDozer'),
              subtitle: const Text('kirshp/bulldozer'),
              onTap: () => openUrl('https://github.com/kirshp/bulldozer'),
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline, color: kGreen),
              title: Text(t('contact')),
              subtitle: const Text('azenha.agent@gmail.com'),
              onTap: () => openUrl(
                  'mailto:azenha.agent@gmail.com?subject=Madeira%20Ativa'),
            ),
            ListTile(
              leading: const Icon(Icons.code, color: kGreen),
              title: const Text('GitHub'),
              subtitle: const Text('github.com/kirshp/ativa'),
              onTap: () => openUrl('https://github.com/kirshp/ativa'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.translate, color: kTerracotta),
              title: Text(t('language')),
              onTap: () {
                locale.value = locale.value == 'en' ? 'pt' : 'en';
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.brightness_6, color: kTerracotta),
                  const SizedBox(width: 12),
                  Text(t('theme'), style: TextStyle(color: context.cBody)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto, size: 18),
                      label: Text(t('theme_system'),
                          style: const TextStyle(fontSize: 11))),
                  ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode, size: 18),
                      label: Text(t('theme_light'),
                          style: const TextStyle(fontSize: 11))),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode, size: 18),
                      label: Text(t('theme_dark'),
                          style: const TextStyle(fontSize: 11))),
                ],
                selected: {themeModeN.value},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setThemeMode(s.first),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goTo,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined), label: t('home')),
          NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              label: t('events')),
          NavigationDestination(
              icon: const Icon(Icons.map_outlined), label: t('map')),
          NavigationDestination(
              icon: const Icon(Icons.hiking), label: t('levadas')),
          NavigationDestination(
              icon: const Icon(Icons.article_outlined), label: t('news')),
          NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              label: t('roots')),
        ],
      ),
    );
  }
}

class AtivaEvent {
  final String name;
  final String date;
  final String location;
  final String type;
  final String mode;
  final String url;

  AtivaEvent.fromJson(Map<String, dynamic> j)
      : name = j['name'] ?? '',
        date = j['date'] ?? '',
        location = j['location'] ?? '',
        type = j['event_type'] ?? 'other',
        mode = j['mode'] ?? '',
        url = j['url'] ?? '';
}

Future<List<AtivaEvent>> fetchEvents() async {
  final data = await cachedJson('https://shpara.com/madeira/events.json');
  final today = DateTime.now().toIso8601String().substring(0, 10);
  return (data['events'] as List)
      .map((e) => AtivaEvent.fromJson(e))
      .where((e) => e.date.compareTo(today) >= 0)
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

class NewsItem {
  final String title;
  final String snippet;
  final String link;
  final String date;
  final String lang;
  final Map<String, String> titles;
  final Map<String, String> snippets;

  NewsItem.fromJson(Map<String, dynamic> j)
      : title = j['title'] ?? '',
        snippet = j['snippet'] ?? '',
        link = j['link'] ?? '',
        date = j['date'] ?? '',
        lang = (j['lang'] ?? 'en').toString().toLowerCase(),
        titles = Map<String, String>.from(
            (j['titles'] ?? {}).map((k, v) => MapEntry(k, v.toString()))),
        snippets = Map<String, String>.from(
            (j['snippets'] ?? {}).map((k, v) => MapEntry(k, v.toString())));

  String titleFor(String lg) =>
      lg == lang ? title : (titles[lg]?.isNotEmpty == true ? titles[lg]! : title);

  String snippetFor(String lg) => lg == lang
      ? snippet
      : (snippets[lg]?.isNotEmpty == true ? snippets[lg]! : snippet);
}

class Broadcast {
  final String date, time, name, comp, channel;
  Broadcast.fromJson(Map<String, dynamic> j)
      : date = j['date'] ?? '',
        time = j['time'] ?? '',
        name = j['name'] ?? '',
        comp = j['comp'] ?? '',
        channel = j['channel'] ?? '';
}

Future<List<Broadcast>> fetchBroadcasts() async {
  final data = await cachedJson('https://shpara.com/madeira/tv_broadcasts.json');
  final list = (data['events'] ?? data['broadcasts'] ?? []) as List;
  final today = DateTime.now().toIso8601String().substring(0, 10);
  return list
      .map((j) => Broadcast.fromJson(j))
      .where((b) => b.date.compareTo(today) >= 0)
      .toList()
    ..sort((a, b) => (a.date + a.time).compareTo(b.date + b.time));
}

class WatchItem {
  final String name, mode, expected, location, url;
  WatchItem.fromJson(Map<String, dynamic> j)
      : name = j['name'] ?? '',
        mode = j['mode'] ?? '',
        expected = j['expected'] ?? '',
        location = j['location'] ?? '',
        url = j['url'] ?? '';
}

Future<List<WatchItem>> fetchWatchlist() async {
  final data = await cachedJson('https://shpara.com/madeira/watchlist.json');
  final list =
      (data is List ? data : data['watchlist'] ?? data['items'] ?? []) as List;
  return list.map((j) => WatchItem.fromJson(j)).toList();
}

const kNewsLangs = ['en', 'pt', 'de', 'pl', 'uk', 'ru'];
const kNewsLangLabels = {
  'en': 'EN',
  'pt': 'PT',
  'de': 'DE',
  'pl': 'PL',
  'uk': 'UK',
  'ru': 'RU',
};

const _typeIcons = {
  'running': Icons.directions_run,
  'trail': Icons.terrain,
  'cycling': Icons.directions_bike,
  'swimming': Icons.pool,
  'triathlon': Icons.timer,
  'orienteering': Icons.explore,
  'festival': Icons.celebration,
};

class HomePage extends StatefulWidget {
  final void Function(int) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AtivaEvent>? _events;
  List<NewsItem>? _news;
  List<Broadcast> _tv = [];
  List<TrailGeo> _geo = [];
  Map<String, dynamic>? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ev = await fetchEvents();
      if (mounted) setState(() => _events = ev);
    } catch (_) {
      if (mounted) setState(() => _events = []);
    }
    try {
      final tv = await fetchBroadcasts();
      if (mounted) setState(() => _tv = tv);
    } catch (_) {}
    try {
      final g = await fetchTrailGeo();
      if (mounted) setState(() => _geo = g);
    } catch (_) {}
    try {
      final s = await fetchTrailStatus();
      if (mounted) setState(() => _status = s);
    } catch (_) {}
    try {
      final data =
          await cachedJson('https://shpara.com/madeira/news_feed.json');
      final list =
          (data is List ? data : data['items'] ?? data['news'] ?? []) as List;
      if (mounted) {
        setState(
            () => _news = list.map((j) => NewsItem.fromJson(j)).toList());
      }
    } catch (_) {
      if (mounted) setState(() => _news = []);
    }
  }

  List<AtivaEvent> _mixed() {
    if (_events == null) return [];
    final seen = <String>{};
    final mix = <AtivaEvent>[];
    for (final e in _events!) {
      if (seen.add(e.type)) mix.add(e);
      if (mix.length == 5) return mix;
    }
    for (final e in _events!) {
      if (!mix.contains(e)) mix.add(e);
      if (mix.length == 5) break;
    }
    return mix;
  }

  @override
  Widget build(BuildContext context) {
    final hero = _events?.isNotEmpty == true ? _events!.first : null;
    final mix = _mixed().skip(1).take(3).toList();

    return RefreshIndicator(
      color: kGreen,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if ((_status?['alerts'] as List?)?.isNotEmpty ?? false)
            GestureDetector(
              onTap: () => widget.onNavigate(3),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: context.cTerraTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded,
                      color: context.cTerraText, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        '${(_status!['alerts'] as List).length} ${t('closed_now')} · ${(_status!['counts']?['partial'] ?? 0)} ${t('partial')}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.cTerraText)),
                  ),
                  Icon(Icons.chevron_right, color: context.cTerraText),
                ]),
              ),
            ),
          if (_geo.isNotEmpty)
            GestureDetector(
              onTap: () => widget.onNavigate(2),
              child: Container(
                height: 190,
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.cHairline, width: 0.5),
                ),
                child: Stack(children: [
                  IgnorePointer(
                    child: FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(32.745, -16.96),
                        initialZoom: 9.1,
                        interactionOptions: InteractionOptions(
                            flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.shpara.ativa',
                        ),
                        PolylineLayer(polylines: [
                          for (final t in _geo)
                            for (final line in t.lines)
                              Polyline(
                                points: line,
                                strokeWidth: 2.2,
                                color: t.status == 'open'
                                    ? kGreen
                                    : (t.status == 'closed'
                                        ? const Color(0xFFD84A3A)
                                        : const Color(0xFFE8920E)),
                              ),
                        ]),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: kGreenDark.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                          '${t('levadas_teaser')} · ${_geo.length} PR',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ]),
              ),
            ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.cTerraTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3, color: kTerracotta),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t('pessoa'),
                              style: TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  fontStyle: FontStyle.italic,
                                  color: context.cTitle)),
                          const SizedBox(height: 4),
                          Text(t('pessoa_by'),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kTerracotta)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => hero != null ? openUrl(hero.url) : null,
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                      hero == null
                          ? t('next_up')
                          : '${t('next_up')} · ${fmtDate(hero.date)} · ${hero.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9FE1CB))),
                  Text(hero?.name ?? t('loading'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kGreenLight)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(
              title: t('coming_up'),
              onMore: () => widget.onNavigate(1)),
          if (_events == null)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: kGreen)))
          else
            for (final e in mix)
              _EventTile(
                icon: _typeIcons[e.type] ?? Icons.event,
                title: e.name,
                subtitle: '${fmtDate(e.date)} · ${e.location} · ${e.type}',
                onTap: () => showEventActions(context, e),
              ),
          const SizedBox(height: 20),
          _SectionHeader(
              title: t('news'),
              onMore: () => widget.onNavigate(4)),
          if (_news != null)
            for (final n in _news!.take(3))
              Card(
                color: context.cSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      BorderSide(color: Colors.grey.shade300, width: 0.5),
                ),
                child: ListTile(
                  dense: true,
                  leading:
                      const Icon(Icons.article_outlined, color: kGreen),
                  title: Text(n.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  subtitle:
                      Text(n.date, style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.open_in_new,
                      size: 14, color: Colors.grey),
                  onTap: () => openUrl(n.link),
                ),
              ),
          if (_tv.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionHeader(
                title: t('on_tv'),
                onMore: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BroadcastsPage(broadcasts: _tv)))),
            for (final b in _tv.take(3))
              Card(
                color: context.cSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300, width: 0.5),
                ),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.live_tv, color: kTerracotta),
                  title: Text(b.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  subtitle: Text('${b.date} ${b.time} · ${b.channel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11)),
                ),
              ),
          ],
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => widget.onNavigate(3),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.cGreenTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.hiking, color: context.cTitle),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('levadas_teaser'),
                            style: TextStyle(
                                fontSize: 11, color: context.cTitle)),
                        Text(t('levadas_hook'),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: context.cTitle),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => widget.onNavigate(5),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.cTerraTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: kTerracotta),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('roots_teaser'),
                            style: const TextStyle(
                                fontSize: 11, color: kTerracotta)),
                        Text(t('roots_hook'),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: kTerracotta),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Finds the closest levada (heritage trail) to an event's location, within
/// [maxKm]. Realizes the "event ↔ heritage place" link: activities happen near
/// centuries-old work-paths.
Future<(Levada, double)?> nearestHeritage(String location,
    {double maxKm = 12}) async {
  final p = geocode(location);
  if (p == null) return null;
  List<Levada> levs;
  try {
    levs = await fetchLevadas();
  } catch (_) {
    return null;
  }
  const d = Distance();
  Levada? best;
  double bestKm = maxKm;
  for (final l in levs) {
    if (l.center == null) continue;
    final km = d.as(LengthUnit.Kilometer, p, l.center!);
    if (km < bestKm) {
      bestKm = km;
      best = l;
    }
  }
  return best == null ? null : (best, bestKm);
}

void showEventActions(BuildContext context, AtivaEvent e) {
  final key = 'event:${e.name}|${e.date}';
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text(e.name,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: ctx.cTitle)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
                [fmtDate(e.date), if (e.location.isNotEmpty) e.location, e.type]
                    .join(' · '),
                style: TextStyle(fontSize: 13, color: ctx.cSubtle)),
          ),
          FutureBuilder<(Levada, double)?>(
            future: nearestHeritage(e.location),
            builder: (_, snap) {
              final r = snap.data;
              if (r == null) return const SizedBox.shrink();
              final (l, km) = r;
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                decoration: BoxDecoration(
                  color: ctx.cTerraTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.account_balance_outlined,
                      color: ctx.cTerraText),
                  title: Text('${t('nearby_heritage')} · ${km.toStringAsFixed(1)} km',
                      style: TextStyle(
                          fontSize: 12, color: ctx.cTerraText)),
                  subtitle: Text('${l.code} · ${l.name}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () =>
                      openUrl(locale.value == 'pt' ? l.urlPt : l.urlEn),
                ),
              );
            },
          ),
          if (e.url.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.open_in_new, color: kGreen),
              title: Text(t('open_site')),
              onTap: () {
                Navigator.pop(ctx);
                openUrl(e.url);
              },
            ),
          ListTile(
            leading: const Icon(Icons.event_available, color: kGreen),
            title: Text(t('add_calendar')),
            onTap: () {
              Navigator.pop(ctx);
              final parts = e.date.split('-');
              final start = DateTime(int.parse(parts[0]), int.parse(parts[1]),
                  int.parse(parts[2]), 9);
              Add2Calendar.addEvent2Cal(Event(
                title: e.name,
                location: e.location,
                startDate: start,
                endDate: start.add(const Duration(hours: 2)),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.ios_share, color: kGreen),
            title: Text(t('share')),
            onTap: () {
              Navigator.pop(ctx);
              final text = [
                e.name,
                '${e.date}${e.location.isEmpty ? '' : ' · ${e.location}'}',
                if (e.url.isNotEmpty) e.url,
                '— Madeira Ativa'
              ].join('\n');
              SharePlus.instance.share(ShareParams(text: text));
            },
          ),
          ValueListenableBuilder(
            valueListenable: reminders,
            builder: (_, __, ___) {
              final on = hasReminder(key);
              return ListTile(
                leading: Icon(on ? Icons.notifications_active : Icons.notifications_none,
                    color: on ? kTerracotta : kGreen),
                title: Text(t('remind')),
                trailing: Switch(
                  value: on,
                  onChanged: (v) async {
                    final messenger = ScaffoldMessenger.of(context);
                    if (v) {
                      final ok = await setReminder(key, e.name, e.date);
                      messenger.showSnackBar(SnackBar(
                          content: Text(ok ? t('remind_set') : t('remind_off'))));
                    } else {
                      await cancelReminder(key);
                      messenger.showSnackBar(
                          SnackBar(content: Text(t('remind_off'))));
                    }
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMore;
  const _SectionHeader({required this.title, required this.onMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: onMore,
            child: Text(t('view_all'),
                style: const TextStyle(fontSize: 12, color: kGreen)),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? favKey;
  const _EventTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.onTap,
      this.favKey});

  @override
  Widget build(BuildContext context) {
    Widget? trailing;
    if (favKey != null) {
      trailing = ValueListenableBuilder(
        valueListenable: favorites,
        builder: (_, __, ___) {
          final fav = isFav(favKey!);
          return IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(fav ? Icons.star : Icons.star_border,
                color: fav ? kTerracotta : Colors.grey, size: 20),
            onPressed: () => toggleFav(favKey!),
          );
        },
      );
    } else if (onTap != null) {
      trailing = const Icon(Icons.chevron_right, color: Colors.grey);
    }
    return Card(
      color: context.cSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: kGreen),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<AtivaEvent>? _events;
  List<WatchItem> _watch = [];
  String? _error;
  String _filter = 'all';
  String? _day;
  String _query = '';
  bool _searching = false;
  bool _favOnly = false;
  bool _compact = false;
  String _period = 'month';

  static const _periods = <(String, String, int)>[
    ('next', 'p_next', 0),
    ('week', 'p_week', 7),
    ('month', 'p_month', 31),
    ('3mo', 'p_3mo', 92),
    ('6mo', 'p_6mo', 183),
    ('year', 'p_year', 365),
  ];

  int get _periodDays =>
      _periods.firstWhere((p) => p.$1 == _period).$3;

  String _favKey(AtivaEvent e) => 'event:${e.name}|${e.date}';

  // Event categories mirror the Madeira site's mode filter (grouped by `mode`).
  static const _modeCats = <(String, String, String)>[
    ('all', '', 'All'),
    ('trail', '🏃', 'Trail'),
    ('road', '🛣', 'Road'),
    ('orienteering', '🧭', 'Orient'),
    ('cycling', '🚴', 'Bike'),
    ('kids', '👶', 'Kids'),
    ('pro', '🏆', 'Pro'),
    ('swim', '🏊', 'Swim'),
    ('festivals', '🎪', 'Fest'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await fetchEvents();
      setState(() => _events = list);
    } catch (e) {
      setState(() => _error = e.toString());
    }
    try {
      final w = await fetchWatchlist();
      if (mounted) setState(() => _watch = w);
    } catch (_) {}
  }

  static const _wd = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  // Same heuristic as the site: orientation events live under mode 'trail'.
  bool _isOrientacao(AtivaEvent e) =>
      e.type == 'orienteering' ||
      e.name.startsWith('Orientação:') ||
      e.url.contains('aoram.pt');

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Couldn\'t load events.\n$_error',
            textAlign: TextAlign.center),
      ));
    }
    if (_events == null) {
      return skeletonList(context);
    }
    // Category filter mirrors the Madeira site exactly: orienteering is a
    // subset of mode 'trail' (by the Orientação heuristic), trail excludes it,
    // swim also picks up swimming_kids.
    var shown = switch (_filter) {
      'all' => _events!,
      'orienteering' =>
        _events!.where((e) => e.mode == 'trail' && _isOrientacao(e)).toList(),
      'trail' =>
        _events!.where((e) => e.mode == 'trail' && !_isOrientacao(e)).toList(),
      'swim' => _events!
          .where((e) => e.mode == 'swim' || e.type == 'swimming_kids')
          .toList(),
      _ => _events!.where((e) => e.mode == _filter).toList(),
    };
    if (_day != null) {
      shown = shown.where((e) => e.date == _day).toList();
    } else if (_period == 'next') {
      // Only the first upcoming day that has events (site's "Next" mode).
      if (shown.isNotEmpty) {
        final first = shown.first.date;
        shown = shown.where((e) => e.date == first).toList();
      }
    } else {
      // No specific day picked: bound the list by the selected period window.
      final end = DateTime.now()
          .add(Duration(days: _periodDays))
          .toIso8601String()
          .substring(0, 10);
      shown = shown.where((e) => e.date.compareTo(end) <= 0).toList();
    }
    if (_favOnly) {
      shown = shown.where((e) => isFav(_favKey(e))).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      shown = shown
          .where((e) =>
              e.name.toLowerCase().contains(q) ||
              e.location.toLowerCase().contains(q))
          .toList();
    }
    final eventDays = _events!.map((e) => e.date).toSet();
    final today = DateTime.now();
    final days = List.generate(30, (i) => today.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            children: [
              Text(t('events'),
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: context.cTitle)),
              const Spacer(),
              if (_day != null)
                ActionChip(
                  label: Text(t('all_dates'),
                      style: const TextStyle(fontSize: 12)),
                  avatar: const Icon(Icons.close, size: 14),
                  onPressed: () => setState(() => _day = null),
                ),
              ValueListenableBuilder(
                valueListenable: favorites,
                builder: (_, __, ___) => IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(_favOnly ? Icons.star : Icons.star_border,
                      color: _favOnly ? kTerracotta : context.cTitle),
                  onPressed: () => setState(() => _favOnly = !_favOnly),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(_searching ? Icons.search_off : Icons.search,
                    color: context.cTitle),
                onPressed: () => setState(() {
                  _searching = !_searching;
                  if (!_searching) _query = '';
                }),
              ),
            ],
          ),
        ),
        if (_searching)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                isDense: true,
                hintText: '${t('events')}…',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
          height: _compact ? 0 : 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final p in _periods)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ChoiceChip(
                    label: Text(t(p.$2)),
                    selected: _day == null && _period == p.$1,
                    showCheckmark: false,
                    selectedColor: kGreen,
                    labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: (_day == null && _period == p.$1)
                            ? kGreenLight
                            : context.cTitle),
                    onSelected: (_) => setState(() {
                      _period = p.$1;
                      _day = null;
                    }),
                  ),
                ),
            ],
          ),
          ),
        ),
        SizedBox(
          height: 62,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final d in days)
                Builder(builder: (_) {
                  final iso = d.toIso8601String().substring(0, 10);
                  final sel = _day == iso;
                  final has = eventDays.contains(iso);
                  return GestureDetector(
                    onTap: () => setState(() => _day = sel ? null : iso),
                    child: Container(
                      width: 46,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: sel ? kGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_wd[d.weekday - 1],
                              style: TextStyle(
                                  fontSize: 10,
                                  color: sel
                                      ? kGreenLight
                                      : (d.weekday >= 6
                                          ? kTerracotta
                                          : Colors.grey))),
                          Text('${d.day}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      sel ? Colors.white : context.cTitle)),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: has
                                  ? (sel ? Colors.white : kGreen)
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final cat in _modeCats)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: FilterChip(
                    showCheckmark: false,
                    label: Text(cat.$1 == 'all'
                        ? cat.$3
                        : '${cat.$2} ${cat.$3}'),
                    selected: _filter == cat.$1,
                    selectedColor: kGreen,
                    backgroundColor: context.cSurface,
                    shape: StadiumBorder(
                        side: BorderSide(
                            color: _filter == cat.$1
                                ? kGreen
                                : context.cHairline)),
                    labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _filter == cat.$1 ? kGreenLight : context.cTitle),
                    onSelected: (_) => setState(() => _filter = cat.$1),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
              _day == null
                  ? '${shown.length} ${t('upcoming')}'
                  : '${shown.length} ${t('on')} $_day',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Expanded(
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: (n) {
              final down = n.metrics.pixels > 40;
              if (down != _compact) setState(() => _compact = down);
              return false;
            },
            child: RefreshIndicator(
            color: kGreen,
            onRefresh: _load,
            child: Builder(builder: (_) {
              final showWatch = _day == null &&
                  !_favOnly &&
                  _query.isEmpty &&
                  _watch.isNotEmpty;
              final watchStart = shown.length;
              if (shown.isEmpty && !showWatch) {
                return ListView(children: [
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(children: [
                      Icon(Icons.search_off,
                          size: 40, color: context.cSubtle),
                      const SizedBox(height: 10),
                      Text(t('nothing_found'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.cSubtle)),
                    ]),
                  ),
                ]);
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount:
                    shown.length + (showWatch ? 1 + _watch.length : 0),
                itemBuilder: (_, i) {
                  if (i < shown.length) {
                    final e = shown[i];
                    final showDate = i == 0 || shown[i - 1].date != e.date;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
                            child: Text(fmtDate(e.date),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: kTerracotta)),
                          ),
                        _EventTile(
                          icon: _typeIcons[e.type] ?? Icons.event,
                          title: e.name,
                          subtitle: e.location.isEmpty
                              ? e.type
                              : '${e.location} · ${e.type}',
                          onTap: () => showEventActions(context, e),
                          favKey: _favKey(e),
                        ),
                      ],
                    );
                  }
                  if (i == watchStart) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(6, 20, 6, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.visibility_outlined,
                                size: 18, color: kTerracotta),
                            const SizedBox(width: 6),
                            Text(t('watchlist'),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: kTerracotta)),
                          ]),
                          Text(t('watchlist_sub'),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  final w = _watch[i - watchStart - 1];
                  return Card(
                    color: context.cTerraTint,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(_typeIcons[w.mode] ?? Icons.event,
                          color: kTerracotta),
                      title: Text(w.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          w.expected.isEmpty
                              ? w.location
                              : '${w.expected} · ${w.location}',
                          style: const TextStyle(fontSize: 12)),
                      trailing: w.url.isEmpty
                          ? null
                          : const Icon(Icons.open_in_new,
                              size: 14, color: Colors.grey),
                      onTap: w.url.isEmpty ? null : () => openUrl(w.url),
                    ),
                  );
                },
              );
            }),
            ),
          ),
        ),
      ],
    );
  }
}

List<double> _parseProfile(dynamic p) {
  try {
    final l = p is String ? (p.isEmpty ? [] : (p.startsWith('[') ? (List.from((p as dynamic).isEmpty ? [] : (p as String).replaceAll('[','').replaceAll(']','').split(',').map(double.parse))) : [])) : (p as List? ?? []);
    return [for (final x in l) (x as num).toDouble()];
  } catch (_) { return []; }
}

class Levada {
  final String code;
  final String name;
  final String status;
  final String distance;
  final String ascent;
  final String fee;
  final String urlEn;
  final String urlPt;
  final LatLng? center;
  final List<double> profile;
  final String fromP, toP;
  String? official;

  /// Official feed wins over the bundled levadas.json status.
  String get state => (official?.isNotEmpty ?? false) ? official! : status;
  bool get isOpen => state == 'open';
  bool get isPartial => state == 'partial';

  Levada.fromJson(Map<String, dynamic> j)
      : code = j['code'] ?? '',
        name = j['name'] ?? '',
        status = j['status'] ?? '',
        distance = j['distance_km']?.toString() ?? '?',
        ascent = j['ascent_m']?.toString() ?? '?',
        fee = j['charge']?.toString() ?? '',
        urlEn = j['url_en'] ?? '',
        urlPt = j['url_pt'] ?? '',
        profile = _parseProfile(j['profile']),
        fromP = j['from'] ?? '',
        toP = j['to'] ?? '',
        center = j['center'] == null
            ? null
            : LatLng((j['center'][0] as num).toDouble(),
                (j['center'][1] as num).toDouble());
}

List<Levada>? _levadaCache;

/// Official trail-status feed: fresher than levadas.json and it knows the
/// 'partial' state plus an alerts list of what is closed right now.
Map<String, dynamic>? _statusCache;

Future<Map<String, dynamic>> fetchTrailStatus() async {
  if (_statusCache != null) return _statusCache!;
  final d = await cachedJson('https://shpara.com/madeira/trails_status.json');
  _statusCache = Map<String, dynamic>.from(d as Map);
  return _statusCache!;
}

Future<List<Levada>> fetchLevadas() async {
  if (_levadaCache != null) return _levadaCache!;
  final data = await cachedJson('https://shpara.com/madeira/levadas.json');
  _levadaCache = (data['levadas'] as List)
      .map((j) => Levada.fromJson(j))
      .toList();
  try {
    final st = await fetchTrailStatus();
    final by = {
      for (final t in (st['trails'] as List? ?? []))
        (t['code'] ?? '').toString(): (t['status'] ?? '').toString()
    };
    for (final l in _levadaCache!) {
      final s = by[l.code];
      if (s != null && s.isNotEmpty) l.official = s;
    }
  } catch (_) {}
  _checkStatusChanges(_levadaCache!);
  return _levadaCache!;
}


class TrailGeo {
  final String status;
  final List<List<LatLng>> lines;
  TrailGeo(this.status, this.lines);
}

List<TrailGeo>? _trailGeoCache;

Future<List<TrailGeo>> fetchTrailGeo() async {
  if (_trailGeoCache != null) return _trailGeoCache!;
  final data = await cachedJson('https://shpara.com/madeira/trails_geo.json');
  _trailGeoCache = [
    for (final t in (data['trails'] as List))
      TrailGeo(
        t['status'] ?? '',
        [
          for (final line in (t['lines'] as List? ?? []))
            [
              for (final p in (line as List))
                LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble())
            ]
        ],
      )
  ];
  return _trailGeoCache!;
}

/// Compares trail statuses with the previously seen ones and fires a local
/// notification when something opened/closed since last launch.
void _checkStatusChanges(List<Levada> ls) {
  try {
    final prev = prefs.getString('levada_status') ?? '';
    final now = ls.map((l) => '${l.code}:${l.status}').join(',');
    if (prev.isNotEmpty && prev != now) {
      final old = {for (final p in prev.split(',')) p.split(':')[0]: p.split(':').last};
      final diffs = [
        for (final l in ls)
          if (old[l.code] != null && old[l.code] != l.status)
            '${l.code} → ${l.status}'
      ];
      if (diffs.isNotEmpty) {
        notifyNow(t('status_changed'), diffs.take(4).join(' · '));
      }
    }
    prefs.setString('levada_status', now);
  } catch (_) {}
}

class LevadasPage extends StatefulWidget {
  const LevadasPage({super.key});

  @override
  State<LevadasPage> createState() => _LevadasPageState();
}

class _LevadasPageState extends State<LevadasPage> {
  List<Levada>? _levadas;
  String _query = '';
  bool _searching = false;
  bool _favOnly = false;
  String _sort = 'name';

  String _favKey(Levada l) => 'levada:${l.code}';

  @override
  void initState() {
    super.initState();
    fetchLevadas().then((l) {
      if (mounted) setState(() => _levadas = l);
    }).catchError((_) {
      if (mounted) setState(() => _levadas = []);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_levadas == null) {
      return skeletonList(context);
    }
    var shown = _levadas!;
    if (_favOnly) {
      shown = shown.where((l) => isFav(_favKey(l))).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      shown = shown
          .where((l) =>
              l.name.toLowerCase().contains(q) ||
              l.code.toLowerCase().contains(q))
          .toList();
    }
    shown = [...shown];
    double numOf(String s) => double.tryParse(s) ?? 0;
    if (_sort == 'km') {
      shown.sort((a, b) => numOf(b.distance).compareTo(numOf(a.distance)));
    } else if (_sort == 'climb') {
      shown.sort((a, b) => numOf(b.ascent).compareTo(numOf(a.ascent)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: shown.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          double km = 0, climb = 0;
          for (final l in _levadas!) {
            km += double.tryParse(l.distance) ?? 0;
            climb += double.tryParse(l.ascent) ?? 0;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 0, 10),
                child: Row(
                  children: [
                    Text(t('levadas'),
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: context.cTitle)),
                    const Spacer(),
                    ValueListenableBuilder(
                      valueListenable: favorites,
                      builder: (_, __, ___) => IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                            _favOnly ? Icons.star : Icons.star_border,
                            color: _favOnly ? kTerracotta : context.cTitle),
                        onPressed: () =>
                            setState(() => _favOnly = !_favOnly),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.bar_chart, color: context.cTitle),
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const StatsPage())),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.sort, color: context.cTitle),
                      onSelected: (v) => setState(() => _sort = v),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'name', child: Text(t('sort_name'))),
                        PopupMenuItem(
                            value: 'km', child: Text(t('sort_km'))),
                        PopupMenuItem(
                            value: 'climb', child: Text(t('sort_climb'))),
                      ],
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                          _searching ? Icons.search_off : Icons.search,
                          color: context.cTitle),
                      onPressed: () => setState(() {
                        _searching = !_searching;
                        if (!_searching) _query = '';
                      }),
                    ),
                  ],
                ),
              ),
              if (_searching)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '${t('levadas')}…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: kGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat('${_levadas!.length}', t('stat_routes')),
                    _stat(km.round().toString(), t('stat_km')),
                    _stat('${(climb / 1000).toStringAsFixed(0)}k',
                        t('stat_climb')),
                    _stat('1848', t('stat_peak')),
                  ],
                ),
              ),
            ],
          );
        }
        final l = shown[i - 1];
        final open = l.isOpen;
        final part = l.isPartial;
        return Card(
          color: context.cSurface,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: open ? kGreenLight : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(l.code.replaceAll(' ', '\n'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: open
                            ? context.cTitle
                            : (part
                                ? const Color(0xFFB06A00)
                                : Colors.grey))),
              ),
            ),
            title: Text(l.name,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(
                '${l.distance} km · ↑${l.ascent} m · ${t(open ? 'open' : 'closed')}'
                '${l.fee.isNotEmpty && l.fee != 'None' ? ' · ${t('fee')} ${l.fee}' : ''}',
                style: TextStyle(
                    fontSize: 12,
                    color: open
                        ? Colors.grey.shade700
                        : (part ? const Color(0xFFB06A00) : Colors.red))),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => LevadaPage(l: l))),
            trailing: ValueListenableBuilder(
              valueListenable: favorites,
              builder: (_, __, ___) {
                final fav = isFav(_favKey(l));
                return IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(fav ? Icons.star : Icons.star_border,
                      color: fav ? kTerracotta : Colors.grey, size: 20),
                  onPressed: () => toggleFav(_favKey(l)),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Levada>? _levadas;
  List<(AtivaEvent, LatLng)> _events = [];
  String _layer = 'events';

  @override
  void initState() {
    super.initState();
    fetchLevadas().then((l) {
      if (mounted) setState(() => _levadas = l);
    }).catchError((_) {
      if (mounted) setState(() => _levadas = []);
    });
    fetchEvents().then((list) {
      final geo = <(AtivaEvent, LatLng)>[];
      for (final e in list) {
        final p = geocode(e.location);
        if (p != null) geo.add((e, p));
      }
      if (mounted) setState(() => _events = geo);
    }).catchError((_) {});
  }

  void _showTrail(Levada l) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l.code} · ${l.name}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.cTitle)),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.route, size: 16, color: kGreen),
              Text(' ${l.distance} km   '),
              const Icon(Icons.trending_up, size: 16, color: kGreen),
              Text(' ↑${l.ascent} m   '),
              Icon(l.status == 'open' ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: l.status == 'open' ? kGreen : Colors.red),
              Text(' ${t(l.status == 'open' ? 'open' : 'closed')}'),
            ]),
            if (l.fee.isNotEmpty && l.fee != 'None')
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('${t('fee')}: ${l.fee}',
                    style:
                        const TextStyle(fontSize: 13, color: kTerracotta)),
              ),
            const SizedBox(height: 12),
            Row(children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => LevadaPage(l: l)));
                },
                icon: const Icon(Icons.landscape, size: 16),
                label: Text(t('elev_profile')),
              ),
              TextButton.icon(
                onPressed: () =>
                    openUrl(locale.value == 'pt' ? l.urlPt : l.urlEn),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('visitmadeira.com'),
              ),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_levadas == null) {
      return skeletonList(context);
    }
    final showEvents = _layer == 'events';
    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(32.75, -16.97),
            initialZoom: 10,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.shpara.ativa',
            ),
            MarkerLayer(
              markers: showEvents
                  ? [
                      for (final (e, p) in _events)
                        Marker(
                          point: p,
                          width: 34,
                          height: 34,
                          child: GestureDetector(
                            onTap: () => showEventActions(context, e),
                            child: Container(
                              decoration: BoxDecoration(
                                color: kTerracotta,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: Icon(_typeIcons[e.type] ?? Icons.event,
                                  size: 17, color: Colors.white),
                            ),
                          ),
                        ),
                    ]
                  : [
                      for (final l in _levadas!)
                        if (l.center != null)
                          Marker(
                            point: l.center!,
                            width: 34,
                            height: 34,
                            child: GestureDetector(
                              onTap: () => _showTrail(l),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: l.isOpen
                                      ? kGreen
                                      : (l.isPartial
                                          ? const Color(0xFFE8920E)
                                          : Colors.grey),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.directions_walk,
                                    size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                    ],
            ),
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Text('© OpenStreetMap',
                    style: TextStyle(fontSize: 10, color: Colors.black54)),
              ),
            ),
          ],
        ),
        Positioned(
          right: 14,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'mapheat',
                backgroundColor: kTerracotta,
                foregroundColor: Colors.white,
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const WebPage(
                            title: 'Heatmap',
                            url: 'https://shpara.com/madeira/map'))),
                icon: const Icon(Icons.local_fire_department),
                label: const Text('Heat'),
              ),
              const SizedBox(height: 10),
              FloatingActionButton.extended(
                heroTag: 'map3d',
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const WebPage(
                            title: '3D',
                            url: 'https://shpara.com/madeira/map3d'))),
                icon: const Icon(Icons.threed_rotation),
                label: const Text('3D'),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Center(
            child: SegmentedButton<String>(
              style: SegmentedButton.styleFrom(
                  backgroundColor: context.cSurface),
              segments: [
                ButtonSegment(
                    value: 'events',
                    icon: const Icon(Icons.event, size: 16),
                    label: Text('${t('events')} (${_events.length})',
                        style: const TextStyle(fontSize: 12))),
                ButtonSegment(
                    value: 'levadas',
                    icon: const Icon(Icons.hiking, size: 16),
                    label: Text(t('levadas'),
                        style: const TextStyle(fontSize: 12))),
              ],
              selected: {_layer},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _layer = s.first),
            ),
          ),
        ),
      ],
    );
  }
}

class WebPage extends StatefulWidget {
  final String title;
  final String url;
  const WebPage({super.key, required this.title, required this.url});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController _c;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) {
        if (mounted) setState(() => _loading = false);
      }))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          WebViewWidget(controller: _c),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: kGreen)),
        ],
      ),
    );
  }
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsItem>? _news;
  late String _lang;

  @override
  void initState() {
    super.initState();
    _lang = locale.value == 'pt' ? 'pt' : 'en';
    _load();
  }

  Future<void> _load() async {
    try {
      final data =
          await cachedJson('https://shpara.com/madeira/news_feed.json');
      final list =
          (data is List ? data : data['items'] ?? data['news'] ?? []) as List;
      if (mounted) {
        setState(() => _news = list.map((j) => NewsItem.fromJson(j)).toList());
      }
    } catch (_) {
      if (mounted) setState(() => _news = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_news == null) {
      return skeletonList(context);
    }
    return RefreshIndicator(
      color: kGreen,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _news!.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('news'),
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: context.cTitle)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final lg in kNewsLangs)
                      GestureDetector(
                        onTap: () => setState(() => _lang = lg),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color:
                                _lang == lg ? kGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: _lang == lg
                                    ? kGreen
                                    : Colors.grey.shade400,
                                width: 0.5),
                          ),
                          child: Text(kNewsLangLabels[lg]!,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _lang == lg
                                      ? Colors.white
                                      : context.cTitle)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            );
          }
          final n = _news![i - 1];
          final translated = n.lang != _lang;
          return Card(
            color: context.cSurface,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300, width: 0.5),
            ),
            child: InkWell(
              onTap: () => _open(n),
              child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2, right: 8),
                        child: Icon(Icons.article_outlined,
                            size: 18, color: kGreen),
                      ),
                      Expanded(
                        child: Text(n.titleFor(_lang),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                      const Icon(Icons.open_in_new,
                          size: 14, color: Colors.grey),
                    ],
                  ),
                  if (n.snippetFor(_lang).isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(n.snippetFor(_lang),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Colors.grey.shade700)),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(n.date,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: context.cGreenTint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                            translated
                                ? '${kNewsLangLabels[_lang]} · auto'
                                : n.lang.toUpperCase(),
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: context.cTitle)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  void _open(NewsItem n) => openUrl(n.link);
}

class BroadcastsPage extends StatelessWidget {
  final List<Broadcast> broadcasts;
  const BroadcastsPage({super.key, required this.broadcasts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('broadcasts'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: broadcasts.length,
        itemBuilder: (_, i) {
          final b = broadcasts[i];
          final showDate = i == 0 || broadcasts[i - 1].date != b.date;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDate)
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
                  child: Text(b.date,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kTerracotta)),
                ),
              Card(
                color: context.cSurface,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300, width: 0.5),
                ),
                child: ListTile(
                  leading: const Icon(Icons.live_tv, color: kTerracotta),
                  title: Text(b.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('${b.time} · ${b.comp} · ${b.channel}',
                      style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _stat(String value, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
      Text(label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF9FE1CB))),
    ],
  );
}

Widget histImage(String path, {double height = 190}) {
  return Image.network(
    'https://shpara.com/madeira/$path',
    height: height,
    width: double.infinity,
    fit: BoxFit.cover,
    loadingBuilder: (_, child, p) => p == null
        ? child
        : Container(
            height: height,
            color: kTerracottaLight,
            child: const Center(
                child: CircularProgressIndicator(color: kTerracotta))),
    errorBuilder: (_, __, ___) =>
        Container(height: 60, color: kTerracottaLight),
  );
}
