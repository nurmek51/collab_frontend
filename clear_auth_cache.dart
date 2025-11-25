// Quick script to clear auth cache
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> clearAuthCache() async {
  print('Clearing authentication cache...');

  // Clear SharedPreferences (TokenManager data)
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');
  await prefs.remove('refresh_token');
  await prefs.remove('expires_in');
  await prefs.remove('token_expiration');
  await prefs.remove('user_id');
  await prefs.remove('current_role');
  await prefs.remove('freelancer_onboarding_state');
  await prefs.remove('selected_role');
  await prefs.remove('phone_number');

  // Clear FlutterSecureStorage (AuthStore data)
  const storage = FlutterSecureStorage();
  await storage.delete(key: 'access_token');
  await storage.delete(key: 'token_type');
  await storage.delete(key: 'expires_in');
  await storage.delete(key: 'role');
  await storage.delete(key: 'user_id');
  await storage.delete(key: 'token_created_at');

  print('✅ Authentication cache cleared successfully!');
  print('🔄 Please restart the app to return to authentication flow.');
}

void main() async {
  await clearAuthCache();
}
