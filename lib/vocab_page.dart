import 'package:flutter/material.dart';

import 'main.dart';
import 'orienteering.dart' show T4, tr;
import 'store.dart';

/// Madeiran words: the 1,782 entries of the "Vocabulário Popular da Madeira"
/// (Father Fernando Augusto da Silva, Junta Geral do Funchal, 1950; public
/// domain, the author died in 1949), with a word of the day and a search.
/// Read from the site (azenha.ai/ativa/words/), the same files as its
/// "Madeiran words" page, so a correction there reaches the app too.
/// Kirill, 28.10.2026: in the app and as news; entry under Roots (history)
/// and a banner at the bottom of News.

const T4 kWordsTitle = ('Madeiran words', 'Falar madeirense', 'Madeirische Wörter', 'Мадейрские слова');
const T4 kWordsSub = (
  "What's a poio? 1,782 words of Madeiran speech and a word of the day",
  'Sabe o que é um poio? 1782 palavras do falar madeirense e a palavra do dia',
  'Was ist ein poio? 1.782 madeirische Wörter und ein Wort des Tages',
  'Что такое poio? 1782 слова мадейрской речи и слово дня'
);

// A preview build can read the files from a local copy of the site before
// they are published: --dart-define=WORDS_BASE=http://localhost:8765/ativa/words
const _base = String.fromEnvironment('WORDS_BASE', defaultValue: 'https://azenha.ai/ativa/words');

void openWords(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VocabPage()));

class _Word {
  _Word(this.t, this.pt, this.en, this.ru);
  final String t, pt, en, ru;
  late final String key = fold('$t $pt $en $ru');
  String get meaning => switch (locale.value) {
        'ru' => ru,
        'pt' => pt,
        _ => en, // German readers get the English rendering: there is no German
      };
}

String fold(String s) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final b = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    final i = from.indexOf(c);
    b.write(i >= 0 ? to[i] : c);
  }
  return b.toString();
}

class VocabPage extends StatefulWidget {
  const VocabPage({super.key});
  @override
  State<VocabPage> createState() => _VocabPageState();
}

