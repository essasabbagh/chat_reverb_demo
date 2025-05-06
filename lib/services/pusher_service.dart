// lib/services/pusher_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';

import '../const.dart';
import '../models/message.dart';
import '../services/local_storage_service.dart';

/// Interface for the Pusher service
abstract class PusherServiceInterface {
  /// Initialize the Pusher client
  Future<void> initialize();

  /// Subscribe to a public channel
  Future<void> subscribeToPublicChannel(
      String channelName, Function(Message) onMessageReceived);

  /// Subscribe to a private channel
  Future<void> subscribeToPrivateChannel(
      String channelName, Function(Message) onMessageReceived);

  /// Dispose of Pusher resources
  void dispose();
}

/// Implementation of the Pusher service
class PusherService implements PusherServiceInterface {
  final LocalStorageService _storageService;
  late PusherChannelsClient _pusherClient;
  final List<StreamSubscription> _subscriptions = [];

  /// Constructor
  PusherService(this._storageService);

  @override
  Future<void> initialize() async {
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
      log('Event received: ${event.name} on ${event.channelName}');
      log('Event data: ${event.data}');
    });

    final connectSubscription =
        _pusherClient.onConnectionEstablished.listen((s) {
      log('Pusher connection established');
    });

    _subscriptions.add(connectSubscription);

    // Connect with the client
    unawaited(_pusherClient.connect());
  }

  @override
  Future<void> subscribeToPublicChannel(
      String channelName, Function(Message) onMessageReceived) async {
    final channel = _pusherClient.publicChannel(channelName);

    final subscription = channel.bind(eventName).listen((event) {
      log('Public event received: ${event.data}');
      try {
        final messageData = Message.fromJson(json.decode(event.data));
        onMessageReceived(messageData);
      } catch (e) {
        log('Error parsing message: $e');
      }
    });

    _subscriptions.add(subscription);
    channel.subscribe();
  }

  @override
  Future<void> subscribeToPrivateChannel(
      String channelName, Function(Message) onMessageReceived) async {
    final token = _storageService.getToken() ?? '';

    final channel = _pusherClient.privateChannel(
      channelName,
      authorizationDelegate:
          EndpointAuthorizableChannelTokenAuthorizationDelegate
              .forPrivateChannel(
        authorizationEndpoint: Uri.parse(broadcastingUrl),
        onAuthFailed: (exception, trace) {
          final ex = exception
              as EndpointAuthorizableChannelTokenAuthorizationException;
          log('Auth failed: ${ex.message}');
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final subscription = channel.bind(eventName).listen((event) {
      log('Private event received: ${event.data}');
      try {
        final messageData = Message.fromJson(json.decode(event.data));
        onMessageReceived(messageData);
      } catch (e) {
        log('Error parsing message: $e');
      }
    });

    _subscriptions.add(subscription);
    channel.subscribe();
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _pusherClient.dispose();
  }
}
