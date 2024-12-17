import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';

import 'package:appwrite_demo/service.dart';

import 'const.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  late PusherChannelsClient client;
  late PublicChannel channel;
  late StreamSubscription<ChannelReadEvent> messageSubscription;

  @override
  void initState() {
    super.initState();
    _initializePusher();
  }

  void _initializePusher() async {
    const options = PusherChannelsOptions.fromHost(
      scheme: scheme,
      host: host,
      key: key,
      port: port,
    );

    client = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (exception, trace, refresh) async {
        log('********************************');
        log('Connection error: $exception');
        refresh(); // Reconnect on errors
      },
    );

    // Initialize a public channel
    channel = client.publicChannel(publicChannel);

    // Subscribe to events on the channel
    messageSubscription = channel.bind(eventName).listen(
      (ChannelReadEvent event) {
        try {
          final data = event.data is String
              ? jsonDecode(event.data) as Map<String, dynamic>
              : event.data as Map<String, dynamic>;

          setState(() {
            messages.add(data['message']);
          });

          debugPrint('event data ********************************');
          print("Parsed event data: $data");
        } catch (e) {
          debugPrint('event error ********************************');
          print("Error parsing event data: $e");
        }
      },
      onError: (Object error) {
        log('error *********************************');
        log(error.toString());
      },
    );

    // Connect to the server
    await client.connect();
    channel.subscribeIfNotUnsubscribed();
  }

  @override
  void dispose() {
    messageSubscription.cancel();
    client.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat App")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Enter message",
                    ),
                    onSubmitted: (value) {
                      if (_controller.text.isNotEmpty) {
                        Service.sendMessage(_controller.text);
                        _controller.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      Service.sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
