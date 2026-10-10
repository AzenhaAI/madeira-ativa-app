import 'dart:math' as math;
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
  // The airport: wind, gusts and the crosswind on runway 05/23 in the gusts.
  double? airWind, airGusts, airCross;
  List<Map<String, dynamic>> shipsToday = [];
  List<Map<String, dynamic>> shipsTomorrow = [];
  String? tide;
  double? uv;
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
            '?latitude=32.648,32.735,32.698&longitude=-16.908,-16.929,-16.774&elevation=50,1818,58'
            '&current=temperature_2m,weather_code,wind_speed_10m,wind_gusts_10m,wind_direction_10m');
        final pts = d as List;
        n.coastT = (pts[0]['current']['temperature_2m'] as num?)?.toDouble();
        n.coastWind = (pts[0]['current']['wind_speed_10m'] as num?)?.toDouble();
        n.coastCode = (pts[0]['current']['weather_code'] as num?)?.toInt();
        n.summitT = (pts[1]['current']['temperature_2m'] as num?)?.toDouble();
        n.summitCode = (pts[1]['current']['weather_code'] as num?)?.toInt();
        if (pts.length > 2) {
          final c = pts[2]['current'];
          n.airWind = (c['wind_speed_10m'] as num?)?.toDouble();
          n.airGusts = (c['wind_gusts_10m'] as num?)?.toDouble();
          final dir = (c['wind_direction_10m'] as num?)?.toDouble();
          if (n.airGusts != null && dir != null) {
            // Runway 05/23 runs about 50°/230°; the usual airline limit at
            // Funchal is 15 knots (28 km/h) across it, measured in the gusts.
            n.airCross = n.airGusts! * math.sin((dir - 50) * math.pi / 180).abs();
          }
        }
      } catch (_) {}
    }(),
    () async {
      try {
        final d = await cachedJson('https://marine-api.open-meteo.com/v1/marine'
            '?latitude=32.63&longitude=-16.92&current=wave_height,sea_surface_temperature'
            '&hourly=sea_level_height_msl&forecast_days=2&timezone=Atlantic%2FMadeira');
        n.seaT = (d['current']['sea_surface_temperature'] as num?)?.toDouble();
        n.waves = (d['current']['wave_height'] as num?)?.toDouble();
        // Next high and low water: turning points of the hourly sea level.
        final times = (d['hourly']['time'] as List).cast<String>();
        final lv = (d['hourly']['sea_level_height_msl'] as List).map((x) => (x as num?)?.toDouble()).toList();
        final hour = madeiraNow().toIso8601String().substring(0, 13);
        String? hi, lo;
        for (var i = 1; i < lv.length - 1; i++) {
          final a = lv[i - 1], b = lv[i], c = lv[i + 1];
          if (times[i].substring(0, 13).compareTo(hour) < 0 || a == null || b == null || c == null) continue;
          if (hi == null && b >= a && b >= c) hi = times[i].substring(11, 16);
          if (lo == null && b <= a && b <= c) lo = times[i].substring(11, 16);
          if (hi != null && lo != null) break;
        }
        final pt = locale.value == 'pt';
        final parts = [
          if (hi != null) '${pt ? 'preia-mar' : 'high'} $hi',
          if (lo != null) '${pt ? 'baixa-mar' : 'low'} $lo',
        ];
        if (parts.isNotEmpty) n.tide = parts.join(', ');
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
        // One line per ship: APRAM lists a stay that spans midnight as two
        // movements, which read as "SANTA MARIA MANUELA, SANTA MARIA MANUELA".
        final seen = <String>{};
        n.shipsToday = calls
            .where((c) =>
                (c['arrival'] as String).substring(0, 10).compareTo(today) <= 0 &&
                (c['departure'] as String).substring(0, 10).compareTo(today) >= 0)
            .where((c) => seen.add((c['ship'] as String).toUpperCase()))
            .toList();
        final tmr = madeiraNow().add(const Duration(days: 1)).toIso8601String().substring(0, 10);
        n.shipsTomorrow = calls
            .where((c) =>
                (c['arrival'] as String).substring(0, 10).compareTo(tmr) <= 0 &&
                (c['departure'] as String).substring(0, 10).compareTo(tmr) >= 0)
            .where((c) => seen.add((c['ship'] as String).toUpperCase()))
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
      try {
        final d = await cachedJson('https://api.ipma.pt/open-data/forecast/meteorology/uv/uv.json');
        final day = madeiraNow().toIso8601String().substring(0, 10);
        for (final x in (d as List)) {
          if (x['globalIdLocal'] == 2310300 && x['data'] == day) {
            n.uv = double.tryParse(x['iUv'].toString());
            break;
          }
        }
      } catch (_) {}
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
          '${n.waves != null ? '  ·  ${pt ? 'ondas' : 'waves'} ${n.waves!.toStringAsFixed(1)} m' : ''}'
          '${n.tide != null ? '  ·  ${pt ? 'maré' : 'tide'}: ${n.tide}' : ''}'));
    }
    if (n.uv != null) {
      final v = n.uv!;
      final band = v >= 11 ? (pt ? 'extremo' : 'extreme') : v >= 8 ? (pt ? 'muito alto' : 'very high')
          : v >= 6 ? (pt ? 'alto' : 'high') : v >= 3 ? (pt ? 'moderado' : 'moderate') : (pt ? 'baixo' : 'low');
      lines.add(line('☀️', 'UV ${v.round()} ($band) — Funchal'));
    }
    if (n.airCross != null) {
      final cross = n.airCross!.round();
      final verdict = cross >= 28
          ? (pt ? 'acima do limite habitual de 15 nós — desvios prováveis' : 'above the usual 15-knot limit — diversions likely')
          : cross >= 20
              ? (pt ? 'rajadas — atrasos possíveis' : 'gusty — delays possible')
              : (pt ? 'calmo para aterrar' : 'calm for landings');
      lines.add(line('✈',
          '${pt ? 'Aeroporto: vento' : 'Airport: wind'} ${n.airWind?.round()} km/h, ${pt ? 'rajadas' : 'gusts'} ${n.airGusts?.round()}, '
          '${pt ? 'cruzado' : 'crosswind'} $cross km/h — $verdict',
          onTap: () => openUrl('https://www.flightradar24.com/airport/fnc')));
    }
    if (n.shipsToday.isNotEmpty || n.shipsTomorrow.isNotEmpty) {
      // APRAM's berth says what a ship is: cruise ships at Terminal Sul, the
      // Porto Santo ferry and freight at Norte, cement carriers at Cimenteiro —
      // "CEMENT TRADER" alone read like a cruise ship.
      String kind(Map c) {
        final b = (c['berth'] ?? '') as String;
        if (b.contains('Sul')) return pt ? 'cruzeiro' : 'cruise';
        if (b.contains('Cimenteiro')) return pt ? 'cimenteiro' : 'cement carrier';
        if (b.contains('Norte')) return pt ? 'ferry / carga' : 'ferry / cargo';
        return pt ? 'ao largo' : 'at anchor';
      }
      String one(Map c) {
        final a = c['arrival'] as String, d = c['departure'] as String;
        final same = a.substring(0, 10) == d.substring(0, 10);
        return '${c['ship']} (${kind(c)}${same ? ', ${a.substring(11, 16)}–${d.substring(11, 16)}' : ''})';
      }
      final parts = <String>[];
      if (n.shipsToday.isNotEmpty) parts.add('${pt ? 'Hoje' : 'Today'}: ${n.shipsToday.map(one).join(', ')}');
      if (n.shipsTomorrow.isNotEmpty) parts.add('${pt ? 'Amanhã' : 'Tomorrow'}: ${n.shipsTomorrow.map(one).join(', ')}');
      lines.add(line('🛳', parts.join('\n'),
          onTap: () => openUrl('https://apram.pt/movimento-navios?port=ptfnc')));
    } else if (n.nextShip != null) {
      final a = DateTime.parse('${(n.nextShip!['arrival'] as String).substring(0, 10)}T00:00:00Z');
      const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const ptd = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
      lines.add(line('🛳', '${pt ? 'Próximo navio' : 'Next ship'}: ${n.nextShip!['ship']} · ${(pt ? ptd : en)[a.weekday - 1]} ${a.day}',
          onTap: () => openUrl('https://apram.pt/movimento-navios?port=ptfnc')));
    }
    if (n.sunriseLine != null) {
      // Tapping it opens the summit webcam: the forecast says what should
      // happen, the camera shows what is.
      lines.add(line('🌅', '${pt ? 'Nascer do sol no Pico do Arieiro' : 'Sunrise at Pico do Arieiro'} — ${n.sunriseLine}  📷',
          onTap: () => openUrl('https://www.netmadeira.com/webcams-madeira/pico-do-arieiro')));
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


// ------------------------------------------------------------ buses, path

/// Next departures from an urban stop: today's remaining, then tomorrow's.
List<({bool today, String time, String line, String to})> nextBuses(
    Map<String, List<List<String>>> deps, int n) {
  final now = madeiraNow();
  final date = now.toIso8601String().substring(0, 10);
  final hm = now.toIso8601String().substring(11, 16);
  final out = <({bool today, String time, String line, String to})>[];
  for (final d in (deps.keys.toList()..sort())) {
    if (d.compareTo(date) < 0) continue;
    for (final x in deps[d]!) {
      if (out.length >= n) return out;
      if (d == date && x[0].compareTo(hm) < 0) continue;
      out.add((today: d == date, time: x[0], line: x[1], to: x.length > 2 ? x[2] : ''));
    }
    if (out.length >= n) break;
  }
  return out;
}

/// Railing, narrow ledge, tunnels, demanding ground — same words as the site.
List<String> pathFacts(Map<String, dynamic>? x) {
  if (x == null || ((x['length_km'] as num?) ?? 0) == 0) return [];
  final pt = locale.value == 'pt';
  int v(String k) => (x[k] as num?)?.round() ?? 0;
  final out = <String>[];
  if (v('railing_pct') > 0 || v('no_railing_pct') > 0) {
    final unknown = (100 - v('railing_pct') - v('no_railing_pct')).clamp(0, 100);
    out.add(pt
        ? 'Corrimão registado em ${v('railing_pct')}% do percurso, sem corrimão em ${v('no_railing_pct')}%, desconhecido em $unknown%'
        : 'Railing recorded on ${v('railing_pct')}% of the route, none on ${v('no_railing_pct')}%, unknown on $unknown%');
  } else {
    out.add(pt ? 'Sem registo de corrimão em nenhum troço' : 'No railing recorded on any section');
  }
  if (v('narrow_pct') > 0) {
    out.add(pt ? '${v('narrow_pct')}% do trilho com 0,5 m de largura ou menos' : '${v('narrow_pct')}% of the path 0.5 m wide or less');
  }
  if (v('tunnels') > 0) {
    final n = v('tunnels');
    out.add(pt ? '$n ${n > 1 ? 'túneis' : 'túnel'} (${v('tunnel_m')} m) — leve lanterna'
        : '$n ${n > 1 ? 'tunnels' : 'tunnel'} (${v('tunnel_m')} m) — bring a torch');
  }
  if (v('demanding_pct') > 0) {
    out.add(pt ? '${v('demanding_pct')}% em terreno de montanha exigente' : '${v('demanding_pct')}% demanding mountain terrain');
  }
  return out;
}
