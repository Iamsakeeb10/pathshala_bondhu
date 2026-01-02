import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
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

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'already_have_account': 'Already have an account?',
      'login': 'Login',
      'full_name': 'Full Name',
      'profile': 'Profile',
      'notifications': 'Notifications',
      'settings': 'Settings',
      'about': 'About',
      'logout': 'Logout',
      'cancel': 'Cancel',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'privacy_policy': 'Privacy Policy',
      'terms_conditions': 'Terms & Conditions',
    },
    'bn': {
      'signup': 'নিবন্ধন করুন',
      'email': 'ইমেইল',
      'password': 'পাসওয়ার্ড',
      'confirm_password': 'পাসওয়ার্ড নিশ্চিত করুন',
      'already_have_account': 'ইতিমধ্যে একটি অ্যাকাউন্ট আছে?',
      'login': 'লগইন',
      'full_name': 'পুরো নাম',
      'profile': 'প্রোফাইল',
      'notifications': 'নোটিফিকেশন',
      'settings': 'সেটিংস',
      'about': 'সম্পর্কে',
      'logout': 'লগআউট',
      'cancel': 'বাতিল',
      'dark_mode': 'ডার্ক মোড',
      'language': 'ভাষা',
      'privacy_policy': 'গোপনীয়তা নীতি',
      'terms_conditions': 'শর্তাবলী',
    },
  };

  void changeLanguage(Locale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  String translate(String key) {
    return _localizedValues[_currentLocale.languageCode]?[key] ?? key;
  }
}
