import 'package:freezed_annotation/freezed_annotation.dart';
import 'clue_model.dart';
part 'mission_progress_model.freezed.dart';
part 'mission_progress_model.g.dart';

@freezed
class MissionProgressModel with _$MissionProgressModel {
  const factory MissionProgressModel({
    required String progressId,
    required String missionId,
    required String status,
    required DateTime startedAt,
    DateTime? completedAt,
    required int hintsUsed,
    ClueModel? currentClue,
  }) = _MissionProgressModel;

  factory MissionProgressModel.fromJson(Map<String, dynamic> json) =>
      _$MissionProgressModelFromJson(json);
}
