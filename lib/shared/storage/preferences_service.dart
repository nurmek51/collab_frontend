import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Preferences service for non-sensitive app data
class PreferencesService {
  static SharedPreferences? _prefs;

  /// Initialize shared preferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  /// Save string value
  Future<bool> setString(String key, String value) async {
    final prefs = await _preferences;
    return await prefs.setString(key, value);
  }

  /// Get string value
  Future<String?> getString(String key) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  /// Save int value
  Future<bool> setInt(String key, int value) async {
    final prefs = await _preferences;
    return await prefs.setInt(key, value);
  }

  /// Get int value
  Future<int?> getInt(String key) async {
    final prefs = await _preferences;
    return prefs.getInt(key);
  }

  /// Save bool value
  Future<bool> setBool(String key, bool value) async {
    final prefs = await _preferences;
    return await prefs.setBool(key, value);
  }

  /// Get bool value
  Future<bool?> getBool(String key) async {
    final prefs = await _preferences;
    return prefs.getBool(key);
  }

  /// Save double value
  Future<bool> setDouble(String key, double value) async {
    final prefs = await _preferences;
    return await prefs.setDouble(key, value);
  }

  /// Get double value
  Future<double?> getDouble(String key) async {
    final prefs = await _preferences;
    return prefs.getDouble(key);
  }

  /// Save list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _preferences;
    return await prefs.setStringList(key, value);
  }

  /// Get list of strings
  Future<List<String>?> getStringList(String key) async {
    final prefs = await _preferences;
    return prefs.getStringList(key);
  }

  /// Save JSON object
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    final prefs = await _preferences;
    return await prefs.setString(key, jsonEncode(value));
  }

  /// Get JSON object
  Future<Map<String, dynamic>?> getJson(String key) async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Remove value
  Future<bool> remove(String key) async {
    final prefs = await _preferences;
    return await prefs.remove(key);
  }

  /// Clear all values
  Future<bool> clear() async {
    final prefs = await _preferences;
    return await prefs.clear();
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    final prefs = await _preferences;
    return prefs.containsKey(key);
  }

  /// Get all keys
  Future<Set<String>> getKeys() async {
    final prefs = await _preferences;
    return prefs.getKeys();
  }
}
