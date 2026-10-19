import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'store.dart';

final _plugin = FlutterLocalNotificationsPlugin();
bool _ready = false;

/// Reminder keys the user has set, so the UI can show the bell state.
final reminders = ValueNotifier<Set<String>>({});

Future<void> initNotify() async {
  reminders.value = (prefs.getStringList('reminders') ?? []).toSet();
  tzdata.initializeTimeZones();
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  } catch (_) {
    tz.setLocalLocation(tz.getLocation('Atlantic/Madeira'));
  }
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _plugin.initialize(
      settings:
          const InitializationSettings(android: android, iOS: ios));
  _ready = true;
}

/// Asks for permission when a reader turns alerts on; false if refused.
Future<bool> ensureNotificationPermission() => _ensurePermission();

Future<bool> _ensurePermission() async {
  final ios = _plugin.resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>();
  if (ios != null) {
    return await ios.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }
  final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (android != null) {
    return await android.requestNotificationsPermission() ?? true;
  }
  return true;
}

int _idFor(String key) => key.hashCode & 0x7fffffff;

bool hasReminder(String key) => reminders.value.contains(key);

/// Schedules a reminder for the day before [dateIso] (YYYY-MM-DD) at 18:00
/// local time. Returns false if permission was denied or the date already
/// passed. [key] uniquely identifies the event.
Future<bool> setReminder(
    String key, String title, String dateIso, {String? body}) async {
  if (!_ready) return false;
  if (!await _ensurePermission()) return false;
  final parts = dateIso.split('-');
  if (parts.length != 3) return false;
  final y = int.tryParse(parts[0]),
      m = int.tryParse(parts[1]),
      d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return false;

  final when = tz.TZDateTime(tz.local, y, m, d, 18)
      .subtract(const Duration(days: 1));
  if (when.isBefore(tz.TZDateTime.now(tz.local))) return false;

  const details = NotificationDetails(
    android: AndroidNotificationDetails('events', 'Event reminders',
        channelDescription: 'Reminders for Madeira events you follow',
        importance: Importance.high),
    iOS: DarwinNotificationDetails(),
  );
  await _plugin.zonedSchedule(
    id: _idFor(key),
    title: 'Madeira Ativa',
    body: body ?? 'Tomorrow: $title',
    scheduledDate: when,
    notificationDetails: details,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  );
  final s = {...reminders.value, key};
  reminders.value = s;
  await prefs.setStringList('reminders', s.toList());
  return true;
}

/// The registration milestones of an event the reader follows: the morning
/// registration opens, three days before it closes, and the day before. Each
/// text is given by the caller in the reader's language; the milestones that
/// have passed are skipped. Ids derive from the reminder key, so cancelling
/// the reminder cancels these too.
Future<void> scheduleRegistrationAlerts(String key,
    {String? opensIso, String? closesIso, String? opensText, String? closesIn3Text, String? closesTomorrowText}) async {
  if (!_ready) return;
  final now = tz.TZDateTime.now(tz.local);
  const details = NotificationDetails(
    android: AndroidNotificationDetails('registration', 'Registration windows',
        channelDescription: 'When registration for a race you follow opens or is about to close',
        importance: Importance.high),
    iOS: DarwinNotificationDetails(),
  );
  tz.TZDateTime? at(String? iso, int hour, int daysBefore) {
    final d = DateTime.tryParse(iso ?? '');
    if (d == null) return null;
    final t = tz.TZDateTime(tz.local, d.year, d.month, d.day, hour).subtract(Duration(days: daysBefore));
    return t.isAfter(now) ? t : null;
  }
  final plan = [
    (':ropen', at(opensIso, 10, 0), opensText),
    (':r3', at(closesIso, 18, 3), closesIn3Text),
    (':r1', at(closesIso, 18, 1), closesTomorrowText),
  ];
  for (final (suffix, fireAt, text) in plan) {
    final id = _idFor(key + suffix);
    if (fireAt == null || text == null) {
      await _plugin.cancel(id: id);
      continue;
    }
    await _plugin.zonedSchedule(
      id: id,
      title: 'Madeira Ativa',
      body: text,
      scheduledDate: fireAt,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}

Future<void> cancelReminder(String key) async {
  await _plugin.cancel(id: _idFor(key));
  for (final suffix in [':ropen', ':r3', ':r1']) {
    await _plugin.cancel(id: _idFor(key + suffix));
  }
  final s = {...reminders.value}..remove(key);
  reminders.value = s;
  await prefs.setStringList('reminders', s.toList());
}

/// Immediate local notification (used for trail status changes).
Future<void> notifyNow(String title, String body) async {
  if (!_ready) return;
  const det = NotificationDetails(
    android: AndroidNotificationDetails('status', 'Trail status',
        channelDescription: 'Trail open/closed changes'),
    iOS: DarwinNotificationDetails(),
  );
  await _plugin.show(id: 777, title: title, body: body, notificationDetails: det);
}
