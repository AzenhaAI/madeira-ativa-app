import 'package:flutter/material.dart';

import 'island_now.dart';
import 'main.dart';
import 'orienteering.dart' show T4, tr;

/// Classes and entries: the part a newcomer meets first, on the orioasis.pt
/// entry form — what H45, "Aberto Vermelho", "Aluguer" and AVO mean, and
/// which class to pick. Asked for by a tester (22.10.2026) who could not read
/// his own entry form.

class ClassesTab extends StatefulWidget {
  const ClassesTab({super.key});
  @override
  State<ClassesTab> createState() => _ClassesTabState();
}

/// Age classes as Portuguese and Madeiran races list them. A class is set by
/// the age you reach during the calendar year, not by your birthday.
const _juniorAges = [10, 12, 14, 16, 18, 20];
const _veteranAges = [35, 40, 45, 50, 55, 60, 65, 70, 75, 80];

class _ClassesTabState extends State<ClassesTab> {
  int _born = 1990;
  bool _women = false;

  ({String own, List<String> alsoOk, String note}) _pick() {
    final year = madeiraNow().year;
    final age = year - _born;
    final s = _women ? 'D' : 'H';
    if (age <= 10) {
      return (own: 'T10', alsoOk: ['${s}12'], note: tr(_tNote10));
    }
    if (age <= 20) {
      final own = _juniorAges.firstWhere((a) => a >= age);
      final up = [for (final a in _juniorAges) if (a > own) '$s$a', '${s}21B'];
      return (own: '$s$own', alsoOk: up, note: tr(_tNoteJunior));
    }
    if (age < 35) {
      return (own: '${s}21A', alsoOk: ['${s}21B', '${_women ? 'Damas' : 'Homens'} Elite'], note: tr(_tNote21));
    }
    final own = _veteranAges.lastWhere((a) => a <= age);
    final down = [for (final a in _veteranAges.reversed) if (a < own) '$s$a', '${s}21A', '${s}21B', '${_women ? 'Damas' : 'Homens'} Elite'];
    return (own: '$s$own', alsoOk: down, note: tr(_tNoteVet));
  }

  @override
  Widget build(BuildContext context) {
    final sub = TextStyle(fontSize: 12.5, color: context.cSubtle, height: 1.35);
    final head = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .6, color: context.cTitle);
    final year = madeiraNow().year;
    final p = _pick();

