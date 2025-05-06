import 'package:appwrite_demo/providers/chat_provider.dart';
import 'package:flutter/material.dart';

import 'package:dash_chat_2/dash_chat_2.dart';

// lib/ui/screens/chat_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

import '../../models/chat_state.dart';
import '../../models/user.dart' as app_user;

class ChatScreen extends ConsumerStatefulWidget {
  final app_user.User user;

  const ChatScreen({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // Load messages when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatProvider(widget.user.id).notifier)
          .loadMessages(widget.user.id);
    });
  }

  void _sendMessage(ChatMessage message) {
    ref.read(chatProvider(widget.user.id).notifier).sendMessage(
          widget.user.id,
          message,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the chat state for this specific user
    final chatState = ref.watch(chatProvider(widget.user.id));
    // Watch the current user
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.user.name)),
      body: currentUserAsync.when(
        data: (currentUser) {
          return _buildChatUI(chatState, currentUser);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error loading user: $error'),
        ),
      ),
    );
  }

  Widget _buildChatUI(ChatState chatState, ChatUser currentUser) {
    switch (chatState.status) {
      case ChatStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case ChatStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${chatState.errorMessage}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(chatProvider(widget.user.id).notifier)
                      .loadMessages(widget.user.id);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );

      case ChatStatus.loaded:
      case ChatStatus.initial:
        return DashChat(
          messages: chatState.messages,
          onSend: _sendMessage,
          currentUser: currentUser,
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
            messagePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            showTime: true,
            spaceWhenAvatarIsHidden: 6,
            textColor: Colors.black87,
            timeFontSize: 8,
            timePadding: const EdgeInsets.only(top: 2),
            timeTextColor: Colors.black26,
          ),
          messageListOptions: MessageListOptions(
            scrollPhysics: const AlwaysScrollableScrollPhysics(),
            dateSeparatorBuilder: (date) => DefaultDateSeparator(
              date: date,
              textStyle: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
            onLoadEarlier: chatState.isLoadingMore
                ? null
                : () async {
                    await ref
                        .read(chatProvider(widget.user.id).notifier)
                        .loadMoreMessages();
                  },
          ),
        );
    }
  }
}

// https://api.flutter.dev/flutter/widgets/AnimatedList-class.html