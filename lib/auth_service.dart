import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

class AuthService {
  // static const String baseUrl = 'https://your-api-url.com/api';
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {
        'email': email,
        'password': password
      }
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Save token and user info
      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('token', data['token']);
        prefs.setInt('userId', data['user']['id']);
      });
      return data;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
  }
}