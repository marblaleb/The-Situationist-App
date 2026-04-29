// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EventModel _$EventModelFromJson(Map<String, dynamic> json) {
  return _EventModel.fromJson(json);
}

/// @nodoc
mixin _$EventModel {
  String get id => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get actionType => throw _privateConstructorUsedError;
  String get interventionLevel => throw _privateConstructorUsedError;
  double get centroidLatitude => throw _privateConstructorUsedError;
  double get centroidLongitude => throw _privateConstructorUsedError;
  int get radiusMeters => throw _privateConstructorUsedError;
  String get visibility => throw _privateConstructorUsedError;
  int? get maxParticipants => throw _privateConstructorUsedError;
  DateTime get startsAt => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get participantCount => throw _privateConstructorUsedError;
  bool get isParticipant => throw _privateConstructorUsedError;

  /// Serializes this EventModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventModelCopyWith<EventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventModelCopyWith<$Res> {
  factory $EventModelCopyWith(
          EventModel value, $Res Function(EventModel) then) =
      _$EventModelCopyWithImpl<$Res, EventModel>;
  @useResult
  $Res call(
      {String id,
      String creatorId,
      String title,
      String description,
      String actionType,
      String interventionLevel,
      double centroidLatitude,
      double centroidLongitude,
      int radiusMeters,
      String visibility,
      int? maxParticipants,
      DateTime startsAt,
      DateTime expiresAt,
      String status,
      int participantCount,
      bool isParticipant});
}

/// @nodoc
class _$EventModelCopyWithImpl<$Res, $Val extends EventModel>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? creatorId = null,
    Object? title = null,
    Object? description = null,
    Object? actionType = null,
    Object? interventionLevel = null,
    Object? centroidLatitude = null,
    Object? centroidLongitude = null,
    Object? radiusMeters = null,
    Object? visibility = null,
    Object? maxParticipants = freezed,
    Object? startsAt = null,
    Object? expiresAt = null,
    Object? status = null,
    Object? participantCount = null,
    Object? isParticipant = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      interventionLevel: null == interventionLevel
          ? _value.interventionLevel
          : interventionLevel // ignore: cast_nullable_to_non_nullable
              as String,
      centroidLatitude: null == centroidLatitude
          ? _value.centroidLatitude
          : centroidLatitude // ignore: cast_nullable_to_non_nullable
              as double,
      centroidLongitude: null == centroidLongitude
          ? _value.centroidLongitude
          : centroidLongitude // ignore: cast_nullable_to_non_nullable
              as double,
      radiusMeters: null == radiusMeters
          ? _value.radiusMeters
          : radiusMeters // ignore: cast_nullable_to_non_nullable
              as int,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      maxParticipants: freezed == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int?,
      startsAt: null == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      participantCount: null == participantCount
          ? _value.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      isParticipant: null == isParticipant
          ? _value.isParticipant
          : isParticipant // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventModelImplCopyWith<$Res>
    implements $EventModelCopyWith<$Res> {
  factory _$$EventModelImplCopyWith(
          _$EventModelImpl value, $Res Function(_$EventModelImpl) then) =
      __$$EventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String creatorId,
      String title,
      String description,
      String actionType,
      String interventionLevel,
      double centroidLatitude,
      double centroidLongitude,
      int radiusMeters,
      String visibility,
      int? maxParticipants,
      DateTime startsAt,
      DateTime expiresAt,
      String status,
      int participantCount,
      bool isParticipant});
}

