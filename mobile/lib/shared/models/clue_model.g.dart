// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clue_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClueModelImpl _$$ClueModelImplFromJson(Map<String, dynamic> json) =>
    _$ClueModelImpl(
      id: json['id'] as String,
      order: (json['order'] as num).toInt(),
      type: json['type'] as String,
      content: json['content'] as String,
      hasHint: json['hasHint'] as bool,
      isOptional: json['isOptional'] as bool,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$ClueModelImplToJson(_$ClueModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order': instance.order,
      'type': instance.type,
      'content': instance.content,
      'hasHint': instance.hasHint,
      'isOptional': instance.isOptional,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
