// // providers/chat_provider.dart
// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/material.dart';

// import 'package:dart_pusher_channels/dart_pusher_channels.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../models/message_model.dart';
// import '../services/chat_service.dart';

// final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>((ref) {
//   final chatService = ref.read(chatServiceProvider);
//   return ChatNotifier(chatService);
// });

// final chatServiceProvider = Provider<ChatService>((ref) {
//   const options = PusherChannelsOptions.fromHost(
//     scheme: 'ws', // 'ws' for non-secure connections
//     host: 'localhost', // Replace with your server's hostname
//     key: 'vvi9foswtexagmutenwt', // Replace with your Pusher app key
//     port: 8080, // Replace with your WebSocket port
//   );

//   final client = PusherChannelsClient.websocket(
//     options: options,
//     connectionErrorHandler: (exception, trace, refresh) async {
//       log('********************************');
//       log('Connection error: $exception');
//       refresh(); // Reconnect on errors
//     },
//   );

//   return ChatService(client);
// });

// class ChatNotifier extends StateNotifier<List<Message>> {
//   final ChatService _chatService;

//   ChatNotifier(this._chatService) : super([]) {
//     _chatService.messagesStream.listen((message) {
//       state = [...state, message];
//     });
//   }

//   Future<void> connect() async {
//     await _chatService.connect();
//   }

//   Future<void> sendMessage(String content, String sender) async {
//     final message = Message(
//       id: DateTime.now().toString(),
//       sender: sender,
//       content: content,
//       timestamp: DateTime.now(),
//     );
//     await _chatService.sendMessage(message);
//   }
// }
