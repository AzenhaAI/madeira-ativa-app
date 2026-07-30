import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

/// User's favorite items, keyed as `event:NAME|DATE` or `levada:CODE`.
final favorites = ValueNotifier<Set<String>>({});

Future<void> initStore() async {
  prefs = await SharedPreferences.getInstance();
  favorites.value = (prefs.getStringList('favorites') ?? []).toSet();
}

/// Network-first JSON fetch with a local cache fallback. On success the raw
/// body is cached; if the network fails, the last cached body is returned so
/// the app still works offline / with a weak signal in the mountains.
Future<dynamic> cachedJson(String url) async {
  final key = 'cache:$url';
  try {
    final r =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
    // Cache only what actually parsed, and only from a 200. Writing the body
    // first meant a 5xx error page overwrote the last good JSON, and then the
    // fallback below re-read that same HTML and threw a second time — the
    // offline cache stayed poisoned even after the server recovered.
    if (r.statusCode != 200) {
      throw http.ClientException('HTTP ${r.statusCode}', Uri.parse(url));
    }
    final body = utf8.decode(r.bodyBytes);
    final parsed = jsonDecode(body);
    await prefs.setString(key, body);
    return parsed;
  } catch (e) {
    final cached = prefs.getString(key);
    if (cached != null) {
      try {
        return jsonDecode(cached);
      } catch (_) {
        await prefs.remove(key); // written by an older, less careful version
      }
    }
    rethrow;
  }
}

bool isFav(String key) => favorites.value.contains(key);

void toggleFav(String key) {
  HapticFeedback.lightImpact();
  final s = {...favorites.value};
  s.contains(key) ? s.remove(key) : s.add(key);
  favorites.value = s;
  prefs.setStringList('favorites', s.toList());
}
