// lib/models/chat_state.dart

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/foundation.dart';

/// The different states a chat can be in
enum ChatStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Class to represent the state of the chat
@immutable
class ChatState {
  /// The current status of the chat
  final ChatStatus status;

  /// List of chat messages
  final List<ChatMessage> messages;

  /// Error message if any
  final String? errorMessage;

  /// Is more messages being loaded
  final bool isLoadingMore;

  /// Constructor
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.isLoadingMore = false,
  });

  /// Create a copy of this state with some changes
  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? errorMessage,
    bool? isLoadingMore,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  /// Initial state of the chat
  factory ChatState.initial() => const ChatState();

  /// Loading state of the chat
  factory ChatState.loading() => const ChatState(status: ChatStatus.loading);

  /// Loaded state of the chat
  factory ChatState.loaded(List<ChatMessage> messages) =>
      ChatState(status: ChatStatus.loaded, messages: messages);

  /// Error state of the chat
  factory ChatState.error(String message) =>
      ChatState(status: ChatStatus.error, errorMessage: message);
}
