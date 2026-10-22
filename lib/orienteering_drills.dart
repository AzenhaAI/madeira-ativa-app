import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'main.dart';
import 'orienteering.dart';
import 'orienteering_cd.dart';
import 'store.dart';
import 'orienteering_club_stub.dart' if (dart.library.io) 'orienteering_club.dart';

/// Drills: short quizzes that turn the reference tabs into practice.
/// Everything here is drawn in code (symbols, descriptions, contour shapes,
/// mini route-choice maps), so it ships in every build.
///
/// Club route puzzles use real club maps photographed in the members' chat.
/// Those maps are "Reprodução interdita": they never go into the repo or a
/// bundle. They live in a pack copied straight onto a test device and the
/// screen only exists in builds made with --dart-define=CLUB_MAPS=true.

const kClubMaps = bool.fromEnvironment('CLUB_MAPS');

class DrillsTab extends StatelessWidget {
  const DrillsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = TextStyle(fontSize: 12.5, color: context.cSubtle, height: 1.35);
    Widget card(String id, IconData icon, T4 title, T4 what, Widget Function() page) {
      final best = prefs.getInt('drill_best_$id');
      return Card(
        elevation: 0,
        color: context.cSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: context.cHairline)),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: CircleAvatar(backgroundColor: context.cGreenTint, child: Icon(icon, color: context.cTitle)),
          title: Text(tr(title), style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(best == null ? tr(what) : '${tr(what)}\n${tr(('Best', 'Melhor', 'Bestwert', 'Лучший'))}: $best/$kRound'),
          isThreeLine: best != null,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page())).then((_) {
            if (context.mounted) (context as Element).markNeedsBuild();
          }),
        ),
      );
    }

    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
      Text(tr(_tDrillsIntro), style: sub),
      const SizedBox(height: 8),
      card('symbols', Icons.category_outlined, ('Map symbols', 'Símbolos do mapa', 'Kartenzeichen', 'Знаки карты'),
          ('What does it mean? And the other way round.', 'O que significa? E ao contrário.', 'Was bedeutet es? Und umgekehrt.', 'Что это значит? И наоборот.'),
          () => QuizPage(id: 'symbols', title: tr(('Map symbols', 'Símbolos do mapa', 'Kartenzeichen', 'Знаки карты')), next: _symbolQuestion)),
      card('cd', Icons.grid_on_outlined, ('Control descriptions', 'Sinalética', 'Postenbeschreibung', 'Легенды КП'),
          ('Read the little pictures on the sheet.', 'Lê os desenhos da folha.', 'Die kleinen Bilder lesen.', 'Читаем значки легенды.'),
          () => QuizPage(id: 'cd', title: tr(('Control descriptions', 'Sinalética', 'Postenbeschreibung', 'Легенды КП')), next: _cdQuestion)),
      card('relief', Icons.terrain_outlined, ('Contours', 'Curvas de nível', 'Höhenlinien', 'Рельеф'),
          ('Hill or pit, higher or lower, steep or gentle.', 'Morro ou cova, mais alto ou mais baixo, íngreme ou suave.', 'Kuppe oder Senke, höher oder tiefer, steil oder flach.', 'Холм или яма, выше или ниже, круто или полого.'),
          () => QuizPage(id: 'relief', title: tr(('Contours', 'Curvas de nível', 'Höhenlinien', 'Рельеф')), next: _reliefQuestion)),
      card('route', Icons.alt_route, ('Route choice', 'Escolha de caminho', 'Routenwahl', 'Выбор пути'),
          ('Straight through the green or round on the path?', 'A direito pelo verde ou à volta pelo caminho?', 'Gerade durchs Grün oder außen herum auf dem Weg?', 'Напрямик через зелёнку или в обход по тропе?'),
          () => QuizPage(id: 'route', title: tr(('Route choice', 'Escolha de caminho', 'Routenwahl', 'Выбор пути')), next: _routeQuestion)),
      if (kClubMaps) ...[
        const SizedBox(height: 14),
        Text(tr(('TEST BUILD ONLY', 'SÓ VERSÃO DE TESTE', 'NUR TESTVERSION', 'ТОЛЬКО ТЕСТОВАЯ СБОРКА')),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .6, color: context.cTerraText)),
        card('club', Icons.photo_library_outlined, ('Club route puzzles', 'Desafios do clube', 'Vereinsaufgaben', 'Клубные разборы'),
            ('Real legs from club races: draw your way, then see how others ran.', 'Pernas reais: desenha o teu caminho e vê como os outros fizeram.', 'Echte Teilstrecken: eigenen Weg zeichnen, dann die anderen sehen.', 'Реальные перегоны: нарисуй свой путь, потом посмотри, как бежали другие.'),
            () => const ClubPuzzlesPage()),
      ],
    ]);
  }
}

