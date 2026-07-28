import 'package:flutter/material.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.name,
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
