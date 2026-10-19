// The face of the Home tab: a photo band that greets by the time of day,
// the island's silhouette with the weather where it is, and a strip that
// says what today is good for. Everything is drawn from the facts the
// "island now" card already loads; nothing new is fetched for it, and the
// photos ship with the app, so it works offline and in a tunnel.
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'island_now.dart';
import 'main.dart';

// ----------------------------------------------------------------- words

String _w(String en, String pt) {
  final l = locale.value;
  if (l == 'pt') return pt;
  if (l == 'de') return _de[en] ?? en;
  if (l == 'ru') return _ru[en] ?? en;
  return en;
}

const _de = <String, String>{
  'Good morning': 'Guten Morgen', 'Good afternoon': 'Guten Tag', 'Good evening': 'Guten Abend', 'Good night': 'Gute Nacht',
  'in Funchal': 'in Funchal', 'levadas open': 'Levadas offen', 'sunrise': 'Sonnenaufgang', 'sunset': 'Sonnenuntergang',
  'Hiking': 'Wandern', 'Beach': 'Strand', 'Viewpoints': 'Aussicht', 'Flights': 'Flüge',
  'Today is good for': 'Heute gut für', 'Tap an icon for why': 'Tippe ein Symbol für den Grund',
  'fog': 'Nebel', 'cloud': 'Wolken', 'rain': 'Regen', 'showers': 'Schauer', 'clear': 'klar', 'sunny': 'sonnig',
  'sea': 'Meer', 'waves': 'Wellen', 'gusts': 'Böen', 'delays': 'Verspätungen', 'diversions likely': 'Umleitungen wahrscheinlich',
  'calm': 'ruhig', 'dry': 'trocken', 'wet on the trails': 'nass auf den Wegen', 'cold on the summit': 'kalt auf dem Gipfel',
  'ridge in cloud': 'Grat in Wolken', 'ridge clear': 'Grat frei', 'IPMA warning': 'IPMA-Warnung',
  'sea too rough': 'Meer zu rau', 'sea warm': 'Meer warm', 'sea cool': 'Meer kühl', 'strong wind': 'starker Wind',
  'UV very high': 'UV sehr hoch', 'crosswind over the limit': 'Seitenwind über dem Limit', 'gusty': 'böig',
  'calm for landings': 'ruhig zum Landen', 'try the coast': 'versuche die Küste', 'above the cloud': 'über den Wolken',
};

const _ru = <String, String>{
  'Good morning': 'Доброе утро', 'Good afternoon': 'Добрый день', 'Good evening': 'Добрый вечер', 'Good night': 'Доброй ночи',
  'in Funchal': 'в Фуншале', 'levadas open': 'левад открыто', 'sunrise': 'восход', 'sunset': 'закат',
  'Hiking': 'Походы', 'Beach': 'Пляж', 'Viewpoints': 'Смотровые', 'Flights': 'Рейсы',
  'Today is good for': 'Сегодня хорошо для', 'Tap an icon for why': 'Нажмите на значок, чтобы узнать почему',
  'fog': 'туман', 'cloud': 'облачно', 'rain': 'дождь', 'showers': 'ливни', 'clear': 'ясно', 'sunny': 'солнечно',
  'sea': 'море', 'waves': 'волна', 'gusts': 'порывы', 'delays': 'задержки', 'diversions likely': 'вероятны уходы на запасной',
  'calm': 'тихо', 'dry': 'сухо', 'wet on the trails': 'мокро на тропах', 'cold on the summit': 'холодно на вершине',
  'ridge in cloud': 'хребет в облаках', 'ridge clear': 'хребет чистый', 'IPMA warning': 'предупреждение IPMA',
  'sea too rough': 'море слишком бурное', 'sea warm': 'море тёплое', 'sea cool': 'море прохладное', 'strong wind': 'сильный ветер',
  'UV very high': 'УФ очень высокий', 'crosswind over the limit': 'боковой ветер выше лимита', 'gusty': 'порывисто',
  'calm for landings': 'спокойно для посадки', 'try the coast': 'лучше побережье', 'above the cloud': 'над облаками',
};

