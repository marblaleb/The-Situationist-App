import '../../../shared/models/mission_model.dart';
import '../../../shared/models/mission_progress_model.dart';
import '../bloc/create_mission_bloc.dart';

abstract class IMissionsRepository {
  Future<List<MissionModel>> getNearbyMissions({
    required double lat,
    required double lng,
    required int radius,
  });

  Future<MissionDetailModel> getMissionDetail(String missionId);

  Future<MissionProgressModel> startMission(String missionId);

  Future<SubmitAnswerResponse> submitAnswer({
    required String missionId,
    required String clueId,
    required String answer,
  });

  Future<String> requestHint({
    required String missionId,
    required String clueId,
  });

  Future<MissionProgressModel> getMissionProgress(String missionId);

  Future<MissionModel> createMission({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required List<ClueFormData> clues,
  });
}
