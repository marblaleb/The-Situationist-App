// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventModelImpl _$$EventModelImplFromJson(Map<String, dynamic> json) =>
    _$EventModelImpl(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      actionType: json['actionType'] as String,
      interventionLevel: json['interventionLevel'] as String,
      centroidLatitude: (json['centroidLatitude'] as num).toDouble(),
      centroidLongitude: (json['centroidLongitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num).toInt(),
      visibility: json['visibility'] as String,
      maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
      startsAt: DateTime.parse(json['startsAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: json['status'] as String,
      participantCount: (json['participantCount'] as num).toInt(),
    );

Map<String, dynamic> _$$EventModelImplToJson(_$EventModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creatorId': instance.creatorId,
      'title': instance.title,
      'description': instance.description,
      'actionType': instance.actionType,
      'interventionLevel': instance.interventionLevel,
      'centroidLatitude': instance.centroidLatitude,
      'centroidLongitude': instance.centroidLongitude,
      'radiusMeters': instance.radiusMeters,
      'visibility': instance.visibility,
      'maxParticipants': instance.maxParticipants,
      'startsAt': instance.startsAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'status': instance.status,
      'participantCount': instance.participantCount,
    };

_$CreateEventRequestImpl _$$CreateEventRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateEventRequestImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      actionType: json['actionType'] as String,
      interventionLevel: json['interventionLevel'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num).toInt(),
      visibility: json['visibility'] as String,
      maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
      startsAt: DateTime.parse(json['startsAt'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$$CreateEventRequestImplToJson(
        _$CreateEventRequestImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'actionType': instance.actionType,
      'interventionLevel': instance.interventionLevel,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radiusMeters': instance.radiusMeters,
      'visibility': instance.visibility,
      'maxParticipants': instance.maxParticipants,
      'startsAt': instance.startsAt.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
    };

_$GenerateEventRequestImpl _$$GenerateEventRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$GenerateEventRequestImpl(
      actionType: json['actionType'] as String,
      interventionLevel: json['interventionLevel'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$GenerateEventRequestImplToJson(
        _$GenerateEventRequestImpl instance) =>
    <String, dynamic>{
      'actionType': instance.actionType,
      'interventionLevel': instance.interventionLevel,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_$GeneratedEventSuggestionImpl _$$GeneratedEventSuggestionImplFromJson(
        Map<String, dynamic> json) =>
    _$GeneratedEventSuggestionImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      actionType: json['actionType'] as String,
      interventionLevel: json['interventionLevel'] as String,
    );

Map<String, dynamic> _$$GeneratedEventSuggestionImplToJson(
        _$GeneratedEventSuggestionImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'actionType': instance.actionType,
      'interventionLevel': instance.interventionLevel,
    };
