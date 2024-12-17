// // models/message_model.dart
// class Message {
//   final String id;
//   final String sender;
//   final String content;
//   final DateTime timestamp;

//   Message({
//     required this.id,
//     required this.sender,
//     required this.content,
//     required this.timestamp,
//   });

//   factory Message.fromJson(Map<String, dynamic> json) {
//     return Message(
//       id: json['id'],
//       sender: json['sender'],
//       content: json['content'],
//       timestamp: DateTime.parse(json['timestamp']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'sender': sender,
//       'content': content,
//       'timestamp': timestamp.toIso8601String(),
//     };
//   }
// }
