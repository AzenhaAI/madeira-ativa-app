import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'island_now.dart';
import 'main.dart';
import 'orienteering_cd.dart';
import 'orienteering_classes.dart';
import 'orienteering_drills.dart';
import 'orienteering_tips.dart';

/// Orienteering basics: what the map symbols mean (forest ISOM 2017 and
/// sprint ISSprOM 2019 — the common ones, drawn here from the published
/// specs, with our own one-line texts), how to read a control description,
/// how a race works on Madeira, and a compass.
///
/// Kirill, 21.10.2026: a chip at the bottom of Home, an orange shelf on
/// Events when the Orient filter is on, a button on every orienteering event.
/// Not only the compass: explain the symbols (stairs and the rest).

typedef T4 = (String en, String pt, String de, String ru);

String tr(T4 x) => switch (locale.value) {
      'pt' => x.$2,
      'de' => x.$3,
      'ru' => x.$4,
      _ => x.$1,
    };

/// Orienteering events, the same heuristic as the Events tab.
bool isOrienteeringEvent(AtivaEvent e) =>
    e.type == 'orienteering' || e.name.startsWith('Orientação') || e.url.contains('aoram.pt');

void openOrienteering(BuildContext context, {int tab = 0}) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrienteeringPage(initialTab: tab)));

const T4 kOrientTitle = ('Orienteering basics', 'Orientação: o básico', 'Orientierungslauf: Grundlagen', 'Ориентирование: основы');

class OrienteeringPage extends StatelessWidget {
  const OrienteeringPage({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr(kOrientTitle)),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: context.cTitle,
            indicatorColor: kGreen,
            tabs: [
              Tab(text: tr(('Map symbols', 'Símbolos', 'Kartenzeichen', 'Знаки карты'))),
              Tab(text: tr(('Control descriptions', 'Sinalética', 'Postenbeschreibung', 'Легенды КП'))),
              Tab(text: tr(('Classes & entry', 'Escalões e inscrição', 'Kategorien & Anmeldung', 'Группы и заявка'))),
              Tab(text: tr(('How a race works', 'Como é uma prova', 'So läuft ein OL-Wettkampf', 'Как проходит старт'))),
              Tab(text: tr(('Club tips', 'Dicas', 'Tipps', 'Советы'))),
              Tab(text: tr(('Drills', 'Treino', 'Übungen', 'Тренировка'))),
              Tab(text: tr(('Compass', 'Bússola', 'Kompass', 'Компас'))),
            ],
          ),
        ),
        body: const TabBarView(children: [_SymbolsTab(), DescriptionsTab(), ClassesTab(), _RaceTab(), TipsTab(), DrillsTab(), _CompassTab()]),
      ),
    );
  }
}

// ----------------------------------------------------------- map symbols

const _brown = Color(0xFFC0651F);
const _black = Color(0xFF1A1A1A);
const _blue = Color(0xFF00A0E0);
const _blueLight = Color(0xFF8FD3F0);
const _yellow = Color(0xFFFFC20E);
const _yellowLight = Color(0xFFFFE08A);
const _green1 = Color(0xFFC9E7B2);
const _green2 = Color(0xFF8CC86E);
const _green3 = Color(0xFF3A9B3A);
const _olive = Color(0xFF9DA02C);
const _grey = Color(0xFFAAAAAA);
const _paved = Color(0xFFF2D6B3);
const _purple = Color(0xFFC0249E);

typedef Draw = void Function(Canvas c, Size s);

class Sym {
  const Sym(this.code, this.name, this.hint, this.draw);
  final String code;
  final T4 name;
  final T4 hint;
  final Draw draw;
}

Paint _st(Color c, double w) => Paint()
  ..color = c
  ..strokeWidth = w
  ..style = PaintingStyle.stroke;
Paint _fi(Color c) => Paint()..color = c;

Path _wave(Size s, [double dy = 0]) => Path()
  ..moveTo(6, s.height * .62 + dy)
  ..cubicTo(s.width * .35, s.height * .2 + dy, s.width * .6, s.height * .85 + dy, s.width - 6, s.height * .38 + dy);

void _dashPath(Canvas c, Path p, Paint paint, double on, double off) {
  for (final m in p.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      c.drawPath(m.extractPath(d, math.min(d + on, m.length)), paint);
      d += on + off;
    }
  }
}

void _ticks(Canvas c, Path p, Paint paint, double every, double len, {bool both = false}) {
  for (final m in p.computeMetrics()) {
    for (var d = every / 2; d < m.length; d += every) {
      final t = m.getTangentForOffset(d)!;
      final n = Offset(-t.vector.dy, t.vector.dx);
      c.drawLine(t.position, t.position + n * len, paint);
      if (both) c.drawLine(t.position, t.position - n * len, paint);
    }
  }
}

Offset _mid(Size s) => Offset(s.width / 2, s.height / 2);
Path _line(Size s) => Path()
  ..moveTo(6, s.height / 2)
  ..lineTo(s.width - 6, s.height / 2);
Rect _area(Size s) => Rect.fromLTWH(8, 7, s.width - 16, s.height - 14);

void _scatter(Canvas c, Size s, Paint p, double r, {int n = 9, int seed = 3}) {
  final rnd = math.Random(seed);
  for (var i = 0; i < n; i++) {
    c.drawCircle(Offset(10 + rnd.nextDouble() * (s.width - 20), 9 + rnd.nextDouble() * (s.height - 18)), r, p);
  }
}

void _tri(Canvas c, Offset o, double r, Paint p) {
  c.drawPath(
      Path()
        ..moveTo(o.dx, o.dy - r)
        ..lineTo(o.dx + r * .9, o.dy + r * .6)
        ..lineTo(o.dx - r * .9, o.dy + r * .6)
        ..close(),
      p);
}

void _x(Canvas c, Offset o, double r, Paint p) {
  c.drawLine(o + Offset(-r, -r), o + Offset(r, r), p);
  c.drawLine(o + Offset(-r, r), o + Offset(r, -r), p);
}

void _crossing(Canvas c, Size s, Color col) {
  final p = _st(col, 2);
  final m = _mid(s);
  c.drawArc(Rect.fromCenter(center: m - const Offset(9, 0), width: 14, height: 22), -math.pi / 3, 2 * math.pi / 3, false, p);
  c.drawArc(Rect.fromCenter(center: m + const Offset(9, 0), width: 14, height: 22), math.pi - math.pi / 3, 2 * math.pi / 3, false, p);
}