/// @nodoc
class __$$EventModelImplCopyWithImpl<$Res>
    extends _$EventModelCopyWithImpl<$Res, _$EventModelImpl>
    implements _$$EventModelImplCopyWith<$Res> {
  __$$EventModelImplCopyWithImpl(
      _$EventModelImpl _value, $Res Function(_$EventModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? creatorId = null,
    Object? title = null,
    Object? description = null,
    Object? actionType = null,
    Object? interventionLevel = null,
    Object? centroidLatitude = null,
    Object? centroidLongitude = null,
    Object? radiusMeters = null,
    Object? visibility = null,
    Object? maxParticipants = freezed,
    Object? startsAt = null,
    Object? expiresAt = null,
    Object? status = null,
    Object? participantCount = null,
    Object? isParticipant = null,
  }) {
    return _then(_$EventModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      interventionLevel: null == interventionLevel
          ? _value.interventionLevel
          : interventionLevel // ignore: cast_nullable_to_non_nullable
              as String,
      centroidLatitude: null == centroidLatitude
          ? _value.centroidLatitude
          : centroidLatitude // ignore: cast_nullable_to_non_nullable
              as double,
      centroidLongitude: null == centroidLongitude
          ? _value.centroidLongitude
          : centroidLongitude // ignore: cast_nullable_to_non_nullable
              as double,
      radiusMeters: null == radiusMeters
          ? _value.radiusMeters
          : radiusMeters // ignore: cast_nullable_to_non_nullable
              as int,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      maxParticipants: freezed == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int?,
      startsAt: null == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      participantCount: null == participantCount
          ? _value.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      isParticipant: null == isParticipant
          ? _value.isParticipant
          : isParticipant // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventModelImpl implements _EventModel {
  const _$EventModelImpl(
      {required this.id,
      required this.creatorId,
      required this.title,
      required this.description,
      required this.actionType,
      required this.interventionLevel,
      required this.centroidLatitude,
      required this.centroidLongitude,
      required this.radiusMeters,
      required this.visibility,
      this.maxParticipants,
      required this.startsAt,
      required this.expiresAt,
      required this.status,
      required this.participantCount,
      this.isParticipant = false});

  factory _$EventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventModelImplFromJson(json);

  @override
  final String id;
  @override
  final String creatorId;
  @override
  final String title;
  @override
  final String description;
  @override
  final String actionType;
  @override
  final String interventionLevel;
  @override
  final double centroidLatitude;
  @override
  final double centroidLongitude;
  @override
  final int radiusMeters;
  @override
  final String visibility;
  @override
  final int? maxParticipants;
  @override
  final DateTime startsAt;
  @override
  final DateTime expiresAt;
  @override
  final String status;
  @override
  final int participantCount;
  @override
  @JsonKey()
  final bool isParticipant;

  @override
  String toString() {
    return 'EventModel(id: $id, creatorId: $creatorId, title: $title, description: $description, actionType: $actionType, interventionLevel: $interventionLevel, centroidLatitude: $centroidLatitude, centroidLongitude: $centroidLongitude, radiusMeters: $radiusMeters, visibility: $visibility, maxParticipants: $maxParticipants, startsAt: $startsAt, expiresAt: $expiresAt, status: $status, participantCount: $participantCount, isParticipant: $isParticipant)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.interventionLevel, interventionLevel) ||
                other.interventionLevel == interventionLevel) &&
            (identical(other.centroidLatitude, centroidLatitude) ||
                other.centroidLatitude == centroidLatitude) &&
            (identical(other.centroidLongitude, centroidLongitude) ||
                other.centroidLongitude == centroidLongitude) &&
            (identical(other.radiusMeters, radiusMeters) ||
                other.radiusMeters == radiusMeters) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.startsAt, startsAt) ||
                other.startsAt == startsAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.participantCount, participantCount) ||
                other.participantCount == participantCount) &&
            (identical(other.isParticipant, isParticipant) ||
                other.isParticipant == isParticipant));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      creatorId,
      title,
      description,
      actionType,
      interventionLevel,
      centroidLatitude,
      centroidLongitude,
      radiusMeters,
      visibility,
      maxParticipants,
      startsAt,
      expiresAt,
      status,
      participantCount,
      isParticipant);

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventModelImplCopyWith<_$EventModelImpl> get copyWith =>
      __$$EventModelImplCopyWithImpl<_$EventModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventModelImplToJson(
      this,
    );
  }
}

abstract class _EventModel implements EventModel {
  const factory _EventModel(
      {required final String id,
      required final String creatorId,
      required final String title,
      required final String description,
      required final String actionType,
      required final String interventionLevel,
      required final double centroidLatitude,
      required final double centroidLongitude,
      required final int radiusMeters,
      required final String visibility,
      final int? maxParticipants,
      required final DateTime startsAt,
      required final DateTime expiresAt,
      required final String status,
      required final int participantCount,
      final bool isParticipant}) = _$EventModelImpl;

  factory _EventModel.fromJson(Map<String, dynamic> json) =
      _$EventModelImpl.fromJson;

  @override
  String get id;
  @override
  String get creatorId;
  @override
  String get title;
  @override
  String get description;
  @override
  String get actionType;
  @override
  String get interventionLevel;
  @override
  double get centroidLatitude;
  @override
  double get centroidLongitude;
  @override
  int get radiusMeters;
  @override
  String get visibility;
  @override
  int? get maxParticipants;
  @override
  DateTime get startsAt;
  @override
  DateTime get expiresAt;
  @override
  String get status;
  @override
  int get participantCount;
  @override
  bool get isParticipant;

