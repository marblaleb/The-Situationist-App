// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MissionModel _$MissionModelFromJson(Map<String, dynamic> json) {
  return _MissionModel.fromJson(json);
}

/// @nodoc
mixin _$MissionModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  int get radiusMeters => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get clueCount => throw _privateConstructorUsedError;

  /// Serializes this MissionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MissionModelCopyWith<MissionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MissionModelCopyWith<$Res> {
  factory $MissionModelCopyWith(
          MissionModel value, $Res Function(MissionModel) then) =
      _$MissionModelCopyWithImpl<$Res, MissionModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      double latitude,
      double longitude,
      int radiusMeters,
      String status,
      int clueCount});
}

/// @nodoc
class _$MissionModelCopyWithImpl<$Res, $Val extends MissionModel>
    implements $MissionModelCopyWith<$Res> {
  _$MissionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? radiusMeters = null,
    Object? status = null,
    Object? clueCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      radiusMeters: null == radiusMeters
          ? _value.radiusMeters
          : radiusMeters // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      clueCount: null == clueCount
          ? _value.clueCount
          : clueCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MissionModelImplCopyWith<$Res>
    implements $MissionModelCopyWith<$Res> {
  factory _$$MissionModelImplCopyWith(
          _$MissionModelImpl value, $Res Function(_$MissionModelImpl) then) =
      __$$MissionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      double latitude,
      double longitude,
      int radiusMeters,
      String status,
      int clueCount});
}

/// @nodoc
class __$$MissionModelImplCopyWithImpl<$Res>
    extends _$MissionModelCopyWithImpl<$Res, _$MissionModelImpl>
    implements _$$MissionModelImplCopyWith<$Res> {
  __$$MissionModelImplCopyWithImpl(
      _$MissionModelImpl _value, $Res Function(_$MissionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? radiusMeters = null,
    Object? status = null,
    Object? clueCount = null,
  }) {
    return _then(_$MissionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      radiusMeters: null == radiusMeters
          ? _value.radiusMeters
          : radiusMeters // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      clueCount: null == clueCount
          ? _value.clueCount
          : clueCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MissionModelImpl implements _MissionModel {
  const _$MissionModelImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.latitude,
      required this.longitude,
      required this.radiusMeters,
      required this.status,
      required this.clueCount});

  factory _$MissionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MissionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final int radiusMeters;
  @override
  final String status;
  @override
  final int clueCount;

  @override
  String toString() {
    return 'MissionModel(id: $id, title: $title, description: $description, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, status: $status, clueCount: $clueCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MissionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.radiusMeters, radiusMeters) ||
                other.radiusMeters == radiusMeters) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.clueCount, clueCount) ||
                other.clueCount == clueCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, latitude,
      longitude, radiusMeters, status, clueCount);

  /// Create a copy of MissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MissionModelImplCopyWith<_$MissionModelImpl> get copyWith =>
      __$$MissionModelImplCopyWithImpl<_$MissionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MissionModelImplToJson(
      this,
    );
  }
}

abstract class _MissionModel implements MissionModel {
  const factory _MissionModel(
      {required final String id,
      required final String title,
      required final String description,
      required final double latitude,
      required final double longitude,
      required final int radiusMeters,
      required final String status,
      required final int clueCount}) = _$MissionModelImpl;

  factory _MissionModel.fromJson(Map<String, dynamic> json) =
      _$MissionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  int get radiusMeters;
  @override
  String get status;
  @override
  int get clueCount;

  /// Create a copy of MissionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MissionModelImplCopyWith<_$MissionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MissionDetailModel _$MissionDetailModelFromJson(Map<String, dynamic> json) {
  return _MissionDetailModel.fromJson(json);
}

/// @nodoc
mixin _$MissionDetailModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  int get radiusMeters => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<ClueModel> get clues => throw _privateConstructorUsedError;

  /// Serializes this MissionDetailModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MissionDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MissionDetailModelCopyWith<MissionDetailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MissionDetailModelCopyWith<$Res> {
  factory $MissionDetailModelCopyWith(
          MissionDetailModel value, $Res Function(MissionDetailModel) then) =
      _$MissionDetailModelCopyWithImpl<$Res, MissionDetailModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      double latitude,
      double longitude,
      int radiusMeters,
      String status,
      List<ClueModel> clues});
}

