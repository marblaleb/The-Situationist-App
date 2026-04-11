import '../../../core/network/api_client.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/models/mission_model.dart';
import '../../../shared/models/profile_model.dart';
import 'i_profile_repository.dart';

class ProfileRepository implements IProfileRepository {
  final ApiClient _client;

  ProfileRepository(this._client);

  @override
  Future<ProfileModel> getProfile() async {
    final response =
        await _client.get<Map<String, dynamic>>('/profile/me');
    return ProfileModel.fromJson(response.data!);
  }

  @override
  Future<ActivityLogPage> getActivityLog({
    String? cursor,
    int pageSize = 20,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/profile/me/activity',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'pageSize': pageSize,
      },
    );
    return ActivityLogPage.fromJson(response.data!);
  }

  @override
  Future<List<EventModel>> getCreatedEvents() async {
    final response = await _client.get<List<dynamic>>('/profile/me/events');
    return (response.data as List)
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MissionModel>> getCreatedMissions() async {
    final response = await _client.get<List<dynamic>>('/profile/me/missions');
    return (response.data as List)
        .map((e) => MissionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
