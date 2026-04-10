// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_progress_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MissionProgressModel _$MissionProgressModelFromJson(Map<String, dynamic> json) {
  return _MissionProgressModel.fromJson(json);
}

/// @nodoc
mixin _$MissionProgressModel {
  String get progressId => throw _privateConstructorUsedError;
  String get missionId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int get hintsUsed => throw _privateConstructorUsedError;
  ClueModel? get currentClue => throw _privateConstructorUsedError;

  /// Serializes this MissionProgressModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MissionProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MissionProgressModelCopyWith<MissionProgressModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MissionProgressModelCopyWith<$Res> {
  factory $MissionProgressModelCopyWith(MissionProgressModel value,
          $Res Function(MissionProgressModel) then) =
      _$MissionProgressModelCopyWithImpl<$Res, MissionProgressModel>;
  @useResult
  $Res call(
      {String progressId,
      String missionId,
      String status,
      DateTime startedAt,
      DateTime? completedAt,
      int hintsUsed,
      ClueModel? currentClue});

  $ClueModelCopyWith<$Res>? get currentClue;
}

/// @nodoc
class _$MissionProgressModelCopyWithImpl<$Res,
        $Val extends MissionProgressModel>
    implements $MissionProgressModelCopyWith<$Res> {
  _$MissionProgressModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MissionProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? progressId = null,
    Object? missionId = null,
    Object? status = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? hintsUsed = null,
    Object? currentClue = freezed,
  }) {
    return _then(_value.copyWith(
      progressId: null == progressId
          ? _value.progressId
          : progressId // ignore: cast_nullable_to_non_nullable
              as String,
      missionId: null == missionId
          ? _value.missionId
          : missionId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hintsUsed: null == hintsUsed
          ? _value.hintsUsed
          : hintsUsed // ignore: cast_nullable_to_non_nullable
              as int,
      currentClue: freezed == currentClue
          ? _value.currentClue
          : currentClue // ignore: cast_nullable_to_non_nullable
              as ClueModel?,
    ) as $Val);
  }

  /// Create a copy of MissionProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClueModelCopyWith<$Res>? get currentClue {
    if (_value.currentClue == null) {
      return null;
    }

    return $ClueModelCopyWith<$Res>(_value.currentClue!, (value) {
      return _then(_value.copyWith(currentClue: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MissionProgressModelImplCopyWith<$Res>
    implements $MissionProgressModelCopyWith<$Res> {
  factory _$$MissionProgressModelImplCopyWith(_$MissionProgressModelImpl value,
          $Res Function(_$MissionProgressModelImpl) then) =
      __$$MissionProgressModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String progressId,
      String missionId,
      String status,
      DateTime startedAt,
      DateTime? completedAt,
      int hintsUsed,
      ClueModel? currentClue});

  @override
  $ClueModelCopyWith<$Res>? get currentClue;
}

/// @nodoc
class __$$MissionProgressModelImplCopyWithImpl<$Res>
    extends _$MissionProgressModelCopyWithImpl<$Res, _$MissionProgressModelImpl>
    implements _$$MissionProgressModelImplCopyWith<$Res> {
  __$$MissionProgressModelImplCopyWithImpl(_$MissionProgressModelImpl _value,
      $Res Function(_$MissionProgressModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MissionProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? progressId = null,
    Object? missionId = null,
    Object? status = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? hintsUsed = null,
    Object? currentClue = freezed,
  }) {
    return _then(_$MissionProgressModelImpl(
      progressId: null == progressId
          ? _value.progressId
          : progressId // ignore: cast_nullable_to_non_nullable
              as String,
      missionId: null == missionId
          ? _value.missionId
          : missionId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hintsUsed: null == hintsUsed
          ? _value.hintsUsed
          : hintsUsed // ignore: cast_nullable_to_non_nullable
              as int,
      currentClue: freezed == currentClue
          ? _value.currentClue
          : currentClue // ignore: cast_nullable_to_non_nullable
              as ClueModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MissionProgressModelImpl implements _MissionProgressModel {
  const _$MissionProgressModelImpl(
      {required this.progressId,
      required this.missionId,
      required this.status,
      required this.startedAt,
      this.completedAt,
      required this.hintsUsed,
      this.currentClue});

  factory _$MissionProgressModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MissionProgressModelImplFromJson(json);

  @override
  final String progressId;
  @override
  final String missionId;
  @override
  final String status;
  @override
  final DateTime startedAt;
  @override
  final DateTime? completedAt;
  @override
  final int hintsUsed;
  @override
  final ClueModel? currentClue;

  @override
  String toString() {
    return 'MissionProgressModel(progressId: $progressId, missionId: $missionId, status: $status, startedAt: $startedAt, completedAt: $completedAt, hintsUsed: $hintsUsed, currentClue: $currentClue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MissionProgressModelImpl &&
            (identical(other.progressId, progressId) ||
                other.progressId == progressId) &&
            (identical(other.missionId, missionId) ||
                other.missionId == missionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.hintsUsed, hintsUsed) ||
                other.hintsUsed == hintsUsed) &&
            (identical(other.currentClue, currentClue) ||
                other.currentClue == currentClue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, progressId, missionId, status,
      startedAt, completedAt, hintsUsed, currentClue);

  /// Create a copy of MissionProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MissionProgressModelImplCopyWith<_$MissionProgressModelImpl>
      get copyWith =>
          __$$MissionProgressModelImplCopyWithImpl<_$MissionProgressModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MissionProgressModelImplToJson(
      this,
    );
  }
}

abstract class _MissionProgressModel implements MissionProgressModel {
  const factory _MissionProgressModel(
      {required final String progressId,
      required final String missionId,
      required final String status,
      required final DateTime startedAt,
      final DateTime? completedAt,
      required final int hintsUsed,
      final ClueModel? currentClue}) = _$MissionProgressModelImpl;

  factory _MissionProgressModel.fromJson(Map<String, dynamic> json) =
      _$MissionProgressModelImpl.fromJson;

  @override
  String get progressId;
  @override
  String get missionId;
  @override
  String get status;
  @override
  DateTime get startedAt;
  @override
  DateTime? get completedAt;
  @override
  int get hintsUsed;
  @override
  ClueModel? get currentClue;

  /// Create a copy of MissionProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MissionProgressModelImplCopyWith<_$MissionProgressModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
