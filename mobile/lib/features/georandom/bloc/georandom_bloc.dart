import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/location/location_service.dart';
import '../../../shared/models/georandom_point_model.dart';
import '../data/i_georandom_repository.dart';

// Events
abstract class GeoRandomEvent extends Equatable {}

class GeoRandomGenerateRequested extends GeoRandomEvent {
  final int radiusMeters;
  final String type;

  GeoRandomGenerateRequested({required this.radiusMeters, required this.type});

  @override
  List<Object?> get props => [radiusMeters, type];
}

// States
abstract class GeoRandomState extends Equatable {}

class GeoRandomIdle extends GeoRandomState {
  @override
  List<Object?> get props => [];
}

class GeoRandomLoading extends GeoRandomState {
  @override
  List<Object?> get props => [];
}

class GeoRandomSuccess extends GeoRandomState {
  final GeoRandomPointModel point;
  GeoRandomSuccess(this.point);
  @override
  List<Object?> get props => [point];
}

class GeoRandomPermissionRequired extends GeoRandomState {
  final LocationPermissionStatus status;
  GeoRandomPermissionRequired(this.status);
  @override
  List<Object?> get props => [status];
}

class GeoRandomError extends GeoRandomState {
  final String message;
  GeoRandomError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class GeoRandomBloc extends Bloc<GeoRandomEvent, GeoRandomState> {
  final IGeoRandomRepository _repository;
  final LocationService _locationService;

  GeoRandomBloc({
    required IGeoRandomRepository repository,
    required LocationService locationService,
  })  : _repository = repository,
        _locationService = locationService,
        super(GeoRandomIdle()) {
    on<GeoRandomGenerateRequested>(_onGenerateRequested);
  }

  Future<void> _onGenerateRequested(
    GeoRandomGenerateRequested event,
    Emitter<GeoRandomState> emit,
  ) async {
    emit(GeoRandomLoading());

    final permission = await _locationService.ensureLocationPermission();
    if (permission != LocationPermissionStatus.granted) {
      emit(GeoRandomPermissionRequired(permission));
      return;
    }

    try {
      final (lat, lng) = await _locationService.getCurrentPosition();
      final point = await _repository.generate(
        lat: lat,
        lng: lng,
        radiusMeters: event.radiusMeters,
        type: event.type,
      );
      emit(GeoRandomSuccess(point));
    } catch (e) {
      emit(GeoRandomError(e.toString()));
    }
  }
}
