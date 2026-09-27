// "The island now": the coast and the summit, the sea, ships in Funchal, the
// next good sunrise at Pico do Arieiro, and IPMA's weather warnings.
//
// The same rules as the site (azenha.ai/ativa — ipma.js, sunrise.js and the
// home strip), so the app and the page never disagree about whether there is a
// storm:
//   - IPMA warnings: yellow and above only; green is every zone's normal state.
//     Times are Madeira wall clock (IPMA writes them without an offset) and a
//     warning stays up an hour past its end, so any error errs towards warning
//     too long. Nothing ever says "all clear" — a failed request and a calm day
//     would look the same.
//   - Weather at the summit asks for its real height (1818 m), not a grid cell.
//   - Sunrise: a morning is called best only if it is actually good.
import 'package:flutter/material.dart';

import 'main.dart';
import 'store.dart';

// ------------------------------------------------------------------ time

/// Madeira keeps Lisbon's clock: UTC in winter, UTC+1 from the last Sunday of
/// March to the last Sunday of October (both at 01:00 UTC). Returned as a UTC
/// DateTime holding Madeira's wall-clock reading, so it compares directly with
/// IPMA's offset-less times parsed the same way.
DateTime madeiraNow() {
  final u = DateTime.now().toUtc();
  DateTime lastSunday(int month) {
    var d = DateTime.utc(u.year, month + 1, 1).subtract(const Duration(days: 1));
    while (d.weekday != DateTime.sunday) {
      d = d.subtract(const Duration(days: 1));
    }
    return DateTime.utc(d.year, d.month, d.day, 1);
  }

  final summer = !u.isBefore(lastSunday(3)) && u.isBefore(lastSunday(10));
  return u.add(Duration(hours: summer ? 1 : 0));
}

DateTime _wall(String s) => DateTime.parse('${s.substring(0, 19)}Z');

// ------------------------------------------------------------------ IPMA

const ipmaZones = {
  'MRM': ('Mountains', 'Regiões montanhosas'),
  'MCN': ('North coast', 'Costa Norte'),
  'MCS': ('South coast', 'Costa Sul'),
  'MPS': ('Porto Santo', 'Porto Santo'),
};
const _zoneOrder = ['MRM', 'MCN', 'MCS', 'MPS'];

const _ipmaTypes = {
  'Trovoada': ('Thunderstorm', 'Trovoada', '⛈'),
  'Precipitação': ('Heavy rain', 'Precipitação', '🌧'),
  'Vento': ('Wind', 'Vento', '💨'),
  'Agitação Marítima': ('Rough sea', 'Agitação marítima', '🌊'),
  'Nevoeiro': ('Fog', 'Nevoeiro', '🌫'),
  'Tempo Quente': ('Heat', 'Tempo quente', '🌡'),
  'Tempo Frio': ('Cold', 'Tempo frio', '🥶'),
  'Neve': ('Snow', 'Neve', '❄️'),
};

const _levels = {
  'red': (0, 'Red', 'Vermelho', Color(0xFFD63A2E)),
  'orange': (1, 'Orange', 'Laranja', Color(0xFFE8741C)),
  'yellow': (2, 'Yellow', 'Amarelo', Color(0xFFD9A400)),
};

class IpmaWarning {
  final String zone, type, level;
  final DateTime start, end;
  IpmaWarning(this.zone, this.type, this.level, this.start, this.end);

  bool get _pt => locale.value == 'pt';
  String get zoneName => _pt ? ipmaZones[zone]!.$2 : ipmaZones[zone]!.$1;
  String get typeName {
    final x = _ipmaTypes[type];
    return x == null ? type : (_pt ? x.$2 : x.$1);
  }

  String get icon => _ipmaTypes[type]?.$3 ?? '⚠️';
  String get levelName => _pt ? _levels[level]!.$3 : _levels[level]!.$2;
  Color get colour => _levels[level]!.$4;
  int get rank => _levels[level]!.$1;
}

