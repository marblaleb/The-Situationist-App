import '../../../core/network/api_client.dart';
import '../../../shared/models/deriva_session_model.dart';
import 'i_deriva_repository.dart';

class DerivaRepository implements IDerivaRepository {
  final ApiClient _client;

  DerivaRepository(this._client);

  @override
  Future<DerivaSessionModel> startSession({
    required String type,
    required double lat,
    required double lng,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/deriva/sessions',
      data: {'type': type, 'latitude': lat, 'longitude': lng, 'language': 'es'},
    );
    return DerivaSessionModel.fromJson(response.data!);
  }

  @override
  Future<DerivaInstructionModel> getNextInstruction({
    required String sessionId,
    required double lat,
    required double lng,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/deriva/sessions/$sessionId/next-instruction',
      queryParameters: {'lat': lat, 'lng': lng, 'lang': 'es'},
    );
    return DerivaInstructionModel.fromJson(response.data!);
  }

  @override
  Future<void> completeSession(String sessionId) async {
    await _client.post<void>('/deriva/sessions/$sessionId/complete');
  }

  @override
  Future<void> abandonSession(String sessionId) async {
    await _client.post<void>('/deriva/sessions/$sessionId/abandon');
  }
}
