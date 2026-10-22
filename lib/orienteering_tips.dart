import 'package:flutter/material.dart';

import 'main.dart';
import 'orienteering.dart' show T4, tr;

/// What Madeira's orienteering runners keep telling newcomers: distilled from
/// three and a half years (2023–2026) of a club's own discussions after races,
/// paraphrased, no names. The site's orienteering page shows the same list.

class TipsTab extends StatelessWidget {
  const TipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final head = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .6, color: context.cTitle);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
      Text(tr(kTipsIntro), style: TextStyle(fontSize: 12.5, color: context.cSubtle, height: 1.35)),
      for (final (i, (title, tips)) in kTips.indexed) ...[
        Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 6), child: Text(tr(title).toUpperCase(), style: head)),
        Container(
          decoration: i == 0
              ? BoxDecoration(color: context.cGreenTint, borderRadius: BorderRadius.circular(14))
              : null,
          padding: i == 0 ? const EdgeInsets.fromLTRB(12, 8, 12, 8) : EdgeInsets.zero,
          child: Column(children: [
            for (final (n, t) in tips.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    width: 24,
                    child: Text(i == 0 ? '${n + 1}.' : '•',
                        style: TextStyle(fontWeight: FontWeight.w700, color: context.cTitle, fontSize: 14)),
                  ),
                  Expanded(child: Text(tr(t), style: const TextStyle(fontSize: 14, height: 1.35))),
                ]),
              ),
          ]),
        ),
      ],
    ]);
  }
}

const T4 kTipsIntro = (
  'What experienced runners on Madeira keep telling newcomers, gathered from three seasons of race talk (2023–2026).',
  'O que os orientistas experientes da Madeira repetem aos principiantes, recolhido em três épocas de conversas depois das provas (2023–2026).',
  'Was erfahrene Läufer auf Madeira Neulingen immer wieder sagen, gesammelt aus drei Saisons Gesprächen nach den Läufen (2023–2026).',
  'Что опытные ориентировщики Мадейры повторяют новичкам — собрано из разговоров после стартов за три сезона (2023–2026).'
);