    Widget section(String t) => Padding(padding: const EdgeInsets.fromLTRB(0, 22, 0, 6), child: Text(t.toUpperCase(), style: head));
    Widget item(String key, T4 text, {Color? chip}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              constraints: const BoxConstraints(minWidth: 74),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(right: 10, top: 1),
              decoration: BoxDecoration(
                color: chip ?? context.cGreenTint,
                borderRadius: BorderRadius.circular(8),
                border: chip == Colors.white ? Border.all(color: context.cHairline) : null,
              ),
              child: Text(key,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: chip == null ? context.cTitle : (chip.computeLuminance() > .5 ? const Color(0xFF1C1B17) : Colors.white))),
            ),
            Expanded(child: Text(tr(text), style: const TextStyle(fontSize: 13.5, height: 1.3))),
          ]),
        );

    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
      Text(tr(kClassesIntro), style: sub),

      // ---------------------------------------------------- class finder
      section(tr(kSecFinder)),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: context.cSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: context.cHairline)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(tr(('Born in', 'Nascido em', 'Geboren', 'Год рождения')), style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => setState(() => _born = (_born - 1).clamp(1930, year - 6))),
            Text('$_born', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()])),
            IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => _born = (_born + 1).clamp(1930, year - 6))),
            const Spacer(),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: [
                ButtonSegment(value: false, label: Text(tr(('Men', 'Homens', 'Männer', 'Муж')))),
                ButtonSegment(value: true, label: Text(tr(('Women', 'Damas', 'Frauen', 'Жен')))),
              ],
              selected: {_women},
              onSelectionChanged: (v) => setState(() => _women = v.first),
            ),
          ]),
          Slider(
            value: _born.toDouble(),
            min: 1930,
            max: (year - 6).toDouble(),
            divisions: year - 6 - 1930,
            onChanged: (v) => setState(() => _born = v.round()),
          ),
          Text.rich(TextSpan(style: const TextStyle(fontSize: 14, height: 1.35), children: [
            TextSpan(text: tr(('In $year you turn ${year - _born}. Your class: ', 'Em $year fazes ${year - _born} anos. O teu escalão: ', '$year wirst du ${year - _born}. Deine Kategorie: ', 'В $year тебе исполняется ${year - _born}. Твоя группа: '))),
            TextSpan(text: p.own, style: TextStyle(fontWeight: FontWeight.w800, color: context.cTitle, fontSize: 16)),
          ])),
          const SizedBox(height: 4),
          Text('${tr(('Also allowed: ', 'Também podes: ', 'Auch erlaubt: ', 'Можно и в: '))}${p.alsoOk.join(', ')}', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Text(p.note, style: sub),
        ]),
      ),

      // ---------------------------------------------------- how a class is named
      section(tr(kSecNames)),
      for (final it in kClassNames) item(it.key, it.text, chip: it.chip == null ? null : Color(it.chip!)),

      // ---------------------------------------------------- open courses
      section(tr(kSecOpen)),
      Text(tr(kOpenIntro), style: sub),
      const SizedBox(height: 6),
      for (final it in kOpenCourses) item(it.key, it.text, chip: it.chip == null ? null : Color(it.chip!)),
      const SizedBox(height: 4),
      Text(tr(kOpenWarn), style: sub),

      // ---------------------------------------------------- rogaine classes
      section(tr(kSecRogaine)),
      Text(tr(kRogaineClasses), style: const TextStyle(fontSize: 13.5, height: 1.35)),

      // ---------------------------------------------------- the entry form
      section(tr(kSecEntry)),
      for (final it in kEntryForm) item(it.key, it.text, chip: it.chip == null ? null : Color(it.chip!)),

      // ---------------------------------------------------- glossary
      section(tr(kSecWords)),
      for (final it in kGlossary) item(it.key, it.text, chip: context.cSurface),
      const SizedBox(height: 16),
      Text(tr(kClassesFoot), style: TextStyle(fontSize: 11.5, color: context.cSubtle)),
    ]);
  }
}

