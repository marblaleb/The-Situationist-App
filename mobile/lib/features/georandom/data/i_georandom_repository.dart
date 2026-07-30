import '../../../shared/models/georandom_point_model.dart';

abstract class IGeoRandomRepository {
  Future<GeoRandomPointModel> generate({
    required double lat,
    required double lng,
    required int radiusMeters,
    required String type,
  });
}
