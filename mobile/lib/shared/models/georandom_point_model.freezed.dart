// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'georandom_point_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GeoRandomPointModel {
  double get lat;
  double get lng;
  String get type;
  DateTime get generatedAt;

  /// Create a copy of GeoRandomPointModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GeoRandomPointModelCopyWith<GeoRandomPointModel> get copyWith =>
      _$GeoRandomPointModelCopyWithImpl<GeoRandomPointModel>(
          this as GeoRandomPointModel, _$identity);

  /// Serializes this GeoRandomPointModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GeoRandomPointModel &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lng, type, generatedAt);

  @override
  String toString() {
    return 'GeoRandomPointModel(lat: $lat, lng: $lng, type: $type, generatedAt: $generatedAt)';
  }
}

/// @nodoc
abstract mixin class $GeoRandomPointModelCopyWith<$Res> {
  factory $GeoRandomPointModelCopyWith(
          GeoRandomPointModel value, $Res Function(GeoRandomPointModel) _then) =
      _$GeoRandomPointModelCopyWithImpl;
  @useResult
  $Res call({double lat, double lng, String type, DateTime generatedAt});
}

/// @nodoc
class _$GeoRandomPointModelCopyWithImpl<$Res>
    implements $GeoRandomPointModelCopyWith<$Res> {
  _$GeoRandomPointModelCopyWithImpl(this._self, this._then);

  final GeoRandomPointModel _self;
  final $Res Function(GeoRandomPointModel) _then;

  /// Create a copy of GeoRandomPointModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lng = null,
    Object? type = null,
    Object? generatedAt = null,
  }) {
    return _then(_self.copyWith(
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      generatedAt: null == generatedAt
          ? _self.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [GeoRandomPointModel].
extension GeoRandomPointModelPatterns on GeoRandomPointModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_GeoRandomPointModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GeoRandomPointModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_GeoRandomPointModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeoRandomPointModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_GeoRandomPointModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeoRandomPointModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(double lat, double lng, String type, DateTime generatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GeoRandomPointModel() when $default != null:
        return $default(_that.lat, _that.lng, _that.type, _that.generatedAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(double lat, double lng, String type, DateTime generatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeoRandomPointModel():
        return $default(_that.lat, _that.lng, _that.type, _that.generatedAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            double lat, double lng, String type, DateTime generatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeoRandomPointModel() when $default != null:
        return $default(_that.lat, _that.lng, _that.type, _that.generatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GeoRandomPointModel implements GeoRandomPointModel {
  const _GeoRandomPointModel(
      {required this.lat,
      required this.lng,
      required this.type,
      required this.generatedAt});
  factory _GeoRandomPointModel.fromJson(Map<String, dynamic> json) =>
      _$GeoRandomPointModelFromJson(json);

  @override
  final double lat;
  @override
  final double lng;
  @override
  final String type;
  @override
  final DateTime generatedAt;

  /// Create a copy of GeoRandomPointModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GeoRandomPointModelCopyWith<_GeoRandomPointModel> get copyWith =>
      __$GeoRandomPointModelCopyWithImpl<_GeoRandomPointModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GeoRandomPointModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GeoRandomPointModel &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lng, type, generatedAt);

  @override
  String toString() {
    return 'GeoRandomPointModel(lat: $lat, lng: $lng, type: $type, generatedAt: $generatedAt)';
  }
}

/// @nodoc
abstract mixin class _$GeoRandomPointModelCopyWith<$Res>
    implements $GeoRandomPointModelCopyWith<$Res> {
  factory _$GeoRandomPointModelCopyWith(_GeoRandomPointModel value,
          $Res Function(_GeoRandomPointModel) _then) =
      __$GeoRandomPointModelCopyWithImpl;
  @override
  @useResult
  $Res call({double lat, double lng, String type, DateTime generatedAt});
}

/// @nodoc
class __$GeoRandomPointModelCopyWithImpl<$Res>
    implements _$GeoRandomPointModelCopyWith<$Res> {
  __$GeoRandomPointModelCopyWithImpl(this._self, this._then);

  final _GeoRandomPointModel _self;
  final $Res Function(_GeoRandomPointModel) _then;

  /// Create a copy of GeoRandomPointModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? lat = null,
    Object? lng = null,
    Object? type = null,
    Object? generatedAt = null,
  }) {
    return _then(_GeoRandomPointModel(
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      generatedAt: null == generatedAt
          ? _self.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
