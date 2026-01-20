import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('bn'),
  ];

  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'bn':
        return 'Bangla';
      default:
        return 'Unknown';
    }
  }

  /// Initialize language from SharedPreferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey) ?? 'en';
    _currentLocale = Locale(savedLanguage);
    notifyListeners();
  }

  /// Change language and persist to SharedPreferences
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      notifyListeners();
    }
  }

  /// Set language by code string
  Future<void> setLanguage(String code) async {
    final locale = Locale(code);
    await changeLanguage(locale);
  }

  /// Toggle between supported languages
  Future<void> toggleLanguage() async {
    final currentIndex = supportedLocales.indexWhere(
      (locale) => locale.languageCode == _currentLocale.languageCode,
    );
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    await changeLanguage(supportedLocales[nextIndex]);
  }

  String translate(String key) {
    // This method is kept for backward compatibility
    // But translations should use AppLocalizations.of(context).translate(key)
    return key;
  }
}
