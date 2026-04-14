class ChatMessageModel {
  final String id;
  final String eventId;
  final String senderId;
  final String senderEmail;
  final String content;
  final DateTime sentAt;

  const ChatMessageModel({
    required this.id,
    required this.eventId,
    required this.senderId,
    required this.senderEmail,
    required this.content,
    required this.sentAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      senderId: json['senderId'] as String,
      senderEmail: json['senderEmail'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String).toLocal(),
    );
  }

  String get senderHandle => senderEmail.split('@').first;
}