/// @nodoc
class _$MissionDetailModelCopyWithImpl<$Res, $Val extends MissionDetailModel>
    implements $MissionDetailModelCopyWith<$Res> {
  _$MissionDetailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MissionDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? radiusMeters = null,
    Object? status = null,
    Object? clues = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      radiusMeters: null == radiusMeters
          ? _value.radiusMeters
          : radiusMeters // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      clues: null == clues
          ? _value.clues
          : clues // ignore: cast_nullable_to_non_nullable
              as List<ClueModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MissionDetailModelImplCopyWith<$Res>
    implements $MissionDetailModelCopyWith<$Res> {
  factory _$$MissionDetailModelImplCopyWith(_$MissionDetailModelImpl value,
          $Res Function(_$MissionDetailModelImpl) then) =
      __$$MissionDetailModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      double latitude,
      double longitude,
      int radiusMeters,
      String status,
      List<ClueModel> clues});
}

/// @nodoc
class __$$MissionDetailModelImplCopyWithImpl<$Res>
    extends _$MissionDetailModelCopyWithImpl<$Res, _$MissionDetailModelImpl>
    implements _$$MissionDetailModelImplCopyWith<$Res> {
  __$$MissionDetailModelImplCopyWithImpl(_$MissionDetailModelImpl _value,
      $Res Function(_$MissionDetailModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MissionDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? radiusMeters = null,
    Object? status = null,
    Object? clues = null,
  }) {
    return _then(_$MissionDetailModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      radiusMeters: null == radiusMeters
          ? _value.radiusMeters
          : radiusMeters // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      clues: null == clues
          ? _value._clues
          : clues // ignore: cast_nullable_to_non_nullable
              as List<ClueModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MissionDetailModelImpl implements _MissionDetailModel {
  const _$MissionDetailModelImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.latitude,
      required this.longitude,
      required this.radiusMeters,
      required this.status,
      required final List<ClueModel> clues})
      : _clues = clues;

  factory _$MissionDetailModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MissionDetailModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final int radiusMeters;
  @override
  final String status;
  final List<ClueModel> _clues;
  @override
  List<ClueModel> get clues {
    if (_clues is EqualUnmodifiableListView) return _clues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_clues);
  }

  @override
  String toString() {
    return 'MissionDetailModel(id: $id, title: $title, description: $description, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, status: $status, clues: $clues)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MissionDetailModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.radiusMeters, radiusMeters) ||
                other.radiusMeters == radiusMeters) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._clues, _clues));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      latitude,
      longitude,
      radiusMeters,
      status,
      const DeepCollectionEquality().hash(_clues));

  /// Create a copy of MissionDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MissionDetailModelImplCopyWith<_$MissionDetailModelImpl> get copyWith =>
      __$$MissionDetailModelImplCopyWithImpl<_$MissionDetailModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MissionDetailModelImplToJson(
      this,
    );
  }
}

abstract class _MissionDetailModel implements MissionDetailModel {
  const factory _MissionDetailModel(
      {required final String id,
      required final String title,
      required final String description,
      required final double latitude,
      required final double longitude,
      required final int radiusMeters,
      required final String status,
      required final List<ClueModel> clues}) = _$MissionDetailModelImpl;

  factory _MissionDetailModel.fromJson(Map<String, dynamic> json) =
      _$MissionDetailModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  int get radiusMeters;
  @override
  String get status;
  @override
  List<ClueModel> get clues;

  /// Create a copy of MissionDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MissionDetailModelImplCopyWith<_$MissionDetailModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubmitAnswerResponse _$SubmitAnswerResponseFromJson(Map<String, dynamic> json) {
  return _SubmitAnswerResponse.fromJson(json);
}

/// @nodoc
mixin _$SubmitAnswerResponse {
  bool get correct => throw _privateConstructorUsedError;
  bool get missionCompleted => throw _privateConstructorUsedError;
  ClueModel? get nextClue => throw _privateConstructorUsedError;

  /// Serializes this SubmitAnswerResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubmitAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmitAnswerResponseCopyWith<SubmitAnswerResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmitAnswerResponseCopyWith<$Res> {
  factory $SubmitAnswerResponseCopyWith(SubmitAnswerResponse value,
          $Res Function(SubmitAnswerResponse) then) =
      _$SubmitAnswerResponseCopyWithImpl<$Res, SubmitAnswerResponse>;
  @useResult
  $Res call({bool correct, bool missionCompleted, ClueModel? nextClue});

  $ClueModelCopyWith<$Res>? get nextClue;
}

