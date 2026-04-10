import 'package:freezed_annotation/freezed_annotation.dart';
import 'clue_model.dart';
part 'mission_model.freezed.dart';
part 'mission_model.g.dart';

@freezed
class MissionModel with _$MissionModel {
  const factory MissionModel({
    required String id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required String status,
    required int clueCount,
  }) = _MissionModel;

  factory MissionModel.fromJson(Map<String, dynamic> json) =>
      _$MissionModelFromJson(json);
}

@freezed
class MissionDetailModel with _$MissionDetailModel {
  const factory MissionDetailModel({
    required String id,
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required String status,
    required List<ClueModel> clues,
  }) = _MissionDetailModel;

  factory MissionDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MissionDetailModelFromJson(json);
}

@freezed
class SubmitAnswerResponse with _$SubmitAnswerResponse {
  const factory SubmitAnswerResponse({
    required bool correct,
    required bool missionCompleted,
    ClueModel? nextClue,
  }) = _SubmitAnswerResponse;

  factory SubmitAnswerResponse.fromJson(Map<String, dynamic> json) =>
      _$SubmitAnswerResponseFromJson(json);
}
