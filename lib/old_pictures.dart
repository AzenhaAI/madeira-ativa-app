import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';
import 'orienteering.dart' show T4, tr;
import 'store.dart';

/// "Madeira in old pictures": the same galleries as the site's history page,
/// read from azenha.ai/ativa/history/gallery/gallery.json — whole sets from
/// Ackermann (1821), Bulwer (1827), Picken (1840), Bryullov (1849–50) and the
/// França watercolours (1853–54, previews linking to their records).

const _base = 'https://azenha.ai/ativa/history/gallery/';
const T4 kOldPicturesTitle = ('Madeira in old pictures', 'A Madeira em imagens antigas', 'Madeira in alten Bildern', 'Мадейра в старых рисунках');
const T4 kOldPicturesSub = (
  'Five galleries of engravings, lithographs and paintings, 1821–1854.',
  'Cinco galerias de gravuras, litografias e pinturas, 1821–1854.',
  'Fünf Galerien mit Stichen, Lithografien und Gemälden, 1821–1854.',
  'Пять галерей гравюр, литографий и картин, 1821–1854.'
);

String _l(dynamic m) => m is Map ? (m[locale.value] ?? m['en'] ?? '') as String : '';

class OldPicturesPage extends StatefulWidget {
  const OldPicturesPage({super.key});
  @override
  State<OldPicturesPage> createState() => _OldPicturesPageState();
}

class _OldPicturesPageState extends State<OldPicturesPage> {
  List<dynamic>? _galleries;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    cachedJson('${_base}gallery.json').then((j) {
      if (mounted) setState(() => _galleries = (j as Map)['galleries'] as List);
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(kOldPicturesTitle))),
      body: _galleries == null
          ? Center(
              child: _failed
                  ? Text(tr(('No connection. Try again later.', 'Sem ligação. Tente mais tarde.', 'Keine Verbindung. Später erneut versuchen.', 'Нет связи. Попробуйте позже.')))
                  : const CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
              Text(
                  tr((
                    'How travellers and artists saw the island two centuries ago — whole sets, in the public domain. Tap a picture to open it, swipe to turn, pinch to zoom.',
                    'Como viajantes e artistas viram a ilha há dois séculos — conjuntos completos, em domínio público. Toque para abrir, deslize para passar, aproxime com dois dedos.',
                    'Wie Reisende und Künstler die Insel vor zwei Jahrhunderten sahen — ganze Serien, gemeinfrei. Antippen zum Öffnen, wischen zum Blättern, mit zwei Fingern zoomen.',
                    'Каким остров видели путешественники и художники двести лет назад — полные наборы в общественном достоянии. Нажмите, чтобы открыть, листайте свайпом, приближайте двумя пальцами.'
                  )),
                  style: TextStyle(fontSize: 13, color: context.cSubtle, height: 1.35)),
              for (final g in _galleries!) _GallerySet(g as Map),
            ]),
    );
  }
}

class _GallerySet extends StatelessWidget {
  const _GallerySet(this.g);
  final Map g;

  @override
  Widget build(BuildContext context) {
    final items = (g['items'] as List).cast<Map>();
    final preview = g['preview_only'] == true;
    final size = preview ? 96.0 : 132.0;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${g['year']}', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: .8, color: context.cTerraText)),
        Text(_l(g['title']), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(_l(g['sub']), style: TextStyle(fontSize: 12.5, color: context.cSubtle, height: 1.35)),
        const SizedBox(height: 8),
        SizedBox(
          height: size + 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final it = items[i];
              return GestureDetector(
                onTap: () => preview
                    ? launchUrl(Uri.parse(it['link'] as String), mode: LaunchMode.externalApplication)
                    : Navigator.of(context).push(MaterialPageRoute(builder: (_) => _Viewer(g: g, start: i))),
                child: SizedBox(
                  width: size * 1.3,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network('$_base${it['thumb']}',
                          width: size * 1.3,
                          height: size,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(width: size * 1.3, height: size, color: context.cTerraTint)),
                    ),
                    const SizedBox(height: 4),
                    Text(_l(it['title']), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: context.cSubtle, height: 1.25)),
                  ]),
                ),
              );
            },
          ),
        ),
        Text('${g['source']} · ${g['licence']}', style: TextStyle(fontSize: 11, color: context.cSubtle)),
      ]),
    );
  }
}

class _Viewer extends StatefulWidget {
  const _Viewer({required this.g, required this.start});
  final Map g;
  final int start;
  @override
  State<_Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<_Viewer> {
  late final PageController _pc = PageController(initialPage: widget.start);
  late int _i = widget.start;

  @override
  Widget build(BuildContext context) {
    final items = (widget.g['items'] as List).cast<Map>();
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0E0C),
        foregroundColor: Colors.white,
        title: Text('${_i + 1} / ${items.length}', style: const TextStyle(color: Colors.white)),
      ),
      body: Column(children: [
        Expanded(
          child: PageView.builder(
            controller: _pc,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _i = i),
            itemBuilder: (_, i) => InteractiveViewer(
              maxScale: 5,
              child: Center(
                child: Image.network('$_base${items[i]['img']}',
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, p) => p == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white54))),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(children: [
              Text(_l(items[_i]['title']), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 15)),
              const SizedBox(height: 3),
              Text('${_l(widget.g['title'])}, ${widget.g['year']}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          ),
        ),
      ]),
    );
  }
}
