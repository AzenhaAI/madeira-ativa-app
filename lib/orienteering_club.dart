import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';
import 'orienteering.dart' show tr;

/// Club route puzzles on real club maps. TEST BUILDS ONLY: the maps are
/// "Reproducao interdita", so they are never in the repo or a bundle; a pack
/// is pushed straight onto a test device (see ativa-testdata/push_club_maps.sh)
/// and the entry point only shows with --dart-define=CLUB_MAPS=true.

// ================================================================ club puzzles (test builds only)

class ClubPuzzle {
  ClubPuzzle(this.title, this.date, this.task, this.reveal, this.note);
  final String title, date, task, note;
  final List<(String img, String label)> reveal;
}

/// Where the pack is copied by the push script: Android external app files
/// (adb can write there), iOS the app's Documents (devicectl / simctl).
Future<Directory?> clubPackDir() async {
  final base = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationDocumentsDirectory();
  if (base == null) return null;
  final d = Directory('${base.path}/club_maps');
  return await File('${d.path}/puzzles.json').exists() ? d : null;
}

Future<List<ClubPuzzle>> loadClubPuzzles(Directory d) async {
  final j = jsonDecode(await File('${d.path}/puzzles.json').readAsString()) as Map<String, dynamic>;
  return [
    for (final p in (j['puzzles'] as List).cast<Map<String, dynamic>>())
      ClubPuzzle(p['title'] as String, p['date'] as String? ?? '', p['task'] as String,
          [for (final r in (p['reveal'] as List).cast<Map<String, dynamic>>()) (r['img'] as String, r['label'] as String? ?? '')], p['note'] as String? ?? ''),
  ];
}

class ClubPuzzlesPage extends StatefulWidget {
  const ClubPuzzlesPage({super.key});
  @override
  State<ClubPuzzlesPage> createState() => _ClubPuzzlesPageState();
}

class _ClubPuzzlesPageState extends State<ClubPuzzlesPage> {
  Directory? _dir;
  List<ClubPuzzle>? _list;
  String? _err;

  @override
  void initState() {
    super.initState();
    () async {
      try {
        final d = await clubPackDir();
        final l = d == null ? <ClubPuzzle>[] : await loadClubPuzzles(d);
        if (mounted) {
          setState(() {
            _dir = d;
            _list = l;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _err = '$e');
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(('Club route puzzles', 'Desafios do clube', 'Vereinsaufgaben', 'Клубные разборы')))),
      body: _err != null
          ? Padding(padding: const EdgeInsets.all(20), child: Text(_err!))
          : _list == null
              ? const Center(child: CircularProgressIndicator())
              : _list!.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(tr((
                        'No club map pack on this device. It is copied from the developer\'s Mac with the push script; club maps are not part of the app.',
                        'Não há pacote de mapas neste aparelho. É copiado do Mac do programador; os mapas do clube não fazem parte da aplicação.',
                        'Kein Kartenpaket auf diesem Gerät. Es wird vom Mac des Entwicklers kopiert; Vereinskarten sind nicht Teil der App.',
                        'На устройстве нет пакета карт. Его копирует скрипт с Мака разработчика; клубные карты не входят в приложение.'
                      ))))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _list!.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final p = _list![i];
                        return ListTile(
                          leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(File('${_dir!.path}/${p.task}'), width: 56, height: 56, fit: BoxFit.cover, cacheWidth: 160)),
                          title: Text(p.title),
                          subtitle: Text('${p.date} · ${p.reveal.length} ${tr(('answers', 'respostas', 'Antworten', 'ответов'))}'),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ClubPuzzlePage(dir: _dir!, p: p))),
                        );
                      }),
    );
  }
}

class ClubPuzzlePage extends StatefulWidget {
  const ClubPuzzlePage({super.key, required this.dir, required this.p});
  final Directory dir;
  final ClubPuzzle p;
  @override
  State<ClubPuzzlePage> createState() => _ClubPuzzlePageState();
}

class _ClubPuzzlePageState extends State<ClubPuzzlePage> {
  bool _draw = true;
  final _strokes = <List<Offset>>[];

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return Scaffold(
      appBar: AppBar(title: Text(p.title), actions: [
        IconButton(
          tooltip: tr(_draw ? ('Pan and zoom', 'Mover e ampliar', 'Verschieben und zoomen', 'Двигать и масштабировать') : ('Draw', 'Desenhar', 'Zeichnen', 'Рисовать')),
          icon: Icon(_draw ? Icons.pan_tool_outlined : Icons.edit_outlined),
          onPressed: () => setState(() => _draw = !_draw),
        ),
        IconButton(
            tooltip: tr(('Clear', 'Apagar', 'Löschen', 'Стереть')),
            icon: const Icon(Icons.layers_clear_outlined),
            onPressed: _strokes.isEmpty ? null : () => setState(_strokes.clear)),
      ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
              p.note.isNotEmpty
                  ? p.note
                  : tr(('Draw the way you would run, then compare. Switch to the hand to zoom.', 'Desenha o caminho que farias e compara. Muda para a mão para ampliar.', 'Zeichne deinen Weg und vergleiche. Mit der Hand zoomen.', 'Нарисуй, как побежал бы сам, потом сравни. Рука — чтобы приблизить.')),
              style: TextStyle(fontSize: 12.5, color: context.cSubtle)),
        ),
        Expanded(
          child: InteractiveViewer(
            panEnabled: !_draw,
            scaleEnabled: !_draw,
            maxScale: 6,
            child: Center(
              child: GestureDetector(
                onPanStart: _draw ? (d) => setState(() => _strokes.add([d.localPosition])) : null,
                onPanUpdate: _draw ? (d) => setState(() => _strokes.last.add(d.localPosition)) : null,
                child: Stack(children: [
                  Image.file(File('${widget.dir.path}/${p.task}')),
                  Positioned.fill(child: CustomPaint(painter: _InkPainter(_strokes))),
                ]),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: FilledButton.icon(
              icon: const Icon(Icons.visibility_outlined),
              label: Text('${tr(('Show how the club ran', 'Ver como o clube fez', 'Zeigen, wie der Verein lief', 'Показать, как бежали в клубе'))} (${p.reveal.length})'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _RevealPage(dir: widget.dir, p: p))),
            ),
          ),
        ),
      ]),
    );
  }
}

class _InkPainter extends CustomPainter {
  _InkPainter(this.strokes);
  final List<List<Offset>> strokes;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: .85)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final s in strokes) {
      if (s.length < 2) continue;
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (final o in s.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _InkPainter old) => true;
}

class _RevealPage extends StatefulWidget {
  const _RevealPage({required this.dir, required this.p});
  final Directory dir;
  final ClubPuzzle p;
  @override
  State<_RevealPage> createState() => _RevealPageState();
}

class _RevealPageState extends State<_RevealPage> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final r = widget.p.reveal;
    return Scaffold(
      appBar: AppBar(title: Text('${_i + 1} / ${r.length}${r[_i].$2.isEmpty ? '' : ' · ${r[_i].$2}'}')),
      body: PageView.builder(
        itemCount: r.length,
        onPageChanged: (i) => setState(() => _i = i),
        itemBuilder: (_, i) => InteractiveViewer(maxScale: 6, child: Center(child: Image.file(File('${widget.dir.path}/${r[i].$1}')))),
      ),
    );
  }
}