const T4 kClassesIntro = (
  'Orienteering races are split into classes ("escalões") by sex and age, plus open courses for anyone. Here is how to choose one and what the entry form asks.',
  'As provas dividem-se em escalões por sexo e idade, mais percursos abertos para todos. Eis como escolher e o que pede a inscrição.',
  'OL-Läufe sind nach Geschlecht und Alter in Kategorien („escalões“) geteilt, dazu offene Bahnen für alle. So wählst du und das fragt die Anmeldung.',
  'Старты делятся на группы («escalões») по полу и возрасту, плюс открытые дистанции для всех. Как выбрать и что спрашивает форма заявки.'
);
const T4 _tNote10 = (
  'Children start in T10, often with a parent. From 11 the age classes begin.',
  'As crianças começam no T10, muitas vezes com um adulto. A partir dos 11 começam os escalões.',
  'Kinder starten in T10, oft mit Begleitung. Ab 11 beginnen die Altersklassen.',
  'Дети начинают с T10, часто с родителем. С 11 лет — возрастные группы.'
);
const T4 _tNoteJunior = (
  'Juniors may move up to an older class, never down. If a race has no class of exactly your age, take the next older one.',
  'Os juniores podem subir para um escalão mais velho, nunca descer. Se não houver o teu, escolhe o seguinte mais velho.',
  'Jugendliche dürfen älter laufen, nie jünger. Fehlt deine Klasse, die nächstältere nehmen.',
  'Юниоры могут бежать в старшей группе, но не в младшей. Нет твоей — бери ближайшую старшую.'
);
const T4 _tNote21 = (
  'Not sure of your level? 21B, or an open course (Verde, Amarelo, Vermelho) without ranking.',
  'Não sabes o teu nível? 21B, ou um percurso aberto (Verde, Amarelo, Vermelho) sem ranking.',
  'Unsicher? 21B oder eine offene Bahn (Verde, Amarelo, Vermelho) ohne Rangliste.',
  'Не уверен в уровне — 21B или открытая дистанция (Verde, Amarelo, Vermelho) без рейтинга.'
);
const T4 _tNoteVet = (
  'Veterans may run any younger class, never an older one. Small races merge classes, so look for your class inside a pair like "D35 / H45".',
  'Os veteranos podem correr em qualquer escalão mais novo, nunca mais velho. Provas pequenas juntam escalões: procura o teu dentro de pares como «D35 / H45».',
  'Senioren dürfen jede jüngere Klasse laufen, nie eine ältere. Kleine Läufe legen Klassen zusammen: deine steckt dann in Paaren wie „D35 / H45“.',
  'Ветеранам можно в любую младшую группу, в старшую нельзя. На маленьких стартах группы объединяют: ищи свою в паре вроде «D35 / H45».'
);
const T4 kOpenIntro = (
  'Open ("Aberto") courses are for anyone, any age, alone or in a pair. On Madeira the colours go from easy to hard: Branco, Verde, Amarelo, Vermelho. Some organisers also write Fácil / Médio / Difícil.',
  'Os percursos abertos são para todos, qualquer idade, sozinho ou a pares. Na Madeira as cores vão do fácil ao difícil: Branco, Verde, Amarelo, Vermelho. Alguns escrevem também Fácil / Médio / Difícil.',
  'Offene Bahnen („Aberto“) sind für alle, jedes Alter, allein oder zu zweit. Auf Madeira von leicht nach schwer: Branco, Verde, Amarelo, Vermelho. Manche schreiben auch Fácil / Médio / Difícil.',
  'Открытые («Aberto») — для всех, любого возраста, одному или парой. На Мадейре цвета от лёгкого к сложному: Branco, Verde, Amarelo, Vermelho. Иногда пишут Fácil / Médio / Difícil.'
);
const T4 kOpenWarn = (
  'Colours are not the same everywhere: in mainland Portugal and abroad the order can differ, and small races pair them with junior classes ("D12 / H12 / Aberto Verde"). The length and climb in the technical table tell you more than the colour.',
  'As cores não são iguais em todo o lado: no continente e no estrangeiro a ordem pode mudar, e provas pequenas juntam-nas a juniores («D12 / H12 / Aberto Verde»). Distância e desnível na tabela técnica dizem mais do que a cor.',
  'Die Farben sind nicht überall gleich: auf dem Festland und im Ausland kann die Reihenfolge abweichen, kleine Läufe koppeln sie an Jugendklassen („D12 / H12 / Aberto Verde“). Länge und Steigung in der Tabelle sagen mehr als die Farbe.',
  'Цвета не везде одинаковы: на континенте и за границей порядок бывает другим, а на маленьких стартах их объединяют с юниорами («D12 / H12 / Aberto Verde»). Длина и набор в технической таблице скажут больше цвета.'
);
const T4 kRogaineClasses = (
  'In a rogaine or score race you run in a team of two or more, with a time limit (1 h, 1 h 20, 3 h). Classes are by team: Absoluto (open age), Veteranos, Super Veteranos, each Masculino, Feminino or Misto. "Aberto 1h20" is the open course with that time limit. Late arrival costs points, usually 1 per started minute.',
  'Num rogaine ou prova de pontuação corre-se em equipa de dois ou mais, com tempo limite (1 h, 1 h 20, 3 h). Escalões por equipa: Absoluto, Veteranos, Super Veteranos, cada um Masculino, Feminino ou Misto. «Aberto 1h20» é o percurso aberto com esse limite. Atraso custa pontos, em geral 1 por minuto começado.',
  'Beim Rogaine oder Score-OL läuft man im Team ab zwei, mit Zeitlimit (1 h, 1 h 20, 3 h). Kategorien nach Team: Absoluto, Veteranos, Super Veteranos, jeweils Masculino, Feminino oder Misto. „Aberto 1h20“ ist die offene Bahn mit diesem Limit. Verspätung kostet Punkte, meist 1 je angefangene Minute.',
  'В рогейне и score бегут командой от двух человек с лимитом времени (1 ч, 1 ч 20, 3 ч). Группы — по составу команды: Absoluto, Veteranos, Super Veteranos, каждая Masculino, Feminino или Misto. «Aberto 1h20» — открытая дистанция с таким лимитом. Опоздание стоит очков, обычно 1 за каждую начатую минуту.'
);
const T4 kClassesFoot = (
  'Class rules follow the Portuguese federation (FPO) and the Madeira races of 2023–2026; each event can differ, so check its "Informações" page.',
  'As regras seguem a FPO e as provas da Madeira de 2023–2026; cada prova pode variar, confirma em «Informações».',
  'Die Regeln folgen dem portugiesischen Verband (FPO) und den Madeira-Läufen 2023–2026; jede Veranstaltung kann abweichen, „Informações“ prüfen.',
  'Правила — по федерации FPO и стартам Мадейры 2023–2026; у каждого старта бывают отличия, смотри «Informações».'
);

