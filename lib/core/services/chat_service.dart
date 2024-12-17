// // services/chat_service.dart
// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';

// import 'package:dart_pusher_channels/dart_pusher_channels.dart';
// import 'package:http/http.dart' as http;

// import '../models/message_model.dart';

// class ChatService {
//   final PusherChannelsClient _client;
//   late final PublicChannel _channel;

//   final _messageStreamController = StreamController<Message>.broadcast();
//   Stream<Message> get messagesStream => _messageStreamController.stream;

//   ChatService(this._client);

//   Future<void> connect() async {
//     await _client.connect();
//     _channel = _client.publicChannel('messages');
//     _channel.bind('message-sent').listen((event) {
//       final data = jsonDecode(event.data as String);
//       final message = Message.fromJson(data);
//       _messageStreamController.add(message);
//     });
//   }

// /*   Future<void> postMessage(Message message) async {
//     _channel.trigger(
//       eventName: 'client-message-sent',
//       data: message.toJson(),
//     );
//   } */

//   Future<void> sendMessage(Message message) async {
//     try {
//       var headers = {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json'
//       };
//       var request = http.Request(
//         'POST',
//         Uri.parse('http://chat_app.test/api/send-message'),
//       );
//       request.body = json.encode(
//         message.toJson(),
//       );
//       request.headers.addAll(headers);

//       http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         print(await response.stream.bytesToString());
//       } else {
//         print(response.reasonPhrase);
//       }
//     } catch (e) {
//       log('_postMessage ********************************');

//       log(e.toString());
//     }
//   }

//   void dispose() {
//     _messageStreamController.close();
//     _client.dispose();
//   }
// }
