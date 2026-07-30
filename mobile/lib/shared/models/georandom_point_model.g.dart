// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'georandom_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GeoRandomPointModel _$GeoRandomPointModelFromJson(Map<String, dynamic> json) =>
    _GeoRandomPointModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      type: json['type'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$GeoRandomPointModelToJson(
        _GeoRandomPointModel instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'type': instance.type,
      'generatedAt': instance.generatedAt.toIso8601String(),
    };
