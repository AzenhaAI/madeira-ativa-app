import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'main.dart';
import 'orienteering.dart';

/// Control description pictograms, drawn here after the IOF "International
/// Specification for Control Descriptions 2018" (own drawings, own texts).
/// Kirill photographed four Madeira sheets (Santana, Ponta do Sol, the
/// Estreito rogaine, Ribeira Brava; 22.10.2026): every pictogram on them is
/// in this list.

const _ink = Color(0xFF1A1A1A);

Paint _s(double w) => Paint()
  ..color = _ink
  ..strokeWidth = w
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round;
Paint get _f => Paint()..color = _ink;

typedef CdDraw = void Function(Canvas c, Size s);

void _arrow(Canvas c, Size s, double deg) {
  final m = Offset(s.width / 2, s.height / 2);
  final a = deg * math.pi / 180;
  final v = Offset(math.sin(a), -math.cos(a));
  final tip = m + v * s.width * .36, tail = m - v * s.width * .36;
  c.drawLine(tail, tip, _s(1.6));
  final l = Offset(math.sin(a + 2.6), -math.cos(a + 2.6)) * 6, r = Offset(math.sin(a - 2.6), -math.cos(a - 2.6)) * 6;
  c.drawLine(tip, tip + l, _s(1.6));
  c.drawLine(tip, tip + r, _s(1.6));
}

void _diag(Canvas c, Size s, {bool dashed = false, bool dotted = false}) {
  final a = Offset(s.width * .2, s.height * .8), b = Offset(s.width * .8, s.height * .2);
  if (!dashed && !dotted) {
    c.drawLine(a, b, _s(1.8));
    return;
  }
  final n = dotted ? 7 : 3;
  for (var i = 0; i < n; i++) {
    final t0 = i / n, t1 = t0 + (dotted ? .04 : .6 / n);
    c.drawLine(Offset.lerp(a, b, t0)!, Offset.lerp(a, b, t1)!, _s(dotted ? 2.2 : 1.6));
  }
}

void _wavy(Canvas c, Size s, {bool dashed = false}) {
  final p = Path()..moveTo(s.width * .2, s.height * .78);
  for (var i = 0; i < 3; i++) {
    final x = s.width * (.2 + i * .2), y = s.height * (.78 - i * .2);
    p.quadraticBezierTo(x + s.width * .02, y - s.height * .18, x + s.width * .2, y - s.height * .2);
  }
  if (!dashed) {
    c.drawPath(p, _s(1.6));
  } else {
    for (final m in p.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 6) {
        c.drawPath(m.extractPath(d, d + 3.5), _s(1.6));
      }
    }
  }
}

void _beads(Canvas c, Size s, {bool hollow = false}) {
  final a = Offset(s.width * .2, s.height * .8), b = Offset(s.width * .8, s.height * .2);
  if (!hollow) {
    _diag(c, s);
    for (final t in [.3, .5, .7]) {
      c.drawCircle(Offset.lerp(a, b, t)!, 2.4, _f);
    }
    return;
  }
  // IOF 4.6 linear thicket / hedge: a chain of open rings.
  const r = 3.8;
  final len = (b - a).distance;
  final pts = [for (final t in [.28, .5, .72]) Offset.lerp(a, b, t)!];
  for (final p in pts) {
    c.drawCircle(p, r, _s(1.3));
  }
  final u = (b - a) / len;
  var prev = a;
  for (final p in pts) {
    c.drawLine(prev, p - u * r, _s(1.3));
    prev = p + u * r;
  }
  c.drawLine(prev, b, _s(1.3));
}

void _ticksOnDiag(Canvas c, Size s) {
  _diag(c, s);
  for (final t in [.25, .45, .65, .85]) {
    final o = Offset(s.width * (.2 + .6 * t), s.height * (.8 - .6 * t));
    c.drawLine(o, o + const Offset(0, -6), _s(1.3));
  }
}

void _circleDot(Canvas c, Size s, Offset dot, {bool inside = false}) {
  final m = Offset(s.width / 2, s.height / 2);
  c.drawCircle(m, s.width * .24, _s(1.5));
  c.drawCircle(m + dot * s.width * (inside ? .12 : .42), 2, _f);
}

void _chevron(Canvas c, Size s, double deg, {required bool inside, double open = 45}) {
  final m = Offset(s.width / 2, s.height / 2);
  final a = deg * math.pi / 180;
  final dir = Offset(math.sin(a), -math.cos(a));
  final vtx = m + dir * s.width * .18;
  for (final sgn in [-1, 1]) {
    final b = a + math.pi + sgn * open * math.pi / 180;
    c.drawLine(vtx, vtx + Offset(math.sin(b), -math.cos(b)) * s.width * .36, _s(1.6));
  }
  c.drawCircle(vtx + dir * (inside ? -s.width * .14 : s.width * .12), 2, _f);
}

void _text(Canvas c, Size s, String t, {double size = 11}) {
  final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: _ink, fontSize: size, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr)
    ..layout();
  tp.paint(c, Offset((s.width - tp.width) / 2, (s.height - tp.height) / 2));
}

Offset _c(Size s) => Offset(s.width / 2, s.height / 2);

class CdItem {
  const CdItem(this.id, this.name, [this.note]);
  final String id;
  final T4 name;
  final T4? note;
}