const List<(T4, List<T4>)> kTips = [
  (
    ('The five that matter most', 'Os cinco mais importantes', 'Die fünf wichtigsten', 'Пять главных'),
    [
      ('Check the control code before you punch, and wait for the beep or flash. Missed and wrong controls cost more places than slow legs.', 'Confirma o código antes de picar e espera pelo apito ou luz. Pontos falhados ou trocados custam mais lugares do que pernas lentas.', 'Code prüfen, bevor du stempelst, und auf Piepen oder Blinken warten. Fehlende oder falsche Posten kosten mehr Plätze als langsame Strecken.', 'Сверь код до отметки и дождись писка или вспышки. Пропущенные и чужие КП стоят больше мест, чем медленные перегоны.'),
      ('Plan every leg: an attack point near the control, the features you will pass, and a stopper behind it — a stream, a road, a change of slope.', 'Planeia cada perna: um ponto de ataque perto do ponto, os objetos por onde passas e um «travão» depois dele — ribeira, estrada, mudança de declive.', 'Jede Strecke planen: Angriffspunkt nahe am Posten, die Objekte unterwegs und ein Auffangobjekt dahinter — Bach, Straße, Hangknick.', 'Планируй каждый перегон: точка атаки у КП, ориентиры по пути и «стоппер» за КП — ручей, дорога, перегиб склона.'),
      ('Count contours before going straight. On Madeira the road or the level path is often as fast and far kinder to the legs.', 'Conta as curvas antes de ir a direito. Na Madeira a estrada ou o caminho plano é muitas vezes tão rápido e poupa as pernas.', 'Höhenlinien zählen, bevor du gerade gehst. Auf Madeira ist die Straße oder der flache Weg oft genauso schnell und schont die Beine.', 'Сначала посчитай горизонтали, потом иди напрямик. На Мадейре дорога или ровная тропа часто не медленнее и щадит ноги.'),
      ('Do not follow other runners. They are usually on another course.', 'Não sigas os outros. Quase sempre estão noutro percurso.', 'Anderen nicht folgen. Sie sind fast immer auf einer anderen Bahn.', 'Не беги за другими — они почти всегда на другой дистанции.'),
      ('After the race, compare your splits and your GPS track with the winners. One bad control usually decides your place.', 'Depois da prova, compara os parciais e o teu traçado GPS com os vencedores. Um ponto mau decide quase sempre o lugar.', 'Nach dem Lauf Zwischenzeiten und GPS-Spur mit den Siegern vergleichen. Meist entscheidet ein einziger schlechter Posten.', 'После старта сравни сплиты и GPS-трек с победителями. Обычно место решает один неудачный КП.'),
    ]
  ),
  (
    ('At the start', 'Na partida', 'Am Start', 'На старте'),
    [
      ('Arrive an hour early. The start is often 0.5–2 km uphill from the event office, and mountain venues have little parking.', 'Chega uma hora antes. A partida fica muitas vezes a 0,5–2 km a subir do secretariado e na serra há pouco estacionamento.', 'Eine Stunde früher da sein. Der Start liegt oft 0,5–2 km bergauf vom Wettkampfbüro, in den Bergen gibt es wenig Parkplätze.', 'Приезжай за час. Старт часто в 0,5–2 км в гору от секретариата, а в горах мало парковки.'),
      ('Clear, check, then punch start when your minute comes. At the end: finish, then download the chip — even if you gave up.', 'Limpar, verificar e picar a partida no teu minuto. No fim: chegada e descarga do chip — mesmo se desististe.', 'Löschen, prüfen, zur Startminute Start stempeln. Am Ende: Ziel, dann Chip auslesen — auch bei Aufgabe.', 'Очистка, проверка, отметка старта в свою минуту. В конце — финиш и считывание чипа, даже если сошёл.'),
      ('Check the map shows your course or class before you run.', 'Confirma que o mapa tem o teu percurso ou escalão antes de partir.', 'Prüfe, ob die Karte deine Bahn oder Kategorie zeigt.', 'Убедись, что на карте твоя дистанция или группа.'),
      ('First glance: scale and contour interval, then where the last controls and the finish are.', 'Primeiro olhar: escala e equidistância, depois onde ficam os últimos pontos e a chegada.', 'Erster Blick: Maßstab und Äquidistanz, dann wo die letzten Posten und das Ziel liegen.', 'Первый взгляд: масштаб и сечение, потом где последние КП и финиш.'),
      ('The control is in the centre of the circle, not where the number is printed.', 'O ponto está no centro do círculo, não onde está o número.', 'Der Posten ist in der Kreismitte, nicht bei der Zahl.', 'КП — в центре кружка, а не там, где напечатан номер.'),
    ]
  ),
  (
    ('Technique', 'Técnica', 'Technik', 'Техника'),
    [
      ('Aim off on purpose: set your direction a little to one side, so at the catching feature you know which way to turn.', 'Desvia de propósito: aponta um pouco para um lado, para saberes para onde virar ao chegar ao «travão».', 'Absichtlich vorhalten: leicht seitlich zielen, dann weißt du am Auffangobjekt, wohin du abbiegst.', 'Намеренно смещай направление в сторону, чтобы у стоппера знать, куда поворачивать.'),
      ('Use lines as handrails: walls, fences, streams, levadas, power lines, vegetation edges.', 'Usa linhas como corrimão: muros, vedações, ribeiras, levadas, linhas elétricas, limites de vegetação.', 'Linien als Geländer nutzen: Mauern, Zäune, Bäche, Levadas, Stromleitungen, Vegetationsgrenzen.', 'Используй линии как перила: стены, заборы, ручьи, левады, ЛЭП, границы растительности.'),
      ('Slow down near the control and read its description. Read the next leg while you punch.', 'Abranda perto do ponto e lê a sinalética. Lê a perna seguinte enquanto picas.', 'Vor dem Posten langsamer werden und die Beschreibung lesen. Beim Stempeln schon die nächste Strecke lesen.', 'У КП сбавь ход и прочитай легенду. Следующий перегон читай, пока отмечаешься.'),
      ('Parallel errors are the classic trap: the stream, path bend or road just beside the right one.', 'O erro paralelo é a armadilha clássica: a ribeira, curva ou estrada mesmo ao lado da certa.', 'Parallelfehler sind die klassische Falle: der Bach, die Kurve oder Straße gleich neben der richtigen.', 'Классическая ловушка — параллельная ошибка: соседний ручей, изгиб тропы или дорога рядом с нужной.'),
      ('Lost? Go back to the last point you were sure of, or to a big line like a road. Do not wander.', 'Perdido? Volta ao último ponto de que tinhas certeza, ou a uma linha grande como uma estrada. Não andes às voltas.', 'Verlaufen? Zurück zum letzten sicheren Punkt oder zu einer großen Linie wie einer Straße. Nicht herumirren.', 'Потерялся — вернись к последней точной точке или к крупной линии вроде дороги. Не кружи.'),
      ('Faint paths come and go; trust big features and direction more than every small path.', 'Trilhos fracos aparecem e desaparecem; confia mais nos objetos grandes e na direção.', 'Schwache Pfade kommen und gehen; großen Objekten und der Richtung mehr trauen.', 'Слабые тропинки то есть, то нет — доверяй крупным объектам и направлению.'),
      ('When unsure, take the route you understand, even if it is longer.', 'Na dúvida, escolhe o caminho que percebes, mesmo que seja mais longo.', 'Im Zweifel die Route nehmen, die du verstehst, auch wenn sie länger ist.', 'Сомневаешься — выбирай понятный путь, даже если он длиннее.'),
    ]
  ),
  (
    ('In Madeira\'s towns', 'Nas vilas da Madeira', 'In Madeiras Orten', 'В городах Мадейры'),
    [
      ('Town courses are steep: stairs, terraces, gardens and dead-end lanes. Read the contours in town too.', 'Os percursos urbanos são íngremes: escadas, socalcos, quintais e becos sem saída. Lê as curvas também na vila.', 'Stadtbahnen sind steil: Treppen, Terrassen, Gärten, Sackgassen. Auch in der Stadt die Höhenlinien lesen.', 'Городские дистанции крутые: лестницы, террасы, огороды, тупики. Читай горизонтали и в городе.'),
      ('Never cross a thick black wall or a fence drawn as impassable, even if you could climb it: disqualification.', 'Nunca atravesses um muro preto grosso ou vedação intransponível, mesmo que dê para trepar: desclassificação.', 'Nie eine dicke schwarze Mauer oder einen unpassierbaren Zaun queren, auch wenn es ginge: Disqualifikation.', 'Не пересекай толстую чёрную стену и непреодолимый забор, даже если можно перелезть: дисквалификация.'),
      ('Olive green is private or out of bounds, not rough ground.', 'Verde-oliva é privado ou interdito, não terreno difícil.', 'Olivgrün ist privat oder gesperrt, kein schwieriges Gelände.', 'Оливковый — частная или запретная зона, а не трудная местность.'),
      ('Car parks and lifts are not shortcuts. A building without contours can hide a raised deck or roof with a control on it.', 'Parques de estacionamento e elevadores não são atalhos. Um edifício sem curvas pode esconder um terraço ou cobertura com um ponto.', 'Parkhäuser und Aufzüge sind keine Abkürzungen. Ein Gebäude ohne Höhenlinien kann ein Deck oder Dach mit Posten sein.', 'Парковки и лифты — не срезка. Здание без горизонталей может оказаться крышей или террасой с КП.'),
      ('Many controls stand close together and courses cross: check the code every time.', 'Muitos pontos ficam juntos e os percursos cruzam-se: confirma sempre o código.', 'Viele Posten stehen dicht beieinander, Bahnen kreuzen sich: immer den Code prüfen.', 'Много КП рядом, дистанции пересекаются — каждый раз сверяй код.'),
      ('Watch for traps: closed staircases, locked gates, passages under roofs, levada tunnels, multi-level streets.', 'Cuidado com armadilhas: escadas fechadas, portões trancados, passagens cobertas, túneis de levada, ruas em vários níveis.', 'Auf Fallen achten: gesperrte Treppen, verschlossene Tore, überdachte Durchgänge, Levada-Tunnel, Straßen auf mehreren Ebenen.', 'Ловушки: закрытые лестницы, запертые калитки, проходы под крышей, тоннели левад, улицы в несколько уровней.'),
    ]
  ),
  (
    ('Forest and mountains', 'Floresta e serra', 'Wald und Berge', 'Лес и горы'),
    [
      ('Laurel forest, brambles and dark green can cost 20–40 minutes. Prefer paths, roads and spurs unless the forest is open.', 'Laurissilva, silvas e verde escuro podem custar 20–40 minutos. Prefere trilhos, estradas e esporões, salvo floresta aberta.', 'Lorbeerwald, Brombeeren und Dunkelgrün kosten leicht 20–40 Minuten. Lieber Wege, Straßen und Rücken, außer im offenen Wald.', 'Лаврисилва, ежевика и тёмная зелень могут стоить 20–40 минут. Выбирай тропы, дороги и отроги, если лес не открытый.'),
      ('Short black lines all over a slope are terrace walls. Pick a distinctive tree or boulder as your attack point.', 'Pequenas linhas pretas pela encosta são muros de socalcos. Escolhe uma árvore ou pedra marcante como ponto de ataque.', 'Viele kurze schwarze Linien am Hang sind Terrassenmauern. Einen markanten Baum oder Felsen als Angriffspunkt wählen.', 'Множество коротких чёрных линий на склоне — стенки террас. Бери за точку атаки заметное дерево или камень.'),
      ('A route down into a deep valley and up again is usually a trap; contour along the spur instead.', 'Descer a um vale fundo e voltar a subir é quase sempre armadilha; contorna pelo esporão.', 'Tief ins Tal und wieder hinauf ist meist eine Falle; lieber am Rücken entlang höhenlinienparallel.', 'Спуск в глубокую долину и подъём обратно — обычно ловушка; лучше обойти по отрогу.'),
      ('In fog, walk. Run only when you are sure of direction and distance.', 'Com nevoeiro, anda. Corre só quando tens certeza da direção e da distância.', 'Im Nebel gehen. Nur laufen, wenn Richtung und Entfernung sicher sind.', 'В тумане иди шагом. Беги, только если уверен в направлении и расстоянии.'),
      ('Mainland Portugal is another world: bigger scales, 2.5 m contours, runnable white forest. Recalibrate.', 'O continente é outro mundo: escalas maiores, curvas de 2,5 m, floresta branca corrível. Recalibra.', 'Das Festland ist eine andere Welt: größere Maßstäbe, 2,5-m-Linien, belaufbarer weißer Wald. Neu einstellen.', 'Континент — другой мир: другие масштабы, сечение 2,5 м, белый беговой лес. Перестраивайся.'),
    ]
  ),
  (
    ('Rogaine and score', 'Rogaine e pontuação', 'Rogaine und Score', 'Рогейн и score'),
    [
      ('Points are the code without its last digit: 152 is worth 15.', 'Os pontos são o código sem o último algarismo: 152 vale 15.', 'Punkte sind der Code ohne letzte Ziffer: 152 ist 15 wert.', 'Очки — код без последней цифры: 152 = 15 очков.'),
      ('Late costs points — usually 1 a minute — and after about 10 minutes the whole result.', 'O atraso custa pontos — em geral 1 por minuto — e após cerca de 10 minutos o resultado inteiro.', 'Verspätung kostet Punkte — meist 1 pro Minute — und nach etwa 10 Minuten das ganze Ergebnis.', 'Опоздание стоит очков — обычно 1 в минуту, а примерно после 10 минут — весь результат.'),
      ('Plan a big loop with a decision point halfway: there, add a far control or cut home.', 'Planeia uma volta grande com um ponto de decisão a meio: aí juntas um ponto longe ou cortas para casa.', 'Eine große Schleife mit Entscheidungspunkt zur Hälfte planen: dort einen fernen Posten dazu oder abkürzen.', 'Планируй большой круг с точкой решения на середине: там добавляешь дальний КП или срезаешь к финишу.'),
      ('Think in clusters and points per minute, not single controls. Do not pass a cheap control right on your line.', 'Pensa em grupos de pontos e pontos por minuto, não em pontos soltos. Não passes ao lado de um ponto barato no teu caminho.', 'In Gruppen und Punkten pro Minute denken, nicht in Einzelposten. Keinen billigen Posten direkt am Weg auslassen.', 'Считай кластеры и очки в минуту, а не отдельные КП. Не пропускай дешёвый КП прямо на пути.'),
      ('Finish high and run the last controls downhill. Measure the climb back before going for the farthest one.', 'Acaba em cima e faz os últimos pontos a descer. Mede a subida de regresso antes de ir ao ponto mais longe.', 'Oben enden, die letzten Posten bergab. Vor dem fernsten Posten den Rückweg-Anstieg abschätzen.', 'Заканчивай наверху, последние КП — под гору. Перед самым дальним КП прикинь подъём обратно.'),
      ('Mistakes rise with speed in the second half. Re-plan rather than rush; no gambles through bushes near the limit.', 'Os erros aumentam com a pressa na segunda metade. Replaneia em vez de correr; nada de atalhos pelo mato perto do fim.', 'In der zweiten Hälfte steigen die Fehler mit dem Tempo. Neu planen statt hetzen; kurz vor Schluss keine Abkürzung durchs Gebüsch.', 'Во второй половине ошибки растут со скоростью. Лучше перепланируй, чем спеши; никаких срезок через кусты под конец.'),
      ('The team moves at its slowest member\'s pace. Walk the climbs, run the flats and descents.', 'A equipa anda ao ritmo do mais lento. Sobe a andar, corre no plano e nas descidas.', 'Das Team läuft im Tempo des Langsamsten. Anstiege gehen, Flaches und Bergab laufen.', 'Команда движется со скоростью самого медленного. Подъёмы — шагом, равнину и спуски — бегом.'),
    ]
  ),
  (
    ('Kit', 'Equipamento', 'Ausrüstung', 'Снаряжение'),
    [
      ('A thumb compass on the map hand. Red points north — and check yours against a friend\'s once.', 'Bússola de polegar na mão do mapa. O vermelho aponta o norte — e compara a tua com a de um amigo.', 'Daumenkompass an der Kartenhand. Rot zeigt nach Norden — einmal mit dem eines Freundes vergleichen.', 'Компас на большой палец руки с картой. Красная стрелка — север; разок сверь с компасом друга.'),
      ('Firm trail shoes grip on rock and roots better than soft cushioned ones. Long legs or socks against brambles.', 'Sapatilhas de trail firmes agarram melhor em pedra e raízes do que as muito macias. Pernas tapadas contra as silvas.', 'Feste Trailschuhe greifen auf Fels und Wurzeln besser als weich gedämpfte. Lange Hosen oder Stutzen gegen Brombeeren.', 'Жёсткие трейловые кроссовки держат на камнях и корнях лучше мягких. Длинные штаны или гетры от ежевики.'),
      ('Winter uplands sit at 5–10 °C with fog: windbreaker, dry clothes, spare shoes.', 'No inverno as serras ficam a 5–10 °C com nevoeiro: corta-vento, roupa seca, sapatilhas extra.', 'Im Winter hat das Hochland 5–10 °C und Nebel: Windjacke, trockene Kleidung, Ersatzschuhe.', 'Зимой в горах 5–10 °C и туман: ветровка, сухая одежда, запасная обувь.'),
      ('Night stages: a headlamp you can tilt, charged the day before.', 'Etapas noturnas: frontal inclinável, carregado na véspera.', 'Nachtetappen: neigbare Stirnlampe, am Vortag geladen.', 'Ночные этапы: налобный фонарь с наклоном, заряженный накануне.'),
      ('A holder for the control descriptions on your wrist or arm.', 'Um porta-sinalética no pulso ou no braço.', 'Eine Halterung für die Postenbeschreibung am Handgelenk oder Arm.', 'Держатель для легенды на запястье или руке.'),
      ('A GPS watch, started before the start punch, gives you a track to compare later.', 'Um relógio GPS, ligado antes de picar a partida, dá-te o traçado para comparar.', 'Eine GPS-Uhr, vor dem Startstempel gestartet, liefert die Spur zum Vergleichen.', 'GPS-часы, включённые до отметки старта, дадут трек для сравнения.'),
    ]
  ),
  (
    ('After the race', 'Depois da prova', 'Nach dem Lauf', 'После старта'),
    [
      ('Before you hand in the chip, make sure every control is punched. You may go back for a missed one only in order and before the readout.', 'Antes de entregar o chip, confirma que picaste todos. Só podes voltar a um ponto falhado pela ordem e antes da descarga.', 'Vor der Abgabe prüfen, ob alle Posten gestempelt sind. Zurück zu einem fehlenden nur in Reihenfolge und vor dem Auslesen.', 'Прежде чем сдать чип, проверь все отметки. Вернуться за пропущенным КП можно только по порядку и до считывания.'),
      ('Splits show whether you lost time to navigation or to speed. A leg 30 % slower than the best was a mistake, not your legs.', 'Os parciais mostram se perdeste tempo na navegação ou na velocidade. Uma perna 30 % mais lenta que a melhor foi erro, não pernas.', 'Zwischenzeiten zeigen, ob Navigation oder Tempo Zeit gekostet hat. 30 % langsamer als der Beste war ein Fehler, nicht die Beine.', 'Сплиты показывают, где ушло время — на навигацию или на скорость. Перегон на 30 % медленнее лучшего — ошибка, а не ноги.'),
      ('Livelox lets you replay your route against the winners leg by leg. Trust the official splits for times.', 'O Livelox mostra o teu caminho contra os vencedores, perna a perna. Para tempos, confia nos parciais oficiais.', 'Livelox spielt deine Route gegen die Sieger ab, Strecke für Strecke. Für Zeiten den offiziellen Splits trauen.', 'Livelox показывает твой путь рядом с победителями по перегонам. Время — по официальным сплитам.'),
      ('Keep your map and draw your route on it. Post a hard leg and ask others how they would run it — that is how clubs learn.', 'Guarda o mapa e desenha o teu caminho. Partilha uma perna difícil e pergunta como os outros a fariam — é assim que os clubes aprendem.', 'Karte behalten, Route einzeichnen. Eine schwierige Strecke teilen und fragen, wie andere sie laufen würden — so lernen Vereine.', 'Сохрани карту и нарисуй свой путь. Выложи сложный перегон и спроси, как пошли бы другие — так учатся клубы.'),
    ]
  ),
  (
    ('Common beginner mistakes', 'Erros comuns de principiante', 'Typische Anfängerfehler', 'Типичные ошибки новичков'),
    [
      ('Missing a control "on the way", often the second-to-last.', 'Falhar um ponto «de passagem», muitas vezes o penúltimo.', 'Einen Posten „unterwegs“ auslassen, oft den vorletzten.', 'Пропустить КП «по пути», часто предпоследний.'),
      ('Punching a nearby control of another course, or a similar number (134 for 143).', 'Picar um ponto vizinho de outro percurso, ou um número parecido (134 em vez de 143).', 'Einen nahen Posten einer anderen Bahn stempeln oder eine ähnliche Nummer (134 statt 143).', 'Отметиться на соседнем КП чужой дистанции или с похожим номером (134 вместо 143).'),
      ('Reading a pit as a hill without checking the description.', 'Ler uma cova como um morro sem ver a sinalética.', 'Eine Senke als Kuppe lesen, ohne die Beschreibung zu prüfen.', 'Принять яму за холм, не заглянув в легенду.'),
      ('Running off the edge of the map.', 'Sair do mapa.', 'Über den Kartenrand hinauslaufen.', 'Выбежать за край карты.'),
      ('Forgetting clear and check, the chip, the compass or the watch — or arriving after your start minute.', 'Esquecer limpar e verificar, o chip, a bússola ou o relógio — ou chegar depois do minuto de partida.', 'Löschen und Prüfen, Chip, Kompass oder Uhr vergessen — oder nach der Startminute ankommen.', 'Забыть очистку и проверку, чип, компас или часы — или опоздать к своей минуте.'),
      ('Getting overconfident after a clean race and losing ten minutes twice the next day.', 'Ficar confiante demais após uma prova limpa e perder dez minutos duas vezes no dia seguinte.', 'Nach einem sauberen Lauf übermütig werden und am nächsten Tag zweimal zehn Minuten verlieren.', 'Расслабиться после чистого старта и назавтра дважды потерять по десять минут.'),
    ]
  ),
];
