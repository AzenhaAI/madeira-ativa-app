import 'package:flutter/material.dart';

import 'main.dart';
import 'store.dart';

/// Race analytics from the site's stats datasets (MIUT & co).
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, dynamic>? _d;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    const b = 'https://shpara.com/madeira';
    final out = <String, dynamic>{};
    for (final f in [
      'all_trails', 'clubs_data', 'localities_data',
      'dnf_by_race', 'finish_hours', 'loyalty_data',
      'country_performance', 'intl_trend', 'time_distributions'
    ]) {
      try {
        out[f] = await cachedJson('$b/$f.json');
      } catch (_) {}
    }
    if (mounted) setState(() => _d = out);
  }

  @override
  Widget build(BuildContext context) {
    if (_d == null) {
      return Scaffold(
          appBar: AppBar(title: Text(t('stats'))),
          body: skeletonList(context));
    }
    final w = <Widget>[];

    // Finishers by year
    final at = (_d!['all_trails'] as List?) ?? [];
    if (at.isNotEmpty) {
      final by = <int, int>{};
      for (final r in at) {
        by[r['year'] as int] = (by[r['year']] ?? 0) + (r['total'] as int? ?? 0);
      }
      final ys = by.keys.toList()..sort();
      w.addAll(_section(context, t('finishers_year'), [
        for (final y in ys.reversed.take(12).toList().reversed)
          ('$y', by[y]!.toDouble(), '${by[y]}')
      ]));
    }
    // Top clubs
    final cl = (_d!['clubs_data'] as List?) ?? [];
    if (cl.isNotEmpty) {
      w.addAll(_section(context, t('top_clubs'), [
        for (final c in cl.take(8))
          (
            (c['club'] ?? c['name'] ?? '').toString(),
            ((c['finishers'] ?? c['count'] ?? 0) as num).toDouble(),
            '${c['finishers'] ?? c['count']}'
          )
      ]));
    }
    // Localities
    final lo = (_d!['localities_data'] as List?) ?? [];
    if (lo.isNotEmpty) {
      w.addAll(_section(context, t('top_localities'), [
        for (final c in lo.take(8))
          (
            (c['locality'] ?? '').toString(),
            ((c['finishers'] ?? 0) as num).toDouble(),
            '${c['finishers']}'
          )
      ]));
    }
    // Toughest (DNF%)
    final dn = (_d!['dnf_by_race'] as List?) ?? [];
    if (dn.isNotEmpty) {
      final rows = <(String, double, String)>[];
      for (final r in dn) {
        final st = (r['started'] as num?)?.toDouble() ?? 0;
        final fi = (r['finished'] as num?)?.toDouble() ?? 0;
        if (st < 30) continue;
        final pct = st == 0 ? 0.0 : (1 - fi / st) * 100;
        rows.add(((r['race'] ?? '').toString(), pct, '${pct.round()}%'));
      }
      rows.sort((a, b) => b.$2.compareTo(a.$2));
      w.addAll(_section(context, t('toughest'), rows.take(8).toList(),
          accent: kTerracotta));
    }
    // Finish hours
    final fh = (_d!['finish_hours'] as List?) ?? [];
    if (fh.isNotEmpty) {
      w.addAll(_section(context, t('finish_hours'), [
        for (final h in fh)
          ('${h['hour']}h', ((h['count'] ?? 0) as num).toDouble(), '')
      ], thin: true));
    }
    // Loyalty
    final loy = _d!['loyalty_data'];
    final dist = (loy is Map ? loy['distribution'] : null) as Map?;
    if (dist != null) {
      final ks = dist.keys.map((k) => int.parse('$k')).toList()..sort();
      w.addAll(_section(context, t('loyalty'), [
        for (final k in ks.take(8))
          ('$k', (dist['$k'] as num).toDouble(), '${dist['$k']}')
      ]));
    }

    // Countries
    final cp = (_d!['country_performance'] as List?) ?? [];
    if (cp.isNotEmpty) {
      w.addAll(_section(context, t('countries'), [
        for (final c in cp.take(10))
          (
            (c['country'] ?? '').toString(),
            ((c['finishers'] ?? 0) as num).toDouble(),
            '${c['finishers']}'
          )
      ]));
    }
    // International trend (% of intl runners by year)
    final it = (_d!['intl_trend'] as List?) ?? [];
    if (it.isNotEmpty) {
      w.addAll(_section(context, t('intl_trend'), [
        for (final r in it)
          (
            '${r['year']}',
            ((r['pct_intl'] ?? 0) as num).toDouble(),
            '${(r['pct_intl'] as num).round()}%'
          )
      ], accent: kTerracotta, thin: true));
    }
    // Finish time spread (median hours by distance bucket)
    final td = _d!['time_distributions'];
    if (td is Map && td.isNotEmpty) {
      w.addAll(_section(context, t('time_dist'), [
        for (final e in td.entries)
          (
            e.key.toString(),
            ((e.value['median'] ?? 0) as num).toDouble() / 60,
            '${(((e.value['median'] ?? 0) as num).toDouble() / 60).toStringAsFixed(1)} h'
          )
      ]));
    }

    return Scaffold(
      appBar: AppBar(title: Text(t('stats'))),
      body: ListView(padding: const EdgeInsets.all(16), children: w),
    );
  }

  List<Widget> _section(BuildContext context, String title,
      List<(String, double, String)> rows,
      {Color accent = kGreen, bool thin = false}) {
    if (rows.isEmpty) return [];
    final mx = rows.map((r) => r.$2).reduce((a, b) => a > b ? a : b);
    return [
      Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 8),
        child: Text(title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.cTitle)),
      ),
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.cHairline, width: 0.5),
        ),
        child: Column(children: [
          for (final r in rows)
            Padding(
              padding: EdgeInsets.symmetric(vertical: thin ? 1.5 : 4),
              child: Row(children: [
                SizedBox(
                    width: 110,
                    child: Text(r.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5))),
                Expanded(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: mx == 0 ? 0 : (r.$2 / mx).clamp(0.02, 1.0),
                    child: Container(
                        height: thin ? 6 : 12,
                        decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(4))),
                  ),
                ),
                if (r.$3.isNotEmpty)
                  SizedBox(
                      width: 52,
                      child: Text(r.$3,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 11, color: context.cSubtle))),
              ]),
            ),
        ]),
      ),
    ];
  }
}
