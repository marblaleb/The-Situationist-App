import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/location/location_service.dart';
import '../../../core/realtime/signalr_service.dart';
import '../../../features/events/data/i_events_repository.dart';
import '../../../shared/models/event_model.dart';

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
  final String? selectedEventId;

  MapReady({
    required this.lat,
    required this.lng,
    required this.events,
    this.selectedEventId,
  });

  MapReady copyWith({
    double? lat,
    double? lng,
    List<EventModel>? events,
    String? selectedEventId,
    bool clearSelection = false,
  }) {
    return MapReady(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      events: events ?? this.events,
      selectedEventId:
          clearSelection ? null : selectedEventId ?? this.selectedEventId,
    );
  }

  @override
  List<Object?> get props => [lat, lng, events, selectedEventId];
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
    on<_MapEventExpired>(_onExpired);
    on<_MapEventFull>(_onFull);
  }

  Future<void> _onInitialized(
    MapInitialized event,
    Emitter<MapState> emit,
  ) async {
    try {
      final (lat, lng) = await _locationService.getCurrentPosition();
      final events = await _eventsRepository.getNearbyEvents(
        lat: lat,
        lng: lng,
        radius: 1000,
      );
      emit(MapReady(lat: lat, lng: lng, events: events));
      await _signalRService.connect();
      await _signalRService.joinZone(lat, lng);
      _signalRSubscription = _signalRService.events.listen((e) {
        if (e is EventExpiredSignal) add(_MapEventExpired(e.eventId));
        if (e is EventFullSignal) add(_MapEventFull(e.eventId));
      });
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

  void _onExpired(_MapEventExpired event, Emitter<MapState> emit) {
    if (state is MapReady) {
      final s = state as MapReady;
      emit(s.copyWith(
        events: s.events.where((e) => e.id != event.eventId).toList(),
        clearSelection: s.selectedEventId == event.eventId,
      ));
    }
  }

  void _onFull(_MapEventFull event, Emitter<MapState> emit) {
    if (state is MapReady) {
      final s = state as MapReady;
      emit(s.copyWith(
        events: s.events.map((e) {
          return e.id == event.eventId ? e.copyWith(status: 'Full') : e;
        }).toList(),
      ));
    }
  }

  @override
  Future<void> close() {
    _signalRSubscription?.cancel();
    return super.close();
  }
}
