import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  ProfileLoaded({
    required this.profile,
    required this.activityItems,
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
      nextCursor: clearCursor ? null : nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [profile, activityItems, nextCursor, isLoadingMore];
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
      final profile = await _repository.getProfile();
      final activityPage = await _repository.getActivityLog();
      emit(ProfileLoaded(
        profile: profile,
        activityItems: activityPage.items,
        nextCursor: activityPage.nextCursor,
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