final Map<String, CdDraw> _d = {
  // column C
  'n': (c, s) => _arrow(c, s, 0),
  'ne': (c, s) => _arrow(c, s, 45),
  'e': (c, s) => _arrow(c, s, 90),
  'se': (c, s) => _arrow(c, s, 135),
  's': (c, s) => _arrow(c, s, 180),
  'sw': (c, s) => _arrow(c, s, 225),
  'w': (c, s) => _arrow(c, s, 270),
  'nw': (c, s) => _arrow(c, s, 315),
  'upper': (c, s) {
    final m = _c(s);
    c.drawLine(m + Offset(-9, -3), m + Offset(9, -3), _s(1.6));
    c.drawLine(m + Offset(-9, 6), m + Offset(9, 6), _s(1.6));
    c.drawCircle(m + const Offset(0, -3), 2.4, _f);
  },
  'lower': (c, s) {
    final m = _c(s);
    c.drawLine(m + Offset(-9, -5), m + Offset(9, -5), _s(1.6));
    c.drawLine(m + Offset(-9, 4), m + Offset(9, 4), _s(1.6));
    c.drawCircle(m + const Offset(0, 4), 2.4, _f);
  },
  'middle': (c, s) {
    final m = _c(s);
    for (final x in [-7.0, 7.0]) {
      c.drawLine(m + Offset(x, -9), m + Offset(x, 9), _s(1.6));
    }
    c.drawLine(m + const Offset(0, -9), m + const Offset(0, 9), _s(1.2));
    c.drawCircle(m, 2.4, _f);
  },
  // column D: landforms
  'terrace': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-8, -10), m + const Offset(-8, 10), _s(1.6));
    c.drawPath(Path()..moveTo(m.dx - 2, m.dy - 10)..quadraticBezierTo(m.dx + 10, m.dy - 10, m.dx + 10, m.dy - 3)..quadraticBezierTo(m.dx + 10, m.dy + 3, m.dx - 2, m.dy + 4)..lineTo(m.dx - 4, m.dy + 10), _s(1.6));
  },
  'spur': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-8, -10), m + const Offset(-8, 10), _s(1.6));
    c.drawPath(Path()..moveTo(m.dx - 2, m.dy - 10)..lineTo(m.dx - 2, m.dy - 3)..quadraticBezierTo(m.dx + 12, m.dy - 3, m.dx + 10, m.dy + 2)..lineTo(m.dx - 2, m.dy + 2)..lineTo(m.dx - 2, m.dy + 10), _s(1.6));
  },
  'reentrant': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx - 9, m.dy + 10)..lineTo(m.dx - 6, m.dy - 2)..quadraticBezierTo(m.dx, m.dy - 14, m.dx + 6, m.dy - 2)..lineTo(m.dx + 9, m.dy + 10), _s(1.6));
  },
  'earthbank': (c, s) {
    final m = _c(s);
    c.drawArc(Rect.fromCenter(center: m + const Offset(0, 8), width: 24, height: 16), math.pi * 1.1, math.pi * .8, false, _s(1.6));
    for (final x in [-6.0, 0.0, 6.0]) {
      c.drawLine(m + Offset(x, -1), m + Offset(x, 4), _s(1.3));
    }
  },
  'earthwall': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-11, 0), m + const Offset(11, 0), _s(1.6));
    for (final x in [-6.0, -2.0, 2.0, 6.0]) {
      c.drawLine(m + Offset(x, -5), m + Offset(x, 5), _s(1.3));
    }
  },
  'gully': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx - 6, m.dy + 10)..lineTo(m.dx, m.dy - 10)..lineTo(m.dx + 6, m.dy + 10), _s(1.6));
  },
  'hill': (c, s) => c.drawOval(Rect.fromCenter(center: _c(s), width: 22, height: 13), _s(1.6)),
  'knoll': (c, s) => c.drawArc(Rect.fromCenter(center: _c(s) + const Offset(0, 4), width: 20, height: 18), math.pi, math.pi, true, _f),
  'saddle': (c, s) {
    final m = _c(s);
    c.drawArc(Rect.fromCenter(center: m + const Offset(-9, 0), width: 10, height: 20), -math.pi / 2.6, math.pi / 1.3, false, _s(1.6));
    c.drawArc(Rect.fromCenter(center: m + const Offset(9, 0), width: 10, height: 20), math.pi - math.pi / 2.6, math.pi / 1.3, false, _s(1.6));
  },
  'depression': (c, s) {
    final m = _c(s);
    c.drawOval(Rect.fromCenter(center: m, width: 22, height: 14), _s(1.6));
    c.drawLine(m + const Offset(-11, 0), m + const Offset(11, 0), _s(1.4));
  },
  'smalldep': (c, s) => c.drawArc(Rect.fromCenter(center: _c(s) - const Offset(0, 4), width: 16, height: 18), 0, math.pi, false, _s(1.7)),
  'pit': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx - 7, m.dy - 8)..lineTo(m.dx, m.dy + 8)..lineTo(m.dx + 7, m.dy - 8), _s(1.7));
  },
  // rock
  'cliff': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-11, -4), m + const Offset(11, -4), _s(1.8));
    for (final x in [-8.0, -3.0, 2.0, 7.0]) {
      c.drawLine(m + Offset(x, -4), m + Offset(x, 4), _s(1.3));
    }
  },
  'boulder': (c, s) => c.drawCircle(_c(s), 3.4, _f),
  'boulderfield': (c, s) {
    // IOF 2.5: five small triangles, 2-1-2 (three are 8.6 Rocky).
    final m = _c(s);
    for (final o in [const Offset(-7, -7), const Offset(7, -7), const Offset(0, 0), const Offset(-7, 7), const Offset(7, 7)]) {
      c.drawPath(Path()..moveTo(m.dx + o.dx, m.dy + o.dy - 3)..lineTo(m.dx + o.dx + 3, m.dy + o.dy + 2.4)..lineTo(m.dx + o.dx - 3, m.dy + o.dy + 2.4)..close(), _f);
    }
  },
  'boulders': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx, m.dy - 9)..lineTo(m.dx + 9, m.dy + 7)..lineTo(m.dx - 9, m.dy + 7)..close(), _f);
  },
  'stony': (c, s) {
    final m = _c(s);
    for (var x = -8.0; x <= 8; x += 4) {
      for (var y = -8.0; y <= 8; y += 4) {
        c.drawCircle(m + Offset(x, y), .9, _f);
      }
    }
  },
  'barerock': (c, s) {
    // IOF 2.8: rays with an open centre (closed in the middle it is an ant hill).
    final m = _c(s);
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 4;
      final v = Offset(math.cos(a), math.sin(a));
      c.drawLine(m + v * 3, m + v * 9, _s(1.4));
      c.drawLine(m - v * 3, m - v * 9, _s(1.4));
    }
  },
  'trench': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx - 9, m.dy - 7)..lineTo(m.dx - 4, m.dy - 7)..lineTo(m.dx - 4, m.dy + 7)..lineTo(m.dx + 4, m.dy + 7)..lineTo(m.dx + 4, m.dy - 7)..lineTo(m.dx + 9, m.dy - 7), _s(1.7));
  },
  // water
  'lake': (c, s) {
    final m = _c(s);
    c.drawOval(Rect.fromCenter(center: m, width: 22, height: 14), _s(1.6));
    c.drawPath(Path()..moveTo(m.dx - 6, m.dy)..quadraticBezierTo(m.dx - 3, m.dy - 4, m.dx, m.dy)..quadraticBezierTo(m.dx + 3, m.dy + 4, m.dx + 6, m.dy), _s(1.3));
  },
  'watercourse': (c, s) => _wavy(c, s),
  'ditch': (c, s) {
    // IOF 3.5: a wave between two dashed lines, so it cannot read as a path.
    _wavy(c, s);
    for (final k in [-4.5, 4.5]) {
      final a = Offset(s.width * .2 + k * .7, s.height * .8 + k * .7), b = Offset(s.width * .8 + k * .7, s.height * .2 + k * .7);
      for (var i = 0; i < 4; i++) {
        c.drawLine(Offset.lerp(a, b, i / 4)!, Offset.lerp(a, b, i / 4 + .12)!, _s(1.2));
      }
    }
  },
  'marsh': (c, s) {
    // IOF 3.7: stacked lines of different length, no ticks.
    final m = _c(s);
    for (final (y, w) in [(-6.0, 5.0), (-2.0, 9.0), (2.0, 9.0), (6.0, 5.0)]) {
      c.drawLine(m + Offset(-w, y), m + Offset(w, y), _s(1.4));
    }
  },
  'well': (c, s) {
    final m = _c(s);
    c.drawCircle(m - const Offset(0, 3), 6, _s(1.6));
    c.drawPath(Path()..moveTo(m.dx - 6, m.dy + 8)..quadraticBezierTo(m.dx - 3, m.dy + 5, m.dx, m.dy + 8)..quadraticBezierTo(m.dx + 3, m.dy + 11, m.dx + 6, m.dy + 8), _s(1.3));
  },
  'spring': (c, s) {
    final m = _c(s);
    c.drawArc(Rect.fromCenter(center: m + const Offset(-4, -4), width: 10, height: 10), math.pi / 2, math.pi * 1.2, false, _s(1.6));
    _wavy(c, Size(s.width * .7, s.height * .7));
  },
  'tank': (c, s) {
    final m = _c(s);
    c.drawRect(Rect.fromCenter(center: m + const Offset(0, 3), width: 16, height: 10), _s(1.6));
    c.drawPath(Path()..moveTo(m.dx - 8, m.dy - 7)..quadraticBezierTo(m.dx - 4, m.dy - 11, m.dx, m.dy - 7)..quadraticBezierTo(m.dx + 4, m.dy - 3, m.dx + 8, m.dy - 7), _s(1.3));
  },
  // vegetation
  'open': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx, m.dy - 10)..lineTo(m.dx + 10, m.dy)..lineTo(m.dx, m.dy + 10)..lineTo(m.dx - 10, m.dy)..close(), _s(1.6));
  },
  'semiopen': (c, s) {
    final m = _c(s);
    final p = Path()..moveTo(m.dx, m.dy - 10)..lineTo(m.dx + 10, m.dy)..lineTo(m.dx, m.dy + 10)..lineTo(m.dx - 10, m.dy)..close();
    for (final mm in p.computeMetrics()) {
      for (var d = 0.0; d < mm.length; d += 5) {
        c.drawCircle(mm.getTangentForOffset(d)!.position, 1.1, _f);
      }
    }
  },
  'clearing': (c, s) {
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      c.drawCircle(_c(s) + Offset(math.cos(a), math.sin(a)) * 9, 1.1, _f);
    }
  },
  'thicket': (c, s) {
    final m = _c(s);
    for (final k in [-4.0, 0.0, 4.0]) {
      c.drawLine(m + Offset(-9 + k, -5 - k), m + Offset(5 + k, 9 - k), _s(1.4));
      c.drawLine(m + Offset(-5 + k, 9 + k), m + Offset(9 + k, -5 + k), _s(1.4));
    }
  },
  'hedge': (c, s) => _beads(c, s, hollow: true),
  'vegboundary': (c, s) {
    final m = _c(s);
    for (var t = 0.0; t <= 1; t += .2) {
      c.drawCircle(Offset.lerp(m + const Offset(-9, -9), m + const Offset(6, 0), t)!, 1.2, _f);
      c.drawCircle(Offset.lerp(m + const Offset(6, 0), m + const Offset(-9, 9), t)!, 1.2, _f);
    }
  },
  'tree': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx, m.dy - 10)..lineTo(m.dx + 6, m.dy + 3)..lineTo(m.dx - 6, m.dy + 3)..close(), _s(1.5));
    c.drawLine(m + const Offset(0, 3), m + const Offset(0, 10), _s(1.5));
  },
  // man-made
  'road': (c, s) => _diag(c, s),
  'path': (c, s) => _diag(c, s, dashed: true),
  'ride': (c, s) {
    // IOF 5.3: two rows of dots.
    for (final k in [-2.5, 2.5]) {
      final a = Offset(s.width * .2 + k, s.height * .8 + k), b = Offset(s.width * .8 + k, s.height * .2 + k);
      for (var i = 0; i < 9; i++) {
        c.drawCircle(Offset.lerp(a, b, i / 8)!, .9, _f);
      }
    }
  },
  'bridge': (c, s) {
    _diag(c, s);
    final m = _c(s);
    c.drawArc(Rect.fromCenter(center: m + const Offset(-7, -7), width: 10, height: 10), 0, math.pi / 2, false, _s(1.4));
    c.drawArc(Rect.fromCenter(center: m + const Offset(7, 7), width: 10, height: 10), math.pi, math.pi / 2, false, _s(1.4));
  },
  'powerline': (c, s) {
    _diag(c, s);
    final m = _c(s);
    for (final t in [-5.0, 0.0, 5.0]) {
      c.drawLine(m + Offset(t - 3, -t - 3), m + Offset(t + 3, -t + 3), _s(1.3));
    }
  },
  'tunnel': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(0, -10), m + const Offset(0, 10), _s(1.6));
    c.drawLine(m + const Offset(-9, -3), m + const Offset(9, -3), _s(1.3));
    c.drawLine(m + const Offset(-9, 3), m + const Offset(9, 3), _s(1.3));
  },
  'wall': (c, s) => _beads(c, s),
  'fence': (c, s) => _ticksOnDiag(c, s),
  'crossing': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-11, 0), m + const Offset(-3, 0), _s(1.6));
    c.drawLine(m + const Offset(3, 0), m + const Offset(11, 0), _s(1.6));
    c.drawLine(m + const Offset(-3, -8), m + const Offset(-3, 8), _s(1.6));
    c.drawLine(m + const Offset(3, -8), m + const Offset(3, 8), _s(1.6));
  },
  'building': (c, s) => c.drawRect(Rect.fromCenter(center: _c(s), width: 16, height: 16), _f),
  'paved': (c, s) {
    final r = Rect.fromCenter(center: _c(s), width: 18, height: 18);
    c.drawRect(r, _s(1.5));
    c.save();
    c.clipRect(r);
    for (var k = -18.0; k < 18; k += 5) {
      c.drawLine(r.bottomLeft + Offset(k, 0), r.bottomLeft + Offset(k + 18, -18), _s(1.1));
    }
    c.restore();
  },
  'ruin': (c, s) {
    final r = Rect.fromCenter(center: _c(s), width: 18, height: 18);
    for (final corner in [r.topLeft, r.topRight, r.bottomLeft, r.bottomRight]) {
      final dx = corner.dx < r.center.dx ? 6.0 : -6.0, dy = corner.dy < r.center.dy ? 6.0 : -6.0;
      c.drawLine(corner, corner + Offset(dx, 0), _s(1.6));
      c.drawLine(corner, corner + Offset(0, dy), _s(1.6));
    }
  },
  'tower': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-8, -9), m + const Offset(8, -9), _s(1.8));
    c.drawLine(m + const Offset(0, -9), m + const Offset(0, 10), _s(1.8));
  },
  'cairn': (c, s) {
    c.drawCircle(_c(s), 9, _s(1.6));
    c.drawCircle(_c(s), 2.6, _f);
  },
  'monument': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx - 7, m.dy + 9)..lineTo(m.dx, m.dy - 9)..lineTo(m.dx + 7, m.dy + 9), _s(1.6));
    c.drawLine(m + const Offset(-9, 9), m + const Offset(9, 9), _s(1.6));
  },
  'canopy': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-9, -8), m + const Offset(9, -8), _s(1.8));
    c.drawLine(m + const Offset(-5, -8), m + const Offset(-5, 10), _s(1.8));
    c.drawLine(m + const Offset(5, -8), m + const Offset(5, 10), _s(1.8));
  },
  'stairway': (c, s) {
    final m = _c(s);
    c.drawPath(
        Path()
          ..moveTo(m.dx - 10, m.dy + 8)
          ..lineTo(m.dx - 5, m.dy + 8)
          ..lineTo(m.dx - 5, m.dy + 3)
          ..lineTo(m.dx, m.dy + 3)
          ..lineTo(m.dx, m.dy - 2)
          ..lineTo(m.dx + 5, m.dy - 2)
          ..lineTo(m.dx + 5, m.dy - 7)
          ..lineTo(m.dx + 10, m.dy - 7),
        _s(1.7));
  },
  'oob': (c, s) {
    final m = _c(s);
    for (final o in [const Offset(-5, -2), const Offset(5, -2), const Offset(0, -6)]) {
      c.drawCircle(m + o, 3.2, _s(1.2));
    }
    c.drawRect(Rect.fromCenter(center: m + const Offset(0, 6), width: 18, height: 6), _s(1.3));
  },
  'specialx': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-8, -8), m + const Offset(8, 8), _s(1.8));
    c.drawLine(m + const Offset(-8, 8), m + const Offset(8, -8), _s(1.8));
  },
  'specialo': (c, s) => c.drawCircle(_c(s), 9, _s(1.8)),
  // column E
  'low': (c, s) => c.drawArc(Rect.fromCenter(center: _c(s) + const Offset(0, 6), width: 22, height: 14), math.pi * 1.15, math.pi * .7, false, _s(1.7)),
  'shallow': (c, s) => c.drawArc(Rect.fromCenter(center: _c(s) - const Offset(0, 6), width: 22, height: 14), math.pi * .15, math.pi * .7, false, _s(1.7)),
  'deep': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx - 9, m.dy - 9)..lineTo(m.dx - 4, m.dy - 9)..lineTo(m.dx - 3, m.dy + 7)..quadraticBezierTo(m.dx, m.dy + 11, m.dx + 3, m.dy + 7)..lineTo(m.dx + 4, m.dy - 9)..lineTo(m.dx + 9, m.dy - 9), _s(1.5));
  },
  'overgrown': (c, s) {
    final m = _c(s);
    for (final k in [-5.0, 0.0, 5.0]) {
      c.drawLine(m + Offset(k, -9), m + Offset(k, 9), _s(1.3));
      c.drawLine(m + Offset(-9, k), m + Offset(9, k), _s(1.3));
    }
  },
  'rocky': (c, s) {
    final m = _c(s);
    for (final o in [const Offset(-5, -3), const Offset(5, -3), const Offset(0, 5)]) {
      c.drawPath(Path()..moveTo(m.dx + o.dx, m.dy + o.dy - 4)..lineTo(m.dx + o.dx + 4, m.dy + o.dy + 3)..lineTo(m.dx + o.dx - 4, m.dy + o.dy + 3)..close(), _f);
    }
  },
  'ruined': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx - 8, m.dy + 9)..lineTo(m.dx - 8, m.dy - 6)..quadraticBezierTo(m.dx - 8, m.dy - 10, m.dx - 3, m.dy - 9)..lineTo(m.dx + 8, m.dy + 4), _s(1.6));
    c.drawLine(m + const Offset(8, 4), m + const Offset(3, 4), _s(1.6));
    c.drawLine(m + const Offset(8, 4), m + const Offset(7, -1), _s(1.6));
  },
  // column F
  'height': (c, s) => _text(c, s, '2.5'),
  'size': (c, s) => _text(c, s, '8×4', size: 10),
  'xcross': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-9, -9), m + const Offset(9, 9), _s(1.7));
    c.drawLine(m + const Offset(-9, 9), m + const Offset(9, -9), _s(1.7));
  },
  'junction': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-8, -9), m + const Offset(0, 0), _s(1.7));
    c.drawLine(m + const Offset(8, -9), m + const Offset(-6, 10), _s(1.7));
  },
  'bend': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx + 6, m.dy - 10)..lineTo(m.dx - 6, m.dy)..lineTo(m.dx + 6, m.dy + 10), _s(1.7));
  },
  // column G
  'side': (c, s) => _circleDot(c, s, const Offset(.7, -.7)),
  'sideN': (c, s) => _circleDot(c, s, const Offset(0, -1)),
  'sideE': (c, s) => _circleDot(c, s, const Offset(1, 0)),
  'sideSE': (c, s) => _circleDot(c, s, const Offset(.7, .7)),
  'sideW': (c, s) => _circleDot(c, s, const Offset(-1, 0)),
  'edge': (c, s) {
    final m = _c(s);
    c.drawCircle(m - const Offset(2, 2), s.width * .22, _s(1.5));
    c.drawLine(m + const Offset(3, 3), m + const Offset(9, 9), _s(1.5));
  },
  'part': (c, s) => _circleDot(c, s, const Offset(-1, 0), inside: true),
  'cornerIn': (c, s) => _chevron(c, s, 90, inside: true),
  'cornerOut': (c, s) => _chevron(c, s, 180, inside: false),
  'cornerInNE': (c, s) => _chevron(c, s, 45, inside: true),
  'tip': (c, s) => _chevron(c, s, 225, inside: false, open: 20),
  'end': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(7, 7), m + const Offset(-5, -5), _s(1.7));
    c.drawLine(m + const Offset(-10, 0), m + const Offset(0, -10), _s(1.7));
  },
  'upperpart': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-5, -9), m + const Offset(-5, 9), _s(1.6));
    c.drawLine(m + const Offset(5, -9), m + const Offset(5, 9), _s(1.6));
    c.drawCircle(m + const Offset(0, -5), 2, _f);
  },
  'lowerpart': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-5, -9), m + const Offset(-5, 9), _s(1.6));
    c.drawLine(m + const Offset(5, -9), m + const Offset(5, 9), _s(1.6));
    c.drawCircle(m + const Offset(0, 5), 2, _f);
  },
  'top': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx - 6, m.dy + 9)..lineTo(m.dx - 6, m.dy - 2)..lineTo(m.dx + 6, m.dy - 2)..lineTo(m.dx + 6, m.dy + 9), _s(1.6));
    c.drawCircle(m + const Offset(0, -8), 2, _f);
  },
  'foot': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx - 6, m.dy - 9)..lineTo(m.dx - 6, m.dy + 8)..lineTo(m.dx + 8, m.dy + 8), _s(1.6));
    c.drawCircle(m + const Offset(-1, 3), 2, _f);
  },
  'beneath': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx - 8, m.dy + 7)..lineTo(m.dx - 8, m.dy - 6)..lineTo(m.dx + 8, m.dy - 6)..lineTo(m.dx + 8, m.dy + 7), _s(1.6));
    c.drawCircle(m + const Offset(0, 2), 2, _f);
  },
  'between': (c, s) {
    final m = _c(s);
    c.drawLine(m + const Offset(-9, -6), m + const Offset(9, -6), _s(1.6));
    c.drawLine(m + const Offset(-9, 6), m + const Offset(9, 6), _s(1.6));
    c.drawCircle(m, 2.2, _f);
  },
  // column H
  'firstaid': (c, s) {
    final m = _c(s);
    c.drawRect(Rect.fromCenter(center: m, width: 6, height: 18), _f);
    c.drawRect(Rect.fromCenter(center: m, width: 18, height: 6), _f);
  },
  'refresh': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx - 8, m.dy - 8)..lineTo(m.dx - 5, m.dy + 9)..lineTo(m.dx + 5, m.dy + 9)..lineTo(m.dx + 8, m.dy - 8)..close(), _s(1.6));
  },
  'manned': (c, s) {
    final m = _c(s);
    c.drawCircle(m - const Offset(0, 7), 2.6, _s(1.4));
    c.drawLine(m - const Offset(0, 4), m + const Offset(0, 4), _s(1.6));
    c.drawLine(m + const Offset(-6, -1), m + const Offset(6, -1), _s(1.6));
    c.drawLine(m + const Offset(0, 4), m + const Offset(-5, 10), _s(1.6));
    c.drawLine(m + const Offset(0, 4), m + const Offset(5, 10), _s(1.6));
  },
  // start triangle used on the sheet
  'start': (c, s) {
    final m = _c(s);
    c.drawPath(Path()..moveTo(m.dx, m.dy - 10)..lineTo(m.dx + 9, m.dy + 7)..lineTo(m.dx - 9, m.dy + 7)..close(), _s(1.6));
  },
};

