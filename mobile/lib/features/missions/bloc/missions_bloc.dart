import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/models/mission_model.dart';
import '../../../shared/models/mission_progress_model.dart';
import '../data/i_missions_repository.dart';

// Events
abstract class MissionsEvent extends Equatable {}

class MissionsNearbyRequested extends MissionsEvent {
  final double lat;
  final double lng;
  final int radius;

  MissionsNearbyRequested({required this.lat, required this.lng, required this.radius});

  @override
  List<Object?> get props => [lat, lng, radius];
}

class MissionStartRequested extends MissionsEvent {
  final String missionId;
  MissionStartRequested({required this.missionId});
  @override
  List<Object?> get props => [missionId];
}

class MissionAnswerSubmitted extends MissionsEvent {
  final String missionId;
  final String clueId;
  final String answer;

  MissionAnswerSubmitted({
    required this.missionId,
    required this.clueId,
    required this.answer,
  });

  @override
  List<Object?> get props => [missionId, clueId, answer];
}

class MissionHintRequested extends MissionsEvent {
  final String missionId;
  final String clueId;

  MissionHintRequested({required this.missionId, required this.clueId});

  @override
  List<Object?> get props => [missionId, clueId];
}

// States
abstract class MissionsState extends Equatable {}

class MissionsInitial extends MissionsState {
  @override
  List<Object?> get props => [];
}

class MissionsLoading extends MissionsState {
  @override
  List<Object?> get props => [];
}

class MissionsLoaded extends MissionsState {
  final List<MissionModel> missions;
  MissionsLoaded({required this.missions});
  @override
  List<Object?> get props => [missions];
}

class MissionsError extends MissionsState {
  final String message;
  MissionsError(this.message);
  @override
  List<Object?> get props => [message];
}

class MissionStarting extends MissionsState {
  @override
  List<Object?> get props => [];
}

class MissionInProgress extends MissionsState {
  final MissionProgressModel progress;
  final bool? lastAnswerCorrect;
  final String? hint;

  MissionInProgress({
    required this.progress,
    this.lastAnswerCorrect,
    this.hint,
  });

  MissionInProgress copyWith({
    MissionProgressModel? progress,
    bool? lastAnswerCorrect,
    String? hint,
    bool clearHint = false,
  }) {
    return MissionInProgress(
      progress: progress ?? this.progress,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
      hint: clearHint ? null : hint ?? this.hint,
    );
  }

  @override
  List<Object?> get props => [progress, lastAnswerCorrect, hint];
}

class MissionCompleted extends MissionsState {
  @override
  List<Object?> get props => [];
}

// BLoC
class MissionsBloc extends Bloc<MissionsEvent, MissionsState> {
  final IMissionsRepository _repository;

  MissionsBloc({required IMissionsRepository repository})
      : _repository = repository,
        super(MissionsInitial()) {
    on<MissionsNearbyRequested>(_onNearbyRequested);
    on<MissionStartRequested>(_onStartRequested);
    on<MissionAnswerSubmitted>(_onAnswerSubmitted);
    on<MissionHintRequested>(_onHintRequested);
  }

  Future<void> _onNearbyRequested(
    MissionsNearbyRequested event,
    Emitter<MissionsState> emit,
  ) async {
    emit(MissionsLoading());
    try {
      final missions = await _repository.getNearbyMissions(
        lat: event.lat,
        lng: event.lng,
        radius: event.radius,
      );
      emit(MissionsLoaded(missions: missions));
    } catch (e) {
      emit(MissionsError(e.toString()));
    }
  }

  Future<void> _onStartRequested(
    MissionStartRequested event,
    Emitter<MissionsState> emit,
  ) async {
    emit(MissionStarting());
    try {
      final progress = await _repository.startMission(event.missionId);
      emit(MissionInProgress(progress: progress));
    } catch (e) {
      emit(MissionsError(e.toString()));
    }
  }

  Future<void> _onAnswerSubmitted(
    MissionAnswerSubmitted event,
    Emitter<MissionsState> emit,
  ) async {
    if (state is! MissionInProgress) return;
    final current = state as MissionInProgress;

    final response = await _repository.submitAnswer(
      missionId: event.missionId,
      clueId: event.clueId,
      answer: event.answer,
    );

    if (response.missionCompleted) {
      emit(MissionCompleted());
      return;
    }

    if (response.correct && response.nextClue != null) {
      final updatedProgress = MissionProgressModel(
        progressId: current.progress.progressId,
        missionId: current.progress.missionId,
        status: current.progress.status,
        startedAt: current.progress.startedAt,
        hintsUsed: current.progress.hintsUsed,
        currentClue: response.nextClue,
      );
      emit(current.copyWith(
        progress: updatedProgress,
        lastAnswerCorrect: true,
        clearHint: true,
      ));
    } else {
      emit(current.copyWith(lastAnswerCorrect: false));
    }
  }

  Future<void> _onHintRequested(
    MissionHintRequested event,
    Emitter<MissionsState> emit,
  ) async {
    if (state is! MissionInProgress) return;
    final current = state as MissionInProgress;
    try {
      final hint = await _repository.requestHint(
        missionId: event.missionId,
        clueId: event.clueId,
      );
      emit(current.copyWith(hint: hint));
    } catch (e) {
      emit(current.copyWith(lastAnswerCorrect: null));
    }
  }
}