final List<(T4, List<Sym>)> kSymbolGroups = [
  (
    ('Landforms (brown)', 'Relevo (castanho)', 'Geländeformen (braun)', 'Рельеф (коричневый)'),
    [
      Sym('101', ('Contour', 'Curva de nível', 'Höhenlinie', 'Горизонталь'),
          ('Line of equal height, usually 5 m apart', 'Linha da mesma altitude, em geral a cada 5 m', 'Linie gleicher Höhe, meist alle 5 m', 'Линия равной высоты, обычно через 5 м'),
          (c, s) => c.drawPath(_wave(s), _st(_brown, 1.4))),
      Sym('102', ('Index contour', 'Curva mestra', 'Zählkurve', 'Утолщённая горизонталь'),
          ('Every fifth contour, drawn thicker', 'Cada quinta curva, mais grossa', 'Jede fünfte Höhenlinie, dicker', 'Каждая пятая горизонталь, толще'),
          (c, s) => c.drawPath(_wave(s), _st(_brown, 2.8))),
      Sym('103', ('Form line', 'Curva auxiliar', 'Hilfshöhenlinie', 'Полугоризонталь'),
          ('Half a contour: shows a small shape', 'Meia curva: mostra uma forma pequena', 'Halbe Stufe: zeigt kleine Formen', 'Половина сечения: мелкие формы'),
          (c, s) => _dashPath(c, _wave(s), _st(_brown, 1.4), 7, 3)),
      Sym('', ('Slope line', 'Indicador de declive', 'Gefällsstrich', 'Бергштрих'),
          ('Tick on a contour, points downhill', 'Traço na curva, aponta para baixo', 'Strich an der Höhenlinie, zeigt bergab', 'Штрих на горизонтали, смотрит под уклон'),
          (c, s) {
            c.drawPath(_wave(s), _st(_brown, 1.4));
            final t = _wave(s).computeMetrics().first.getTangentForOffset(26)!;
            c.drawLine(t.position, t.position + Offset(-t.vector.dy, t.vector.dx) * 7, _st(_brown, 1.4));
          }),
      Sym('104', ('Earth bank', 'Escarpa de terra', 'Böschung', 'Земляной обрыв'),
          ('Steep earth step, ticks point down', 'Degrau de terra, traços para baixo', 'Steile Erdstufe, Striche zeigen hinab', 'Крутой уступ, штрихи вниз'),
          (c, s) {
            c.drawPath(_line(s), _st(_brown, 1.8));
            _ticks(c, _line(s), _st(_brown, 1.2), 7, 6);
          }),
      Sym('107', ('Erosion gully', 'Ravina', 'Erosionsrinne', 'Промоина'),
          ('Dry ditch cut by water', 'Vala seca aberta pela água', 'Vom Wasser ausgewaschener Graben', 'Сухая канава, промытая водой'),
          (c, s) => c.drawLine(Offset(12, s.height * .7), Offset(s.width - 12, s.height * .3), _st(_brown, 3)..strokeCap = StrokeCap.round)),
      Sym('109', ('Small knoll', 'Pequeno cabeço', 'Kuppe', 'Бугор'),
          ('Hill too small for a contour', 'Elevação pequena demais para curva', 'Hügel, zu klein für eine Höhenlinie', 'Холмик меньше сечения рельефа'),
          (c, s) => c.drawCircle(_mid(s), 3.5, _fi(_brown))),
      Sym('110', ('Elongated knoll', 'Cabeço alongado', 'Längliche Kuppe', 'Вытянутый бугор'),
          ('Small long hump', 'Pequena lomba comprida', 'Kleiner länglicher Rücken', 'Небольшая продолговатая горка'),
          (c, s) => c.drawOval(Rect.fromCenter(center: _mid(s), width: 14, height: 6), _fi(_brown))),
      Sym('111', ('Small depression', 'Pequena depressão', 'Kleine Senke', 'Западина'),
          ('Shallow hollow without steep sides', 'Concavidade suave', 'Flache Mulde ohne steile Ränder', 'Неглубокое понижение'),
          (c, s) => c.drawArc(Rect.fromCenter(center: _mid(s) - const Offset(0, 4), width: 14, height: 14), 0, math.pi, false, _st(_brown, 1.8))),
      Sym('112', ('Pit', 'Buraco', 'Grube', 'Яма'),
          ('Hole with steep sides', 'Buraco de lados íngremes', 'Grube mit steilen Rändern', 'Яма с крутыми краями'),
          (c, s) {
            final m = _mid(s);
            c.drawPath(Path()..moveTo(m.dx - 7, m.dy - 6)..lineTo(m.dx, m.dy + 6)..lineTo(m.dx + 7, m.dy - 6), _st(_brown, 1.8));
          }),
      Sym('113', ('Broken ground', 'Terreno irregular', 'Unruhiger Boden', 'Неровная поверхность'),
          ('Many small pits and humps: slower', 'Muitas covas e lombas: mais lento', 'Viele kleine Löcher und Buckel: langsamer', 'Много мелких ям и бугров: медленнее'),
          (c, s) => _scatter(c, s, _fi(_brown), 1.6, n: 12)),
      Sym('115', ('Special land feature', 'Objeto de relevo especial', 'Besondere Geländeform', 'Особый объект рельефа'),
          ('Explained in the map legend', 'Explicado na legenda do mapa', 'In der Kartenlegende erklärt', 'Пояснён в легенде карты'),
          (c, s) => _x(c, _mid(s), 5, _st(_brown, 1.8))),
    ]
  ),
  (
    ('Rock and boulders (black)', 'Rochas e pedras (preto)', 'Fels und Steine (schwarz)', 'Скалы и камни (чёрный)'),
    [
      Sym('201', ('Impassable cliff', 'Falésia intransponível', 'Unpassierbare Felswand', 'Непреодолимая скала'),
          ('Never cross it: dangerous', 'Nunca atravessar: perigoso', 'Nie überqueren: gefährlich', 'Не пересекать: опасно'),
          (c, s) {
            c.drawPath(_line(s), _st(_black, 3.2));
            _ticks(c, _line(s), _st(_black, 1.4), 7, 6);
          }),
      Sym('202', ('Cliff', 'Falésia', 'Felswand', 'Скала'),
          ('Rock face you can cross with care', 'Rocha que se passa com cuidado', 'Felsstufe, vorsichtig passierbar', 'Скальный уступ, преодолим осторожно'),
          (c, s) {
            c.drawPath(_line(s), _st(_black, 1.6));
            _ticks(c, _line(s), _st(_black, 1.2), 7, 5);
          }),
      Sym('203', ('Rocky pit', 'Cova rochosa', 'Felsloch', 'Каменная яма'),
          ('Hole in rock', 'Buraco na rocha', 'Loch im Fels', 'Яма в скале'),
          (c, s) {
            final m = _mid(s);
            c.drawPath(Path()..moveTo(m.dx - 7, m.dy - 6)..lineTo(m.dx, m.dy + 6)..lineTo(m.dx + 7, m.dy - 6), _st(_black, 1.8));
          }),
      Sym('204', ('Boulder', 'Rocha', 'Stein', 'Камень'),
          ('Rock taller than about 1 m', 'Pedra com mais de cerca de 1 m', 'Fels höher als etwa 1 m', 'Камень выше примерно 1 м'),
          (c, s) => c.drawCircle(_mid(s), 2.8, _fi(_black))),
      Sym('205', ('Large boulder', 'Pedra grande', 'Großer Felsblock', 'Большой камень'),
          ('Very big rock, a clear landmark', 'Rocha muito grande, bom ponto de referência', 'Sehr großer Fels, klarer Anhaltspunkt', 'Очень большой камень, явный ориентир'),
          (c, s) => c.drawCircle(_mid(s), 4.6, _fi(_black))),
      Sym('208', ('Boulder field', 'Zona de pedras', 'Blockfeld', 'Каменное поле'),
          ('Many boulders together: slow', 'Muitas pedras juntas: lento', 'Viele Blöcke beisammen: langsam', 'Россыпь камней: медленно'),
          (c, s) {
            for (final o in [const Offset(-12, -4), const Offset(0, 5), const Offset(12, -3), const Offset(-4, -9), const Offset(8, 9)]) {
              _tri(c, _mid(s) + o, 4, _fi(_black));
            }
          }),
      Sym('210', ('Stony ground', 'Terreno pedregoso', 'Steiniger Boden', 'Каменистая поверхность'),
          ('Loose stones: watch your ankles', 'Pedras soltas: cuidado com os tornozelos', 'Lose Steine: Knöchel beachten', 'Мелкие камни: береги щиколотки'),
          (c, s) => _scatter(c, s, _fi(_black), 1.1, n: 14, seed: 7)),
      Sym('214', ('Bare rock', 'Afloramento rochoso', 'Offener Fels', 'Открытая скала'),
          ('Rock surface without soil', 'Rocha sem terra', 'Fels ohne Erdschicht', 'Скальная поверхность без почвы'),
          (c, s) => c.drawRect(_area(s), _fi(_grey))),
    ]
  ),
  (
    ('Water and marsh (blue)', 'Água e pântano (azul)', 'Gewässer und Sumpf (blau)', 'Вода и болото (синий)'),
    [
      Sym('301', ('Uncrossable water', 'Água intransponível', 'Unpassierbares Gewässer', 'Непреодолимый водоём'),
          ('Black edge: you may not cross', 'Contorno preto: proibido atravessar', 'Schwarzer Rand: nicht überqueren', 'Чёрная кромка: пересекать нельзя'),
          (c, s) {
            c.drawRect(_area(s), _fi(_blue));
            c.drawRect(_area(s), _st(_black, 2));
          }),
      Sym('302', ('Shallow water', 'Água pouco funda', 'Seichtes Gewässer', 'Мелкий водоём'),
          ('You can wade through', 'Pode-se atravessar a vau', 'Durchwatbar', 'Можно перейти вброд'),
          (c, s) {
            c.drawRect(_area(s), _fi(_blueLight));
            _dashPath(c, Path()..addRect(_area(s)), _st(_blue, 1.4), 5, 3);
          }),
      Sym('304', ('Crossable watercourse', 'Linha de água', 'Bach, überquerbar', 'Ручей'),
          ('Stream or levada you can cross', 'Ribeira ou levada que se atravessa', 'Bach oder Levada, überquerbar', 'Ручей или левада, можно пересечь'),
          (c, s) => c.drawPath(_wave(s), _st(_blue, 2.2))),
      Sym('305', ('Small watercourse', 'Pequena linha de água', 'Kleiner Bach', 'Маленький ручей'),
          ('Narrow ditch with water', 'Vala estreita com água', 'Schmaler Graben mit Wasser', 'Узкая канава с водой'),
          (c, s) => c.drawPath(_wave(s), _st(_blue, 1.1))),
      Sym('308', ('Marsh', 'Pântano', 'Sumpf', 'Болото'),
          ('Wet ground: slow and muddy', 'Terreno encharcado: lento', 'Nasser Boden: langsam', 'Сырая земля: медленно'),
          (c, s) {
            for (var y = 12.0; y < s.height - 8; y += 6) {
              _dashPath(c, Path()..moveTo(10, y)..lineTo(s.width - 10, y), _st(_blue, 1.3), 8, 4);
            }
          }),
      Sym('311', ('Well, fountain', 'Poço, fonte', 'Brunnen', 'Колодец, фонтан'),
          ('Built water point', 'Ponto de água construído', 'Gebaute Wasserstelle', 'Обустроенный источник воды'),
          (c, s) => c.drawCircle(_mid(s), 5, _st(_blue, 1.8))),
      Sym('312', ('Spring', 'Nascente', 'Quelle', 'Родник'),
          ('Where a stream starts', 'Onde nasce a água', 'Wo ein Bach entspringt', 'Начало ручья'),
          (c, s) {
            final m = _mid(s);
            c.drawArc(Rect.fromCenter(center: m, width: 12, height: 12), -math.pi / 2, math.pi, false, _st(_blue, 1.8));
            c.drawLine(m, m + const Offset(14, 0), _st(_blue, 1.8));
          }),
      Sym('313', ('Special water feature', 'Objeto de água especial', 'Besonderes Gewässerobjekt', 'Особый водный объект'),
          ('Explained in the map legend', 'Explicado na legenda do mapa', 'In der Kartenlegende erklärt', 'Пояснён в легенде карты'),
          (c, s) => _x(c, _mid(s), 5, _st(_blue, 1.8))),
    ]
  ),
  (
    ('Vegetation (yellow, white, green)', 'Vegetação (amarelo, branco, verde)', 'Vegetation (gelb, weiß, grün)', 'Растительность (жёлтый, белый, зелёный)'),
    [
      Sym('401', ('Open land', 'Área aberta', 'Offenes Gelände', 'Открытая местность'),
          ('Meadow or field: fast', 'Prado ou campo: rápido', 'Wiese oder Feld: schnell', 'Луг или поле: быстро'),
          (c, s) => c.drawRect(_area(s), _fi(_yellow))),
      Sym('402', ('Semi-open land', 'Área semi-aberta', 'Halboffenes Gelände', 'Открытая местность с отдельными деревьями'),
          ('Open, with scattered trees', 'Aberto, com árvores dispersas', 'Offen, vereinzelte Bäume', 'Открыто, редкие деревья'),
          (c, s) {
            c.drawRect(_area(s), _fi(_yellow));
            _scatter(c, s, _fi(Colors.white), 3, n: 6, seed: 11);
          }),
      Sym('403', ('Rough open land', 'Aberto com mato', 'Raues offenes Gelände', 'Полуоткрытая местность'),
          ('Heather, long grass: slower', 'Urze, erva alta: mais lento', 'Heide, hohes Gras: langsamer', 'Вереск, высокая трава: медленнее'),
          (c, s) => c.drawRect(_area(s), _fi(_yellowLight))),
      Sym('405', ('Forest', 'Floresta', 'Wald', 'Лес'),
          ('White = forest you can run through', 'Branco = floresta onde se corre bem', 'Weiß = gut belaufbarer Wald', 'Белый = лес, где хорошо бежать'),
          (c, s) => c.drawRect(_area(s), _st(_grey, 1))),
      Sym('406', ('Slow running', 'Corrida lenta', 'Langsam belaufbar', 'Медленный бег'),
          ('Light green: about 60–80% of speed', 'Verde claro: cerca de 60–80% da velocidade', 'Hellgrün: etwa 60–80 % Tempo', 'Светло-зелёный: 60–80% скорости'),
          (c, s) => c.drawRect(_area(s), _fi(_green1))),
      Sym('408', ('Walk', 'Andar', 'Gehen', 'Шагом'),
          ('Mid green: you can only walk', 'Verde médio: só a andar', 'Mittelgrün: nur gehen', 'Средний зелёный: только шагом'),
          (c, s) => c.drawRect(_area(s), _fi(_green2))),
      Sym('410', ('Fight', 'Passagem difícil', 'Dickicht', 'Продирание'),
          ('Dark green: go round. On sprint maps: no entry', 'Verde escuro: contornar. No sprint: proibido', 'Dunkelgrün: umlaufen. Im Sprint: verboten', 'Тёмно-зелёный: обходи. В спринте: нельзя'),
          (c, s) => c.drawRect(_area(s), _fi(_green3))),
      Sym('407', ('Undergrowth', 'Vegetação rasteira', 'Unterholz', 'Подлесок'),
          ('Stripes: low bushes slow you down', 'Riscas: arbustos baixos atrasam', 'Streifen: niedriges Gestrüpp bremst', 'Полосы: низкий кустарник тормозит'),
          (c, s) {
            for (var x = 12.0; x < s.width - 8; x += 7) {
              c.drawLine(Offset(x, 8), Offset(x, s.height - 8), _st(_green2, 2.4));
            }
          }),
      Sym('413', ('Orchard', 'Pomar', 'Obstgarten', 'Сад'),
          ('Trees in rows', 'Árvores em filas', 'Bäume in Reihen', 'Деревья рядами'),
          (c, s) {
            c.drawRect(_area(s), _fi(_yellow));
            for (var y = 13.0; y < s.height - 8; y += 9) {
              for (var x = 14.0; x < s.width - 8; x += 9) {
                c.drawCircle(Offset(x, y), 2.4, _fi(_green3));
              }
            }
          }),
      Sym('414', ('Vineyard', 'Vinha', 'Weinberg', 'Виноградник'),
          ('Rows of vines on terraces: run along them', 'Filas de vinha em poios: corre ao longo delas', 'Rebzeilen auf Terrassen: entlang laufen', 'Ряды лозы на террасах: беги вдоль'),
          (c, s) {
            c.drawRect(_area(s), _fi(_yellow));
            for (var x = 13.0; x < s.width - 8; x += 7) {
              _dashPath(c, Path()..moveTo(x, 9)..lineTo(x, s.height - 9), _st(_green3, 1.8), 4, 3);
            }
          }),
      Sym('', ('Hedge', 'Sebe', 'Hecke', 'Живая изгородь'),
          ('Line of dense bushes: usually cannot pass', 'Linha de arbustos densos: em geral não se passa', 'Dichte Buschreihe: meist nicht passierbar', 'Ряд плотных кустов: обычно не пройти'),
          (c, s) => c.drawPath(_line(s), _st(_green3, 4)..strokeCap = StrokeCap.round)),
      Sym('412', ('Cultivated land', 'Terreno cultivado', 'Kulturland', 'Сельхозугодья'),
          ('Crops: usually do not cross', 'Culturas: em geral não atravessar', 'Feldfrüchte: meist nicht betreten', 'Посевы: обычно не пересекать'),
          (c, s) {
            c.drawRect(_area(s), _fi(_yellow));
            _scatter(c, s, _fi(_black), 1, n: 14, seed: 5);
          }),
      Sym('416', ('Vegetation boundary', 'Limite de vegetação', 'Vegetationsgrenze', 'Граница растительности'),
          ('Clear edge, e.g. forest to field', 'Limite nítido, p. ex. mata e campo', 'Deutliche Grenze, z. B. Wald/Feld', 'Чёткая граница, напр. лес/поле'),
          (c, s) {
            for (var x = 8.0; x < s.width - 6; x += 5) {
              c.drawCircle(Offset(x, s.height / 2), 1.2, _fi(_black));
            }
          }),
      Sym('417', ('Prominent tree', 'Árvore notável', 'Markanter Baum', 'Отдельное дерево'),
          ('A tree you will notice', 'Árvore que se destaca', 'Auffälliger Baum', 'Заметное дерево'),
          (c, s) => c.drawCircle(_mid(s), 5.5, _st(_green3, 2))),
      Sym('418', ('Prominent bush', 'Arbusto notável', 'Markanter Busch', 'Отдельный куст'),
          ('A bush you will notice', 'Arbusto que se destaca', 'Auffälliger Busch', 'Заметный куст'),
          (c, s) => c.drawCircle(_mid(s), 3, _fi(_green3))),
    ]
  ),
  (
    ('Man-made features and sprint (black, grey, olive)', 'Construções e sprint (preto, cinza, oliva)', 'Bauwerke und Sprint (schwarz, grau, oliv)', 'Постройки и спринт (чёрный, серый, оливковый)'),
    [
      Sym('501', ('Paved area', 'Alcatrão, área pavimentada', 'Befestigte Fläche', 'Площадка с покрытием'),
          ('Square, car park, asphalt', 'Praça, parque, asfalto', 'Platz, Parkplatz, Asphalt', 'Площадь, парковка, асфальт'),
          (c, s) {
            c.drawRect(_area(s), _fi(_paved));
            c.drawRect(_area(s), _st(_black, .8));
          }),
      Sym('502', ('Wide road', 'Estrada larga', 'Breite Straße', 'Широкая дорога'),
          ('Two black edges', 'Dois limites pretos', 'Zwei schwarze Ränder', 'Две чёрные кромки'),
          (c, s) {
            final m = s.height / 2;
            c.drawRect(Rect.fromLTRB(6, m - 5, s.width - 6, m + 5), _fi(_paved));
            c.drawLine(Offset(6, m - 5), Offset(s.width - 6, m - 5), _st(_black, 1.2));
            c.drawLine(Offset(6, m + 5), Offset(s.width - 6, m + 5), _st(_black, 1.2));
          }),
      Sym('504', ('Vehicle track', 'Caminho de terra', 'Fahrweg', 'Грунтовая дорога'),
          ('Dirt road for cars', 'Estradão para carros', 'Unbefestigter Weg für Autos', 'Грунтовка для машин'),
          (c, s) => _dashPath(c, _line(s), _st(_black, 2.2), 12, 3)),
      Sym('505', ('Footpath', 'Caminho, carreiro', 'Pfad', 'Тропа'),
          ('Clear path', 'Trilho bem visível', 'Deutlicher Pfad', 'Хорошо заметная тропа'),
          (c, s) => _dashPath(c, _line(s), _st(_black, 1.5), 7, 3)),
      Sym('506', ('Small path', 'Vereda', 'Kleiner Pfad', 'Малая тропа'),
          ('Faint path, easy to lose', 'Vereda ténue, fácil de perder', 'Schwacher Pfad, leicht zu verlieren', 'Слабая тропа, легко потерять'),
          (c, s) => _dashPath(c, _line(s), _st(_black, 1), 4, 3)),
      Sym('509', ('Railway', 'Via férrea', 'Eisenbahn', 'Железная дорога'),
          ('Usually forbidden to cross', 'Em geral proibido atravessar', 'Meist verboten zu queren', 'Обычно пересекать нельзя'),
          (c, s) {
            c.drawPath(_line(s), _st(_black, 2.4));
            _ticks(c, _line(s), _st(_black, 1.2), 8, 4, both: true);
          }),
      Sym('510', ('Power line', 'Linha elétrica', 'Stromleitung', 'ЛЭП'),
          ('A good line to follow', 'Boa linha para seguir', 'Gute Leitlinie', 'Хороший ориентир-линия'),
          (c, s) {
            c.drawPath(_line(s), _st(_black, .9));
            for (var x = 14.0; x < s.width - 8; x += 16) {
              c.drawLine(Offset(x, s.height / 2 - 4), Offset(x, s.height / 2 + 4), _st(_black, 1.4));
            }
          }),
      Sym('513', ('Wall', 'Muro transponível', 'Mauer', 'Стена'),
          ('Low wall you may cross', 'Muro baixo que se pode passar', 'Niedrige, passierbare Mauer', 'Низкая стенка, можно перелезть'),
          (c, s) => c.drawPath(_line(s), _st(_black, 1.6))),
      Sym('515', ('Impassable wall', 'Muro intransponível', 'Unpassierbare Mauer', 'Непреодолимая стена'),
          ('Thick line: forbidden to cross', 'Linha grossa: proibido passar', 'Dicke Linie: nicht überqueren', 'Толстая линия: пересекать нельзя'),
          (c, s) => c.drawPath(_line(s), _st(_black, 3.4))),
      Sym('516', ('Fence', 'Cerca transponível', 'Zaun', 'Забор'),
          ('Fence you may climb', 'Vedação que se pode transpor', 'Überkletterbarer Zaun', 'Забор, можно перелезть'),
          (c, s) {
            c.drawPath(_line(s), _st(_black, 1.2));
            _ticks(c, _line(s), _st(_black, 1.2), 9, 5);
          }),
      Sym('518', ('Impassable fence', 'Cerca intransponível', 'Unpassierbarer Zaun', 'Непреодолимый забор'),
          ('Forbidden to cross', 'Proibido transpor', 'Nicht überqueren', 'Пересекать нельзя'),
          (c, s) {
            c.drawPath(_line(s), _st(_black, 2.2));
            _ticks(c, _line(s), _st(_black, 1.4), 7, 5, both: true);
          }),
      Sym('519', ('Crossing point', 'Passagem', 'Durchgang', 'Проход'),
          ('Gate or gap in a wall or fence', 'Portão ou abertura', 'Tor oder Lücke', 'Калитка или проём'),
          (c, s) => _crossing(c, s, _black)),
      Sym('520', ('Private area', 'Zona privada', 'Privatgelände', 'Частная территория'),
          ('Olive: gardens, private land, no entry', 'Oliva: jardins, privado, proibido', 'Oliv: Gärten, Privatgrund, verboten', 'Оливковый: сады, частная земля, нельзя'),
          (c, s) => c.drawRect(_area(s), _fi(_olive))),
      Sym('521', ('Building', 'Casa', 'Gebäude', 'Здание'),
          ('You cannot pass through', 'Não se atravessa', 'Nicht durchlaufbar', 'Насквозь не пройти'),
          (c, s) {
            final r = Rect.fromCenter(center: _mid(s), width: 30, height: 20);
            c.drawRect(r, _fi(const Color(0xFF6A6A6A)));
            c.drawRect(r, _st(_black, 1.4));
          }),
      Sym('522', ('Canopy, passage', 'Coberto', 'Überdachung, Durchgang', 'Навес, проход'),
          ('Light grey: you can run under it', 'Cinza claro: pode-se passar por baixo', 'Hellgrau: darunter laufen erlaubt', 'Светло-серый: можно пробежать под ним'),
          (c, s) {
            final r = Rect.fromCenter(center: _mid(s), width: 30, height: 20);
            c.drawRect(r, _fi(const Color(0xFFCFCFCF)));
            c.drawRect(r, _st(_black, 1));
          }),
      Sym('532', ('Stairway', 'Escadas', 'Treppe', 'Лестница'),
          ('Steps; the long lines are its sides', 'Degraus; as linhas longas são os lados', 'Stufen; die langen Linien sind die Ränder', 'Ступени; длинные линии — края'),
          (c, s) {
            final m = _mid(s);
            final r = Rect.fromCenter(center: m, width: 34, height: 14);
            c.drawLine(r.topLeft, r.topRight, _st(_black, 1.2));
            c.drawLine(r.bottomLeft, r.bottomRight, _st(_black, 1.2));
            for (var x = r.left + 3; x <= r.right; x += 5) {
              c.drawLine(Offset(x, r.top), Offset(x, r.bottom), _st(_black, 1));
            }
          }),
      Sym('', ('Tunnel', 'Túnel', 'Tunnel', 'Тоннель'),
          ('A way under a road or building', 'Passagem por baixo de estrada ou casa', 'Weg unter Straße oder Gebäude', 'Проход под дорогой или домом'),
          (c, s) {
            final r = Rect.fromCenter(center: _mid(s), width: 34, height: 12);
            c.drawRect(r, _fi(const Color(0xFFD9C3A0)));
            _dashPath(c, Path()..moveTo(r.left, r.top)..lineTo(r.right, r.top), _st(_black, 1.4), 4, 2);
            _dashPath(c, Path()..moveTo(r.left, r.bottom)..lineTo(r.right, r.bottom), _st(_black, 1.4), 4, 2);
          }),
      Sym('524', ('High tower', 'Torre grande', 'Hoher Turm', 'Высокая башня'),
          ('Seen from far: a good landmark', 'Vê-se de longe: boa referência', 'Weit sichtbar: guter Anhaltspunkt', 'Видна издалека: хороший ориентир'),
          (c, s) {
            final m = _mid(s);
            c.drawCircle(m, 3.2, _fi(_black));
            for (final d in [const Offset(0, -9), const Offset(0, 9), const Offset(-9, 0), const Offset(9, 0)]) {
              c.drawLine(m, m + d, _st(_black, 1.6));
            }
          }),
      Sym('525', ('Small tower', 'Torre pequena', 'Kleiner Turm', 'Малая вышка'),
          ('Hunting stand, small mast', 'Posto de caça, pequeno mastro', 'Hochsitz, kleiner Mast', 'Охотничья вышка, мачта'),
          (c, s) {
            final m = _mid(s);
            c.drawLine(m + const Offset(-7, -8), m + const Offset(7, -8), _st(_black, 2));
            c.drawLine(m + const Offset(0, -8), m + const Offset(0, 9), _st(_black, 2));
          }),
      Sym('531', ('Special man-made feature', 'Objeto artificial especial', 'Besonderes Bauwerk', 'Особый искусственный объект'),
          ('Explained in the map legend', 'Explicado na legenda do mapa', 'In der Kartenlegende erklärt', 'Пояснён в легенде карты'),
          (c, s) => _x(c, _mid(s), 5, _st(_black, 1.8))),
    ]
  ),
  (
    ('Special features and map lines', 'Elementos especiais e linhas do mapa', 'Sonderzeichen und Kartenlinien', 'Особые знаки и линии карты'),
    [
      Sym('', ('Special features', 'Elementos especiais', 'Sonderzeichen', 'Особые объекты'),
          ('Brown △ landform, green × vegetation, black ×/○ man-made, blue □/× water: the map legend says what', 'Triângulo castanho relevo, × verde vegetação, ×/○ preto artificial, □/× azul água: a legenda diz o quê', 'Braunes △ Gelände, grünes × Vegetation, schwarzes ×/○ Bauwerk, blaues □/× Wasser: die Legende sagt was', 'Коричневый △ — рельеф, зелёный × — растительность, чёрные ×/○ — постройки, синие □/× — вода: что именно, скажет легенда'),
          (c, s) {
            final m = _mid(s);
            _tri(c, m + const Offset(-16, -5), 5, _st(_brown, 1.6));
            _x(c, m + const Offset(-3, -5), 4, _st(_green3, 1.8));
            c.drawCircle(m + const Offset(10, -5), 3.6, _st(_black, 1.6));
            c.drawRect(Rect.fromCenter(center: m + const Offset(-8, 8), width: 7, height: 7), _st(_blue, 1.6));
            _x(c, m + const Offset(6, 8), 4, _st(_blue, 1.6));
          }),
      Sym('601', ('Magnetic north lines', 'Linhas do norte magnético', 'Nordlinien', 'Линии магнитного севера'),
          ('Blue or black lines; the top of the map is magnetic north', 'Linhas azuis ou pretas; o topo do mapa é o norte magnético', 'Blaue oder schwarze Linien; oben ist magnetisch Nord', 'Синие или чёрные линии; верх карты — магнитный север'),
          (c, s) {
            for (final x in [16.0, 32.0, 48.0]) {
              c.drawLine(Offset(x, 6), Offset(x, s.height - 6), _st(_blue, 1.2));
            }
          }),
      Sym('714', ('Dangerous or forbidden area', 'Zona perigosa ou proibida', 'Gefährliches oder verbotenes Gebiet', 'Опасная или запретная зона'),
          ('Red-purple cross-hatching, often a busy road: do not cross', 'Grelha vermelha-roxa, muitas vezes estrada com trânsito: não atravessar', 'Rot-violettes Gitter, oft eine befahrene Straße: nicht queren', 'Красно-пурпурная сетка, часто оживлённая дорога: не пересекать'),
          (c, s) {
            final r = _area(s);
            c.save();
            c.clipRect(r);
            for (var k = -40.0; k < 80; k += 7) {
              c.drawLine(Offset(r.left + k, r.top), Offset(r.left + k + 30, r.bottom), _st(_purple, 1.2));
              c.drawLine(Offset(r.left + k + 30, r.top), Offset(r.left + k, r.bottom), _st(_purple, 1.2));
            }
            c.restore();
          }),
    ]
  ),
  (
    ('Your course (purple)', 'O teu percurso (roxo)', 'Deine Bahn (violett)', 'Твоя дистанция (пурпурный)'),
    [
      Sym('701', ('Start', 'Partida', 'Start', 'Старт'),
          ('Triangle: where you begin', 'Triângulo: onde começas', 'Dreieck: hier beginnst du', 'Треугольник: отсюда начинаешь'),
          (c, s) => c.drawPath(
              Path()
                ..moveTo(s.width / 2, s.height / 2 - 10)
                ..lineTo(s.width / 2 + 10, s.height / 2 + 7)
                ..lineTo(s.width / 2 - 10, s.height / 2 + 7)
                ..close(),
              _st(_purple, 2))),
      Sym('703', ('Control', 'Ponto de controlo', 'Posten', 'КП'),
          ('The flag is at the centre of the circle', 'A baliza está no centro do círculo', 'Der Posten steht im Kreismittelpunkt', 'Призма в центре круга'),
          (c, s) => c.drawCircle(_mid(s), 10, _st(_purple, 2))),
      Sym('704', ('Control number', 'Número do ponto', 'Postennummer', 'Номер КП'),
          ('Visit the controls in this order', 'Visita os pontos por esta ordem', 'Posten in dieser Reihenfolge anlaufen', 'Бери КП в этом порядке'),
          (c, s) {
            c.drawCircle(_mid(s) - const Offset(6, 0), 9, _st(_purple, 2));
            final tp = TextPainter(
                text: const TextSpan(text: '1', style: TextStyle(color: _purple, fontSize: 14, fontWeight: FontWeight.w700)),
                textDirection: TextDirection.ltr)
              ..layout();
            tp.paint(c, _mid(s) + const Offset(7, -16));
          }),
      Sym('705', ('Course line', 'Linha do percurso', 'Bahnlinie', 'Линия дистанции'),
          ('Joins controls; not a route to follow', 'Liga os pontos; não é o caminho', 'Verbindet Posten; keine Route', 'Соединяет КП; это не путь'),
          (c, s) {
            c.drawCircle(Offset(14, s.height / 2), 7, _st(_purple, 1.8));
            c.drawCircle(Offset(s.width - 14, s.height / 2), 7, _st(_purple, 1.8));
            c.drawLine(Offset(21, s.height / 2), Offset(s.width - 21, s.height / 2), _st(_purple, 1.8));
          }),
      Sym('706', ('Finish', 'Chegada', 'Ziel', 'Финиш'),
          ('Double circle', 'Círculo duplo', 'Doppelkreis', 'Двойной круг'),
          (c, s) {
            c.drawCircle(_mid(s), 11, _st(_purple, 2));
            c.drawCircle(_mid(s), 7, _st(_purple, 2));
          }),
      Sym('707', ('Marked route', 'Percurso balizado', 'Markierte Strecke', 'Маркированный участок'),
          ('Follow the tapes', 'Segue as fitas', 'Den Bändern folgen', 'Беги по разметке'),
          (c, s) => _dashPath(c, _line(s), _st(_purple, 2), 6, 4)),
      Sym('708', ('Out-of-bounds boundary', 'Limite interdito', 'Sperrgrenze', 'Запретная граница'),
          ('Thick purple line: do not cross', 'Linha roxa grossa: não atravessar', 'Dicke violette Linie: nicht queren', 'Толстая пурпурная линия: не пересекать'),
          (c, s) => c.drawPath(_line(s), _st(_purple, 4))),
      Sym('709', ('Out-of-bounds area', 'Área interdita', 'Sperrgebiet', 'Запрещённая зона'),
          ('Purple stripes: no entry, ever', 'Riscas roxas: nunca entrar', 'Violette Streifen: nie betreten', 'Пурпурные полосы: входить нельзя'),
          (c, s) {
            for (var x = 12.0; x < s.width - 8; x += 6) {
              c.drawLine(Offset(x, 8), Offset(x, s.height - 8), _st(_purple, 2));
            }
          }),
      Sym('710', ('Crossing point', 'Ponto de passagem', 'Übergangsstelle', 'Пункт перехода'),
          ('Cross only here', 'Atravessar só aqui', 'Nur hier queren', 'Переходить только здесь'),
          (c, s) => _crossing(c, s, _purple)),
      Sym('712', ('First aid', 'Primeiros socorros', 'Erste Hilfe', 'Медпункт'),
          ('Help is here', 'Aqui há ajuda', 'Hier gibt es Hilfe', 'Здесь помогут'),
          (c, s) {
            final m = _mid(s);
            c.drawLine(m - const Offset(0, 9), m + const Offset(0, 9), _st(_purple, 3.4));
            c.drawLine(m - const Offset(9, 0), m + const Offset(9, 0), _st(_purple, 3.4));
          }),
    ]
  ),
];