const T4 _tDrillsIntro = (
  'Ten questions a round, new ones every time. Two minutes on the bus is enough. Everything is drawn for this app after the IOF standards.',
  'Dez perguntas por ronda, sempre novas. Dois minutos no autocarro chegam. Tudo desenhado para a aplicação segundo as normas IOF.',
  'Zehn Fragen pro Runde, jedes Mal neue. Zwei Minuten im Bus reichen. Alles für die App nach den IOF-Normen gezeichnet.',
  'Десять вопросов за раунд, каждый раз новые. Хватит двух минут в автобусе. Всё нарисовано для приложения по стандартам IOF.'
);

// ================================================================ quiz shell

const kRound = 10;

class Question {
  Question({required this.prompt, required this.options, required this.correct, required this.explain, this.ask});
  final Widget prompt;
  final List<Widget> options;
  final int correct;
  final String explain;
  final String? ask;
}

typedef QuestionGen = Question Function(math.Random rnd, BuildContext context);

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.id, required this.title, required this.next});
  final String id;
  final String title;
  final QuestionGen next;
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _rnd = math.Random();
  Question? _q;
  int _n = 0, _right = 0;
  int? _picked;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _q ??= widget.next(_rnd, context);
  }

  void _pick(int i) {
    if (_picked != null) return;
    setState(() {
      _picked = i;
      if (i == _q!.correct) _right++;
    });
  }

  void _advance() {
    if (_n + 1 >= kRound) {
      final best = prefs.getInt('drill_best_${widget.id}') ?? 0;
      if (_right > best) prefs.setInt('drill_best_${widget.id}', _right);
      setState(() => _n = kRound);
      return;
    }
    setState(() {
      _n++;
      _picked = null;
      _q = widget.next(_rnd, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final done = _n >= kRound;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: done
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('$_right / $kRound', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: context.cTitle)),
                    const SizedBox(height: 8),
                    Text(
                        tr(_right >= 9
                            ? ('Excellent. You read the map like a local.', 'Excelente. Lês o mapa como um local.', 'Hervorragend. Du liest die Karte wie ein Einheimischer.', 'Отлично. Читаешь карту как местный.')
                            : _right >= 6
                                ? ('Good. One more round to make it stick.', 'Bom. Mais uma ronda para fixar.', 'Gut. Noch eine Runde, damit es sitzt.', 'Хорошо. Ещё раунд, чтобы закрепить.')
                                : ('Keep going — the reference tabs have every answer.', 'Continua — as outras abas têm todas as respostas.', 'Weiter so — die anderen Reiter haben alle Antworten.', 'Продолжай — все ответы есть в соседних вкладках.')),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      icon: const Icon(Icons.replay),
                      label: Text(tr(('Another round', 'Outra ronda', 'Noch eine Runde', 'Ещё раунд'))),
                      onPressed: () => setState(() {
                        _n = 0;
                        _right = 0;
                        _picked = null;
                        _q = widget.next(_rnd, context);
                      }),
                    ),
                  ]),
                ),
              )
            : ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
                LinearProgressIndicator(value: (_n + (_picked == null ? 0 : 1)) / kRound, color: kGreen, backgroundColor: context.cHairline),
                const SizedBox(height: 6),
                Text('${_n + 1} / $kRound  ·  ✓ $_right', style: TextStyle(fontSize: 12, color: context.cSubtle)),
                const SizedBox(height: 10),
                if (_q!.ask != null) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(_q!.ask!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                Center(child: _q!.prompt),
                const SizedBox(height: 14),
                for (var i = 0; i < _q!.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Material(
                      color: _picked == null
                          ? context.cSurface
                          : i == _q!.correct
                              ? (context.dark ? kGreenTintDark : const Color(0xFFD7F2E3))
                              : i == _picked
                                  ? (context.dark ? kTerraTintDark : const Color(0xFFF9D9CF))
                                  : context.cSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: context.cHairline)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _pick(i),
                        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: _q!.options[i]),
                      ),
                    ),
                  ),
                if (_picked != null) ...[
                  const SizedBox(height: 10),
                  Text(_q!.explain, style: TextStyle(fontSize: 13.5, height: 1.35, color: context.cBody)),
                  const SizedBox(height: 14),
                  FilledButton(onPressed: _advance, child: Text(tr(_n + 1 >= kRound ? ('Results', 'Resultado', 'Ergebnis', 'Итог') : ('Next', 'Seguinte', 'Weiter', 'Дальше')))),
                ],
              ]),
      ),
    );
  }
}

