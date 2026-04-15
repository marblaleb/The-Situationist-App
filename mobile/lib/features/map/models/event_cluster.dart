import '../../../shared/models/event_model.dart';

class EventCluster {
  final double lat;
  final double lng;
  final List<EventModel> events;

  const EventCluster({
    required this.lat,
    required this.lng,
    required this.events,
  });

  bool get isSingle => events.length == 1;
  EventModel get single => events.first;
}