class _VocabPageState extends State<VocabPage> {
  List<_Word>? _words;
  Map<String, dynamic>? _day;
  bool _failed = false;
  String _q = '';
  String _letter = '';
  final _field = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final v = await cachedJson('$_base/madeira_vocab.json');
      final d = await cachedJson('$_base/word_of_the_day.json');
      final list = [
        for (final w in (v['words'] as List))
          _Word('${w['t']}', '${w['pt'] ?? ''}', '${w['en'] ?? ''}', '${w['ru'] ?? ''}')
      ];
      final days = (d as List).cast<Map<String, dynamic>>();
      final now = DateTime.now();
      final n = now.difference(DateTime(now.year)).inDays;
      if (mounted) setState(() {
        _words = list;
        _day = days[n % days.length];
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = _words;
    final q = fold(_q.trim());
    List<_Word> hits = const [];
    if (words != null && (q.isNotEmpty || _letter.isNotEmpty)) {
      hits = words.where((w) {
        if (_letter.isNotEmpty && !fold(w.t).startsWith(_letter)) return false;
        return q.isEmpty || w.key.contains(q);
      }).toList();
      if (q.isNotEmpty) {
        hits.sort((a, b) => (fold(a.t).startsWith(q) ? 0 : 1).compareTo(fold(b.t).startsWith(q) ? 0 : 1));
      }
    }
    final letters = words == null
        ? <String>[]
        : (words.map((w) => fold(w.t).isEmpty ? '' : fold(w.t)[0]).where((c) => RegExp('[a-z]').hasMatch(c)).toSet().toList()..sort());
    final sub = TextStyle(fontSize: 13, color: context.cSubtle, height: 1.35);
    final showPt = locale.value != 'pt';
    return Scaffold(
      appBar: AppBar(title: Text(tr(kWordsTitle))),
      body: _failed
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(tr(('No connection: the dictionary needs one the first time.', 'Sem ligação: o dicionário precisa de rede da primeira vez.', 'Keine Verbindung: das Wörterbuch braucht beim ersten Mal Netz.', 'Нет связи: словарю нужен интернет при первом открытии.')), textAlign: TextAlign.center)))
          : words == null
              ? skeletonList(context)
              : ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
                  Text(
                      tr((
                        '1,782 words and expressions of Madeiran speech from the Vocabulário Popular da Madeira (1950): levadas and terraces, fish, wine and country life.',
                        '1782 palavras e expressões do falar madeirense do Vocabulário Popular da Madeira (1950): levadas e socalcos, peixe, vinho e vida no campo.',
                        '1.782 Wörter und Wendungen der madeirischen Sprache aus dem Vocabulário Popular da Madeira (1950): Levadas und Terrassen, Fisch, Wein und Landleben. Bedeutungen auf Englisch.',
                        '1782 слова и выражения мадейрской речи из «Vocabulário Popular da Madeira» (1950): левады и террасы, рыба, вино и деревенская жизнь.'
                      )),
                      style: sub),
                  const SizedBox(height: 12),
                  if (_day != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: context.cSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.cHairline)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(tr(('WORD OF THE DAY', 'PALAVRA DO DIA', 'WORT DES TAGES', 'СЛОВО ДНЯ')),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: .6, color: kTerracotta)),
                        const SizedBox(height: 4),
                        Text('${_day!['term']}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: context.cTitle)),
                        const SizedBox(height: 2),
                        Text('${_day![locale.value] ?? _day!['en']}', style: const TextStyle(fontSize: 15)),
                        if (showPt) ...[
                          const SizedBox(height: 4),
                          Text('${_day!['pt']}', style: sub.copyWith(fontStyle: FontStyle.italic)),
                        ],
                      ]),
                    ),
                  const SizedBox(height: 12),
                  // More words, audio and practice: our PapaGaio app
                  // (Kirill, 28.10.2026: "рекламка — скачай словарь PapaGaio").
                  Material(
                    color: context.cGreenTint,
                    borderRadius: BorderRadius.circular(14),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: const Text('🦜', style: TextStyle(fontSize: 26)),
                      title: Text(tr(('Learn the words properly: PapaGaio', 'Aprenda as palavras a sério: PapaGaio', 'Wörter richtig lernen: PapaGaio', 'Учить слова всерьёз: PapaGaio')),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.cTitle)),
                      subtitle: Text(
                          tr((
                            'A European Portuguese dictionary of 100,000 words, flashcards with audio and an AI coach. Free.',
                            'Dicionário de português europeu com 100 000 palavras, cartões com áudio e um treinador com IA. Grátis.',
                            'Wörterbuch des europäischen Portugiesisch mit 100.000 Wörtern, Lernkarten mit Ton und ein KI-Coach. Kostenlos.',
                            'Словарь европейского португальского на 100 000 слов, карточки с озвучкой и ИИ-тренер. Бесплатно.'
                          )),
                          style: const TextStyle(fontSize: 12.5)),
                      trailing: Icon(Icons.open_in_new, size: 18, color: context.cTitle),
                      onTap: () => openUrl('https://azenha.ai/papagaio/'),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      hintText: tr(('Find a word: poio, levada… or a meaning', 'Procurar: poio, levada… ou um significado', 'Suchen: poio, levada … oder eine Bedeutung', 'Найти: poio, levada… или значение')),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (v) => setState(() {
                      _q = v;
                      _letter = '';
                    }),
                  ),
                  const SizedBox(height: 10),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for (final c in letters)
                      ChoiceChip(
                        label: Text(c.toUpperCase()),
                        selected: _letter == c,
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) => setState(() {
                          _letter = _letter == c ? '' : c;
                          _q = '';
                          _field.clear();
                        }),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  if (q.isEmpty && _letter.isEmpty)
                    Text(tr(('Search or pick a letter', 'Pesquise ou escolha uma letra', 'Suchen oder Buchstaben wählen', 'Ищите или выберите букву')), style: sub)
                  else if (hits.isEmpty)
                    Text(tr(('Nothing found.', 'Nada encontrado.', 'Nichts gefunden.', 'Ничего не найдено.')), style: sub)
                  else ...[
                    Text(tr(('${hits.length} found', '${hits.length} encontradas', '${hits.length} gefunden', 'Найдено: ${hits.length}')), style: sub),
                    for (final w in hits.take(150))
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: context.cHairline))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(w.t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.cTitle)),
                          const SizedBox(height: 2),
                          Text(w.meaning, style: const TextStyle(fontSize: 14.5)),
                          if (showPt && w.pt.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(w.pt, style: sub.copyWith(fontStyle: FontStyle.italic)),
                          ],
                        ]),
                      ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                      tr((
                        'Source: Vocabulário Popular da Madeira, Father Fernando Augusto da Silva (1863–1949), Junta Geral do Funchal, 1950. Public domain; 1950 spelling kept. English and Russian meanings by Madeira Ativa.',
                        'Fonte: Vocabulário Popular da Madeira, Padre Fernando Augusto da Silva (1863–1949), Junta Geral do Funchal, 1950. Domínio público; ortografia de 1950. Traduções para inglês e russo pela Madeira Ativa.',
                        'Quelle: Vocabulário Popular da Madeira, Pater Fernando Augusto da Silva (1863–1949), Junta Geral do Funchal, 1950. Gemeinfrei; Schreibweise von 1950. Englische und russische Bedeutungen von Madeira Ativa.',
                        'Источник: «Vocabulário Popular da Madeira», отец Фернанду Аугушту да Силва (1863–1949), Junta Geral do Funchal, 1950. Общественное достояние; орфография 1950 года. Переводы значений — Madeira Ativa.'
                      )),
                      style: TextStyle(fontSize: 11.5, color: context.cSubtle)),
                ]),
    );
  }
}
