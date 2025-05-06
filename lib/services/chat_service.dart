import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:appwrite_demo/models/message.dart';

import '../const.dart';

class ChatService {
  Future<List<Message>> getMessages(int receiverId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response =
        await http.get(Uri.parse('$baseUrl/messages/$receiverId'), headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    });

    // debugPrint('RESPONSE: ${response.body}');
    if (response.statusCode == 200) {
      List<dynamic> messagesJson = json.decode(response.body);
      return messagesJson.map((m) => Message.fromJson(m)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<Message> sendMessage(int receiverId, String messageText) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/send-message'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: json.encode(
        {
          'receiver_id': receiverId,
          'message': messageText,
        },
      ),
    );
    log(' token: $token');
    log('RESPONSE sendMessage: ${response.body}');

    if (response.statusCode == 200) {
      return Message.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }
}
