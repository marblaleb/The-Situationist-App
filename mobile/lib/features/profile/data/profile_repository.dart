import '../../../core/network/api_client.dart';
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
}