// ------------------------------------------------------------ the period

enum DayPart { morning, afternoon, evening, night }

/// Where the day is, from the sunrise and sunset of the coast. Without
/// them (the forecast did not answer) the clock alone decides.
DayPart dayPart(IslandNow? n) {
  final now = madeiraNow();
  final h = now.hour + now.minute / 60;
  double? at(String? iso) {
    if (iso == null || iso.length < 16) return null;
    return int.parse(iso.substring(11, 13)) + int.parse(iso.substring(14, 16)) / 60;
  }
  final sr = at(n?.sunrise) ?? 7.5, ss = at(n?.sunset) ?? 18.5;
  if (h < sr - 0.5 || h >= ss + 1.2) return DayPart.night;
  if (h < 12) return DayPart.morning;
  if (h < ss - 1.0) return DayPart.afternoon;
  return DayPart.evening;
}

// -------------------------------------------------------------- the photo

/// The band's photo: by the time of day first, then by what the island is
/// doing — cloud on the ridge gets the cloud-sea pictures. Within a pool
/// the day of the year rotates the choice, so a week of mornings is not
/// one morning seven times.
String heroAsset(IslandNow? n) {
  final part = dayPart(n);
  final code = n?.summitCode ?? 0;
  final cloudy = code == 3 || (code >= 45 && code <= 48);
  final pool = switch (part) {
    DayPart.morning => cloudy
        ? ['cloud_ridge', 'morning_rays', 'cloud_sea']
        : ['morning_umbrella', 'morning_rays', 'day_rocks'],
    DayPart.afternoon => cloudy
        ? ['cloud_sea', 'cloud_ridge', 'day_valley', 'day_terraces']
        : ['day_terraces', 'day_tallship', 'day_plane', 'day_valley', 'day_rocks', 'cloud_sea'],
    DayPart.evening => ['evening_banana', 'evening_redsun'],
    DayPart.night => ['night_sea', 'evening_redsun'],
  };
  final now = madeiraNow();
  final doy = now.difference(DateTime.utc(now.year)).inDays;
  return 'assets/hero/${pool[doy % pool.length]}.jpg';
}

String greeting(IslandNow? n) => switch (dayPart(n)) {
      DayPart.morning => _w('Good morning', 'Bom dia'),
      DayPart.afternoon => _w('Good afternoon', 'Boa tarde'),
      DayPart.evening => _w('Good evening', 'Boa tarde'),
      DayPart.night => _w('Good night', 'Boa noite'),
    };

/// The photo band with the greeting and one line of facts.
class HeroBand extends StatelessWidget {
  const HeroBand({super.key, required this.now, required this.levadasOpen});
  final IslandNow? now;
  final int? levadasOpen;

  @override
  Widget build(BuildContext context) {
    final n = now;
    final d = madeiraNow();
    final parts = <String>[
      '${wdShort(d.weekday)} ${d.day} ${monShort(d.month)}',
      if (n?.coastT != null) '${n!.coastT!.round()}° ${_w('in Funchal', 'no Funchal')}',
      if (dayPart(n) == DayPart.morning && n?.sunrise != null) '${_w('sunrise', 'nascer do sol')} ${n!.sunrise!.substring(11, 16)}',
      if (dayPart(n) == DayPart.evening && n?.sunset != null) '${_w('sunset', 'pôr do sol')} ${n!.sunset!.substring(11, 16)}',
      if (levadasOpen != null) '$levadasOpen ${_w('levadas open', 'levadas abertas')}',
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 118,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(heroAsset(n), fit: BoxFit.cover, alignment: Alignment.center),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withValues(alpha: .62), Colors.black.withValues(alpha: 0)],
                stops: const [0, .62],
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(greeting(n),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                Text(parts.join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: .92), fontSize: 12)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

String wdShort(int wd) => switch (locale.value) {
      'pt' => const ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'][wd - 1],
      'de' => const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][wd - 1],
      'ru' => const ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'][wd - 1],
      _ => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][wd - 1],
    };