/// Live Madeira warnings, yellow and above, in force now or due before
/// [until] (default: the next 24 hours). Empty if IPMA cannot be reached.
Future<List<IpmaWarning>> fetchIpmaWarnings({DateTime? until}) async {
  try {
    final d = await cachedJson(
        'https://api.ipma.pt/open-data/forecast/warnings/warnings_www.json');
    final now = madeiraNow();
    final horizon = until ?? now.add(const Duration(hours: 24));
    final out = <IpmaWarning>[];
    for (final w in (d as List)) {
      final zone = (w['idAreaAviso'] ?? '').toString();
      final level = (w['awarenessLevelID'] ?? '').toString();
      if (!ipmaZones.containsKey(zone) || !_levels.containsKey(level)) continue;
      final start = _wall(w['startTime']), end = _wall(w['endTime']);
      if (end.add(const Duration(hours: 1)).isBefore(now)) continue;
      if (!start.isBefore(horizon)) continue;
      out.add(IpmaWarning(zone, (w['awarenessTypeName'] ?? '').toString(),
          level, start, end));
    }
    return out;
  } catch (e) {
    debugPrint('IPMA warnings unavailable: $e');
    return [];
  }
}

/// Which IPMA zone a trail walks in: Porto Santo by island; on Madeira a trail
/// that climbs above 800 m is in the mountains whatever coast it starts from;
/// below that the central ridge (about 32.755° N) decides.
String trailZone(Levada l) {
  if (l.island == 'Porto Santo') return 'MPS';
  final top = l.profile.isEmpty ? 0.0 : l.profile.reduce((a, b) => a > b ? a : b);
  if (top >= 800) return 'MRM';
  final lat = l.center?.latitude ?? 32.7;
  return lat >= 32.755 ? 'MCN' : 'MCS';
}

String _hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _when(IpmaWarning w) {
  final pt = locale.value == 'pt';
  final now = madeiraNow();
  const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const ptd = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
  String day(DateTime d) => (d.year == now.year && d.month == now.month && d.day == now.day)
      ? ''
      : '${(pt ? ptd : en)[d.weekday - 1]} ';
  if (w.start.isAfter(now)) return '${pt ? 'a partir de' : 'from'} ${day(w.start)}${_hhmm(w.start)}';
  return '${pt ? 'até' : 'until'} ${day(w.end)}${_hhmm(w.end)}';
}

/// One line per level + type + time window; zones listed together.
class IpmaWarningList extends StatelessWidget {
  final List<IpmaWarning> warnings;
  final String? onlyZone;
  const IpmaWarningList({super.key, required this.warnings, this.onlyZone});

  @override
  Widget build(BuildContext context) {
    final list = warnings.where((w) => onlyZone == null || w.zone == onlyZone);
    final groups = <String, (IpmaWarning, List<String>)>{};
    for (final w in list) {
      final k = '${w.level}|${w.type}|${w.start}|${w.end}';
      groups.putIfAbsent(k, () => (w, <String>[])).$2.add(w.zone);
    }
    final rows = groups.values.toList()
      ..sort((a, b) => a.$1.rank.compareTo(b.$1.rank));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (w, zones) in rows)
          GestureDetector(
            onTap: () => openUrl(
                'https://www.ipma.pt/${locale.value == 'pt' ? 'pt' : 'en'}/otempo/prev-sam/?p=${zones.first}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: context.cSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(color: w.colour, width: 4)),
              ),
              child: Row(children: [
                Expanded(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(
                        text: '${w.levelName.toUpperCase()}  ',
                        style: TextStyle(
                            color: w.colour,
                            fontWeight: FontWeight.w700,
                            fontSize: 11)),
                    TextSpan(
                        text: '${w.icon} ${w.typeName} — ${(zones..sort((a, b) => _zoneOrder.indexOf(a).compareTo(_zoneOrder.indexOf(b)))).map((z) => locale.value == 'pt' ? ipmaZones[z]!.$2 : ipmaZones[z]!.$1).join(', ')}',
                        style: TextStyle(
                            color: context.cBody, fontWeight: FontWeight.w600, fontSize: 13)),
                  ])),
                ),
                const SizedBox(width: 8),
                Text(_when(w), style: TextStyle(fontSize: 12, color: context.cSubtle)),
              ]),
            ),
          ),
      ],
    );
  }
}

// --------------------------------------------------------------- the now

class IslandNow {
  double? coastT, coastWind, summitT, seaT, waves;
  int? coastCode, summitCode;
  List<Map<String, dynamic>> shipsToday = [];
  Map<String, dynamic>? nextShip;
  String? sunriseLine;
  List<IpmaWarning> warnings = [];
}