CdDraw cd(String id) => _d[id] ?? (c, s) {};

class CdSwatch extends StatelessWidget {
  const CdSwatch(this.id, {super.key, this.size = 34, this.border = true});
  final String id;
  final double size;
  final bool border;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: Colors.white, border: border ? Border.all(color: const Color(0xFFB0B0B0), width: .7) : null),
        child: id.isEmpty ? null : CustomPaint(painter: _CdPainter(cd(id))),
      );
}

class _CdPainter extends CustomPainter {
  _CdPainter(this.d);
  final CdDraw d;
  @override
  void paint(Canvas canvas, Size size) => d(canvas, size);
  @override
  bool shouldRepaint(covariant _CdPainter old) => false;
}

/// The groups of the dictionary, in sheet order.
const List<(String, T4, T4, List<CdItem>)> kCdGroups = [
  (
    'C',
    ('Which of several similar features', 'Qual de vários objetos iguais', 'Welches von mehreren gleichen Objekten', 'Какой из похожих объектов'),
    ('Only when several alike are inside the circle. The arrow shows the compass direction: ↘︎ means "the south-eastern one".', 'Só quando há vários iguais no círculo. A seta aponta o rumo: ↘︎ quer dizer «o mais a sudeste».', 'Nur wenn mehrere gleiche im Kreis liegen. Der Pfeil zeigt die Himmelsrichtung: ↘︎ heißt „der südöstlichste“.', 'Только если в круге несколько похожих. Стрелка показывает сторону света: ↘︎ — «юго-восточный».'),
    [
      CdItem('n', ('Northern', 'O mais a norte', 'Nördlicher', 'Северный')),
      CdItem('se', ('South-eastern', 'O mais a sudeste', 'Südöstlicher', 'Юго-восточный')),
      CdItem('w', ('Western', 'O mais a oeste', 'Westlicher', 'Западный')),
      CdItem('upper', ('Upper (directly above another)', 'Superior (por cima de outro)', 'Oberer (direkt über einem anderen)', 'Верхний (прямо над другим)')),
      CdItem('lower', ('Lower', 'Inferior', 'Unterer', 'Нижний')),
      CdItem('middle', ('Middle one', 'O do meio', 'Mittlerer', 'Средний')),
    ]
  ),
  (
    'D',
    ('The control feature: ground', 'O objeto: relevo', 'Das Postenobjekt: Gelände', 'Объект: рельеф'),
    ('', '', '', ''),
    [
      CdItem('terrace', ('Terrace (poio)', 'Socalco, poio', 'Terrasse', 'Терраса')),
      CdItem('spur', ('Spur', 'Esporão', 'Sporn', 'Отрог')),
      CdItem('reentrant', ('Re-entrant (small valley)', 'Reentrância (vale pequeno)', 'Einbuchtung (kleines Tal)', 'Лощина')),
      CdItem('earthbank', ('Earth bank', 'Escarpa de terra', 'Böschung', 'Земляной обрыв')),
      CdItem('earthwall', ('Earth wall', 'Muro de terra', 'Erdwall', 'Земляной вал')),
      CdItem('gully', ('Erosion gully', 'Ravina', 'Erosionsrinne', 'Промоина')),
      CdItem('hill', ('Hill', 'Monte', 'Hügel', 'Холм')),
      CdItem('knoll', ('Knoll', 'Cabeço', 'Kuppe', 'Бугор')),
      CdItem('saddle', ('Saddle', 'Colo', 'Sattel', 'Седловина')),
      CdItem('depression', ('Depression', 'Depressão', 'Senke', 'Котловина')),
      CdItem('smalldep', ('Small depression', 'Pequena depressão', 'Kleine Senke', 'Западина')),
      CdItem('pit', ('Pit', 'Buraco', 'Grube', 'Яма')),
    ]
  ),
  (
    'D',
    ('Rock and water', 'Rochas e água', 'Fels und Wasser', 'Скалы и вода'),
    ('', '', '', ''),
    [
      CdItem('cliff', ('Cliff, rock face', 'Falésia', 'Felswand', 'Скала')),
      CdItem('boulder', ('Boulder', 'Rocha', 'Stein', 'Камень')),
      CdItem('boulders', ('Boulder cluster', 'Grupo de pedras', 'Steingruppe', 'Группа камней')),
      CdItem('boulderfield', ('Boulder field', 'Zona de pedras', 'Blockfeld', 'Каменное поле')),
      CdItem('stony', ('Stony ground', 'Terreno pedregoso', 'Steiniger Boden', 'Каменистая поверхность')),
      CdItem('barerock', ('Bare rock', 'Afloramento rochoso', 'Offener Fels', 'Скальная площадка')),
      CdItem('trench', ('Trench', 'Trincheira', 'Graben', 'Траншея')),
      CdItem('lake', ('Lake', 'Lago', 'See', 'Озеро')),
      CdItem('watercourse', ('Stream, levada, watercourse', 'Ribeira, levada, linha de água', 'Bach, Levada', 'Ручей, левада')),
      CdItem('ditch', ('Ditch, minor water channel', 'Vala', 'Wassergraben', 'Канава')),
      CdItem('marsh', ('Marsh', 'Pântano', 'Sumpf', 'Болото')),
      CdItem('well', ('Well', 'Poço', 'Brunnen', 'Колодец')),
      CdItem('spring', ('Spring', 'Nascente', 'Quelle', 'Родник')),
      CdItem('tank', ('Water tank, trough', 'Tanque, bebedouro', 'Wasserbehälter, Trog', 'Резервуар, корыто')),
    ]
  ),
  (
    'D',
    ('Vegetation', 'Vegetação', 'Vegetation', 'Растительность'),
    ('', '', '', ''),
    [
      CdItem('open', ('Open land', 'Área aberta', 'Offenes Gelände', 'Открытое место')),
      CdItem('semiopen', ('Semi-open land', 'Área semi-aberta', 'Halboffenes Gelände', 'Полуоткрытое место')),
      CdItem('clearing', ('Clearing', 'Clareira', 'Lichtung', 'Поляна')),
      CdItem('thicket', ('Thicket; in sprint also a single bush', 'Mata densa; no sprint também um arbusto', 'Dickicht; im Sprint auch ein Busch', 'Заросли; в спринте и отдельный куст')),
      CdItem('hedge', ('Hedge, line of trees', 'Sebe, fila de árvores', 'Hecke, Baumreihe', 'Живая изгородь, ряд деревьев')),
      CdItem('vegboundary', ('Vegetation boundary', 'Limite de vegetação', 'Vegetationsgrenze', 'Граница растительности')),
      CdItem('tree', ('Prominent tree', 'Árvore isolada', 'Markanter Baum', 'Отдельное дерево')),
    ]
  ),
  (
    'D',
    ('Man-made: town sprint', 'Construções: sprint urbano', 'Bauwerke: Stadtsprint', 'Постройки: городской спринт'),
    ('', '', '', ''),
    [
      CdItem('road', ('Road', 'Estrada', 'Straße', 'Дорога')),
      CdItem('path', ('Path, track', 'Caminho, carreiro', 'Weg, Pfad', 'Тропа, грунтовка')),
      CdItem('ride', ('Ride (cleared line in forest)', 'Aceiro', 'Schneise', 'Просека')),
      CdItem('bridge', ('Bridge', 'Ponte', 'Brücke', 'Мост')),
      CdItem('powerline', ('Power line', 'Linha elétrica', 'Stromleitung', 'ЛЭП')),
      CdItem('tunnel', ('Tunnel', 'Túnel', 'Tunnel', 'Тоннель')),
      CdItem('wall', ('Stone wall', 'Muro', 'Mauer', 'Каменная стена')),
      CdItem('fence', ('Fence', 'Cerca, vedação', 'Zaun', 'Забор')),
      CdItem('crossing', ('Crossing point: gate, stile, gap', 'Passagem: portão, abertura', 'Durchgang: Tor, Lücke', 'Проход: калитка, проём')),
      CdItem('building', ('Building', 'Casa, edifício', 'Gebäude', 'Здание')),
      CdItem('paved', ('Paved area: square, car park', 'Zona alcatroada: largo, parque', 'Befestigte Fläche: Platz, Parkplatz', 'Площадка с покрытием: площадь, парковка')),
      CdItem('ruin', ('Ruin', 'Ruína', 'Ruine', 'Руины')),
      CdItem('tower', ('Tower', 'Torre', 'Turm', 'Вышка')),
      CdItem('cairn', ('Boundary stone, cairn, survey point', 'Marco, marco geodésico', 'Grenzstein, Vermessungspunkt', 'Межевой камень, геопункт')),
      CdItem('monument', ('Monument, statue', 'Monumento, estátua', 'Denkmal, Statue', 'Памятник, статуя')),
      CdItem('canopy', ('Canopy, covered passage', 'Coberto, passagem coberta', 'Überdachung, Durchgang', 'Навес, крытый проход')),
      CdItem('stairway', ('Stairway', 'Escadas', 'Treppe', 'Лестница')),
      CdItem('oob', ('Out of bounds: flower bed', 'Interdito: canteiro', 'Sperrgebiet: Blumenbeet', 'Запретная зона: клумба')),
      CdItem('specialx', ('Special item X: see the event notes', 'Objeto especial X: ver as instruções', 'Spezialobjekt X: siehe Wettkampfinformation', 'Особый объект X: см. информацию к старту'),
          ('On Madeira sheets often a bench, post or bin', 'Nas provas da Madeira muitas vezes banco, poste ou caixote do lixo', 'Auf Madeira oft Bank, Pfosten oder Mülleimer', 'На Мадейре часто скамейка, столб или урна')),
      CdItem('specialo', ('Special item O: see the event notes', 'Objeto especial O: ver as instruções', 'Spezialobjekt O: siehe Wettkampfinformation', 'Особый объект O: см. информацию к старту')),
    ]
  ),
  (
    'E',
    ('Appearance', 'Aspeto', 'Aussehen', 'Особенности'),
    ('', '', '', ''),
    [
      CdItem('low', ('Low, flat', 'Baixo', 'Niedrig', 'Низкий')),
      CdItem('shallow', ('Shallow', 'Pouco fundo', 'Flach', 'Мелкий')),
      CdItem('deep', ('Deep', 'Fundo', 'Tief', 'Глубокий')),
      CdItem('overgrown', ('Overgrown', 'Com vegetação', 'Überwachsen', 'Заросший')),
      CdItem('rocky', ('Rocky, stony', 'Rochoso', 'Felsig', 'Каменистый')),
      CdItem('ruined', ('Ruined, fallen', 'Em ruínas', 'Verfallen', 'Разрушенный')),
    ]
  ),
  (
    'F',
    ('Size and combinations', 'Dimensões e combinações', 'Größe und Kombinationen', 'Размер и сочетания'),
    ('Crossing and junction need two features: one in D, the other in E. Path + path + X = two paths cross.', 'Cruzamento e junção pedem dois objetos: um em D, outro em E. Caminho + caminho + X = dois caminhos cruzam-se.', 'Kreuzung und Einmündung brauchen zwei Objekte: eins in D, eins in E. Weg + Weg + X = zwei Wege kreuzen sich.', 'Для пересечения и развилки нужны два объекта: в D и в E. Тропа + тропа + X — две тропы пересекаются.'),
    [
      CdItem('height', ('Height or depth, metres', 'Altura ou profundidade, m', 'Höhe oder Tiefe, m', 'Высота или глубина, м')),
      CdItem('size', ('Size, metres', 'Dimensões, m', 'Größe, m', 'Размер, м')),
      CdItem('xcross', ('Crossing', 'Cruzamento', 'Kreuzung', 'Пересечение')),
      CdItem('junction', ('Junction (meet or fork)', 'Junção, bifurcação', 'Einmündung, Gabelung', 'Развилка, примыкание')),
      CdItem('bend', ('Bend', 'Curva', 'Biegung', 'Изгиб, поворот')),
    ]
  ),
  (
    'G',
    ('Where the flag is', 'Onde está a baliza', 'Wo der Posten hängt', 'Где стоит призма'),
    ('Empty means the centre (for a cliff: its foot). The symbol turns to show the side: on Madeira sheets a right angle with a dot is a corner pointing NE, SE, SW or NW; a dot inside the angle is the inside corner, outside it the outside corner.', 'Vazio quer dizer o centro (numa falésia: a base). O símbolo roda para mostrar o lado: nas folhas da Madeira um ângulo reto com ponto é um canto virado a NE, SE, SO ou NO; ponto dentro do ângulo = canto interior, fora = canto exterior.', 'Leer heißt Mitte (bei einer Felswand: der Fuß). Das Zeichen dreht sich zur Seite: auf Madeira-Blättern ist ein rechter Winkel mit Punkt eine Ecke nach NO, SO, SW oder NW; Punkt im Winkel = Innenecke, außen = Außenecke.', 'Пусто — центр объекта (у скалы — подножие). Знак поворачивается в нужную сторону: на мадейрских листах прямой угол с точкой — угол, смотрящий на СВ, ЮВ, ЮЗ или СЗ; точка внутри угла — внутренний угол, снаружи — внешний.'),
    [
      CdItem('side', ('Side (here north-east side)', 'Lado (aqui nordeste)', 'Seite (hier Nordost)', 'Сторона (здесь северо-восточная)')),
      CdItem('edge', ('Edge (here south-east edge)', 'Borda (aqui sudeste)', 'Rand (hier Südost)', 'Край (здесь юго-восточный)')),
      CdItem('part', ('Part (here west part)', 'Parte (aqui oeste)', 'Teil (hier West)', 'Часть (здесь западная)')),
      CdItem('cornerIn', ('Corner, inside (here east)', 'Canto interior (aqui leste)', 'Innenecke (hier Ost)', 'Внутренний угол (здесь восточный)')),
      CdItem('cornerOut', ('Corner, outside (here south)', 'Canto exterior (aqui sul)', 'Außenecke (hier Süd)', 'Внешний угол (здесь южный)')),
      CdItem('cornerInNE', ('Corner as a right angle (north-east, inside)', 'Canto em ângulo reto (nordeste, interior)', 'Ecke als rechter Winkel (Nordost, innen)', 'Угол прямым углом (северо-восточный, внутренний)')),
      CdItem('tip', ('Tip (here south-west)', 'Ponta (aqui sudoeste)', 'Spitze (hier Südwest)', 'Острый край (здесь юго-западный)')),
      CdItem('end', ('End (here north-west end)', 'Extremidade (aqui noroeste)', 'Ende (hier Nordwest)', 'Конец (здесь северо-западный)')),
      CdItem('upperpart', ('Upper part', 'Parte superior', 'Oberer Teil', 'Верхняя часть')),
      CdItem('lowerpart', ('Lower part', 'Parte inferior', 'Unterer Teil', 'Нижняя часть')),
      CdItem('top', ('Top', 'Topo', 'Oben', 'Верх, вершина')),
      CdItem('foot', ('Foot', 'Base, pé', 'Fuß', 'Подножие')),
      CdItem('beneath', ('Beneath', 'Por baixo', 'Darunter', 'Под объектом')),
      CdItem('between', ('Between the two features in D and E', 'Entre os dois objetos de D e E', 'Zwischen den Objekten in D und E', 'Между объектами из D и E')),
    ]
  ),
  (
    'H',
    ('Other', 'Outros', 'Sonstiges', 'Прочее'),
    ('', '', '', ''),
    [
      CdItem('firstaid', ('First aid', 'Primeiros socorros', 'Erste Hilfe', 'Медпомощь')),
      CdItem('refresh', ('Refreshments', 'Abastecimento', 'Verpflegung', 'Пункт питания')),
      CdItem('manned', ('Manned control', 'Ponto com controlador', 'Besetzter Posten', 'КП с судьёй')),
    ]
  ),
];