String monShort(int m) => switch (locale.value) {
      'pt' => const ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'][m - 1],
      'de' => const ['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'][m - 1],
      'ru' => const ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'][m - 1],
      _ => const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1],
    };

// ------------------------------------------------------------ the island

class _Island {
  _Island(this.w, this.h, this.path, this.pts);
  final double w, h;
  final Path path;
  final Map<String, Offset> pts;
}

_Island? _island;
Future<_Island>? _islandLoad;

/// The coastline (OpenStreetMap, simplified to ~150 points) and a few
/// named places, projected once in the build script; kept as an asset.
Future<_Island> loadIsland() => _islandLoad ??= () async {
      final j = jsonDecode(await rootBundle.loadString('assets/island.json')) as Map;
      final p = Path();
      // "M582.8 412.9 L583.1 410.2 … Z": the letter sits on the number.
      final tokens = (j['path'] as String).replaceAllMapped(RegExp(r'[MLZ]'), (m) => ' ${m[0]} ').trim().split(RegExp(r'\s+'));
      var i = 0;
      while (i < tokens.length) {
        final t = tokens[i];
        if ((t == 'M' || t == 'L') && i + 2 < tokens.length) {
          final x = double.parse(tokens[i + 1]), y = double.parse(tokens[i + 2]);
          t == 'M' ? p.moveTo(x, y) : p.lineTo(x, y);
          i += 3;
        } else if (t == 'Z') {
          p.close();
          i++;
        } else {
          i++;
        }
      }
      final pts = <String, Offset>{};
      (j['pts'] as Map).forEach((k, v) => pts[k as String] = Offset((v[0] as num).toDouble(), (v[1] as num).toDouble()));
      return _island = _Island((j['w'] as num).toDouble(), (j['h'] as num).toDouble(), p, pts);
    }();

/// A word for a weather code, short enough for a label.
String _sky(int? code) {
  if (code == null) return '';
  if (code >= 95) return _w('rain', 'chuva');
  if (code >= 61) return _w('rain', 'chuva');
  if (code >= 51) return _w('showers', 'aguaceiros');
  if (code >= 45) return _w('fog', 'nevoeiro');
  if (code == 3) return _w('cloud', 'nublado');
  if (code >= 1) return _w('clear', 'limpo');
  return _w('sunny', 'sol');
}

class IslandSilhouette extends StatefulWidget {
  const IslandSilhouette({super.key, required this.now});
  final IslandNow now;
  @override
  State<IslandSilhouette> createState() => _IslandSilhouetteState();
}

class _IslandSilhouetteState extends State<IslandSilhouette> {
  _Island? _isl = _island;

  @override
  void initState() {
    super.initState();
    if (_isl == null) loadIsland().then((i) => mounted ? setState(() => _isl = i) : null);
  }

  @override
  Widget build(BuildContext context) {
    final isl = _isl;
    if (isl == null) return const SizedBox(height: 200);
    return LayoutBuilder(builder: (context, box) {
      // viewBox: the island plus room for labels around it.
      const padX = 120.0, padT = 64.0, padB = 96.0;
      final vw = isl.w + 2 * padX, vh = isl.h + padT + padB;
      final h = box.maxWidth * vh / vw;
      return SizedBox(
        width: box.maxWidth,
        height: h,
        child: CustomPaint(
          painter: _IslandPainter(isl, widget.now, context, padX, padT, vw, vh),
        ),
      );
    });
  }
}

class _IslandPainter extends CustomPainter {
  _IslandPainter(this.isl, this.n, this.context, this.padX, this.padT, this.vw, this.vh);
  final _Island isl;
  final IslandNow n;
  final BuildContext context;
  final double padX, padT, vw, vh;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / vw;
    final dark = context.dark;
    canvas.save();
    canvas.scale(s, s);
    canvas.translate(padX, padT);
    final land1 = dark ? const Color(0xFF2E7A5E) : const Color(0xFF9CCBB4);
    final land2 = dark ? const Color(0xFF1E4A3B) : const Color(0xFFCFE6DB);
    final sea = dark ? const Color(0xFF6FA8D6) : const Color(0xFF2F6F9E);
    final cloudCol = dark ? const Color(0xFF5A6065) : const Color(0xFFB9BEC2);
    final ink = context.cBody;
    final muted = context.cSubtle;

