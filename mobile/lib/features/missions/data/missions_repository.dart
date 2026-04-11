import '../../../core/network/api_client.dart';
import '../../../shared/models/mission_model.dart';
import '../../../shared/models/mission_progress_model.dart';
import '../bloc/create_mission_bloc.dart';
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

  @override
  Future<MissionModel> createMission({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required List<ClueFormData> clues,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/missions',
      data: {
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'radiusMeters': radiusMeters,
        'clues': clues.asMap().entries.map((e) => {
          'order': e.key + 1,
          'type': e.value.type,
          'content': e.value.content,
          'answer': e.value.answer,
          'hint': e.value.hint.isNotEmpty ? e.value.hint : null,
          'isOptional': e.value.isOptional,
          'latitude': null,
          'longitude': null,
        }).toList(),
      },
    );
    return MissionModel.fromJson(response.data!);
  }
}