  /// Create a copy of EventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventModelImplCopyWith<_$EventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateEventRequest _$CreateEventRequestFromJson(Map<String, dynamic> json) {
  return _CreateEventRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateEventRequest {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get actionType => throw _privateConstructorUsedError;
  String get interventionLevel => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  int get radiusMeters => throw _privateConstructorUsedError;
  String get visibility => throw _privateConstructorUsedError;
  int? get maxParticipants => throw _privateConstructorUsedError;
  DateTime get startsAt => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;

  /// Serializes this CreateEventRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateEventRequestCopyWith<CreateEventRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateEventRequestCopyWith<$Res> {
  factory $CreateEventRequestCopyWith(
          CreateEventRequest value, $Res Function(CreateEventRequest) then) =
      _$CreateEventRequestCopyWithImpl<$Res, CreateEventRequest>;
  @useResult
  $Res call(
      {String title,
      String description,
      String actionType,
      String interventionLevel,
      double latitude,
      double longitude,
      int radiusMeters,
      String visibility,
      int? maxParticipants,
      DateTime startsAt,
      int durationMinutes});
}

/// @nodoc
class _$CreateEventRequestCopyWithImpl<$Res, $Val extends CreateEventRequest>
    implements $CreateEventRequestCopyWith<$Res> {
  _$CreateEventRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? actionType = null,
    Object? interventionLevel = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? radiusMeters = null,
    Object? visibility = null,
    Object? maxParticipants = freezed,
    Object? startsAt = null,
    Object? durationMinutes = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      interventionLevel: null == interventionLevel
          ? _value.interventionLevel
          : interventionLevel // ignore: cast_nullable_to_non_nullable
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
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      maxParticipants: freezed == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int?,
      startsAt: null == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateEventRequestImplCopyWith<$Res>
    implements $CreateEventRequestCopyWith<$Res> {
  factory _$$CreateEventRequestImplCopyWith(_$CreateEventRequestImpl value,
          $Res Function(_$CreateEventRequestImpl) then) =
      __$$CreateEventRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String description,
      String actionType,
      String interventionLevel,
      double latitude,
      double longitude,
      int radiusMeters,
      String visibility,
      int? maxParticipants,
      DateTime startsAt,
      int durationMinutes});
}

/// @nodoc
class __$$CreateEventRequestImplCopyWithImpl<$Res>
    extends _$CreateEventRequestCopyWithImpl<$Res, _$CreateEventRequestImpl>
    implements _$$CreateEventRequestImplCopyWith<$Res> {
  __$$CreateEventRequestImplCopyWithImpl(_$CreateEventRequestImpl _value,
      $Res Function(_$CreateEventRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? actionType = null,
    Object? interventionLevel = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? radiusMeters = null,
    Object? visibility = null,
    Object? maxParticipants = freezed,
    Object? startsAt = null,
    Object? durationMinutes = null,
  }) {
    return _then(_$CreateEventRequestImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      interventionLevel: null == interventionLevel
          ? _value.interventionLevel
          : interventionLevel // ignore: cast_nullable_to_non_nullable
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
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      maxParticipants: freezed == maxParticipants
          ? _value.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int?,
      startsAt: null == startsAt
          ? _value.startsAt
          : startsAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateEventRequestImpl implements _CreateEventRequest {
  const _$CreateEventRequestImpl(
      {required this.title,
      required this.description,
      required this.actionType,
      required this.interventionLevel,
      required this.latitude,
      required this.longitude,
      required this.radiusMeters,
      required this.visibility,
      this.maxParticipants,
      required this.startsAt,
      required this.durationMinutes});

  factory _$CreateEventRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateEventRequestImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  @override
  final String actionType;
  @override
  final String interventionLevel;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final int radiusMeters;
  @override
  final String visibility;
  @override
  final int? maxParticipants;
  @override
  final DateTime startsAt;
  @override
  final int durationMinutes;

  @override
  String toString() {
    return 'CreateEventRequest(title: $title, description: $description, actionType: $actionType, interventionLevel: $interventionLevel, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, visibility: $visibility, maxParticipants: $maxParticipants, startsAt: $startsAt, durationMinutes: $durationMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateEventRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.interventionLevel, interventionLevel) ||
                other.interventionLevel == interventionLevel) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.radiusMeters, radiusMeters) ||
                other.radiusMeters == radiusMeters) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.startsAt, startsAt) ||
                other.startsAt == startsAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      description,
      actionType,
      interventionLevel,
      latitude,
      longitude,
      radiusMeters,
      visibility,
      maxParticipants,
      startsAt,
      durationMinutes);

  /// Create a copy of CreateEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateEventRequestImplCopyWith<_$CreateEventRequestImpl> get copyWith =>
      __$$CreateEventRequestImplCopyWithImpl<_$CreateEventRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateEventRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateEventRequest implements CreateEventRequest {
  const factory _CreateEventRequest(
      {required final String title,
      required final String description,
      required final String actionType,
      required final String interventionLevel,
      required final double latitude,
      required final double longitude,
      required final int radiusMeters,
      required final String visibility,
      final int? maxParticipants,
      required final DateTime startsAt,
      required final int durationMinutes}) = _$CreateEventRequestImpl;

  factory _CreateEventRequest.fromJson(Map<String, dynamic> json) =
      _$CreateEventRequestImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  String get actionType;
  @override
  String get interventionLevel;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  int get radiusMeters;
  @override
  String get visibility;
  @override
  int? get maxParticipants;
  @override
  DateTime get startsAt;
  @override
  int get durationMinutes;

  /// Create a copy of CreateEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateEventRequestImplCopyWith<_$CreateEventRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GenerateEventRequest _$GenerateEventRequestFromJson(Map<String, dynamic> json) {
  return _GenerateEventRequest.fromJson(json);
}