    // sea halo
    canvas.drawPath(
        isl.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 40
          ..strokeJoin = StrokeJoin.round
          ..color = sea.withValues(alpha: .22));
    // land
    canvas.drawPath(
        isl.path,
        Paint()
          ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [land1, land2])
              .createShader(Rect.fromLTWH(0, 0, isl.w, isl.h)));
    canvas.drawPath(
        isl.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeJoin = StrokeJoin.round
          ..color = kGreen);
    // cloud over the north and the ridge when the summit says so
    final code = n.summitCode ?? 0;
    final cloudy = code == 3 || (code >= 45 && code <= 48) || code >= 51;
    if (cloudy) {
      canvas.save();
      canvas.clipPath(isl.path);
      final c1 = Path()
        ..moveTo(-100, -50)
        ..lineTo(1100, -50)
        ..lineTo(1100, 150)
        ..quadraticBezierTo(900, 215, 700, 190)
        ..quadraticBezierTo(500, 165, 300, 230)
        ..quadraticBezierTo(150, 270, -100, 240)
        ..close();
      final c2 = Path()
        ..moveTo(-100, -50)
        ..lineTo(1100, -50)
        ..lineTo(1100, 60)
        ..quadraticBezierTo(800, 120, 500, 90)
        ..quadraticBezierTo(250, 60, -100, 120)
        ..close();
      canvas.drawPath(c1, Paint()..color = cloudCol.withValues(alpha: .55));
      canvas.drawPath(c2, Paint()..color = cloudCol.withValues(alpha: .5));
      canvas.restore();
    }
    // the ridge, Arieiro to Ruivo
    final a = isl.pts['arieiro']!, pr = isl.pts['picoruivo']!;
    _dashed(canvas, a, pr, Paint()
      ..color = ink.withValues(alpha: .35)
      ..strokeWidth = 5);

    void dot(Offset o, Color col, [double r = 24]) {
      canvas.drawCircle(o, r + 14, Paint()..color = col.withValues(alpha: .18));
      canvas.drawCircle(o, r, Paint()..color = col);
      canvas.drawCircle(
          o,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7
            ..color = context.cSurface);
    }

    void label(Offset o, String big, String sub, {TextAlign align = TextAlign.left, Color? bigCol}) {
      final tp = TextPainter(
          text: TextSpan(text: big, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: bigCol ?? ink)),
          textDirection: TextDirection.ltr,
          textAlign: align)
        ..layout();
      final sp = TextPainter(
          text: TextSpan(text: sub, style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: muted)),
          textDirection: TextDirection.ltr,
          textAlign: align)
        ..layout();
      double x(TextPainter p) => align == TextAlign.right ? o.dx - p.width : align == TextAlign.center ? o.dx - p.width / 2 : o.dx;
      tp.paint(canvas, Offset(x(tp), o.dy - tp.height + 8));
      sp.paint(canvas, Offset(x(sp), o.dy + 8));
    }

    final f = isl.pts['funchal']!, ap = isl.pts['airport']!, pm = isl.pts['portomoniz']!;
    final kmh = locale.value == 'ru' ? 'км/ч' : 'km/h';
    if (n.coastT != null) {
      dot(f, kGreen);
      label(Offset(f.dx, f.dy + 80), '${n.coastT!.round()}°',
          'Funchal${n.coastWind != null ? ' · ${n.coastWind!.round()} $kmh' : ''}',
          align: TextAlign.center);
    }
    if (n.summitT != null) {
      dot(a, ink, 20);
      label(Offset(a.dx + 36, a.dy - 4), '${n.summitT!.round()}°', 'Pico do Arieiro · ${_sky(n.summitCode)}');
    }
    if (n.airGusts != null) {
      final cross = n.airCross ?? 0;
      final verdict = cross >= 28 ? _w('diversions likely', 'desvios prováveis') : cross >= 20 ? _w('gusty', 'rajadas') + ' · ' + _w('delays', 'atrasos') : _w('calm for landings', 'calmo para aterrar');
      dot(ap, kTerracotta);
      label(Offset(ap.dx + 44, ap.dy + 10), '✈ ${n.airWind?.round() ?? '–'} / ${n.airGusts!.round()}', verdict);
    }
    if (n.northT != null) {
      dot(pm, sea, 20);
      label(Offset(pm.dx + 36, pm.dy + 46), '${n.northT!.round()}°', 'Porto Moniz · ${_sky(n.northCode)}');
    }
    if (n.seaT != null) {
      final waves = n.waves != null ? ' · ${_w('waves', 'ondas')} ${n.waves!.toStringAsFixed(1)} ${locale.value == 'ru' ? 'м' : 'm'}' : '';
      label(Offset(f.dx - 330, f.dy + 56), '🌊 ${n.seaT!.toStringAsFixed(1)}°', '${_w('sea', 'mar')}$waves', align: TextAlign.center, bigCol: sea);
    }
    if (n.uv != null) {
      final v = n.uv!;
      final band = v >= 11 ? 'extreme' : v >= 8 ? 'very high' : v >= 6 ? 'high' : v >= 3 ? 'moderate' : 'low';
      final bandPt = v >= 11 ? 'extremo' : v >= 8 ? 'muito alto' : v >= 6 ? 'alto' : v >= 3 ? 'moderado' : 'baixo';
      label(Offset(isl.w + 110, -24), '☀ UV ${v.round()}', '${_w(band, bandPt)} · Funchal', align: TextAlign.right);
    }
    canvas.restore();
  }

  void _dashed(Canvas c, Offset a, Offset b, Paint p) {
    final d = b - a;
    final len = d.distance;
    final u = d / len;
    var t = 0.0;
    while (t < len) {
      final e = math.min(t + 10, len);
      c.drawLine(a + u * t, a + u * e, p);
      t += 22;
    }
  }

  @override
  bool shouldRepaint(_IslandPainter old) => old.n != n || old.isl != isl;
}

