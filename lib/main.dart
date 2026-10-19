import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'gazetteer.dart';
import 'ask_review.dart';
import 'island_now.dart';
import 'levada_page.dart';
import 'stats_page.dart';
import 'notify.dart';
import 'roots_page.dart';
import 'store.dart';
import 'stories_data.dart';
import 'strings_de.dart';
import 'strings_ru.dart';

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

// Bottom-bar positions. Home's shortcuts navigate by these names, not by bare
// numbers, so adding a tab (Ask AI went in after Home) moves one list instead of
// silently sending "Levadas" to the map.
const kTabHome = 0;
const kTabAsk = 1;
const kTabEvents = 2;
const kTabMap = 3;
const kTabLevadas = 4;
const kTabNews = 5;
// Roots is no longer a tab: seven made every label small on a phone. It opens
// as its own screen from the drawer, from News and from Home (openRoots).

final themeModeN = ValueNotifier<ThemeMode>(ThemeMode.light);

const _tr = {
  'en': {
    'home': 'Home',
    'ask': 'Ask AI',
    'by_bus': 'Trails by bus',
    'next_bus': 'Next',
    'tomorrow_w': 'tomorrow',
    'webcam': 'Live webcam',
    'on_path': 'On the path',
    'path_src': 'OpenStreetMap, where surveyed; mapped on',
    'of_route': 'of the route',
    'roots_link': 'Roots — 600 years of island history',
    'get_there': 'How to get there',
    'upper_end': 'Upper end',
    'lower_end': 'Lower end',
    'trail_end': 'Trail end',
    'loop_end': 'Start and finish',
    'drive_park': 'Drive to the car park',
    'from_path': 'from the path',
    'paid': 'paid',
    'end_on_map': 'This end on the map',
    'no_park': 'no mapped car park nearby',
    'bus_one': 'Bus',
    'bus_many': 'Buses',
    'pass_one': 'passes here',
    'pass_many': 'pass here',
    'no_route': 'No bus route mapped near this end',
    'plan_bus': 'Plan the trip here by bus',
    'all_timetables': 'All bus timetables (SIGA)',
    'time_official': 'Official time and difficulty from Visit Madeira, as on the trailhead board.',
    'ipma_here': 'IPMA warnings for this trail\'s zone',
    'events': 'Events',
    'map': 'Map',
    'levadas': 'Levadas',
    'roots': 'Roots',
    'next_up': 'Next up',
    'lv_open': 'open',
    'lv_partly': 'partly',
    'lv_closed': 'closed',
    'webcams_live': 'Live views of the island',
    'new_badge': 'NEW',
    'bus_promo': 'Island bus timetables',
    'bus_promo_sub': 'Which trails you can reach by bus, stops and next departures',
    'coming_up': 'Coming up',
    'news': 'News',
    'all_news': 'All news',
    'roots_teaser': 'Roots · the island\'s memory',
    'roots_hook': 'Old Madeira in 19 pictures — levadas, sugar, wine sledges',
    'levadas_teaser': 'Levadas & trails',
    'levadas_hook': '44 official PR routes with status and elevation',
    'upcoming': 'upcoming', 'later': 'later',
    'on': 'on',
    'all_dates': 'All dates',
    'loading': 'Loading…',
    'open': 'open',
    'closed': 'closed',
    'closed_now': 'closed now',
    'partial': 'partly open',
    'fee': 'Fee',
    'pay_link': 'Book & pay on SIMplifica',
    'glossary': 'Words on the signs',
    'g_levada': 'Levada — a hand-cut irrigation channel; the path runs along its bank, so the walk is nearly level.',
    'g_vereda': 'Vereda — a footpath, usually over a ridge or down to the sea, so expect climbing.',
    'g_pr': 'PR — Pequena Rota, an official waymarked trail with a number; only PR routes carry the fee and the status feed.',
    'g_partial': 'Partially open — one section is closed; the rest can be walked, and the sign at the closure says where to turn back.',
    'g_oneway': 'Open one way — you may walk it in one direction only, usually to avoid crowds on a narrow stretch.',
    'races_here': 'Races along this trail', 'covers': 'covers',
    'rate_app': 'Rate the app',
    'heat': 'Heat',
    'cat_all': 'All', 'cat_trail': 'Trail', 'cat_road': 'Road',
    'cat_orient': 'Orient', 'cat_bike': 'Bike', 'cat_kids': 'Kids',
    'cat_pro': 'Pro', 'cat_swim': 'Swim', 'cat_other': 'Other', 'cat_fest': 'Fest',
    // The Fest shelf's own categories, from the feed's `category`.
    'cc_concert': 'Concert', 'cc_theatre': 'Theatre', 'cc_exhibition': 'Exhibition',
    'cc_cinema': 'Cinema', 'cc_dance': 'Dance', 'cc_folklore': 'Folklore',
    'cc_arraial': 'Arraial', 'cc_religious': 'Religious', 'cc_festival': 'Festival',
    'cc_market': 'Market', 'cc_food': 'Food & wine', 'cc_family': 'Family',
    'cc_workshop': 'Workshop', 'cc_talk': 'Talks & books', 'cc_show': 'Show',
    'cc_sport': 'Sport', 'cc_culture': 'Culture',
    'more_in_fest': 'more in Fest',
    'dist': 'dist', 'climb': 'climb', 'status': 'status',
    'weather': 'Weather here', 'weather_src': 'Forecast for this trail\u2019s own coordinates \u00b7 Open-Meteo', 'today': 'Today',
    'nearby': 'Walkable nearby', 'as_the_crow': 'away',
    'of_trail': 'of the trail', 'editions': 'editions', 'finishers_total': 'finishers',
    'course_record': 'Course record', 'race_not_trail': 'Times are for the full race, not this section',
    'descent': 'Descent', 'marking': 'Waymark', 'route_type': 'Route',
    'roundtrip': 'Round trip', 'one_way': 'Point to point',
    'on_foot': 'On foot', 'altitude': 'Altitude', 'steepest': 'Steepest climb',
    'difficulty': 'Difficulty', 'easy': 'Easy', 'moderate': 'Moderate', 'hard': 'Hard',
    'time_note': 'Estimate — 12 min/km, plus climb and descent',
    'website': 'Website',
    'telegram': 'Telegram bot',
    'tg_channel': 'Weekly digest channel',
    'language': 'Português',
    'roots_sub': "The island's memory, one place at a time",
    'view_all': 'View all',
    'roots_h1': 'How Madeira learned to move',
    'timeline': 'The timeline',
    'timeline_sub': 'Six hundred years in six chapters — worth a slow scroll.',
    'album': 'The Album',
    'album_sub': 'Eighteen pictures of old Madeira.',
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
    'open_site': 'Open site', 'open_calendar': 'Open the organiser\'s calendar', 'open_calendar_hint': 'No page for this race yet — a season calendar',
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
    'web_failed': 'This map needs a connection. Check your network and try again.',
    'retry': 'Try again',
    'privacy': 'Privacy policy',
    'countries': 'Countries',
    'intl_trend': 'International runners by year',
    'time_dist': 'Median finish time',
    'stats': 'Trail stats','finishers_year':'Finishers by year','top_clubs':'Top clubs','top_localities':'Top localities','toughest':'Toughest races (DNF %)','finish_hours':'Finish times (hour of day)','loyalty':'Returning runners (years raced)','elev_profile':'Elevation profile','status_changed':'Trail status changed','p_next':'Next','p_today':'Today','p_weekend':'Weekend','organized_by':'Organised by',
  },
  'pt': {
    'home': 'Início',
    'ask': 'Ask AI',
    'by_bus': 'Percursos de autocarro',
    'next_bus': 'Próximos',
    'tomorrow_w': 'amanhã',
    'webcam': 'Webcam em direto',
    'on_path': 'No trilho',
    'path_src': 'OpenStreetMap, onde levantado; mapeado em',
    'of_route': 'do percurso',
    'roots_link': 'Raízes — 600 anos de história da ilha',
    'get_there': 'Como chegar',
    'upper_end': 'Extremo superior',
    'lower_end': 'Extremo inferior',
    'trail_end': 'Extremo do percurso',
    'loop_end': 'Início e fim',
    'drive_park': 'Ir de carro até ao parque',
    'from_path': 'do percurso',
    'paid': 'pago',
    'end_on_map': 'Este extremo no mapa',
    'no_park': 'sem parque mapeado perto',
    'bus_one': 'Autocarro',
    'bus_many': 'Autocarros',
    'pass_one': 'passa aqui',
    'pass_many': 'passam aqui',
    'no_route': 'Sem linha de autocarro mapeada perto deste extremo',
    'plan_bus': 'Planear a viagem de autocarro até aqui',
    'all_timetables': 'Todos os horários (SIGA)',
    'time_official': 'Duração e dificuldade oficiais da Visit Madeira, como no painel do início do percurso.',
    'ipma_here': 'Avisos IPMA para a zona deste percurso',
    'events': 'Eventos',
    'map': 'Mapa',
    'levadas': 'Levadas',
    'roots': 'Raízes',
    'next_up': 'A seguir',
    'lv_open': 'abertas',
    'lv_partly': 'parciais',
    'lv_closed': 'encerradas',
    'webcams_live': 'Vistas em direto da ilha',
    'new_badge': 'NOVO',
    'bus_promo': 'Horários de autocarro',
    'bus_promo_sub': 'Percursos com acesso de autocarro, paragens e próximas partidas',
    'coming_up': 'Próximos',
    'news': 'Notícias',
    'all_news': 'Todas as notícias',
    'roots_teaser': 'Raízes · a memória da ilha',
    'roots_hook': 'A Madeira antiga em 19 imagens — levadas, açúcar, corsas',
    'levadas_teaser': 'Levadas e veredas',
    'levadas_hook': '44 percursos PR oficiais com estado e desnível',
    'upcoming': 'a seguir', 'later': 'mais tarde',
    'on': 'em',
    'all_dates': 'Todas as datas',
    'loading': 'A carregar…',
    'open': 'aberto',
    'closed': 'fechado',
    'closed_now': 'fechadas agora',
    'partial': 'parcial',
    'fee': 'Taxa',
    'pay_link': 'Reservar e pagar no SIMplifica',
    'glossary': 'As palavras das placas',
    'g_levada': 'Levada — canal de rega talhado à mão; o caminho segue a margem, por isso o percurso é quase plano.',
    'g_vereda': 'Vereda — caminho pedonal, normalmente por uma crista ou a descer ao mar; conte com subida.',
    'g_pr': 'PR — Pequena Rota, percurso oficial sinalizado com número; só os PR têm taxa e estado atualizado.',
    'g_partial': 'Parcialmente aberto — um troço está fechado; o resto percorre-se, e a placa no fecho indica onde voltar.',
    'g_oneway': 'Aberto num sentido — só se percorre numa direção, normalmente para evitar cruzamentos num troço estreito.',
    'races_here': 'Provas que passam aqui', 'covers': 'cobre',
    'rate_app': 'Avaliar a app',
    'heat': 'Calor',
    'cat_all': 'Todos', 'cat_trail': 'Trail', 'cat_road': 'Estrada',
    'cat_orient': 'Orient.', 'cat_bike': 'Bike', 'cat_kids': 'Crianças',
    'cat_pro': 'Pro', 'cat_swim': 'Natação', 'cat_other': 'Outros', 'cat_fest': 'Festas',
    'cc_concert': 'Concerto', 'cc_theatre': 'Teatro', 'cc_exhibition': 'Exposição',
    'cc_cinema': 'Cinema', 'cc_dance': 'Dança', 'cc_folklore': 'Folclore',
    'cc_arraial': 'Arraial', 'cc_religious': 'Religioso', 'cc_festival': 'Festival',
    'cc_market': 'Mercado', 'cc_food': 'Gastronomia', 'cc_family': 'Família',
    'cc_workshop': 'Oficina', 'cc_talk': 'Conferências', 'cc_show': 'Espetáculo',
    'cc_sport': 'Desporto', 'cc_culture': 'Cultura',
    'more_in_fest': 'mais em Festas',
    'dist': 'distância', 'climb': 'subida', 'status': 'estado',
    'weather': 'Tempo aqui', 'weather_src': 'Previs\u00e3o para as coordenadas deste trilho \u00b7 Open-Meteo', 'today': 'Hoje',
    'nearby': 'Perto daqui', 'as_the_crow': 'de dist\u00e2ncia',
    'of_trail': 'do trilho', 'editions': 'edições', 'finishers_total': 'finalistas',
    'course_record': 'Recorde da prova', 'race_not_trail': 'Tempos da prova completa, não deste troço',
    'descent': 'Descida', 'marking': 'Marcação', 'route_type': 'Percurso',
    'roundtrip': 'Circular', 'one_way': 'Ponto a ponto',
    'on_foot': 'A pé', 'altitude': 'Altitude', 'steepest': 'Subida mais dura',
    'difficulty': 'Dificuldade', 'easy': 'Fácil', 'moderate': 'Moderado', 'hard': 'Difícil',
    'time_note': 'Estimativa — 12 min/km, mais subida e descida',
    'website': 'Site',
    'telegram': 'Bot do Telegram',
    'tg_channel': 'Canal do resumo semanal',
    'language': 'Deutsch',
    'roots_sub': 'A memória da ilha, um lugar de cada vez',
    'view_all': 'Ver tudo',
    'roots_h1': 'Como a Madeira aprendeu a mover-se',
    'timeline': 'A linha do tempo',
    'timeline_sub': 'Seiscentos anos em seis capítulos — vale a pena descer devagar.',
    'album': 'O Álbum',
    'album_sub': 'Dezoito imagens da Madeira antiga.',
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
    'open_site': 'Abrir site', 'open_calendar': 'Abrir calendário do organizador', 'open_calendar_hint': 'Sem página própria — calendário da época',
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
    'web_failed': 'Este mapa precisa de ligação. Verifique a rede e tente novamente.',
    'retry': 'Tentar novamente',
    'privacy': 'Política de privacidade',
    'countries': 'Países',
    'intl_trend': 'Corredores estrangeiros por ano',
    'time_dist': 'Tempo mediano',
    'stats': 'Estatísticas','finishers_year':'Finalistas por ano','top_clubs':'Melhores clubes','top_localities':'Localidades','toughest':'Provas mais duras (DNF %)','finish_hours':'Horas de chegada','loyalty':'Corredores fiéis (anos)','elev_profile':'Perfil altimétrico','status_changed':'Estado do trilho mudou','p_next':'Próximo','p_today':'Hoje','p_weekend':'Fim de semana','organized_by':'Organização:',
  },
  'de': trDe,
  'ru': trRu,
};