/// @nodoc
class _$SubmitAnswerResponseCopyWithImpl<$Res,
        $Val extends SubmitAnswerResponse>
    implements $SubmitAnswerResponseCopyWith<$Res> {
  _$SubmitAnswerResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubmitAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? correct = null,
    Object? missionCompleted = null,
    Object? nextClue = freezed,
  }) {
    return _then(_value.copyWith(
      correct: null == correct
          ? _value.correct
          : correct // ignore: cast_nullable_to_non_nullable
              as bool,
      missionCompleted: null == missionCompleted
          ? _value.missionCompleted
          : missionCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      nextClue: freezed == nextClue
          ? _value.nextClue
          : nextClue // ignore: cast_nullable_to_non_nullable
              as ClueModel?,
    ) as $Val);
  }

  /// Create a copy of SubmitAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClueModelCopyWith<$Res>? get nextClue {
    if (_value.nextClue == null) {
      return null;
    }

    return $ClueModelCopyWith<$Res>(_value.nextClue!, (value) {
      return _then(_value.copyWith(nextClue: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SubmitAnswerResponseImplCopyWith<$Res>
    implements $SubmitAnswerResponseCopyWith<$Res> {
  factory _$$SubmitAnswerResponseImplCopyWith(_$SubmitAnswerResponseImpl value,
          $Res Function(_$SubmitAnswerResponseImpl) then) =
      __$$SubmitAnswerResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool correct, bool missionCompleted, ClueModel? nextClue});

  @override
  $ClueModelCopyWith<$Res>? get nextClue;
}

/// @nodoc
class __$$SubmitAnswerResponseImplCopyWithImpl<$Res>
    extends _$SubmitAnswerResponseCopyWithImpl<$Res, _$SubmitAnswerResponseImpl>
    implements _$$SubmitAnswerResponseImplCopyWith<$Res> {
  __$$SubmitAnswerResponseImplCopyWithImpl(_$SubmitAnswerResponseImpl _value,
      $Res Function(_$SubmitAnswerResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubmitAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? correct = null,
    Object? missionCompleted = null,
    Object? nextClue = freezed,
  }) {
    return _then(_$SubmitAnswerResponseImpl(
      correct: null == correct
          ? _value.correct
          : correct // ignore: cast_nullable_to_non_nullable
              as bool,
      missionCompleted: null == missionCompleted
          ? _value.missionCompleted
          : missionCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      nextClue: freezed == nextClue
          ? _value.nextClue
          : nextClue // ignore: cast_nullable_to_non_nullable
              as ClueModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmitAnswerResponseImpl implements _SubmitAnswerResponse {
  const _$SubmitAnswerResponseImpl(
      {required this.correct, required this.missionCompleted, this.nextClue});

  factory _$SubmitAnswerResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubmitAnswerResponseImplFromJson(json);

  @override
  final bool correct;
  @override
  final bool missionCompleted;
  @override
  final ClueModel? nextClue;

  @override
  String toString() {
    return 'SubmitAnswerResponse(correct: $correct, missionCompleted: $missionCompleted, nextClue: $nextClue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitAnswerResponseImpl &&
            (identical(other.correct, correct) || other.correct == correct) &&
            (identical(other.missionCompleted, missionCompleted) ||
                other.missionCompleted == missionCompleted) &&
            (identical(other.nextClue, nextClue) ||
                other.nextClue == nextClue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, correct, missionCompleted, nextClue);

  /// Create a copy of SubmitAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitAnswerResponseImplCopyWith<_$SubmitAnswerResponseImpl>
      get copyWith =>
          __$$SubmitAnswerResponseImplCopyWithImpl<_$SubmitAnswerResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmitAnswerResponseImplToJson(
      this,
    );
  }
}

abstract class _SubmitAnswerResponse implements SubmitAnswerResponse {
  const factory _SubmitAnswerResponse(
      {required final bool correct,
      required final bool missionCompleted,
      final ClueModel? nextClue}) = _$SubmitAnswerResponseImpl;

  factory _SubmitAnswerResponse.fromJson(Map<String, dynamic> json) =
      _$SubmitAnswerResponseImpl.fromJson;

  @override
  bool get correct;
  @override
  bool get missionCompleted;
  @override
  ClueModel? get nextClue;

  /// Create a copy of SubmitAnswerResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmitAnswerResponseImplCopyWith<_$SubmitAnswerResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