const List<ClassItem> kGlossary = [
  ClassItem('Escalão', ('Class', 'Categoria por sexo e idade', 'Kategorie', 'Группа')),
  ClassItem('Percurso', ('Course: the line of controls you run', 'Sequência de pontos a fazer', 'Bahn: die Postenfolge', 'Дистанция: последовательность КП')),
  ClassItem('Secretariado', ('Event office: chips, maps for later, results', 'Onde se levantam chips e se veem resultados', 'Wettkampfbüro: Chips, Ergebnisse', 'Секретариат: чипы, результаты')),
  ClassItem('Partida', ('Start', 'Início da prova', 'Start', 'Старт')),
  ClassItem('Chegada', ('Finish', 'Fim da prova', 'Ziel', 'Финиш')),
  ClassItem('Baliza · Ponto', ('Control: the orange and white flag', 'A bandeira laranja e branca', 'Posten: der orange-weiße Schirm', 'КП: оранжево-белая призма')),
  ClassItem('Picar', ('To punch: put the chip into the unit', 'Pôr o chip na estação', 'Stempeln: Chip in die Station', 'Отметиться: вставить чип в станцию')),
  ClassItem('Descarga', ('Downloading your chip after the finish', 'Ler o chip depois da chegada', 'Auslesen nach dem Ziel', 'Считывание чипа после финиша')),
  ClassItem('Sinalética', ('Control descriptions', 'Descrição dos pontos em símbolos', 'Postenbeschreibung', 'Легенда КП')),
  ClassItem('Escala', ('Scale: 1:4000 means 1 cm = 40 m', '1:4000 quer dizer 1 cm = 40 m', 'Maßstab: 1:4000 heißt 1 cm = 40 m', 'Масштаб: 1:4000 — 1 см = 40 м')),
  ClassItem('Equidistância', ('Contour interval: height between brown lines', 'Diferença de altura entre curvas', 'Äquidistanz: Höhe zwischen den braunen Linien', 'Сечение рельефа: высота между коричневыми линиями')),
  ClassItem('Desnível', ('Climb along the best route, in metres', 'Subida pelo melhor caminho, em metros', 'Steigung auf der besten Route, in Metern', 'Набор высоты по оптимальному пути, м')),
  ClassItem('Aluguer', ('Rental (of the chip)', 'Aluguer do chip', 'Miete (des Chips)', 'Прокат (чипа)')),
  ClassItem('PM · DSQ', ('Mispunch / disqualified: a control missing or wrong order', 'Ponto em falta ou fora de ordem', 'Fehlstempel / disqualifiziert', 'Пропуск КП / снят')),
  ClassItem('Partida em massa', ('Mass start: everyone at once', 'Todos partem ao mesmo tempo', 'Massenstart', 'Общий старт')),
  ClassItem('Estafeta', ('Relay', 'Prova por equipas em revezamento', 'Staffel', 'Эстафета')),
  ClassItem('Boleias', ('Car sharing to the venue', 'Partilha de carro até à prova', 'Mitfahrgelegenheit', 'Попутки до места старта')),
  ClassItem('Reprodução interdita', ('Copying the map is not allowed', 'Não é permitido copiar o mapa', 'Vervielfältigung verboten', 'Копировать карту запрещено')),
];


