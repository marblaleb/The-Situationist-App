// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deriva_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DerivaSessionModelImpl _$$DerivaSessionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DerivaSessionModelImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      status: json['status'] as String,
      firstInstruction: json['firstInstruction'] as String,
    );

Map<String, dynamic> _$$DerivaSessionModelImplToJson(
        _$DerivaSessionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'startedAt': instance.startedAt.toIso8601String(),
      'status': instance.status,
      'firstInstruction': instance.firstInstruction,
    };

_$DerivaInstructionModelImpl _$$DerivaInstructionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DerivaInstructionModelImpl(
      instructionId: json['instructionId'] as String,
      content: json['content'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$DerivaInstructionModelImplToJson(
        _$DerivaInstructionModelImpl instance) =>
    <String, dynamic>{
      'instructionId': instance.instructionId,
      'content': instance.content,
      'generatedAt': instance.generatedAt.toIso8601String(),
    };
