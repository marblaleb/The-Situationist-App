import 'dart:async';
import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/location/location_service.dart';
import '../../../core/realtime/signalr_service.dart';
import '../../../features/events/data/i_events_repository.dart';
import '../../../shared/models/event_model.dart';
import '../models/event_cluster.dart';

// Groups events within [thresholdMeters] of each other into clusters.
List<EventCluster> _clusterEvents(List<EventModel> events, {double thresholdMeters = 50}) {
  final clusters = <EventCluster>[];
  final used = <int>{};

  for (int i = 0; i < events.length; i++) {
    if (used.contains(i)) continue;
    final group = [events[i]];
    used.add(i);

    for (int j = i + 1; j < events.length; j++) {
      if (used.contains(j)) continue;
      final dist = _haversineMeters(
        events[i].centroidLatitude, events[i].centroidLongitude,
        events[j].centroidLatitude, events[j].centroidLongitude,
      );
      if (dist <= thresholdMeters) {
        group.add(events[j]);
        used.add(j);
      }
    }

    final lat = group.map((e) => e.centroidLatitude).reduce((a, b) => a + b) / group.length;
    final lng = group.map((e) => e.centroidLongitude).reduce((a, b) => a + b) / group.length;
    clusters.add(EventCluster(lat: lat, lng: lng, events: group));
  }
  return clusters;
}

double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _rad(double deg) => deg * pi / 180;

abstract class MapEvent extends Equatable {}

class MapInitialized extends MapEvent {
  @override
  List<Object?> get props => [];
}

class MapEventSelected extends MapEvent {
  final String? eventId;
  MapEventSelected(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class MapClusterSelected extends MapEvent {
  final EventCluster? cluster;
  MapClusterSelected(this.cluster);
  @override
  List<Object?> get props => [cluster];
}

class _MapEventExpired extends MapEvent {
  final String eventId;
  _MapEventExpired(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class _MapEventFull extends MapEvent {
  final String eventId;
  _MapEventFull(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

abstract class MapState extends Equatable {}

class MapLoading extends MapState {
  @override
  List<Object?> get props => [];
}

class MapReady extends MapState {
  final double lat;
  final double lng;
  final List<EventModel> events;
  final List<EventCluster> clusters;
  final String? selectedEventId;
  final EventCluster? selectedCluster;

  MapReady({
    required this.lat,
    required this.lng,
    required this.events,
    required this.clusters,
    this.selectedEventId,
    this.selectedCluster,
  });

  MapReady copyWith({
    List<EventModel>? events,
    List<EventCluster>? clusters,
    String? selectedEventId,
    EventCluster? selectedCluster,
    bool clearSelection = false,
    bool clearCluster = false,
  }) {
    return MapReady(
      lat: lat,
      lng: lng,
      events: events ?? this.events,
      clusters: clusters ?? this.clusters,
      selectedEventId: clearSelection ? null : selectedEventId ?? this.selectedEventId,
      selectedCluster: clearCluster ? null : selectedCluster ?? this.selectedCluster,
    );
  }

  EventModel? get selectedEvent =>
      selectedEventId == null ? null : events.where((e) => e.id == selectedEventId).firstOrNull;

  @override
  List<Object?> get props => [lat, lng, events, clusters, selectedEventId, selectedCluster];
}

class MapError extends MapState {
  final String message;
  MapError(this.message);
  @override
  List<Object?> get props => [message];
}

class MapBloc extends Bloc<MapEvent, MapState> {
  final IEventsRepository _eventsRepository;
  final LocationService _locationService;
  final SignalRService _signalRService;
  StreamSubscription<SignalREvent>? _signalRSubscription;

  MapBloc({
    required IEventsRepository eventsRepository,
    required LocationService locationService,
    required SignalRService signalRService,
  })  : _eventsRepository = eventsRepository,
        _locationService = locationService,
        _signalRService = signalRService,
        super(MapLoading()) {
    on<MapInitialized>(_onInitialized);
    on<MapEventSelected>(_onEventSelected);
    on<MapClusterSelected>(_onClusterSelected);
    on<_MapEventExpired>(_onExpired);
    on<_MapEventFull>(_onFull);
  }

  Future<void> _onInitialized(
    MapInitialized event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());
    try {
      final (lat, lng) = await _locationService.getCurrentPosition();
      final events = await _eventsRepository.getNearbyEvents(
        lat: lat,
        lng: lng,
        radius: 1000,
      );
      final clusters = _clusterEvents(events);
      emit(MapReady(lat: lat, lng: lng, events: events, clusters: clusters));
      // SignalR is optional — failure must not overwrite the working map state
      try {
        await _signalRService.connect();
        await _signalRService.joinZone(lat, lng);
        _signalRSubscription = _signalRService.events.listen((e) {
          if (e is EventExpiredSignal) add(_MapEventExpired(e.eventId));
          if (e is EventFullSignal) add(_MapEventFull(e.eventId));
        });
      } catch (_) {}
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  void _onEventSelected(MapEventSelected event, Emitter<MapState> emit) {
    if (state is MapReady) {
      if (event.eventId == null) {
        emit((state as MapReady).copyWith(clearSelection: true));
      } else {
        emit((state as MapReady).copyWith(selectedEventId: event.eventId));
      }
    }
  }

  void _onClusterSelected(MapClusterSelected event, Emitter<MapState> emit) {
    if (state is! MapReady) return;
    final current = state as MapReady;
    emit(current.copyWith(
      selectedCluster: event.cluster,
      clearCluster: event.cluster == null,
      clearSelection: true,
    ));
  }

  void _onExpired(_MapEventExpired event, Emitter<MapState> emit) {
    if (state is MapReady) {
      final s = state as MapReady;
      final updated = s.events.where((e) => e.id != event.eventId).toList();
      emit(s.copyWith(
        events: updated,
        clusters: _clusterEvents(updated),
        clearSelection: s.selectedEventId == event.eventId,
      ));
    }
  }

  void _onFull(_MapEventFull event, Emitter<MapState> emit) {
    if (state is MapReady) {
      final s = state as MapReady;
      final updated = s.events.map((e) {
        return e.id == event.eventId ? e.copyWith(status: 'Full') : e;
      }).toList();
      emit(s.copyWith(events: updated, clusters: _clusterEvents(updated)));
    }
  }

  @override
  Future<void> close() {
    _signalRSubscription?.cancel();
    return super.close();
  }
}