/// @nodoc
mixin _$GenerateEventRequest {
  String get actionType => throw _privateConstructorUsedError;
  String get interventionLevel => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;

  /// Serializes this GenerateEventRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GenerateEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenerateEventRequestCopyWith<GenerateEventRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerateEventRequestCopyWith<$Res> {
  factory $GenerateEventRequestCopyWith(GenerateEventRequest value,
          $Res Function(GenerateEventRequest) then) =
      _$GenerateEventRequestCopyWithImpl<$Res, GenerateEventRequest>;
  @useResult
  $Res call(
      {String actionType,
      String interventionLevel,
      double? latitude,
      double? longitude});
}

/// @nodoc
class _$GenerateEventRequestCopyWithImpl<$Res,
        $Val extends GenerateEventRequest>
    implements $GenerateEventRequestCopyWith<$Res> {
  _$GenerateEventRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenerateEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actionType = null,
    Object? interventionLevel = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_value.copyWith(
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      interventionLevel: null == interventionLevel
          ? _value.interventionLevel
          : interventionLevel // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$GenerateEventRequestImplCopyWith<$Res>
    implements $GenerateEventRequestCopyWith<$Res> {
  factory _$$GenerateEventRequestImplCopyWith(_$GenerateEventRequestImpl value,
          $Res Function(_$GenerateEventRequestImpl) then) =
      __$$GenerateEventRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String actionType,
      String interventionLevel,
      double? latitude,
      double? longitude});
}

