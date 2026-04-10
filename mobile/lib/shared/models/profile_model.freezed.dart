// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) {
  return _ProfileModel.fromJson(json);
}

/// @nodoc
mixin _$ProfileModel {
  String get userId => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  SituationistFootprint get situationistFootprint =>
      throw _privateConstructorUsedError;

  /// Serializes this ProfileModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileModelCopyWith<ProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileModelCopyWith<$Res> {
  factory $ProfileModelCopyWith(
          ProfileModel value, $Res Function(ProfileModel) then) =
      _$ProfileModelCopyWithImpl<$Res, ProfileModel>;
  @useResult
  $Res call(
      {String userId,
      DateTime joinedAt,
      SituationistFootprint situationistFootprint});

  $SituationistFootprintCopyWith<$Res> get situationistFootprint;
}

/// @nodoc
class _$ProfileModelCopyWithImpl<$Res, $Val extends ProfileModel>
    implements $ProfileModelCopyWith<$Res> {
  _$ProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? joinedAt = null,
    Object? situationistFootprint = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      situationistFootprint: null == situationistFootprint
          ? _value.situationistFootprint
          : situationistFootprint // ignore: cast_nullable_to_non_nullable
              as SituationistFootprint,
    ) as $Val);
  }

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SituationistFootprintCopyWith<$Res> get situationistFootprint {
    return $SituationistFootprintCopyWith<$Res>(_value.situationistFootprint,
        (value) {
      return _then(_value.copyWith(situationistFootprint: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileModelImplCopyWith<$Res>
    implements $ProfileModelCopyWith<$Res> {
  factory _$$ProfileModelImplCopyWith(
          _$ProfileModelImpl value, $Res Function(_$ProfileModelImpl) then) =
      __$$ProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      DateTime joinedAt,
      SituationistFootprint situationistFootprint});

  @override
  $SituationistFootprintCopyWith<$Res> get situationistFootprint;
}

/// @nodoc
class __$$ProfileModelImplCopyWithImpl<$Res>
    extends _$ProfileModelCopyWithImpl<$Res, _$ProfileModelImpl>
    implements _$$ProfileModelImplCopyWith<$Res> {
  __$$ProfileModelImplCopyWithImpl(
      _$ProfileModelImpl _value, $Res Function(_$ProfileModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? joinedAt = null,
    Object? situationistFootprint = null,
  }) {
    return _then(_$ProfileModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      situationistFootprint: null == situationistFootprint
          ? _value.situationistFootprint
          : situationistFootprint // ignore: cast_nullable_to_non_nullable
              as SituationistFootprint,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileModelImpl implements _ProfileModel {
  const _$ProfileModelImpl(
      {required this.userId,
      required this.joinedAt,
      required this.situationistFootprint});

  factory _$ProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileModelImplFromJson(json);

  @override
  final String userId;
  @override
  final DateTime joinedAt;
  @override
  final SituationistFootprint situationistFootprint;

  @override
  String toString() {
    return 'ProfileModel(userId: $userId, joinedAt: $joinedAt, situationistFootprint: $situationistFootprint)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.situationistFootprint, situationistFootprint) ||
                other.situationistFootprint == situationistFootprint));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, joinedAt, situationistFootprint);

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileModelImplCopyWith<_$ProfileModelImpl> get copyWith =>
      __$$ProfileModelImplCopyWithImpl<_$ProfileModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileModelImplToJson(
      this,
    );
  }
}

abstract class _ProfileModel implements ProfileModel {
  const factory _ProfileModel(
          {required final String userId,
          required final DateTime joinedAt,
          required final SituationistFootprint situationistFootprint}) =
      _$ProfileModelImpl;

  factory _ProfileModel.fromJson(Map<String, dynamic> json) =
      _$ProfileModelImpl.fromJson;

  @override
  String get userId;
  @override
  DateTime get joinedAt;
  @override
  SituationistFootprint get situationistFootprint;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileModelImplCopyWith<_$ProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SituationistFootprint _$SituationistFootprintFromJson(
    Map<String, dynamic> json) {
  return _SituationistFootprint.fromJson(json);
}

/// @nodoc
mixin _$SituationistFootprint {
  int get eventsParticipated => throw _privateConstructorUsedError;
  int get derivasCompleted => throw _privateConstructorUsedError;
  int get missionsCompleted => throw _privateConstructorUsedError;

  /// Serializes this SituationistFootprint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SituationistFootprint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SituationistFootprintCopyWith<SituationistFootprint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SituationistFootprintCopyWith<$Res> {
  factory $SituationistFootprintCopyWith(SituationistFootprint value,
          $Res Function(SituationistFootprint) then) =
      _$SituationistFootprintCopyWithImpl<$Res, SituationistFootprint>;
  @useResult
  $Res call(
      {int eventsParticipated, int derivasCompleted, int missionsCompleted});
}

/// @nodoc
class _$SituationistFootprintCopyWithImpl<$Res,
        $Val extends SituationistFootprint>
    implements $SituationistFootprintCopyWith<$Res> {
  _$SituationistFootprintCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SituationistFootprint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventsParticipated = null,
    Object? derivasCompleted = null,
    Object? missionsCompleted = null,
  }) {
    return _then(_value.copyWith(
      eventsParticipated: null == eventsParticipated
          ? _value.eventsParticipated
          : eventsParticipated // ignore: cast_nullable_to_non_nullable
              as int,
      derivasCompleted: null == derivasCompleted
          ? _value.derivasCompleted
          : derivasCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      missionsCompleted: null == missionsCompleted
          ? _value.missionsCompleted
          : missionsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SituationistFootprintImplCopyWith<$Res>
    implements $SituationistFootprintCopyWith<$Res> {
  factory _$$SituationistFootprintImplCopyWith(
          _$SituationistFootprintImpl value,
          $Res Function(_$SituationistFootprintImpl) then) =
      __$$SituationistFootprintImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int eventsParticipated, int derivasCompleted, int missionsCompleted});
}

/// @nodoc
class __$$SituationistFootprintImplCopyWithImpl<$Res>
    extends _$SituationistFootprintCopyWithImpl<$Res,
        _$SituationistFootprintImpl>
    implements _$$SituationistFootprintImplCopyWith<$Res> {
  __$$SituationistFootprintImplCopyWithImpl(_$SituationistFootprintImpl _value,
      $Res Function(_$SituationistFootprintImpl) _then)
      : super(_value, _then);

  /// Create a copy of SituationistFootprint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventsParticipated = null,
    Object? derivasCompleted = null,
    Object? missionsCompleted = null,
  }) {
    return _then(_$SituationistFootprintImpl(
      eventsParticipated: null == eventsParticipated
          ? _value.eventsParticipated
          : eventsParticipated // ignore: cast_nullable_to_non_nullable
              as int,
      derivasCompleted: null == derivasCompleted
          ? _value.derivasCompleted
          : derivasCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      missionsCompleted: null == missionsCompleted
          ? _value.missionsCompleted
          : missionsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SituationistFootprintImpl implements _SituationistFootprint {
  const _$SituationistFootprintImpl(
      {required this.eventsParticipated,
      required this.derivasCompleted,
      required this.missionsCompleted});

  factory _$SituationistFootprintImpl.fromJson(Map<String, dynamic> json) =>
      _$$SituationistFootprintImplFromJson(json);

  @override
  final int eventsParticipated;
  @override
  final int derivasCompleted;
  @override
  final int missionsCompleted;

  @override
  String toString() {
    return 'SituationistFootprint(eventsParticipated: $eventsParticipated, derivasCompleted: $derivasCompleted, missionsCompleted: $missionsCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SituationistFootprintImpl &&
            (identical(other.eventsParticipated, eventsParticipated) ||
                other.eventsParticipated == eventsParticipated) &&
            (identical(other.derivasCompleted, derivasCompleted) ||
                other.derivasCompleted == derivasCompleted) &&
            (identical(other.missionsCompleted, missionsCompleted) ||
                other.missionsCompleted == missionsCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, eventsParticipated, derivasCompleted, missionsCompleted);

  /// Create a copy of SituationistFootprint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SituationistFootprintImplCopyWith<_$SituationistFootprintImpl>
      get copyWith => __$$SituationistFootprintImplCopyWithImpl<
          _$SituationistFootprintImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SituationistFootprintImplToJson(
      this,
    );
  }
}

abstract class _SituationistFootprint implements SituationistFootprint {
  const factory _SituationistFootprint(
      {required final int eventsParticipated,
      required final int derivasCompleted,
      required final int missionsCompleted}) = _$SituationistFootprintImpl;

  factory _SituationistFootprint.fromJson(Map<String, dynamic> json) =
      _$SituationistFootprintImpl.fromJson;

  @override
  int get eventsParticipated;
  @override
  int get derivasCompleted;
  @override
  int get missionsCompleted;

  /// Create a copy of SituationistFootprint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SituationistFootprintImplCopyWith<_$SituationistFootprintImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ActivityLogItem _$ActivityLogItemFromJson(Map<String, dynamic> json) {
  return _ActivityLogItem.fromJson(json);
}

/// @nodoc
mixin _$ActivityLogItem {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get referenceId => throw _privateConstructorUsedError;
  DateTime get occurredAt => throw _privateConstructorUsedError;

  /// Serializes this ActivityLogItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityLogItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityLogItemCopyWith<ActivityLogItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityLogItemCopyWith<$Res> {
  factory $ActivityLogItemCopyWith(
          ActivityLogItem value, $Res Function(ActivityLogItem) then) =
      _$ActivityLogItemCopyWithImpl<$Res, ActivityLogItem>;
  @useResult
  $Res call({String id, String type, String referenceId, DateTime occurredAt});
}

/// @nodoc
class _$ActivityLogItemCopyWithImpl<$Res, $Val extends ActivityLogItem>
    implements $ActivityLogItemCopyWith<$Res> {
  _$ActivityLogItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityLogItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? referenceId = null,
    Object? occurredAt = null,
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
      referenceId: null == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String,
      occurredAt: null == occurredAt
          ? _value.occurredAt
          : occurredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityLogItemImplCopyWith<$Res>
    implements $ActivityLogItemCopyWith<$Res> {
  factory _$$ActivityLogItemImplCopyWith(_$ActivityLogItemImpl value,
          $Res Function(_$ActivityLogItemImpl) then) =
      __$$ActivityLogItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String type, String referenceId, DateTime occurredAt});
}

/// @nodoc
class __$$ActivityLogItemImplCopyWithImpl<$Res>
    extends _$ActivityLogItemCopyWithImpl<$Res, _$ActivityLogItemImpl>
    implements _$$ActivityLogItemImplCopyWith<$Res> {
  __$$ActivityLogItemImplCopyWithImpl(
      _$ActivityLogItemImpl _value, $Res Function(_$ActivityLogItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivityLogItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? referenceId = null,
    Object? occurredAt = null,
  }) {
    return _then(_$ActivityLogItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      referenceId: null == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String,
      occurredAt: null == occurredAt
          ? _value.occurredAt
          : occurredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityLogItemImpl implements _ActivityLogItem {
  const _$ActivityLogItemImpl(
      {required this.id,
      required this.type,
      required this.referenceId,
      required this.occurredAt});

  factory _$ActivityLogItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityLogItemImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String referenceId;
  @override
  final DateTime occurredAt;

  @override
  String toString() {
    return 'ActivityLogItem(id: $id, type: $type, referenceId: $referenceId, occurredAt: $occurredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityLogItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.occurredAt, occurredAt) ||
                other.occurredAt == occurredAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, referenceId, occurredAt);

  /// Create a copy of ActivityLogItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityLogItemImplCopyWith<_$ActivityLogItemImpl> get copyWith =>
      __$$ActivityLogItemImplCopyWithImpl<_$ActivityLogItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityLogItemImplToJson(
      this,
    );
  }
}

abstract class _ActivityLogItem implements ActivityLogItem {
  const factory _ActivityLogItem(
      {required final String id,
      required final String type,
      required final String referenceId,
      required final DateTime occurredAt}) = _$ActivityLogItemImpl;

  factory _ActivityLogItem.fromJson(Map<String, dynamic> json) =
      _$ActivityLogItemImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get referenceId;
  @override
  DateTime get occurredAt;

  /// Create a copy of ActivityLogItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityLogItemImplCopyWith<_$ActivityLogItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivityLogPage _$ActivityLogPageFromJson(Map<String, dynamic> json) {
  return _ActivityLogPage.fromJson(json);
}

/// @nodoc
mixin _$ActivityLogPage {
  List<ActivityLogItem> get items => throw _privateConstructorUsedError;
  String? get nextCursor => throw _privateConstructorUsedError;

  /// Serializes this ActivityLogPage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityLogPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityLogPageCopyWith<ActivityLogPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityLogPageCopyWith<$Res> {
  factory $ActivityLogPageCopyWith(
          ActivityLogPage value, $Res Function(ActivityLogPage) then) =
      _$ActivityLogPageCopyWithImpl<$Res, ActivityLogPage>;
  @useResult
  $Res call({List<ActivityLogItem> items, String? nextCursor});
}

/// @nodoc
class _$ActivityLogPageCopyWithImpl<$Res, $Val extends ActivityLogPage>
    implements $ActivityLogPageCopyWith<$Res> {
  _$ActivityLogPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityLogPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ActivityLogItem>,
      nextCursor: freezed == nextCursor
          ? _value.nextCursor
          : nextCursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityLogPageImplCopyWith<$Res>
    implements $ActivityLogPageCopyWith<$Res> {
  factory _$$ActivityLogPageImplCopyWith(_$ActivityLogPageImpl value,
          $Res Function(_$ActivityLogPageImpl) then) =
      __$$ActivityLogPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ActivityLogItem> items, String? nextCursor});
}

/// @nodoc
class __$$ActivityLogPageImplCopyWithImpl<$Res>
    extends _$ActivityLogPageCopyWithImpl<$Res, _$ActivityLogPageImpl>
    implements _$$ActivityLogPageImplCopyWith<$Res> {
  __$$ActivityLogPageImplCopyWithImpl(
      _$ActivityLogPageImpl _value, $Res Function(_$ActivityLogPageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivityLogPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextCursor = freezed,
  }) {
    return _then(_$ActivityLogPageImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ActivityLogItem>,
      nextCursor: freezed == nextCursor
          ? _value.nextCursor
          : nextCursor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityLogPageImpl implements _ActivityLogPage {
  const _$ActivityLogPageImpl(
      {required final List<ActivityLogItem> items, this.nextCursor})
      : _items = items;

  factory _$ActivityLogPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityLogPageImplFromJson(json);

  final List<ActivityLogItem> _items;
  @override
  List<ActivityLogItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? nextCursor;

  @override
  String toString() {
    return 'ActivityLogPage(items: $items, nextCursor: $nextCursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityLogPageImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_items), nextCursor);

  /// Create a copy of ActivityLogPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityLogPageImplCopyWith<_$ActivityLogPageImpl> get copyWith =>
      __$$ActivityLogPageImplCopyWithImpl<_$ActivityLogPageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityLogPageImplToJson(
      this,
    );
  }
}

abstract class _ActivityLogPage implements ActivityLogPage {
  const factory _ActivityLogPage(
      {required final List<ActivityLogItem> items,
      final String? nextCursor}) = _$ActivityLogPageImpl;

  factory _ActivityLogPage.fromJson(Map<String, dynamic> json) =
      _$ActivityLogPageImpl.fromJson;

  @override
  List<ActivityLogItem> get items;
  @override
  String? get nextCursor;

  /// Create a copy of ActivityLogPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityLogPageImplCopyWith<_$ActivityLogPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
