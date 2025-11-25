import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _localeKey = 'selected_locale';
  static const String _defaultLocale = 'ru';

  late SharedPreferences _prefs;

  static final LocalizationService _instance = LocalizationService._internal();

  factory LocalizationService() {
    return _instance;
  }

  LocalizationService._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setLocale(String locale) async {
    await _prefs.setString(_localeKey, locale);
  }

  String getLocale() {
    return _prefs.getString(_localeKey) ?? _defaultLocale;
  }

  Locale getCurrentLocale() {
    final localeString = getLocale();
    return Locale(localeString);
  }

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ru')];
}
