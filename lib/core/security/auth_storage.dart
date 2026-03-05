import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyEmail = 'auth_email';
  static const _keyUserId = 'auth_user_id';

  // Save Credentials
  static Future<void> saveCredentials({
    required String token,
    required String email,
    required String userId,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyUserId, value: userId);
  }

  // Get Token
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Get Email
  static Future<String?> getEmail() async {
    return await _storage.read(key: _keyEmail);
  }

  // Get User ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  // Clear Credentials (Logout)
  static Future<void> clearCredentials() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyUserId);
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
