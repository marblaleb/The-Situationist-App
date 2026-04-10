import 'package:freezed_annotation/freezed_annotation.dart';
part 'clue_model.freezed.dart';
part 'clue_model.g.dart';

@freezed
class ClueModel with _$ClueModel {
  const factory ClueModel({
    required String id,
    required int order,
    required String type,
    required String content,
    required bool hasHint,
    required bool isOptional,
    double? latitude,
    double? longitude,
  }) = _ClueModel;

  factory ClueModel.fromJson(Map<String, dynamic> json) =>
      _$ClueModelFromJson(json);
}