Widget _optText(String s) => Text(s, style: const TextStyle(fontSize: 15));

/// Scale a fixed-size painted swatch up for the question card.
Widget _big(Widget w, double size) => SizedBox(width: size, height: size * .7, child: FittedBox(child: w));

List<int> _pickDistinct(math.Random rnd, int n, int count, int exclude) {
  final out = <int>{};
  while (out.length < count && out.length < n - 1) {
    final i = rnd.nextInt(n);
    if (i != exclude) out.add(i);
  }
  return out.toList();
}

// ================================================================ symbols

Question _symbolQuestion(math.Random rnd, BuildContext context) {
  final all = [for (final g in kSymbolGroups) ...g.$2];
  final k = rnd.nextInt(all.length);
  final s = all[k];
  // distractors: prefer the same colour group, it is harder
  final group = kSymbolGroups.firstWhere((g) => g.$2.contains(s)).$2;
  final pool = group.length >= 4 ? group : all;
  final others = _pickDistinct(rnd, pool.length, 3, pool.indexOf(s)).map((i) => pool[i]).toList();
  final opts = [s, ...others]..shuffle(rnd);
  final why = '${tr(s.name)}${s.code.isEmpty ? '' : ' (${s.code})'}: ${tr(s.hint)}.';
  if (rnd.nextBool()) {
    return Question(
      ask: tr(('What is this?', 'O que é isto?', 'Was ist das?', 'Что это?')),
      prompt: SymbolSwatch(s.draw, w: 160, h: 110),
      options: [for (final o in opts) _optText(tr(o.name))],
      correct: opts.indexOf(s),
      explain: why,
    );
  }
  return Question(
    ask: '${tr(('Find', 'Encontra', 'Finde', 'Найди'))}: ${tr(s.name)}',
    prompt: const SizedBox.shrink(),
    options: [for (final o in opts) Row(children: [SymbolSwatch(o.draw, w: 96, h: 64)])],
    correct: opts.indexOf(s),
    explain: why,
  );
}

// ================================================================ control descriptions

Question _cdQuestion(math.Random rnd, BuildContext context) {
  final groups = kCdGroups.where((g) => g.$4.length >= 4).toList();
  final g = groups[rnd.nextInt(groups.length)];
  final items = g.$4;
  final k = rnd.nextInt(items.length);
  final it = items[k];
  final others = _pickDistinct(rnd, items.length, 3, k).map((i) => items[i]).toList();
  final opts = [it, ...others]..shuffle(rnd);
  final why = '${tr(('Column', 'Coluna', 'Spalte', 'Столбец'))} ${g.$1} · ${tr(g.$2)}: ${tr(it.name)}${it.note == null ? '' : ' — ${tr(it.note!)}'}.';
  return Question(
    ask: tr(('This sits in a description row. It means…', 'Isto está numa linha da sinalética. Significa…', 'Das steht in einer Beschreibungszeile. Es heißt…', 'Это значок из строки легенды. Он означает…')),
    prompt: _big(CdSwatch(it.id), 150),
    options: [for (final o in opts) _optText(tr(o.name))],
    correct: opts.indexOf(it),
    explain: why,
  );
}

// ================================================================ contours

enum _ReliefKind { hillOrPit, higher, steeper, climb }

class _Relief {
  _Relief(this.rnd)
      : pit = rnd.nextInt(3) == 0,
        n = 3 + rnd.nextInt(3),
        center = Offset(150 + rnd.nextDouble() * 20 - 10, 100 + rnd.nextDouble() * 16 - 8),
        r0 = 60 + rnd.nextDouble() * 8,
        phase1 = rnd.nextDouble() * math.pi * 2,
        phase2 = rnd.nextDouble() * math.pi * 2,
        steepDir = rnd.nextDouble() * math.pi * 2,
        shift = 5 + rnd.nextDouble() * 5;
  final math.Random rnd;
  final bool pit;
  final int n; // number of contours
  final Offset center;
  final double r0, phase1, phase2, steepDir, shift;
  final marks = <String, Offset>{};

