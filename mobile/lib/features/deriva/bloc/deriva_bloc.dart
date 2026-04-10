import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/i_deriva_repository.dart';

// Events
abstract class DerivaEvent extends Equatable {}

class DerivaStartRequested extends DerivaEvent {
  final String type;
  final double lat;
  final double lng;

  DerivaStartRequested({required this.type, required this.lat, required this.lng});

  @override
  List<Object?> get props => [type, lat, lng];
}

class DerivaNextInstructionRequested extends DerivaEvent {
  final double lat;
  final double lng;

  DerivaNextInstructionRequested({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];
}

class DerivaCompleteRequested extends DerivaEvent {
  @override
  List<Object?> get props => [];
}

class DerivaAbandonRequested extends DerivaEvent {
  @override
  List<Object?> get props => [];
}

// States
abstract class DerivaState extends Equatable {}

class DerivaIdle extends DerivaState {
  @override
  List<Object?> get props => [];
}

class DerivaStarting extends DerivaState {
  @override
  List<Object?> get props => [];
}

class DerivaActive extends DerivaState {
  final String sessionId;
  final String currentInstruction;
  final String type;
  final bool isWriting;

  DerivaActive({
    required this.sessionId,
    required this.currentInstruction,
    required this.type,
    required this.isWriting,
  });

  DerivaActive copyWith({
    String? currentInstruction,
    bool? isWriting,
  }) {
    return DerivaActive(
      sessionId: sessionId,
      currentInstruction: currentInstruction ?? this.currentInstruction,
      type: type,
      isWriting: isWriting ?? this.isWriting,
    );
  }

  @override
  List<Object?> get props => [sessionId, currentInstruction, type, isWriting];
}

class DerivaCompleted extends DerivaState {
  @override
  List<Object?> get props => [];
}

class DerivaError extends DerivaState {
  final String message;
  DerivaError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class DerivaBloc extends Bloc<DerivaEvent, DerivaState> {
  final IDerivaRepository _repository;

  DerivaBloc({required IDerivaRepository repository})
      : _repository = repository,
        super(DerivaIdle()) {
    on<DerivaStartRequested>(_onStartRequested);
    on<DerivaNextInstructionRequested>(_onNextInstruction);
    on<DerivaCompleteRequested>(_onCompleteRequested);
    on<DerivaAbandonRequested>(_onAbandonRequested);
  }

  Future<void> _onStartRequested(
    DerivaStartRequested event,
    Emitter<DerivaState> emit,
  ) async {
    emit(DerivaStarting());
    try {
      final session = await _repository.startSession(
        type: event.type,
        lat: event.lat,
        lng: event.lng,
      );
      emit(DerivaActive(
        sessionId: session.id,
        currentInstruction: session.firstInstruction,
        type: session.type,
        isWriting: true,
      ));
    } catch (e) {
      emit(DerivaError(e.toString()));
    }
  }

  Future<void> _onNextInstruction(
    DerivaNextInstructionRequested event,
    Emitter<DerivaState> emit,
  ) async {
    if (state is! DerivaActive) return;
    final current = state as DerivaActive;
    try {
      final instruction = await _repository.getNextInstruction(
        sessionId: current.sessionId,
        lat: event.lat,
        lng: event.lng,
      );
      emit(current.copyWith(
        currentInstruction: instruction.content,
        isWriting: true,
      ));
    } catch (e) {
      emit(DerivaError(e.toString()));
    }
  }

  Future<void> _onCompleteRequested(
    DerivaCompleteRequested event,
    Emitter<DerivaState> emit,
  ) async {
    if (state is! DerivaActive) return;
    final sessionId = (state as DerivaActive).sessionId;
    await _repository.completeSession(sessionId);
    emit(DerivaCompleted());
  }

  Future<void> _onAbandonRequested(
    DerivaAbandonRequested event,
    Emitter<DerivaState> emit,
  ) async {
    if (state is! DerivaActive) return;
    final sessionId = (state as DerivaActive).sessionId;
    await _repository.abandonSession(sessionId);
    emit(DerivaIdle());
  }
}
