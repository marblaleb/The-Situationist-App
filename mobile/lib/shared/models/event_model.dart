import 'package:freezed_annotation/freezed_annotation.dart';
part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    required String creatorId,
    required String title,
    required String description,
    required String actionType,
    required String interventionLevel,
    required double centroidLatitude,
    required double centroidLongitude,
    required int radiusMeters,
    required String visibility,
    int? maxParticipants,
    required DateTime startsAt,
    required DateTime expiresAt,
    required String status,
    required int participantCount,
    @Default(false) bool isParticipant,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);
}

@freezed
class CreateEventRequest with _$CreateEventRequest {
  const factory CreateEventRequest({
    required String title,
    required String description,
    required String actionType,
    required String interventionLevel,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required String visibility,
    int? maxParticipants,
    required DateTime startsAt,
    required int durationMinutes,
  }) = _CreateEventRequest;

  factory CreateEventRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateEventRequestFromJson(json);
}

@freezed
class GenerateEventRequest with _$GenerateEventRequest {
  const factory GenerateEventRequest({
    required String actionType,
    required String interventionLevel,
    double? latitude,
    double? longitude,
  }) = _GenerateEventRequest;

  factory GenerateEventRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateEventRequestFromJson(json);
}

@freezed
class GeneratedEventSuggestion with _$GeneratedEventSuggestion {
  const factory GeneratedEventSuggestion({
    required String title,
    required String description,
    required String actionType,
    required String interventionLevel,
  }) = _GeneratedEventSuggestion;

  factory GeneratedEventSuggestion.fromJson(Map<String, dynamic> json) =>
      _$GeneratedEventSuggestionFromJson(json);
}
