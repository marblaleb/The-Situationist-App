import 'package:freezed_annotation/freezed_annotation.dart';
part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class ProfileModel with _$ProfileModel {
  const factory ProfileModel({
    required String userId,
    required DateTime joinedAt,
    required SituationistFootprint situationistFootprint,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
}

@freezed
class SituationistFootprint with _$SituationistFootprint {
  const factory SituationistFootprint({
    required int eventsParticipated,
    required int derivasCompleted,
    required int missionsCompleted,
  }) = _SituationistFootprint;

  factory SituationistFootprint.fromJson(Map<String, dynamic> json) =>
      _$SituationistFootprintFromJson(json);
}

@freezed
class ActivityLogItem with _$ActivityLogItem {
  const factory ActivityLogItem({
    required String id,
    required String type,
    required String referenceId,
    required DateTime occurredAt,
  }) = _ActivityLogItem;

  factory ActivityLogItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogItemFromJson(json);
}

@freezed
class ActivityLogPage with _$ActivityLogPage {
  const factory ActivityLogPage({
    required List<ActivityLogItem> items,
    String? nextCursor,
  }) = _ActivityLogPage;

  factory ActivityLogPage.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogPageFromJson(json);
}
