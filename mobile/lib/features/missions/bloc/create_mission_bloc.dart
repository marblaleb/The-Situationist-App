import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/i_missions_repository.dart';

// ── Value object for clue form data ──────────────────────────────────────────

class ClueFormData extends Equatable {
  final String type;
  final String content;
  final String answer;
  final String hint;
  final bool isOptional;

  const ClueFormData({
    required this.type,
    required this.content,
    required this.answer,
    this.hint = '',
    this.isOptional = false,
  });

  @override
  List<Object?> get props => [type, content, answer, hint, isOptional];
}

// ── Events ────────────────────────────────────────────────────────────────────

abstract class CreateMissionEvent extends Equatable {}

class CreateMissionSubmitted extends CreateMissionEvent {
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final List<ClueFormData> clues;

  CreateMissionSubmitted({
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.clues,
  });

  @override
  List<Object?> get props => [title, description, latitude, longitude, radiusMeters, clues];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class CreateMissionState extends Equatable {}

class CreateMissionIdle extends CreateMissionState {
  @override
  List<Object?> get props => [];
}

class CreateMissionSubmitting extends CreateMissionState {
  @override
  List<Object?> get props => [];
}

class CreateMissionSuccess extends CreateMissionState {
  @override
  List<Object?> get props => [];
}

class CreateMissionError extends CreateMissionState {
  final String message;
  CreateMissionError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class CreateMissionBloc extends Bloc<CreateMissionEvent, CreateMissionState> {
  final IMissionsRepository _repository;

  CreateMissionBloc({required IMissionsRepository repository})
      : _repository = repository,
        super(CreateMissionIdle()) {
    on<CreateMissionSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    CreateMissionSubmitted event,
    Emitter<CreateMissionState> emit,
  ) async {
    emit(CreateMissionSubmitting());
    try {
      await _repository.createMission(
        title: event.title,
        description: event.description,
        latitude: event.latitude,
        longitude: event.longitude,
        radiusMeters: event.radiusMeters,
        clues: event.clues,
      );
      emit(CreateMissionSuccess());
    } catch (e) {
      emit(CreateMissionError(e.toString()));
    }
  }
}
