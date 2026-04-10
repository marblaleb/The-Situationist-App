// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clue_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClueModel _$ClueModelFromJson(Map<String, dynamic> json) {
  return _ClueModel.fromJson(json);
}

/// @nodoc
mixin _$ClueModel {
  String get id => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  bool get hasHint => throw _privateConstructorUsedError;
  bool get isOptional => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;

  /// Serializes this ClueModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClueModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClueModelCopyWith<ClueModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClueModelCopyWith<$Res> {
  factory $ClueModelCopyWith(ClueModel value, $Res Function(ClueModel) then) =
      _$ClueModelCopyWithImpl<$Res, ClueModel>;
  @useResult
  $Res call(
      {String id,
      int order,
      String type,
      String content,
      bool hasHint,
      bool isOptional,
      double? latitude,
      double? longitude});
}

/// @nodoc
class _$ClueModelCopyWithImpl<$Res, $Val extends ClueModel>
    implements $ClueModelCopyWith<$Res> {
  _$ClueModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClueModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? order = null,
    Object? type = null,
    Object? content = null,
    Object? hasHint = null,
    Object? isOptional = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      hasHint: null == hasHint
          ? _value.hasHint
          : hasHint // ignore: cast_nullable_to_non_nullable
              as bool,
      isOptional: null == isOptional
          ? _value.isOptional
          : isOptional // ignore: cast_nullable_to_non_nullable
              as bool,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClueModelImplCopyWith<$Res>
    implements $ClueModelCopyWith<$Res> {
  factory _$$ClueModelImplCopyWith(
          _$ClueModelImpl value, $Res Function(_$ClueModelImpl) then) =
      __$$ClueModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int order,
      String type,
      String content,
      bool hasHint,
      bool isOptional,
      double? latitude,
      double? longitude});
}

/// @nodoc
class __$$ClueModelImplCopyWithImpl<$Res>
    extends _$ClueModelCopyWithImpl<$Res, _$ClueModelImpl>
    implements _$$ClueModelImplCopyWith<$Res> {
  __$$ClueModelImplCopyWithImpl(
      _$ClueModelImpl _value, $Res Function(_$ClueModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClueModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? order = null,
    Object? type = null,
    Object? content = null,
    Object? hasHint = null,
    Object? isOptional = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_$ClueModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      hasHint: null == hasHint
          ? _value.hasHint
          : hasHint // ignore: cast_nullable_to_non_nullable
              as bool,
      isOptional: null == isOptional
          ? _value.isOptional
          : isOptional // ignore: cast_nullable_to_non_nullable
              as bool,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClueModelImpl implements _ClueModel {
  const _$ClueModelImpl(
      {required this.id,
      required this.order,
      required this.type,
      required this.content,
      required this.hasHint,
      required this.isOptional,
      this.latitude,
      this.longitude});

  factory _$ClueModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClueModelImplFromJson(json);

  @override
  final String id;
  @override
  final int order;
  @override
  final String type;
  @override
  final String content;
  @override
  final bool hasHint;
  @override
  final bool isOptional;
  @override
  final double? latitude;
  @override
  final double? longitude;

  @override
  String toString() {
    return 'ClueModel(id: $id, order: $order, type: $type, content: $content, hasHint: $hasHint, isOptional: $isOptional, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClueModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.hasHint, hasHint) || other.hasHint == hasHint) &&
            (identical(other.isOptional, isOptional) ||
                other.isOptional == isOptional) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, order, type, content,
      hasHint, isOptional, latitude, longitude);

  /// Create a copy of ClueModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClueModelImplCopyWith<_$ClueModelImpl> get copyWith =>
      __$$ClueModelImplCopyWithImpl<_$ClueModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClueModelImplToJson(
      this,
    );
  }
}

abstract class _ClueModel implements ClueModel {
  const factory _ClueModel(
      {required final String id,
      required final int order,
      required final String type,
      required final String content,
      required final bool hasHint,
      required final bool isOptional,
      final double? latitude,
      final double? longitude}) = _$ClueModelImpl;

  factory _ClueModel.fromJson(Map<String, dynamic> json) =
      _$ClueModelImpl.fromJson;

  @override
  String get id;
  @override
  int get order;
  @override
  String get type;
  @override
  String get content;
  @override
  bool get hasHint;
  @override
  bool get isOptional;
  @override
  double? get latitude;
  @override
  double? get longitude;

  /// Create a copy of ClueModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClueModelImplCopyWith<_$ClueModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
