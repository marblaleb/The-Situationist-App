// mobile/test/features/events/create_hub_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:situationist/features/events/bloc/create_hub_bloc.dart';
import 'package:situationist/features/profile/data/i_profile_repository.dart';
import 'package:situationist/shared/models/creation_limits_model.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late MockProfileRepository repo;

  setUp(() {
    repo = MockProfileRepository();
  });

  group('CreateHubBloc', () {
    blocTest<CreateHubBloc, CreateHubState>(
      'emite CreateHubLoaded con los límites al inicializarse',
      build: () {
        when(() => repo.getCreationLimits()).thenAnswer((_) async =>
            const CreationLimitsModel(
                eventsToday: 1, missionsToday: 0, dailyLimit: 2));
        return CreateHubBloc(repository: repo);
      },
      expect: () => [isA<CreateHubLoading>(), isA<CreateHubLoaded>()],
      verify: (bloc) {
        final state = bloc.state as CreateHubLoaded;
        expect(state.limits.eventsToday, 1);
        expect(state.limits.missionsToday, 0);
        expect(state.limits.dailyLimit, 2);
      },
    );

    blocTest<CreateHubBloc, CreateHubState>(
      'emite CreateHubError cuando falla la carga',
      build: () {
        when(() => repo.getCreationLimits())
            .thenThrow(Exception('network error'));
        return CreateHubBloc(repository: repo);
      },
      expect: () => [isA<CreateHubLoading>(), isA<CreateHubError>()],
    );
  });
}
