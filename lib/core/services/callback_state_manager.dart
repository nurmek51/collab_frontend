import 'package:shared_preferences/shared_preferences.dart';

class CallbackStateManager {
  static const String _callbackRequestedKey = 'callback_requested';
  static const String _callbackTimestampKey = 'callback_timestamp';
  static const int _callbackValidityHours = 24;

  static CallbackStateManager? _instance;
  static CallbackStateManager get instance =>
      _instance ??= CallbackStateManager._();

  CallbackStateManager._();

  Future<void> setCallbackRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_callbackRequestedKey, true);
    await prefs.setInt(
      _callbackTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<bool> hasActiveCallbackRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCallback = prefs.getBool(_callbackRequestedKey) ?? false;

    if (!hasCallback) return false;

    final timestamp = prefs.getInt(_callbackTimestampKey) ?? 0;
    final callbackTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final hoursDifference = now.difference(callbackTime).inHours;

    if (hoursDifference >= _callbackValidityHours) {
      await clearCallbackRequest();
      return false;
    }

    return true;
  }

  Future<void> clearCallbackRequest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_callbackRequestedKey);
    await prefs.remove(_callbackTimestampKey);
  }
}
