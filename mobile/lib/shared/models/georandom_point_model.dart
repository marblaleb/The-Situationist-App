import 'package:freezed_annotation/freezed_annotation.dart';
part 'georandom_point_model.freezed.dart';
part 'georandom_point_model.g.dart';

@freezed
abstract class GeoRandomPointModel with _$GeoRandomPointModel {
  const factory GeoRandomPointModel({
    required double lat,
    required double lng,
    required String type,
    required DateTime generatedAt,
  }) = _GeoRandomPointModel;

  factory GeoRandomPointModel.fromJson(Map<String, dynamic> json) =>
      _$GeoRandomPointModelFromJson(json);
}
