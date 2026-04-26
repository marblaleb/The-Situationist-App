class ChatMessageModel {
  final String id;
  final String eventId;
  final String senderId;
  final String senderUsername;
  final String content;
  final DateTime sentAt;

  const ChatMessageModel({
    required this.id,
    required this.eventId,
    required this.senderId,
    required this.senderUsername,
    required this.content,
    required this.sentAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      senderId: json['senderId'] as String,
      senderUsername: json['senderUsername'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String).toLocal(),
    );
  }
}
