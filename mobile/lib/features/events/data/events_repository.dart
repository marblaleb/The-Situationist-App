import '../../../core/network/api_client.dart';
import '../../../shared/models/event_model.dart';
import 'i_events_repository.dart';

class EventsRepository implements IEventsRepository {
  final ApiClient _client;

  EventsRepository(this._client);

  @override
  Future<List<EventModel>> getNearbyEvents({
    required double lat,
    required double lng,
    required int radius,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/events',
      queryParameters: {'lat': lat, 'lng': lng, 'radius': radius},
    );
    return (response.data as List)
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EventModel> getEventDetail({
    required String id,
    required double lat,
    required double lng,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/events/$id',
      queryParameters: {'lat': lat, 'lng': lng},
    );
    return EventModel.fromJson(response.data!);
  }

  @override
  Future<EventModel> createEvent(CreateEventRequest request) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/events',
      data: request.toJson(),
    );
    return EventModel.fromJson(response.data!);
  }

  @override
  Future<GeneratedEventSuggestion> generateEvent(
      GenerateEventRequest request) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/events/generate',
      data: request.toJson(),
    );
    return GeneratedEventSuggestion.fromJson(response.data!);
  }

  @override
  Future<void> participate({
    required String eventId,
    required String role,
  }) async {
    await _client.post<void>(
      '/events/$eventId/participate',
      data: {'role': role},
    );
  }

  @override
  Future<void> cancelEvent(String eventId) async {
    await _client.delete<void>('/events/$eventId');
  }
}
