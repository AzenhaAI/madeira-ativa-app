import 'dart:math';

import 'package:flutter/material.dart';
// Only LatLng: latlong2 also exports a Path, which shadows the dart:ui Path
// that the elevation profile is drawn with.
import 'package:latlong2/latlong.dart' show LatLng;

import 'ask_review.dart';
import 'island_now.dart';
import 'main.dart';

/// Detail screen for one PR trail: stats, elevation profile, link.
class LevadaPage extends StatefulWidget {
  final Levada l;
  const LevadaPage({super.key, required this.l});

  @override
  State<LevadaPage> createState() => _LevadaPageState();
}

class _LevadaPageState extends State<LevadaPage> {
  @override
  void initState() {
    super.initState();
    // Opening trail pages is what someone here to plan a walk actually does,
    // so it is the honest signal that the app was useful. Fire-and-forget:
    // AskReview decides whether this is the third time, and iOS decides
    // whether to draw anything at all.
    AskReview.maybeAskForReview();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
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
                _S('${l.distance} km', t('dist')),
                _S('↑${l.ascent} m', t('climb')),
                _S(t(open ? 'open' : (part ? 'partial' : 'closed')), t('status'),
                    warn: !open),
                if (l.fee.isNotEmpty && l.fee != 'None')
                  // The fee was shown with nowhere to pay it. Booking is
                  // mandatory and online-only, and the trailhead has no signal.
                  GestureDetector(
                    onTap: () => openUrl('https://simplifica.madeira.gov.pt/'),
                    child: _S(l.fee, t('fee')),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _DetailGrid(l: l),
          _TrailWarnings(l: l),
          if (l.ends.isNotEmpty) ...[
            const SizedBox(height: 18),
            _GetThere(l: l),
          ],
          if (l.fee.isNotEmpty && l.fee != 'None') ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => openUrl('https://simplifica.madeira.gov.pt/'),
              icon: const Icon(Icons.confirmation_number_outlined, size: 18),
              label: Text(t('pay_link')),
            ),
          ],
          const SizedBox(height: 18),
          const _Glossary(),
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
                  : () => openUrl('https://azenha.ai${race['url']}'),
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
      if (l.walkingTime != null)
        (t('on_foot'), l.timeIsOfficial ? l.walkingTime! : '~${l.walkingTime}'),
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
            child: Text(t(l.timeIsOfficial ? 'time_official' : 'time_note'),
                style: TextStyle(fontSize: 11, color: context.cSubtle)),
          ),
      ],
    );
  }
}

/// The words on the trail signs, explained once. A tester who has lived here
/// for years said a newcomer "will not work it out without a bottle": levada,
/// vereda, PR, partially open, open one way — the app used all of them and
/// defined none.
class _Glossary extends StatelessWidget {
  const _Glossary();

  @override
  Widget build(BuildContext context) {
    final keys = ['g_levada', 'g_vereda', 'g_pr', 'g_partial', 'g_oneway'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('glossary'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 6),
        for (final k in keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(t(k),
                style: TextStyle(fontSize: 13, height: 1.35, color: context.cSubtle)),
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


/// IPMA warnings in force for the zone this trail walks in (mountains, a
/// coast, or Porto Santo). Nothing is shown when there are none — never "all
/// clear", since a failed request would look the same.
class _TrailWarnings extends StatelessWidget {
  final Levada l;
  const _TrailWarnings({required this.l});

  @override
  Widget build(BuildContext context) {
    final zone = trailZone(l);
    return FutureBuilder<List<IpmaWarning>>(
      future: fetchIpmaWarnings(),
      builder: (context, snap) {
        final here = (snap.data ?? []).where((w) => w.zone == zone).toList();
        if (here.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('ipma_here'),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.cSubtle)),
              const SizedBox(height: 6),
              IpmaWarningList(warnings: here),
            ],
          ),
        );
      },
    );
  }
}

/// How to reach each end: height, directions to the nearest car park (or the
/// place itself — an end with no car park may be a summit no road reaches),
/// and the bus lines that pass it, each opening its SIGA timetable. The ends
/// are called upper and lower only when they differ by 150 m or more; the
/// elevation model flattens sharp summits.
class _GetThere extends StatelessWidget {
  final Levada l;
  const _GetThere({required this.l});

  @override
  Widget build(BuildContext context) {
    final ends = l.ends;
    final spread = ends.length == 2 ? ends[0].elev - ends[1].elev : 0;
    String title(int i) => ends.length == 1
        ? t('loop_end')
        : spread >= 150
            ? t(i == 0 ? 'upper_end' : 'lower_end')
            : t('trail_end');
    TextStyle body = TextStyle(fontSize: 14, color: context.cBody);
    TextStyle soft = TextStyle(fontSize: 13, color: context.cSubtle);

    Widget endBlock(int i) {
      final e = ends[i];
      final rows = <Widget>[
        Text('${spread >= 150 ? (i == 0 ? '▲ ' : '▼ ') : '● '}${title(i)} · ${e.elev} m',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.cTitle)),
      ];
      if (e.parking != null) {
        final pk = e.parking!;
        rows.add(InkWell(
          onTap: () => openUrl('https://www.google.com/maps/dir/?api=1&destination=${pk.lat},${pk.lon}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text('🚗 ${t('drive_park')}${pk.name.isNotEmpty ? ' ${pk.name}' : ''} — ${pk.dist} m ${t('from_path')}'
                '${pk.paid ? ' · ${t('paid')}' : ''}',
                style: body.copyWith(color: kGreen, fontWeight: FontWeight.w600)),
          ),
        ));
      } else {
        rows.add(InkWell(
          onTap: () => openUrl('https://www.google.com/maps/search/?api=1&query=${e.lat},${e.lon}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '📍 ${t('end_on_map')}', style: body.copyWith(color: kGreen, fontWeight: FontWeight.w600)),
              if (e.parkingKnown) TextSpan(text: '  (${t('no_park')})', style: soft),
            ])),
          ),
        ));
      }
      if (e.lines.isNotEmpty) {
        rows.add(Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Text('🚌 ${t(e.lines.length > 1 ? 'bus_many' : 'bus_one')}', style: body),
              for (final ln in e.lines)
                ActionChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(ln.line),
                  tooltip: ln.name,
                  onPressed: ln.timetable.isEmpty ? null : () => openUrl(ln.timetable),
                ),
              Text(t(e.lines.length > 1 ? 'pass_many' : 'pass_one'), style: soft),
            ],
          ),
        ));
      }
      if (e.stop != null) {
        rows.add(Text('🚏 ${e.stop!.stop}, ${e.stop!.dist} m (${e.stop!.lines.join(', ')})', style: soft));
      }
      if (e.lines.isEmpty && e.stop == null && e.linesKnown) {
        rows.add(Text('🚌 ${t('no_route')}', style: soft));
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('get_there'),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.cTitle)),
        const SizedBox(height: 8),
        for (var i = 0; i < ends.length; i++) endBlock(i),
        InkWell(
          onTap: () => openUrl('https://siga.madeira.gov.pt/horarios'),
          child: Text('${t('all_timetables')} ↗', style: soft.copyWith(decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}