  Offset c(int k) => center + Offset(math.cos(steepDir), math.sin(steepDir)) * (shift * k);
  double r(int k, double t) => r0 * (1 - k / (n + .6)) * (1 + .13 * math.sin(2 * t + phase1) + .07 * math.sin(3 * t + phase2));
  Offset at(int k, double t) => c(k) + Offset(math.cos(t), math.sin(t)) * r(k, t);
  /// A point halfway between contour k and k+1 (k = -1 is outside the outer one).
  Offset between(int k, double t) {
    if (k < 0) return at(0, t) + Offset(math.cos(t), math.sin(t)) * 16;
    if (k >= n - 1) return c(n - 1) + (at(n - 1, t) - c(n - 1)) * .35;
    return (at(k, t) + at(k + 1, t)) / 2;
  }

  Path ring(int k) {
    final p = Path();
    for (var i = 0; i <= 72; i++) {
      final o = at(k, i / 72 * math.pi * 2);
      i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
    }
    return p..close();
  }
}

class _ReliefPainter extends CustomPainter {
  _ReliefPainter(this.m);
  final _Relief m;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 300, size.height / 200);
    final brown = Paint()
      ..color = const Color(0xFFC0651F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    for (var k = 0; k < m.n; k++) {
      canvas.drawPath(m.ring(k), brown..strokeWidth = k == 0 && m.n >= 5 ? 2.4 : 1.6);
    }
    if (m.pit) {
      // slope ticks on the inner rings point downhill, into the pit
      for (final k in [m.n - 1, m.n - 2]) {
        for (var i = 0; i < 10; i++) {
          final t = i / 10 * math.pi * 2 + .2;
          final o = m.at(k, t);
          final d = (m.c(k) - o);
          canvas.drawLine(o, o + d / d.distance * 6, brown..strokeWidth = 1.4);
        }
      }
    }
    const purple = Color(0xFFC0249E);
    for (final e in m.marks.entries) {
      canvas.drawCircle(e.value, 4.5, Paint()..color = purple);
      final tp = TextPainter(
          text: TextSpan(text: e.key, style: const TextStyle(color: purple, fontSize: 15, fontWeight: FontWeight.w800)),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, e.value + const Offset(6, -18));
    }
  }

  @override
  bool shouldRepaint(covariant _ReliefPainter old) => old.m != m;
}

Widget _map(CustomPainter p, {double w = 320, double h = 213}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFBBBBBB))),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CustomPaint(painter: p)),
    );

