// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deriva_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DerivaSessionModel _$DerivaSessionModelFromJson(Map<String, dynamic> json) {
  return _DerivaSessionModel.fromJson(json);
}

/// @nodoc
mixin _$DerivaSessionModel {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get firstInstruction => throw _privateConstructorUsedError;

  /// Serializes this DerivaSessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DerivaSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DerivaSessionModelCopyWith<DerivaSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DerivaSessionModelCopyWith<$Res> {
  factory $DerivaSessionModelCopyWith(
          DerivaSessionModel value, $Res Function(DerivaSessionModel) then) =
      _$DerivaSessionModelCopyWithImpl<$Res, DerivaSessionModel>;
  @useResult
  $Res call(
      {String id,
      String type,
      DateTime startedAt,
      String status,
      String firstInstruction});
}

/// @nodoc
class _$DerivaSessionModelCopyWithImpl<$Res, $Val extends DerivaSessionModel>
    implements $DerivaSessionModelCopyWith<$Res> {
  _$DerivaSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DerivaSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? startedAt = null,
    Object? status = null,
    Object? firstInstruction = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      firstInstruction: null == firstInstruction
          ? _value.firstInstruction
          : firstInstruction // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DerivaSessionModelImplCopyWith<$Res>
    implements $DerivaSessionModelCopyWith<$Res> {
  factory _$$DerivaSessionModelImplCopyWith(_$DerivaSessionModelImpl value,
          $Res Function(_$DerivaSessionModelImpl) then) =
      __$$DerivaSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      DateTime startedAt,
      String status,
      String firstInstruction});
}

/// @nodoc
class __$$DerivaSessionModelImplCopyWithImpl<$Res>
    extends _$DerivaSessionModelCopyWithImpl<$Res, _$DerivaSessionModelImpl>
    implements _$$DerivaSessionModelImplCopyWith<$Res> {
  __$$DerivaSessionModelImplCopyWithImpl(_$DerivaSessionModelImpl _value,
      $Res Function(_$DerivaSessionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DerivaSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? startedAt = null,
    Object? status = null,
    Object? firstInstruction = null,
  }) {
    return _then(_$DerivaSessionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      firstInstruction: null == firstInstruction
          ? _value.firstInstruction
          : firstInstruction // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DerivaSessionModelImpl implements _DerivaSessionModel {
  const _$DerivaSessionModelImpl(
      {required this.id,
      required this.type,
      required this.startedAt,
      required this.status,
      required this.firstInstruction});

  factory _$DerivaSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DerivaSessionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final DateTime startedAt;
  @override
  final String status;
  @override
  final String firstInstruction;

  @override
  String toString() {
    return 'DerivaSessionModel(id: $id, type: $type, startedAt: $startedAt, status: $status, firstInstruction: $firstInstruction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DerivaSessionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.firstInstruction, firstInstruction) ||
                other.firstInstruction == firstInstruction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, startedAt, status, firstInstruction);

  /// Create a copy of DerivaSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DerivaSessionModelImplCopyWith<_$DerivaSessionModelImpl> get copyWith =>
      __$$DerivaSessionModelImplCopyWithImpl<_$DerivaSessionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DerivaSessionModelImplToJson(
      this,
    );
  }
}

abstract class _DerivaSessionModel implements DerivaSessionModel {
  const factory _DerivaSessionModel(
      {required final String id,
      required final String type,
      required final DateTime startedAt,
      required final String status,
      required final String firstInstruction}) = _$DerivaSessionModelImpl;

  factory _DerivaSessionModel.fromJson(Map<String, dynamic> json) =
      _$DerivaSessionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  DateTime get startedAt;
  @override
  String get status;
  @override
  String get firstInstruction;

  /// Create a copy of DerivaSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DerivaSessionModelImplCopyWith<_$DerivaSessionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DerivaInstructionModel _$DerivaInstructionModelFromJson(
    Map<String, dynamic> json) {
  return _DerivaInstructionModel.fromJson(json);
}

/// @nodoc
mixin _$DerivaInstructionModel {
  String get instructionId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this DerivaInstructionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DerivaInstructionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DerivaInstructionModelCopyWith<DerivaInstructionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DerivaInstructionModelCopyWith<$Res> {
  factory $DerivaInstructionModelCopyWith(DerivaInstructionModel value,
          $Res Function(DerivaInstructionModel) then) =
      _$DerivaInstructionModelCopyWithImpl<$Res, DerivaInstructionModel>;
  @useResult
  $Res call({String instructionId, String content, DateTime generatedAt});
}

/// @nodoc
class _$DerivaInstructionModelCopyWithImpl<$Res,
        $Val extends DerivaInstructionModel>
    implements $DerivaInstructionModelCopyWith<$Res> {
  _$DerivaInstructionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DerivaInstructionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instructionId = null,
    Object? content = null,
    Object? generatedAt = null,
  }) {
    return _then(_value.copyWith(
      instructionId: null == instructionId
          ? _value.instructionId
          : instructionId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DerivaInstructionModelImplCopyWith<$Res>
    implements $DerivaInstructionModelCopyWith<$Res> {
  factory _$$DerivaInstructionModelImplCopyWith(
          _$DerivaInstructionModelImpl value,
          $Res Function(_$DerivaInstructionModelImpl) then) =
      __$$DerivaInstructionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String instructionId, String content, DateTime generatedAt});
}

/// @nodoc
class __$$DerivaInstructionModelImplCopyWithImpl<$Res>
    extends _$DerivaInstructionModelCopyWithImpl<$Res,
        _$DerivaInstructionModelImpl>
    implements _$$DerivaInstructionModelImplCopyWith<$Res> {
  __$$DerivaInstructionModelImplCopyWithImpl(
      _$DerivaInstructionModelImpl _value,
      $Res Function(_$DerivaInstructionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DerivaInstructionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instructionId = null,
    Object? content = null,
    Object? generatedAt = null,
  }) {
    return _then(_$DerivaInstructionModelImpl(
      instructionId: null == instructionId
          ? _value.instructionId
          : instructionId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DerivaInstructionModelImpl implements _DerivaInstructionModel {
  const _$DerivaInstructionModelImpl(
      {required this.instructionId,
      required this.content,
      required this.generatedAt});

  factory _$DerivaInstructionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DerivaInstructionModelImplFromJson(json);

  @override
  final String instructionId;
  @override
  final String content;
  @override
  final DateTime generatedAt;

  @override
  String toString() {
    return 'DerivaInstructionModel(instructionId: $instructionId, content: $content, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DerivaInstructionModelImpl &&
            (identical(other.instructionId, instructionId) ||
                other.instructionId == instructionId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, instructionId, content, generatedAt);

  /// Create a copy of DerivaInstructionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DerivaInstructionModelImplCopyWith<_$DerivaInstructionModelImpl>
      get copyWith => __$$DerivaInstructionModelImplCopyWithImpl<
          _$DerivaInstructionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DerivaInstructionModelImplToJson(
      this,
    );
  }
}

abstract class _DerivaInstructionModel implements DerivaInstructionModel {
  const factory _DerivaInstructionModel(
      {required final String instructionId,
      required final String content,
      required final DateTime generatedAt}) = _$DerivaInstructionModelImpl;

  factory _DerivaInstructionModel.fromJson(Map<String, dynamic> json) =
      _$DerivaInstructionModelImpl.fromJson;

  @override
  String get instructionId;
  @override
  String get content;
  @override
  DateTime get generatedAt;

  /// Create a copy of DerivaInstructionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DerivaInstructionModelImplCopyWith<_$DerivaInstructionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
