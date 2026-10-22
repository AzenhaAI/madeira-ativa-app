// Exports the Orienteering basics content for the website, so the site page
// and the app never drift: every symbol and control-description pictogram is
// rendered to PNG from the same painting code, and all texts go to one JSON.
//
//   flutter test test/export_orienteering_test.dart \
//     --dart-define=OUT=/path/to/site/ativa/orient \
//     --dart-define=FONT=/path/to/flutter/bin/cache/artifacts/material_fonts/Roboto-Bold.ttf
//
// Without OUT the test only checks that everything renders.

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ativa/orienteering.dart';
import 'package:ativa/orienteering_cd.dart';
import 'package:ativa/orienteering_classes.dart';
import 'package:ativa/orienteering_tips.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _out = String.fromEnvironment('OUT');
const _font = String.fromEnvironment('FONT');

Map<String, String> j4(T4 t) => {'en': t.$1, 'pt': t.$2, 'de': t.$3, 'ru': t.$4};

Future<List<int>> render(void Function(Canvas, Size) draw, Size size, {double scale = 3, Color bg = Colors.white}) async {
  final rec = ui.PictureRecorder();
  final c = Canvas(rec);
  c.scale(scale);
  c.drawRect(Offset.zero & size, Paint()..color = bg);
  draw(c, size);
  final img = await rec.endRecording().toImage((size.width * scale).round(), (size.height * scale).round());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

void main() {
  testWidgets('export orienteering content', (tester) async {
    await tester.runAsync(() async {
      if (_font.isNotEmpty) {
        // The pictograms with letters (column A-style numbers) need a real font,
        // not the test font that draws boxes.
        final data = File(_font).readAsBytesSync();
        final loader = FontLoader('Roboto')..addFont(Future.value(ByteData.sublistView(data)));
        await loader.load();
      }
      final out = _out.isEmpty ? null : Directory(_out);
      out?.createSync(recursive: true);
      Directory? sub(String n) => out == null ? null : (Directory('${out.path}/$n')..createSync(recursive: true));
      final symDir = sub('sym'), cdDir = sub('cd');

      var i = 0;
      final symbols = [];
      for (final (title, syms) in kSymbolGroups) {
        final items = [];
        for (final s in syms) {
          final name = 's${i++}.png';
          final png = await render(s.draw, const Size(64, 44));
          symDir?.let((d) => File('${d.path}/$name').writeAsBytesSync(png));
          items.add({'code': s.code, 'name': j4(s.name), 'hint': j4(s.hint), 'img': 'sym/$name'});
        }
        symbols.add({'title': j4(title), 'items': items});
      }

      final cdOut = [];
      for (final (col, title, note, items) in kCdGroups) {
        final list = [];
        for (final it in items) {
          final name = 'cd_${it.id.replaceAll(RegExp(r'[^a-z0-9_-]', caseSensitive: false), '_')}.png';
          final png = await render(cd(it.id), const Size(34, 34));
          cdDir?.let((d) => File('${d.path}/$name').writeAsBytesSync(png));
          list.add({'id': it.id, 'name': j4(it.name), if (it.note != null) 'note': j4(it.note!), 'img': 'cd/$name'});
        }
        cdOut.add({'col': col, 'title': j4(title), 'note': j4(note), 'items': list});
      }

      Map<String, dynamic> sec(T4 title, List<ClassItem> items) => {
            'title': j4(title),
            'items': [
              for (final it in items) {'key': it.key, 'text': j4(it.text), if (it.chip != null) 'chip': '#${(it.chip! & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}'}
            ],
          };

      final json = {
        'title': j4(kOrientTitle),
        'symbols': symbols,
        'cd': cdOut,
        'classes': {
          'intro': j4(kClassesIntro),
          'finder': j4(kSecFinder),
          'names': sec(kSecNames, kClassNames),
          'open': {...sec(kSecOpen, kOpenCourses), 'intro': j4(kOpenIntro), 'warn': j4(kOpenWarn)},
          'rogaine': {'title': j4(kSecRogaine), 'text': j4(kRogaineClasses)},
          'entry': sec(kSecEntry, kEntryForm),
          'words': sec(kSecWords, kGlossary),
          'foot': j4(kClassesFoot),
        },
        'race': {
          'steps': [for (final (_, t, x) in kRaceSteps) {'title': j4(t), 'text': j4(x)}],
          'sheet': [for (final x in kSheetNotes) j4(x)],
          'rules': [for (final x in kRaceRules) j4(x)],
        },
        'tips': {
          'intro': j4(kTipsIntro),
          'sections': [
            for (final (t, items) in kTips) {'title': j4(t), 'items': [for (final x in items) j4(x)]}
          ],
        },
      };
      if (out != null) {
        File('${out.path}/orient.json').writeAsStringSync(const JsonEncoder.withIndent(' ').convert(json));
      }
      expect(symbols, isNotEmpty);
      expect(cdOut, isNotEmpty);
    });
  });
}

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