Question _reliefQuestion(math.Random rnd, BuildContext context) {
  final kind = _ReliefKind.values[rnd.nextInt(_ReliefKind.values.length)];
  final m = _Relief(rnd);
  const interval = 5;
  switch (kind) {
    case _ReliefKind.hillOrPit:
      final opts = [tr(('A hill', 'Um morro', 'Eine Kuppe', 'Холм')), tr(('A depression (pit)', 'Uma depressão (cova)', 'Eine Senke', 'Впадина (яма)'))];
      return Question(
        ask: tr(('Hill or depression?', 'Morro ou depressão?', 'Kuppe oder Senke?', 'Холм или впадина?')),
        prompt: _map(_ReliefPainter(m)),
        options: [for (final o in opts) _optText(o)],
        correct: m.pit ? 1 : 0,
        explain: tr(m.pit
            ? ('A depression: the little slope ticks on the inner rings point downhill, into the middle. Closed rings without ticks are hills.', 'Uma depressão: os tracinhos nas curvas de dentro apontam para baixo, para o centro. Anéis fechados sem tracinhos são morros.', 'Eine Senke: die kleinen Gefällsstriche innen zeigen bergab, zur Mitte. Geschlossene Ringe ohne Striche sind Kuppen.', 'Впадина: бергштрихи на внутренних кольцах смотрят вниз, к центру. Замкнутые кольца без штрихов — холм.')
            : ('A hill: closed rings without slope ticks. A depression would have little ticks pointing into the middle.', 'Um morro: anéis fechados sem tracinhos. Uma depressão teria tracinhos a apontar para o centro.', 'Eine Kuppe: geschlossene Ringe ohne Gefällsstriche. Eine Senke hätte Striche zur Mitte.', 'Холм: замкнутые кольца без бергштрихов. У впадины штрихи смотрели бы к центру.')),
      );
    case _ReliefKind.higher:
      final t1 = rnd.nextDouble() * math.pi * 2;
      final inner = m.between(m.n - 1, t1);
      final outer = m.between(-1, t1 + math.pi * (.6 + rnd.nextDouble() * .8));
      final innerIsA = rnd.nextBool();
      m.marks[innerIsA ? 'A' : 'B'] = inner;
      m.marks[innerIsA ? 'B' : 'A'] = outer;
      final innerHigher = !m.pit;
      final aHigher = innerIsA == innerHigher;
      final diff = m.n * interval;
      return Question(
        ask: tr(('Which point is higher? Contour interval $interval m.', 'Qual ponto está mais alto? Equidistância $interval m.', 'Welcher Punkt liegt höher? Äquidistanz $interval m.', 'Какая точка выше? Сечение $interval м.')),
        prompt: _map(_ReliefPainter(m)),
        options: [_optText('A'), _optText('B')],
        correct: aHigher ? 0 : 1,
        explain: tr((
          '${m.pit ? 'It is a depression, so the middle is the lowest part' : 'It is a hill, so the middle is the top'}. ${aHigher ? 'A' : 'B'} is higher by about $diff m: ${m.n} contours × $interval m.',
          '${m.pit ? 'É uma depressão, o centro é o ponto mais baixo' : 'É um morro, o centro é o topo'}. ${aHigher ? 'A' : 'B'} está cerca de $diff m mais alto: ${m.n} curvas × $interval m.',
          '${m.pit ? 'Eine Senke, die Mitte ist der tiefste Punkt' : 'Eine Kuppe, die Mitte ist der Gipfel'}. ${aHigher ? 'A' : 'B'} liegt etwa $diff m höher: ${m.n} Linien × $interval m.',
          '${m.pit ? 'Это впадина, в центре самое низкое место' : 'Это холм, в центре вершина'}. ${aHigher ? 'A' : 'B'} выше примерно на $diff м: ${m.n} горизонтали × $interval м.'
        )),
      );
    case _ReliefKind.steeper:
      final k = math.max(0, m.n ~/ 2 - 1);
      final steep = m.between(k, m.steepDir);
      final gentle = m.between(k, m.steepDir + math.pi);
      final steepIsA = rnd.nextBool();
      m.marks[steepIsA ? 'A' : 'B'] = steep;
      m.marks[steepIsA ? 'B' : 'A'] = gentle;
      return Question(
        ask: tr(('Where is the slope steeper?', 'Onde é mais íngreme?', 'Wo ist es steiler?', 'Где склон круче?')),
        prompt: _map(_ReliefPainter(m)),
        options: [_optText('A'), _optText('B')],
        correct: steepIsA ? 0 : 1,
        explain: tr((
          'At ${steepIsA ? 'A' : 'B'}: the contours are closer together, so you gain the same height in fewer metres. Plan to walk up there, or go round.',
          'Em ${steepIsA ? 'A' : 'B'}: as curvas estão mais juntas, sobe-se a mesma altura em menos metros. Conta andar a pé ou contornar.',
          'Bei ${steepIsA ? 'A' : 'B'}: die Linien liegen enger, gleiche Höhe auf kürzerer Strecke. Dort eher gehen oder umlaufen.',
          'В ${steepIsA ? 'A' : 'B'}: горизонтали ближе друг к другу — та же высота на меньшем расстоянии. Там скорее пешком или в обход.'
        )),
      );
    case _ReliefKind.climb:
      final t = rnd.nextDouble() * math.pi * 2;
      m.marks['A'] = m.between(-1, t);
      m.marks['B'] = m.between(m.n - 1, t + .3);
      final right = m.n * interval;
      final cand = <int>{right, right + 2 * interval, math.max(interval, right - 2 * interval), right * 2}.toList()..shuffle(rnd);
      while (cand.length < 4) {
        cand.add(cand.last + interval);
      }
      return Question(
        ask: tr((
          m.pit ? 'From A down to B, how far do you descend? Contour interval $interval m.' : 'From A up to B, how much do you climb? Contour interval $interval m.',
          m.pit ? 'De A até B, quanto desces? Equidistância $interval m.' : 'De A até B, quanto sobes? Equidistância $interval m.',
          m.pit ? 'Von A hinunter nach B: wie viele Meter? Äquidistanz $interval m.' : 'Von A hinauf nach B: wie viele Höhenmeter? Äquidistanz $interval m.',
          m.pit ? 'От A вниз до B — сколько метров спуска? Сечение $interval м.' : 'От A вверх до B — сколько набора? Сечение $interval м.'
        )),
        prompt: _map(_ReliefPainter(m)),
        options: [for (final c in cand) _optText('$c m')],
        correct: cand.indexOf(right),
        explain: tr((
          'Count the brown lines you cross: ${m.n} × $interval m = $right m. Ignore how far apart they are; that is steepness, not height.',
          'Conta as curvas que atravessas: ${m.n} × $interval m = $right m. A distância entre elas é o declive, não a altura.',
          'Zähle die gekreuzten Linien: ${m.n} × $interval m = $right m. Ihr Abstand ist die Steilheit, nicht die Höhe.',
          'Считай пересекаемые линии: ${m.n} × $interval м = $right м. Расстояние между ними — это крутизна, а не высота.'
        )),
      );
  }
}

