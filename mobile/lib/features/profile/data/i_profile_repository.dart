import '../../../shared/models/event_model.dart';
import '../../../shared/models/mission_model.dart';
import '../../../shared/models/profile_model.dart';

abstract class IProfileRepository {
  Future<ProfileModel> getProfile();
  Future<ActivityLogPage> getActivityLog({String? cursor, int pageSize = 20});
  Future<List<EventModel>> getCreatedEvents();
  Future<List<MissionModel>> getCreatedMissions();
}
