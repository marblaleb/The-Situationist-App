import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/models/event_model.dart';
import '../data/i_events_repository.dart';

// Events
abstract class EventsEvent extends Equatable {}

class EventsNearbyRequested extends EventsEvent {
  final double lat;
  final double lng;
  final int radius;

  EventsNearbyRequested({required this.lat, required this.lng, required this.radius});

  @override
  List<Object?> get props => [lat, lng, radius];
}

class EventParticipateRequested extends EventsEvent {
  final String eventId;
  final String role;

  EventParticipateRequested({required this.eventId, required this.role});

  @override
  List<Object?> get props => [eventId, role];
}

class EventExpiredReceived extends EventsEvent {
  final String eventId;

  EventExpiredReceived({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class EventFullReceived extends EventsEvent {
  final String eventId;

  EventFullReceived({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class EventCancelRequested extends EventsEvent {
  final String eventId;

  EventCancelRequested({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

// States
abstract class EventsState extends Equatable {}

class EventsInitial extends EventsState {
  @override
  List<Object?> get props => [];
}

class EventsLoading extends EventsState {
  @override
  List<Object?> get props => [];
}

class EventsLoaded extends EventsState {
  final List<EventModel> events;

  EventsLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

class EventsError extends EventsState {
  final String message;

  EventsError(this.message);

  @override
  List<Object?> get props => [message];
}

class EventsParticipating extends EventsState {
  final String eventId;

  EventsParticipating(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class EventParticipationSucceeded extends EventsState {
  final String eventId;

  EventParticipationSucceeded(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

// BLoC
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final IEventsRepository _repository;

  EventsBloc({required IEventsRepository repository})
      : _repository = repository,
        super(EventsInitial()) {
    on<EventsNearbyRequested>(_onNearbyRequested);
    on<EventParticipateRequested>(_onParticipateRequested);
    on<EventCancelRequested>(_onCancelRequested);
    on<EventExpiredReceived>(_onEventExpired);
    on<EventFullReceived>(_onEventFull);
  }

  Future<void> _onNearbyRequested(
    EventsNearbyRequested event,
    Emitter<EventsState> emit,
  ) async {
    emit(EventsLoading());
    try {
      final events = await _repository.getNearbyEvents(
        lat: event.lat,
        lng: event.lng,
        radius: event.radius,
      );
      emit(EventsLoaded(events: events));
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> _onParticipateRequested(
    EventParticipateRequested event,
    Emitter<EventsState> emit,
  ) async {
    emit(EventsParticipating(event.eventId));
    try {
      await _repository.participate(
        eventId: event.eventId,
        role: event.role,
      );
      emit(EventParticipationSucceeded(event.eventId));
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> _onCancelRequested(
    EventCancelRequested event,
    Emitter<EventsState> emit,
  ) async {
    try {
      await _repository.cancelEvent(event.eventId);
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  void _onEventExpired(EventExpiredReceived event, Emitter<EventsState> emit) {
    if (state is EventsLoaded) {
      final current = (state as EventsLoaded).events;
      emit(EventsLoaded(
        events: current.where((e) => e.id != event.eventId).toList(),
      ));
    }
  }

  void _onEventFull(EventFullReceived event, Emitter<EventsState> emit) {
    if (state is EventsLoaded) {
      final current = (state as EventsLoaded).events;
      emit(EventsLoaded(
        events: current.map((e) {
          if (e.id == event.eventId) {
            return e.copyWith(status: 'Full');
          }
          return e;
        }).toList(),
      ));
    }
  }
}
