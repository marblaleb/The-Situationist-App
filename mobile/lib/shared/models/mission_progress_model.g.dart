// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MissionProgressModelImpl _$$MissionProgressModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MissionProgressModelImpl(
      progressId: json['progressId'] as String,
      missionId: json['missionId'] as String,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      hintsUsed: (json['hintsUsed'] as num).toInt(),
      currentClue: json['currentClue'] == null
          ? null
          : ClueModel.fromJson(json['currentClue'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MissionProgressModelImplToJson(
        _$MissionProgressModelImpl instance) =>
    <String, dynamic>{
      'progressId': instance.progressId,
      'missionId': instance.missionId,
      'status': instance.status,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'hintsUsed': instance.hintsUsed,
      'currentClue': instance.currentClue,
    };