String weatherEmoji(int c) => c >= 95
    ? '⛈'
    : c >= 61
        ? '🌧'
        : c >= 51
            ? '🌦'
            : c >= 45
                ? '🌫'
                : c == 3
                    ? '☁️'
                    : c >= 1
                        ? '🌤'
                        : '☀️';

Future<IslandNow> fetchIslandNow() async {
  final n = IslandNow();
  final jobs = <Future<void>>[
    () async {
      try {
        final d = await cachedJson('https://api.open-meteo.com/v1/forecast'
            '?latitude=32.648,32.735&longitude=-16.908,-16.929&elevation=50,1818'
            '&current=temperature_2m,weather_code,wind_speed_10m');
        final pts = d as List;
        n.coastT = (pts[0]['current']['temperature_2m'] as num?)?.toDouble();
        n.coastWind = (pts[0]['current']['wind_speed_10m'] as num?)?.toDouble();
        n.coastCode = (pts[0]['current']['weather_code'] as num?)?.toInt();
        n.summitT = (pts[1]['current']['temperature_2m'] as num?)?.toDouble();
        n.summitCode = (pts[1]['current']['weather_code'] as num?)?.toInt();
      } catch (_) {}
    }(),
    () async {
      try {
        final d = await cachedJson('https://marine-api.open-meteo.com/v1/marine'
            '?latitude=32.63&longitude=-16.92&current=wave_height,sea_surface_temperature');
        n.seaT = (d['current']['sea_surface_temperature'] as num?)?.toDouble();
        n.waves = (d['current']['wave_height'] as num?)?.toDouble();
      } catch (_) {}
    }(),
    () async {
      try {
        final d = await cachedJson('https://azenha.ai/ativa/cruise_calls.json');
        final today = madeiraNow().toIso8601String().substring(0, 10);
        final week = madeiraNow().add(const Duration(days: 7)).toIso8601String().substring(0, 10);
        final calls = (d['calls'] as List)
            .map((c) => Map<String, dynamic>.from(c as Map))
            .where((c) => c['superseded'] != true && (c['arrival'] ?? '') != '' && (c['departure'] ?? '') != '')
            .toList();
        n.shipsToday = calls
            .where((c) =>
                (c['arrival'] as String).substring(0, 10).compareTo(today) <= 0 &&
                (c['departure'] as String).substring(0, 10).compareTo(today) >= 0)
            .toList();
        final next = calls.where((c) {
          final a = (c['arrival'] as String).substring(0, 10);
          return a.compareTo(today) > 0 && a.compareTo(week) <= 0;
        });
        n.nextShip = next.isEmpty ? null : next.first;
      } catch (_) {}
    }(),
    () async {
      n.sunriseLine = await _sunrise();
    }(),
    () async {
      n.warnings = await fetchIpmaWarnings();
    }(),
  ];
  await Future.wait(jobs);
  return n;
}

/// The next five sunrises at Pico do Arieiro, classified from the forecast at
/// the summit (1818 m) and on the north slope (900 m), where a cloud sea lies.
Future<String?> _sunrise() async {
  try {
    final d = await cachedJson('https://api.open-meteo.com/v1/forecast'
        '?latitude=32.735,32.745&longitude=-16.929,-16.890&elevation=1818,900'
        '&hourly=cloud_cover_low,cloud_cover_mid,cloud_cover_high,precipitation_probability,visibility'
        '&daily=sunrise&forecast_days=7&timezone=Atlantic%2FMadeira');
    final s = d[0], l = d[1];
    final times = (s['hourly']['time'] as List).cast<String>();
    final now = madeiraNow().toIso8601String().substring(0, 16);
    final pt = locale.value == 'pt';
    String? bestLabel;
    var bestScore = -1.0;
    var counted = 0;
    for (final sr in (s['daily']['sunrise'] as List).cast<String>()) {
      if (sr.compareTo(now) <= 0) continue;
      if (++counted > 5) break;
      final i = times.indexOf('${sr.substring(0, 13)}:00');
      if (i < 0) continue;
      num v(Map m, String k) => (m['hourly'][k][i] ?? 0) as num;
      if (v(s, 'precipitation_probability') >= 40) continue;
      if (v(s, 'visibility') < 5000 || v(s, 'cloud_cover_low') >= 50) continue;
      final cover = [v(s, 'cloud_cover_mid'), v(s, 'cloud_cover_high') * 0.7]
          .reduce((a, b) => a > b ? a : b);
      if (cover >= 60) continue;
      final sea = v(l, 'cloud_cover_low') >= 50;
      final score = 100 - cover + (sea ? 15 : 0);
      if (score > bestScore) {
        bestScore = score.toDouble();
        final date = DateTime.parse('${sr.substring(0, 10)}T00:00:00Z');
        const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        const ptd = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
        final kind = sea ? (pt ? 'mar de nuvens' : 'sea of clouds') : (pt ? 'limpo' : 'clear');
        bestLabel = '${(pt ? ptd : en)[date.weekday - 1]} ${date.day}, ${sr.substring(11, 16)} — $kind';
      }
    }
    if (counted == 0) return null;
    return bestLabel == null
        ? (pt ? 'Sem nascer do sol limpo previsto nos próximos dias.' : 'No clear sunrise forecast in the next days.')
        : '${pt ? 'Melhor manhã' : 'Best morning'}: $bestLabel';
  } catch (_) {
    return null;
  }
}

