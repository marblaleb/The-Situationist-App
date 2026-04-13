// mobile/lib/features/events/bloc/create_hub_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../profile/data/i_profile_repository.dart';
import '../../../shared/models/creation_limits_model.dart';

// Events
abstract class CreateHubEvent extends Equatable {}

class CreateHubLimitsRequested extends CreateHubEvent {
  @override
  List<Object?> get props => [];
}

// States
abstract class CreateHubState extends Equatable {}

class CreateHubInitial extends CreateHubState {
  @override
  List<Object?> get props => [];
}

class CreateHubLoading extends CreateHubState {
  @override
  List<Object?> get props => [];
}

class CreateHubLoaded extends CreateHubState {
  final CreationLimitsModel limits;
  CreateHubLoaded(this.limits);

  @override
  List<Object?> get props => [limits];
}

class CreateHubError extends CreateHubState {
  final String message;
  CreateHubError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CreateHubBloc extends Bloc<CreateHubEvent, CreateHubState> {
  final IProfileRepository _repository;

  CreateHubBloc({required IProfileRepository repository})
      : _repository = repository,
        super(CreateHubInitial()) {
    on<CreateHubLimitsRequested>(_onLimitsRequested);
    add(CreateHubLimitsRequested());
  }

  Future<void> _onLimitsRequested(
    CreateHubLimitsRequested event,
    Emitter<CreateHubState> emit,
  ) async {
    emit(CreateHubLoading());
    try {
      final limits = await _repository.getCreationLimits();
      emit(CreateHubLoaded(limits));
    } catch (e) {
      emit(CreateHubError(e.toString()));
    }
  }
}