/// "Free" in the reader's language; any other price as the source wrote it.
String priceLabel(String p) => RegExp(r'^(free|grátis|gratuito|entrada livre)$', caseSensitive: false).hasMatch(p.trim())
    ? (locale.value == 'pt' ? 'Grátis' : locale.value == 'de' ? 'Gratis' : locale.value == 'ru' ? 'Бесплатно' : 'Free')
    : p;

String t(String k) => (_tr[locale.value] ?? _tr['en']!)[k] ?? _tr['en']![k] ?? k;

/// Event `type` arrives as a raw feed key — 'road_run', 'swimming_kids',
/// 'motorsport'. Those are pipeline identifiers, not labels, and they were
/// leaking straight into the UI. Sentence case, not Title Case: these sit inside
/// a subtitle line next to a place name.
/// The feed's event_type, in the reader's language.
///
/// It used to be a mechanical de-underscore of the raw value, so a Portuguese
/// row read "Madeira · Road run" directly beneath a filter chip that said
/// "Estrada" — the same category named twice, differently, one of them in the
/// wrong language. The words here match the chips deliberately.
const _typeNames = {
  'trail': {'en': 'Trail', 'pt': 'Trail'},
  'running': {'en': 'Running', 'pt': 'Corrida'},
  'road_run': {'en': 'Road run', 'pt': 'Estrada'},
  'orienteering': {'en': 'Orienteering', 'pt': 'Orientação'},
  'cycling': {'en': 'Cycling', 'pt': 'Ciclismo'},
  'cycling_pro': {'en': 'Cycling pro', 'pt': 'Ciclismo pro'},
  'cycling_kids': {'en': 'Cycling kids', 'pt': 'Ciclismo infantil'},
  'motorsport': {'en': 'Motorsport', 'pt': 'Automobilismo'},
  'swimming': {'en': 'Swimming', 'pt': 'Natação'},
  'swimrun': {'en': 'Swimrun', 'pt': 'Swimrun'},
  'triathlon': {'en': 'Triathlon', 'pt': 'Triatlo'},
  'triathlon_pro': {'en': 'Triathlon pro', 'pt': 'Triatlo pro'},
  'children': {'en': 'Children', 'pt': 'Crianças'},
  'festival': {'en': 'Festival', 'pt': 'Festa'},
};

/// The subtype, unless it merely restates the filter the row already sits
/// under.
///
/// The chip comes from `mode` and the label from `event_type`, and for a third
/// of the calendar the two say the same word twice: 33 festivals labelled
/// "Festival" under the Festas chip, 13 trails labelled "Trail" under Trail.
/// Where the label is genuinely more specific — cycling_pro under Pro, swimrun
/// under Swim — it stays.
const _redundantType = {
  'trail': 'trail',
  'festivals': 'festival',
  'cycling': 'cycling',
  'swim': 'swimming',
  'kids': 'children',
};

String typeFor(String mode, String type) =>
    _redundantType[mode] == type ? '' : humanType(type);

String humanType(String raw) {
  final known = _typeNames[raw];
  if (known != null) return known[locale.value] ?? known['en']!;
  // Unknown value from the feed: de-underscore it rather than print nothing,
  // so a new category shows up as itself instead of vanishing.
  final words = raw.split(RegExp(r'[_\-\s]+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '';
  final s = words.join(' ');
  return '${s[0].toUpperCase()}${s.substring(1)}';
}

/// Feed locations sometimes come glued — 'Camacha,Madeira'. Cheap to make them
/// readable here rather than chase every producer.
String tidyPlace(String s) => s.replaceAll(RegExp(r',(?=\S)'), ', ').trim();

/// Joins subtitle parts, dropping the empty ones. Without this an event with no
/// category rendered a dangling ' · '.
String dotJoin(Iterable<String> parts) =>
    parts.map((p) => p.trim()).where((p) => p.isNotEmpty).join(' · ');

// Day and month names, per language. An events calendar that prints "Sat,
// 15 Aug" inside an otherwise Portuguese screen is the most visible kind of
// half-translation there is — it is the first thing on every row.
const _wdName = {
  'en': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  'pt': ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
  'de': ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
  'ru': ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
};
const _moName = {
  'en': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  // Portuguese abbreviates months in lower case: 15 ago, 3 set.
  'pt': ['jan', 'fev', 'mar', 'abr', 'mai', 'jun',
         'jul', 'ago', 'set', 'out', 'nov', 'dez'],
  'de': ['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
         'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'],
  // Russian dates read "15 авг": the genitive short forms.
  'ru': ['янв', 'фев', 'мар', 'апр', 'мая', 'июн',
         'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'],
};

List<String> _wdFor() => _wdName[locale.value] ?? _wdName['en']!;
List<String> _moFor() => _moName[locale.value] ?? _moName['en']!;

/// '2026-07-11' -> 'Sat, 11 Jul' / 'Sáb, 11 jul'
String fmtDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${_wdFor()[d.weekday - 1]}, ${d.day} ${_moFor()[d.month - 1]}';
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
  // The theme survived a relaunch and the language did not, so anyone reading
  // the app in Portuguese had to switch it again on every single launch — on
  // an island where Portuguese is the first language, that is most of the
  // audience being asked to re-state the obvious daily.
  final lang = prefs.getString('locale');
  if (lang == 'pt' || lang == 'en' || lang == 'de' || lang == 'ru') locale.value = lang!;
  runApp(const AtivaApp());
}

void setThemeMode(ThemeMode m) {
  themeModeN.value = m;
  prefs.setString('themeMode', m.name);
}

/// Sets the interface language and remembers it.
void setLocale(String code) {
  locale.value = code;
  prefs.setString('locale', code);
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
        // The tabs are the '/' route rather than `home`: Flutter refuses `home`
        // next to onGenerateInitialRoutes, and a cold start from a link needs
        // both the tabs and the linked screen on the stack, or Back closes the
        // app instead of returning home.
        onGenerateRoute: (s) => (s.name == null || s.name == '/') ? homeRoute() : deepLinkRoute(s),
        onGenerateInitialRoutes: (name) {
          // A tab link on a cold start just selects the tab.
          final page = Uri.tryParse(name)?.pathSegments.firstOrNull;
          if (_tabLinks[page] case final i?) {
            homeTab.value = i;
            return [homeRoute()];
          }
          return [homeRoute(), if (deepLinkRoute(RouteSettings(name: name)) case final r?) r];
        },
        onUnknownRoute: (_) => homeRoute(),
      ),
    );
  }
}

