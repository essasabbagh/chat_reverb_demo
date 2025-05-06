// lib/providers/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

import '../models/chat_state.dart';
import '../services/local_storage_service.dart';
import '../services/chat_service.dart';
import '../services/pusher_service.dart';
import '../repositories/chat_repository.dart';
import '../repositories/user_repository.dart';

// Service Providers
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final service = LocalStorageService();
  // Initialize shared preferences
  service.init();
  return service;
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final pusherServiceProvider = Provider<PusherServiceInterface>((ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return PusherService(localStorageService);
});

// Repository Providers
final userRepositoryProvider = Provider<UserRepositoryInterface>((ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return UserRepository(localStorageService);
});

final chatRepositoryProvider = Provider<ChatRepositoryInterface>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  final pusherService = ref.watch(pusherServiceProvider);
  final localStorageService = ref.watch(localStorageServiceProvider);
  return ChatRepository(chatService, pusherService, localStorageService);
});

// Current User Provider
final currentUserProvider = FutureProvider<ChatUser>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return await userRepository.getCurrentChatUser();
});

// Chat State Notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepositoryInterface _chatRepository;

  ChatNotifier(this._chatRepository) : super(ChatState.initial()) {
    _initializeRealTimeUpdates();
  }

  void _initializeRealTimeUpdates() {
    _chatRepository.initializeRealTimeUpdates((message) {
      final updatedMessages = [message, ...state.messages];
      state = state.copyWith(
        messages: updatedMessages,
      );
    });
  }

  Future<void> loadMessages(int userId) async {
    state = ChatState.loading();

    try {
      final messages = await _chatRepository.getMessages(userId);
      state = ChatState.loaded(messages);
    } catch (e) {
      state = ChatState.error(e.toString());
    }
  }

  Future<void> sendMessage(int userId, ChatMessage message) async {
    try {
      // Add message to local state immediately for UI feedback
      final updatedMessages = [message, ...state.messages];
      state = state.copyWith(
        messages: updatedMessages,
      );

      // Send message to server
      await _chatRepository.sendMessage(userId, message.text);
    } catch (e) {
      // On error, remove the message from local state
      state = state.copyWith(
        messages: state.messages.where((m) => m != message).toList(),
        errorMessage: 'Failed to send message: ${e.toString()}',
      );
    }
  }

  Future<void> loadMoreMessages() async {
    // Implementation for pagination (loading more messages)
    state = state.copyWith(isLoadingMore: true);

    // Add implementation for loading more messages

    state = state.copyWith(isLoadingMore: false);
  }

  @override
  void dispose() {
    _chatRepository.dispose();
    super.dispose();
  }
}

// Chat State Provider
final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, int>((ref, userId) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(chatRepository);
});
