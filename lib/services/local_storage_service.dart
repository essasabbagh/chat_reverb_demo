// lib/services/local_storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';

/// A service class for handling local storage operations
class LocalStorageService {
  late SharedPreferences _prefs;

  /// Initialize the shared preferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save user ID to local storage
  Future<bool> saveUserId(int userId) async {
    return await _prefs.setInt('userId', userId);
  }

  /// Get user ID from local storage
  int? getUserId() {
    return _prefs.getInt('userId');
  }

  /// Save authentication token to local storage
  Future<bool> saveToken(String token) async {
    return await _prefs.setString('token', token);
  }

  /// Get authentication token from local storage
  String? getToken() {
    return _prefs.getString('token');
  }

  /// Save user data to local storage
  Future<bool> saveUserData(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Get user data from local storage
  String? getUserData(String key) {
    return _prefs.getString(key);
  }

  /// Clear all user data from local storage
  Future<bool> clearUserData() async {
    return await _prefs.clear();
  }
}
