// What the reader follows, and what that is used for: the order of the
// events list ("for you"), a count of new events since the last visit, and
// the registration alerts for starred events and followed kinds.
//
// Everything here stays on the device: the choices, the opened categories,
// the keys seen on the last visit. Nothing is sent anywhere, so the stores'
// privacy forms do not change. Nobody is asked at first launch — the chips
// sit on the Events tab and in the menu, and the ranking also learns from
// what the reader opens and stars.
import 'package:flutter/material.dart';

import 'main.dart';
import 'notify.dart';
import 'store.dart';

/// Kinds of sport the reader follows: 'trail', 'road', 'orienteering',
/// 'cycling', 'swim', 'kids', 'pro'. Culture is followed by its own
/// sub-categories (event_subcats on the Events tab).
final interests = ValueNotifier<Set<String>>({});

/// Registration alerts for starred events and followed kinds.
final alertsOn = ValueNotifier<bool>(false);

/// Events matching the reader's interests that appeared since the last time
/// the Events tab was opened. Shown as a badge on the tab.
final newForYou = ValueNotifier<int>(0);

Set<String> _seen = {};

void initInterests() {
  interests.value = (prefs.getStringList('interests') ?? []).toSet();
  alertsOn.value = prefs.getBool('alerts_on') ?? false;
  _seen = (prefs.getStringList('seen_events') ?? []).toSet();
  // Landing on the Events tab, by tap or by link, clears the badge.
  homeTab.addListener(() {
    if (homeTab.value == kTabEvents) markEventsSeen(latestEvents);
  });
}

void toggleInterest(String kind) {
  final s = {...interests.value};
  s.contains(kind) ? s.remove(kind) : s.add(kind);
  interests.value = s;
  prefs.setStringList('interests', s.toList());
}

void setAlerts(bool on) {
  alertsOn.value = on;
  prefs.setBool('alerts_on', on);
}

bool hasInterests() =>
    interests.value.isNotEmpty || (prefs.getStringList('event_subcats') ?? []).isNotEmpty;

String eventKey(AtivaEvent e) => 'event:${e.name}|${e.date}';

bool _isOrienteering(AtivaEvent e) =>
    e.type == 'orienteering' || e.name.startsWith('Orientação') || e.url.contains('aoram.pt');

/// Does this event belong to a kind the reader follows?
bool matchesInterests(AtivaEvent e) {
  final kinds = interests.value;
  if (e.isCulture) {
    final subs = (prefs.getStringList('event_subcats') ?? []).toSet();
    return subs.contains(e.category);
  }
  if (kinds.contains('orienteering') && _isOrienteering(e)) return true;
  return kinds.contains(e.mode);
}

/// Why this event is shown first — one short reason, in the reader's
/// language, or '' when it is just in date order.
String whyFor(AtivaEvent e) {
  if (isFav(eventKey(e))) return t('why_starred');
  final r = e.registration;
  if (r != null && r.daysLeft >= 0 && r.daysLeft <= 7 && r.status == 'open') return t('why_reg_closing');
  if (matchesInterests(e)) {
    if (e.isCulture) return '${t('why_follow')} ${t('cc_${e.category}')}';
    final kind = _isOrienteering(e) && interests.value.contains('orienteering') ? 'orient' : e.mode;
    return '${t('why_follow')} ${t('cat_$kind')}';
  }
  if (!_seen.contains(eventKey(e)) && _seen.isNotEmpty) return t('why_new');
  return '';
}

/// How much this reader cares: followed kind, starred, registration about
/// to close, new since the last visit. Only an order; nothing is hidden.
int interestScore(AtivaEvent e) {
  var s = 0;
  if (matchesInterests(e)) s += 100;
  if (isFav(eventKey(e))) s += 60;
  final r = e.registration;
  if (r != null && r.status == 'open' && r.daysLeft >= 0 && r.daysLeft <= 7) s += 30;
  if (_seen.isNotEmpty && !_seen.contains(eventKey(e))) s += 15;
  return s;
}

