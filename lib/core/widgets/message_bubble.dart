// // widgets/message_bubble.dart
// import 'package:flutter/material.dart';

// import '../models/message_model.dart';

// class MessageBubble extends StatelessWidget {
//   final Message message;

//   const MessageBubble({super.key, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     final isMe = message.sender == 'YourName'; // Adjust as per your logic
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         padding: const EdgeInsets.all(10.0),
//         margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
//         decoration: BoxDecoration(
//           color: isMe ? Colors.blue : Colors.grey[300],
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: Column(
//           crossAxisAlignment:
//               isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           children: [
//             Text(
//               message.sender,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: isMe ? Colors.white : Colors.black,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               message.content,
//               style: TextStyle(
//                 color: isMe ? Colors.white : Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