// ================================================================ route choice

/// Running speed as a share of path speed, after the usual ISOM guidance.
enum _Terrain { forest, open, light, medium, dark }

const _speed = {_Terrain.forest: .8, _Terrain.open: .9, _Terrain.light: .65, _Terrain.medium: .4, _Terrain.dark: .2};
const _fill = {
  _Terrain.open: Color(0xFFFFD25A),
  _Terrain.light: Color(0xFFC9E7B2),
  _Terrain.medium: Color(0xFF8CC86E),
  _Terrain.dark: Color(0xFF3A9B3A),
};

class _Blob {
  _Blob(this.rect, this.kind);
  final Rect rect; // ellipse bounds
  final _Terrain kind;
  bool contains(Offset p) {
    final c = rect.center;
    final dx = (p.dx - c.dx) / (rect.width / 2), dy = (p.dy - c.dy) / (rect.height / 2);
    return dx * dx + dy * dy <= 1;
  }
}

class _RouteMap {
  /// Units are metres; the map is 300 × 200 m.
  _RouteMap(math.Random rnd) {
    start = Offset(32, 70 + rnd.nextDouble() * 60);
    control = Offset(268, 70 + rnd.nextDouble() * 60);
    final bow = (rnd.nextBool() ? 1 : -1) * (55 + rnd.nextDouble() * 35);
    final p0 = Offset(8, start.dy + (rnd.nextDouble() * 20 - 10) + bow * .25);
    final p2 = Offset(292, control.dy + (rnd.nextDouble() * 20 - 10) + bow * .25);
    final p1 = Offset(150, (start.dy + control.dy) / 2 + bow * 1.6);
    for (var i = 0; i <= 80; i++) {
      final t = i / 80;
      path.add(p0 * ((1 - t) * (1 - t)) + p1 * (2 * (1 - t) * t) + p2 * (t * t));
    }
    // vegetation, mostly across the straight line so the choice is real
    final kinds = [_Terrain.light, _Terrain.medium, _Terrain.dark, _Terrain.open];
    final count = 2 + rnd.nextInt(4);
    for (var i = 0; i < count; i++) {
      final t = .2 + rnd.nextDouble() * .6;
      final c = Offset.lerp(start, control, t)! + Offset(rnd.nextDouble() * 40 - 20, rnd.nextDouble() * 60 - 30);
      final w = 30 + rnd.nextDouble() * 70, h = 25 + rnd.nextDouble() * 60;
      blobs.add(_Blob(Rect.fromCenter(center: c, width: w, height: h), kinds[rnd.nextInt(kinds.length)]));
    }
    // a few elsewhere, for the look of a real map
    for (var i = 0; i < 3; i++) {
      blobs.add(_Blob(Rect.fromCenter(center: Offset(rnd.nextDouble() * 300, rnd.nextDouble() * 200), width: 20 + rnd.nextDouble() * 40, height: 20 + rnd.nextDouble() * 30),
          kinds[rnd.nextInt(kinds.length)]));
    }
    straight = [start, control];
    int nearest(Offset p) {
      var best = 0;
      for (var i = 1; i < path.length; i++) {
        if ((path[i] - p).distance < (path[best] - p).distance) best = i;
      }
      return best;
    }

    final a = nearest(start), b = nearest(control);
    viaPath = [start, ...(a <= b ? path.sublist(a, b + 1) : path.sublist(b, a + 1).reversed), control];
    onPath = {for (var i = 1; i < viaPath.length - 2; i++) i};
  }

