import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/models/mission_model.dart';
import '../../../shared/models/profile_model.dart';
import '../data/i_profile_repository.dart';

// Events
abstract class ProfileEvent extends Equatable {}

class ProfileLoadRequested extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class ProfileActivityPageRequested extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

// States
abstract class ProfileState extends Equatable {}

class ProfileInitial extends ProfileState {
  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {
  @override
  List<Object?> get props => [];
}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  final List<ActivityLogItem> activityItems;
  final String? nextCursor;
  final bool isLoadingMore;
  final List<EventModel> createdEvents;
  final List<MissionModel> createdMissions;

  ProfileLoaded({
    required this.profile,
    required this.activityItems,
    required this.createdEvents,
    required this.createdMissions,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  ProfileLoaded copyWith({
    List<ActivityLogItem>? activityItems,
    String? nextCursor,
    bool? isLoadingMore,
    bool clearCursor = false,
  }) {
    return ProfileLoaded(
      profile: profile,
      activityItems: activityItems ?? this.activityItems,
      createdEvents: createdEvents,
      createdMissions: createdMissions,
      nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [profile, activityItems, createdEvents, createdMissions, nextCursor, isLoadingMore];
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IProfileRepository _repository;

  ProfileBloc({required IProfileRepository repository})
      : _repository = repository,
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileActivityPageRequested>(_onActivityPageRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final results = await Future.wait([
        _repository.getProfile(),
        _repository.getActivityLog(),
        _repository.getCreatedEvents(),
        _repository.getCreatedMissions(),
      ]);
      emit(ProfileLoaded(
        profile: results[0] as ProfileModel,
        activityItems: (results[1] as ActivityLogPage).items,
        nextCursor: (results[1] as ActivityLogPage).nextCursor,
        createdEvents: results[2] as List<EventModel>,
        createdMissions: results[3] as List<MissionModel>,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onActivityPageRequested(
    ProfileActivityPageRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;
    if (current.nextCursor == null || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await _repository.getActivityLog(cursor: current.nextCursor);
      emit(current.copyWith(
        activityItems: [...current.activityItems, ...page.items],
        nextCursor: page.nextCursor,
        isLoadingMore: false,
        clearCursor: page.nextCursor == null,
      ));
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
