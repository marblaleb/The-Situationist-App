import '../../../core/network/api_client.dart';
import '../../../shared/models/chat_message_model.dart';
import 'i_chat_repository.dart';

class ChatRepository implements IChatRepository {
  final ApiClient _apiClient;

  ChatRepository(this._apiClient);

  @override
  Future<List<ChatMessageModel>> getMessages(String eventId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/events/$eventId/messages',
    );
    return (response.data as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ChatMessageModel.fromJson)
        .toList();
  }
}