class SymbolSwatch extends StatelessWidget {
  const SymbolSwatch(this.draw, {super.key, this.w = 64, this.h = 44});
  final Draw draw;
  final double w, h;
  @override
  Widget build(BuildContext context) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white, // map paper, in dark mode too
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: context.cHairline),
        ),
        child: CustomPaint(painter: _SwatchPainter(draw)),
      );
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.draw);
  final Draw draw;
  @override
  void paint(Canvas canvas, Size size) => draw(canvas, size);
  @override
  bool shouldRepaint(covariant _SwatchPainter old) => old.draw != draw;
}

class _SymbolsTab extends StatefulWidget {
  const _SymbolsTab();
  @override
  State<_SymbolsTab> createState() => _SymbolsTabState();
}

class _SymbolsTabState extends State<_SymbolsTab> {
  String _q = '';
  final _field = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    bool hit(Sym s) =>
        q.isEmpty ||
        s.code.contains(q) ||
        [s.name.$1, s.name.$2, s.name.$3, s.name.$4, tr(s.hint)].any((x) => x.toLowerCase().contains(q));
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
      Text(
          tr((
            'Every orienteering map uses the same international symbols (IOF). Colour tells the kind of thing: brown is the ground, black is rock and anything built, blue is water, yellow is open, green is hard going, purple is your course.',
            'Todos os mapas de orientação usam os mesmos símbolos internacionais (IOF). A cor diz o tipo: castanho é o relevo, preto é rocha e construções, azul é água, amarelo é aberto, verde é difícil de passar, roxo é o teu percurso.',
            'Jede OL-Karte nutzt dieselben internationalen Zeichen (IOF). Die Farbe verrät die Art: braun ist Gelände, schwarz Fels und Bauwerke, blau Wasser, gelb offen, grün schwer belaufbar, violett deine Bahn.',
            'На всех картах для ориентирования одни и те же международные знаки (IOF). Цвет говорит о типе: коричневый — рельеф, чёрный — скалы и постройки, синий — вода, жёлтый — открытое, зелёный — трудная проходимость, пурпурный — твоя дистанция.'
          )),
          style: TextStyle(fontSize: 13, color: context.cSubtle, height: 1.35)),
      const SizedBox(height: 10),
      TextField(
        controller: _field,
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _q.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() {
                        _field.clear();
                        _q = '';
                      })),
          hintText: tr(('Find a symbol: stairs, wall, marsh…', 'Procurar: escadas, muro, pântano…', 'Suchen: Treppe, Mauer, Sumpf…', 'Найти знак: лестница, стена, болото…')),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (v) => setState(() => _q = v),
      ),
      if (!kSymbolGroups.any((g) => g.$2.any(hit)))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(tr(('Nothing found. Try another word, or a colour: brown, blue, green.', 'Nada encontrado. Experimente outra palavra ou uma cor: castanho, azul, verde.', 'Nichts gefunden. Anderes Wort oder eine Farbe probieren: braun, blau, grün.', 'Ничего не найдено. Попробуй другое слово или цвет: коричневый, синий, зелёный.')),
              textAlign: TextAlign.center, style: TextStyle(color: context.cSubtle)),
        ),
      for (final (title, syms) in kSymbolGroups)
        if (syms.any(hit)) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 18, 0, 6),
            child: Text(tr(title).toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .6, color: context.cTitle)),
          ),
          for (final s in syms.where(hit))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                SymbolSwatch(s.draw),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(tr(s.name), style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                    Text(tr(s.hint), style: TextStyle(fontSize: 12.5, color: context.cSubtle)),
                  ]),
                ),
                const SizedBox(width: 6),
                Text(s.code, style: TextStyle(fontSize: 11, color: context.cSubtle, fontFeatures: const [FontFeature.tabularFigures()])),
              ]),
            ),
        ],
      const SizedBox(height: 16),
      Text(
          tr((
            'Symbols from the IOF standards ISOM 2017-2 (forest) and ISSprOM 2019-2 (sprint), simplified. The map you get at a race has its own legend: check it.',
            'Símbolos das normas IOF ISOM 2017-2 (floresta) e ISSprOM 2019-2 (sprint), simplificados. O mapa da prova tem a sua legenda: confirma.',
            'Zeichen nach den IOF-Normen ISOM 2017-2 (Wald) und ISSprOM 2019-2 (Sprint), vereinfacht. Die Wettkampfkarte hat ihre eigene Legende: prüfen.',
            'Знаки по стандартам IOF ISOM 2017-2 (лес) и ISSprOM 2019-2 (спринт), упрощённо. У карты соревнований своя легенда: сверяйся с ней.'
          )),
          style: TextStyle(fontSize: 11.5, color: context.cSubtle)),
    ]);
  }
}

