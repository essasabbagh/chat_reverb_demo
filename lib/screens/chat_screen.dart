import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/chat_service.dart';
import '../const.dart';
import '../models/message.dart';
import '../models/user.dart';

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
  late String userId;
  bool isLoading = false;
  List<ChatMessage> _messages = [];
  late PusherChannelsClient _pusherClient;

  void _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId').toString();
  }

  @override
  void initState() {
    super.initState();

    _getUserId();
    _initializePusher();
    _loadMessages();
  }

  // In your _ChatScreenState class, replace the _initializePusher method with this:

  void _initializePusher() async {
    final prefs = await SharedPreferences.getInstance();

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

    _pusherClient.eventStream.listen((event) {
      log('channelName: ${event.channelName}');
      log('userId: ${event.userId}');
      log('rootObject: ${event.rootObject}');
      log('name: ${event.name}');
      log('data: ${event.data}');
    });

    final publicChannel = _pusherClient.publicChannel(
      publicChannelName,
    );

    final privateChannel = _pusherClient.privateChannel(
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
        publicChannel.bind(eventName).listen((event) {
      log('public event received: ${event.data}');
      final messageData = Message.fromJson(json.decode(event.data));
      insertMessage(
        ChatMessage(
          createdAt: messageData.createdAt,
          text: messageData.message,
          user: ChatUser(
            id: messageData.senderId.toString(),
            profileImage: 'https://avatar.iran.liara.run/public',
          ),
        ),
      );
    });

    StreamSubscription<ChannelReadEvent> privateSubscription =
        privateChannel.bind(eventName).listen((event) {
      log('Private event received: ${event.data}');
      log('Received private message: $event');
      final messageData = Message.fromJson(json.decode(event.data));
      insertMessage(
        ChatMessage(
          createdAt: messageData.createdAt,
          text: messageData.message,
          user: ChatUser(
            id: messageData.senderId.toString(),
            profileImage: 'https://avatar.iran.liara.run/public',
          ),
        ),
      );
    });

    _pusherClient.onConnectionEstablished.listen((s) {
      log('Connection established');
      // publicChannel.subscribe();
      privateChannel.subscribe();
    });

    // Connect with the client
    unawaited(_pusherClient.connect());
  }

  void _loadMessages() async {
    try {
      setState(() {
        isLoading = true;
      });
      final messages = await ChatService().getMessages(
        widget.user.id,
      );
      setState(() {
        _messages = messages.reversed.map((msg) {
          return ChatMessage(
            createdAt: msg.createdAt,
            text: msg.message,
            user: ChatUser(
              id: msg.senderId.toString(),
              profileImage: 'https://avatar.iran.liara.run/public',
            ),
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('E: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load messages: $e'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _sendMessage(ChatMessage message) async {
    try {
      final res = await ChatService().sendMessage(
        widget.user.id,
        message.text,
      );

      insertMessage(message);
    } catch (e) {
      debugPrint('E: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
        ),
      );
    }
  }

  void insertMessage(ChatMessage message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.name)),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : DashChat(
              messages: _messages,
              onSend: _sendMessage,
              currentUser: ChatUser(
                id: userId,
                firstName: 'Me',
                lastName: '',
                profileImage: 'https://avatar.iran.liara.run/public',
              ),
              inputOptions: InputOptions(
                inputTextStyle: TextStyle(
                  color: Colors.grey.shade900,
                ),
                inputDecoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: const EdgeInsets.only(
                    left: 18,
                    top: 10,
                    bottom: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              messageOptions: MessageOptions(
                containerColor: Colors.grey.shade200,
                currentUserContainerColor: Colors.grey.shade200,
                currentUserTextColor: Colors.black87,
                currentUserTimeTextColor: Colors.black38,
                messagePadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                showTime: true,
                spaceWhenAvatarIsHidden: 6,
                textColor: Colors.black87,
                timeFontSize: 8,
                timePadding: EdgeInsets.only(top: 2),
                timeTextColor: Colors.black26,
              ),
              messageListOptions: MessageListOptions(
                scrollPhysics: AlwaysScrollableScrollPhysics(),
                dateSeparatorBuilder: (date) => DefaultDateSeparator(
                  date: date,
                  textStyle: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onLoadEarlier: () async {
                  await Future.delayed(const Duration(seconds: 2));
                },
              ),
            ),
    );
  }

  @override
  void dispose() {
    _pusherClient.dispose();
    super.dispose();
  }
}


// https://api.flutter.dev/flutter/widgets/AnimatedList-class.html