/// The home tabs as a route. A route's page is built once and does not follow
/// MaterialApp's rebuilds, so it listens to the locale itself — and builds a
/// fresh, non-const HomeShell each time: Dart canonicalises const instances,
/// Flutter skips updating an element whose widget is identical, and a const
/// HomeShell once left every string unchanged after a language switch. State
/// is kept, so the selected tab and scroll position survive the switch.
Route<dynamic> homeRoute() => MaterialPageRoute(
    settings: const RouteSettings(name: '/'),
    builder: (_) => ListenableBuilder(listenable: locale, builder: (_, __) => HomeShell()));

/// The selected bottom tab, so a link can switch it (madeiraativa://open/events).
final homeTab = ValueNotifier<int>(0);
const _tabLinks = {'events': 2, 'map': 3, 'levadas': 4, 'news': 5};

/// A link to a tab: switch the tab and close this empty route, and anything
/// else above the tabs, at once. (The
/// Navigator has to push something for a named route; returning null would
/// push a second set of tabs through onUnknownRoute.)
Route<dynamic> _tabSwitch(int i) => PageRouteBuilder(
    opaque: false,
    transitionDuration: Duration.zero,
    pageBuilder: (ctx, _, __) {
      // After the frame: switching the tab rebuilds HomeShell, which may not
      // happen while this route is being built.
      // Everything above the tabs closes too, or the switch happens out of sight.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        homeTab.value = i;
        Navigator.of(ctx).popUntil((r) => r.isFirst);
      });
      return const SizedBox.shrink();
    });

Route<dynamic>? deepLinkRoute(RouteSettings s) {
  final page = Uri.tryParse(s.name ?? '')?.pathSegments.firstOrNull;
  if (_tabLinks[page] case final i?) return _tabSwitch(i);
  String? url;
  String title = 'Madeira Ativa';
  switch (page) {
    case 'bus':
      // from / to (a place or "lat,lon") ride along: Apple Maps' directions
      // requests and the trail pages' "by bus" button arrive this way.
      final q = Uri.tryParse(s.name ?? '')?.query ?? '';
      url = 'https://azenha.ai/ativa/bus?app=1&lang=${locale.value}${q.isEmpty ? '' : '&$q'}';
      title = t('bus_one');
    case 'ask':
      url = 'https://azenha.ai/ativa/ask?app=1&lang=${locale.value}';
      title = 'Ask AI';
    case 'webcams':
      url = 'https://azenha.ai/ativa/webcams?app=1&lang=${locale.value}';
      title = t('webcams_live');
  }
  if (url == null) return null;
  return MaterialPageRoute(settings: s, builder: (_) => WebPage(title: title, url: url!));
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = homeTab.value;

  void _goTo(int i) => homeTab.value = i;
  void _follow() {
    if (mounted && _tab != homeTab.value) setState(() => _tab = homeTab.value);
  }

  @override
  void initState() {
    super.initState();
    homeTab.addListener(_follow);
  }

  @override
  void dispose() {
    homeTab.removeListener(_follow);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // None of these may be const, and the reason is the same trap that made
    // MaterialApp.home inert: Dart canonicalises const instances, so a
    // `const EventsPage()` is the *identical* object on every rebuild, and
    // Flutter skips an element update when the new widget is identical to the
    // old one. HomePage was the only non-const entry here — it takes a
    // callback — which is exactly why the language switch appeared to work on
    // Home and nowhere else. State is still preserved: same type, same
    // position, so the tab keeps its scroll and its loaded data.
    final pages = [
      HomePage(onNavigate: _goTo),
      const AskTab(),
      EventsPage(),
      MapPage(),
      LevadasPage(),
      NewsPage(),
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
          // Used to print just the current locale ('EN'), which reads as a state
          // label: nothing announced that a Portuguese version existed, and the
          // tap did something the label never promised. Showing both with the
          // active one marked makes the control explain itself — and on an island
          // whose locals read Portuguese, that discoverability is the point. The
          // drawer row still says 'Português' (the target), which is the right
          // wording for a menu item.
          // Two targets, each of which SELECTS its language. It used to be one
          // TextButton over both labels whose onPressed inverted the locale, so
          // tapping "EN" while already on English sent you to Portuguese, and
          // the whole pair lit up as one control. Worse, this build() read
          // locale.value without listening to it, so the highlight never moved
          // after a tap and both labels looked equally active.
          ValueListenableBuilder<String>(
            valueListenable: locale,
            builder: (context, lang, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LangTab(label: 'EN', code: 'en', active: lang),
                Text('·', style: TextStyle(color: context.cHairline)),
                _LangTab(label: 'PT', code: 'pt', active: lang),
                Text('·', style: TextStyle(color: context.cHairline)),
                _LangTab(label: 'DE', code: 'de', active: lang),
              ],
            ),
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
              // /ativa is the canonical address; /ative redirects to it and
              // /madeira is a legacy page kept alive only for old links. The
              // data endpoints below still fetch from /madeira on purpose —
              // that is where the feeds are published, and a shipped app must
              // keep reading the path it was released with.
              onTap: () => openUrl('https://azenha.ai/ativa/'),
            ),
            ListTile(
              leading: const Icon(Icons.send, color: kGreen),
              title: Text(t('telegram')),
              onTap: () => openUrl('https://t.me/madeira_ebot'),
            ),
            // The bot answers a question the moment it is asked; the channel
            // carries one post a week without being asked. Different needs, so
            // the app offers both rather than choosing for the reader.
            ListTile(
              leading: const Icon(Icons.campaign, color: kGreen),
              title: Text(t('tg_channel')),
              onTap: () => openUrl('https://t.me/madeira_ativa'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined, color: kGreen),
              title: Text(t('roots')),
              onTap: () {
                Navigator.of(context).pop();
                openRoots(context);
              },
            ),
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
                      url: 'https://azenha.ai/ativa/mapfly?app=1'))),
            ),
            ListTile(
              leading: const Icon(Icons.terrain, color: kGreen),
              title: const Text('Aerial view'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const WebPage(
                      title: 'Aerial',
                      url: 'https://azenha.ai/ativa/mapbay?app=1'))),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: kGreen),
              title: Text(t('privacy')),
              onTap: () => openUrl('https://azenha.ai/ativa/privacy'),
            ),
            const Divider(),
            // The menu used to carry three GitHub links: this app's repository,
            // the website's, and an unrelated product's. A menu is not a
            // portfolio, and the account name in those URLs put a personal
            // handle in front of every user. The app is published by Azenha AI;
            // that, and an address that reaches it, is all anyone needs.
            // The practice that publishes the app, and it has its own page —
            // this row briefly pointed at the app's own website instead, which
            // made it a button promising one place and going to another.
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined, color: kGreen),
              title: const Text('azenha.ai'),
              subtitle: const Text('Where data finds its form'),
              onTap: () => openUrl('https://azenha.ai/'),
            ),
            // No quota on this one: a person pressed it. The system prompt
            // (see ask_review.dart) is the scarce one.
            ListTile(
              leading: const Icon(Icons.star_outline, color: kGreen),
              title: Text(t('rate_app')),
              onTap: () {
                Navigator.pop(context);
                AskReview.openStoreListing();
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline, color: kGreen),
              title: Text(t('contact')),
              subtitle: const Text('agent@azenha.ai'),
              onTap: () => openUrl(
                  'mailto:agent@azenha.ai?subject=Madeira%20Ativa'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.translate, color: kTerracotta),
              title: Text(t('language')),
              onTap: () {
                // EN → PT → DE → RU → EN; the row's label names the next one.
                // Russian is reached only here: the header keeps its three
                // buttons, and any of them brings you back from Russian.
                setLocale(locale.value == 'en' ? 'pt' : locale.value == 'pt' ? 'de' : locale.value == 'de' ? 'ru' : 'en');
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
      body: SafeArea(
        child: _tab == kTabMap || _tab == kTabAsk
            ? pages[_tab]
            : ReadableWidth(child: pages[_tab]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goTo,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined), label: t('home')),
          NavigationDestination(
              icon: const Icon(Icons.auto_awesome_outlined), label: t('ask')),
          NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              label: t('events')),
          NavigationDestination(
              icon: const Icon(Icons.map_outlined), label: t('map')),
          NavigationDestination(
              icon: const Icon(Icons.hiking), label: t('levadas')),
          NavigationDestination(
              icon: const Icon(Icons.article_outlined), label: t('news')),
        ],
      ),
    );
  }
}


/// A link to a season calendar or a federation PDF, not to the event. The
/// same test the export uses to rank sources.
final RegExp _genericLink = RegExp(
    r'\.pdf(\?|$)|/calendario|/calendar|/eventos/?$|fpacompeticoes\.pt/?$|visitmadeira\.com/[a-z]{2}(/[a-z-]+)?/?$',
    caseSensitive: false);
bool _isGenericLink(String url) => _genericLink.hasMatch(url);

class AtivaEvent {
  final String name;
  final String date;
  final String location;
  final String type;
  final String mode;
  final String url;
  // Present only where the source entered the event by hand — a start time,
  // a price ("Free", "€25"), who runs it. Posters and federation PDFs carry
  // none of these, so the fields stay empty rather than guessed.
  final String time;
  final String price;
  final String organizer;
  // The Fest shelf's own category ('concert', 'arraial', 'religious', …).
  // Set on every cultural row since the feed started classifying them;
  // empty on sport rows and on a cached feed from before.
  final String category;

  bool get isCulture => mode == 'festivals';

