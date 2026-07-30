import '../../../core/network/api_client.dart';
import '../../../shared/models/georandom_point_model.dart';
import 'i_georandom_repository.dart';

class GeoRandomRepository implements IGeoRandomRepository {
  final ApiClient _client;

  GeoRandomRepository(this._client);

  @override
  Future<GeoRandomPointModel> generate({
    required double lat,
    required double lng,
    required int radiusMeters,
    required String type,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/georandom/generate',
      data: {
        'latitude': lat,
        'longitude': lng,
        'radiusMeters': radiusMeters,
        'type': type,
      },
    );
    return GeoRandomPointModel.fromJson(response.data!);
  }
}