/// Home card: everything above in one glance. Each line appears only if its
/// source answered.
class IslandNowCard extends StatefulWidget {
  const IslandNowCard({super.key});
  @override
  State<IslandNowCard> createState() => _IslandNowCardState();
}

class _IslandNowCardState extends State<IslandNowCard> {
  IslandNow? _n;

  @override
  void initState() {
    super.initState();
    fetchIslandNow().then((n) {
      if (mounted) setState(() => _n = n);
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = _n;
    if (n == null) return const SizedBox.shrink();
    final pt = locale.value == 'pt';
    final lines = <Widget>[];
    Widget line(String icon, String text, {VoidCallback? onTap}) => InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 26, child: Text(icon, style: const TextStyle(fontSize: 15))),
              Expanded(
                  child: Text(text,
                      style: TextStyle(fontSize: 14, color: context.cBody))),
            ]),
          ),
        );
    if (n.coastT != null) {
      lines.add(line(weatherEmoji(n.coastCode ?? 0),
          'Funchal ${n.coastT!.round()}°  ·  ${n.coastWind?.round() ?? '–'} km/h'
          '${n.summitT != null ? '     ⛰ Pico do Arieiro ${n.summitT!.round()}°' : ''}'));
    }
    if (n.seaT != null) {
      lines.add(line('🌊',
          '${pt ? 'Mar' : 'Sea'} ${n.seaT!.toStringAsFixed(1)}°'
          '${n.waves != null ? '  ·  ${pt ? 'ondas' : 'waves'} ${n.waves!.toStringAsFixed(1)} m' : ''}'));
    }
    if (n.shipsToday.isNotEmpty || n.nextShip != null) {
      final parts = <String>[];
      if (n.shipsToday.isNotEmpty) {
        parts.add('${pt ? 'No Funchal hoje' : 'In Funchal today'}: ${n.shipsToday.map((c) => c['ship']).join(', ')}');
      }
      if (n.nextShip != null) {
        final a = DateTime.parse('${(n.nextShip!['arrival'] as String).substring(0, 10)}T00:00:00Z');
        const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        const ptd = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
        parts.add('${pt ? 'seguinte' : 'next'}: ${n.nextShip!['ship']} · ${(pt ? ptd : en)[a.weekday - 1]} ${a.day}');
      }
      lines.add(line('🛳', parts.join(' · '),
          onTap: () => openUrl('https://apram.pt/movimento-navios?port=ptfnc')));
    }
    if (n.sunriseLine != null) {
      lines.add(line('🌅', '${pt ? 'Nascer do sol no Pico do Arieiro' : 'Sunrise at Pico do Arieiro'} — ${n.sunriseLine}'));
    }
    if (lines.isEmpty && n.warnings.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.cHairline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pt ? 'A ilha agora' : 'The island now',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.cTitle)),
          const SizedBox(height: 6),
          ...lines,
          if (n.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(pt ? 'AVISOS IPMA' : 'IPMA WARNINGS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: .6, color: context.cSubtle)),
            const SizedBox(height: 4),
            IpmaWarningList(warnings: n.warnings),
          ],
        ],
      ),
    );
  }
}