/// A worked sheet in the style of the Madeira town races Kirill brought:
/// columns A–H, then the meaning of every row in words.
const List<(String, String, String, String, String, String, String, T4)> _sheet = [
  ('start', '', '', 'crossing', '', '', '', ('Start at the gate (crossing point)', 'Partida junto ao portão (passagem)', 'Start am Tor (Durchgang)', 'Старт у калитки (проход)')),
  ('1', '61', '', 'canopy', '', '', 'cornerInNE', ('Canopy, north-east corner, inside', 'Coberto, canto nordeste interior', 'Überdachung, Nordost-Innenecke', 'Навес, северо-восточный внутренний угол')),
  ('2', '69', '', 'cairn', '', '', 'sideSE', ('Survey stone, south-east side', 'Marco, lado sudeste', 'Vermessungsstein, Südostseite', 'Геопункт, юго-восточная сторона')),
  ('3', '74', 'n', 'tree', '', '', 'sideN', ('The northern prominent tree, north side', 'A árvore isolada mais a norte, lado norte', 'Der nördliche markante Baum, Nordseite', 'Северное из деревьев, северная сторона')),
  ('4', '82', '', 'specialx', '', '', 'sideE', ('Special item X, east side', 'Objeto especial X, lado leste', 'Spezialobjekt X, Ostseite', 'Особый объект X, восточная сторона')),
  ('5', '88', '', 'stairway', '', '', 'foot', ('Stairway, foot', 'Escadas, em baixo', 'Treppe, Fuß', 'Лестница, внизу')),
  ('6', '94', 'middle', 'tree', '', '', 'sideW', ('The middle tree, west side', 'A árvore do meio, lado oeste', 'Der mittlere Baum, Westseite', 'Среднее дерево, западная сторона')),
  ('7', '51', '', 'path', 'path', 'junction', '', ('Path junction', 'Junção de caminhos', 'Wegeinmündung', 'Развилка троп')),
  ('8', '95', '', 'path', 'watercourse', 'xcross', '', ('Path crosses the stream (levada)', 'O caminho cruza a ribeira (levada)', 'Weg kreuzt den Bach (Levada)', 'Тропа пересекает ручей (леваду)')),
  ('9', '43', '', 'path', '', 'bend', '', ('Path bend', 'Curva do caminho', 'Wegbiegung', 'Изгиб тропы')),
  ('10', '72', 'n', 'building', '', '', 'cornerOut', ('The northern building, south corner, outside', 'O edifício mais a norte, canto sul exterior', 'Das nördliche Gebäude, Süd-Außenecke', 'Северное здание, южный внешний угол')),
];