// ------------------------------------------------------- how a race works

const List<T4> kRaceRules = [
    ('Phones and GPS may not be used to navigate. A compass is allowed.', 'Telemóvel e GPS não podem ser usados para navegar. A bússola é permitida.', 'Handy und GPS dürfen nicht zur Navigation dienen. Ein Kompass ist erlaubt.', 'Телефон и GPS для навигации нельзя. Компас можно.'),
    ('Purple stripes and olive green are out of bounds: entering means disqualification.', 'Riscas roxas e verde-oliva são interditos: entrar dá desclassificação.', 'Violette Streifen und Olivgrün sind gesperrt: Betreten heißt Disqualifikation.', 'Пурпурные полосы и оливковый — запрет: зашёл — дисквалификация.'),
    ('Miss a control or punch in the wrong order and you get no result (mispunch).', 'Falhar um ponto ou a ordem dá desclassificação.', 'Ein fehlender Posten oder falsche Reihenfolge: keine Wertung.', 'Пропуск КП или нарушение порядка — без результата.'),
    ('Carry a whistle on long forest courses. Someone hurt always comes before your time.', 'Leva um apito nos percursos longos. Um ferido vem sempre antes do teu tempo.', 'Auf langen Waldbahnen eine Pfeife mitnehmen. Verletzte gehen immer vor.', 'На длинных лесных дистанциях бери свисток. Помочь пострадавшему важнее результата.'),
    ('Do not lead or follow others on purpose.', 'Não guies nem sigas os outros de propósito.', 'Nicht absichtlich führen oder folgen.', 'Не веди других и не иди за другими специально.'),
  ];


