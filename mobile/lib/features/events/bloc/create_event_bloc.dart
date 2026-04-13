import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/location/location_service.dart';
import '../../../shared/models/event_model.dart';
import '../data/i_events_repository.dart';

// Events
abstract class CreateEventEvent extends Equatable {}

class CreateEventGenerateRequested extends CreateEventEvent {
  final String actionType;
  final String interventionLevel;

  CreateEventGenerateRequested({
    required this.actionType,
    required this.interventionLevel,
  });

  @override
  List<Object?> get props => [actionType, interventionLevel];
}

class CreateEventSubmitted extends CreateEventEvent {
  final String title;
  final String description;
  final String actionType;
  final String interventionLevel;
  final String visibility;
  final int durationMinutes;
  final double latitude;
  final double longitude;

  CreateEventSubmitted({
    required this.title,
    required this.description,
    required this.actionType,
    required this.interventionLevel,
    required this.visibility,
    required this.durationMinutes,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        actionType,
        interventionLevel,
        visibility,
        durationMinutes,
        latitude,
        longitude,
      ];
}

// States
abstract class CreateEventState extends Equatable {}

class CreateEventInitial extends CreateEventState {
  @override
  List<Object?> get props => [];
}

class CreateEventGenerating extends CreateEventState {
  @override
  List<Object?> get props => [];
}

class CreateEventSuggested extends CreateEventState {
  final GeneratedEventSuggestion suggestion;

  CreateEventSuggested(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

class CreateEventSubmitting extends CreateEventState {
  @override
  List<Object?> get props => [];
}

class CreateEventSuccess extends CreateEventState {
  final EventModel event;

  CreateEventSuccess(this.event);

  @override
  List<Object?> get props => [event];
}

class CreateEventError extends CreateEventState {
  final String message;

  CreateEventError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  final IEventsRepository _repository;
  final LocationService _locationService;

  CreateEventBloc({
    required IEventsRepository repository,
    required LocationService locationService,
  })  : _repository = repository,
        _locationService = locationService,
        super(CreateEventInitial()) {
    on<CreateEventGenerateRequested>(_onGenerateRequested);
    on<CreateEventSubmitted>(_onSubmitted);
  }

  Future<void> _onGenerateRequested(
    CreateEventGenerateRequested event,
    Emitter<CreateEventState> emit,
  ) async {
    emit(CreateEventGenerating());
    try {
      final (lat, lng) = await _locationService.getCurrentPosition();
      final suggestion = await _repository.generateEvent(
        GenerateEventRequest(
          actionType: event.actionType,
          interventionLevel: event.interventionLevel,
          latitude: lat,
          longitude: lng,
        ),
      );
      emit(CreateEventSuggested(suggestion));
    } catch (e) {
      emit(CreateEventError(e.toString()));
    }
  }

  Future<void> _onSubmitted(
    CreateEventSubmitted event,
    Emitter<CreateEventState> emit,
  ) async {
    emit(CreateEventSubmitting());
    try {
      final created = await _repository.createEvent(
        CreateEventRequest(
          title: event.title,
          description: event.description,
          actionType: event.actionType,
          interventionLevel: event.interventionLevel,
          latitude: event.latitude,
          longitude: event.longitude,
          radiusMeters: 200,
          visibility: event.visibility,
          startsAt: DateTime.now().toUtc(),
          durationMinutes: event.durationMinutes,
        ),
      );
      emit(CreateEventSuccess(created));
    } catch (e) {
      emit(CreateEventError(e.toString()));
    }
  }
}