const List<ClassItem> kClassNames = [
  ClassItem('H · D', ('H = Homens, men; D = Damas, women. Some Madeira races write M/F or Masculino/Feminino.', 'H = Homens; D = Damas. Algumas provas escrevem M/F ou Masculino/Feminino.', 'H = Homens, Männer; D = Damas, Frauen. Manche Läufe schreiben M/F.', 'H — Homens, мужчины; D — Damas, женщины. Иногда пишут M/F или Masculino/Feminino.'), null),
  ClassItem('12 … 20', ('Juniors: the oldest age you may be that year. H14 is for boys who turn 13 or 14. Juniors may run an older class, never a younger one.', 'Juniores: a idade máxima nesse ano. H14 é para quem faz 13 ou 14. Pode-se correr num escalão mais velho, nunca mais novo.', 'Jugend: das Höchstalter im Jahr. H14 ist für Jungen, die 13 oder 14 werden. Älter laufen geht, jünger nicht.', 'Юниоры: максимальный возраст в этом году. H14 — для тех, кому исполняется 13 или 14. Можно бежать в старшей группе, в младшей — нельзя.'), null),
  ClassItem('21 · E', ('Seniors. Elite (HE/DE) is the longest and hardest course and counts for the ranking; most racers run 21A.', 'Seniores. Elite (HE/DE) é o percurso mais longo e difícil e conta para o ranking; a maioria corre 21A.', 'Hauptklasse. Elite (HE/DE) ist die längste und schwerste Bahn und zählt für die Rangliste; die meisten laufen 21A.', 'Взрослые. Элита (HE/DE) — самая длинная и сложная дистанция, идёт в рейтинг; большинство бежит 21A.'), null),
  ClassItem('A · B', ('21A is long and technical; 21B (or HB/DB) is shorter and a little easier — a good first ranked class for adults.', '21A é longo e técnico; 21B (ou HB/DB) é mais curto e um pouco mais fácil — bom primeiro escalão de competição para adultos.', '21A ist lang und technisch; 21B (HB/DB) ist kürzer und etwas leichter — gut als erste Wertungsklasse für Erwachsene.', '21A — длинная и техничная; 21B (HB/DB) короче и чуть проще — хорошая первая зачётная группа для взрослых.'), null),
  ClassItem('35 … 80', ('Veterans: the youngest age that year. H45 is for men who turn 45 to 49. You may run a younger class (H35, H21), never an older one. Small races merge classes: "D35 / H45 / H20" is one course.', 'Veteranos: a idade mínima nesse ano. H45 é para quem faz 45 a 49. Podes correr num escalão mais novo (H35, H21), nunca mais velho. Provas pequenas juntam escalões: «D35 / H45 / H20» é um só percurso.', 'Senioren: das Mindestalter im Jahr. H45 ist für Männer, die 45 bis 49 werden. Jünger laufen geht (H35, H21), älter nicht. Kleine Läufe legen zusammen: „D35 / H45 / H20“ ist eine Bahn.', 'Ветераны: минимальный возраст в этом году. H45 — кому исполняется 45–49. Можно бежать в младшей (H35, H21), в старшей — нельзя. На маленьких стартах группы объединяют: «D35 / H45 / H20» — одна дистанция.'), null),
  ClassItem('T10', ('Children up to 10, boys and girls together, often with a parent.', 'Crianças até 10 anos, rapazes e raparigas juntos, muitas vezes com um adulto.', 'Kinder bis 10, gemeinsam, oft mit einem Elternteil.', 'Дети до 10 лет, мальчики и девочки вместе, часто с родителем.'), null),
  ClassItem('Ranking', ('"Ranking Competition" classes count for the FPO / regional ranking. "Extra-Competition" have results but no ranking points. Open courses have neither.', '«Ranking Competição» conta para o ranking FPO / regional. «Extra-Competição» tem resultados mas sem pontos. Os abertos não têm nenhum.', '„Ranking Competição“ zählt für die FPO- bzw. Regionalrangliste, „Extra-Competição“ hat Ergebnisse ohne Punkte, offene Bahnen keins von beiden.', '«Ranking Competição» — идёт в рейтинг FPO / региона. «Extra-Competição» — результат есть, очков нет. Открытые — ни того, ни другого.'), null),
];