/// @nodoc
class __$$GenerateEventRequestImplCopyWithImpl<$Res>
    extends _$GenerateEventRequestCopyWithImpl<$Res, _$GenerateEventRequestImpl>
    implements _$$GenerateEventRequestImplCopyWith<$Res> {
  __$$GenerateEventRequestImplCopyWithImpl(_$GenerateEventRequestImpl _value,
      $Res Function(_$GenerateEventRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of GenerateEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actionType = null,
    Object? interventionLevel = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_$GenerateEventRequestImpl(
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      interventionLevel: null == interventionLevel
          ? _value.interventionLevel
          : interventionLevel // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$GenerateEventRequestImpl implements _GenerateEventRequest {
  const _$GenerateEventRequestImpl(
      {required this.actionType,
      required this.interventionLevel,
      this.latitude,
      this.longitude});

  factory _$GenerateEventRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$GenerateEventRequestImplFromJson(json);

  @override
  final String actionType;
  @override
  final String interventionLevel;
  @override
  final double? latitude;
  @override
  final double? longitude;

  @override
  String toString() {
    return 'GenerateEventRequest(actionType: $actionType, interventionLevel: $interventionLevel, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerateEventRequestImpl &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.interventionLevel, interventionLevel) ||
                other.interventionLevel == interventionLevel) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, actionType, interventionLevel, latitude, longitude);

  /// Create a copy of GenerateEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerateEventRequestImplCopyWith<_$GenerateEventRequestImpl>
      get copyWith =>
          __$$GenerateEventRequestImplCopyWithImpl<_$GenerateEventRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GenerateEventRequestImplToJson(
      this,
    );
  }
}

abstract class _GenerateEventRequest implements GenerateEventRequest {
  const factory _GenerateEventRequest(
      {required final String actionType,
      required final String interventionLevel,
      final double? latitude,
      final double? longitude}) = _$GenerateEventRequestImpl;

  factory _GenerateEventRequest.fromJson(Map<String, dynamic> json) =
      _$GenerateEventRequestImpl.fromJson;

  @override
  String get actionType;
  @override
  String get interventionLevel;
  @override
  double? get latitude;
  @override
  double? get longitude;

  /// Create a copy of GenerateEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenerateEventRequestImplCopyWith<_$GenerateEventRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

GeneratedEventSuggestion _$GeneratedEventSuggestionFromJson(
    Map<String, dynamic> json) {
  return _GeneratedEventSuggestion.fromJson(json);
}

/// @nodoc
mixin _$GeneratedEventSuggestion {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get actionType => throw _privateConstructorUsedError;
  String get interventionLevel => throw _privateConstructorUsedError;

  /// Serializes this GeneratedEventSuggestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GeneratedEventSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeneratedEventSuggestionCopyWith<GeneratedEventSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeneratedEventSuggestionCopyWith<$Res> {
  factory $GeneratedEventSuggestionCopyWith(GeneratedEventSuggestion value,
          $Res Function(GeneratedEventSuggestion) then) =
      _$GeneratedEventSuggestionCopyWithImpl<$Res, GeneratedEventSuggestion>;
  @useResult
  $Res call(
      {String title,
      String description,
      String actionType,
      String interventionLevel});
}

/// @nodoc
class _$GeneratedEventSuggestionCopyWithImpl<$Res,
        $Val extends GeneratedEventSuggestion>
    implements $GeneratedEventSuggestionCopyWith<$Res> {
  _$GeneratedEventSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeneratedEventSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? actionType = null,
    Object? interventionLevel = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      interventionLevel: null == interventionLevel
          ? _value.interventionLevel
          : interventionLevel // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GeneratedEventSuggestionImplCopyWith<$Res>
    implements $GeneratedEventSuggestionCopyWith<$Res> {
  factory _$$GeneratedEventSuggestionImplCopyWith(
          _$GeneratedEventSuggestionImpl value,
          $Res Function(_$GeneratedEventSuggestionImpl) then) =
      __$$GeneratedEventSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String description,
      String actionType,
      String interventionLevel});
}

/// @nodoc
class __$$GeneratedEventSuggestionImplCopyWithImpl<$Res>
    extends _$GeneratedEventSuggestionCopyWithImpl<$Res,
        _$GeneratedEventSuggestionImpl>
    implements _$$GeneratedEventSuggestionImplCopyWith<$Res> {
  __$$GeneratedEventSuggestionImplCopyWithImpl(
      _$GeneratedEventSuggestionImpl _value,
      $Res Function(_$GeneratedEventSuggestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of GeneratedEventSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? actionType = null,
    Object? interventionLevel = null,
  }) {
    return _then(_$GeneratedEventSuggestionImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      interventionLevel: null == interventionLevel
          ? _value.interventionLevel
          : interventionLevel // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GeneratedEventSuggestionImpl implements _GeneratedEventSuggestion {
  const _$GeneratedEventSuggestionImpl(
      {required this.title,
      required this.description,
      required this.actionType,
      required this.interventionLevel});

  factory _$GeneratedEventSuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeneratedEventSuggestionImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  @override
  final String actionType;
  @override
  final String interventionLevel;

  @override
  String toString() {
    return 'GeneratedEventSuggestion(title: $title, description: $description, actionType: $actionType, interventionLevel: $interventionLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeneratedEventSuggestionImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.interventionLevel, interventionLevel) ||
                other.interventionLevel == interventionLevel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, title, description, actionType, interventionLevel);

  /// Create a copy of GeneratedEventSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeneratedEventSuggestionImplCopyWith<_$GeneratedEventSuggestionImpl>
      get copyWith => __$$GeneratedEventSuggestionImplCopyWithImpl<
          _$GeneratedEventSuggestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeneratedEventSuggestionImplToJson(
      this,
    );
  }
}

abstract class _GeneratedEventSuggestion implements GeneratedEventSuggestion {
  const factory _GeneratedEventSuggestion(
          {required final String title,
          required final String description,
          required final String actionType,
          required final String interventionLevel}) =
      _$GeneratedEventSuggestionImpl;

  factory _GeneratedEventSuggestion.fromJson(Map<String, dynamic> json) =
      _$GeneratedEventSuggestionImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  String get actionType;
  @override
  String get interventionLevel;

  /// Create a copy of GeneratedEventSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeneratedEventSuggestionImplCopyWith<_$GeneratedEventSuggestionImpl>
      get copyWith => throw _privateConstructorUsedError;
}
