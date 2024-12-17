// // screens/chat_screen.dart
// import 'package:flutter/material.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../providers/chat_provider.dart';
// import '../widgets/message_bubble.dart';

// class NewChatScreen extends ConsumerWidget {
//   const NewChatScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final chatState = ref.watch(chatProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Chat')),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: chatState.length,
//               itemBuilder: (context, index) {
//                 final message = chatState[index];
//                 return MessageBubble(message: message);
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: TextEditingController(),
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: 'Type a message',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     final textController = TextEditingController();
//                     ref.read(chatProvider.notifier).sendMessage(
//                           textController.text,
//                           'YourName',
//                         );
//                     textController.clear();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
