import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔹 مزوّد اللغة (Locale) للتطبيق
/// يخزّن لغة الواجهة (ar / en) في SharedPreferences
class LocaleProvider extends ChangeNotifier {
  static const _kKey = 'app_locale'; // 'ar' أو 'en' (غيابها = لغة النظام)

  Locale? _locale; // null => لغة النظام
  Locale? get locale => _locale;

  /// تحميل اللغة المحفوظة من التخزين المحلي
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kKey);
    _locale = (code == null || code.isEmpty) ? null : Locale(code);
    notifyListeners();
  }

  /// تحديث اللغة وحفظها
  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_kKey); // إذا رجع للغة النظام
    } else {
      await prefs.setString(_kKey, locale.languageCode);
    }
  }

  /// تغيير اللغة من خلال كود مباشرة ('ar' / 'en')
  Future<void> setLocaleCode(String? code) async {
    await setLocale((code == null || code.isEmpty) ? null : Locale(code));
  }
}
