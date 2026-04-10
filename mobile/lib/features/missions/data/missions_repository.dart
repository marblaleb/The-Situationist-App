import '../../../core/network/api_client.dart';
import '../../../shared/models/mission_model.dart';
import '../../../shared/models/mission_progress_model.dart';
import 'i_missions_repository.dart';

class MissionsRepository implements IMissionsRepository {
  final ApiClient _client;

  MissionsRepository(this._client);

  @override
  Future<List<MissionModel>> getNearbyMissions({
    required double lat,
    required double lng,
    required int radius,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/missions',
      queryParameters: {'lat': lat, 'lng': lng, 'radius': radius},
    );
    return (response.data as List)
        .map((e) => MissionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MissionDetailModel> getMissionDetail(String missionId) async {
    final response =
        await _client.get<Map<String, dynamic>>('/missions/$missionId');
    return MissionDetailModel.fromJson(response.data!);
  }

  @override
  Future<MissionProgressModel> startMission(String missionId) async {
    final response = await _client
        .post<Map<String, dynamic>>('/missions/$missionId/start');
    return MissionProgressModel.fromJson(response.data!);
  }

  @override
  Future<SubmitAnswerResponse> submitAnswer({
    required String missionId,
    required String clueId,
    required String answer,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/missions/$missionId/clues/$clueId/submit',
      data: {'answer': answer},
    );
    return SubmitAnswerResponse.fromJson(response.data!);
  }

  @override
  Future<String> requestHint({
    required String missionId,
    required String clueId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/missions/$missionId/clues/$clueId/hint',
    );
    return response.data!['hint'] as String;
  }

  @override
  Future<MissionProgressModel> getMissionProgress(String missionId) async {
    final response =
        await _client.get<Map<String, dynamic>>('/missions/$missionId/progress');
    return MissionProgressModel.fromJson(response.data!);
  }
}