const List<T4> kSheetNotes = [
    ('Scale 1:6000 (printed «Escala») — 1 cm on the map is 60 m. Sprint maps are 1:4000 (sometimes 1:3000); local town races also use 1:5000 or 1:6000 like this one; forest races 1:15000 or 1:10000.', 'Escala 1:6000 — 1 cm no mapa são 60 m. Mapas de sprint 1:4000 (às vezes 1:3000); provas urbanas locais também usam 1:5000 ou 1:6000, como esta; floresta 1:15000 ou 1:10000.', 'Maßstab 1:6000 (auf dem Blatt «Escala») — 1 cm auf der Karte sind 60 m. Sprintkarten 1:4000 (manchmal 1:3000); lokale Stadtläufe auch 1:5000 oder 1:6000 wie hier; Wald 1:15000 oder 1:10000.', 'Масштаб 1:6000 — 1 см на карте = 60 м. Спринт — 1:4000 (иногда 1:3000); местные городские старты — также 1:5000 или 1:6000, как здесь; лес — 1:15000 или 1:10000.'),
    ('Contour interval 10 m (printed «Equidistância»): each brown line is 10 m higher or lower than the next. Lines close together mean steep.', 'Equidistância 10 m — cada curva castanha fica 10 m acima ou abaixo da seguinte. Curvas juntas = íngreme.', 'Äquidistanz 10 m (auf dem Blatt «Equidistância»): jede braune Linie liegt 10 m höher oder tiefer als die nächste. Enge Linien = steil.', 'Сечение 10 м (на листе «Equidistância») — каждая коричневая линия на 10 м выше или ниже соседней. Частые линии — круто.'),
    ('The blue lines point to magnetic north; hold the map so they match the compass.', 'As linhas azuis apontam o norte magnético; segura o mapa alinhado com a bússola.', 'Die blauen Linien zeigen nach magnetisch Nord; Karte nach dem Kompass ausrichten.', 'Синие линии показывают магнитный север; держи карту по компасу.'),
    ('Boxes R1, R2, R3: if a SPORTident unit does not beep, punch the pin punch hanging at the control into the next free box.', 'Quadrados R1, R2, R3: se a estação SPORTident não apitar, pica com o picotador do ponto no quadrado livre seguinte.', 'Felder R1, R2, R3: piept die SPORTident-Station nicht, mit der Stiftzange am Posten ins nächste freie Feld stanzen.', 'Клетки R1, R2, R3: если станция SPORTident не пищит, пробей компостером на КП следующую свободную клетку.'),
    ('Rogaine: no order and no fixed course. Column A shows the points: the code without its last digit (code 152 = 15 points). Collect as many as you can before the time is up.', 'Rogaine: sem ordem nem percurso fixo. A coluna A mostra os pontos: o código sem o último algarismo (código 152 = 15 pontos). Junta o máximo antes do fim do tempo.', 'Rogaine: keine Reihenfolge, keine feste Bahn. Spalte A zeigt die Punkte: der Code ohne die letzte Ziffer (Code 152 = 15 Punkte). So viele wie möglich in der Zeit sammeln.', 'Рогейн: без порядка и без заданной дистанции. В столбце A — очки: код без последней цифры (код 152 = 15 очков). Набери как можно больше до конца времени.'),
  ];


