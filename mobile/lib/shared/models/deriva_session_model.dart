import 'package:freezed_annotation/freezed_annotation.dart';
part 'deriva_session_model.freezed.dart';
part 'deriva_session_model.g.dart';

@freezed
class DerivaSessionModel with _$DerivaSessionModel {
  const factory DerivaSessionModel({
    required String id,
    required String type,
    required DateTime startedAt,
    required String status,
    required String firstInstruction,
  }) = _DerivaSessionModel;

  factory DerivaSessionModel.fromJson(Map<String, dynamic> json) =>
      _$DerivaSessionModelFromJson(json);
}

@freezed
class DerivaInstructionModel with _$DerivaInstructionModel {
  const factory DerivaInstructionModel({
    required String instructionId,
    required String content,
    required DateTime generatedAt,
  }) = _DerivaInstructionModel;

  factory DerivaInstructionModel.fromJson(Map<String, dynamic> json) =>
      _$DerivaInstructionModelFromJson(json);
}
