import 'dart:math';

import 'package:flutter/material.dart';
// Only LatLng: latlong2 also exports a Path, which shadows the dart:ui Path
// that the elevation profile is drawn with.
import 'package:latlong2/latlong.dart' show LatLng;

import 'main.dart';

/// Detail screen for one PR trail: stats, elevation profile, link.
class LevadaPage extends StatelessWidget {
  final Levada l;
  const LevadaPage({super.key, required this.l});

  @override
  Widget build(BuildContext context) {
    final open = l.isOpen;
    final part = l.isPartial;
    return Scaffold(
      appBar: AppBar(title: Text(l.code)),
      body: ReadableWidth(
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.displayName,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: context.cTitle)),
          if (l.fromP.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${l.fromP} → ${l.toP}',
                  style: TextStyle(fontSize: 13, color: context.cSubtle)),
            ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
                color: kGreen, borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _S('${l.distance} km', 'dist'),
                _S('↑${l.ascent} m', 'climb'),
                _S(t(open ? 'open' : (part ? 'partial' : 'closed')), 'status',
                    warn: !open),
                if (l.fee.isNotEmpty && l.fee != 'None') _S(l.fee, t('fee')),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _DetailGrid(l: l),
          if (l.profile.length > 2) ...[
            const SizedBox(height: 20),
            Text(t('elev_profile'),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.cTitle)),
            const SizedBox(height: 8),
            Container(
              height: 160,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.cSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cHairline, width: 0.5),
              ),
              child: CustomPaint(
                  size: Size.infinite,
                  painter: _ProfilePainter(l.profile, context.cSubtle)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                  '${l.profile.reduce((a, b) => a < b ? a : b).round()}–${l.profile.reduce((a, b) => a > b ? a : b).round()} m',
                  style: TextStyle(fontSize: 11, color: context.cSubtle)),
            ),
          ],
          // Only 2 of the 44 trails carry a description in the feed, so a
          // detail page used to be a row of numbers and nothing else. These
          // sections add what can be known for certain rather than written:
          // the forecast at this trail's own altitude, and what else is
          // walkable from the same trailhead.
          if (l.center != null) _WeatherHere(at: l.center!),
          _RacesHere(code: l.code),
          _NearbyTrails(here: l),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: kGreen),
            onPressed: () =>
                openUrl(locale.value == 'pt' ? l.urlPt : l.urlEn),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('visitmadeira.com'),
          ),
        ],
        ),
      ),
    );
  }
}

/// Races whose course runs along this trail, and what the site knows about
/// them. Silent when no race passes here, so it never leaves an empty heading.
///
/// The times shown belong to the race. Results are recorded per race distance,
/// never per trail segment, so there is no honest "record for this levada" to
/// print and none is invented.
class _RacesHere extends StatefulWidget {
  final String code;
  const _RacesHere({required this.code});

  @override
  State<_RacesHere> createState() => _RacesHereState();
}

class _RacesHereState extends State<_RacesHere> {
  List<dynamic>? _races;

  @override
  void initState() {
    super.initState();
    fetchTrailRaces().then((all) {
      if (!mounted) return;
      setState(() => _races = all[widget.code] as List<dynamic>?);
    }).catchError((Object e) {
      // Swallowing this silently is how a broken feed turns into a section
      // that simply never appears, with nothing to explain why.
      debugPrint('trail races unavailable for ${widget.code}: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    final races = _races;
    if (races == null || races.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Text(t('races_here'),
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.cTitle)),
        const SizedBox(height: 8),
        for (final race in races.cast<Map<String, dynamic>>())
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: race['url'] == null
                  ? null
                  : () => openUrl('https://shpara.com${race['url']}'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: context.cSurface,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: context.cHairline, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(race['race'] as String,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: context.cTitle)),
                          const SizedBox(height: 3),
                          Text(
                            '${t('covers')} ${race['coverage_pct']}% ${t('of_trail')}'
                            '${race['editions'] != null ? ' · ${race['editions']} ${t('editions')}' : ''}'
                            '${race['finishers'] != null ? ' · ${race['finishers']} ${t('finishers_total')}' : ''}',
                            style: TextStyle(
                                fontSize: 12, color: context.cSubtle),
                          ),
                          if (race['best'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${t('course_record')} '
                              '${(race['best']['distance_km'] as num).round()} km — '
                              '${race['best']['time']} · ${race['best']['holder']}',
                              style: TextStyle(
                                  fontSize: 12, color: context.cSubtle),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (race['url'] != null)
                      Icon(Icons.chevron_right,
                          size: 20, color: context.cSubtle),
                  ],
                ),
              ),
            ),
          ),
        if (races.any((r) => (r as Map)['best'] != null))
          Text(t('race_not_trail'),
              style: TextStyle(fontSize: 11, color: context.cSubtle)),
      ],
    );
  }
}

