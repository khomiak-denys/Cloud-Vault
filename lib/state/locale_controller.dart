import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const _localeKey = 'app_locale';

  Locale _locale = const Locale('uk');

  Locale get locale => _locale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code == 'en' || code == 'uk') {
      _locale = Locale(code!);
    }
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    if (code != 'uk' && code != 'en') return;
    if (_locale.languageCode == code) return;

    _locale = Locale(code);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
  }
}

final appLocaleController = LocaleController();
