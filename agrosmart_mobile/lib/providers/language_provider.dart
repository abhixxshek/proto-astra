import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _prefKeyIsHindi = 'pref_is_hindi';
  bool _isHindi = false;

  bool get isHindi => _isHindi;
  String get currentLanguageCode => _isHindi ? 'hi' : 'en';

  LanguageProvider() {
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isHindi = prefs.getBool(_prefKeyIsHindi) ?? false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLanguage(bool isHindi) async {
    _isHindi = isHindi;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyIsHindi, isHindi);
    } catch (_) {}
    notifyListeners();
  }

  void toggleLanguage() {
    setLanguage(!_isHindi);
  }
}
