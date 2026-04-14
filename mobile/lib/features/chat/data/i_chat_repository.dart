import '../../../shared/models/chat_message_model.dart';

abstract class IChatRepository {
  Future<List<ChatMessageModel>> getMessages(String eventId);
}
