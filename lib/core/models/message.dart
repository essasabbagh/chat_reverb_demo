// class Message {
//   final int id;
//   final int senderId;
//   final int receiverId;
//   final String content;
//   final DateTime createdAt;

//   const Message({
//     required this.id,
//     required this.senderId,
//     required this.receiverId,
//     required this.content,
//     required this.createdAt,
//   });

//   factory Message.fromJson(Map<String, dynamic> json) {
//     return Message(
//       id: json['id'],
//       senderId: json['sender_id'],
//       receiverId:
//           json['receiver_id'], // Ensure this matches the key from your backend
//       content: json['content'],
//       createdAt: DateTime.parse(json['created_at']),
//     );
//   }

//   // Optional: Add toJson method for consistency
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'sender_id': senderId,
//       'receiver_id': receiverId,
//       'content': content,
//       'created_at': createdAt.toIso8601String(),
//     };
//   }
// }