  AtivaEvent.fromJson(Map<String, dynamic> j)
      : name = j['name'] ?? '',
        date = j['date'] ?? '',
        location = j['location'] ?? '',
        type = j['event_type'] ?? 'other',
        mode = j['mode'] ?? '',
        url = j['url'] ?? '',
        time = j['time'] ?? '',
        price = j['price'] ?? '',
        organizer = j['organizer'] ?? '',
        category = j['category'] ?? '';
}

Future<List<AtivaEvent>> fetchEvents() async {
  final data = await cachedJson('https://azenha.ai/ativa/events.json');
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

  /// The outlet the item came from ('JM Madeira', …). The feed always carried it;
  /// the app just never showed it, so third-party headlines appeared unattributed.
  final String source;

  /// The feed's own topic for the item — trail, desporto, cultura, educação,
  /// ocorrências, geral. It has been arriving all along and the site filters by
  /// it; only the app ignored it, so 50 headlines came as one undifferentiated
  /// list where most of them are incidents rather than anything sporting.
  final String cat;
  final Map<String, String> titles;
  final Map<String, String> snippets;

  NewsItem.fromJson(Map<String, dynamic> j)
      : title = j['title'] ?? '',
        snippet = j['snippet'] ?? '',
        source = j['source'] ?? '',
        link = j['link'] ?? '',
        date = j['date'] ?? '',
        lang = (j['lang'] ?? 'en').toString().toLowerCase(),
        cat = (j['cat'] ?? '').toString().toLowerCase(),
        titles = Map<String, String>.from(
            (j['titles'] ?? {}).map((k, v) => MapEntry(k, v.toString()))),
        snippets = Map<String, String>.from(
            (j['snippets'] ?? {}).map((k, v) => MapEntry(k, v.toString())));

  String titleFor(String lg) =>
      lg == lang ? title : (titles[lg]?.isNotEmpty == true ? titles[lg]! : title);

  String snippetFor(String lg) => lg == lang
      ? snippet
      : (snippets[lg]?.isNotEmpty == true ? snippets[lg]! : snippet);

  /// Whether what the reader sees in [lg] is actually a translation. The
  /// badge used to say "RU · auto" whenever the article's language differed
  /// from the chip — including when the feed had fallen back to the original
  /// under that key, so the badge sat over Portuguese text for four days and
  /// nothing on screen admitted it.
  bool isTranslatedTo(String lg) =>
      lg != lang && titles[lg]?.isNotEmpty == true && titles[lg] != title;
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
  final data = await cachedJson('https://azenha.ai/ativa/tv_broadcasts.json');
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
  final data = await cachedJson('https://azenha.ai/ativa/watchlist.json');
  final list =
      (data is List ? data : data['watchlist'] ?? data['items'] ?? []) as List;
  return list.map((j) => WatchItem.fromJson(j)).toList();
}

const kNewsLangs = ['en', 'pt', 'de', 'pl', 'uk', 'ru'];
// Keys stay ISO 639-1 (the feed's own codes); labels are what a reader sees.
// 'uk' is genuinely Ukrainian in ISO, but next to EN it reads as the United
// Kingdom — so the chip says UA, the country flag code everyone recognises.
const kNewsLangLabels = {
  'en': 'EN',
  'pt': 'PT',
  'de': 'DE',
  'pl': 'PL',
  'uk': 'UA',
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

/// The Fest shelf's categories in display order, with the glyph each chip
/// shows and the icon its rows get. The order is the feed's, which puts the
/// evening-out kinds first and the catch-all last; it is fixed on purpose,
/// so a chip stays where a reader last found it.
const _cultureCats = <(String, String, IconData)>[
  ('concert', '🎵', Icons.music_note),
  ('theatre', '🎭', Icons.theater_comedy),
  ('exhibition', '🖼', Icons.palette),
  ('cinema', '🎬', Icons.movie),
  ('dance', '💃', Icons.nightlife),
  ('folklore', '🪗', Icons.groups),
  ('arraial', '🎉', Icons.celebration),
  ('religious', '⛪', Icons.church),
  ('festival', '🎪', Icons.festival),
  ('market', '🛍', Icons.storefront),
  ('food', '🍷', Icons.restaurant),
  ('family', '👶', Icons.family_restroom),
  ('workshop', '🛠', Icons.handyman),
  ('talk', '📚', Icons.menu_book),
  ('show', '🎤', Icons.mic),
  ('sport', '⚽', Icons.sports),
  ('culture', '🏛', Icons.museum),
];

IconData cultureIcon(String category) {
  for (final c in _cultureCats) {
    if (c.$1 == category) return c.$3;
  }
  return Icons.celebration;
}

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
      final s = await fetchTrailStatus();
      if (mounted) setState(() => _status = s);
    } catch (_) {}
    try {
      final data =
          await cachedJson('https://azenha.ai/ativa/news_feed.json');
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

  // Sport first, the way the site's home mixes it: a Saturday with six village
  // festas would otherwise push every race off the list.
  List<AtivaEvent> _mixed() {
    if (_events == null) return [];
    final sport = _events!.where((e) => e.mode != 'festivals').take(4).toList();
    final fest = _events!.where((e) => e.mode == 'festivals').take(6 - sport.length);
    return [...sport, ...fest]..sort((x, y) => x.date.compareTo(y.date));
  }

  @override
  Widget build(BuildContext context) {
    final mix = _mixed();
    final counts = (_status?['counts'] as Map?) ?? const {};


    return RefreshIndicator(
      color: kGreen,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bright launch banner for the bus timetables (new in 1.9.3).
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => WebPage(
                    title: t('bus_one'),
                    url: 'https://azenha.ai/ativa/bus?app=1&lang=${locale.value}'))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2A65A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: kTerracotta, borderRadius: BorderRadius.circular(20)),
                  child: Text(t('new_badge'),
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: Colors.white, letterSpacing: 0.6)),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.directions_bus, color: Color(0xFF3A1A08), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('bus_promo'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: Color(0xFF3A1A08))),
                      Text(t('bus_promo_sub'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF5A2A10))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF3A1A08)),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          // Coast and summit, the sea, ships in Funchal, the next good sunrise
          // and IPMA warnings — the same facts and rules as the site's strip.
          // Keyed by language so a switch rebuilds its wording.
          IslandNowCard(key: ValueKey('now-${locale.value}')),
          // Levadas by status, as on the site's home; a tap opens the list.
          if (counts.isNotEmpty)
            _HomeRow(
              icon: Icons.hiking,
              label: 'Levadas',
              value: '${counts['open'] ?? 0} ${t('lv_open')}',
              extra: ' · ${counts['partial'] ?? 0} ${t('lv_partly')} · ${counts['closed'] ?? 0} ${t('lv_closed')}',
              onTap: () => widget.onNavigate(kTabLevadas),
            ),
          _HomeRow(
            icon: Icons.videocam_outlined,
            label: 'Webcams',
            value: t('webcams_live'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => WebPage(
                    title: 'Webcams',
                    url: 'https://azenha.ai/ativa/webcams?app=1&lang=${locale.value}'))),
          ),
          const SizedBox(height: 12),
          _SectionHeader(
              title: t('coming_up'),
              onMore: () => widget.onNavigate(kTabEvents)),
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
                subtitle: dotJoin(
                    [fmtDate(e.date), tidyPlace(e.location), typeFor(e.mode, e.type)]),
                onTap: () => showEventActions(context, e),
              ),
          const SizedBox(height: 20),
          _SectionHeader(
              title: t('news'),
              onMore: () => widget.onNavigate(kTabNews)),
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
                  // n.title is the headline in the outlet's own language, so an
                  // English session read Portuguese here while the News tab —
                  // which asks for titleFor(lang) — read English. Same item, two
                  // languages, one screen apart.
                  title: Text(n.titleFor(locale.value),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  subtitle: Text(
                      n.source.isEmpty ? n.date : '${n.date} · ${n.source}',
                      style: const TextStyle(fontSize: 11)),
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
            onTap: () => widget.onNavigate(kTabLevadas),
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
            onTap: () => openRoots(context),
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
    // A short window (iPad compatibility mode, landscape phone, large text)
    // used to clip the bottom of this sheet — the last actions were simply
    // unreachable. Let it take the height it needs and scroll for the rest.
    isScrollControlled: true,
    constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: 760),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
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
                dotJoin([
                  fmtDate(e.date),
                  if (e.time.isNotEmpty) e.time,
                  if (e.price.isNotEmpty) priceLabel(e.price),
                  tidyPlace(e.location),
                  typeFor(e.mode, e.type),
                ]),
                style: TextStyle(fontSize: 13, color: ctx.cSubtle)),
          ),
          if (e.organizer.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text('${t('organized_by')} ${e.organizer}',
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
                  subtitle: Text('${l.code} · ${l.displayName}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () =>
                      openUrl(locale.value == 'pt' ? l.urlPt : l.urlEn),
                ),
              );
            },
          ),
          // "Open site" promised the event's page and, for the races that only
          // a federation calendar knows about, delivered a season table or a
          // PDF. Say which it is before the tap, not after.
          if (e.url.isNotEmpty)
            ListTile(
              leading: Icon(
                  _isGenericLink(e.url) ? Icons.table_chart_outlined : Icons.open_in_new,
                  color: kGreen),
              title: Text(t(_isGenericLink(e.url) ? 'open_calendar' : 'open_site')),
              subtitle: _isGenericLink(e.url)
                  ? Text(t('open_calendar_hint'),
                      style: TextStyle(fontSize: 12, color: ctx.cSubtle))
                  : null,
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
              // The feed is clean ISO today, but int.parse on a split string
              // turns any future '2026-08' or 'TBC' into a crash inside a tap
              // handler. Parse defensively and just skip the action instead.
              final day = DateTime.tryParse(e.date);
              if (day == null) return;
              // A concert at 21:00 went into a tester's phone as 09:00–11:00,
              // because nine o'clock was invented for every event whether or
              // not the source knew the real hour. Where the feed carries a
              // time, use it. Where it does not, an all-day entry is honest:
              // it says "this day", which is all we know.
              final hm = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(e.time);
              final start = hm == null
                  ? DateTime(day.year, day.month, day.day)
                  : DateTime(day.year, day.month, day.day,
                      int.parse(hm.group(1)!), int.parse(hm.group(2)!));
              Add2Calendar.addEvent2Cal(Event(
                title: e.name,
                location: e.location,
                startDate: start,
                endDate: hm == null
                    ? start.add(const Duration(days: 1))
                    : start.add(const Duration(hours: 2)),
                allDay: hm == null,
                description: e.url,
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
    ),
  );
}

