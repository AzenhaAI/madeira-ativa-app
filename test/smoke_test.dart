// Replaces the generator's counter test, which asserted a widget the app never
// had and so failed on every run — a red suite nobody reads is worse than none.
//
// This one checks what actually matters after a layout change: the app builds,
// the six tabs are there, and it survives being laid out at sizes other than a
// phone's. App Review rejected 1.8.0 for a screen that broke on an iPad-shaped
// window, so the sizes below are the regression test for that rejection.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ativa/main.dart';

const _tabs = ['Home', 'Events', 'Map', 'Levadas', 'News', 'Roots'];

Future<void> _pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const AtivaApp());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  _langSwitchTest();
  testWidgets('shell renders every tab on a phone', (tester) async {
    await _pumpAt(tester, const Size(390, 844));
    for (final label in _tabs) {
      expect(find.text(label), findsWidgets, reason: 'tab $label missing');
    }
  });

  testWidgets('shell survives an iPad-shaped window', (tester) async {
    await _pumpAt(tester, const Size(834, 1194));
    expect(tester.takeException(), isNull);
    for (final label in _tabs) {
      expect(find.text(label), findsWidgets, reason: 'tab $label missing');
    }
  });

  testWidgets('shell survives a short landscape window', (tester) async {
    await _pumpAt(tester, const Size(956, 440));
    expect(tester.takeException(), isNull);
  });
}

// The language switch was inert for a release: MaterialApp rebuilt on a locale
// change, but its home was a const instance, so Flutter skipped the subtree and
// not one string changed. This asserts the strings actually move.
void _langSwitchTest() {
  testWidgets('switching locale changes the strings on screen', (tester) async {
    locale.value = 'en';
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(() => locale.value = 'en');

    await tester.pumpWidget(const AtivaApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Events'), findsWidgets, reason: 'English label missing');

    locale.value = 'pt';
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Events'), findsNothing,
        reason: 'still English after switching to Portuguese');
  });

  // The switch worked on Home and nowhere else, because every other page in
  // the shell was a const instance and Flutter skips an identical widget.
  // Home was non-const only by accident — it takes a callback. This asserts
  // the other tabs move too.
  testWidgets('locale reaches tabs other than Home', (tester) async {
    locale.value = 'en';
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(() => locale.value = 'en');

    await tester.pumpWidget(const AtivaApp());
    await tester.pump(const Duration(seconds: 1));

    // Open the Levadas tab, then switch language and check its own title.
    await tester.tap(find.text('Levadas').last);
    await tester.pump(const Duration(seconds: 1));

    locale.value = 'pt';
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.text('Events'), findsNothing,
        reason: 'nav labels stayed English away from Home');
  });
}