// --------------------------------------------------------- good day for

class DayScore {
  DayScore(this.key, this.icon, this.score, this.why);
  final String key;
  final IconData icon;
  final int score; // 1..5
  final String why;
  String get label => switch (key) {
        'hiking' => _w('Hiking', 'Caminhadas'),
        'beach' => _w('Beach', 'Praia'),
        'views' => _w('Viewpoints', 'Miradouros'),
        _ => _w('Flights', 'Voos'),
      };
}

int _clamp(int v) => v < 1 ? 1 : v > 5 ? 5 : v;

/// Four verdicts from the same facts. Only an order of merit: a 2 says
/// "think twice", never "closed".
List<DayScore> dayScores(IslandNow n) {
  final out = <DayScore>[];
  final sc = n.summitCode ?? 0, cc = n.coastCode ?? 0;
  final rain = sc >= 51 || cc >= 51;
  final fog = sc >= 45 && sc <= 48;
  final cloudRidge = sc == 3 || fog;
  final severe = n.warnings.any((w) => w.level == 'orange' || w.level == 'red');
  final gusts = n.airGusts ?? 0;

  // hiking
  var h = 5;
  final hw = <String>[];
  if (rain) { h -= 3; hw.add(_w('wet on the trails', 'molhado nas veredas')); } else { hw.add(_w('dry', 'seco')); }
  if ((n.summitT ?? 15) < 5) { h -= 1; hw.add(_w('cold on the summit', 'frio no cume')); }
  if (fog) { h -= 1; hw.add(_w('ridge in cloud', 'cumeada nas nuvens')); }
  if (gusts > 55) { h -= 1; hw.add('${_w('gusts', 'rajadas')} ${gusts.round()}'); }
  if (severe) { h -= 2; hw.add(_w('IPMA warning', 'aviso IPMA')); }
  out.add(DayScore('hiking', Icons.hiking, _clamp(h), hw.join(' · ')));

  // beach
  final seaT = n.seaT ?? 21, waves = n.waves ?? 1;
  var b = seaT >= 22 ? 4 : seaT >= 20 ? 3 : 2;
  final bw = <String>['${_w('sea', 'mar')} ${seaT.toStringAsFixed(1)}°'];
  if (cc <= 1 && !rain) { b += 1; }
  if (waves > 2.5) { b -= 2; bw.add(_w('sea too rough', 'mar demasiado agitado')); } else if (waves > 1.5) { b -= 1; bw.add('${_w('waves', 'ondas')} ${waves.toStringAsFixed(1)} m'); } else { bw.add('${_w('waves', 'ondas')} ${waves.toStringAsFixed(1)} m'); }
  if (rain) { b -= 2; bw.add(_w('rain', 'chuva')); }
  if ((n.coastWind ?? 0) > 30) { b -= 1; bw.add(_w('strong wind', 'vento forte')); }
  if ((n.uv ?? 0) >= 8) bw.add(_w('UV very high', 'UV muito alto'));
  out.add(DayScore('beach', Icons.beach_access, _clamp(b), bw.join(' · ')));

  // viewpoints
  var v = sc <= 1 ? 5 : sc == 2 ? 3 : 1;
  final vw = <String>[];
  if (rain) { v = 1; vw.add(_w('rain', 'chuva')); }
  else if (cloudRidge) { vw.add(_w('ridge in cloud', 'cumeada nas nuvens')); vw.add(_w('try the coast', 'tente a costa')); }
  else if (sc == 2) { vw.add(_w('cloud', 'nublado')); }
  else { vw.add(_w('ridge clear', 'cumeada limpa')); }
  out.add(DayScore('views', Icons.visibility_outlined, _clamp(v), vw.join(' · ')));

  // flights
  final cross = n.airCross;
  var fl = cross == null ? 4 : cross >= 28 ? 1 : cross >= 20 ? 3 : 5;
  if (gusts > 60) fl = 1;
  final fw = <String>[];
  if (cross == null) { fw.add(_w('calm', 'calmo')); }
  else if (cross >= 28) { fw.add(_w('crosswind over the limit', 'vento cruzado acima do limite')); fw.add(_w('diversions likely', 'desvios prováveis')); }
  else if (cross >= 20) { fw.add('${_w('gusts', 'rajadas')} ${gusts.round()}'); fw.add(_w('delays', 'atrasos')); }
  else { fw.add(_w('calm for landings', 'calmo para aterrar')); }
  out.add(DayScore('flights', Icons.flight, _clamp(fl), fw.join(' · ')));
  return out;
}

class GoodDayStrip extends StatelessWidget {
  const GoodDayStrip({super.key, required this.now});
  final IslandNow now;

  @override
  Widget build(BuildContext context) {
    final scores = dayScores(now);
    Color col(int s) => s >= 4 ? kGreen : s == 3 ? const Color(0xFFD9A441) : (context.dark ? kTerraBright : kTerracotta);
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: context.cSurface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_w('Today is good for', 'Hoje está bom para'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.cTitle)),
            const SizedBox(height: 10),
            for (final s in scores)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Icon(s.icon, size: 22, color: col(s.score)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${s.label} · ${s.score}/5', style: TextStyle(fontWeight: FontWeight.w600, color: context.cBody)),
                      Text(s.why, style: TextStyle(fontSize: 13, color: context.cSubtle)),
                    ]),
                  ),
                ]),
              ),
          ]),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          for (final s in scores)
            Expanded(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(s.icon, size: 18, color: col(s.score)),
                  const SizedBox(width: 4),
                  Text(s.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.cBody)),
                ]),
                const SizedBox(height: 3),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  for (var i = 0; i < 5; i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: i < s.score ? col(s.score) : context.cHairline),
                    ),
                ]),
              ]),
            ),
        ]),
      ),
    );
  }
}