class DescriptionsTab extends StatelessWidget {
  const DescriptionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = TextStyle(fontSize: 12.5, color: context.cSubtle, height: 1.35);
    final head = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .6, color: context.cTitle);
    Widget cellText(String t, {bool bold = false}) => Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFB0B0B0), width: .7)),
          child: Text(t, style: TextStyle(color: _ink, fontSize: 12, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        );
    Widget row(List<String> r) => Row(children: [
          if (r[0] == 'start') const CdSwatch('start') else cellText(r[0], bold: true),
          cellText(r[1]),
          for (final id in r.sublist(2, 7)) CdSwatch(id),
          const CdSwatch(''),
        ]);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
      Text(
          tr((
            'Next to the map you get a sheet of little pictures, one row per control. It says exactly where the flag stands. Every symbol on the Santana, Ponta do Sol, Estreito and Ribeira Brava sheets is below.',
            'Junto ao mapa vem a sinalética: uma linha por ponto, com pequenos desenhos que dizem exatamente onde está a baliza. Todos os símbolos das folhas de Santana, Ponta do Sol, Estreito e Ribeira Brava estão abaixo.',
            'Neben der Karte bekommst du die Postenbeschreibung: eine Zeile pro Posten, kleine Bilder, die genau sagen, wo der Posten steht. Alle Zeichen der Blätter aus Santana, Ponta do Sol, Estreito und Ribeira Brava stehen unten.',
            'К карте выдают легенду: строка на каждый КП, картинки точно говорят, где стоит призма. Все значки с листов Сантаны, Понта-ду-Сол, Эштрейту и Рибейра-Бравы — ниже.'
          )),
          style: sub),
      const SizedBox(height: 14),
      Text(tr(('An example sheet, Madeira town style', 'Folha de exemplo, estilo urbano da Madeira', 'Beispielblatt im Stil der Madeira-Stadtläufe', 'Пример листа в стиле городских стартов Мадейры')).toUpperCase(), style: head),
      const SizedBox(height: 6),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [for (final l in 'ABCDEFGH'.split('')) cellText(l)]),
          for (final r in _sheet) row([r.$1, r.$2, r.$3, r.$4, r.$5, r.$6, r.$7]),
        ]),
      ),
      const SizedBox(height: 8),
      for (final r in _sheet)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text('${r.$1 == 'start' ? '▷' : r.$1}${r.$2.isEmpty ? '' : ' · ${r.$2}'} — ${tr(r.$8)}', style: const TextStyle(fontSize: 13)),
        ),
      const SizedBox(height: 10),
      Text(
          tr((
            'On a real sheet, above and below the table: the header "10 | 2,8 km | 30" is course, length and climb in metres. "– – 40 m – → △": walk 40 m from the timed start to the start triangle. "○ – – 85 m – → ◎": follow the tapes 85 m from the last control to the finish.',
            'Numa folha real, acima e abaixo da tabela: o cabeçalho «10 | 2,8 km | 30» é percurso, distância, desnível em metros. «– – 40 m – → △»: 40 m da partida cronometrada até ao triângulo. «○ – – 85 m – → ◎»: seguir as fitas 85 m do último ponto até à chegada.',
            'Auf einem echten Blatt über und unter der Tabelle: die Kopfzeile „10 | 2,8 km | 30“ ist Bahn, Länge, Steigung in Metern. „– – 40 m – → △“: 40 m vom Zeitstart zum Startdreieck. „○ – – 85 m – → ◎“: 85 m den Bändern vom letzten Posten ins Ziel folgen.',
            'На настоящем листе над и под таблицей: шапка «10 | 2,8 km | 30» — это дистанция, длина, набор высоты в метрах. «– – 40 m – → △»: от старта по времени 40 м до треугольника. «○ – – 85 m – → ◎»: от последнего КП 85 м по разметке до финиша.'
          )),
          style: sub),
      for (final (col, title, note, items) in kCdGroups) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 4),
          child: Text('$col · ${tr(title)}'.toUpperCase(), style: head),
        ),
        if (tr(note).isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(tr(note), style: sub)),
        Wrap(spacing: 10, runSpacing: 8, children: [
          for (final it in items)
            SizedBox(
              width: 160,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CdSwatch(it.id),
                const SizedBox(width: 8),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr(it.name), style: const TextStyle(fontSize: 12.5)),
                  if (it.note != null) Text(tr(it.note!), style: TextStyle(fontSize: 11, color: context.cSubtle)),
                ])),
              ]),
            ),
        ]),
      ],
      const SizedBox(height: 16),
      Text(
          tr((
            'Symbols after the IOF International Specification for Control Descriptions 2018, drawn for this app.',
            'Símbolos segundo a norma IOF de sinalética 2018, desenhados para esta aplicação.',
            'Zeichen nach der IOF-Norm für Postenbeschreibungen 2018, für diese App gezeichnet.',
            'Значки по стандарту IOF для легенд КП 2018 года, нарисованы для приложения.'
          )),
          style: TextStyle(fontSize: 11.5, color: context.cSubtle)),
    ]);
  }
}