/// After the events load: count what is new for the reader, and (when alerts
/// are on) schedule the registration milestones of starred and followed
/// events. Scheduling the same event again replaces its alerts, so this is
/// safe to run on every load. iOS keeps at most 64 pending notifications;
/// the twenty soonest windows are enough.
Future<void> syncEventAlerts(List<AtivaEvent> events) async {
  // Nothing is "new" on the first visit, and nothing is new while the tab
  // is already open. The badge counts only what appeared between visits.
  if (homeTab.value == kTabEvents) {
    markEventsSeen(events);
  } else if (hasInterests() && _seen.isNotEmpty) {
    newForYou.value = events.where((e) => !_seen.contains(eventKey(e)) && matchesInterests(e)).length;
  }
  if (!alertsOn.value) return;
  final wanted = events
      .where((e) => e.registration != null && e.registration!.closes.isNotEmpty)
      .where((e) => isFav(eventKey(e)) || matchesInterests(e))
      .toList()
    ..sort((a, b) => a.registration!.closes.compareTo(b.registration!.closes));
  for (final e in wanted.take(20)) {
    final r = e.registration!;
    await scheduleRegistrationAlerts(eventKey(e),
        opensIso: r.opens,
        closesIso: r.closes,
        opensText: t('ntf_reg_opens').replaceAll('{name}', e.name),
        closesIn3Text: t('ntf_reg_closes').replaceAll('{name}', e.name),
        closesTomorrowText: t('ntf_reg_closes_tmrw').replaceAll('{name}', e.name));
  }
}

/// The Events tab was opened: everything listed now counts as seen.
void markEventsSeen(List<AtivaEvent> events) {
  if (events.isEmpty) return; // not loaded yet; the load marks them
  _seen = events.map(eventKey).toSet();
  prefs.setStringList('seen_events', _seen.toList());
  newForYou.value = 0;
}

/// Kinds a reader can follow, with the key of their label and an emoji.
const interestKinds = <(String, String, String)>[
  ('trail', '🏃', 'cat_trail'),
  ('road', '🛣', 'cat_road'),
  ('orienteering', '🧭', 'cat_orient'),
  ('cycling', '🚴', 'cat_bike'),
  ('swim', '🏊', 'cat_swim'),
  ('kids', '👶', 'cat_kids'),
  ('pro', '🏆', 'cat_pro'),
];

/// The Interests screen: what to follow, and whether to be told about
/// registration windows. Reached from the menu; the same chips also live on
/// the Events tab.
class InterestsPage extends StatelessWidget {
  const InterestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('interests'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(t('interests_sub'), style: TextStyle(fontSize: 13, color: context.cSubtle)),
          const SizedBox(height: 12),
          Text(t('interests_sport'), style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ValueListenableBuilder<Set<String>>(
            valueListenable: interests,
            builder: (_, on, __) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (kind, emoji, label) in interestKinds)
                  FilterChip(
                    showCheckmark: false,
                    avatar: Text(emoji, style: const TextStyle(fontSize: 13)),
                    label: Text(t(label)),
                    selected: on.contains(kind),
                    selectedColor: kGreen,
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: on.contains(kind) ? Colors.white : context.cTitle),
                    onSelected: (_) => toggleInterest(kind),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(t('interests_culture'), style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(t('interests_culture_sub'), style: TextStyle(fontSize: 13, color: context.cSubtle)),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: alertsOn,
            builder: (_, on, __) => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: on,
              onChanged: (v) async {
                if (v && !await ensureNotificationPermission()) return;
                setAlerts(v);
              },
              title: Text(t('alerts_reg')),
              subtitle: Text(t('alerts_reg_sub'), style: TextStyle(fontSize: 13, color: context.cSubtle)),
            ),
          ),
          const SizedBox(height: 8),
          Text(t('alerts_note'), style: TextStyle(fontSize: 12, color: context.cSubtle)),
        ],
      ),
    );
  }
}