/// Caps how wide content is allowed to grow and centres it.
///
/// The phone layout stretched edge to edge on a 13" iPad: paragraphs ran to
/// ~150 characters a line, and list rows put the title and its star a hand-span
/// apart. That is what App Review meant by "laid out in a way that made it
/// difficult to use". Full-bleed screens (the map) deliberately opt out.
class ReadableWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ReadableWidth({super.key, required this.child, this.maxWidth = 760});

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
}

class _HomeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String extra;
  final VoidCallback onTap;
  const _HomeRow({required this.icon, required this.label, required this.value, this.extra = '', required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.cHairline, width: 0.5),
        ),
        child: Row(children: [
          Icon(icon, color: context.cTitle, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label.toUpperCase(),
                  style: TextStyle(fontSize: 11, letterSpacing: 0.6, color: context.cSubtle)),
              Text.rich(TextSpan(children: [
                TextSpan(text: value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                if (extra.isNotEmpty)
                  TextSpan(text: extra, style: TextStyle(fontSize: 13, color: context.cSubtle)),
              ])),
            ]),
          ),
          Icon(Icons.chevron_right, color: context.cTitle),
        ]),
      ),
    );
  }
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


/// One race, one row — its distances listed underneath rather than as separate
/// entries. EcoTrail Madeira filled three rows for 30, 45 and 60 km, Ultra X
/// another three, and a day with two races read as a day with six.
///
/// The split is done on the name rather than a list of known series: a trailing
/// "30 km" or "10 km / 800D+" is the organiser writing one race's options, and
/// new series appear every season. Events whose name already carries the whole
/// set — "Camacha Trail (9/15/26 km)" — are left alone; they are one row
/// already.
final RegExp _distanceTail = RegExp(r'\s+(\d+(?:[.,]\d+)?\s*km\b.*)$', caseSensitive: false);

class EventGroup {
  final AtivaEvent lead;
  final List<String> distances;
  EventGroup(this.lead, this.distances);

  String get title => distances.isEmpty
      ? lead.name
      : lead.name.replaceFirst(_distanceTail, '');
}