  late final Offset start, control;
  final path = <Offset>[];
  final blobs = <_Blob>[];
  late final List<Offset> straight, viaPath;
  late final Set<int> onPath; // segment indexes of viaPath that run on the path

  _Terrain terrainAt(Offset p) {
    _Terrain t = _Terrain.forest;
    for (final b in blobs) {
      if (b.contains(p)) t = b.kind; // later blobs are drawn on top
    }
    return t;
  }

  /// Seconds at 4:00 min/km on the path, and metres off-path in green.
  ({double secs, double metres, double green}) cost(List<Offset> pts, Set<int> pathSegs) {
    const pathSpeed = 1000 / 240;
    double secs = 0, metres = 0, green = 0;
    for (var i = 0; i < pts.length - 1; i++) {
      final seg = pts[i + 1] - pts[i];
      final len = seg.distance;
      metres += len;
      final steps = math.max(1, (len / 2).ceil());
      for (var s = 0; s < steps; s++) {
        final p = pts[i] + seg * ((s + .5) / steps);
        final dl = len / steps;
        if (pathSegs.contains(i)) {
          secs += dl / pathSpeed;
        } else {
          final t = terrainAt(p);
          secs += dl / (pathSpeed * _speed[t]!);
          if (t == _Terrain.light || t == _Terrain.medium || t == _Terrain.dark) green += dl;
        }
      }
    }
    return (secs: secs, metres: metres, green: green);
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.m, this.labels);
  final _RouteMap m;
  final Map<String, List<Offset>> labels;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 300, size.height / 200);
    for (final b in m.blobs) {
      canvas.drawOval(b.rect, Paint()..color = _fill[b.kind]!);
    }
    const purple = Color(0xFFC0249E);
    final course = Paint()
      ..color = purple
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    // start triangle and control circle
    final s = m.start, c = m.control;
    canvas.drawPath(
        Path()
          ..moveTo(s.dx, s.dy - 8)
          ..lineTo(s.dx + 7, s.dy + 5)
          ..lineTo(s.dx - 7, s.dy + 5)
          ..close(),
        course);
    canvas.drawCircle(c, 8, course);
    final colours = [const Color(0xFFE65100), const Color(0xFF1565C0)];
    var k = 0;
    for (final e in labels.entries) {
      final paint = Paint()
        ..color = colours[k % 2].withValues(alpha: .9)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke;
      final pts = e.value;
      final p = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      for (final mm in p.computeMetrics()) {
        for (var d = 10.0; d < mm.length - 10; d += 7) {
          canvas.drawPath(mm.extractPath(d, math.min(d + 4, mm.length)), paint);
        }
      }
      final metric = p.computeMetrics().first;
      final mid = metric.getTangentForOffset(metric.length * (k == 0 ? .42 : .5))!.position;
      final tp = TextPainter(
          text: TextSpan(text: e.key, style: TextStyle(color: colours[k % 2], fontSize: 16, fontWeight: FontWeight.w900)),
          textDirection: TextDirection.ltr)
        ..layout();
      canvas.drawCircle(mid + const Offset(0, -14), 10, Paint()..color = Colors.white.withValues(alpha: .85));
      tp.paint(canvas, mid + Offset(-tp.width / 2, -14 - tp.height / 2));
      k++;
    }
    final pathPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < m.path.length - 1; i += 2) {
      canvas.drawLine(m.path[i], m.path[i + 1], pathPaint);
    }
    // scale bar 50 m
    final bar = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1.4;
    canvas.drawLine(const Offset(232, 190), const Offset(282, 190), bar);
    canvas.drawLine(const Offset(232, 186), const Offset(232, 194), bar);
    canvas.drawLine(const Offset(282, 186), const Offset(282, 194), bar);
    final tp = TextPainter(text: const TextSpan(text: '50 m', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 9)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(257 - tp.width / 2, 177));
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) => old.m != m;
}