/// Facts that levadas.json always carries but the page never showed, plus the
/// few worth deriving from the elevation profile. Laid out as a wrap so a wide
/// iPad window fills across instead of leaving a column of empty space.
class _DetailGrid extends StatelessWidget {
  final Levada l;
  const _DetailGrid({required this.l});

  @override
  Widget build(BuildContext context) {
    final range = l.altitudeRange;
    final steep = l.steepestStep;

    final rows = <(String, String)>[
      if (l.walkingTime != null) (t('on_foot'), '~${l.walkingTime}'),
      (t('difficulty'), t(l.difficultyKey)),
      if (l.descent.isNotEmpty && l.descent != 'null')
        (t('descent'), '↓${l.descent} m'),
      if (range != null)
        (t('altitude'), '${range.min.round()}–${range.max.round()} m'),
      if (steep != null && steep > 0)
        (t('steepest'), '${steep.round()} m'),
      (t('route_type'), t(l.roundtrip ? 'roundtrip' : 'one_way')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (label, value) in rows)
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 132),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.cSurface,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: context.cHairline, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 11, color: context.cSubtle)),
                      const SizedBox(height: 2),
                      Text(value,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.cTitle)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (l.walkingTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(t('time_note'),
                style: TextStyle(fontSize: 11, color: context.cSubtle)),
          ),
      ],
    );
  }
}

class _S extends StatelessWidget {
  final String v, l;
  final bool warn;
  const _S(this.v, this.l, {this.warn = false});
  @override
  Widget build(BuildContext c) => Column(mainAxisSize: MainAxisSize.min, children: [
        Text(v,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: warn ? const Color(0xFFFFB3A5) : Colors.white)),
        Text(l,
            style:
                const TextStyle(fontSize: 10, color: Color(0xFF9FE1CB))),
      ]);
}

class _ProfilePainter extends CustomPainter {
  final List<double> pts;
  final Color axis;
  _ProfilePainter(this.pts, this.axis);

  @override
  void paint(Canvas c, Size s) {
    final mn = pts.reduce((a, b) => a < b ? a : b);
    final mx = pts.reduce((a, b) => a > b ? a : b);
    final span = (mx - mn) == 0 ? 1 : mx - mn;
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final x = i / (pts.length - 1) * s.width;
      final y = s.height - (pts[i] - mn) / span * (s.height - 8) - 4;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    final fill = Path.from(path)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    c.drawPath(fill,
        Paint()..color = kGreen.withValues(alpha: 0.15));
    c.drawPath(
        path,
        Paint()
          ..color = kGreen
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant _ProfilePainter o) => o.pts != pts;
}

/// The forecast where the trail actually is.
class _WeatherHere extends StatefulWidget {
  final LatLng at;
  const _WeatherHere({required this.at});