List<EventGroup> groupByRace(List<AtivaEvent> events) {
  final order = <String>[];
  final buckets = <String, List<AtivaEvent>>{};
  for (final e in events) {
    final m = _distanceTail.firstMatch(e.name);
    final base = m == null ? e.name : e.name.substring(0, m.start);
    final key = '${e.date}|$base|${e.location}|${e.mode}';
    if (!buckets.containsKey(key)) order.add(key);
    buckets.putIfAbsent(key, () => []).add(e);
  }
  return [
    for (final key in order)
      () {
        final group = buckets[key]!;
        if (group.length < 2) return EventGroup(group.first, const []);
        final labels = group
            .map((e) => _distanceTail.firstMatch(e.name)?.group(1)?.trim())
            .whereType<String>()
            .toList();
        return EventGroup(group.first, labels);
      }(),
  ];
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
  // Three months, not one. A month showed 40 of 120 events and hid both of
  // the island's next big races — 42 and 92 days out, which is exactly the
  // horizon someone plans a trail trip on. A near-empty list reads as
  // 'nothing is happening', not as 'widen the filter'.
  String _period = '3mo';
  int _beyondWindow = 0;

  // Which of the Fest shelf's categories the reader asked for. Empty means
  // all of them. Kept across launches: this is a preference, not a filter
  // state, and asking again each time would be the onboarding quiz nobody
  // wanted.
  Set<String> _subCats = {};
  // Looking past the chosen categories for a moment — the "+N more" row
  // under a day, or the All chip in the Fest row — without unticking them.
  // Cleared by the next tap on a category or on the main chip row.
  bool _peek = false;
  Set<String> get _subCatsInEffect => _peek ? const {} : _subCats;
  // How often each category has been opened. Nobody ticks a preference box
  // for 'arraial', but someone who opened three of them wants the next one
  // on the first screen. Weighted into the All shelf's quota, below.
  Map<String, int> _opened = {};
  // Cultural rows the All shelf held back, per day, so each day can say so.
  final Map<String, int> _hiddenByDay = {};

  // Culture rows the All shelf shows per day when nothing is chosen: enough
  // to say the island has an evening life, few enough that the week's races
  // — the reason the app exists — are not buried under it.
  static const _cultureQuota = 2;

  static const _periods = <(String, String, int)>[
    // "Today" and "Weekend" answer the question a resident asks at six in
    // the evening; the month-scale windows answer the one a visitor asks
    // while planning. Both belong on the same strip.
    ('today', 'p_today', 0),
    ('weekend', 'p_weekend', 0),
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
  // Labels go through t(): they were hard-coded English, so a Portuguese
  // reader got "All / Road / Kids / Swim / Fest" in an otherwise translated
  // screen. Trail, Bike and Pro stay as they are — those are the words used
  // in Portuguese sport too, and the site's own filter row uses them.
  static const _modeCats = <(String, String, String)>[
    ('all', '', 'cat_all'),
    ('trail', '🏃', 'cat_trail'),
    ('road', '🛣', 'cat_road'),
    ('orienteering', '🧭', 'cat_orient'),
    ('cycling', '🚴', 'cat_bike'),
    ('kids', '👶', 'cat_kids'),
    ('pro', '🏆', 'cat_pro'),
    ('swim', '🏊', 'cat_swim'),
    ('other', '🎾', 'cat_other'),
    ('festivals', '🎪', 'cat_fest'),
  ];

  @override
  void initState() {
    super.initState();
    _subCats = (prefs.getStringList('event_subcats') ?? []).toSet();
    _opened = {
      for (final s in prefs.getStringList('event_opened') ?? [])
        if (s.contains('=')) s.split('=').first: int.tryParse(s.split('=').last) ?? 0,
    };
    _load();
  }

  void _toggleSubCat(String slug) {
    setState(() {
      _peek = false;
      _subCats.contains(slug) ? _subCats.remove(slug) : _subCats.add(slug);
    });
    prefs.setStringList('event_subcats', _subCats.toList());
  }

  void _noteOpened(AtivaEvent e) {
    if (!e.isCulture || e.category.isEmpty) return;
    _opened[e.category] = (_opened[e.category] ?? 0) + 1;
    prefs.setStringList('event_opened',
        [for (final k in _opened.keys) '$k=${_opened[k]}']);
  }

  /// How much this reader cares about a cultural row: chosen categories
  /// first, then the ones they keep opening or starring, then the island's
  /// big draws. Only the order within a day's quota; nothing is dropped
  /// for scoring low.
  int _interest(AtivaEvent e) {
    var score = 0;
    if (_subCats.contains(e.category)) score += 100;
    score += 10 * (_opened[e.category] ?? 0).clamp(0, 5);
    if (isFav(_favKey(e))) score += 50;
    if (e.category == 'festival' || e.category == 'arraial') score += 5;
    return score;
  }

  /// The All shelf: every sport row, and per day the cultural rows the
  /// reader asked for plus a couple more. The rest are counted, not shown
  /// — the day's row says how many wait under Fest.
  List<AtivaEvent> _withQuota(List<AtivaEvent> events) {
    _hiddenByDay.clear();
    final byDay = <String, List<AtivaEvent>>{};
    for (final e in events) {
      byDay.putIfAbsent(e.date, () => []).add(e);
    }
    final out = <AtivaEvent>[];
    for (final day in byDay.keys) {
      final rows = byDay[day]!;
      out.addAll(rows.where((e) => !e.isCulture));
      final culture = rows.where((e) => e.isCulture).toList()
        ..sort((a, b) => _interest(b).compareTo(_interest(a)));
      final chosen = culture.where((e) => _subCats.contains(e.category)).toList();
      final others = culture.where((e) => !_subCats.contains(e.category)).toList();
      final extra = _subCats.isEmpty ? _cultureQuota : 0;
      final kept = [...chosen, ...others.take(extra)];
      out.addAll(kept);
      final hidden = culture.length - kept.length;
      if (hidden > 0) _hiddenByDay[day] = hidden;
    }
    return out;
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
      'festivals' => _events!
          .where((e) => e.isCulture &&
              (_subCatsInEffect.isEmpty ||
                  _subCatsInEffect.contains(e.category)))
          .toList(),
      _ => _events!.where((e) => e.mode == _filter).toList(),
    };
    if (_day != null) {
      shown = shown.where((e) => e.date == _day).toList();
    } else if (_period == 'today') {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      _beyondWindow = shown.where((e) => e.date != today).length;
      shown = shown.where((e) => e.date == today).toList();
    } else if (_period == 'weekend') {
      // The coming Saturday and Sunday. On a Saturday or Sunday, this one.
      final now = DateTime.now();
      final toSat = (DateTime.saturday - now.weekday) % 7;
      final sat = now.weekday == DateTime.sunday
          ? now.subtract(const Duration(days: 1))
          : now.add(Duration(days: toSat));
      final a = sat.toIso8601String().substring(0, 10);
      final b = sat.add(const Duration(days: 1)).toIso8601String().substring(0, 10);
      _beyondWindow = shown.where((e) => e.date.compareTo(b) > 0).length;
      shown = shown.where((e) => e.date.compareTo(a) >= 0 && e.date.compareTo(b) <= 0).toList();
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
      // Count what the window is holding back, so the tally can admit to it.
      // "5 upcoming" reads as "there are five" — it took a user asking where
      // two well-known races had gone to notice the count never mentioned a
      // boundary. They were in the data, just past the edge of the filter.
      _beyondWindow = shown.where((e) => e.date.compareTo(end) > 0).length;
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
    // A search or the star filter asks for a specific thing; the quota
    // would hide exactly what was asked for.
    if (_filter == 'all' && _query.isEmpty && !_favOnly) {
      shown = _withQuota(shown);
    } else {
      _hiddenByDay.clear();
    }
    final hiddenTotal = _hiddenByDay.values.fold(0, (a, b) => a + b);
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
        // ClipRect is not decoration. When the strip collapses on scroll, the
        // list inside keeps its full height and paints over the day row
        // beneath it — "Next" across the 18, "Week" between SAT and SUN — and
        // on a 375-point screen, where the chips sit tighter, a tester
        // photographed it. Clip to the animated height and nothing leaks.
        ClipRect(
          child: AnimatedSize(
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
                          Text(_wdFor()[d.weekday - 1].toUpperCase(),
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
        // Nine categories in a horizontal strip showed five and clipped the
        // sixth mid-chip, which reads as the end of the list rather than as
        // "scroll me" — four filters were effectively invisible. Wrap shows
        // every one of them, using two rows on a phone and folding back to a
        // single row on a tablet, where the width is there anyway.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: LayoutBuilder(builder: (context, box) {
            // Nine categories with an emoji each need three rows on a 360dp
            // phone, and the row then eats a third of the screen before a
            // single event is visible. It gets worse with the system font
            // enlarged — which is exactly the reader who can least afford the
            // space. So measure what these labels actually need on this
            // screen, at this font size, and keep the emoji only while they
            // still fit in two rows.
            final scaler = MediaQuery.textScalerOf(context);
            const labelStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
            const spacing = 6.0;
            const chipChrome = 34.0;  // FilterChip's padding around its label
            const emojiCost = 30.0;   // the avatar slot plus its gap

            double labelWidth(String text) {
              final painter = TextPainter(
                text: TextSpan(text: text, style: labelStyle),
                textDirection: TextDirection.ltr,
                textScaler: scaler,
              )..layout();
              return painter.width;
            }

            int rowsNeeded({required bool withEmoji}) {
              var rows = 1;
              var used = 0.0;
              for (final cat in _modeCats) {
                final width = labelWidth(t(cat.$3)) +
                    chipChrome +
                    (withEmoji && cat.$2.isNotEmpty ? emojiCost : 0);
                if (used > 0 && used + spacing + width > box.maxWidth) {
                  rows++;
                  used = width;
                } else {
                  used += (used > 0 ? spacing : 0) + width;
                }
              }
              return rows;
            }

            final showEmoji = rowsNeeded(withEmoji: true) <= 2;

            return Wrap(
            spacing: spacing,
            runSpacing: 6,
            children: [
              for (final cat in _modeCats)
                Builder(
                  builder: (context) => FilterChip(
                    showCheckmark: false,
                    // The emoji belongs in the avatar slot, not inside the label
                    // string: a glyph from the emoji font inside the label made
                    // the label measure short and clip mid-word — 'Trail' came
                    // out as 'Tra'.
                    avatar: (!showEmoji || cat.$2.isEmpty)
                        ? null
                        : Text(cat.$2, style: const TextStyle(fontSize: 14)),
                    label: Text(t(cat.$3), maxLines: 1, softWrap: false),
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
                    onSelected: (_) => setState(() {
                      _filter = cat.$1;
                      _peek = false;
                    }),
                  ),
                ),
            ],
            );
          }),
        ),
        // Tapping Fest opens a second row: the shelf's own categories, as
        // many as the reader likes. A strip rather than a wrap — seventeen
        // chips wrapped would push the first event off the screen.
        if (_filter == 'festivals')
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              children: [
                // "All" is lit when nothing is chosen, or while peeking past
                // what is. Tapping it with categories chosen peeks rather
                // than unticks: a preference should survive one look around.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: FilterChip(
                    showCheckmark: false,
                    label: Text(t('cat_all'), maxLines: 1, softWrap: false),
                    selected: _subCatsInEffect.isEmpty,
                    selectedColor: kTerracotta,
                    backgroundColor: context.cSurface,
                    visualDensity: VisualDensity.compact,
                    shape: StadiumBorder(
                        side: BorderSide(
                            color: _subCatsInEffect.isEmpty
                                ? kTerracotta
                                : context.cHairline)),
                    labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _subCatsInEffect.isEmpty
                            ? Colors.white
                            : context.cTitle),
                    onSelected: (_) => setState(() {
                      if (_subCats.isEmpty) return;
                      _peek = !_peek;
                    }),
                  ),
                ),
                for (final c in _cultureCats)
                  if (_events!.any((e) => e.isCulture && e.category == c.$1))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: FilterChip(
                        showCheckmark: false,
                        avatar: Text(c.$2, style: const TextStyle(fontSize: 13)),
                        label: Text(t('cc_${c.$1}'), maxLines: 1, softWrap: false),
                        selected: _subCatsInEffect.contains(c.$1),
                        selectedColor: kTerracotta,
                        backgroundColor: context.cSurface,
                        visualDensity: VisualDensity.compact,
                        shape: StadiumBorder(
                            side: BorderSide(
                                color: _subCatsInEffect.contains(c.$1)
                                    ? kTerracotta
                                    : context.cHairline)),
                        labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _subCatsInEffect.contains(c.$1)
                                ? Colors.white
                                : context.cTitle),
                        onSelected: (_) => _toggleSubCat(c.$1),
                      ),
                    ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
              _day == null
                  // Counted in races, not start lines: if three distances make
                  // one row, the tally has to agree with what can be counted
                  // on screen.
                  ? '${groupByRace(shown).length} ${t('upcoming')}'
                      '${_beyondWindow > 0 ? ' · +$_beyondWindow ${t('later')}' : ''}'
                      '${hiddenTotal > 0 ? ' · +$hiddenTotal ${t('more_in_fest')}' : ''}'
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
              // Counted from the grouped list, not the raw one: folding three
              // distances into one row shortens it, and the watchlist header
              // would otherwise be indexed past the end and never drawn.
              final watchStart = groupByRace(shown).length;
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
              // One race, one row: 30/45/60 km of the same event belong under it,
              // not beside it.
              final groups = groupByRace(shown);
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount:
                    groups.length + (showWatch ? 1 + _watch.length : 0),
                itemBuilder: (_, i) {
                  if (i < groups.length) {
                    final g = groups[i];
                    final e = g.lead;
                    final showDate =
                        i == 0 || groups[i - 1].lead.date != e.date;
                    final lastOfDay = i == groups.length - 1 ||
                        groups[i + 1].lead.date != e.date;
                    final hidden = lastOfDay ? (_hiddenByDay[e.date] ?? 0) : 0;
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
                          icon: e.isCulture
                              ? cultureIcon(e.category)
                              : _typeIcons[e.type] ?? Icons.event,
                          title: g.title,
                          // "19:00 · Free · MAMMA · Concert": the time and the
                          // price lead, because they are what decides whether
                          // tonight is possible. Absent on most sport rows,
                          // which read exactly as before.
                          subtitle: dotJoin([
                            if (e.time.isNotEmpty) e.time,
                            if (e.price.isNotEmpty) priceLabel(e.price),
                            if (g.distances.isNotEmpty) g.distances.join(', '),
                            tidyPlace(e.location),
                            e.isCulture && e.category.isNotEmpty
                                ? t('cc_${e.category}')
                                : typeFor(e.mode, e.type),
                          ]),
                          onTap: () {
                            _noteOpened(e);
                            showEventActions(context, e);
                          },
                          favKey: _favKey(e),
                        ),
                        if (hidden > 0)
                          // What the quota held back that day, one tap from
                          // the Fest shelf on that date.
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => setState(() {
                                _filter = 'festivals';
                                _day = e.date;
                                _peek = true;
                              }),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: Row(children: [
                                  Icon(Icons.celebration,
                                      size: 14, color: kTerracotta),
                                  const SizedBox(width: 6),
                                  Text('+$hidden ${t('more_in_fest')}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: kTerracotta)),
                                  const SizedBox(width: 2),
                                  Icon(Icons.chevron_right,
                                      size: 14, color: kTerracotta),
                                ]),
                              ),
                            ),
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
  final String descent;
  final String marking;
  final bool roundtrip;
  String? official;
  // Madeira or Porto Santo: both islands number their trails from PR 1, so a
  // code alone does not name a trail.
  final String island;
  // Visit Madeira's figures, the ones on the trailhead board, when it has a
  // page for the route (32 of 44). Ours are only estimates.
  final String? officialDifficulty;
  final int? officialMinutes;
  // Each end of the route: height, nearest car park, bus lines passing it.
  final List<TrailEnd> ends;
  // Railings, narrow ledges, tunnels, demanding ground — OpenStreetMap by
  // length, with how much of the route is mapped (build_trail_exposure.py).
  final Map<String, dynamic>? exposure;
  // Live webcams near the trail (NetMadeira pages, linked, never embedded).
  final List<({String name, String url})> webcams;
  bool get byBus => ends.any((e) => e.lines.isNotEmpty || e.stop != null);

  bool get timeIsOfficial => officialMinutes != null;

  /// Rough time on foot: Naismith's 12 min per km plus 10 min for every 100 m
  /// of climb, and a gentler 10 min per 300 m of descent.
  ///
  /// The descent term matters here. Several PR routes only go down — PR 19 is
  /// 1.8 km with 464 m of drop and no climb at all — and plain Naismith calls
  /// that 22 minutes, which nobody walking it would recognise.
  String? get walkingTime {
    if (officialMinutes != null) {
      final h = officialMinutes! ~/ 60, m = officialMinutes! % 60;
      return h > 0 ? (m > 0 ? '${h}h ${m.toString().padLeft(2, '0')}m' : '${h}h') : '${m}m';
    }
    final km = double.tryParse(distance);
    if (km == null) return null;
    final climb = double.tryParse(ascent) ?? 0;
    final drop = double.tryParse(descent) ?? 0;
    final minutes = (km * 12 + climb / 100 * 10 + drop / 300 * 10).round();
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '${h}h ${m.toString().padLeft(2, '0')}m' : '${m}m';
  }

  /// Highest and lowest point walked, straight off the elevation profile.
  ({double min, double max})? get altitudeRange {
    if (profile.length < 2) return null;
    return (
      min: profile.reduce((a, b) => a < b ? a : b),
      max: profile.reduce((a, b) => a > b ? a : b),
    );
  }

  /// Biggest jump between two profile samples — a plain proxy for how brutal
  /// the steepest stretch is. PR 1 sits at 61 m, PR 1.1 at 747 m.
  double? get steepestStep {
    if (profile.length < 2) return null;
    var worst = 0.0;
    for (var i = 0; i < profile.length - 1; i++) {
      final step = (profile[i + 1] - profile[i]).abs();
      if (step > worst) worst = step;
    }
    return worst;
  }

  /// Easy / moderate / hard from distance and climb together, so nobody has to
  /// do the arithmetic in their head.
  String get difficultyKey {
    // The board at the trailhead wins. Ours is computed from the climb, and the
    // climb is only as right as the direction OSM draws the route in: PR 1.3
    // runs downhill from Pico Ruivo and we called it hard.
    switch ((officialDifficulty ?? '').toLowerCase()) {
      case 'easy':
        return 'easy';
      case 'moderate':
        return 'moderate';
      case 'difficult':
      case 'hard':
      case 'very difficult':
        return 'hard';
    }
    final km = double.tryParse(distance) ?? 0;
    final climb = double.tryParse(ascent) ?? 0;
    final score = km + climb / 100;
    if (score < 8) return 'easy';
    if (score < 16) return 'moderate';
    return 'hard';
  }

  /// PR 13.1 ships with an empty `name` in levadas.json, which rendered a row
  /// with a blank title. The route code is always present, so fall back to it —
  /// a nameless row is a bug the user should never have to see, whatever the feed
  /// does.
  String get displayName => name.trim().isEmpty ? code : name;

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
        descent = j['descent_m']?.toString() ?? '',
        marking = j['marking']?.toString() ?? '',
        roundtrip = j['roundtrip'] == true,
        island = (j['island'] ?? 'Madeira').toString(),
        officialDifficulty = (j['official'] is Map) ? j['official']['difficulty']?.toString() : null,
        officialMinutes = (j['official'] is Map) ? (j['official']['duration_min'] as num?)?.toInt() : null,
        exposure = j['exposure'] is Map ? Map<String, dynamic>.from(j['exposure']) : null,
        webcams = (j['access'] is Map && j['access']['webcams'] is List)
            ? (j['access']['webcams'] as List)
                .map((w) => (name: (w['name'] ?? '').toString(), url: (w['url'] ?? '').toString()))
                .toList()
            : const [],
        ends = (j['access'] is Map && j['access']['ends'] is List)
            ? (j['access']['ends'] as List)
                .map((e) => TrailEnd.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList()
            : const [],
        center = j['center'] == null
            ? null
            : LatLng((j['center'][0] as num).toDouble(),
                (j['center'][1] as num).toDouble());
}

