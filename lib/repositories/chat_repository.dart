// lib/repositories/chat_repository.dart

import 'package:appwrite_demo/const.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

import '../models/message.dart' as app_message;
import '../models/user.dart';
import '../services/chat_service.dart';
import '../services/pusher_service.dart';
import '../services/local_storage_service.dart';

/// Interface for the chat repository
abstract class ChatRepositoryInterface {
  /// Get messages for a specific chat
  Future<List<ChatMessage>> getMessages(int userId);

  /// Send a message to a specific user
  Future<void> sendMessage(int userId, String message);

  /// Initialize Pusher channels for real-time updates
  Future<void> initializeRealTimeUpdates(
      Function(ChatMessage) onMessageReceived);

  /// Dispose of resources
  void dispose();
}

/// Implementation of the chat repository
class ChatRepository implements ChatRepositoryInterface {
  final ChatService _chatService;
  final PusherServiceInterface _pusherService;
  final LocalStorageService _storageService;

  /// Constructor
  ChatRepository(this._chatService, this._pusherService, this._storageService);

  @override
  Future<List<ChatMessage>> getMessages(int userId) async {
    try {
      final messages = await _chatService.getMessages(userId);
      return _convertToChatMessages(messages);
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  @override
  Future<void> sendMessage(int userId, String message) async {
    try {
      await _chatService.sendMessage(userId, message);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> initializeRealTimeUpdates(
      Function(ChatMessage) onMessageReceived) async {
    await _pusherService.initialize();

    final userId = _storageService.getUserId();

    if (userId == null) {
      throw Exception('User ID not found in local storage');
    }

    // Subscribe to public channel
    await _pusherService.subscribeToPublicChannel(publicChannelName,
        (app_message.Message message) {
      final chatMessage = _convertToChatMessage(message);
      onMessageReceived(chatMessage);
    });

    // Subscribe to private channel
    await _pusherService.subscribeToPrivateChannel('private-chat.$userId',
        (app_message.Message message) {
      final chatMessage = _convertToChatMessage(message);
      onMessageReceived(chatMessage);
    });
  }

  /// Convert app message model to chat message model
  ChatMessage _convertToChatMessage(app_message.Message message) {
    return ChatMessage(
      createdAt: message.createdAt,
      text: message.message,
      user: ChatUser(
        id: message.senderId.toString(),
        profileImage: 'https://avatar.iran.liara.run/public',
      ),
    );
  }

  /// Convert a list of app message models to chat message models
  List<ChatMessage> _convertToChatMessages(List<app_message.Message> messages) {
    return messages.reversed.map((msg) => _convertToChatMessage(msg)).toList();
  }

  @override
  void dispose() {
    _pusherService.dispose();
  }
}
