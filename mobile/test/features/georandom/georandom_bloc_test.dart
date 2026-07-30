import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:situationist/core/location/location_service.dart';
import 'package:situationist/features/georandom/bloc/georandom_bloc.dart';
import 'package:situationist/features/georandom/data/i_georandom_repository.dart';
import 'package:situationist/shared/models/georandom_point_model.dart';

class MockGeoRandomRepository extends Mock implements IGeoRandomRepository {}
class MockLocationService extends Mock implements LocationService {}

final _mockPoint = GeoRandomPointModel(
  lat: 40.42,
  lng: -3.70,
  type: 'Atractor',
  generatedAt: DateTime.now(),
);

void main() {
  late MockGeoRandomRepository repo;
  late MockLocationService location;

  setUp(() {
    repo = MockGeoRandomRepository();
    location = MockLocationService();
  });

  group('GeoRandomBloc', () {
    blocTest<GeoRandomBloc, GeoRandomState>(
      'emite GeoRandomSuccess al generar exitosamente con permiso otorgado',
      build: () {
        when(() => location.ensureLocationPermission())
            .thenAnswer((_) async => LocationPermissionStatus.granted);
        when(() => location.getCurrentPosition())
            .thenAnswer((_) async => (40.4168, -3.7038));
        when(() => repo.generate(
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              radiusMeters: any(named: 'radiusMeters'),
              type: any(named: 'type'),
            )).thenAnswer((_) async => _mockPoint);
        return GeoRandomBloc(repository: repo, locationService: location);
      },
      act: (bloc) => bloc.add(GeoRandomGenerateRequested(radiusMeters: 2000, type: 'Atractor')),
      expect: () => [
        isA<GeoRandomLoading>(),
        isA<GeoRandomSuccess>(),
      ],
    );

    blocTest<GeoRandomBloc, GeoRandomState>(
      'emite GeoRandomPermissionRequired(denied) cuando el permiso está denegado',
      build: () {
        when(() => location.ensureLocationPermission())
            .thenAnswer((_) async => LocationPermissionStatus.denied);
        return GeoRandomBloc(repository: repo, locationService: location);
      },
      act: (bloc) => bloc.add(GeoRandomGenerateRequested(radiusMeters: 2000, type: 'Atractor')),
      expect: () => [
        isA<GeoRandomLoading>(),
        isA<GeoRandomPermissionRequired>(),
      ],
      verify: (bloc) {
        final state = bloc.state as GeoRandomPermissionRequired;
        expect(state.status, LocationPermissionStatus.denied);
      },
    );

    blocTest<GeoRandomBloc, GeoRandomState>(
      'emite GeoRandomPermissionRequired(deniedForever) cuando el permiso está denegado para siempre',
      build: () {
        when(() => location.ensureLocationPermission())
            .thenAnswer((_) async => LocationPermissionStatus.deniedForever);
        return GeoRandomBloc(repository: repo, locationService: location);
      },
      act: (bloc) => bloc.add(GeoRandomGenerateRequested(radiusMeters: 2000, type: 'Atractor')),
      expect: () => [
        isA<GeoRandomLoading>(),
        isA<GeoRandomPermissionRequired>(),
      ],
      verify: (bloc) {
        final state = bloc.state as GeoRandomPermissionRequired;
        expect(state.status, LocationPermissionStatus.deniedForever);
      },
    );

    blocTest<GeoRandomBloc, GeoRandomState>(
      'emite GeoRandomError cuando el repositorio falla',
      build: () {
        when(() => location.ensureLocationPermission())
            .thenAnswer((_) async => LocationPermissionStatus.granted);
        when(() => location.getCurrentPosition())
            .thenAnswer((_) async => (40.4168, -3.7038));
        when(() => repo.generate(
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              radiusMeters: any(named: 'radiusMeters'),
              type: any(named: 'type'),
            )).thenThrow(Exception('503'));
        return GeoRandomBloc(repository: repo, locationService: location);
      },
      act: (bloc) => bloc.add(GeoRandomGenerateRequested(radiusMeters: 2000, type: 'Atractor')),
      expect: () => [
        isA<GeoRandomLoading>(),
        isA<GeoRandomError>(),
      ],
    );
  });
}
