// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileModelImpl _$$ProfileModelImplFromJson(Map<String, dynamic> json) =>
    _$ProfileModelImpl(
      userId: json['userId'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      situationistFootprint: SituationistFootprint.fromJson(
          json['situationistFootprint'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProfileModelImplToJson(_$ProfileModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'situationistFootprint': instance.situationistFootprint,
    };

_$SituationistFootprintImpl _$$SituationistFootprintImplFromJson(
        Map<String, dynamic> json) =>
    _$SituationistFootprintImpl(
      eventsParticipated: (json['eventsParticipated'] as num).toInt(),
      derivasCompleted: (json['derivasCompleted'] as num).toInt(),
      missionsCompleted: (json['missionsCompleted'] as num).toInt(),
    );

Map<String, dynamic> _$$SituationistFootprintImplToJson(
        _$SituationistFootprintImpl instance) =>
    <String, dynamic>{
      'eventsParticipated': instance.eventsParticipated,
      'derivasCompleted': instance.derivasCompleted,
      'missionsCompleted': instance.missionsCompleted,
    };

_$ActivityLogItemImpl _$$ActivityLogItemImplFromJson(
        Map<String, dynamic> json) =>
    _$ActivityLogItemImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      referenceId: json['referenceId'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
    );

Map<String, dynamic> _$$ActivityLogItemImplToJson(
        _$ActivityLogItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'referenceId': instance.referenceId,
      'occurredAt': instance.occurredAt.toIso8601String(),
    };

_$ActivityLogPageImpl _$$ActivityLogPageImplFromJson(
        Map<String, dynamic> json) =>
    _$ActivityLogPageImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => ActivityLogItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$$ActivityLogPageImplToJson(
        _$ActivityLogPageImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextCursor': instance.nextCursor,
    };