  @override
  State<_WeatherHere> createState() => _WeatherHereState();
}

class _WeatherHereState extends State<_WeatherHere> {
  Map<String, dynamic>? _f;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    fetchTrailWeather(widget.at).then((f) {
      if (mounted) setState(() { _f = f; _done = true; });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Nothing at all until the forecast lands, and nothing ever if it fails:
    // a hiking page should not show an empty weather frame in a dead spot.
    if (!_done || _f == null) return const SizedBox.shrink();
    final d = _f!['daily'] as Map<String, dynamic>;
    final days = List<String>.from(d['time'] as List);
    final elev = (_f!['elevation'] as num?)?.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Text(t('weather'),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.cTitle)),
            if (elev != null) ...[
              const SizedBox(width: 8),
              Text('· $elev m',
                  style: TextStyle(fontSize: 13, color: context.cSubtle)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < days.length; i++)
          Builder(builder: (context) {
            final code = (d['weather_code'] as List)[i] as int;
            final face = weatherFace(code);
            final lo = (d['temperature_2m_min'] as List)[i];
            final hi = (d['temperature_2m_max'] as List)[i];
            final rain = (d['precipitation_probability_max'] as List)[i];
            final wind = (d['wind_speed_10m_max'] as List)[i];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                      width: 84,
                      child: Text(i == 0 ? t('today') : days[i].substring(5),
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.cBody))),
                  Text(face.$1, style: const TextStyle(fontSize: 17)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(face.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: context.cBody)),
                  ),
                  if (rain != null && (rain as num) >= 20) ...[
                    Text('💧$rain%',
                        style:
                            TextStyle(fontSize: 12, color: context.cSubtle)),
                    const SizedBox(width: 8),
                  ],
                  if (wind != null && (wind as num) >= 30) ...[
                    Text('💨${wind.round()}',
                        style:
                            TextStyle(fontSize: 12, color: context.cSubtle)),
                    const SizedBox(width: 8),
                  ],
                  Text('${(lo as num).round()}–${(hi as num).round()}°',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.cTitle)),
                ],
              ),
            );
          }),
        const SizedBox(height: 4),
        Text(t('weather_src'),
            style: TextStyle(fontSize: 11, color: context.cSubtle)),
      ],
    );
  }
}

/// Other trails within a short drive of this one's midpoint.
///
/// Straight-line distance, and labelled as such: on Madeira a ridge two
/// kilometres away can be an hour by road, so the number is a hint about which
/// walks pair up in a day, not a travel estimate.
class _NearbyTrails extends StatefulWidget {
  final Levada here;
  const _NearbyTrails({required this.here});

  @override
  State<_NearbyTrails> createState() => _NearbyTrailsState();
}

class _NearbyTrailsState extends State<_NearbyTrails> {
  List<(Levada, double)> _near = const [];

  @override
  void initState() {
    super.initState();
    final c = widget.here.center;
    if (c == null) return;
    fetchLevadas().then((all) {
      if (!mounted) return;
      final rows = <(Levada, double)>[];
      for (final o in all) {
        if (o.code == widget.here.code || o.center == null) continue;
        rows.add((o, _km(c, o.center!)));
      }
      rows.sort((a, b) => a.$2.compareTo(b.$2));
      setState(() => _near = rows.take(4).toList());
    }).catchError((Object e) => debugPrint('nearby trails unavailable: $e'));
  }

  static double _km(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final la1 = a.latitude * pi / 180, la2 = b.latitude * pi / 180;
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(la1) * cos(la2) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * r * asin(min(1.0, sqrt(h)));
  }

  @override
  Widget build(BuildContext context) {
    if (_near.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(t('nearby'),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.cTitle)),
        const SizedBox(height: 8),
        for (final (o, km) in _near)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: ListTile(
              dense: true,
              title: Text(o.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(
                  '${km.toStringAsFixed(1)} km ${t('as_the_crow')}'
                  '${o.distance.isEmpty ? '' : ' · ${o.distance} km'}',
                  style: TextStyle(fontSize: 12, color: context.cSubtle)),
              trailing: Icon(
                  o.isOpen ? Icons.check_circle_outline : Icons.error_outline,
                  size: 18,
                  color: o.isOpen ? kGreen : kTerracotta),
              onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => LevadaPage(l: o))),
            ),
          ),
      ],
    );
  }
}
