// Drives the app for store videos and screenshots while the simulator or the
// emulator records. Not part of any release build.
//
//   flutter test integration_test/store_tour_test.dart -d <device> \
//     --dart-define=SHOT_TIME=11:20 --dart-define=TOUR_LANG=pt --dart-define=TOUR_MODE=video
//
// TOUR_MODE=video: the walk Kirill asked for (22.10.2026) — Home, Events, the
//   Trail chip and one event, the Fest chip with its tabs, Map with the bus
//   layer and one stop, Levadas with one trail scrolled through, News.
// TOUR_MODE=shots: stops on each store screen and prints "SHOT:<name>"; the
//   host script takes the screenshot when it sees the line.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ativa/main.dart' as app;
import 'package:ativa/orienteering.dart' show openOrienteering;

const lang = String.fromEnvironment('TOUR_LANG', defaultValue: 'en');
const mode = String.fromEnvironment('TOUR_MODE', defaultValue: 'video');
// On the simulator the app can see the host's files: the host script drops
// <TOUR_ACK>/<lang>_<shot> once the screenshot is taken, and the tour waits
// for it instead of guessing how late the log line arrives.
const ackDir = String.fromEnvironment('TOUR_ACK');

Future<void> wait(WidgetTester t, double seconds) async {
  final n = (seconds * 20).round();
  for (var i = 0; i < n; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await t.pump();
  }
}

Future<void> tab(WidgetTester t, int i) async {
  await t.tap(find.byType(NavigationDestination).at(i));
  await wait(t, .6);
}

Future<void> tapIf(WidgetTester t, Finder f) async {
  if (f.evaluate().isNotEmpty) {
    await t.tap(f.first, warnIfMissed: false);
  }
}

Future<void> scroll(WidgetTester t, double dy, {double secs = 1.2}) async {
  final s = find.byType(Scrollable);
  if (s.evaluate().isEmpty) return;
  // The last Scrollable is the page on top; the first may sit under a route.
  await t.timedDrag(s.last, Offset(0, -dy), Duration(milliseconds: (secs * 1000).round()));
  await wait(t, .4);
}

Future<void> back(WidgetTester t) async {
  final nav = Navigator.of(t.element(find.byType(NavigationBar, skipOffstage: false)));
  if (nav.canPop()) nav.pop();
  await wait(t, .8);
}

Future<void> shotAndWait(WidgetTester t, String name) async {
  debugPrint('SHOT:$name');
  if (ackDir.isEmpty) return wait(t, 2.5);
  final f = File('$ackDir/${lang}_$name');
  for (var i = 0; i < 120 && !f.existsSync(); i++) {
    await wait(t, .25);
  }
}

BuildContext ctx(WidgetTester t) => t.element(find.byType(NavigationBar, skipOffstage: false));

Finder chip(String key) => find.widgetWithText(ChoiceChip, app.t(key));

final eventTiles = find.byWidgetPredicate((w) => w.runtimeType.toString() == '_EventTile');

/// Waits until [f] shows up (the event list loads on the first visit), at most [max] s.
Future<void> until(WidgetTester t, Finder f, {double max = 20}) async {
  for (var i = 0; i < max * 4 && f.evaluate().isEmpty; i++) {
    await wait(t, .25);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('store tour', (t) async {
    app.main();
    await wait(t, 4);
    app.setLocale(lang);
    await wait(t, 6); // island card, events and news load
    debugPrint('TOUR:start');

    if (mode == 'video') {
      await wait(t, 3); // Home
      await scroll(t, 500, secs: 1.6);
      await wait(t, 1.5);
      await scroll(t, -500, secs: .8);

      await tab(t, app.kTabEvents);
      await until(t, eventTiles);
      await wait(t, 1.5);
      await tapIf(t, chip('cat_trail'));
      await wait(t, 2);
      final ev = eventTiles;
      await tapIf(t, ev);
      await wait(t, 3.5); // the event sheet
      await back(t);
      await tapIf(t, chip('cat_fest'));
      await wait(t, 3.5); // the festa sub-category tabs
      await tapIf(t, ev);
      await wait(t, 3);
      await back(t);

      await tab(t, app.kTabMap);
      await wait(t, 3);
      await tapIf(t, find.descendant(of: find.byType(SegmentedButton<String>), matching: find.text(app.t('buses'))));
      await wait(t, 3);
      final stops = find.descendant(of: find.byType(MarkerLayer), matching: find.byIcon(Icons.directions_bus));
      if (stops.evaluate().isNotEmpty) {
        await t.tap(stops.at(stops.evaluate().length ~/ 2), warnIfMissed: false);
      }
      await wait(t, 8); // the bus planner to that stop
      await back(t);

      await tab(t, app.kTabLevadas);
      await wait(t, 2.5);
      await tapIf(t, find.text('Vereda do Pico Ruivo'));
      await wait(t, 3);
      for (var i = 0; i < 4; i++) {
        await scroll(t, 420, secs: 1.1);
        await wait(t, 1.2);
      }
      await back(t);

      await tab(t, app.kTabNews);
      await wait(t, 3);
      await scroll(t, 400, secs: 1.4);
      await wait(t, 2.5);
    } else {
      await shotAndWait(t, '1-home');

      await tab(t, app.kTabEvents);
      await until(t, eventTiles);
      await wait(t, 2);
      await shotAndWait(t, '5-events');

      await tab(t, app.kTabMap);
      await wait(t, 3);
      await tapIf(t, find.descendant(of: find.byType(SegmentedButton<String>), matching: find.text(app.t('buses'))));
      await wait(t, 4);
      await shotAndWait(t, '4-map');

      Navigator.of(ctx(t)).push(MaterialPageRoute(
          builder: (_) => app.WebPage(
              title: app.t('bus_one'),
              url: 'https://azenha.ai/ativa/bus?app=1&lang=$lang&from=Funchal&to=Santana')));
      await wait(t, 12);
      await shotAndWait(t, '4b-busroute');
      await back(t);

      await tab(t, app.kTabLevadas);
      await wait(t, 3);
      await shotAndWait(t, '2-levadas');
      await tapIf(t, find.text('Vereda do Pico Ruivo'));
      await wait(t, 4);
      await scroll(t, 560, secs: 1);
      await wait(t, 2);
      await shotAndWait(t, '3b-trail-profile');
      await back(t);

      openOrienteering(ctx(t));
      await wait(t, 3);
      await scroll(t, 330, secs: .8);
      await wait(t, 1.5);
      await shotAndWait(t, '8-orient');
      await back(t);

      app.openTrailStats(ctx(t));
      await wait(t, 12);
      await shotAndWait(t, '9-stats');
      await back(t);

      await tab(t, app.kTabAsk);
      await wait(t, 10);
      await shotAndWait(t, '6-ask');

      await tab(t, app.kTabNews);
      await wait(t, 4);
      await shotAndWait(t, '7-news');
    }
    debugPrint('TOUR:end');
  });
}
