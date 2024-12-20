import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_service.dart';
import 'const.dart';
import 'message.dart';
import 'user.dart';

class ChatScreen extends StatefulWidget {
  final User user;

  const ChatScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  List<Message> _messages = [];
  late PusherChannelsClient _pusherClient;
  // late PrivateChannel _channel;

  @override
  void initState() {
    super.initState();
    _initializePusher();
    _loadMessages();
  }

  void _initializePusher() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final token = prefs.getString('token');
    PusherChannelsPackageLogger.enableLogs();

    const options = PusherChannelsOptions.fromHost(
      scheme: scheme,
      host: host,
      key: key,
      port: port,
      shouldSupplyMetadataQueries: true,
      metadata: PusherChannelsOptionsMetadata.byDefault(),
    );

    _pusherClient = PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (exception, trace, refresh) {
        log('Connection error: $exception');
        refresh();
      },
    );

    // _pusherClient.eventStream.listen((event) {
    //   log('channelName: ${event.channelName}');
    //   log('userId: ${event.userId}');
    //   log('rootObject: ${event.rootObject}');
    //   log('name: ${event.name}');
    //   log('data: ${event.data}');
    // });

    final channel = _pusherClient.publicChannel(
      publicChannel,
    );

    final private = _pusherClient.privateChannel(
      'private-chat.$userId',
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPrivateChannel(
        authorizationEndpoint: Uri.parse(broadcastingUrl),
        onAuthFailed: (exception, trace) {
          final ex = exception
              as EndpointAuthorizableChannelTokenAuthorizationException;
          log('EXCEPTION: ${ex.message}');
        },
        headers: {
          'Authorization': 'Bearer $token', // Send user's auth token
        },
      ),
    );

    StreamSubscription<ChannelReadEvent> channelSubscription =
        channel.bind(eventName).listen((event) {
      log('public event received: ${event.data}');
      final messageData = json.decode(event.data);
      insertMessage(Message.fromJson(messageData));
    });

    StreamSubscription<ChannelReadEvent> privateSubscription =
        private.bind(eventName).listen((event) {
      log('Private event received: ${event.data}');
      log('Received private message: $event');
      final messageData = json.decode(event.data);
      insertMessage(Message.fromJson(messageData));
    });

    _pusherClient.onConnectionEstablished.listen((s) {
      log('Connection established');
      channel.subscribe();
      private.subscribe();
    });

    // await _pusherClient.connect();
    // Connect with the client
    unawaited(_pusherClient.connect());

    // Subscribe to private channel
    // _channel = _pusherClient.privateChannel(
    //   'chat.22',
    //   // 'chat.$userId',
    //   authorizationDelegate:
    //       EndpointAuthorizableChannelTokenAuthorizationDelegate
    //           .forPrivateChannel(
    //     // overrideContentTypeHeader: true,
    //     authorizationEndpoint: Uri.parse(broadcastingUrl),
    //     // parser: (response) {
    //     //   final decoded = jsonDecode(response.body) as Map;
    //     //   final auth = decoded['auth'] as String;
    //     //   return PrivateChannelAuthorizationData(
    //     //     authKey: auth,
    //     //   );
    //     // },
    //     onAuthFailed: (exception, trace) {
    //       final ex = exception
    //           as EndpointAuthorizableChannelTokenAuthorizationException;
    //       log('EXCEPTION: ${ex.message}');
    //     },
    //     headers: {
    //       // "Access-Control-Allow-Origin":
    //       //     "*", // Required for CORS support to work
    //       // "Access-Control-Allow-Credentials":
    //       //     'true', // Required for cookies, authorization headers with HTTPS
    //       // "Access-Control-Allow-Headers":
    //       //     "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
    //       // "Access-Control-Allow-Methods": "POST, OPTIONS",
    //       // 'Accept': 'application/json',
    //       // 'Content-Type': 'application/json',
    //       'Authorization': 'Bearer $token', // Send user's auth token
    //     },
    //   ),
    // );

    /*   _channel.bind('App\\Events\\MessageSent').listen((event) {
      log('Received private message: $event');
      final messageData = json.decode(event.data);
      setState(() {
        _messages.add(Message.fromJson(messageData));
      });
    });

    _pusherClient.onConnectionEstablished.listen((_) {
      log('Connection established');
      _channel.subscribeIfNotUnsubscribed();
    });

    _pusherClient.connect(); */
  }

  void _loadMessages() async {
    try {
      final messages = await ChatService().getMessages(
        widget.user.id,
      );
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load messages: $e'),
        ),
      );
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    try {
      final message = await ChatService().sendMessage(
        widget.user.id,
        _messageController.text,
      );
      insertMessage(message);

      setState(() {
        // _messages.add(message);
        _messageController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
        ),
      );
    }
  }

  void insertMessage(Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.name)),
      body: Column(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 500,
                minWidth: 300,
              ),
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Directionality(
                    textDirection: message.receiverId == widget.user.id
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tileColor: Colors.grey.shade200,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        dense: true,
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'user id: ${message.receiverId}',
                              style: const TextStyle(fontSize: 8),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.message,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          message.createdAt.toString(),
                          style: const TextStyle(fontSize: 8),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onSubmitted: (value) {
                      _sendMessage();
                    },
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _pusherClient.dispose();
    super.dispose();
  }
}


// https://api.flutter.dev/flutter/widgets/AnimatedList-class.html