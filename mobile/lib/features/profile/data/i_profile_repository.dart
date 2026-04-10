import '../../../shared/models/profile_model.dart';

abstract class IProfileRepository {
  Future<ProfileModel> getProfile();
  Future<ActivityLogPage> getActivityLog({String? cursor, int pageSize = 20});
}