/// One end of a trail, from levadas.json's `access` (scripts/build_trail_access.py).
/// A field that is absent means its source did not answer on the last build —
/// shown as nothing, never as "none".
class TrailEnd {
  final double lat, lon;
  final int elev;
  final bool parkingKnown, linesKnown;
  final ({int dist, String name, bool paid, double lat, double lon})? parking;
  final ({int dist, String stop, List<String> lines, Map<String, List<List<String>>> departures})? stop;
  final List<({String line, String timetable, String name})> lines;

  TrailEnd.fromJson(Map<String, dynamic> j)
      : lat = (j['lat'] as num).toDouble(),
        lon = (j['lon'] as num).toDouble(),
        elev = (j['elev'] as num?)?.round() ?? 0,
        parkingKnown = j.containsKey('parking'),
        linesKnown = j.containsKey('lines'),
        parking = j['parking'] is Map
            ? (
                dist: (j['parking']['dist'] as num).round(),
                name: (j['parking']['name'] ?? '').toString(),
                paid: j['parking']['fee'] == 'yes',
                lat: (j['parking']['lat'] as num).toDouble(),
                lon: (j['parking']['lon'] as num).toDouble(),
              )
            : null,
        stop = j['bus'] is Map
            ? (
                dist: (j['bus']['dist'] as num).round(),
                stop: (j['bus']['stop'] ?? '').toString().replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), ''),
                lines: ((j['bus']['lines'] as List?) ?? []).map((x) => x.toString()).toList(),
                departures: {
                  for (final e in ((j['bus']['departures'] as Map?) ?? {}).entries)
                    e.key.toString(): (e.value as List)
                        .map((x) => (x as List).map((y) => y.toString()).toList())
                        .toList()
                },
              )
            : null,
        lines = ((j['lines'] as List?) ?? [])
            .map((x) => (
                  line: (x['line'] ?? '').toString(),
                  timetable: (x['timetable'] ?? '').toString(),
                  name: (x['siga_name'] ?? '').toString(),
                ))
            .toList();
}

List<Levada>? _levadaCache;

/// Official trail-status feed: fresher than levadas.json and it knows the
/// 'partial' state plus an alerts list of what is closed right now.
Map<String, dynamic>? _statusCache;

Future<Map<String, dynamic>> fetchTrailStatus() async {
  if (_statusCache != null) return _statusCache!;
  final d = await cachedJson('https://azenha.ai/ativa/trails_status.json');
  _statusCache = Map<String, dynamic>.from(d as Map);
  return _statusCache!;
}

/// Races whose recorded course runs along each PR trail, with the results the
/// site already publishes for them. Built by scripts/build_trail_races.py.
Map<String, dynamic>? _trailRaceCache;

Future<Map<String, dynamic>> fetchTrailRaces() async {
  if (_trailRaceCache != null) return _trailRaceCache!;
  final d = await cachedJson('https://azenha.ai/ativa/trail_races.json');
  _trailRaceCache = Map<String, dynamic>.from((d as Map)['trails'] as Map);
  return _trailRaceCache!;
}

Future<List<Levada>> fetchLevadas() async {
  if (_levadaCache != null) return _levadaCache!;
  final data = await cachedJson('https://azenha.ai/ativa/levadas.json');
  _levadaCache = (data['levadas'] as List)
      .map((j) => Levada.fromJson(j))
      .toList();
  try {
    final st = await fetchTrailStatus();
    // Keyed by code AND island. Madeira and Porto Santo both have a PR 1, 2
    // and 3; by code alone Porto Santo's closed PR 3 closed Madeira's PR 3
    // (Vereda do Burro) too.
    final by = {
      for (final t in (st['trails'] as List? ?? []))
        '${t['code'] ?? ''}|${t['island'] ?? 'Madeira'}': (t['status'] ?? '').toString()
    };
    for (final l in _levadaCache!) {
      final s = by['${l.code}|${l.island}'];
      if (s != null && s.isNotEmpty) l.official = s;
    }
    final missing = _levadaCache!.where((l) => l.official == null).length;
    if (missing > 0) {
      debugPrint('trail status: $missing of ${_levadaCache!.length} trails have '
          'no official status and fall back to the bundled file');
    }
  } catch (e) {
    // Falling back to the bundled statuses is the right behaviour, but it must
    // not happen quietly: everything on screen is then as old as the last
    // levadas.json build.
    debugPrint('trail status feed unavailable, using bundled statuses: $e');
  }
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
  final data = await cachedJson('https://azenha.ai/ativa/trails_geo.json');
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
///
/// Reads `state`, not `status`. Every screen in the app shows `state` — the
/// official feed where there is one, the bundled file otherwise — while this
/// compared the bundled value alone. So a trail could close on the feed, show
/// as closed on the levada page, and raise nothing here, because the file it
/// was watching had not been rebuilt yet. Two surfaces of one app disagreeing
/// about whether a trail is walkable.
void _checkStatusChanges(List<Levada> ls) {
  try {
    final prev = prefs.getString('levada_status') ?? '';
    final now = ls.map((l) => '${l.code}:${l.state}').join(',');
    if (prev.isNotEmpty && prev != now) {
      final old = {for (final p in prev.split(',')) p.split(':')[0]: p.split(':').last};
      final diffs = [
        for (final l in ls)
          if (old[l.code] != null && old[l.code] != l.state)
            '${l.code} → ${l.state}'
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
  bool _busOnly = false;
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
    if (_busOnly) shown = shown.where((l) => l.byBus).toList();
    if (_favOnly) {
      shown = shown.where((l) => isFav(_favKey(l))).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      shown = shown
          .where((l) =>
              l.displayName.toLowerCase().contains(q) ||
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
              // Warnings first: a thunderstorm over the mountains changes which
              // of the trails below is worth the drive.
              FutureBuilder<List<IpmaWarning>>(
                future: fetchIpmaWarnings(),
                builder: (context, snap) => (snap.data ?? []).isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                        child: IpmaWarningList(warnings: snap.data!),
                      ),
              ),
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
                    // Trails with a bus at one end — 15 of Madeira's 40.
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: t('by_bus'),
                      icon: Icon(
                          _busOnly ? Icons.directions_bus : Icons.directions_bus_outlined,
                          color: _busOnly ? kTerracotta : context.cTitle),
                      onPressed: () => setState(() => _busOnly = !_busOnly),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: _stat(
                            '${_levadas!.length}', t('stat_routes'))),
                    Expanded(
                        child: _stat(km.round().toString(), t('stat_km'))),
                    Expanded(
                        child: _stat('${(climb / 1000).toStringAsFixed(0)}k',
                            t('stat_climb'))),
                    Expanded(child: _stat('1848', t('stat_peak'))),
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
            title: Text(l.displayName,
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
      isScrollControlled: true,
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 760),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l.code} · ${l.displayName}',
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
              Icon(
                  l.isOpen
                      ? Icons.check_circle
                      : (l.isPartial ? Icons.error_outline : Icons.cancel),
                  size: 16,
                  color: l.isOpen
                      ? kGreen
                      : (l.isPartial ? kTerracotta : Colors.red)),
              Text(' ${t(l.isOpen ? 'open' : (l.isPartial ? 'partial' : 'closed'))}'),
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
              // Seven of the 44 trails have no page on visitmadeira. A button
              // that opens nothing reads as broken, which is how a tester
              // reported it. No page, no button.
              if ((locale.value == 'pt' ? l.urlPt : l.urlEn).isNotEmpty)
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
              userAgentPackageName: 'ai.azenha.ativa',
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
                                  // Red, not grey. Grey read as "unknown" or
                                  // "inactive" to a tester, never as closed —
                                  // and the same trail is drawn red on the
                                  // web map and named red in its legend. One
                                  // state, one colour, on every surface.
                                  color: l.isOpen
                                      ? kGreen
                                      : (l.isPartial
                                          ? const Color(0xFFE8920E)
                                          : const Color(0xFFE23B2E)),
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
                            url: 'https://azenha.ai/ativa/map?app=1'))),
                icon: const Icon(Icons.local_fire_department),
                label: Text(t('heat')),
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
                            url: 'https://azenha.ai/ativa/map3d?app=1'))),
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

