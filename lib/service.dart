import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:appwrite_demo/const.dart';
import 'package:http/http.dart' as http;

class Service {
 static Future<void> sendMessage(String message) async {
    try {
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };
      var request = http.Request(
        'POST',
        Uri.parse('$baseUrl/send-message'),
      );
      request.body = json.encode({"message": message});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      log('_postMessage ********************************');

      log(e.toString());
    }
  }
}