const List<(IconData, T4, T4)> kRaceSteps = [
    (Icons.how_to_reg_outlined, ('Sign up', 'Inscrição', 'Anmelden', 'Заявка'),
        ('Pick a class by age and level. Most races have an open or beginner course: no licence needed.', 'Escolhe o escalão por idade e nível. Quase todas as provas têm um percurso aberto ou de iniciação: sem licença.', 'Wähle eine Kategorie nach Alter und Niveau. Fast immer gibt es eine offene oder Anfängerbahn: ohne Lizenz.', 'Выбери группу по возрасту и уровню. Почти везде есть открытая или новичковая дистанция: лицензия не нужна.')),
    (Icons.credit_card, ('The chip', 'O chip', 'Der Chip', 'Чип'),
        ('An electronic card on your finger (SPORTident). Rent one at the desk if you have none.', 'Um cartão eletrónico no dedo (SPORTident). Aluga-se no secretariado.', 'Ein elektronischer Chip am Finger (SPORTident). Im Wettkampfbüro ausleihen.', 'Электронный чип на палец (SPORTident). Можно взять напрокат в секретариате.')),
    (Icons.timer_outlined, ('Start time', 'Hora de partida', 'Startzeit', 'Время старта'),
        ('Everyone starts alone, a minute or more apart. Clear and check your chip in the start boxes.', 'Cada um parte sozinho, com um minuto ou mais de intervalo. Limpa e verifica o chip nas boxes de partida.', 'Jeder startet allein, mit einer Minute Abstand oder mehr. In den Startboxen Chip löschen und prüfen.', 'Стартуют по одному, с интервалом в минуту или больше. В стартовом коридоре очисти и проверь чип.')),
    (Icons.map_outlined, ('Map at the start', 'Mapa na partida', 'Karte am Start', 'Карта на старте'),
        ('You see the map only when your clock starts. Find the triangle, then control 1.', 'Só vês o mapa quando o teu tempo começa. Encontra o triângulo e depois o ponto 1.', 'Die Karte siehst du erst, wenn deine Zeit läuft. Dreieck finden, dann Posten 1.', 'Карту видишь только когда пошло твоё время. Найди треугольник, потом КП 1.')),
    (Icons.flag_outlined, ('Controls', 'Pontos', 'Posten', 'КП'),
        ('An orange and white flag with a unit. Check the code, put the chip in until it beeps or flashes.', 'Uma baliza laranja e branca com uma estação. Confirma o código e pica até apitar ou piscar.', 'Ein orange-weißer Posten mit Station. Code prüfen, Chip hineinhalten, bis es piept oder blinkt.', 'Оранжево-белая призма со станцией. Сверь код и отметься до писка или вспышки.')),
    (Icons.alt_route, ('Your own route', 'O teu caminho', 'Deine Route', 'Свой путь'),
        ('Between controls you choose the way. Paths are longer but faster; straight is shorter but rougher.', 'Entre pontos escolhes o caminho. Trilhos são mais longos mas rápidos; a direito é mais curto mas duro.', 'Zwischen den Posten wählst du den Weg. Wege sind länger, aber schneller; gerade ist kürzer, aber rauer.', 'Путь между КП выбираешь сам. По тропам дальше, но быстрее; напрямик короче, но тяжелее.')),
    (Icons.sports_score, ('Finish and download', 'Chegada e descarga', 'Ziel und Auslesen', 'Финиш и считывание'),
        ('Punch the finish, then read out your chip at the desk — even if you gave up. They count everyone back in.', 'Pica a chegada e descarrega o chip no secretariado — mesmo se desististe. Assim sabem que voltaste.', 'Ziel stempeln, dann Chip auslesen — auch bei Aufgabe. So weiß man, dass du zurück bist.', 'Отметься на финише и считай чип — даже если сошёл. Так знают, что ты вернулся.')),
  ];