const List<ClassItem> kOpenCourses = [
  ClassItem('Branco', ('Initiation. Very short, along paths and taped lines. First time ever, or with small children.', 'Iniciação. Muito curto, por caminhos e fitas. Primeira vez, ou com crianças pequenas.', 'Einsteiger. Sehr kurz, auf Wegen und markierten Linien. Das erste Mal oder mit kleinen Kindern.', 'Знакомство. Очень коротко, по дорожкам и разметке. Впервые или с маленькими детьми.'), 0xFFFFFFFF),
  ClassItem('Verde', ('Easy ("Fácil"). Controls on paths and obvious features. Good first race for adults.', 'Fácil. Pontos em caminhos e objetos evidentes. Boa primeira prova para adultos.', 'Leicht („Fácil“). Posten an Wegen und deutlichen Objekten. Gut als erster Lauf für Erwachsene.', 'Лёгкая («Fácil»). КП на дорожках и явных объектах. Хороший первый старт для взрослых.'), 0xFF3A9B3A),
  ClassItem('Amarelo', ('Medium ("Médio"). Some route choice and controls off the paths.', 'Médio. Alguma escolha de caminho e pontos fora dos trilhos.', 'Mittel („Médio“). Etwas Routenwahl, Posten abseits der Wege.', 'Средняя («Médio»). Есть выбор пути, КП в стороне от дорожек.'), 0xFFFFC20E),
  ClassItem('Vermelho', ('Hard ("Difícil"). The same technical level as the ranked adult courses, just without the ranking.', 'Difícil. O mesmo nível técnico dos escalões de competição, só sem ranking.', 'Schwer („Difícil“). Technisch wie die Wertungsklassen, nur ohne Rangliste.', 'Сложная («Difícil»). Техника как у зачётных взрослых дистанций, только без рейтинга.'), 0xFFD32F2F),
];

