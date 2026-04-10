import '../../../shared/models/event_model.dart';

abstract class IEventsRepository {
  Future<List<EventModel>> getNearbyEvents({
    required double lat,
    required double lng,
    required int radius,
  });

  Future<EventModel> getEventDetail({
    required String id,
    required double lat,
    required double lng,
  });

  Future<EventModel> createEvent(CreateEventRequest request);

  Future<GeneratedEventSuggestion> generateEvent(GenerateEventRequest request);

  Future<void> participate({
    required String eventId,
    required String role,
  });

  Future<void> cancelEvent(String eventId);
}