class _RaceTab extends StatefulWidget {
  const _RaceTab();
  @override
  State<_RaceTab> createState() => _RaceTabState();
}

class _RaceTabState extends State<_RaceTab> {
  List<AtivaEvent>? _next;

  @override
  void initState() {
    super.initState();
    fetchEvents().then((all) {
      final today = madeiraNow().toIso8601String().substring(0, 10);
      final list = all.where((e) => isOrienteeringEvent(e) && e.date.compareTo(today) >= 0).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      if (mounted) setState(() => _next = list.take(6).toList());
    }).catchError((_) {
      if (mounted) setState(() => _next = const []);
    });
  }



  // What the Madeira sheets Kirill photographed print around the map.




  @override
  Widget build(BuildContext context) {
    final sub = TextStyle(fontSize: 13, color: context.cSubtle, height: 1.35);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
      for (var i = 0; i < kRaceSteps.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
                radius: 16,
                backgroundColor: context.cGreenTint,
                child: Icon(kRaceSteps[i].$1, size: 18, color: context.cTitle)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${i + 1}. ${tr(kRaceSteps[i].$2)}', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
              Text(tr(kRaceSteps[i].$3), style: sub),
            ])),
          ]),
        ),
      const SizedBox(height: 14),
      Text(tr(('Reading the map sheet', 'Ler o mapa', 'Das Kartenblatt lesen', 'Как читать лист карты')).toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .6, color: context.cTitle)),
      for (final r in kSheetNotes)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.circle, size: 6, color: kGreen)),
            const SizedBox(width: 10),
            Expanded(child: Text(tr(r), style: const TextStyle(fontSize: 13.5))),
          ]),
        ),
      const SizedBox(height: 14),
      Text(tr(('Rules to know', 'Regras a saber', 'Wichtige Regeln', 'Важные правила')).toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .6, color: context.cTitle)),
      for (final r in kRaceRules)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.circle, size: 6, color: kTerracotta)),
            const SizedBox(width: 10),
            Expanded(child: Text(tr(r), style: const TextStyle(fontSize: 13.5))),
          ]),
        ),
      const SizedBox(height: 18),
      Text(tr(('Next orienteering events', 'Próximas provas de orientação', 'Nächste OL-Läufe', 'Ближайшие старты по ориентированию')).toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .6, color: context.cTitle)),
      if (_next == null)
        const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: kGreen)))
      else if (_next!.isEmpty)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(tr(('None in the calendar right now.', 'Nenhuma no calendário de momento.', 'Gerade keine im Kalender.', 'Сейчас в календаре нет.')), style: sub))
      else
        for (final e in _next!)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.explore, color: kGreen),
            title: Text(e.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(dotJoin([fmtDate(e.date), tidyPlace(e.location)])),
            onTap: () => showEventActions(context, e, fromOrienteering: true),
          ),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        OutlinedButton.icon(
            onPressed: () => openUrl('https://aoram.pt'),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('AORAM — Madeira')),
        OutlinedButton.icon(
            onPressed: () => openUrl('https://www.fpo.pt'),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: Text(tr(('Portuguese federation', 'Federação (FPO)', 'Portugiesischer Verband', 'Федерация Португалии')))),
      ]),
    ]);
  }
}

// ----------------------------------------------------------------- compass

class _CompassTab extends StatefulWidget {
  const _CompassTab();
  @override
  State<_CompassTab> createState() => _CompassTabState();
}

