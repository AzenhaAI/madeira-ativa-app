import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Asking for a rating, on Apple's terms rather than ours.
///
/// Two different things live here and they are not interchangeable:
///
/// * [maybeAskForReview] triggers the *system* prompt. iOS draws it, the rating
///   is given without leaving the app, and iOS decides whether to draw it at
///   all — three times a year per user, and there is no way to find out what it
///   did. So the call must be fire-and-forget: never gate anything on it, never
///   follow it with "did that work?", never show our own dialog as a fallback.
///   A hand-rolled "rate us" box with buttons is against the guidelines.
///
/// * [openStoreListing] opens the App Store page straight onto the review form.
///   No quota, because a person pressed a menu row to get there.
///
/// The counter below exists because the prompt is a scarce resource. Spending
/// one of three yearly chances on someone who opened the app once, at launch,
/// wastes it. It is spent after a few real uses instead — and only once per
/// install, so a heavy user is never nagged twice by us on top of whatever iOS
/// allows.
class AskReview {
  static const _kUses = 'review_uses';
  static const _kAsked = 'review_asked';

  /// Real uses before the prompt is worth spending. Three trail pages is a
  /// person who came back and looked around, not a bounce.
  static const _threshold = 3;

  static final _plugin = InAppReview.instance;

  /// Call at a moment that went well. Cheap, silent, and safe to call often.
  static Future<void> maybeAskForReview() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kAsked) ?? false) return;

    final uses = (prefs.getInt(_kUses) ?? 0) + 1;
    await prefs.setInt(_kUses, uses);
    if (uses < _threshold) return;

    if (await _plugin.isAvailable()) {
      await prefs.setBool(_kAsked, true);
      await _plugin.requestReview();
    }
  }

  /// The menu row. Opens the store page with the review sheet already up.
  static Future<void> openStoreListing() =>
      _plugin.openStoreListing(appStoreId: '6796836699');
}