const List<ClassItem> kEntryForm = [
  ClassItem('Clube', ('No club? Pick "Individual POR". You can still enter every race.', 'Sem clube? Escolhe «Individual POR». Podes inscrever-te em todas as provas.', 'Kein Verein? „Individual POR“ wählen. Alle Läufe stehen trotzdem offen.', 'Без клуба — «Individual POR». Записываться можно на всё.'), null),
  ClassItem('SI', ('Your SPORTident chip number. No chip? Leave it empty and choose "Aluguer" (rental, 1–3 €); you get one at the desk.', 'O número do teu chip SPORTident. Sem chip? Deixa vazio e escolhe «Aluguer» (1–3 €); recebes no secretariado.', 'Deine SPORTident-Chipnummer. Keiner? Leer lassen und „Aluguer“ (Miete, 1–3 €) wählen; Ausgabe im Wettkampfbüro.', 'Номер чипа SPORTident. Нет своего — оставь пустым и выбери «Aluguer» (прокат, 1–3 €), выдадут в секретариате.'), null),
  ClassItem('Taxa', ('Fee per stage. Without an FPO licence ("não federado") it is a little higher: it includes the day insurance.', 'Taxa por etapa. Sem licença FPO («não federado») é um pouco mais alta: inclui o seguro do dia.', 'Gebühr pro Etappe. Ohne FPO-Lizenz („não federado“) etwas höher: Tagesversicherung inklusive.', 'Взнос за этап. Без лицензии FPO («não federado») чуть дороже — включает страховку на день.'), null),
  ClassItem('Limite', ('Entry deadlines: "com desconto" is the cheap one; after "inscrições online" you can only ask the organiser.', 'Prazos: «com desconto» é o mais barato; depois de «inscrições online» só pedindo à organização.', 'Meldeschluss: „com desconto“ ist der günstige; nach „inscrições online“ nur noch beim Veranstalter.', 'Сроки: «com desconto» — со скидкой; после «inscrições online» — только через организатора.'), null),
  ClassItem('AVC', ('Waiting for your club to confirm. Individuals skip this step.', 'Aguarda validação do clube. Individuais saltam este passo.', 'Wartet auf den Verein. Einzelstarter überspringen das.', 'Ждёт подтверждения клуба. У индивидуалов этого шага нет.'), 0xFFF4A3A3),
  ClassItem('AVO', ('Waiting for the organiser — usually it means "not paid yet". Some clubs want a transfer to the IBAN on the event page, others take the fee at the desk on the day, sometimes cash only.', 'Aguarda a organização — em geral quer dizer «ainda não pago». Alguns clubes pedem transferência para o IBAN da prova, outros cobram no secretariado no dia, às vezes só em dinheiro.', 'Wartet auf den Veranstalter — meist heißt das „noch nicht bezahlt“. Manche Vereine wollen eine Überweisung auf die IBAN der Eventseite, andere kassieren am Lauftag im Büro, manchmal nur bar.', 'Ждёт организатора — обычно значит «ещё не оплачено». Одни клубы просят перевод на IBAN со страницы старта, другие берут взнос в секретариате в день старта, иногда только наличными.'), 0xFF5B6CF0),
  ClassItem('OK', ('Confirmed. Your name will be on the start list, published a day or two before.', 'Confirmada. O teu nome aparece na lista de partidas, publicada um ou dois dias antes.', 'Bestätigt. Dein Name steht auf der Startliste, die ein bis zwei Tage vorher erscheint.', 'Подтверждено. Ты в стартовом протоколе, его публикуют за день-два.'), 0xFFBFF0C4),
];

class ClassItem {
  const ClassItem(this.key, this.text, [this.chip]);
  final String key;
  final T4 text;
  final int? chip; // ARGB, null = the green tint
}

const T4 kSecFinder = ('Which class is mine?', 'Qual é o meu escalão?', 'Welche Kategorie ist meine?', 'Какая группа моя?');
const T4 kSecNames = ('Reading a class name', 'Como se lê um escalão', 'Kategorien lesen', 'Как читать название группы');
const T4 kSecOpen = ('Open courses: no age, no licence', 'Percursos abertos: sem idade, sem licença', 'Offene Bahnen: ohne Alter, ohne Lizenz', 'Открытые дистанции: без возраста и лицензии');
const T4 kSecRogaine = ('Rogaine and score classes', 'Rogaine e escalões de pontuação', 'Rogaine- und Score-Kategorien', 'Рогейн и score: группы');
const T4 kSecEntry = ('The entry form on orioasis.pt', 'A inscrição no orioasis.pt', 'Die Anmeldung auf orioasis.pt', 'Форма заявки на orioasis.pt');
const T4 kSecWords = ('Words on the sheets', 'Palavras das folhas', 'Begriffe auf den Blättern', 'Слова на листах');