String _mmss(double s) => '${s ~/ 60}:${(s.round() % 60).toString().padLeft(2, '0')}';

Question _routeQuestion(math.Random rnd, BuildContext context) {
  late _RouteMap m;
  late ({double secs, double metres, double green}) a, b;
  for (var tries = 0; tries < 40; tries++) {
    m = _RouteMap(rnd);
    a = m.cost(m.straight, const {});
    b = m.cost(m.viaPath, m.onPath);
    if ((a.secs - b.secs).abs() / math.min(a.secs, b.secs) > .1) break;
  }
  final straightIsA = rnd.nextBool();
  final labels = straightIsA ? {'A': m.straight, 'B': m.viaPath} : {'A': m.viaPath, 'B': m.straight};
  final straightFaster = a.secs < b.secs;
  final correct = (straightFaster == straightIsA) ? 0 : 1;
  final sName = straightIsA ? 'A' : 'B', pName = straightIsA ? 'B' : 'A';
  return Question(
    ask: tr(('Which way is faster from the triangle to the circle?', 'Qual caminho é mais rápido do triângulo ao círculo?', 'Welcher Weg vom Dreieck zum Kreis ist schneller?', 'Какой путь от треугольника до кружка быстрее?')),
    prompt: Column(children: [
      _map(_RoutePainter(m, labels)),
      const SizedBox(height: 6),
      Wrap(spacing: 10, runSpacing: 4, children: [
        for (final (t, label) in [
          (_Terrain.forest, ('white forest 80 %', 'floresta branca 80 %', 'weißer Wald 80 %', 'белый лес 80 %')),
          (_Terrain.open, ('open 90 %', 'aberto 90 %', 'offen 90 %', 'открытое 90 %')),
          (_Terrain.light, ('light green 65 %', 'verde claro 65 %', 'hellgrün 65 %', 'светло-зелёный 65 %')),
          (_Terrain.medium, ('green 40 %', 'verde 40 %', 'grün 40 %', 'зелёный 40 %')),
          (_Terrain.dark, ('dark green 20 %', 'verde escuro 20 %', 'dunkelgrün 20 %', 'тёмно-зелёный 20 %')),
        ])
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: _fill[t] ?? Colors.white, border: Border.all(color: const Color(0xFFBBBBBB)))),
            const SizedBox(width: 4),
            Text(tr(label), style: TextStyle(fontSize: 11, color: context.cSubtle)),
          ]),
      ]),
      Text(tr(('Speed compared with running on the path. Flat ground.', 'Velocidade comparada com o caminho. Terreno plano.', 'Tempo im Vergleich zum Weg. Flaches Gelände.', 'Скорость относительно бега по тропе. Местность ровная.')),
          style: TextStyle(fontSize: 11, color: context.cSubtle)),
    ]),
    options: [_optText('A'), _optText('B')],
    correct: correct,
    explain: tr((
      'Straight ($sName): ${a.metres.round()} m, ${a.green.round()} m of it in green → about ${_mmss(a.secs)}. Path ($pName): ${b.metres.round()} m → about ${_mmss(b.secs)}. ${straightFaster ? 'Here the green is thin enough to cut through.' : 'Longer, but you keep running speed the whole way.'}',
      'A direito ($sName): ${a.metres.round()} m, ${a.green.round()} m no verde → cerca de ${_mmss(a.secs)}. Caminho ($pName): ${b.metres.round()} m → cerca de ${_mmss(b.secs)}. ${straightFaster ? 'Aqui o verde é pouco e compensa cortar.' : 'Mais longo, mas corres sempre à velocidade máxima.'}',
      'Gerade ($sName): ${a.metres.round()} m, davon ${a.green.round()} m im Grün → etwa ${_mmss(a.secs)}. Weg ($pName): ${b.metres.round()} m → etwa ${_mmss(b.secs)}. ${straightFaster ? 'Hier ist das Grün dünn genug zum Durchqueren.' : 'Länger, aber durchgehend im Lauftempo.'}',
      'Напрямик ($sName): ${a.metres.round()} м, из них ${a.green.round()} м по зелёнке → около ${_mmss(a.secs)}. По тропе ($pName): ${b.metres.round()} м → около ${_mmss(b.secs)}. ${straightFaster ? 'Здесь зелёнки мало — выгодно срезать.' : 'Длиннее, но всё время бежишь в полную скорость.'}'
    )),
  );
}

