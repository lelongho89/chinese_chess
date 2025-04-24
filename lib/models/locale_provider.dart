import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static LocaleProvider? _instance;
  
  Locale _locale = const Locale('en');
  SharedPreferences? _prefs;
  
  Locale get locale => _locale;
  
  static Future<LocaleProvider> getInstance() async {
    if (_instance == null) {
      _instance = LocaleProvider();
      await _instance!._init();
    }
    return _instance!;
  }
  
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final String? savedLocale = _prefs?.getString(_localeKey);
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    }
  }
  
  Future<void> setLocale(String localeCode) async {
    _locale = Locale(localeCode);
    await _prefs?.setString(_localeKey, localeCode);
    notifyListeners();
  }
}