class _CompassTabState extends State<_CompassTab> {
  static const _events = EventChannel('ativa/heading');
  static const _control = MethodChannel('ativa/heading/control');
  StreamSubscription? _sub;
  bool? _available;
  double? _heading; // magnetic, degrees
  double _accuracy = 180;
  double? _locked;
  double _sx = 0, _sy = 0; // smoothed unit vector

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    bool ok;
    try {
      ok = await _control.invokeMethod<bool>('isAvailable') ?? false;
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    setState(() => _available = ok);
    if (!ok) return;
    _sub = _events.receiveBroadcastStream().listen((e) {
      if (e is! Map) return;
      final w = (e['w'] as num).toDouble(), x = (e['x'] as num).toDouble(), y = (e['y'] as num).toDouble(), z = (e['z'] as num).toDouble();
      // The phone's top edge (+Y) in East-North-Up; when the phone stands
      // upright, the back (−Z) is where it points instead.
      var east = 2 * (x * y - w * z), north = 1 - 2 * (x * x + z * z), up = 2 * (y * z + w * x);
      if (up.abs() > .7) {
        east = -2 * (x * z + w * y);
        north = -2 * (y * z - w * x);
      }
      final len = math.sqrt(east * east + north * north);
      if (len < 1e-6) return;
      // Low-pass on the unit vector, so 359° to 1° does not swing round.
      _sx = _sx * .8 + east / len * .2;
      _sy = _sy * .8 + north / len * .2;
      final h = (math.atan2(_sx, _sy) * 180 / math.pi + 360) % 360;
      if (mounted) {
        setState(() {
          _heading = h;
          _accuracy = (e['accuracy'] as num?)?.toDouble() ?? 180;
        });
      }
    }, onError: (_) {
      if (mounted) setState(() => _available = false);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _dir(double h) {
    const n = [('N', 'N', 'N', 'С'), ('NE', 'NE', 'NO', 'СВ'), ('E', 'E', 'O', 'В'), ('SE', 'SE', 'SO', 'ЮВ'), ('S', 'S', 'S', 'Ю'), ('SW', 'SO', 'SW', 'ЮЗ'), ('W', 'O', 'W', 'З'), ('NW', 'NO', 'NW', 'СЗ')];
    return tr(n[((h + 22.5) % 360 ~/ 45)]);
  }

  @override
  Widget build(BuildContext context) {
    final sub = TextStyle(fontSize: 13, color: context.cSubtle, height: 1.35);
    final h = _heading;
    double? turn;
    if (h != null && _locked != null) turn = ((_locked! - h + 540) % 360) - 180;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), children: [
      if (_available == false)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
              tr((
                'This device has no compass sensor. On a phone the dial turns with you.',
                'Este aparelho não tem sensor de bússola. Num telemóvel o mostrador roda contigo.',
                'Dieses Gerät hat keinen Kompasssensor. Auf einem Handy dreht sich die Scheibe mit.',
                'На этом устройстве нет датчика компаса. На телефоне шкала поворачивается вместе с тобой.'
              )),
              textAlign: TextAlign.center,
              style: sub),
        ),
      Center(
        child: SizedBox(
          width: 260,
          height: 260,
          child: CustomPaint(painter: _DialPainter(heading: h ?? 0, locked: _locked, dark: context.dark, letters: tr(('NESW', 'NESO', 'NOSW', 'СВЮЗ')))),
        ),
      ),
      const SizedBox(height: 12),
      Center(
        child: Text(h == null ? '—' : '${h.round() % 360}° ${_dir(h)}',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: context.cTitle, fontFeatures: const [FontFeature.tabularFigures()])),
      ),
      Center(child: Text(tr(('magnetic bearing', 'rumo magnético', 'magnetischer Kurs', 'магнитный азимут')), style: sub)),
      if (turn != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Center(
            child: Text(
                turn.abs() < 4
                    ? tr(('On your bearing', 'No rumo', 'Auf Kurs', 'По азимуту'))
                    : '${turn > 0 ? tr(('Turn right', 'Vira à direita', 'Nach rechts', 'Правее')) : tr(('Turn left', 'Vira à esquerda', 'Nach links', 'Левее'))} ${turn.abs().round()}°',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: turn.abs() < 4 ? kGreen : kTerracotta)),
          ),
        ),
      const SizedBox(height: 12),
      Center(
        child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: kGreen, foregroundColor: Colors.white),
          onPressed: h == null ? null : () => setState(() => _locked = _locked == null ? h : null),
          icon: Icon(_locked == null ? Icons.lock_outline : Icons.lock_open, size: 18),
          label: Text(_locked == null
              ? tr(('Lock this bearing', 'Fixar este rumo', 'Kurs festhalten', 'Запомнить азимут'))
              : '${tr(('Release', 'Soltar', 'Lösen', 'Сбросить'))} ${_locked!.round() % 360}°'),
        ),
      ),
      if (_available == true && _accuracy > 15)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
              tr((
                'Low accuracy: wave the phone in a figure eight, away from cars and metal.',
                'Pouca precisão: faz um oito no ar com o telemóvel, longe de carros e metal.',
                'Ungenau: Handy in einer Acht schwenken, weg von Autos und Metall.',
                'Низкая точность: поводи телефоном восьмёркой, подальше от машин и металла.'
              )),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: kTerracotta)),
        ),
      const SizedBox(height: 20),
      Text(tr(('How to take a bearing', 'Como tirar um rumo', 'So nimmst du einen Kurs', 'Как взять азимут')).toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .6, color: context.cTitle)),
      const SizedBox(height: 6),
      Text(
          tr((
            '1. Turn the map so its north lines point the way the compass says north.\n2. Find on the map the direction from you to the control and read its angle from north.\n3. Turn until the phone shows that angle, lock it, and walk where the phone points. Pick a tree or rock on the line and run to it.',
            '1. Roda o mapa até as linhas de norte apontarem para o norte da bússola.\n2. No mapa, vê a direção de ti até ao ponto e o seu ângulo a partir do norte.\n3. Roda até o telemóvel mostrar esse ângulo, fixa-o e segue para onde ele aponta. Escolhe uma árvore ou pedra na linha e corre até ela.',
            '1. Karte drehen, bis die Nordlinien zum Kompassnorden zeigen.\n2. Auf der Karte die Richtung von dir zum Posten und ihren Winkel ab Nord ablesen.\n3. Drehen, bis das Handy diesen Winkel zeigt, festhalten, in Zeigerichtung gehen. Einen Baum oder Fels auf der Linie anpeilen und hinlaufen.',
            '1. Поверни карту, чтобы линии севера смотрели на север компаса.\n2. Найди на карте направление от себя к КП и его угол от севера.\n3. Повернись, пока телефон не покажет этот угол, запомни его и иди, куда смотрит телефон. Выбери на линии дерево или камень и беги к нему.'
          )),
          style: sub),
      const SizedBox(height: 14),
      Text(
          tr((
            'Orienteering maps are drawn to magnetic north, so this compass shows magnetic bearings and you need no correction. On Madeira true north is about 4° to the right of magnetic north: on an ordinary topographic map, add 4° to the map angle.',
            'Os mapas de orientação são desenhados para o norte magnético, por isso esta bússola mostra rumos magnéticos e não precisas de correção. Na Madeira o norte verdadeiro fica cerca de 4° à direita do magnético: num mapa topográfico comum, soma 4° ao ângulo do mapa.',
            'OL-Karten sind nach magnetisch Nord ausgerichtet, daher zeigt dieser Kompass magnetische Kurse — keine Korrektur nötig. Auf Madeira liegt geografisch Nord etwa 4° rechts von magnetisch Nord: bei einer normalen topografischen Karte 4° zum Kartenwinkel addieren.',
            'Карты для ориентирования рисуют по магнитному северу, поэтому компас показывает магнитный азимут и поправка не нужна. На Мадейре истинный север примерно на 4° правее магнитного: для обычной топокарты прибавь 4° к углу по карте.'
          )),
          style: sub),
    ]);
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.heading, required this.locked, required this.dark, required this.letters});
  final String letters;
  final double heading;
  final double? locked;
  final bool dark;

  @override
  void paint(Canvas c, Size s) {
    final m = Offset(s.width / 2, s.height / 2);
    final r = s.width / 2 - 4;
    c.drawCircle(m, r, _fi(dark ? const Color(0xFF1E2A26) : Colors.white));
    c.drawCircle(m, r, _st(dark ? const Color(0xFF3A4A44) : const Color(0xFFD6D6D0), 1.5));
    c.save();
    c.translate(m.dx, m.dy);
    c.rotate(-heading * math.pi / 180);
    final ink = dark ? const Color(0xFFE6EEEA) : _black;
    for (var d = 0; d < 360; d += 5) {
      final major = d % 30 == 0;
      final a = d * math.pi / 180;
      final v = Offset(math.sin(a), -math.cos(a));
      c.drawLine(v * (r - (major ? 16 : 8)), v * (r - 2), _st(ink, major ? 2 : 1));
    }
    final labels = {0: letters[0], 90: letters[1], 180: letters[2], 270: letters[3]};
    for (final e in labels.entries) {
      final a = e.key * math.pi / 180;
      final v = Offset(math.sin(a), -math.cos(a)) * (r - 32);
      final tp = TextPainter(
          text: TextSpan(text: e.value, style: TextStyle(color: e.key == 0 ? const Color(0xFFD7263D) : ink, fontSize: 20, fontWeight: FontWeight.w800)),
          textDirection: TextDirection.ltr)
        ..layout();
      c.save();
      c.translate(v.dx, v.dy);
      c.rotate(heading * math.pi / 180);
      tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
      c.restore();
    }
    if (locked != null) {
      final a = locked! * math.pi / 180;
      final v = Offset(math.sin(a), -math.cos(a));
      c.drawLine(v * (r - 18), v * (r - 2), _st(_purple, 5)..strokeCap = StrokeCap.round);
    }
    c.restore();
    // The phone's own direction: always straight up.
    c.drawPath(
        Path()
          ..moveTo(m.dx, m.dy - r + 4)
          ..lineTo(m.dx - 9, m.dy - r + 26)
          ..lineTo(m.dx + 9, m.dy - r + 26)
          ..close(),
        _fi(kGreen));
    c.drawCircle(m, 4, _fi(kGreen));
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) => old.heading != heading || old.locked != locked || old.dark != dark;
}
