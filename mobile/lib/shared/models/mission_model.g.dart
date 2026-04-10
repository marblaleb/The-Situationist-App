// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MissionModelImpl _$$MissionModelImplFromJson(Map<String, dynamic> json) =>
    _$MissionModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num).toInt(),
      status: json['status'] as String,
      clueCount: (json['clueCount'] as num).toInt(),
    );

Map<String, dynamic> _$$MissionModelImplToJson(_$MissionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radiusMeters': instance.radiusMeters,
      'status': instance.status,
      'clueCount': instance.clueCount,
    };

_$MissionDetailModelImpl _$$MissionDetailModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MissionDetailModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num).toInt(),
      status: json['status'] as String,
      clues: (json['clues'] as List<dynamic>)
          .map((e) => ClueModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MissionDetailModelImplToJson(
        _$MissionDetailModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radiusMeters': instance.radiusMeters,
      'status': instance.status,
      'clues': instance.clues,
    };

_$SubmitAnswerResponseImpl _$$SubmitAnswerResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$SubmitAnswerResponseImpl(
      correct: json['correct'] as bool,
      missionCompleted: json['missionCompleted'] as bool,
      nextClue: json['nextClue'] == null
          ? null
          : ClueModel.fromJson(json['nextClue'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SubmitAnswerResponseImplToJson(
        _$SubmitAnswerResponseImpl instance) =>
    <String, dynamic>{
      'correct': instance.correct,
      'missionCompleted': instance.missionCompleted,
      'nextClue': instance.nextClue,
    };