/// Roots — the island's history — as a screen of its own, with a way back.
void openRoots(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: Text(t('roots'))),
      body: const ReadableWidth(child: RootsPage()),
    ),
  ));
}

class WebPage extends StatefulWidget {
  final String title;
  final String url;
  // Inside a bottom-bar tab the app's own bar is already on screen; a second
  // one would stack under it.
  final bool bare;
  const WebPage(
      {super.key, required this.title, required this.url, this.bare = false});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  // Built once. "Try again" used to call _load(), which assigned this
  // late final a second time: LateInitializationError, and a spinner that never
  // stopped on every web screen whose first load had failed.
  late final WebViewController _c = _makeController();
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _loading = true;
      _failed = false;
    });
    _c.loadRequest(Uri.parse(widget.url));
  }

  WebViewController _makeController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Only onPageFinished was handled, so a navigation that died — no network,
      // captive wifi, a 5xx — left the spinner turning forever, because iOS
      // never reports a finish for a load that failed. These screens are the
      // ones a reviewer on flaky hotel wifi is most likely to open.
      ..setNavigationDelegate(NavigationDelegate(
        // Our own pages stay in the app; a link out (a SIGA timetable, a
        // webcam, an organiser's site) opens in the browser. Loaded inside
        // this screen, it replaced the page with no way back to it.
        onNavigationRequest: (req) {
          final host = Uri.tryParse(req.url)?.host ?? '';
          final ours = host == 'azenha.ai' || host.endsWith('.azenha.ai') || host.isEmpty;
          if (!req.isMainFrame || ours || !req.url.startsWith('http')) return NavigationDecision.navigate;
          openUrl(req.url);
          return NavigationDecision.prevent;
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
        onWebResourceError: (err) {
          if (!mounted || !err.isForMainFrame!) return;
          setState(() {
            _loading = false;
            _failed = true;
          });
        },
        onHttpError: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ));
  }

  @override
  Widget build(BuildContext context) {
    final body = _body(context);
    if (widget.bare) return body;
    return Scaffold(appBar: AppBar(title: Text(widget.title)), body: body);
  }

  Widget _body(BuildContext context) {
    return _failed
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 40, color: context.cSubtle),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(t('web_failed'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.cSubtle)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                      onPressed: _load, child: Text(t('retry'))),
                ],
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _c),
                if (_loading)
                  const Center(
                      child: CircularProgressIndicator(color: kGreen)),
              ],
            );
  }
}

// Ask AI — in development. The answering lives on the site (/ativa/ask), where
// it reads the same live data as everything else; the app shows that page in
// the reader's language, without the site's back link (?app=1). One engine, so
// the app and the site cannot answer the same question differently.
class AskTab extends StatelessWidget {
  const AskTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: locale,
      builder: (_, lang, _) => WebPage(
        key: ValueKey('ask-$lang'),
        title: t('ask'),
        url: 'https://azenha.ai/ativa/ask?app=1&lang=$lang',
        bare: true,
      ),
    );
  }
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

/// The feed's topics, in the order the site's news page lists them, with the
/// site's own English labels so the two read the same.
const kNewsCats = <(String, String)>[
  ('all', 'All'),
  ('trail', 'Trail'),
  ('desporto', 'Sport'),
  ('cultura', 'Culture'),
  ('educação', 'Education'),
  ('ocorrências', 'Incidents'),
  ('política', 'Politics'),
  ('saúde', 'Health'),
  ('tempo', 'Weather'),
  ('geral', 'General'),
];

class _NewsPageState extends State<NewsPage> {
  List<NewsItem>? _news;
  late String _lang;
  String _cat = 'all';

  @override
  void initState() {
    super.initState();
    _lang = kNewsLangs.contains(locale.value) ? locale.value : 'en';
    _load();
  }

  Future<void> _load() async {
    try {
      final data =
          await cachedJson('https://azenha.ai/ativa/news_feed.json');
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
    // Only offer a topic that this feed actually carries: an empty tab is a
    // dead end, and the mix shifts from day to day.
    final present = _news!.map((n) => n.cat).where((c) => c.isNotEmpty).toSet();
    final cats = kNewsCats
        .where((c) => c.$1 == 'all' || present.contains(c.$1))
        .toList();
    final shown = _cat == 'all'
        ? _news!
        : _news!.where((n) => n.cat == _cat).toList();

    return RefreshIndicator(
      color: kGreen,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shown.length + 1,
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
                const SizedBox(height: 8),
                // Roots moved off the bottom bar; today's news is where the
                // island's longer story sits best.
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => openRoots(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.cTerraTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.menu_book_outlined, color: kTerracotta, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(t('roots_link'),
                              style: TextStyle(fontWeight: FontWeight.w600, color: context.cBody))),
                      const Icon(Icons.chevron_right, color: kTerracotta),
                    ]),
                  ),
                ),
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
                if (cats.length > 1) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final (key, label) in cats)
                        GestureDetector(
                          onTap: () => setState(() => _cat = key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: _cat == key
                                  ? kGreen.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: _cat == key
                                      ? kGreen
                                      : Colors.grey.shade400,
                                  width: 0.5),
                            ),
                            child: Text(label,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _cat == key
                                        ? kGreen
                                        : context.cSubtle)),
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
              ],
            );
          }
          final n = shown[i - 1];
          final translated = n.isTranslatedTo(_lang);
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
                      if (n.source.isNotEmpty) ...[
                        const Text(' · ',
                            style:
                                TextStyle(fontSize: 11, color: Colors.grey)),
                        Flexible(
                          child: Text(n.source,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey)),
                        ),
                      ],
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

/// One cell of the Levadas stat band. Always used inside an [Expanded], so the
/// four cells split the width instead of asking for their natural size.
///
/// The label wraps to two lines rather than overflowing. English fits on one —
/// "km trails", "m climb" — but Portuguese does not: "km de trilhos" and
/// "m de subida" ran the row 65pt off the right edge of a 390pt phone, so the
/// band was broken in Portuguese for as long as the translation has existed.
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
          maxLines: 2,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 10, height: 1.2, color: Color(0xFF9FE1CB))),
    ],
  );
}

Widget histImage(String path, {double height = 190}) {
  return Image.network(
    'https://azenha.ai/ativa/$path',
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

/// One half of the EN · PT switch in the app bar.
///
/// Selects a language rather than toggling one, so the label and the outcome
/// agree: tapping EN gives you English whatever you were reading. The active
/// side is inert — there is nothing to do when you are already there — and the
/// tap target is padded out to 44pt, which the bare text was not.
class _LangTab extends StatelessWidget {
  final String label;
  final String code;
  final String active;

  const _LangTab(
      {required this.label, required this.code, required this.active});

  @override
  Widget build(BuildContext context) {
    final on = active == code;
    return InkWell(
      onTap: on ? null : () => setLocale(code),
      borderRadius: BorderRadius.circular(8),
      child: Semantics(
        selected: on,
        button: !on,
        label: code == 'en' ? 'English' : code == 'de' ? 'Deutsch' : 'Português',
        child: Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: on ? kGreen : context.cSubtle),
          ),
        ),
      ),
    );
  }
}

/// Three-day forecast for a trail's own coordinates.
///
/// Not the island's forecast: on Madeira the difference between the coast and
/// the ridge is the whole point. The same August day is 25 °C in Funchal and
/// 11 °C on Pico Ruivo, and a walker who packed for the first number is the
/// one who turns back. IPMA publishes only Funchal and Porto Santo for the
/// islands, which cannot express that, so the forecast is requested per
/// latitude/longitude and the elevation the model resolved is shown with it —
/// if that number looks wrong, so does everything under it.
///
/// Open-Meteo needs no key and receives nothing but a public trail's
/// coordinates.
Future<Map<String, dynamic>?> fetchTrailWeather(LatLng at) async {
  final url = 'https://api.open-meteo.com/v1/forecast'
      '?latitude=${at.latitude.toStringAsFixed(4)}'
      '&longitude=${at.longitude.toStringAsFixed(4)}'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_probability_max,wind_speed_10m_max'
      '&timezone=Atlantic%2FMadeira&forecast_days=3';
  try {
    final d = await cachedJson(url);
    if (d is Map && d['daily'] != null) return Map<String, dynamic>.from(d);
  } catch (e) {
    debugPrint('forecast unavailable for ${at.latitude},${at.longitude}: $e');
  }
  return null;
}

/// WMO weather codes, collapsed to the handful of cases a walker acts on.
///
/// Localised, because the first Portuguese screenshot of a trail page showed
/// "Fog" and "Overcast" sitting in the middle of an otherwise Portuguese
/// screen. Fog in particular is the word that matters here: on the Paul da
/// Serra it is the difference between a walk and a whiteout.
(String, String) weatherFace(int code) {
  final pt = locale.value == 'pt';
  if (code == 0) return ('☀️', pt ? 'Céu limpo' : 'Clear');
  if (code <= 2) return ('🌤️', pt ? 'Pouco nublado' : 'Mostly clear');
  if (code == 3) return ('☁️', pt ? 'Encoberto' : 'Overcast');
  if (code == 45 || code == 48) return ('🌫️', pt ? 'Nevoeiro' : 'Fog');
  if (code >= 51 && code <= 57) return ('🌦️', pt ? 'Chuvisco' : 'Drizzle');
  if (code >= 61 && code <= 67) return ('🌧️', pt ? 'Chuva' : 'Rain');
  if (code >= 71 && code <= 77) return ('🌨️', pt ? 'Neve' : 'Snow');
  if (code >= 80 && code <= 82) return ('🌧️', pt ? 'Aguaceiros' : 'Showers');
  if (code >= 95) return ('⛈️', pt ? 'Trovoada' : 'Thunderstorm');
  return ('🌥️', pt ? 'Nublado' : 'Cloudy');
}
